PLUGIN KONG ORACLE IDCS

PT-BR: 

Sobre:

A ideia do plugin é viabilizar a integração nativa com a autenticação dos serviços que estão cadastrados no IDCS da Oracle Cloud.

Como usar: 

Como adicionar o plugin em um Kong gateway services via RestAPI do próprio admin do Kong: 

POST - http://{kong-base-path}/services/{id}/plugins

Body:

{
	"name": "kong-oracle-idcs",
	"config": {
		"oracle_idcs_base_url": {ORACLE-IDCS-BASE-PATH}, (Obrigatório)
		"clients": [
			{
				"client_id": {client_id}, (Obrigatório)
				"client_secret": {client_secret}, (Obrigatório)
				"scope": {scopes} (Opcional)
			}
	    ...
		]
	}
}

Fique a vontade para fazer um Fork do repositório.

Esse plugin é opensource e está sendo mantido por pedrofarbo@gmail.com

EN: 

About:

The idea of the plugin is to enable native integration with the authentication of services registered in Oracle Cloud's IDCS.

How to use:

To add the plugin to a Kong gateway service via the Kong admin's RestAPI:

POST - http://{kong-base-path}/services/{id}/plugins

Body:

{
	"name": "kong-oracle-idcs",
	"config": {
		"oracle_idcs_base_url": {ORACLE-IDCS-BASE-PATH}, (Required)
		"clients": [
			{
				"client_id": {client_id}, (Required)
				"client_secret": {client_secret}, (Required)
				"scope": {scopes} (Optional)
			}
		...
		]
	}
}

Feel free to fork the repository.

This plugin is open source and it is being maintained by pedrofarbo@gmail.com.