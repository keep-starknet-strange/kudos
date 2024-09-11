package handlers

import (
	"net/http"

	"github.com/keep-starknet-strange/kudos/api/internal/config"
	"github.com/gin-gonic/gin"
)

type GoogleUser struct {
	ID            string `json:"id,omitempty"`
	Email         string `json:"email,omitempty"`
	VerifiedEmail bool   `json:"verified_email,omitempty"`
	Name          string `json:"name,omitempty"`
	GivenName     string `json:"given_name,omitempty"`
	FamilyName    string `json:"family_name,omitempty"`
	Picture       string `json:"picture,omitempty"`
	Locale        string `json:"locale,omitempty"`
}

func LoginGoogle(c *gin.Context) {
	authorizationURL := config.GOOGLE_CONFIG.AuthCodeURL("state")

	c.IndentedJSON(http.StatusOK, gin.H{"authorizationUrl": authorizationURL})
}