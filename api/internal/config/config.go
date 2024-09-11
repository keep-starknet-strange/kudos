package data

import (
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
)

var GOOGLE_CONFIG *oauth2.Config

func Init() {
	GOOGLE_CONFIG = &oauth2.Config{
		ClientID:     "<REPLACE_ME>",
		ClientSecret: "<REPLACE_ME>",
		RedirectURL:  "<REPLACE_ME>",
		Scopes: []string{
			"https://www.googleapis.com/auth/userinfo.email",
			"https://www.googleapis.com/auth/userinfo.profile",
		},
		Endpoint: google.Endpoint,
	}
}
