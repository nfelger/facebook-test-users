$(function() {
  // Requires an appId and appSecret, passed in e.g. like so:
  //   new FacebookAppCredentials({
  //     appId: 123,
  //     appSecret: "abc"
  //   });
  //
  window.FacebookAppCredentials = Backbone.Model.extend({
    initialize: function() {
      _.bindAll(this, 'url');
    },
    
    url: function() {
      return "/access_token?app_id=" + this.get('appId') + "&app_secret=" + this.get('appSecret');
    },
  });
  
  window.TestUser = Backbone.Model.extend({});
  
  window.TestUsers = Backbone.Collection.extend({
    model: TestUser,

    initialize: function() {
      _.bindAll(this, 'url');
    },
    
    url: function() {
      return "/apps/" + this.credentials.get('appId') + "/test_users?access_token=" + escape(this.credentials.get('accessToken'));
    },
  });
  
  window.Application = Backbone.Model.extend({
    initialize: function() {
      _.bindAll(this, 'cookieName');
    },
    
    cookieName: function() {
      return escape(this.get("name").toLowerCase().replace(' ', '-') + "-secret");
    },
  });
  
  window.ApplicationList = Backbone.Collection.extend({
    model: Application,

    // Aaaargh, dependecy creep...
    url: "https://graph.facebook.com/me?fields=accounts&callback=?&access_token=" + FB.getSession().access_token,
    
    parse: function(response) {
      return _.select(response.accounts.data, function(account) {
        return account.category === "Application"
      });
    },
  });

  window.TestUserView = Backbone.View.extend({
    tagName: "tr",
    
    template: _.template($("#test-user-template").html()),
    
    events: {
      "submit .deleteUser": "deleteUser"
    },
    
    initialize: function() {
      _.bindAll(this, 'deleteUser', 'render');
    },
        
    deleteUser: function() {
      var view = this.collectionView;
      this.$("form.deleteUser").ajaxSubmit(function() {
        // Get the list of users again after user creation is complete.
        view.fetchUsers();
      });
      
      // Disable default submit action.
      return false;
    },
    
    render: function() {
      $(this.el).html(this.template({
        model: this.model.toJSON(),
        credentials: this.credentials.toJSON()
      }));
      return this;
    },
  });
  
  window.TestUsersView = Backbone.View.extend({
    tagName: 'div',
    
    template: _.template($("#test-users-template").html()),

    events: {
      "submit .createUser": "createUser"
    },
    
    initialize: function() {
      _.bindAll(this, 'addOne', 'createUser', 'fetchUsers', 'render');
    },
    
    addOne: function(testUser) {
      var view = new TestUserView({ model: testUser });
      view.credentials = this.credentials;
      view.collectionView = this;
      this.$("tbody").append(view.render().el);
    },
    
    createUser: function() {
      var view = this;
      this.$("form.createUser").ajaxSubmit(function() {
        // Get the list of users again after user creation is complete.
        view.fetchUsers();
      });
      
      // Disable default submit action.
      return false;
    },
    
    fetchUsers: function() {
      this.testUsers = new TestUsers;
      this.testUsers.credentials = this.credentials;
      this.testUsers.bind('refresh', this.render);
      this.testUsers.fetch();
    },
    
    render: function() {
      $(this.el).html(this.template(this.testUsers.credentials.toJSON()));
      $(this.applicationView.el).append(this.el);
      this.testUsers.each(this.addOne);
    },
  });
  
  window.ApplicationView = Backbone.View.extend({
    tagName: "li",
    
    template: _.template($("#application-template").html()),
    
    events: {
      "submit .fetchUsers": "fetchUsers",
    },
    
    initialize: function() {
      _.bindAll(this, 'render');
      this.model.bind('change', this.render);
      this.model.view = this;
    },
    
    fetchUsers: function() {
      var secret = this.$('.appSecret').val();
      $.cookie(this.model.cookieName(), secret, {path: '/', expires: 365});
      var credentials = new FacebookAppCredentials({
        appId: this.model.get('id'),
        appSecret: secret
      });
      this.testUsersView = new TestUsersView;
      this.testUsersView.credentials = credentials;
      this.testUsersView.applicationView = this;
      credentials.fetch();
      credentials.bind('change', this.testUsersView.fetchUsers);

      // Disable default submit action.
      return false;
    },
    
    render: function() {
      $(this.el).html(this.template(this.model.toJSON()));
      this.$('.appSecret').val($.cookie(this.model.cookieName()));
      return this;
    },
  });

  window.AppView = Backbone.View.extend({
    el: $("#test-users"),
    
    initialize: function() {
      _.bindAll(this, 'addOne', 'render');
      
      this.applications = new ApplicationList;
      this.applications.bind('refresh', this.render);
      this.applications.fetch();
    },
    
    addOne: function(application) {
      var view = new ApplicationView({model: application});
      this.$("#applications").append(view.render().el);
    },
    
    render: function() {
      this.applications.each(this.addOne);
    },
  });
  
});
