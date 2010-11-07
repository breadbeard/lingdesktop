Ext.ns("User");

User.Index = Ext.extend(Desktop.App, {
	layout: 'fit',
	
	initComponent : function() {		
	   
	   //setup store
	   var store = new Ext.data.JsonStore({
		    // store configs
		    autoDestroy: true,
		    url: 'users.json',
			storeId: 'user_index',
		    // reader configs
		    root: 'data',
		    fields: ['username', 'email', 'first_name', 'last_name', {name:'created', type:'date'},{name:'is_admin', type:'boolean'}, {name:'is_active', type:'boolean'}]
		});
		
		//setup grid
		var _this = this;
		var grid = new Ext.grid.GridPanel({
		    store: store,
		    colModel: new Ext.grid.ColumnModel({
		        columns: [
		            {header: 'Username', dataIndex: 'username'},
					{header: 'First Name', dataIndex: 'first_name'},
					{header: 'Last Name', dataIndex: 'last_name'},
					{header: 'Email', dataIndex: 'email'},
		            {
		                header: 'Created', dataIndex: 'created',
		                xtype: 'datecolumn', format: 'M d, Y'
		            },
					{header: 'Administrator', dataIndex: 'is_admin'},
					{header: 'Active', dataIndex: 'is_active'}
		        ]
		    }),
		    viewConfig: {
		        forceFit: true
		    },
		    sm: new Ext.grid.RowSelectionModel({singleSelect:true}),
			listeners: {
				rowclick: function(g, index){
					Desktop.workspace.getMainBar().showButton('edit', _this);
				},
				rowdblclick : function(g, index){
					var record = g.getStore().getAt(index);
					Desktop.AppMgr.display('user_form', record.get('username'));
				}
			},
			scope: this
		});
		
		//setup mainBar 
		var mainBar = [
			{text: 'New', iconCls: 'dt-icon-add', handler:function(){this.fireEvent('new')}, scope: this},
			{text: 'Edit', itemId: 'edit', iconCls: 'dt-icon-edit', hidden:true, handler:function(){this.fireEvent('edit')}, scope: this}
		];
		
		//apply all components to this app instance
 		Ext.apply(this, {
 			items : grid,
			mainBar : mainBar
 		});
 		
		//call App initComponent
		User.Index.superclass.initComponent.call(this);
		
		//event handlers
		this.on('new',function(){
			Desktop.AppMgr.display('user_form');
		});
		
		this.on('edit',function(){
			var record = grid.getSelectionModel().getSelected();
			Desktop.AppMgr.display('user_form', record.get('username'));
		});
		
		this.on('render',function(){
			store.reload();
		});
 	}
});

Desktop.AppMgr.registerApp(User.Index, {
	title: 'Users',
	iconCls: 'dt-icon-user',
	appId: 'user_index',
	displayMenu: 'admin',
	dockContainer: Desktop.CENTER
});