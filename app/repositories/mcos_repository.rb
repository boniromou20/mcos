module MCOS
  module Repositories
    class McosRepository < Citrine::Repository[:sql]

      def before_save
        self.updated_at = Time.now
      end

      model :menu do
        unrestrict_primary_key

        def before_create
          create_time = Time.now
          self.created_at = create_time
          self.updated_at = create_time
        end
        
        def before_save
          self.updated_at = Time.now  
        end

        # dataset_module do 
        #   def find_all_menu()
        #     where(:target => '') 
        #   end
        # end

      end

      model :table do
        unrestrict_primary_key

        def before_create
          create_time = Time.now
          self.created_at = create_time
          self.updated_at = create_time
        end
        
        def before_save
          self.updated_at = Time.now  
        end
      end

      model :order do
        unrestrict_primary_key

        def before_create
          create_time = Time.now
          self.created_at = create_time
          self.updated_at = create_time
        end
        
        def before_save
          self.updated_at = Time.now  
        end
      end

      model :order_detail do
        unrestrict_primary_key

        def before_create
          create_time = Time.now
          self.created_at = create_time
          self.updated_at = create_time
        end
        
        def before_save
          self.updated_at = Time.now  
        end
      end

      model :bill do
        unrestrict_primary_key

        def before_create
          create_time = Time.now
          self.created_at = create_time
          self.updated_at = create_time
        end
        
        def before_save
          self.updated_at = Time.now  
        end
      end

    end
  end
end
