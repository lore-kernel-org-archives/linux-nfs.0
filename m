Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47404 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754133AbcLTVlT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Dec 2016 16:41:19 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [libnfsidmap PATCH] libnfsidmap: add options to aid id mapping in multi domain environments
Date: Tue, 20 Dec 2016 16:41:18 -0500
Message-Id: <1482270078-60234-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This commit adds two options for the nsswitch plugin: No-Strip and
Reformat-Group.

In multi-domain environments, some NFS servers will append the
identity management domain to the owner and owner_group in lieu of a
true NFSv4 domain.  If No-Strip is set to a value other than "none",
the nsswitch plugin will first pass the name to the getpwnam_r() /
getgrnam_r() without stripping the domain off.  If that mapping fails
then the plugin will try again using the old method (comparing the
domain in the string to the Domain value, stripping it if it matches,
and passing the resulting short name to getpwnam_r() / getgrnam_r()).

The Reformat-Group option is used to work around a quirk in Winbind
whereby doing a group lookup in UPN format (e.g.
staff@americas.example.com) will cause the group to be displayed
prefixed with the full domain in uppercase (e.g.
AMERICAS.EXAMPLE.COM\staff) instead of in the familiar netbios
name format (e.g. AMERICAS\staff).  Setting this option to true
causes the name to be reformatted before passing it to getgrnam_r().

These options affect the behavior of of the name_to_uid, name_to_gid,
uid_to_name, and gid_to_name functions, so they work with both the
nfsidmap and rpc.idmapd programs.  These options do not change the
behavior of the princ_to_ids or gss_princ_to_grouplist functions.  Both
of those are used by rpc.svcgssd, which is deprecated in favor of
gssproxy (which does not call either of those functions).

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 idmapd.conf         |  23 +++++++
 idmapd.conf.5       |  24 +++++++
 libnfsidmap.c       |  24 +++++++
 nfsidmap_internal.h |   2 +
 nss.c               | 179 ++++++++++++++++++++++++++++++++++++++++++----------
 5 files changed, 217 insertions(+), 35 deletions(-)

diff --git a/idmapd.conf b/idmapd.conf
index ebf9754..f07286c 100644
--- a/idmapd.conf
+++ b/idmapd.conf
@@ -4,6 +4,29 @@
 # The default is the host's DNS domain name.
 #Domain = local.domain.edu
 
+# In multi-domain environments, some NFS servers will append the identity
+# management domain to the owner and owner_group in lieu of a true NFSv4
+# domain.  This option can facilitate lookups in such environments.  If
+# set to a value other than "none", the nsswitch  plugin will first pass
+# the name to the password/group lookup function without stripping the
+# domain off.  If that mapping fails then the plugin will try again using
+# the old method (comparing the domain in the string to the Domain value,
+# stripping it if it matches, and passing the resulting short name to the
+# lookup function).  Valid values are "user", "group", "both", and
+# "none".  The default is "none".
+#No-Strip = none
+
+# Winbind has a quirk whereby doing a group lookup in UPN format
+# (e.g. staff@americas.example.com) will cause the group to be
+# displayed prefixed with the full domain in uppercase
+# (e.g. AMERICAS.EXAMPLE.COM\staff) instead of in the familiar netbios
+# name format (e.g. AMERICAS\staff).  Setting this option to true
+# causes the name to be reformatted before passing it to the group
+# lookup function in order to work around this.  This setting is
+# ignored unless No-Strip is set to either "both" or "group".
+# The default is "false".
+#Reformat-Group = false
+
 # The following is a comma-separated list of Kerberos realm
 # names that should be considered to be equivalent to the
 # local realm, such that <user>@REALM.A can be assumed to
diff --git a/idmapd.conf.5 b/idmapd.conf.5
index de1bfa9..9a6457e 100644
--- a/idmapd.conf.5
+++ b/idmapd.conf.5
@@ -63,6 +63,30 @@ The local NFSv4 domain name.  An NFSv4 domain is a namespace with
 a unique username<->UID and groupname<->GID mapping.
 (Default: Host's fully-qualified DNS domain name)
 .TP
+.B No-Strip
+In multi-domain environments, some NFS servers will append the identity
+management domain to the owner and owner_group in lieu of a true NFSv4
+domain.  This option can facilitate lookups in such environments.  If
+set to a value other than "none", the nsswitch  plugin will first pass
+the name to the password/group lookup function without stripping the
+domain off.  If that mapping fails then the plugin will try again using
+the old method (comparing the domain in the string to the Domain value,
+stripping it if it matches, and passing the resulting short name to the
+lookup function).  Valid values are "user", "group", "both", and
+"none".
+(Default: "none")
+.TP
+.B Reformat-Group
+Winbind has a quirk whereby doing a group lookup in UPN format
+(e.g. staff@americas.example.com) will cause the group to be
+displayed prefixed with the full domain in uppercase
+(e.g. AMERICAS.EXAMPLE.COM\\staff) instead of in the familiar netbios
+name format (e.g. AMERICAS\\staff).  Setting this option to true
+causes the name to be reformatted before passing it to the group
+lookup function in order to work around this.  This setting is
+ignored unless No-Strip is set to either "both" or "group".
+(Default: "false")
+.TP
 .B Local-Realms
 A comma-separated list of Kerberos realm names that may be considered equivalent to the
 local realm name.  For example, users juser@ORDER.EDU and juser@MAIL.ORDER.EDU
diff --git a/libnfsidmap.c b/libnfsidmap.c
index 7b8c0ed..d484101 100644
--- a/libnfsidmap.c
+++ b/libnfsidmap.c
@@ -64,6 +64,8 @@
 static char *default_domain;
 static struct conf_list *local_realms;
 int idmap_verbosity = 0;
+int no_strip = 0;
+int reformat_group = 0;
 static struct mapping_plugin **nfs4_plugins = NULL;
 static struct mapping_plugin **gss_plugins = NULL;
 uid_t nobody_uid = (uid_t)-1;
@@ -336,6 +338,8 @@ int nfs4_init_name_mapping(char *conffile)
 	int dflt = 0;
 	struct conf_list *nfs4_methods, *gss_methods;
 	char *nobody_user, *nobody_group;
+	char *nostrip;
+	char *reformatgroup;
 
 	/* XXX: need to be able to reload configurations... */
 	if (nfs4_plugins) /* already succesfully initialized */
@@ -408,6 +412,26 @@ int nfs4_init_name_mapping(char *conffile)
 			IDMAP_LOG(1, ("libnfsidmap: Realms list: <NULL> "));
 	}
 
+	nostrip = conf_get_str_with_def("General", "No-Strip", "none");
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
+		reformatgroup = conf_get_str_with_def("General", "Reformat-Group", "false");
+		if ((strcasecmp(reformatgroup, "true") == 0) ||
+		    (strcasecmp(reformatgroup, "on") == 0) ||
+		    (strcasecmp(reformatgroup, "yes") == 0))
+			reformat_group = 1;
+		else
+			reformat_group = 0;
+	}
+
 	nfs4_methods = conf_get_list("Translation", "Method");
 	if (nfs4_methods) {
 		IDMAP_LOG(1, ("libnfsidmap: processing 'Method' list"));
diff --git a/nfsidmap_internal.h b/nfsidmap_internal.h
index e10fa66..6696f50 100644
--- a/nfsidmap_internal.h
+++ b/nfsidmap_internal.h
@@ -63,6 +63,8 @@ typedef enum {
 	IDTYPE_GROUP = 2
 } idtypes;
 
+extern int no_strip;
+extern int reformat_group;
 extern int idmap_verbosity;
 extern nfs4_idmap_log_function_t idmap_log_func;
 /* Level zero always prints, others print depending on verbosity level */
diff --git a/nss.c b/nss.c
index 0f12351..67e657a 100644
--- a/nss.c
+++ b/nss.c
@@ -45,6 +45,7 @@
 #include <err.h>
 #include <grp.h>
 #include <limits.h>
+#include <ctype.h>
 #include "nfsidmap.h"
 #include "nfsidmap_internal.h"
 #include "cfg.h"
@@ -58,14 +59,20 @@
  * and ignore the domain entirely when looking up a name.
  */
 
-static int write_name(char *dest, char *localname, char *domain, size_t len)
+static int write_name(char *dest, char *localname, char *domain, size_t len,
+		      int doappend)
 {
-	if (strlen(localname) + 1 + strlen(domain) + 1 > len) {
-		return -ENOMEM; /* XXX: Is there an -ETOOLONG? */
+	if (doappend || !strchr(localname,'@')) {
+		if (strlen(localname) + 1 + strlen(domain) + 1 > len)
+			return -ENOMEM; /* XXX: Is there an -ETOOLONG? */
+		strcpy(dest, localname);
+		strcat(dest, "@");
+		strcat(dest, domain);
+	} else {
+		if (strlen(localname) + 1 > len)
+			return -ENOMEM;
+		strcpy(dest, localname);
 	}
-	strcpy(dest, localname);
-	strcat(dest, "@");
-	strcat(dest, domain);
 	return 0;
 }
 
@@ -87,7 +94,10 @@ static int nss_uid_to_name(uid_t uid, char *domain, char *name, size_t len)
 		err = -ENOENT;
 	if (err)
 		goto out_buf;
-	err = write_name(name, pw->pw_name, domain, len);
+	if (no_strip & IDTYPE_USER)
+		err = write_name(name, pw->pw_name, domain, len, 0);
+	else
+		err = write_name(name, pw->pw_name, domain, len, 1);
 out_buf:
 	free(buf);
 out:
@@ -121,7 +131,10 @@ static int nss_gid_to_name(gid_t gid, char *domain, char *name, size_t len)
 
 	if (err)
 		goto out_buf;
-	err = write_name(name, gr->gr_name, domain, len);
+	if (no_strip & IDTYPE_GROUP)
+		err = write_name(name, gr->gr_name, domain, len, 0);
+	else
+		err = write_name(name, gr->gr_name, domain, len, 1);
 out_buf:
 	free(buf);
 out:
@@ -164,7 +177,8 @@ struct pwbuf {
 	char buf[1];
 };
 
-static struct passwd *nss_getpwnam(const char *name, const char *domain, int *err_p)
+static struct passwd *nss_getpwnam(const char *name, const char *domain,
+				   int *err_p, int dostrip)
 {
 	struct passwd *pw;
 	struct pwbuf *buf;
@@ -180,22 +194,29 @@ static struct passwd *nss_getpwnam(const char *name, const char *domain, int *er
 		goto err;
 
 	err = EINVAL;
-	localname = strip_domain(name, domain);
-	IDMAP_LOG(4, ("nss_getpwnam: name '%s' domain '%s': "
-		  "resulting localname '%s'", name, domain, localname));
-	if (localname == NULL) {
-		IDMAP_LOG(0, ("nss_getpwnam: name '%s' does not map "
-			"into domain '%s'", name,
-			domain ? domain : "<not-provided>"));
-		goto err_free_buf;
-	}
+	if (dostrip) {
+		localname = strip_domain(name, domain);
+		IDMAP_LOG(4, ("nss_getpwnam: name '%s' domain '%s': "
+			  "resulting localname '%s'", name, domain, localname));
+		if (localname == NULL) {
+			IDMAP_LOG(0, ("nss_getpwnam: name '%s' does not map "
+				"into domain '%s'", name,
+				domain ? domain : "<not-provided>"));
+			goto err_free_buf;
+		}
 
-	err = getpwnam_r(localname, &buf->pwbuf, buf->buf, buflen, &pw);
-	if (pw == NULL && domain != NULL)
-		IDMAP_LOG(0,
-			("nss_getpwnam: name '%s' not found in domain '%s'",
-			localname, domain));
-	free(localname);
+		err = getpwnam_r(localname, &buf->pwbuf, buf->buf, buflen, &pw);
+		if (pw == NULL && domain != NULL)
+			IDMAP_LOG(1,
+				("nss_getpwnam: name '%s' not found in domain '%s'",
+				localname, domain));
+		free(localname);
+	} else {
+		err = getpwnam_r(name, &buf->pwbuf, buf->buf, buflen, &pw);
+		if (pw == NULL)
+			IDMAP_LOG(1,
+				("nss_getpwnam: name '%s' not found (domain not stripped)", name));
+	}
 	if (err == 0 && pw != NULL) {
 		*err_p = 0;
 		return pw;
@@ -217,28 +238,83 @@ static int nss_name_to_uid(char *name, uid_t *uid)
 	int err = -ENOENT;
 
 	domain = get_default_domain();
-	pw = nss_getpwnam(name, domain, &err);
+	if (no_strip & IDTYPE_USER) {
+		pw = nss_getpwnam(name, domain, &err, 0);
+		if (pw != NULL)
+			goto out_uid;
+	}
+	pw = nss_getpwnam(name, domain, &err, 1);
 	if (pw == NULL)
 		goto out;
+out_uid:
 	*uid = pw->pw_uid;
+	IDMAP_LOG(4, ("nss_name_to_uid: name '%s' uid %u", name, *uid));
 	free(pw);
 	err = 0;
 out:
 	return err;
 }
 
-static int nss_name_to_gid(char *name, gid_t *gid)
+static char *reformat_name(const char *name)
+{
+	const char *domain;
+	const char *c;
+	const char *d;
+	char *l = NULL;
+	int len;
+	int dlen = 0;
+	int i;
+
+	c = strchr(name, '@');
+	if (c == NULL)
+		goto out;
+	len = c - name;
+	domain = ++c;
+	d = strchr(domain, '.');
+	if (d == NULL)
+		goto out;
+	dlen = d - domain;
+	l = malloc(dlen + 1 + len + 1);
+	if (l == NULL)
+		goto out;
+	for (i = 0; i < dlen; i++)
+		l[i] = toupper(domain[i]);
+	l[dlen] = '\\';
+	memcpy(l + dlen + 1, name, len);
+	l[dlen + 1 + len] = '\0';
+out:
+	return l;
+}
+
+static int _nss_name_to_gid(char *name, gid_t *gid, int dostrip)
 {
 	struct group *gr = NULL;
 	struct group grbuf;
-	char *buf, *localname, *domain;
+	char *buf, *domain;
 	size_t buflen = sysconf(_SC_GETGR_R_SIZE_MAX);
 	int err = -EINVAL;
+	char *localname = NULL;
+	char *ref_name = NULL;
 
 	domain = get_default_domain();
-	localname = strip_domain(name, domain);
-	if (!localname)
-		goto out;
+	if (dostrip) {
+		localname = strip_domain(name, domain);
+		IDMAP_LOG(4, ("nss_name_to_gid: name '%s' domain '%s': "
+			  "resulting localname '%s'", name, domain, localname));
+		if (!localname) {
+			IDMAP_LOG(0, ("nss_name_to_gid: name '%s' does not map "
+				  "into domain '%s'", name, domain));
+			goto out;
+		}
+	} else if (reformat_group) {
+		ref_name = reformat_name(name);
+		if (ref_name == NULL) {
+			IDMAP_LOG(1, ("nss_name_to_gid: failed to reformat name '%s'",
+				  name));
+			err = -ENOENT;
+			goto out;
+		}
+	}
 
 	err = -ENOMEM;
 	if (buflen > UINT_MAX)
@@ -248,9 +324,24 @@ static int nss_name_to_gid(char *name, gid_t *gid)
 		buf = malloc(buflen);
 		if (!buf)
 			goto out_name;
-		err = -getgrnam_r(localname, &grbuf, buf, buflen, &gr);
-		if (gr == NULL && !err)
+		if (dostrip)
+			err = -getgrnam_r(localname, &grbuf, buf, buflen, &gr);
+		else if (reformat_group)
+			err = -getgrnam_r(ref_name, &grbuf, buf, buflen, &gr);
+		else
+			err = -getgrnam_r(name, &grbuf, buf, buflen, &gr);
+		if (gr == NULL && !err) {
+			if (dostrip)
+				IDMAP_LOG(1, ("nss_name_to_gid: name '%s' not found "
+					  "in domain '%s'", localname, domain));
+			else if (reformat_group)
+				IDMAP_LOG(1, ("nss_name_to_gid: name '%s' not found "
+					  "(reformatted)", ref_name));
+			else
+				IDMAP_LOG(1, ("nss_name_to_gid: name '%s' not found "
+					  "(domain not stripped)", name));
 			err = -ENOENT;
+		}
 		if (err == -ERANGE) {
 			buflen *= 2;
 			free(buf);
@@ -260,10 +351,28 @@ static int nss_name_to_gid(char *name, gid_t *gid)
 	if (err)
 		goto out_buf;
 	*gid = gr->gr_gid;
+	IDMAP_LOG(4, ("nss_name_to_gid: name '%s' gid %u", name, *gid));
 out_buf:
 	free(buf);
 out_name:
-	free(localname);
+	if (dostrip)
+		free(localname);
+	if (reformat_group)
+		free(ref_name);
+out:
+	return err;
+}
+
+static int nss_name_to_gid(char *name, gid_t *gid)
+{
+	int err = 0;
+
+	if (no_strip & IDTYPE_GROUP) {
+		err = _nss_name_to_gid(name, gid, 0);
+		if (!err)
+			goto out;
+	}
+	err = _nss_name_to_gid(name, gid, 1);
 out:
 	return err;
 }
@@ -306,7 +415,7 @@ static int nss_gss_princ_to_ids(char *secname, char *princ,
 		return -ENOENT;
 	}
 	/* XXX: this should call something like getgssauthnam instead? */
-	pw = nss_getpwnam(princ, NULL, &err);
+	pw = nss_getpwnam(princ, NULL, &err, 0);
 	if (pw == NULL) {
 		err = -ENOENT;
 		goto out;
@@ -329,7 +438,7 @@ int nss_gss_princ_to_grouplist(char *secname, char *princ,
 		goto out;
 	/* XXX: not quite right?  Need to know default realm? */
 	/* XXX: this should call something like getgssauthnam instead? */
-	pw = nss_getpwnam(princ, NULL, &ret);
+	pw = nss_getpwnam(princ, NULL, &ret, 0);
 	if (pw == NULL) {
 		ret = -ENOENT;
 		goto out;
-- 
2.7.4

