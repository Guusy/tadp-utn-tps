def find_by_id(table, id)
  TADB::DB.table(table)
      .entries
      .select { |entry| entry[:id] === id }
      .first
end