Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6671 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751548AbdIMOG6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Sep 2017 10:06:58 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 62B47C0587F2
        for <linux-nfs@vger.kernel.org>; Wed, 13 Sep 2017 14:06:58 +0000 (UTC)
Message-ID: <1505311607.15819.30.camel@redhat.com>
Subject: [PATCH 7/7] nfs-utils: cleanup warnings from merged libnfsidmap code
From: Justin Mitchell <jumitche@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        Bruce Fields <bfields@redhat.com>
Date: Wed, 13 Sep 2017 15:06:47 +0100
In-Reply-To: <1505311126.15819.20.camel@redhat.com>
References: <1505311126.15819.20.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up a bunch of warnings about unused parameters,
signedness differences, etc that we inherited from
the merged libnfsidmap code.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 utils/libnfsidmap/libnfsidmap.c       | 10 ++++++----
 utils/libnfsidmap/nfsidmap_internal.h |  7 +++++++
 utils/libnfsidmap/nss.c               |  6 +++---
 utils/libnfsidmap/static.c            | 20 +++++++++++---------
 utils/libnfsidmap/umich_ldap.c        | 11 ++++++-----
 5 files changed, 33 insertions(+), 21 deletions(-)

diff --git a/utils/libnfsidmap/libnfsidmap.c b/utils/libnfsidmap/libnfsidmap.c
index aa368b7..c8b53ff 100644
--- a/utils/libnfsidmap/libnfsidmap.c
+++ b/utils/libnfsidmap/libnfsidmap.c
@@ -103,7 +103,7 @@ nfs4_idmap_log_function_t idmap_log_func = default_logger;
 
 static char * toupper_str(char *s)
 {
-	int i;
+	size_t i;
 	for (i=0; i < strlen(s); i++)
 		s[i] = toupper(s[i]);
 	return s;
@@ -128,7 +128,8 @@ static int id_as_chars(char *name, uid_t *id)
 static int dns_txt_query(char *domain, char **nfs4domain)
 {
 	char *txtname = NFS4DNSTXTREC;
-	char *msg, *answ, *eom, *mptr; 
+	unsigned char *msg, *eom, *mptr; 
+	char *answ;
 	int len, status = -1;
 	HEADER *hdr;
 	
@@ -323,7 +324,8 @@ out:
 		unload_plugins(plgns);
 	return ret;
 }
-void nfs4_cleanup_name_mapping()
+
+void nfs4_cleanup_name_mapping(void)
 {
 	if (nfs4_plugins)
 		unload_plugins(nfs4_plugins);
@@ -534,7 +536,7 @@ struct conf_list *get_local_realms(void)
 }
 
 int
-nfs4_get_default_domain(char *server, char *domain, size_t len)
+nfs4_get_default_domain(char *UNUSED(server), char *domain, size_t len)
 {
 	char *d = get_default_domain();
 
diff --git a/utils/libnfsidmap/nfsidmap_internal.h b/utils/libnfsidmap/nfsidmap_internal.h
index 6696f50..a327862 100644
--- a/utils/libnfsidmap/nfsidmap_internal.h
+++ b/utils/libnfsidmap/nfsidmap_internal.h
@@ -70,3 +70,10 @@ extern nfs4_idmap_log_function_t idmap_log_func;
 /* Level zero always prints, others print depending on verbosity level */
 #define IDMAP_LOG(LVL, MSG) \
 	do { if (LVL <= idmap_verbosity) (*idmap_log_func)MSG; } while (0)
+
+#ifdef __GNUC__
+#define UNUSED(foo) UNUSED_ ## foo __attribute__((__unused__))
+#else
+#define UNUSED(foo) UNUSED_ ## foo
+#endif
+
diff --git a/utils/libnfsidmap/nss.c b/utils/libnfsidmap/nss.c
index 48215ff..a86d768 100644
--- a/utils/libnfsidmap/nss.c
+++ b/utils/libnfsidmap/nss.c
@@ -379,7 +379,7 @@ out:
 
 static int nss_gss_princ_to_ids(char *secname, char *princ,
 				uid_t *uid, uid_t *gid,
-				extra_mapping_params **ex)
+				extra_mapping_params **UNUSED(ex))
 {
 	struct passwd *pw;
 	int err = 0;
@@ -429,7 +429,7 @@ out:
 
 int nss_gss_princ_to_grouplist(char *secname, char *princ,
 			       gid_t *groups, int *ngroups,
-			       extra_mapping_params **ex)
+			       extra_mapping_params **UNUSED(ex))
 {
 	struct passwd *pw;
 	int ret = -EINVAL;
@@ -462,7 +462,7 @@ struct trans_func nss_trans = {
 	.gss_princ_to_grouplist = nss_gss_princ_to_grouplist,
 };
 
-struct trans_func *libnfsidmap_plugin_init()
+struct trans_func *libnfsidmap_plugin_init(void)
 {
 	return (&nss_trans);
 }
diff --git a/utils/libnfsidmap/static.c b/utils/libnfsidmap/static.c
index 37b293b..488010d 100644
--- a/utils/libnfsidmap/static.c
+++ b/utils/libnfsidmap/static.c
@@ -92,7 +92,8 @@ static __inline__ u_int8_t gid_hash (gid_t gid)
 LIST_HEAD (uid_mappings, uid_mapping) uid_mappings[256];
 LIST_HEAD (gid_mappings, gid_mapping) gid_mappings[256];
 
-static struct passwd *static_getpwnam(const char *name, const char *domain,
+static struct passwd *static_getpwnam(const char *name, 
+				      const char *UNUSED(domain),
 				      int *err_p)
 {
 	struct passwd *pw;
@@ -142,8 +143,9 @@ err:
 	return NULL;
 }
 
-static struct group *static_getgrnam(const char *name, const char *domain,
-				      int *err_p)
+static struct group *static_getgrnam(const char *name, 
+				     const char *UNUSED(domain),
+				     int *err_p)
 {
 	struct group *gr;
 	struct grbuf *buf;
@@ -194,7 +196,7 @@ err:
 
 static int static_gss_princ_to_ids(char *secname, char *princ,
 				   uid_t *uid, uid_t *gid,
-				   extra_mapping_params **ex)
+				   extra_mapping_params **UNUSED(ex))
 {
 	struct passwd *pw;
 	int err;
@@ -216,7 +218,7 @@ static int static_gss_princ_to_ids(char *secname, char *princ,
 
 static int static_gss_princ_to_grouplist(char *secname, char *princ,
 					 gid_t *groups, int *ngroups,
-					 extra_mapping_params **ex)
+					 extra_mapping_params **UNUSED(ex))
 {
 	struct passwd *pw;
 	int err;
@@ -266,7 +268,7 @@ static int static_name_to_gid(char *name, gid_t *gid)
 	return -err;
 }
 
-static int static_uid_to_name(uid_t uid, char *domain, char *name, size_t len)
+static int static_uid_to_name(uid_t uid, char *UNUSED(domain), char *name, size_t UNUSED(len))
 {
 	struct uid_mapping * um;
 
@@ -281,7 +283,7 @@ static int static_uid_to_name(uid_t uid, char *domain, char *name, size_t len)
 	return -ENOENT;
 }
 
-static int static_gid_to_name(gid_t gid, char *domain, char *name, size_t len)
+static int static_gid_to_name(gid_t gid, char *UNUSED(domain), char *name, size_t UNUSED(len))
 {
 	struct gid_mapping * gm;
 
@@ -301,7 +303,7 @@ static int static_gid_to_name(gid_t gid, char *domain, char *name, size_t len)
  * uid_to_name functions will be fast enough.
  */
 
-static int static_init() {	
+static int static_init(void) {	
 	int err;
 	struct conf_list * princ_list = NULL;
 	struct conf_list_node * cln, *next;
@@ -404,7 +406,7 @@ struct trans_func static_trans = {
 	.gss_princ_to_grouplist	= static_gss_princ_to_grouplist,
 };
 
-struct trans_func *libnfsidmap_plugin_init()
+struct trans_func *libnfsidmap_plugin_init(void)
 {
 	return (&static_trans);
 }
diff --git a/utils/libnfsidmap/umich_ldap.c b/utils/libnfsidmap/umich_ldap.c
index 664f282..736f40f 100644
--- a/utils/libnfsidmap/umich_ldap.c
+++ b/utils/libnfsidmap/umich_ldap.c
@@ -970,7 +970,8 @@ out:
  */
 static int
 umichldap_gss_princ_to_ids(char *secname, char *principal,
-			   uid_t *uid, gid_t *gid, extra_mapping_params **ex)
+			   uid_t *uid, gid_t *gid, 
+			   extra_mapping_params **UNUSED(ex))
 {
 	uid_t rtnd_uid = -1;
 	gid_t rtnd_gid = -1;
@@ -1012,20 +1013,20 @@ umichldap_name_to_gid(char *name, gid_t *gid)
 }
 
 static int
-umichldap_uid_to_name(uid_t uid, char *domain, char *name, size_t len)
+umichldap_uid_to_name(uid_t uid, char *UNUSED(domain), char *name, size_t len)
 {
 	return umich_id_to_name(uid, IDTYPE_USER, &name, len, &ldap_info);
 }
 
 static int
-umichldap_gid_to_name(gid_t gid, char *domain, char *name, size_t len)
+umichldap_gid_to_name(gid_t gid, char *UNUSED(domain), char *name, size_t len)
 {
 	return umich_id_to_name(gid, IDTYPE_GROUP, &name, len, &ldap_info);
 }
 
 static int
 umichldap_gss_princ_to_grouplist(char *secname, char *principal,
-		gid_t *groups, int *ngroups, extra_mapping_params **ex)
+		gid_t *groups, int *ngroups, extra_mapping_params **UNUSED(ex))
 {
 	int err = -EINVAL;
 
@@ -1296,7 +1297,7 @@ struct trans_func umichldap_trans = {
 	.gss_princ_to_grouplist = umichldap_gss_princ_to_grouplist,
 };
 
-struct trans_func *libnfsidmap_plugin_init()
+struct trans_func *libnfsidmap_plugin_init(void)
 {
 	return (&umichldap_trans);
 }
-- 
1.8.3.1



