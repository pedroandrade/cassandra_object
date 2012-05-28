module CassandraObject
  module Connection
    extend ActiveSupport::Concern
    
    included do
      class_attribute :connection
      class_attribute :namespace
    end

    module ClassMethods
      # DEFAULT_OPTIONS = {
      #   servers: "127.0.0.1:9160",
      #   thrift: {}
      # }
      def establish_connection(spec)
        self.namespace = spec[:namespace]
        self.connection = AWS::DynamoDB.new(
          access_key_id: spec[:access_key_id],
          secret_access_key: spec[:secret_access_key]
        )
      end

      def dynamo_table
        @dynamo_table ||= begin
          table = connection.tables[dynamo_table_name]
          table.hash_key = [:id, :number]
          table
        end
      end

      def dynamo_table_name
        "#{namespace}.#{column_family.underscore}"
      end
    end
  end
end
