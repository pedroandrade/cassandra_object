module CassandraObject
  module FinderMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def find(key)
        key_string = key.try(:to_s)

        if key_string.blank?
          raise CassandraObject::RecordNotFound, "Couldn't find #{self.name} with key #{key.inspect}"
        # elsif attributes = connection.get(column_family, key_string, {:count => 500}).presence
        elsif (attributes = dynamo_table.items[key_string].attributes.to_h).any?
          # attributes = item.attributes.to_h
          instantiate(attributes.delete('id'), attributes)
        else
          raise CassandraObject::RecordNotFound
        end
      end

      def find_by_id(key)
        find(key)
      rescue CassandraObject::RecordNotFound
        nil
      end

      def all(options = {})
        limit = options[:limit] || 100
        results = ActiveSupport::Notifications.instrument("get_range.cassandra_object", column_family: column_family, key_count: limit) do
          dynamo_table.items.select#.limit(limit)
          # connection.get_range(column_family, key_count: limit, consistency: thrift_read_consistency, count: 500)
        end

        results.map do |result|
          attributes = result.attributes
          attributes.empty? ? nil : instantiate(attributes.delete("id"), attributes)
        end.compact
      end

      def first(options = {})
        all(options.merge(limit: 1)).first
      end

      def find_with_ids(*ids)
        ids = ids.flatten
        return ids if ids.empty?

        ids = ids.compact.map(&:to_s).uniq

        multi_get(ids).values.compact
      end

      def count
        # connection.count_range(column_family)
        dynamo_table.items.count
      end

      def multi_get(keys, options={})
        attribute_results = ActiveSupport::Notifications.instrument("multi_get.cassandra_object", column_family: column_family, keys: keys) do
          dynamo_table.batch_get(:all, keys.map(&:to_s))
        end

        Hash[attribute_results.map do |attributes|
          key = attributes.delete("id")
          [parse_key(key), attributes.present? ? instantiate(key, attributes) : nil]
        end]
      end
    end
  end
end