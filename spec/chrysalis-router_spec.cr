require "./spec_helper"
require "../src/chrysalis-router.cr"

include Chrysalis::Router

def route_not_found?(&block)
  begin
    block.call

    false
  rescue RouteNotFoundException
    true
  end
end

describe Chrysalis::Router do
  manager = RoutesManager(String).new

  it "should handle adding new routes with attachments just fine" do
    manager.add_route "/", "Index"
    manager.add_route "/products", "Products"
  end

  puts manager.debug_tree_structure

  it "should get routes attachments without problems, also with trailing slash - route not found" do
    fail "Index page was not found correctly!" if manager.resolve_path("/") != "Index"
    fail "Products page was not found correctly!" if manager.resolve_path("/products") != "Products"

    fail "Products page with trailing slash should not be found!" if !route_not_found? { manager.resolve_path("/products/") }
  end

  it "should raise an exception if no route found" do
    exception_occured = false

    begin
      manager.resolve_path "/unknown-path"
    rescue RouteNotFoundException
      exception_occured = true
    end

    fail "There should've been an exception, but was none" if !exception_occured
  end

  it "should handle correctly routes with :variables" do
    manager.add_route "/products/:id/properties/:id", "Product Property"

    if manager.resolve_path("/products/23/properties/11") != "Product Property"
      fail "Route with 2 variables is not handled properly"
    end
  end

  manager = RoutesManager(String).new

  it "should handle route with variable even from start" do
    manager.add_route "/:controller/:action", "ControllerAction"

    if manager.resolve_path("/cars/all") != "ControllerAction"
      fail "Controller action route with variables was not handled correctly"
    end
  end
end
