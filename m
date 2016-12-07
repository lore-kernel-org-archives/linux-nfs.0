Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57382 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752323AbcLGQg4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 11:36:56 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 729DF7AEAB
        for <linux-nfs@vger.kernel.org>; Wed,  7 Dec 2016 16:36:56 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [libnfsidmap RFC PATCH] libnfsidmap: add support for multiple domains
Date: Wed,  7 Dec 2016 11:36:26 -0500
Message-Id: <1481128586-53009-2-git-send-email-smayhew@redhat.com>
In-Reply-To: <1481128586-53009-1-git-send-email-smayhew@redhat.com>
References: <1481128586-53009-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 Makefile.am   |   5 +-
 idmapd.conf   |  26 +++-
 idmapd.conf.5 |  40 ++++++-
 multidom.c    | 379 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 445 insertions(+), 5 deletions(-)
 create mode 100644 multidom.c

diff --git a/Makefile.am b/Makefile.am
index 85f19c8..62a1d1e 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -11,7 +11,7 @@ else
 GUMS_MAPPING_LIB =
 endif
 lib_LTLIBRARIES = libnfsidmap.la
-pkglib_LTLIBRARIES = nsswitch.la static.la $(UMICH_LDAP_LIB) $(GUMS_MAPPING_LIB)
+pkglib_LTLIBRARIES = nsswitch.la static.la multidom.la $(UMICH_LDAP_LIB) $(GUMS_MAPPING_LIB)
 
 # Library versioning notes from:
 #  http://sources.redhat.com/autobook/autobook/autobook_91.html
@@ -35,6 +35,9 @@ nsswitch_la_LDFLAGS = -module -avoid-version
 static_la_SOURCES = static.c
 static_la_LDFLAGS = -module -avoid-version
 
+multidom_la_SOURCES = multidom.c
+multidom_la_LDFLAGS = -module -avoid-version
+
 umich_ldap_la_SOURCES = umich_ldap.c
 umich_ldap_la_LDFLAGS = -module -avoid-version
 umich_ldap_la_LIBADD = -lldap
diff --git a/idmapd.conf b/idmapd.conf
index ebf9754..0517d40 100644
--- a/idmapd.conf
+++ b/idmapd.conf
@@ -24,8 +24,8 @@
 
 # Translation Method is an comma-separated, ordered list of
 # translation methods that can be used.  Distributed methods
-# include "nsswitch", "umich_ldap", and "static".  Each method
-# is a dynamically loadable plugin library.
+# include "nsswitch", "multidom", "umich_ldap", and "static".  Each
+# method is a dynamically loadable plugin library.
 # New methods may be defined and inserted in the list.
 # The default is "nsswitch".
 #Method = nsswitch
@@ -36,6 +36,28 @@
 # If this option is omitted, the same methods as those
 # specified in "Method" are used.
 #GSS-Methods = <alternate method list for translating GSS names>
+
+#-------------------------------------------------------------------#
+# The following are used only for the "multidom" Translation Method.
+#-------------------------------------------------------------------#
+[Multi-Domain]
+# The "multidom" plugin does not strip the domain off the name before
+# passing it to the password/group lookup function.  Instead it
+# compares the domain to this list.  If the domain does not match a
+# domain in the list, then the name is mapped to the Nobody-User or
+# Nobody-Group.  If the domain does match a domain in the list, then
+# the name is passed to the password/group lookup function as-is.
+#Domain-List = americas.example.com,emea.example.com,apac,example.com
+
+# Winbind has a "quirk" whereby doing a group lookup in UPN format
+# (e.g. staff@americas.example.com) will cause the group to be
+# displayed prefixed with the full domain in uppercase
+# (e.g. AMERICAS.EXAMPLE.COM\staff) instead of in the familiar netbios
+# name format (e.g. AMERICAS\staff).  Setting this option to true
+# causes the name to be reformatted before passing it to the group
+# lookup function in order to work around this "quirk".
+# The default is "false".
+#Reformat-Group-For-Winbind-Query = false
  
 #-------------------------------------------------------------------#
 # The following are used only for the "static" Translation Method.
diff --git a/idmapd.conf.5 b/idmapd.conf.5
index de1bfa9..74cc683 100644
--- a/idmapd.conf.5
+++ b/idmapd.conf.5
@@ -102,8 +102,8 @@ A comma-separated, ordered list of mapping methods (plug-ins)
 to use when mapping between NFSv4 names and local IDs.  Each
 specified method is tried in order until a mapping is found,
 or there are no more methods to try.  The methods included in
-the default distribution include "nsswitch", "umich_ldap", and
-"static".
+the default distribution include "nsswitch", "multidom",
+"umich_ldap", and "static".
 (Default: nsswitch)
 .TP
 .B GSS-Methods
@@ -113,6 +113,42 @@ to use when mapping between GSS Authenticated names and local IDs.
 .B Method)
 .\"
 .\" -------------------------------------------------------------------
+.\" The [Multi-Domain] section
+.\" -------------------------------------------------------------------
+.\"
+.SS "[Multi-Domain] section variables"
+.nf
+
+.fi
+If the "multidom" translation method is specified, the following
+variables within the [Multi-Domain] section are used.
+.TP
+.B Domain-List
+A comma-separated list of domains in which to attempt to map users
+and groups.  In multi-domain environments, some NFS servers will send
+append the owner and group_owner attributes with the identity
+management domain in lieu of a true NFSv4 domain.  To accomodate
+lookups in those environments, the "multidom" plugin does not strip
+the domain off the name before passing it to the password/group lookup
+function.  Instead it compares the domain to this list.  If the domain
+does not match a domain in the list, then the name is mapped to the
+Nobody-User or Nobody-Group.  If the domain does match a domain in the
+list, then the name is passed to the password/group lookup function as-is.
+
+.fi
+.TP
+.B Reformat-Group-For-Winbind-Query
+Winbind has a "quirk" whereby doing a group lookup in UPN format
+(e.g. staff@americas.example.com) will cause the group to be
+displayed prefixed with the full domain in uppercase
+(e.g. AMERICAS.EXAMPLE.COM\\staff) instead of in the familiar netbios
+name format (e.g. AMERICAS\\staff).  Setting this option to true
+causes the name to be reformatted before passing it to the group
+lookup function in order to work around this "quirk".
+(Default: false)
+
+.\"
+.\" -------------------------------------------------------------------
 .\" The [Static] section
 .\" -------------------------------------------------------------------
 .\"
diff --git a/multidom.c b/multidom.c
new file mode 100644
index 0000000..c67b992
--- /dev/null
+++ b/multidom.c
@@ -0,0 +1,379 @@
+/*
+ *  multidom.c
+ *
+ *  multi-domain idmapping functions.
+ *
+ *  Copyright (c) 2004 The Regents of the University of Michigan.
+ *  Copyright (c) 2016 Red Hat, Inc.
+ *  All rights reserved.
+ *
+ *  Scott Mayhew <smayhew@redhat.com>
+ *
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the University nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <sys/types.h>
+#include <errno.h>
+#include <unistd.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <pwd.h>
+#include <grp.h>
+#include <netdb.h>
+#include <err.h>
+#include <grp.h>
+#include <limits.h>
+#include "nfsidmap.h"
+#include "nfsidmap_internal.h"
+#include "cfg.h"
+#include <syslog.h>
+
+static struct conf_list *domain_list;
+static int winbind_quirk = 0;
+
+static int write_name(char *dest, char *localname, size_t len)
+{
+	if (strlen(localname) + 1 > len) {
+		return -ENOMEM;
+	}
+	strcpy(dest, localname);
+	return 0;
+}
+
+static struct conf_list *get_domain_list(void)
+{
+	return domain_list;
+}
+
+static int check_domain_list(const char *name)
+{
+	struct conf_list *dom_list;
+	struct conf_list_node *d;
+	int found = 0;
+	char *dom;
+
+	dom = strstr(name, "@");
+	if (dom != NULL) {
+		dom++;
+	} else {
+		IDMAP_LOG(1, ("check_domain_list: name '%s' does not contain a domain",
+				name));
+		goto out;
+	}
+	dom_list = get_domain_list();
+	TAILQ_FOREACH(d, &dom_list->fields, link) {
+		if (strcmp(d->field, dom) == 0) {
+			found = 1;
+			break;
+		}
+	}
+	if (!found)
+		IDMAP_LOG(1, ("check_domain_list: Domain '%s': not found in domain list",
+				dom));
+out:
+	return found;
+}
+
+static int multidom_uid_to_name(uid_t uid, char *domain, char *name, size_t len)
+{
+	struct passwd *pw = NULL;
+	struct passwd pwbuf;
+	char *buf;
+	size_t buflen = sysconf(_SC_GETPW_R_SIZE_MAX);
+	int err = -ENOMEM;
+
+	buf = malloc(buflen);
+	if (!buf)
+		goto out;
+	err = -getpwuid_r(uid, &pwbuf, buf, buflen, &pw);
+	if (pw == NULL)
+		err = -ENOENT;
+	if (err)
+		goto out_buf;
+	if (!check_domain_list(pw->pw_name)) {
+		err = -ENOENT;
+		goto out_buf;
+	}
+	err = write_name(name, pw->pw_name, len);
+out_buf:
+	free(buf);
+out:
+	return err;
+}
+
+static int multidom_gid_to_name(gid_t gid, char *domain, char *name, size_t len)
+{
+	struct group *gr = NULL;
+	struct group grbuf;
+	char *buf;
+	size_t buflen = sysconf(_SC_GETGR_R_SIZE_MAX);
+	int err;
+
+	do {
+		err = -ENOMEM;
+		buf = malloc(buflen);
+		if (!buf)
+			goto out;
+		err = -getgrgid_r(gid, &grbuf, buf, buflen, &gr);
+		if (gr == NULL && !err)
+			err = -ENOENT;
+		if (err == -ERANGE) {
+			buflen *= 2;
+			free(buf);
+		}
+	} while (err == -ERANGE);
+
+	if (err)
+		goto out_buf;
+	if (!check_domain_list(gr->gr_name)) {
+		err = -ENOENT;
+		goto out_buf;
+	}
+	err = write_name(name, gr->gr_name, len);
+out_buf:
+	free(buf);
+out:
+	return err;
+}
+
+struct pwbuf {
+	struct passwd pwbuf;
+	char buf[1];
+};
+
+static struct passwd *multidom_getpwnam(const char *name, int *err_p)
+{
+	struct passwd *pw;
+	struct pwbuf *buf;
+	size_t buflen = sysconf(_SC_GETPW_R_SIZE_MAX);
+	int err = ENOMEM;
+	int found = 0;
+
+	if (buflen > UINT_MAX)
+		goto err;
+
+	buf = malloc(sizeof(*buf) + buflen);
+	if (buf == NULL)
+		goto err;
+
+	found = check_domain_list(name);
+	if (!found) {
+		err = -ENOENT;
+		goto err_free_buf;
+	}
+
+	err = getpwnam_r(name, &buf->pwbuf, buf->buf, buflen, &pw);
+	if (pw == NULL)
+		IDMAP_LOG(2,
+			("multidom_getpwnam: name '%s' not found", name));
+	if (err == 0 && pw != NULL) {
+		*err_p = 0;
+		return pw;
+	} else if (err == 0 && pw == NULL) {
+		err = ENOENT;
+	}
+
+err_free_buf:
+	free(buf);
+err:
+	*err_p = -err;
+	return NULL;
+}
+
+static int multidom_name_to_uid(char *name, uid_t *uid)
+{
+	struct passwd *pw = NULL;
+	int err = -ENOENT;
+
+	pw = multidom_getpwnam(name, &err);
+	if (pw == NULL)
+		goto out;
+	*uid = pw->pw_uid;
+	IDMAP_LOG(4, ("multidom_name_to_uid: name '%s' uid %u", name, *uid));
+	free(pw);
+	err = 0;
+out:
+	return err;
+}
+
+static char *multidom_reformat_name(const char *name)
+{
+	const char *domain;
+	const char *c;
+	const char *d;
+	char *l = NULL;
+	int len;
+	int dlen = 0;
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
+	memcpy(l, domain, dlen);
+	l[dlen] = '\\';
+	memcpy(l + dlen + 1, name, len);
+	l[dlen + 1 + len] = '\0';
+out:
+	return l;
+}
+
+static int multidom_name_to_gid(char *name, gid_t *gid)
+{
+	struct group *gr = NULL;
+	struct group grbuf;
+	char *buf;
+	size_t buflen = sysconf(_SC_GETGR_R_SIZE_MAX);
+	int err = -EINVAL;
+	int found = 0;
+	char *ref_name = NULL;
+
+	found = check_domain_list(name);
+	if (!found) {
+		err = -ENOENT;
+		goto out;
+	}
+
+	if (winbind_quirk) {
+		ref_name = multidom_reformat_name(name);
+		if (ref_name == NULL) {
+			IDMAP_LOG(2, ("multidom_name_to_gid: failed to reformat name '%s'",
+					name));
+			err = -ENOENT;
+			goto out;
+		}
+	}
+	err = -ENOMEM;
+	if (buflen > UINT_MAX)
+		goto out_ref_name;
+
+	do {
+		buf = malloc(buflen);
+		if (!buf)
+			goto out_ref_name;
+		if (winbind_quirk)
+			err = -getgrnam_r(ref_name, &grbuf, buf, buflen, &gr);
+		else
+			err = -getgrnam_r(name, &grbuf, buf, buflen, &gr);
+		if (gr == NULL && !err)
+			err = -ENOENT;
+		if (err == -ERANGE) {
+			buflen *= 2;
+			free(buf);
+		}
+	} while (err == -ERANGE);
+
+	if (err)
+		goto out_buf;
+	*gid = gr->gr_gid;
+	IDMAP_LOG(4, ("multidom_name_to_gid: name '%s' gid %u", name, *gid));
+out_buf:
+	free(buf);
+out_ref_name:
+	if (winbind_quirk)
+		free(ref_name);
+out:
+	return err;
+}
+
+static int multidom_gss_princ_to_ids(char *secname, char *princ,
+				uid_t *uid, uid_t *gid,
+				extra_mapping_params **ex)
+{
+	IDMAP_LOG(4, ("%s: not implemented", __func__));
+	return -ENOENT;
+}
+
+int multidom_gss_princ_to_grouplist(char *secname, char *princ,
+			       gid_t *groups, int *ngroups,
+			       extra_mapping_params **ex)
+{
+	IDMAP_LOG(4, ("%s: not implemented", __func__));
+	return -ENOENT;
+}
+
+static int multidom_init(void)
+{
+	char *reformat_group;
+
+	domain_list = conf_get_list("Multi-Domain", "Domain-List");
+	if (domain_list == NULL) {
+		IDMAP_LOG(1, ("multidom_init: domain list: <NULL> "));
+		return -1;
+	}
+
+	if (idmap_verbosity >= 1) {
+		struct conf_list_node *r;
+		char *buf = NULL;
+		int siz=0;
+
+		TAILQ_FOREACH(r, &domain_list->fields, link) {
+			siz += (strlen(r->field)+4);
+		}
+		buf = malloc(siz);
+		if (buf) {
+			*buf = 0;
+			TAILQ_FOREACH(r, &domain_list->fields, link) {
+				sprintf(buf+strlen(buf), "'%s' ", r->field);
+			}
+			IDMAP_LOG(1, ("multidom_init: domain list: %s", buf));
+			free(buf);
+		}
+	}
+	reformat_group = conf_get_str_with_def("Multi-Domain", "Reformat-Group-For-Winbind-Query", "false");
+	if ((strcasecmp(reformat_group, "true") == 0) ||
+	    (strcasecmp(reformat_group, "on") == 0) ||
+	    (strcasecmp(reformat_group, "yes") == 0))
+		winbind_quirk = 1;
+	else
+		winbind_quirk = 0;
+
+	return 0;
+}
+
+struct trans_func multidom_trans = {
+	.name		= "multidom",
+	.init		= multidom_init,
+	.princ_to_ids	= multidom_gss_princ_to_ids,
+	.name_to_uid	= multidom_name_to_uid,
+	.name_to_gid	= multidom_name_to_gid,
+	.uid_to_name	= multidom_uid_to_name,
+	.gid_to_name	= multidom_gid_to_name,
+	.gss_princ_to_grouplist = multidom_gss_princ_to_grouplist,
+};
+
+struct trans_func *libnfsidmap_plugin_init()
+{
+	return (&multidom_trans);
+}
-- 
2.7.4

