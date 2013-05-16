
var uti = {
    gid: function(i) { return document.getElementById(i); },
    ce: function(s) { return document.createElement(s); },
    ap: function(a, b) { return a.appendChild(b); },
    cls: function(a, c) { return a.className = c; },
    bind: function(t, fn) { return function() { return fn.apply(t, arguments); }; },
    addEvent: document.addEventListener ? function(e, n, fn) {
	e.addEventListener(n, fn, false);
    } : function(e, n, fn) {
	e.attachEvent('on' + n , fn);
    },
    removeEvent: document.removeEventListener ? function(e, n, fn) {
	e.removeEventListener(n, fn);
    } : function(e, fn) {
	e.detachEvent('on' + n , fn);	
    },
    inherit: function(child, parent) {
	function temp() {};

	temp.prototype = parent.prototype;
	child.prototype = new temp();
	child.prototype.constructor = child;
	child._super = parent.prototype;
    },
    secondInherit: function (child, parent) {
	for (i in parent.prototype) {
	    child.prototype[i] = parent.prototype[i];
	}
    },
    ellipse: function(str, chars) {
	if (str.length <= chars) { return str; }
	else { return str.slice(0,chars-3) + '...'; }
    },
    showLoader: function() {
	uti.hideLoader();
	$(uti.gid('loader-holder')).stop().fadeIn(150);
	uti._lastSpinner = uti.getDefaultSpinner(100, {
	    color: '#ffffff', lines: 16, radius: 15,
	    width: 5, speed: 2.4
	}).spin(uti.gid('loader-holder'));
	setTimeout(uti.hideLoader, 24 * 1000);
    },
    hideLoader: function() {
	uti._lastSpinner && uti._lastSpinner.stop();
	$(uti.gid('loader-holder')).empty().stop().fadeOut(150);
    },
    observable: function() { return new Observable(); },
    html: function(e, s, esc) { $(e).html(s); },
    count: 0,
    uid: function() { return uti.count++; },
    guid: function() {
	return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
	    var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
	    return v.toString(16);
	});
    },
    clamp: function(v, min, max) { return Math.min(Math.max(v, min), max); },
    each: function(items, fn) {
	var i = 0, len = items.length;
	for (;i < len;i++) { fn.call(items[i], i); }
    },
    zip: function(a, b) {
	var i = 0, len = Math.min(a.length, b.length), out = [];
	for (;i < len;i++) {
	    out.push([a[i], b[i]]);
	}
	return out;
    },
    getDefaultSpinner: function(z, extra) {
	var opts = $.extend({
	    lines: 15, length: 17, width: 4,
	    radius: 17, corners: 1,	rotate: 0,
	    color: '', // to allow the dark theme to automatically style this
	    speed: 2, trail: 60,
	    shadow: false, hwaccel: true, className: 'spinner',
	    zIndex: z ? z : 1, top: 'auto',	left: 'auto'
	}, extra ? extra: {});
	return new Spinner(opts);
    },
    cleanerUrl: function(str) {
	return str.replace(/\s/g, '_').replace(/\//g, '-');
    },
    normalise: function(min, max, zero) {
	if (zero) {
	    if (min < 0 && max > 0) {
		var largest = Math.max(Math.abs(min), max);
		return function(v) { return v / largest; };
	    } else {
		return function(v) { return (((v - min) / (max - min)) - 0.5) * 2; };
	    }
	} else return function(v) { return (v - min) / (max - min); };
    },
    formatDate: function(d) {
	return d3.time.format("%a %d %b %Y")(d);
    },
    formatDateMonth: function(d) {
	return d3.time.format("%b %Y")(d);
    },
    formatDateQuarter: function(d) {
	var y = d.getFullYear(),
	    m = d.getMonth(),
	    q;

	if (m < 3) q = 1;
	else if (m < 6) q = 2;
	else if (m < 9) q = 3;
	else if (m < 12) q = 4;

	return (y + " Q" + q);
    },
    formatNumberFull: function(v) {
	if (v == undefined || v == null || isNaN(v)) return '-';

	if ($.isNumeric(v) && Math.abs(v) < 0.00001) return 0;
	
	var base = Math.floor(Math.log(Math.abs(v))/Math.log(1000));
	if (v == 0 || (uti.isInt(v) && base < 2)) {
	    v = Math.round(v); 
	    return v;
	}
	if (window.d3) return d3.format(',.5r')(v);
	return v;
    },
    isInt: function(n) {
	return typeof n === 'number' &&  n % 1 == 0
    },
    formatNumber: function(v) {
	if (v == 0) return '0';
	var pow=Math.pow, floor=Math.floor, abs=Math.abs, log=Math.log;
	function round(n, precision) {
	    var prec = Math.pow(10, precision);
	    return Math.round(n*prec)/prec;
	}

	var base = floor(log(abs(v))/log(1000));

	if (base < 4 && base > 0) {
	    var suffix = 'kmb'[base-1];
	    return suffix ? round(v/pow(1000,base),2)+suffix : ''+v;
	} else {
	    return d3 && d3.format(',.3g')(v); // an alternative is '.5s'
	}
    },
    /* aware that 'AAA' should appear before 'AA'
     * ensure same for tenors, 3m - 30y, sort order should ensure this already
     */
    sortRates: { '60Top': 70, 'Top': 60, 'SSS': 50, 'JSS': 40,
		 'AAA': 29, 'AA': 28, 'A': 27,
		 'BBB': 19, 'BB': 18, 'B': 17,
		 'CCC': 9, 'CCC': 8, 'C': 7,
		 'Equity': 1
	       },
    regionsSimple: {
	'america': 10, 'europe': 20, 'asia': 30, 'australia': 40, 'oceania': 50,
	'amer': 10, 'eur': 20, 'asia': 30, 'africa': 40, 'india': 41, 'oceania': 50, 'offshore': 60
    },
    currencies: { 'AUD': 50, 'SGD': 59, 'JPY': 60, 'CHF': 70, 'GBP': 80, 'EUR': 90 , 'CAD': 96, 'USD': 100 },
    tiers: { 'PREFT1': 10,  'JRSUBUT2': 20, 'SUBLT2': 30, 'SNRFOR': 40, 'SECDOM': 50, '1STLIEN': 60,  },
    docClauses: { 'XR': 1, 'MR': 2, 'MM': 3, 'CR': 4 },
    simpleFilter: function(items) {
	var i = 0, len = items.length, out = [];
	for (;i < len;i++) { if (items[i]) out.push(items[i]); }
	return out;
    },
    arrayToObj: function(arr) {
	var len = arr.length, out = {};
	while (len--) { out[arr[len]] = true; }
	return out;
    },
    flattenArr: function(arr, accessor) {
	var i = 0, len = arr.length, out = [];
	for (;i < len;i++) { out.push(arr[i][accessor]); }
	return out;
    },
    flattenObj: function(obj) {
	var out = [];
	for (i in obj) out.push(i);
	return out;
    },
    objToArray: function(obj) {
	var out = [];
	for (i in obj) out.push(obj[i]);
	return out;
    },
    sum: function(items) {
	var len = items.length, out = 0;
	while (len--) { out += items[len]; }
	return out;
    },
    all: function(items) {
	var len = items.length;
	while (len--) { if (!items[len]) return false; }
	return true;
    },
    any: function(items) {
	var len = items.length;
	while (len--) { if (items[len]) return true; }
	return false;
    },
    smartSort: function(a, b, accessor) {
	accessor = accessor || 'name';

	if (a[accessor] && b[accessor]) {
	    if (typeof a[accessor] === "number" && typeof b[accessor] === "number")
		return a[accessor] - b[accessor];

	    if (typeof a[accessor] === "string" && typeof b[accessor] === "string") {
		var rate_a = a[accessor] in uti.sortRates,
   	        rate_b = b[accessor] in uti.sortRates,
	        ten_a = a[accessor].match(/^(\d\d?)([mMyY]r?)$/),
	        ten_b = b[accessor].match(/^(\d\d?)([mMyY]r?)$/),
	        region_a = a[accessor].match(/eur|amer|asia|australia|oceania|offshore|india|africa/i),
	        region_b = b[accessor].match(/eur|amer|asia|australia|oceania|offshore|india|africa/i),
	        range_a = a[accessor].match(/\d+-\d+/i),
	        range_b = b[accessor].match(/\d+-\d+/i),
	        cust_date_a = a[accessor].match(/(d|j)[\d+]/i), // dec./june
	        cust_date_b = b[accessor].match(/(d|j)[\d+]/i),
	        cur_a = a[accessor] in uti.currencies,
	        cur_b = b[accessor] in uti.currencies;

	    if (cur_a && cur_b) {
		return uti.currencies[a[accessor]] - uti.currencies[b[accessor]];
	    } else if (cust_date_a && cust_date_b) {
		var a_yr = parseInt(a[accessor].slice(1)), b_yr = parseInt(b[accessor].slice(1));

		if (a_yr == b_yr) {
		    return a[0] < b[0] ? 1 : -1;
		} else {
		    return a_yr - b_yr;
		}

	    } else if (range_a && range_b) {
		var a_sp = a[accessor].split('-'), b_sp = b[accessor].split('-'),
		a_1 = parseInt(a_sp[0]), b_1 = parseInt(b_sp[0]),
		a_2 = parseInt(a_sp[1]), b_2 = parseInt(b_sp[1]);

		if (a_2 === b_2) {
		    return a_1 - b_1;
		} else {
		    return a_2 - b_2;
		}

	    } else if (rate_a && rate_b) {
		return uti.sortRates[a[accessor]] - uti.sortRates[b[accessor]];
	    } else if (ten_a && ten_b) {
		try {
		    if (ten_a[2].toLowerCase() == ten_b[2].toLowerCase()) {
			return (parseInt(ten_a[1]) < parseInt(ten_b[1])) ? -1 : 1;
		    } else {
			return (ten_a[2].toLowerCase() == 'y'  || ten_a[2].toLowerCase() == 'yr') ? 1 : -1;
		    }
		} catch (e) {}
	    } else if (region_a && region_b) {
		return uti.regionsSimple[region_a[0].toLowerCase()] - uti.regionsSimple[region_b[0].toLowerCase()];
	    } else  {
		var tiers = uti.tiers,
		docClauses = uti.docClauses,
		tierA = tiers[a[accessor]], tierB = tiers[b[accessor]],
		dcA = docClauses[a[accessor]], dcB = docClauses[b[accessor]];

		if (tierA && tierB) return tierA - tierB;
		else if (dcA && dcB) return dcA - dcB;
		else {
		    return a[accessor] > b[accessor] ? 1 : -1;
		}
		
	    }

	    }
	}

    },
    uniqueButtonGroup: function(group, fns) {
	var buts = $(group).find('.btn'),
	    value;

	uti.each(uti.zip(buts, fns), function(i) {
	    var self = this;
	    $(this[0]).click(function() {
		value = i;
		buts.removeClass('selected');
		$(self[0]).addClass('selected');
		self[1]();
	    });
	});

	return {
	    setValue: function(idx, quiet) {
		value = idx;
		buts.removeClass('selected');
		$(buts[0]).addClass('selected');
		fns[idx]();
	    },
	    getValue: function() { return value; }
	};
    },
    fillArray: function(len, item) {
	var out = [];
	while (len--) { out.push(item); }
	return out;
    },
    roundDate: function(date, timePeriodCode) {
	if (!timePeriodCode) return date;
	else if (timePeriodCode == 'day')
	    return new Date(date.getFullYear(), date.getMonth(), date.getDate());
	else if (timePeriodCode == 'week')
	    return moment(new Date(date.getFullYear(), date.getMonth(), date.getDate())).day(1).toDate();
	else if (timePeriodCode == 'month')
	    return new Date(date.getFullYear(), date.getMonth(), 1);
	else if (timePeriodCode == 'quarter') {
	    var q = {
		0: 0, 1: 0, 2: 0,
		3: 3, 4: 3, 5: 3,
		6: 6, 7: 6, 8: 6,
		9: 9, 10: 9, 11: 9,
	    }[date.getMonth()];
	    return new Date(date.getFullYear(), q, 1);
	} else if (timePeriodCode == 'year')
	    return new Date(date.getFullYear(), 1, 1);

	return date;
    },
    flattenFilters: function(filters) {
	var len = filters.length,
        cs_filters = [],
        ts_filters = [];
	
	while (len--) {
	    if (filters[len]._cross_section) {
		cs_filters.push([filters[len].cond, filters[len].value]);
	    } else {
		ts_filters.push([filters[len].time_series_col, filters[len].start_date, filters[len].end_date]);
	    }
	}
	
	return {
	    cs_filters: cs_filters,
	    ts_filters: ts_filters,
	};
    },
};

uti.clientId = uti.guid();

uti.csChartOptions = function(){
    return [{
	id: ElementContentKinds.TreeMap,
	name: 'Tree Map'
    },{
	id: ElementContentKinds.BarChart,
	name: 'Bar Chart'
    },{
	id: ElementContentKinds.SplitBarChart,
	name: 'Split Bar Chart'
    },{
	id: ElementContentKinds.ColumnChart,
	name: 'Column Chart'
    },{
	id: ElementContentKinds.BubbleChart,
	name: 'Bubble Chart'
    },{
	id: ElementContentKinds.PieChart,
	name: 'Pie Chart'
    },{
	id: ElementContentKinds.CrossSection_Column3D,
	name: '3D Column Chart'
    },{
	id: ElementContentKinds.CrossSection_Surface3D,
	name: '3D Surface Chart'
    },{
	id: ElementContentKinds.ZoneWorldMap,
	name: 'Zoned World Map'
    }];
};

uti.infoChartOptions = function() {
    return [{
	id: ElementContentKinds.SummaryStats,
	name: 'Summary Statistics'
    }]; 
};

uti.altChartOptions = function() {
    return [{
	id: ElementContentKinds.PangolinSupervisor,
	name: 'Pangolin Supervisor'
    }]; 
};

uti.tsChartOptions = function(){ return [{
	    id: ElementContentKinds.TileChart,
	    name: 'Tile Chart'
	},{
	    id: ElementContentKinds.LineChart,
	    name: 'Line Chart'
	},{
	    id: ElementContentKinds.GroupedTileChart,
	    name: 'Grouped Tile Chart'
	},{
	    id: ElementContentKinds.GroupedLineChart,
	    name: 'Grouped Line Chart'
	},{
	    id: ElementContentKinds.TimeSeries_Column3D,
	    name: '3D Column Chart'
	},{
	    id: ElementContentKinds.TimeSeries_Surface3D,
	    name: '3D Surface Chart'
	}];
};

uti.createColourRows = function(changeFn) {
    var i = 0,
        len = uti.colourSwatches.length,
        out = $('<div></div>'),
        optionsLookup = {},
        currentSelectionId;
    
    function setSelection(id) {
	$(optionsLookup[currentSelectionId].nodes).removeClass('selected')
	$(optionsLookup[id].nodes).addClass('selected')
	currentSelectionId = id;
    }

    function createRow(conf){
	var custom = conf.id === -1,
	    readOnly = !custom,
	    nodes = $('<div class="option-row">' +
		      '<div class="form-row center">' +
		      '<input type="color"/>' +
		      '<input type="color"/>' +
		      '<input type="color"/>' +
		      '<input type="color"/>' +
		      '</div>' +
		      '<div class="form-row title">' + conf.name + '</div>' +
		      '</div>');

	nodes.click(function() {
	    setSelection(conf.id);
	    changeFn && changeFn.apply(this, arguments);
	});

	changeFn && nodes.find('input').change(changeFn)

	var max_nve = $($(nodes).find('input')[0]),
	    min_nve = $($(nodes).find('input')[1]),
	    min_pve = $($(nodes).find('input')[2]),
	    max_pve = $($(nodes).find('input')[3]);

	function deser(data) {
	    max_nve.val(data.max_nve);
	    min_nve.val(data.min_nve);
	    min_pve.val(data.min_pve);
	    max_pve.val(data.max_pve);
	}

	deser(conf.opts);

	if (readOnly) nodes.find('input').attr('readonly', true);

	var info = {
	    nodes: nodes[0],
	    custom: custom,
	    coloursDeser: deser,
	    coloursSer: function() {
		return {
		    'neutral_light': conf.opts.neutral_light,
		    'max_nve': max_nve.val(),
		    'min_nve': min_nve.val(),
		    'min_pve': min_pve.val(),
		    'max_pve': max_pve.val()
		};
	    }
	}

	optionsLookup[conf.id] = info;

	if (currentSelectionId == undefined) currentSelectionId = conf.id;

	out.append(nodes[0]);
    }

    for (;i < len;i++) {
	createRow(uti.colourSwatches[i]);
    }

    createRow({
	id: -1,
	name: 'Custom',
	opts: uti.colourSwatches[0].opts
    });

    return {
	nodes: out[0],
	serialise: function() {
	    var cur = optionsLookup[currentSelectionId],
	        out = {};

	    out['swatch'] = currentSelectionId;
	    out['custom'] = optionsLookup[-1].coloursSer();
	    
	    return out;
	},
	deserialise: function(conf) {
	    if ($.isNumeric(conf.swatch) && conf.swatch in uti.colourSwatchesLookup) {
		setSelection(conf.swatch);
	    } else if (conf.swatch == -1) {
		setSelection(-1);
	    } else {
		setSelection(uti.colourSwatches[0].id);
	    }

	    optionsLookup[-1].coloursDeser(conf.custom || uti.colourSwatches[0].opts);
	}
    };
};

/* more: http://colorbrewer2.org/ */
uti.colourSwatches = [{
    id: 1,
    name: 'Red/Green',
    opts: {
	neutral_light: "#fafafa",
	max_pve: "#31E31E",
	max_nve: "#DB2143",
	min_pve: "#D2F7D2",
	min_nve: "#F7D2D2",
    }
},{
    id: 2,
    name: 'Gold/Blue',
    opts: {
	neutral_light: "#fafafa",
	max_nve: "#d99f1a",
	max_pve: "#1a9fdf",
	min_nve: "#f9f2d0",
	min_pve: "#d1ebf8"
    }
},{
    id: 3,
    name: 'Red/Teal',
    opts: {
	neutral_light: "#fafafa",
	max_nve: "#ce2471",
	max_pve: "#31ca9c",
	min_nve: "#f5d3f0",
	min_pve: "#d1f8ed"
    }
},{
    id: 4,
    name: 'Orange/Purple',
    opts: {
	neutral_light: "#fafafa",
	max_nve: "#ee8822",
	max_pve: "#69349a",
	min_nve: "#fae4c9",
	min_pve: "#eed8f1"
    }
}];

uti.colourSwatchesLookup = (function() {
    var out = {}, len = uti.colourSwatches.length;
    while (len--) { out[uti.colourSwatches[len].id] = uti.colourSwatches[len]; }
    return out;
})();

uti.colourOptions = $.extend({}, uti.colourSwatches[1].opts);

uti.renderOptions = function(parent, opts, parentObj, handlers) {
    uti.each(opts, function() {
	var self = this,
	item = uti.ce('a'),
	text = uti.ce('div'),
	iconsCont = uti.ce('div');
	
	function setLinkName(el) {
	    $(el).attr('href', self.href(self.id, self.name));
	}

	if (self.href && self.id && self.name) {
	    setLinkName(item);
	    $(item).attr('target', '_blank');
	} else {
	    $(item).attr('href', '#')
	    handlers.handler && (self.id !== undefined) && $(item).click(function() { handlers.handler(self.id, parentObj); });
	}

	uti.cls(item, (this.unselectable ? 'item' : 'item active'));
	uti.cls(text, 'text');
	uti.cls(iconsCont, 'icons-cont');
	uti.html(text, this.name);
	uti.ap(item, text);
	uti.ap(item, iconsCont);
	uti.ap(parent, item);

	if (this.editIcon) {
	    var ei = uti.ce('div');
	    uti.cls(ei, 'icon-pencil');
	    uti.ap(iconsCont, ei);
	    
	    $(ei).click(function(e) {
		e.stopPropagation();
		if (handlers.editHandler) {
		    self = handlers.editHandler(self.id, self, item, function(conf) {
			self = conf;
			setLinkName(item);
		    });
		}

		return false;
	    });
	}

	if (this.removeIcon) {
	    var ri = uti.ce('div');
	    uti.cls(ri, 'icon-remove');
	    uti.ap(iconsCont, ri);
	    $(ri).click(function(e) {
		e.stopPropagation();
		handlers.removeHandler && handlers.removeHandler(self.id, self, item, function() {
		    $(item).remove();
		    if (parent.children.length == 0) {
			$(parent).remove();
		    }
		});
		return false;
	    });
	}

	var subCont = uti.ce('div');

	$(item).hover(function () {
	    $(this).siblings().find('.sub').hide();
	    $(subCont).show();
	});

	if (this.sub) {
	    var caret = uti.ce('div');

	    uti.cls(subCont, 'popup-menu sub');
	    uti.cls(caret, 'icon-caret-right');
	    uti.ap(iconsCont, caret);

	    uti.renderOptions(subCont, this.sub, this, handlers);
	    uti.ap(item, subCont);
	}
    });
};

uti.d3Utils = {
    ts_diff_data: function(scalarCount) {
	return function(d) {
	    var scalars = [],
	        i = 0,
	        scalarsFull = [], e = $.extend(d, {});

	    for (;i < scalarCount;i++) {
		var a = d.scalars[i],
		    b = d.scalars[i + scalarCount],
		    bothNull = (a == null && b == null);

		a = $.isNumeric(a) ? a : 0;
		b = $.isNumeric(b) ? b : 0;

		if (bothNull) scalars.push(null);
		else scalars.push(b - a);
		
		scalarsFull.push([a, b]);
	    }
	    e.scalarsFull = scalarsFull;
	    e.scalars = scalars;
	    return e;
	};
    }
};

uti.bodyWatch = (function() {
    var init = false,
        curWindows = [];

    function hideAll() {
        var len = curWindows.length;
        while (len--) { curWindows[len].hidePopup(); }
    }
                     
    function initFn() {
        $('html').click(hideAll);
        init = true;
    }

    function removeId(id) {
	if (id === undefined || id === null) return;
	var len = curWindows.length;
	while (len--) {
	    if (curWindows[len].getId && curWindows[len].getId() == id) {
		curWindows.splice(len, 1);
		return;
	    }
	}
    }

    return {
        add: function(win) {
            init || initFn();
            curWindows.push(win);
        },
        hideAll: hideAll,
	removeId: removeId
    };
})();

uti.d3ZoomDur = 150;

/* only hub to get chart types and info */
var ElementContentKindsFull = {
    "BarChart": [5, 'bar chart', function() { return BarChartEC; }],
    "BubbleChart": [6, 'scatter chart', function() { return BubbleChartEC; }],
    "ColumnChart": [7, 'column chart', function() { return ColumnChartEC; }],
    "SplitBarChart": [8, 'split bar chart', function() { return SplitBarChartEC; }],
    "TreeMap": [9, 'tree map', function() { return TreeMapEC; }],
    "SummaryStats": [10, 'summary statistics', function() { return SummaryStatisticsEC; }],
    "ZoneWorldMap": [11, 'zoned world map', function() { return ZoneWorldMapEC; }],
    "PieChart": [1, 'pie chart', function() { return PieChartEC; }],
    "TimeSeries_Column3D": [22, 'time series column 3d', function() { return TimeSeries_Column3D_EC; }],
    "CrossSection_Column3D": [23, 'cross section column 3d', function() { return CrossSection_Column3D_EC; }],
    "TimeSeries_Surface3D": [24, 'time series column 3d', function() { return TimeSeries_Surface3D_EC; }],
    "CrossSection_Surface3D": [25, 'cross section surface 3d', function() { return CrossSection_Surface3D_EC; }],
    "TileChart": [40, 'tile chart', function() { return TileChartEC; }],
    "LineChart": [41, 'line chart', function() { return LineChartEC; }],
    "GroupedTileChart": [42, 'grouped tile chart', function() { return GroupedTileChartEC; }],
    "GroupedLineChart": [43, 'grouped area chart', function() { return GroupedLineChartEC; }],
    "PangolinSupervisor": [60, 'pangolin supervisor', function() { return PangolinSupervisorEC; }],
};

var ElementContentKinds = (function() {
    var out = {}
    for (k in ElementContentKindsFull) { out[k] = ElementContentKindsFull[k][0]; }
    return out;
})();

var ElementContentKindsRev = (function() {
    var out = {};
    for (k in ElementContentKinds) { out[ElementContentKindsFull[k][0]] = ElementContentKindsFull[k]; }
    return out;
})();

var CrossSection_TimeSeriesKeywords = {
    "cs_date_state_1": 'Current',
    "cs_date_state_2": 'Previous',
    "cs_scenario_state_1": 'Baseline',
    "cs_scenario_state_2": 'Hypothetical',
    "ts_date_state_1": 'Start',
    "ts_date_state_2": 'End'
};

// useful
// http://stackoverflow.com/questions/13274151/d3js-scale-transform-and-translate
// https://github.com/mbostock/d3/pull/330
uti.mapCountries = {
    'Asia': {
	'Afghanistan': { 'id': 1, 'names': [] },
	'United Arab Emirates': { 'id': 4, 'names': ['uae'] },
	'Armenia': { 'id': 6, 'names': [] },
	'Azerbaijan': { 'id': 11, 'names': [] },
	'Bangladesh': { 'id': 16, 'names': [] },
	'Brunei': { 'id': 24, 'names': [] },
	'Bhutan': { 'id': 25, 'names': [] },
	'China': { 'id': 31, 'names': ['hong kong'] },
	'Northern Cyprus': { 'id': 39, 'names': [] },
	'Georgia': { 'id': 59, 'names': [] },
	'Indonesia': { 'id': 73, 'names': [] },
	'India': { 'id': 74, 'names': [] },
	'Iran': { 'id': 76, 'names': [] },
	'Iraq': { 'id': 77, 'names': [] },
	'Israel': { 'id': 79, 'names': [] },
	'Jordan': { 'id': 82, 'names': [] },
	'Japan': { 'id': 83, 'names': [] },
	'Kazakhstan': { 'id': 84, 'names': [] },
	'Kyrgyzstan': { 'id': 86, 'names': [] },
	'Cambodia': { 'id': 87, 'names': [] },
	'South Korea': { 'id': 88, 'names': ['korea, republic of', 'republic of korea'] },
	'Kuwait': { 'id': 90, 'names': [] },
	'Laos': { 'id': 91, 'names': [] },
	'Lebanon': { 'id': 92, 'names': [] },
	'Russia': { 'id': 135, 'names': [] },
	'Sri Lanka': { 'id': 95, 'names': [] },
	'Myanmar': { 'id': 106, 'names': [] },
	'Mongolia': { 'id': 108, 'names': [] },
	'Malaysia': { 'id': 112, 'names': [] },
	'Nepal': { 'id': 120, 'names': [] },
	'Oman': { 'id': 122, 'names': [] },
	'Pakistan': { 'id': 123, 'names': [] },
	'Philippines': { 'id': 126, 'names': [] },
	'North Korea': { 'id': 130, 'names': [] },
	'Qatar': { 'id': 133, 'names': [] },
	'Saudi Arabia': { 'id': 138, 'names': [] },
	'Syria': { 'id': 153, 'names': [] },
	'Thailand': { 'id': 156, 'names': [] },
	'Tajikistan': { 'id': 157, 'names': [] },
	'Turkmenistan': { 'id': 158, 'names': [] },
	'East Timor': { 'id': 159, 'names': [] },
	'Turkey': { 'id': 162, 'names': [] },
	'Taiwan': { 'id': 163, 'names': [] },
	'Uzebekistan': { 'id': 169, 'names': [] },
	'Vietnam': { 'id': 171, 'names': [] },
	'West Bank': { 'id': 173, 'names': [] },
	'Yemen': { 'id': 174, 'names': [] },
    },
    'Africa': {
	'Angola': { 'id': 2, 'names': [] },
	'Burundi': { 'id': 12, 'names': [] },
	'Benin': { 'id': 14, 'names': [] },
	'Burkina Faso': { 'id': 15, 'names': [] },
	'Botswana': { 'id': 26, 'names': [] },
	'Central Africa Republic': { 'id': 27, 'names': [] },
	'Ivory Coast': { 'id': 32, 'names': [] },
	'Cameroon': { 'id': 33, 'names': [] },
	'Democratic Republic of the Congo': { 'id': 34, 'names': [] },
	'Republic of the Congo': { 'id': 35, 'names': [] },
	'Djibouti': { 'id': 43, 'names': [] },
	'Algeria': { 'id': 46, 'names': [] },
	'Egypt': { 'id': 48, 'names': [] },
	'Eritrea': { 'id': 49, 'names': [] },
	'Ethiopia': { 'id': 52, 'names': [] },
	'Gabon': { 'id': 57, 'names': [] },
	'Ghana': { 'id': 60, 'names': [] },
	'Gambia': { 'id': 62, 'names': [] },
	'Guinea Bissau': { 'id': 63, 'names': [] },
	'Equatorial Guinea': { 'id': 64, 'names': [] },
	'Kenya': { 'id': 85, 'names': [] },
	'Liberia': { 'id': 93, 'names': [] },
	'Libya': { 'id': 94, 'names': [] },
	'Lesotho': { 'id': 96, 'names': [] },
	'Morocco': { 'id': 100, 'names': [] },
	'Madagascar': { 'id': 102, 'names': [] },
	'Mali': { 'id': 105, 'names': [] },
	'Mozambique': { 'id': 109, 'names': [] },
	'Mauritania': { 'id': 110, 'names': [] },
	'Malawai': { 'id': 111, 'names': [] },
	'Namibia': { 'id': 113, 'names': [] },
	'Niger': { 'id': 115, 'names': [] },
	'Nigeria': { 'id': 116, 'names': [] },
	'Rwanda': { 'id': 136, 'names': [] },
	'Western Sahara': { 'id': 137, 'names': [] },
	'Sudan': { 'id': 139, 'names': [] },
	'South Sudan': { 'id': 140, 'names': [] },
	'Senegal': { 'id': 141, 'names': [] },
	'Sierra Leone': { 'id': 143, 'names': [] },
	'Somaliland': { 'id': 145, 'names': [] },
	'Somalia': { 'id': 146, 'names': [] },
	'Swaziland': { 'id': 152, 'names': [] },
	'Chad': { 'id': 154, 'names': [] },
	'Togo': { 'id': 155, 'names': [] },
	'Tunisia': { 'id': 161, 'names': [] },
	'United Republic of Tanzania': { 'id': 164, 'names': [] },
	'Uganda': { 'id': 165, 'names': [] },
	'South Africa': { 'id': 175, 'names': [] },
	'Zambia': { 'id': 176, 'names': [] },
	'Zimbabwe': { 'id': 177, 'names': [] },
    },
    'Europe': {
	'Russia': { 'id': 135, 'names': ['russian federation'] },
	'Albania': { 'id': 3, 'names': [] },
	'Austria': { 'id': 10, 'names': [] },
	'Belgium': { 'id': 13, 'names': [] },
	'Bulgaria': { 'id': 17, 'names': [] },
	'Bosnia and Herzegovina': { 'id': 19, 'names': [] },
	'Belarus': { 'id': 20, 'names': [] },
	'Switzerland': { 'id': 29, 'names': [] },
	'Cyprus': { 'id': 40, 'names': [] },
	'Czech Republic': { 'id': 41, 'names': [] },
	'Germany': { 'id': 42, 'names': [] },
	'Denmark': { 'id': 44, 'names': [] },
	'Spain': { 'id': 50, 'names': [] },
	'Estonia': { 'id': 51, 'names': [] },
	'Finland': { 'id': 53, 'names': [] },
	'France': { 'id': 56, 'names': [] },
	'United Kingdom': { 'id': 58, 'names': [] },
	'Greece': { 'id': 65, 'names': [] },
	'Croatia': { 'id': 65, 'names': [] },
	'Hungary': { 'id': 72, 'names': [] },
	'Ireland': { 'id': 75, 'names': [] },
	'Iceland': { 'id': 78, 'names': [] },
	'Italy': { 'id': 80, 'names': [] },
	'Kosovo': { 'id': 89, 'names': [] },
	'Lithuania': { 'id': 97, 'names': [] },
	'Luxembourg': { 'id': 98, 'names': [] },
	'Latvia': { 'id': 99, 'names': [] },
	'Moldova': { 'id': 101, 'names': [] },
	'Macedonia': { 'id': 104, 'names': [] },
	'Montenegro': { 'id': 107, 'names': [] },
	'Netherlands': { 'id': 118, 'names': [] },
	'Norway': { 'id': 119, 'names': [] },
	'Poland': { 'id': 128, 'names': [] },
	'Portugal': { 'id': 131, 'names': [] },
	'Romania': { 'id': 134, 'names': [] },
	'Republic of Serbia': { 'id': 147, 'names': [] },
	'Slovakia': { 'id': 149, 'names': [] },
	'Slovenia': { 'id': 150, 'names': [] },
	'Sweden': { 'id': 151, 'names': [] },
	'Ukraine': { 'id': 166, 'names': [] },
    },
    'Oceania': {
	'Australia': { 'id': 9, 'names': [] },
	'Fiji': { 'id': 54, 'names': [] },
	'New Caledonia': { 'id': 114, 'names': [] },
	'New Zealand': { 'id': 121, 'names': [] },
	'Papua New Guinea': { 'id': 127, 'names': [] },
	'Solomon Islands': { 'id': 142, 'names': [] },
	'Vanuatu': { 'id': 172, 'names': [] },
    },
    'NAmerica': {
	'The Bahamas': { 'id': 18, 'names': [] },
	'Belize': { 'id': 21, 'names': [] },
	'Canada': { 'id': 28, 'names': [] },
	'Costa Rica': { 'id': 37, 'names': [] },
	'Cuba': { 'id': 38, 'names': [] },
	'Dominican Republic': { 'id': 45, 'names': [] },
	'Greenland': { 'id': 66, 'names': [] },
	'Guatemala': { 'id': 67, 'names': [] },
	'Honduras': { 'id': 69, 'names': [] },
	'Haiti': { 'id': 71, 'names': [] },
	'Jamaica': { 'id': 81, 'names': [] },
	'Mexico': { 'id': 103, 'names': [] },
	'Nicaragua': { 'id': 117, 'names': [] },
	'Panama': { 'id': 124, 'names': [] },
	'Puerto Rico': { 'id': 129, 'names': [] },
	'El Salvador': { 'id': 144, 'names': [] },
	'Trinidad and Tobago': { 'id': 160, 'names': ['trinidad', 'tobago'] },
	'United States of America': { 'id': 168, 'names': ['united states'] },
    },
    'SAmerica': {
	'Argentina': { 'id': 5, 'names': [] },
	'Bolivia': { 'id': 22, 'names': [] },
	'Brazil': { 'id': 23, 'names': [] },
	'Chile': { 'id': 30, 'names': [] },
	'Colombia': { 'id': 36, 'names': [] },
	'Ecuador': { 'id': 47, 'names': [] },
	'Falkland Islands': { 'id': 55, 'names': [] },
	'Guyana': { 'id': 68, 'names': [] },
	'Peru': { 'id': 125, 'names': [] },
	'Paraguay': { 'id': 132, 'names': [] },
	'Suriname': { 'id': 148, 'names': [] },
	'Uruguay': { 'id': 167, 'names': [] },
	'Venezuela': { 'id': 170, 'names': [] },
    }
};

uti.mapContinents = {
    'Asia': {
	'id': 2,
	'center': [100,40],
	'scale': 3,
	'names': ['asia', 'india', 'middleeast'],
	'sub': uti.mapCountries['Asia']
    },
    'Africa': {
	'id': 1,
	'center': [10, 0],
	'scale': 2.2,
	'names': ['africa'],
	'sub': uti.mapCountries['Africa']
    },
    'Europe': {
	'id': 7,
	'center': [30,60],
	'scale': 2.5,
	'names': ['europe', 'e.eur'],
	'sub': uti.mapCountries['Europe']
    },
    'Oceania': {
	'id': 4,
	'center': [140,-28],
	'scale': 1.8,
	'names': ['oceania'],
	'sub': uti.mapCountries['Oceania']
    },
    'NAmerica': {
	'id': 3,
	'center': [-100,50],
	'scale': 2.8,
	'names': ['n.amer', 'caribbean'],
	'sub': uti.mapCountries['NAmerica']
    },
    'SAmerica': {
	'id': 5,
	'center': [-60,-25],
	'scale': 2.3,
	'names': ['lat.amer'],
	'sub': uti.mapCountries['SAmerica']
    }
};

uti.mapData = $.extend({
    'Continents': {
	'center': [0,40],
	'scale': 7,
	'names': [],
	'sub': uti.mapContinents
    },
}, uti.mapContinents);

uti.forms = {};
uti.forms.conditionRenderer = function(tableSelect,
				       title,
				       requiredFirst,
				       sel_sel_reverse) {


    var area = $(
	'<div>' +
	  (title ? ('<div class="form-row title">' + title + '</div>') : '') +
	  '<div class="condition-area"></div>' +
	  '<div class="condition form-row center">' +
	    '<div class="btn primary icon"><div class="icon-plus"></div></div>' +
	  '</div>' +
	'</div>'
    )[0], addEl = $(area).find('.btn.primary.icon')[0],
          dynEl = $(area).find('.condition-area')[0],
          items = [];

    function serialise() {
	var i = 0, len = items.length,
	out = [];
	for (;i < len;i++) {
	    out.push({
		'col': items[i]['col'].getValue(),
		'value': sel_sel_reverse ? items[i]['value'].getValue() : undefined
	    });
	}
	return out;
    }

    function removeRow(id) {
	var len = items.length;
	while (len--) {
	    if (items[len]['id'] == id) {
		items.splice(len, 1);
		return;
	    }
	}
    }

    $(addEl).click(function() { createRow({}); });

    function createRow(idx) {
	var rowEl = uti.ce('div'),
	remove = uti.ce('div'),
	remIcon = uti.ce('div'),
	id = uti.uid();

	uti.cls(remove, "btn danger icon");
	uti.cls(remIcon, "icon-remove");
	uti.cls(rowEl, "form-row center");

	$(remove).click(function() {
	    $(rowEl).remove();
	    removeRow(id);
	});

	var sel = new Control.Select({
	    value: this['col'],
	    options: tableSelect ? initData.keyedColTablesDimMeas[tableSelect.getValue()] : initData.allCols
	});

	tableSelect && tableSelect.on('_change_', function(v) {
	    sel.setOptions(initData.keyedColTablesDimMeas[v]);
	});

	var input, sel2;

	if (requiredFirst && idx == 0 && sel_sel_reverse) {
	    $(sel.getNodes()).css('margin-right', -30);	    
	} else if (requiredFirst && idx == 0) {
	    $(sel.getNodes()).css('margin-left', 36);
	} else {
	    uti.ap(rowEl, remove);
	    uti.ap(remove, remIcon);
	}

	if (!sel_sel_reverse) {
	    uti.ap(rowEl, sel.getNodes());
	} else {
	    sel2 = new Control.Select({
		value: this['value'],
		options: sel_sel_reverse
	    });
	    uti.ap(rowEl, sel2.getNodes());
	    uti.ap(rowEl, sel.getNodes());
	}

	uti.ap(dynEl, rowEl);

	items.push({
	    'id': id,
	    'col': sel,
	    'value': input ? input : sel2
	});
    }

    function deserialise(conds) {
	$(dynEl).empty();
	items = []
	$(conds).each(function(i) {
	    createRow.call(this, i);
	});
    }

    return {
	serialise: serialise,
	deserialise: deserialise,
	area: area
    };
};

var StageInfoManager = (function() {

    var topAlert,
        centerAlert,
        topTimeout,
        centerTimeout;


    $(function setupEls() {
	topAlert = $('<div class="top-alert"><div class="inner"></div></div>').hide().appendTo(document.body);
	centerAlert = $('<div class="center-alert">' +
			'<div class="close-but"></div>' +
			'<div class="inner"></div>' +
			'</div>').hide().appendTo(document.body);

	centerAlert
	    .find('.close-but')
	    .click(function() { $(this).parent().hide(); })
	    .append('\u00D7');
    });

    function displayAlert(top, content, cls, timeout) {
	var alert = top ? topAlert : centerAlert;

	alert
	    .show()
	    .removeClass('primary success danger warn')
	    .addClass(cls);

	alert
	    .find('.inner')
	    .html(content);

	if (timeout) {
	    var hideFn = function() { alert.fadeOut(150); };
	    timeout = $.isNumeric(timeout) ? timeout * 1000 : 4 * 1000;

	    if (top) {
		clearTimeout(topTimeout);
		topTimeout = setTimeout(hideFn, timeout);
	    } else {
		clearTimeout(centerTimeout);
		centerTimeout = setTimeout(hideFn, timeout);
	    }
	}
    }

    return {
	showTopAlert: function(msg, cls, timeout) {
	    displayAlert(true, msg, cls, timeout);
	},
	showCenterAlert: function(nodes, cls, timeout) {
	    displayAlert(false, nodes, cls, timeout);	    
	},
	hideTopAlert: function() { topAlert.hide(); },
	hideCenterAlert: function() { centerAlert.hide(); }
    };

})();

