package types

import (
	"fmt"

	"github.com/jmoiron/sqlx"
	"github.com/pidanou/c1-core/internal/constants"
)

type ConnectorForm struct {
	NameOverride string `form:"name_override" json:"name_override"`
	Config       string `form:"config" json:"config"`
}

type Filter interface {
	ToSQL(db *sqlx.DB, query string) (q string, args []interface{}, err error)
}

func isValidOrderBy(orderBy string) bool {
	allowedColumns := map[string]bool{
		"account_id":    true,
		"resource_name": true,
	}
	return allowedColumns[orderBy]
}

type DataFilter struct {
	Search       string   `query:"search"`
	Page         int      `query:"page"`
	Limit        int      `query:"limit"`
	Accounts     []int    `query:"account_id"`
	Connectors   []string `query:"connector"`
	OrderBy      string   `query:"order_by"`
	Sort         string   `query:"sort"`
	LastSyncedAt LastSyncedAt
}

type LastSyncedAt struct {
	DateTime string
	Operator string
}

func (d *DataFilter) ToSQL(db *sqlx.DB, baseQuery, countQuery string) (string, string, []interface{}, error) {
	var args []interface{}
	if d.Search != "" {
		baseQuery += fmt.Sprint(" AND (resource_name LIKE ? OR metadata LIKE ? OR notes LIKE ?)")
		countQuery += fmt.Sprint(" AND (resource_name LIKE ? OR metadata LIKE ? OR notes LIKE ?)")
		args = append(args, "%"+d.Search+"%", "%"+d.Search+"%", "%"+d.Search+"%")
	}
	if d.Accounts != nil {
		queryPart, argsPart, _ := sqlx.In(" AND account_id in (?)", d.Accounts)
		baseQuery += queryPart
		countQuery += queryPart
		args = append(args, argsPart...)
	}
	if d.Connectors != nil {
		queryPart, argsPart, _ := sqlx.In(" AND connector in (?)", d.Connectors)
		baseQuery += queryPart
		countQuery += queryPart
		args = append(args, argsPart...)
	}
	if d.LastSyncedAt.DateTime != "" {
		if d.LastSyncedAt.Operator != ">" && d.LastSyncedAt.Operator != "<" {
			d.LastSyncedAt.Operator = ">"
		}
		baseQuery += " AND last_synced_at " + d.LastSyncedAt.Operator + " ?"
		countQuery += " AND last_synced_at " + d.LastSyncedAt.Operator + " ?"
		args = append(args, d.LastSyncedAt.DateTime)
	}
	if d.OrderBy != "" && isValidOrderBy(d.OrderBy) {
		baseQuery += fmt.Sprintf("%v ORDER BY %s", baseQuery, d.OrderBy)
	} else {
		baseQuery += " ORDER BY account_id ASC, resource_name ASC"
	}
	if d.Sort != "" && (d.Sort == "ASC" || d.Sort == "DESC") {
		baseQuery += fmt.Sprintf(" %v", d.Sort)
	}
	baseQuery += " LIMIT 50"
	if d.Page != 0 {
		baseQuery += fmt.Sprintf(" Offset %v", (d.Page-1)*constants.PageSize)
	}
	baseQuery = db.Rebind(baseQuery)
	countQuery = db.Rebind(countQuery)
	return baseQuery, countQuery, args, nil

}

type SyncInfoFilter struct {
	Connectors []string `query:"connector"`
	Accounts   []int    `query:"account_id"`
	Success    *bool    `query:"success"`
	Page       int      `query:"page"`
	Limit      int      `query:"limit"`
	OrderBy    string   `query:"order_by"`
	Sort       string   `query:"sort"`
}
