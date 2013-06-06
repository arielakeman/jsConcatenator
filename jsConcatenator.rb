
# CONFIG

MIRROR_DIR = "../js"
CLOSURE_COMPILER_JAR_NAME = "closure-compiler.jar"

# regex to find the type of import statement used to refer to other files
# here it is //=require "dir/file"
# this refers to dir/file.js
IMPORTRE = /^\/\/=require\s?"[\w_\/]+"\n/
IMPORTREFILE = /^\/\/=require\s?"([\w_\/]+)"\n/

DO_MIN = false
MIN_ALL = false
DO_WATCH = false

ARGV.each do|a|
  case a
    when '-m'
      DO_MIN = true
    when '-ma'
      MIN_ALL = true
    when '-w'
      DO_WATCH = true
  end
end

# END OF CONFIG

require 'rubygems'
require 'FSSM'

# prepends needed files, e.g. jQuery.min.js or other files needed
# this happens after minification i.e. won't reminify these files
# TODO: implement
def prependFiles(file, fileList)

end

# TODO: implement
def gzip(file)

end

def minify(base, file, new_file)
  puts "minifying " + file

  system("java -jar " + base + "/" + CLOSURE_COMPILER_JAR_NAME + " --js " +
         file + " --js_output_file " +
         new_file + " --jscomp_off=internetExplorerChecks")
end

def _sanitiseDir(dir)
 return dir.gsub(/[\/]{3}|[\/]{2}/, "/")
end

# takes a file, iterates through it looking for import statements,
# appends below the import statements the recursive dependencies
# returns a file with import statements replaced with the file contents
# doesn't ensure a DAG, can give infinite loops
# always pass around the full path
def substituteContents(base, relative)

  file = base + "/" + relative
  stringFile = fileToString(file)

  matches = stringFile.scan(IMPORTRE)

  # double imports of the same file will fail
  matches.each { |m|
    idx = stringFile.index(m)
    fileName = m.match(IMPORTREFILE)[1] + ".js"
    
    newDir = _sanitiseDir(base + "/" + fileName)

    if validImport(newDir)
      stringFile.insert(idx + m.length, substituteContents(base, fileName))
    end
  }

  return stringFile
end

# returns whether the file passed in exists
def validImport(file)
  begin
    File.open(file)
    return true
  rescue
    return false
  end
end

# returns the string contents of a file
def fileToString(file)
  file = File.open(file)
  contents = ""
  file.each {|line|
    contents << line
  }
  return contents
end

# now need to create mirror structure

# also need to do the initial loop through all files and create all items

def initiateFullUpdate
  filePath = File.dirname(__FILE__)
  curDir = File.join(Dir.getwd(), filePath)

  all = Dir.glob(File.join(File.dirname(__FILE__), '**', '*.js'))

  all.each {|jsFile|
    jsFile = jsFile[filePath.length..jsFile.length]

    outFile = substituteContents(curDir, jsFile)
    # then either create or update the mirror if doesn't have an underscore
    fileName = jsFile.match(/[^|\/][\w]+\.js/)[0]

    if fileName[0,1] != "_"
      createMirror(curDir, jsFile, outFile)
    end
  }
end

# creates the mirror file, e.g. current-dir/main.js -> js/main.js
def createMirror(base, relative, newFileContent)
  newDir = _sanitiseDir("/" + relative)
  splitted = newDir.split("/")
  splitted = splitted.find_all{|item| item != ""}

  cur = base + "/" + MIRROR_DIR + "/"

  splitted.each { |path|
    cur += path

    isFile = cur[-3,3] == ".js"

    if isFile
      File.open(cur, 'w') {|f| f.write(newFileContent) }
    else
      if !File.exist?(cur)
        Dir.mkdir(cur)
      end
    end

    min_file = !!cur.match('.do-min.js')
    min_file_name = cur.sub(".do-min.js", ".js")
    if (DO_MIN and min_file) or MIN_ALL
      minify(base, cur, min_file_name)
    elsif isFile and min_file
      File.open(min_file_name, 'w') {|f| f.write(newFileContent) }      
    end

    cur += "/"
  }

end

def log()
  puts "polling for *.js changes"
end

def monitor()
  log()

  begin

  FSSM::Monitor.new(:directories => true)

  FSSM.monitor('.', Dir.glob(File.join(File.dirname(__FILE__), '**', '*.js')), :directories => true) do

    update {|base, relative, type |
      puts relative + " changed"
      initiateFullUpdate()
      log()
    }

    create {|base, relative, type |
      puts relative + " created"
      initiateFullUpdate()
      log()
    }

    delete {|base, relative, type |
      puts relative + " deleted"
      initiateFullUpdate()
      File.delete(base + "/" + MIRROR_DIR + "/" + relative)
      log()
    }
  end
  
  rescue
    monitor()
  end
end

def main()
  initiateFullUpdate()  
  if DO_WATCH
    monitor()
  end
end

main()
