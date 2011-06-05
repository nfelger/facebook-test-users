$(function() {
  window.Application = Backbone.Model.extend({
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

  window.Applications = new ApplicationList;
  
  window.ApplicationView = Backbone.View.extend({
    tagName: "li",
    
    template: _.template($("#application-template").html()),
    
    initialize: function() {
      _.bindAll(this, 'render');
      this.model.bind('change', this.render);
      this.model.view = this;
    },
    
    render: function() {
      $(this.el).html(this.template(this.model.toJSON()));
      return this;
    },
  });

  window.AppView = Backbone.View.extend({
    el: $("#test-users"),
    
    initialize: function() {
      _.bindAll(this, 'addOne', 'addAll');
      
      Applications.bind('refresh', this.addAll);
      
      Applications.fetch();
    },
    
    addOne: function(application) {
      var view = new ApplicationView({model: application});
      this.$("#applications").append(view.render().el);
    },
    
    addAll: function() {
      Applications.each(this.addOne);
    },
  });
  
});
