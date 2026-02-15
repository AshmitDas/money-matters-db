# Database Initialization & Maintenance

This repository contains the SQL scripts necessary to set up, configure, and clean the database environment. Following the correct execution order is critical to maintain referential integrity.

---

## 📂 Execution Order

Please run the scripts in the following sequence to ensure that tables and dependencies are created before data is inserted.

| Step | Script Name | Description |
| :--- | :--- | :--- |
| **1** | `Table Creation.SQL` | Generates the base schema, defines data types, and sets up primary/foreign keys. |
| **2** | `Transaction Types Creation.SQL` | Populates lookup tables for transaction categories and system logic. |
| **3** | `Currency Insertion.SQL` | Seeds the database with standard currency codes and formatting data. |

---

## 🧹 Cleanup & Reset

If you need to wipe the database and start from scratch, use the cleanup script:

* **`Database Cleanup.SQL`**
    * **Action:** Drops tables and removes all associated data.
    * **Caution:** This action is irreversible. Ensure you have backups if running this in a non-development environment.

---

## 🛠 Usage Notes

* **Constraints:** Script #1 must be successful before running Script #2 or #3, as they rely on the existence of the tables.
* **Permissions:** Ensure your SQL user profile has `CREATE`, `DROP`, and `INSERT` privileges.
* **Environment:** Recommended for use in local development or staging environments.

---
