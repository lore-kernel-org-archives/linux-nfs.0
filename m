Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54598 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751300AbdH3L7V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 30 Aug 2017 07:59:21 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id DC312495
        for <linux-nfs@vger.kernel.org>; Wed, 30 Aug 2017 11:59:20 +0000 (UTC)
Message-ID: <1504094358.10850.11.camel@redhat.com>
Subject: [PATCH 7/7] libnfsidmap: use conf_get_bool()
From: Justin Mitchell <jumitche@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 30 Aug 2017 12:59:18 +0100
In-Reply-To: <1504093866.10850.1.camel@redhat.com>
References: <1504093866.10850.1.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We can improve code readability by using conf_get_bool() from
libnfsconf instead of comparing the string values ourselves

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 libnfsidmap.c |  6 +-----
 umich_ldap.c  | 21 ++++++---------------
 2 files changed, 7 insertions(+), 20 deletions(-)

diff --git a/libnfsidmap.c b/libnfsidmap.c
index afe84ef..bacb0e3 100644
--- a/libnfsidmap.c
+++ b/libnfsidmap.c
@@ -339,7 +339,6 @@ int nfs4_init_name_mapping(char *conffile)
 	struct conf_list *nfs4_methods, *gss_methods;
 	char *nobody_user, *nobody_group;
 	char *nostrip;
-	char *reformatgroup;
 	char *conf_path;
 
 	/* XXX: need to be able to reload configurations... */
@@ -424,10 +423,7 @@ int nfs4_init_name_mapping(char *conffile)
 		no_strip = 0;
 
 	if (no_strip & IDTYPE_GROUP) {
-		reformatgroup = conf_get_str_with_def("General", "Reformat-Group", "false");
-		if ((strcasecmp(reformatgroup, "true") == 0) ||
-		    (strcasecmp(reformatgroup, "on") == 0) ||
-		    (strcasecmp(reformatgroup, "yes") == 0))
+		if (conf_get_bool("General", "Reformat-Group", false))
 			reformat_group = 1;
 		else
 			reformat_group = 0;
diff --git a/umich_ldap.c b/umich_ldap.c
index 6e01cc3..6ddce32 100644
--- a/umich_ldap.c
+++ b/umich_ldap.c
@@ -1095,9 +1095,9 @@ out_err:
 static int
 umichldap_init(void)
 {
-	char *tssl, *canonicalize, *memberof;
 	char missing_msg[128] = "";
 	char *server_in, *canon_name;
+	bool canonicalize = false;
 
 	server_in = conf_get_str(LDAP_SECTION, "LDAP_server");
 	ldap_info.base = conf_get_str(LDAP_SECTION, "LDAP_base");
@@ -1105,10 +1105,7 @@ umichldap_init(void)
 	ldap_info.group_tree = conf_get_str(LDAP_SECTION, "LDAP_group_base");
 	ldap_info.user_dn = conf_get_str(LDAP_SECTION, "LDAP_user_dn");
 	ldap_info.passwd = conf_get_str(LDAP_SECTION, "LDAP_passwd");
-	tssl = conf_get_str_with_def(LDAP_SECTION, "LDAP_use_ssl", "false");
-	if ((strcasecmp(tssl, "true") == 0) ||
-	    (strcasecmp(tssl, "on") == 0) ||
-	    (strcasecmp(tssl, "yes") == 0))
+	if (conf_get_bool(LDAP_SECTION, "LDAP_use_ssl", false))
 		ldap_info.use_ssl = 1;
 	else
 		ldap_info.use_ssl = 0;
@@ -1130,10 +1127,8 @@ umichldap_init(void)
 	}
 
 	ldap_info.server = server_in;
-	canonicalize = conf_get_str_with_def(LDAP_SECTION, "LDAP_canonicalize_name", "yes");
-	if ((strcasecmp(canonicalize, "true") == 0) ||
-	    (strcasecmp(canonicalize, "on") == 0) ||
-	    (strcasecmp(canonicalize, "yes") == 0)) {
+	if (conf_get_bool(LDAP_SECTION, "LDAP_canonicalize_name", true)) {
+		canonicalize = true;
 		canon_name = get_canonical_hostname(server_in);
 		if (canon_name == NULL)
 			IDMAP_LOG(0, ("umichldap_init: Warning! Unable to "
@@ -1202,11 +1197,7 @@ umichldap_init(void)
 	 * will use the memberof lists of the account and search through
 	 * only those groups to obtain gids.
 	 */
-	memberof = conf_get_str_with_def(LDAP_SECTION,
-				"LDAP_use_memberof_for_groups", "false");
-        if ((strcasecmp(memberof, "true") == 0) ||
-            (strcasecmp(memberof, "on") == 0) ||
-            (strcasecmp(memberof, "yes") == 0))
+	if (conf_get_bool(LDAP_SECTION, "LDAP_use_memberof_for_groups", false))
                 ldap_info.memberof_for_groups = 1;
         else
                 ldap_info.memberof_for_groups = 0;
@@ -1233,7 +1224,7 @@ umichldap_init(void)
 
 	/* print out some good debugging info */
 	IDMAP_LOG(1, ("umichldap_init: canonicalize_name: %s",
-		  canonicalize));
+		  canonicalize ? "yes" : "no"));
 	IDMAP_LOG(1, ("umichldap_init: server  : %s (from config value '%s')",
 		  ldap_info.server, server_in));
 	IDMAP_LOG(1, ("umichldap_init: port    : %d", ldap_info.port));
-- 
1.8.3.1



