
static const char _afb_description_v2_UNICENS[] =
    "{\"openapi\":\"3.0.0\",\"$schema\":\"http:iot.bzh/download/openapi/schem"
    "a-3.0/default-schema.json\",\"info\":{\"description\":\"\",\"title\":\"u"
    "cs2\",\"version\":\"1.0\",\"x-binding-c-generator\":{\"api\":\"UNICENS\""
    ",\"version\":2,\"prefix\":\"ucs2_\",\"postfix\":\"\",\"start\":null,\"on"
    "event\":null,\"init\":null,\"scope\":\"\",\"private\":false}},\"servers\""
    ":[{\"url\":\"ws://{host}:{port}/api/monitor\",\"description\":\"Unicens2"
    " API.\",\"variables\":{\"host\":{\"default\":\"localhost\"},\"port\":{\""
    "default\":\"1234\"}},\"x-afb-events\":[{\"$ref\":\"#/components/schemas/"
    "afb-event\"}]}],\"components\":{\"schemas\":{\"afb-reply\":{\"$ref\":\"#"
    "/components/schemas/afb-reply-v2\"},\"afb-event\":{\"$ref\":\"#/componen"
    "ts/schemas/afb-event-v2\"},\"afb-reply-v2\":{\"title\":\"Generic respons"
    "e.\",\"type\":\"object\",\"required\":[\"jtype\",\"request\"],\"properti"
    "es\":{\"jtype\":{\"type\":\"string\",\"const\":\"afb-reply\"},\"request\""
    ":{\"type\":\"object\",\"required\":[\"status\"],\"properties\":{\"status"
    "\":{\"type\":\"string\"},\"info\":{\"type\":\"string\"},\"token\":{\"typ"
    "e\":\"string\"},\"uuid\":{\"type\":\"string\"},\"reqid\":{\"type\":\"str"
    "ing\"}}},\"response\":{\"type\":\"object\"}}},\"afb-event-v2\":{\"type\""
    ":\"object\",\"required\":[\"jtype\",\"event\"],\"properties\":{\"jtype\""
    ":{\"type\":\"string\",\"const\":\"afb-event\"},\"event\":{\"type\":\"str"
    "ing\"},\"data\":{\"type\":\"object\"}}}},\"x-permissions\":{\"config\":{"
    "\"permission\":\"urn:AGL:permission:UNICENS:public:initialise\"},\"monit"
    "or\":{\"permission\":\"urn:AGL:permission:UNICENS:public:monitor\"}},\"r"
    "esponses\":{\"200\":{\"description\":\"A complex object array response\""
    ",\"content\":{\"application/json\":{\"schema\":{\"$ref\":\"#/components/"
    "schemas/afb-reply\"}}}}}},\"paths\":{\"/listconfig\":{\"description\":\""
    "List Config Files\",\"get\":{\"x-permissions\":{\"$ref\":\"#/components/"
    "x-permissions/config\"},\"parameters\":[{\"in\":\"query\",\"name\":\"cfg"
    "path\",\"required\":false,\"schema\":{\"type\":\"string\"}}],\"responses"
    "\":{\"200\":{\"$ref\":\"#/components/responses/200\"}}}},\"/initialise\""
    ":{\"description\":\"configure Unicens2 lib from NetworkConfig.XML.\",\"g"
    "et\":{\"x-permissions\":{\"$ref\":\"#/components/x-permissions/config\"}"
    ",\"parameters\":[{\"in\":\"query\",\"name\":\"filename\",\"required\":tr"
    "ue,\"schema\":{\"type\":\"string\"}}],\"responses\":{\"200\":{\"$ref\":\""
    "#/components/responses/200\"}}}},\"/subscribe\":{\"description\":\"Subsc"
    "ribe to UNICENS Events.\",\"get\":{\"x-permissions\":{\"$ref\":\"#/compo"
    "nents/x-permissions/monitor\"},\"responses\":{\"200\":{\"$ref\":\"#/comp"
    "onents/responses/200\"}}}},\"/writei2c\":{\"description\":\"Writes I2C c"
    "ommand to remote node.\",\"get\":{\"x-permissions\":{\"$ref\":\"#/compon"
    "ents/x-permissions/monitor\"},\"parameters\":[{\"in\":\"query\",\"name\""
    ":\"node\",\"required\":true,\"schema\":{\"type\":\"integer\",\"format\":"
    "\"int32\"}},{\"in\":\"query\",\"name\":\"data\",\"required\":true,\"sche"
    "ma\":{\"type\":\"array\",\"format\":\"int32\"},\"style\":\"simple\"}],\""
    "responses\":{\"200\":{\"$ref\":\"#/components/responses/200\"}}}}}}"
;

static const struct afb_auth _afb_auths_v2_UNICENS[] = {
	{ .type = afb_auth_Permission, .text = "urn:AGL:permission:UNICENS:public:initialise" },
	{ .type = afb_auth_Permission, .text = "urn:AGL:permission:UNICENS:public:monitor" }
};

 void ucs2_listconfig(struct afb_req req);
 void ucs2_initialise(struct afb_req req);
 void ucs2_subscribe(struct afb_req req);
 void ucs2_writei2c(struct afb_req req);

static const struct afb_verb_v2 _afb_verbs_v2_UNICENS[] = {
    {
        .verb = "listconfig",
        .callback = ucs2_listconfig,
        .auth = &_afb_auths_v2_UNICENS[0],
        .info = "List Config Files",
        .session = AFB_SESSION_NONE_V2
    },
    {
        .verb = "initialise",
        .callback = ucs2_initialise,
        .auth = &_afb_auths_v2_UNICENS[0],
        .info = "configure Unicens2 lib from NetworkConfig.XML.",
        .session = AFB_SESSION_NONE_V2
    },
    {
        .verb = "subscribe",
        .callback = ucs2_subscribe,
        .auth = &_afb_auths_v2_UNICENS[1],
        .info = "Subscribe to UNICENS Events.",
        .session = AFB_SESSION_NONE_V2
    },
    {
        .verb = "writei2c",
        .callback = ucs2_writei2c,
        .auth = &_afb_auths_v2_UNICENS[1],
        .info = "Writes I2C command to remote node.",
        .session = AFB_SESSION_NONE_V2
    },
    {
        .verb = NULL,
        .callback = NULL,
        .auth = NULL,
        .info = NULL,
        .session = 0
	}
};

const struct afb_binding_v2 afbBindingV2 = {
    .api = "UNICENS",
    .specification = _afb_description_v2_UNICENS,
    .info = "",
    .verbs = _afb_verbs_v2_UNICENS,
    .preinit = NULL,
    .init = NULL,
    .onevent = NULL,
    .noconcurrency = 0
};

