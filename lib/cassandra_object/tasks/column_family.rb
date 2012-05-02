module CassandraObject
  module Tasks
    class ColumnFamily
      COLUMN_TYPES = {
        standard: 'Standard',
        super:    'Super'
      }

      def initialize(keyspace)
        @keyspace = keyspace
      end

      def exists?(name)
        CassandraObject::Base.connection.tables["#{CassandraObject::Base.namespace}.#{name.to_s.underscore}"].exists?
        # connection.schema.cf_defs.find { |cf_def| cf_def.name == name.to_s }
      end

      def create(name)
        CassandraObject::Base.connection.tables.create(
          "#{CassandraObject::Base.namespace}.#{name.to_s.underscore}",
          10, 10
        )
        # cf = Cassandra::ColumnFamily.new
        # cf.name = name.to_s
        # cf.keyspace = @keyspace.to_s
        # cf.comparator_type = 'UTF8Type'
        # cf.column_type = 'Standard'
        # 
        # yield(cf) if block_given?
        # 
        # post_process_column_family(cf)
        # connection.add_column_family(cf)
      rescue => e
        p "Error: #{e.message}"
      end

      def drop(name)
        connection.drop_column_family(name.to_s)
      end

      def rename(old_name, new_name)
        connection.rename_column_family(old_name.to_s, new_name.to_s)
      end

      private
        def connection
          CassandraObject::Base.connection
        end

        def post_process_column_family(cf)
          col_type = cf.column_type
          if col_type && COLUMN_TYPES.has_key?(col_type)
            cf.column_type = COLUMN_TYPES[col_type]
          end

          cf
        end
    end
  end
end

class Cassandra
  class ColumnFamily
    def with_fields(options)
      struct_fields.collect { |f| f[1][:name] }.each do |f|
        send("#{f}=", options[f.to_sym] || options[f.to_s])
      end
      self
    end
  end
end

