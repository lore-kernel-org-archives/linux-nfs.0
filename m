Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:33888 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933386AbeCGQqQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Mar 2018 11:46:16 -0500
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.rdu2.redhat.com [10.11.54.5])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 3450AD1424
        for <linux-nfs@vger.kernel.org>; Wed,  7 Mar 2018 16:46:16 +0000 (UTC)
Message-ID: <1520441174.7682.6.camel@redhat.com>
Subject: [PATCH] nfs-utils: Fix variable shadowing issue caused by ABI
 cleanup
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Steve Dickson <steved@redhat.com>
Date: Wed, 07 Mar 2018 16:46:14 +0000
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A mistake when cleaning up the ABI caused certain values to not
be available to libnfsidmap plugins, requiring code reorganisation
to not expose further unneccesary symbols. Adds one symbol reporting
the configuration file path used.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 support/nfsidmap/libnfsidmap.c      | 66 ++++-------------------------
 support/nfsidmap/nfsidmap_common.c  | 82 +++++++++++++++++++++++++++++++++++--
 support/nfsidmap/nfsidmap_plugin.h  |  1 +
 support/nfsidmap/nfsidmap_private.h |  6 +--
 support/nfsidmap/nss.c              | 26 ++++++++----
 support/nfsidmap/static.c           |  3 ++
 support/nfsidmap/umich_ldap.c       |  3 ++
 7 files changed, 111 insertions(+), 76 deletions(-)

diff --git a/support/nfsidmap/libnfsidmap.c b/support/nfsidmap/libnfsidmap.c
index d9d44de..35ddf01 100644
--- a/support/nfsidmap/libnfsidmap.c
+++ b/support/nfsidmap/libnfsidmap.c
@@ -104,14 +104,6 @@ nfs4_idmap_log_function_t idmap_log_func = default_logger;
 int idmap_verbosity = 2;
 #pragma GCC visibility push(hidden)
 
-static char * toupper_str(char *s)
-{
-	size_t i;
-	for (i=0; i < strlen(s); i++)
-		s[i] = toupper(s[i]);
-	return s;
-}
-
 static int id_as_chars(char *name, uid_t *id)
 {
 	long int value;
@@ -354,24 +346,22 @@ void nfs4_cleanup_name_mapping(void)
 
 #pragma GCC visibility pop
 
+const char * nfsidmap_conf_path = PATH_IDMAPDCONF;
+
 int nfs4_init_name_mapping(char *conffile)
 {
 	int ret = -ENOENT;
 	int dflt = 0;
 	struct conf_list *nfs4_methods, *gss_methods;
 	char *nobody_user, *nobody_group;
-	char *nostrip;
-	char *reformatgroup;
-	char *conf_path;
 
 	/* XXX: need to be able to reload configurations... */
 	if (nfs4_plugins) /* already succesfully initialized */
 		return 0;
 	if (conffile)
-		conf_path = conffile;
-	else
-		conf_path = PATH_IDMAPDCONF;
-	conf_init_file(conf_path);
+		nfsidmap_conf_path = conffile;
+	conf_init_file(nfsidmap_conf_path);
+
 	default_domain = conf_get_str("General", "Domain");
 	if (default_domain == NULL) {
 		dflt = 1;
@@ -388,30 +378,8 @@ int nfs4_init_name_mapping(char *conffile)
 	IDMAP_LOG(1, ("libnfsidmap: using%s domain: %s",
 		(dflt ? " (default)" : ""), default_domain));
 
-	/* Get list of "local equivalent" realms.  Meaning the list of realms
-	 * where john@REALM.A is considered the same user as john@REALM.B
-	 * If not specified, default to upper-case of local domain name */
-	local_realms = conf_get_list("General", "Local-Realms");
-	if (local_realms == NULL) {
-		struct conf_list_node *node;
-
-		local_realms = malloc(sizeof *local_realms);
-		if (local_realms == NULL)
-			return -ENOMEM;
-		local_realms->cnt = 0;
-		TAILQ_INIT(&local_realms->fields);
-
-		node = calloc(1, sizeof *node);
-		if (node == NULL)
-			return -ENOMEM;
-		node->field = strdup(get_default_domain());
-		if (node->field == NULL)
-			return -ENOMEM;
-		toupper_str(node->field);
-
-		TAILQ_INSERT_TAIL(&local_realms->fields, node, link);
-		local_realms->cnt++;
-	}
+	struct conf_list *local_realms = get_local_realms();
+	if (local_realms == NULL) return -ENOMEM;
 
 	if (idmap_verbosity >= 1) {
 		struct conf_list_node *r;
@@ -435,26 +403,6 @@ int nfs4_init_name_mapping(char *conffile)
 			IDMAP_LOG(1, ("libnfsidmap: Realms list: <NULL> "));
 	}
 
-	nostrip = conf_get_str_with_def("General", "No-Strip", "none");
-	if (strcasecmp(nostrip, "both") == 0)
-		no_strip = IDTYPE_USER|IDTYPE_GROUP;
-	else if (strcasecmp(nostrip, "group") == 0)
-		no_strip = IDTYPE_GROUP;
-	else if (strcasecmp(nostrip, "user") == 0)
-		no_strip = IDTYPE_USER;
-	else
-		no_strip = 0;
-
-	if (no_strip & IDTYPE_GROUP) {
-		reformatgroup = conf_get_str_with_def("General", "Reformat-Group", "false");
-		if ((strcasecmp(reformatgroup, "true") == 0) ||
-		    (strcasecmp(reformatgroup, "on") == 0) ||
-		    (strcasecmp(reformatgroup, "yes") == 0))
-			reformat_group = 1;
-		else
-			reformat_group = 0;
-	}
-
 	nfs4_methods = conf_get_list("Translation", "Method");
 	if (nfs4_methods) {
 		IDMAP_LOG(1, ("libnfsidmap: processing 'Method' list"));
diff --git a/support/nfsidmap/nfsidmap_common.c b/support/nfsidmap/nfsidmap_common.c
index 891c855..5242c7e 100644
--- a/support/nfsidmap/nfsidmap_common.c
+++ b/support/nfsidmap/nfsidmap_common.c
@@ -6,6 +6,9 @@
  *
  *  Code common to libnfsidmap and some of its bundled plugins
  *
+ *  If you make use of these functions you must initialise your own
+ *  copy of the config file data using: conf_init_file(nfsidmap_conf_path)
+ *  failure to do so will appear as if the config was empty
  */
 
 #include "config.h"
@@ -13,6 +16,8 @@
 #include <sys/types.h>
 #include <unistd.h>
 #include <stdlib.h>
+#include <errno.h>
+#include <string.h>
 
 #include "nfsidmap.h"
 #include "nfsidmap_private.h"
@@ -21,13 +26,82 @@
 
 #pragma GCC visibility push(hidden)
 
-int reformat_group = 0;
-int no_strip = 0;
-
-struct conf_list *local_realms;
+static char * toupper_str(char *s)
+{
+        size_t i;
+        for (i=0; i < strlen(s); i++)
+                s[i] = toupper(s[i]);
+        return s;
+}
 
+/* Get list of "local equivalent" realms.  Meaning the list of realms
+ * where john@REALM.A is considered the same user as john@REALM.B
+ * If not specified, default to upper-case of local domain name */
 struct conf_list *get_local_realms(void)
 {
+	static struct conf_list *local_realms = NULL;
+	if (local_realms) return local_realms;
+
+	local_realms = conf_get_list("General", "Local-Realms");
+	if (local_realms == NULL) {
+		struct conf_list_node *node;
+
+		local_realms = malloc(sizeof *local_realms);
+		if (local_realms == NULL)
+			return NULL;
+		local_realms->cnt = 0;
+		TAILQ_INIT(&local_realms->fields);
+
+		node = calloc(1, sizeof *node);
+		if (node == NULL)
+			return NULL;
+
+		node->field = calloc(1, NFS4_MAX_DOMAIN_LEN);
+		if (node->field == NULL)
+			return NULL;
+
+		nfs4_get_default_domain(NULL, node->field, NFS4_MAX_DOMAIN_LEN);
+		toupper_str(node->field);
+
+		TAILQ_INSERT_TAIL(&local_realms->fields, node, link);
+		local_realms->cnt++;
+	}
 	return local_realms;
 }
 
+static int no_strip = -1;
+static int reformat_group = 0;
+
+int get_nostrip(void)
+{
+	if (no_strip != -1) return no_strip;
+
+	char * nostrip = conf_get_str_with_def("General", "No-Strip", "none");
+	if (strcasecmp(nostrip, "both") == 0)
+		no_strip = IDTYPE_USER|IDTYPE_GROUP;
+	else if (strcasecmp(nostrip, "group") == 0)
+		no_strip = IDTYPE_GROUP;
+	else if (strcasecmp(nostrip, "user") == 0)
+		no_strip = IDTYPE_USER;
+	else
+		no_strip = 0;
+
+	if (no_strip & IDTYPE_GROUP) {
+		char * reformatgroup = conf_get_str_with_def("General", "Reformat-Group", "false");
+		if ((strcasecmp(reformatgroup, "true") == 0) ||
+		    (strcasecmp(reformatgroup, "on") == 0) ||
+		    (strcasecmp(reformatgroup, "yes") == 0))
+			reformat_group = 1;
+		else
+			reformat_group = 0;
+	}
+
+	return no_strip;
+}
+
+int get_reformat_group(void)
+{
+	if (no_strip != -1) return reformat_group;
+
+	return reformat_group;
+}
diff --git a/support/nfsidmap/nfsidmap_plugin.h b/support/nfsidmap/nfsidmap_plugin.h
index 708874c..66fcdaa 100644
--- a/support/nfsidmap/nfsidmap_plugin.h
+++ b/support/nfsidmap/nfsidmap_plugin.h
@@ -65,5 +65,6 @@ struct trans_func *libnfsidmap_plugin_init(void);
 #endif
 #endif
 
+extern const char *nfsidmap_conf_path;
 extern const char *nfsidmap_config_get(const char *section, const char *tag);
 
diff --git a/support/nfsidmap/nfsidmap_private.h b/support/nfsidmap/nfsidmap_private.h
index 2cc309e..f1af55f 100644
--- a/support/nfsidmap/nfsidmap_private.h
+++ b/support/nfsidmap/nfsidmap_private.h
@@ -37,16 +37,14 @@
 #include "conffile.h"
 
 struct conf_list *get_local_realms(void);
+int get_nostrip(void);
+int get_reformat_group(void);
 
 typedef enum {
 	IDTYPE_USER = 1,
 	IDTYPE_GROUP = 2
 } idtypes;
 
-extern int no_strip;
-extern int reformat_group;
-extern struct conf_list *local_realms;
-
 typedef struct trans_func * (*libnfsidmap_plugin_init_t)(void);
 
 struct mapping_plugin {
diff --git a/support/nfsidmap/nss.c b/support/nfsidmap/nss.c
index 65625a8..9d46499 100644
--- a/support/nfsidmap/nss.c
+++ b/support/nfsidmap/nss.c
@@ -38,6 +38,7 @@
 #include <errno.h>
 #include <unistd.h>
 #include <stdlib.h>
+#include <stdio.h>
 #include <string.h>
 #include <pwd.h>
 #include <grp.h>
@@ -103,7 +104,7 @@ static int nss_uid_to_name(uid_t uid, char *domain, char *name, size_t len)
 		err = -ENOENT;
 	if (err)
 		goto out_buf;
-	if (no_strip & IDTYPE_USER)
+	if (get_nostrip() & IDTYPE_USER)
 		err = write_name(name, pw->pw_name, domain, len, 0);
 	else
 		err = write_name(name, pw->pw_name, domain, len, 1);
@@ -140,7 +141,7 @@ static int nss_gid_to_name(gid_t gid, char *domain, char *name, size_t len)
 
 	if (err)
 		goto out_buf;
-	if (no_strip & IDTYPE_GROUP)
+	if (get_nostrip() & IDTYPE_GROUP)
 		err = write_name(name, gr->gr_name, domain, len, 0);
 	else
 		err = write_name(name, gr->gr_name, domain, len, 1);
@@ -247,7 +248,7 @@ static int nss_name_to_uid(char *name, uid_t *uid)
 	int err = -ENOENT;
 
 	domain = get_default_domain();
-	if (no_strip & IDTYPE_USER) {
+	if (get_nostrip() & IDTYPE_USER) {
 		pw = nss_getpwnam(name, domain, &err, 0);
 		if (pw != NULL)
 			goto out_uid;
@@ -315,7 +316,7 @@ static int _nss_name_to_gid(char *name, gid_t *gid, int dostrip)
 				  "into domain '%s'", name, domain));
 			goto out;
 		}
-	} else if (reformat_group) {
+	} else if (get_reformat_group()) {
 		ref_name = reformat_name(name);
 		if (ref_name == NULL) {
 			IDMAP_LOG(1, ("nss_name_to_gid: failed to reformat name '%s'",
@@ -335,7 +336,7 @@ static int _nss_name_to_gid(char *name, gid_t *gid, int dostrip)
 			goto out_name;
 		if (dostrip)
 			err = -getgrnam_r(localname, &grbuf, buf, buflen, &gr);
-		else if (reformat_group)
+		else if (get_reformat_group())
 			err = -getgrnam_r(ref_name, &grbuf, buf, buflen, &gr);
 		else
 			err = -getgrnam_r(name, &grbuf, buf, buflen, &gr);
@@ -343,7 +344,7 @@ static int _nss_name_to_gid(char *name, gid_t *gid, int dostrip)
 			if (dostrip)
 				IDMAP_LOG(1, ("nss_name_to_gid: name '%s' not found "
 					  "in domain '%s'", localname, domain));
-			else if (reformat_group)
+			else if (get_reformat_group())
 				IDMAP_LOG(1, ("nss_name_to_gid: name '%s' not found "
 					  "(reformatted)", ref_name));
 			else
@@ -366,7 +367,7 @@ out_buf:
 out_name:
 	if (dostrip)
 		free(localname);
-	if (reformat_group)
+	if (get_reformat_group())
 		free(ref_name);
 out:
 	return err;
@@ -376,7 +377,7 @@ static int nss_name_to_gid(char *name, gid_t *gid)
 {
 	int err = 0;
 
-	if (no_strip & IDTYPE_GROUP) {
+	if (get_nostrip() & IDTYPE_GROUP) {
 		err = _nss_name_to_gid(name, gid, 0);
 		if (!err)
 			goto out;
@@ -459,10 +460,17 @@ out:
 	return ret;
 }
 
+static int nss_plugin_init(void)
+{
+	if (nfsidmap_conf_path)
+		conf_init_file(nfsidmap_conf_path);
+	return 0;
+}
+
 
 struct trans_func nss_trans = {
 	.name		= "nsswitch",
-	.init		= NULL,
+	.init		= nss_plugin_init,
 	.princ_to_ids	= nss_gss_princ_to_ids,
 	.name_to_uid	= nss_name_to_uid,
 	.name_to_gid	= nss_name_to_gid,
diff --git a/support/nfsidmap/static.c b/support/nfsidmap/static.c
index 0b1173f..f7b8a67 100644
--- a/support/nfsidmap/static.c
+++ b/support/nfsidmap/static.c
@@ -317,6 +317,9 @@ static int static_init(void) {
 	for (i = 0; i < sizeof uid_mappings / sizeof uid_mappings[0]; i++)
 		LIST_INIT (&uid_mappings[i]);
 
+	if (nfsidmap_conf_path)
+		conf_init_file(nfsidmap_conf_path);
+
 	//get all principals for which we have mappings
 	princ_list = conf_get_tag_list("Static", NULL);
 
diff --git a/support/nfsidmap/umich_ldap.c b/support/nfsidmap/umich_ldap.c
index e82828c..0e31b1c 100644
--- a/support/nfsidmap/umich_ldap.c
+++ b/support/nfsidmap/umich_ldap.c
@@ -1101,6 +1101,9 @@ umichldap_init(void)
 	char missing_msg[128] = "";
 	char *server_in, *canon_name;
 
+	if (nfsidmap_conf_path)
+		conf_init_file(nfsidmap_conf_path);
+
 	server_in = conf_get_str(LDAP_SECTION, "LDAP_server");
 	ldap_info.base = conf_get_str(LDAP_SECTION, "LDAP_base");
 	ldap_info.people_tree = conf_get_str(LDAP_SECTION, "LDAP_people_base");
-- 
1.8.3.1



