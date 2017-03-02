module Chrysalis::Router
  ROUTE_VAR_STRING = ":var"

  class BranchAttachment(RouteAttachment)
    getter :route_attachment

    @route_attachment : RouteAttachment

    def initialize(@route_attachment)
    end
  end

  class BranchShouldBeRootIfWithAttachmentException < Exception
    def initialize
      super "[chrysalis-router]: tried to create branch with is_root = false and attachment."
    end
  end

  # This is branch for building tree for router
  # There could be attachment to branch
  class Branch(RouteAttachmentType)
    getter :branches, :attachment
    
    @branches = {} of String => Branch(RouteAttachmentType)
    @attachment : BranchAttachment(RouteAttachmentType)?
    @is_route : Bool = false

    def initialize
    end

    def initialize(@attachment)
      # Only routes can have attachment
      @is_route = true
    end

    def route?
      @is_route
    end
    
    # For debug purpose
    def to_s(ident = 0)
      ident_s = ""

      (0..ident).each do
        ident_s = ident_s + " "
      end
      
      next_line_s = @branches.keys.size != 0 ? "\n" : ""
      
      ident_s = "" if @branches.keys.size == 0

      s = ident == 0 ? "Routes tree (• after path means it has attachment, so it basically a functioning route):\n\n" : ""
      
      s += ident_s + "#{next_line_s}#{ident_s}{"
      
      ident_s_one = ident_s + "  "
      
      @branches.each do |str, branch|
        route_s = branch.route? ? "•" : ""

        s = s + %(\n#{ident_s_one}"/#{str}#{route_s}": #{branch.to_s ident + 4}, )
      end
      
      s = s + "#{next_line_s}" + ident_s + "}"
      
      s
    end
  end

  class RouteNotFoundException < Exception
    def initialize(path : String)
      super "[chrysalis-router]: tried to find route for path #{path}, did not find any"
    end
  end

  class RouteCannotBeEmptyException < Exception
    def initialize
      super "[chrysalis-router]: tried to add empty route, which is not allowed!"
    end
  end
  
  # Manages routes, adding them, finding the, throwing error if not found.
  class RoutesManager(RouteAttachmentType)
    @tree = Branch(RouteAttachmentType).new
    
    # Adding route and return value to the tree
    def add_route(path : String, attachment : RouteAttachmentType)  
      branch = @tree

      parts = get_parts path

      parts.each do |part|
        part_is_last = part == parts[parts.size - 1]

        if !branch.branches.has_key? part
          # If this is the branch for given path, we should add
          # branch attachment with route attachment
          if part_is_last
            new_branch = Branch(RouteAttachmentType).new(
              BranchAttachment(RouteAttachmentType).new attachment
            )
          else
            new_branch = Branch(RouteAttachmentType).new
          end

          branch.branches[part] = new_branch
        end

        branch = branch.branches[part]
      end
    end
        
    def resolve_path(path : String) : RouteAttachmentType
      branch = @tree

      parts = get_parts(path)

      attachment : BranchAttachment(RouteAttachmentType)? = nil

      parts.each do |part|
        # If there is no part, it maybe variable part, it maybe anything
        if !branch.branches.has_key? part
          raise RouteNotFoundException.new path unless branch.branches.has_key? ROUTE_VAR_STRING

          part_index = parts.index part

          parts[part_index.as(Int32)] = ROUTE_VAR_STRING

          part = ROUTE_VAR_STRING
        end

        branch = branch.branches[part]

        part_is_last = part == parts[parts.size - 1]

        if (part_is_last && branch.route?)
          attachment = branch.attachment
        end
      end

      raise RouteNotFoundException.new path unless attachment

      attachment.as(BranchAttachment(RouteAttachmentType)).route_attachment
    end

    def debug_tree_structure : String
      @tree.to_s
    end

    # Breaking path to parts readable by routes manager
    private def get_parts(path : String) : Array(String)
      path == "/" ? [""] : (path.split "/").map { |p| (p.starts_with? ":") ? ROUTE_VAR_STRING : p }
    end
  end
end