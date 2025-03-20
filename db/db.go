package db

import (
	"database/sql"
	"fmt"
	"time"

	_ "github.com/jackc/pgx/v5/stdlib"
)

type DB struct {
	DB *sql.DB
}

var dbConn = &DB{}

const maxOpenDbConn = 10
const maxIdleDbConn = 5
const maxDbLifetime = 5 * time.Minute

func ConnectPostgres(dsn string) (*DB, error) {
	fmt.Printf("Attempting to connect to database with DSN: %s\n", dsn)
	d, err := sql.Open("pgx", dsn)
	if err != nil {
		fmt.Printf("Error opening database connection: %v\n", err)
		return nil, err
	}

	fmt.Println("Setting connection pool settings...")
	d.SetMaxOpenConns(maxOpenDbConn)
	d.SetMaxIdleConns(maxIdleDbConn)
	d.SetConnMaxLifetime(maxDbLifetime)

	fmt.Println("Testing database connection...")
	err = testDB(d)
	if err != nil {
		fmt.Printf("Error testing database connection: %v\n", err)
		return nil, err
	}

	dbConn.DB = d
	fmt.Println("Database connection successful!")
	return dbConn, nil
}

func testDB(d *sql.DB) error {
	err := d.Ping()
	if err != nil {
		fmt.Printf("Error pinging database: %v\n", err)
		return err
	}
	fmt.Println("*** Pinged database successfully! ***")
	return nil
}
