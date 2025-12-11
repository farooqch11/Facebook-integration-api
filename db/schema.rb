ActiveRecord::Schema[7.2].define(version: 2025_11_21_102306) do
  enable_extension "plpgsql"

  # === Multi-Tenant Core ===
  create_table "organizations", force: :cascade do |t|
    t.string   "name", null: false
    t.string   "time_zone"
    t.jsonb    "settings", default: {}
    t.timestamps
    t.index ["name"], unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string   "email", null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "encrypted_password", null: false
    t.boolean  "enabled", default: true
    t.references :organization, null: false, foreign_key: true
    t.timestamps
    t.index ["email"], unique: true
  end

  # === Roles & Permissions (RBAC) ===
  create_table "roles", force: :cascade do |t|
    t.string   "name", null: false
    t.boolean  "is_admin", default: false
    t.references :organization
    t.timestamps
    t.index ["name", "organization_id"], unique: true
  end

  create_table "permissions", force: :cascade do |t|
    t.string   "key", null: false
    t.timestamps
    t.index ["key"], unique: true
  end

  create_table "role_permissions", force: :cascade do |t|
    t.references :role, null: false
    t.references :permission, null: false
    t.boolean "enabled", default: false
    t.index ["role_id", "permission_id"], unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.references :user, null: false
    t.references :role, null: false
    t.index ["user_id", "role_id"], unique: true
  end

  # === Content & Facilities (Example Domain Models) ===
  create_table "locations", force: :cascade do |t|
    t.references :organization, null: false
    t.string     "name", null: false
    t.string     "address"
    t.jsonb      "metadata", default: {}
    t.timestamps
  end

  create_table "resources", force: :cascade do |t|
    t.references :location, null: false
    t.string     "name", null: false
    t.integer    "resource_type", null: false
    t.jsonb      "details", default: {}
    t.timestamps
  end

  # === Scheduling (Multi-Tenant Operations Layer) ===
  create_table "schedules", force: :cascade do |t|
    t.references :location, null: false
    t.integer    "schedule_type", null: false
    t.date       "week_start_date", null: false
    t.string     "title"
    t.index ["location_id", "schedule_type", "week_start_date"],
          name: "index_unique_week_per_location_and_type",
          unique: true
    t.timestamps
  end

  create_table "schedule_entries", force: :cascade do |t|
    t.references :schedule, null: false
    t.references :assigned_user
    t.date       "date", null: false
    t.boolean    "on_call", default: false
    t.timestamps
  end

  # === Notifications System ===
  create_table "notifications", force: :cascade do |t|
    t.references :organization, null: false
    t.references :sender, null: false
    t.integer    "notification_type", default: 0
    t.string     "title", null: false
    t.text       "body"
    t.datetime   "archived_at"
    t.timestamps
  end

  create_table "notification_recipients", force: :cascade do |t|
    t.references :notification, null: false
    t.references :user, null: false
    t.index ["notification_id", "user_id"], unique: true
    t.timestamps
  end

  # === Media Storage (Active Storage) ===
  create_table "active_storage_blobs", force: :cascade do |t|
    t.string   "key", null: false
    t.string   "filename", null: false
    t.string   "content_type"
    t.bigint   "byte_size", null: false
    t.jsonb    "metadata"
    t.timestamps
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string     "name", null: false
    t.references :record, null: false, polymorphic: true
    t.references :blob, null: false
    t.timestamps
  end

  # === JWT Auth (API Authentication Layer) ===
  create_table "jwt_denylists", force: :cascade do |t|
    t.string   "jti", null: false
    t.datetime "exp", null: false
    t.timestamps
    t.index ["jti"], unique: true
  end
end
