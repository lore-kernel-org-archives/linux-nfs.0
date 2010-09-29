Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42635 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755658Ab0I2Tl5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Sep 2010 15:41:57 -0400
Message-ID: <4CA39682.5050401@netapp.com>
Date: Wed, 29 Sep 2010 15:41:54 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, SteveD@redhat.com
Subject: [PATCH] libnfsidmap: add numerical string translation
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Add numerical string translation

nfs4_owner_to_gid and nfs4_owner_to_uid will call their respective
nfs4_name_to_*id functions first.  If the name could not be resolved, we
check if the string is a numerical representation of an id number.  If it is,
we convert the string to an id number.  If not, we map the user to "nobody"

If we are unable to find a mapping for a uid or gid, we convert the
id into a numeric string to send to the server.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
diff --git a/libnfsidmap.c b/libnfsidmap.c
index 41a6dc8..faea763 100644
--- a/libnfsidmap.c
+++ b/libnfsidmap.c
@@ -42,6 +42,7 @@
 #include <stdlib.h>
 #include <stdio.h>
 #include <string.h>
+#include <ctype.h>
 #include <pwd.h>
 #include <grp.h>
 #include <netdb.h>
@@ -92,6 +93,16 @@ static char * toupper_str(char *s)
 	return s;
 }
 
+static int id_as_chars(char *name, int *id)
+{
+	char *end_ptr;
+	long int value = strtol(name, &end_ptr, 10);
+	if (end_ptr == name || *end_ptr != '\0')
+		return 0;
+	*id = (int)value;
+	return 1;
+}
+
 static int domain_from_dns(char **domain)
 {
 	struct hostent *he;
@@ -386,6 +397,20 @@ int nfs4_gid_to_name(gid_t gid, char *domain, char *name, size_t len)
 	RUN_TRANSLATIONS(gid_to_name, 0, gid, domain, name, len);
 }
 
+int nfs4_uid_to_owner(uid_t uid, char *domain, char *name, size_t len)
+{
+	if (nfs4_uid_to_name(uid, domain, name, len))
+		sprintf(name, "%u", uid);
+	return 0;
+}
+
+int nfs4_gid_to_group_owner(gid_t gid, char *domain, char *name, size_t len)
+{
+	if (nfs4_gid_to_name(gid, domain, name, len))
+		sprintf(name, "%u", gid);
+	return 0;
+}
+
 int nfs4_name_to_uid(char *name, uid_t *uid)
 {
 	RUN_TRANSLATIONS(name_to_uid, 0, name, uid);
@@ -396,6 +421,46 @@ int nfs4_name_to_gid(char *name, gid_t *gid)
 	RUN_TRANSLATIONS(name_to_gid, 0, name, gid);
 }
 
+static int set_id_to_nobody(int *id, int is_uid)
+{
+	int rc = 0;
+	const char name[] = "nobody@";
+	char nobody[strlen(name) + strlen(get_default_domain()) + 1];
+	strcpy(nobody, name);
+	strcat(nobody, get_default_domain());
+
+	if (is_uid)
+		rc = nfs4_name_to_uid(nobody, id);
+	else
+		rc = nfs4_name_to_gid(nobody, id);
+
+	if (rc) {
+		*id = -2;
+		rc = 0;
+	}
+	return rc;
+}
+
+int nfs4_owner_to_uid(char *name, uid_t *uid)
+{
+	int rc = nfs4_name_to_uid(name, uid);
+	if (rc && id_as_chars(name, uid))
+		rc = 0;
+	else if (rc)
+		rc = set_id_to_nobody(uid, 1);
+	return rc;
+}
+
+int nfs4_group_owner_to_gid(char *name, gid_t *gid)
+{
+	int rc = nfs4_name_to_gid(name, gid);
+	if (rc && id_as_chars(name, gid))
+		rc = 0;
+	else if (rc)
+		rc = set_id_to_nobody(gid, 0);
+	return rc;
+}
+
 int nfs4_gss_princ_to_ids(char *secname, char *princ, uid_t *uid, gid_t *gid)
 {
 	RUN_TRANSLATIONS(princ_to_ids, 1, secname, princ, uid, gid, NULL);
diff --git a/nfsidmap.h b/nfsidmap.h
index ee54c47..eee40af 100644
--- a/nfsidmap.h
+++ b/nfsidmap.h
@@ -53,8 +53,12 @@ int nfs4_init_name_mapping(char *conffile);
 int nfs4_get_default_domain(char *server, char *domain, size_t len);
 int nfs4_uid_to_name(uid_t uid, char *domain, char *name, size_t len);
 int nfs4_gid_to_name(gid_t gid, char *domain, char *name, size_t len);
+int nfs4_uid_to_owner(uid_t uid, char *domain, char *name, size_t len);
+int nfs4_gid_to_group_owner(gid_t gid, char *domain, char *name, size_t len);
 int nfs4_name_to_uid(char *name, uid_t *uid);
 int nfs4_name_to_gid(char *name, gid_t *gid);
+int nfs4_owner_to_uid(char *name, uid_t *uid);
+int nfs4_owner_to_gid(char *name, gid_t *gid);
 int nfs4_gss_princ_to_ids(char *secname, char *princ, uid_t *uid, gid_t *gid);
 int nfs4_gss_princ_to_grouplist(char *secname, char *princ, gid_t *groups, int *ngroups);
 int nfs4_gss_princ_to_ids_ex(char *secname, char *princ, uid_t *uid, gid_t *gid, extra_mapping_params **ex);
