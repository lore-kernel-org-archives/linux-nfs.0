Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:45414 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755658Ab0KSRjH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Nov 2010 12:39:07 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1PJUvQ-0005fG-Lb
	for linux-nfs@vger.kernel.org; Fri, 19 Nov 2010 12:39:05 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] Add the new nfsidmap program
Date: Fri, 19 Nov 2010 12:39:02 -0500
Message-Id: <1290188343-10579-2-git-send-email-steved@redhat.com>
In-Reply-To: <1290188343-10579-1-git-send-email-steved@redhat.com>
References: <1290188343-10579-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Bryan Schumaker <bjschuma@netapp.com>

This patch adds the nfsidmap program to nfs-utils.  This program is
called by the nfs idmapper through request-keys to map between
uid / user name and gid / group name.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 aclocal/keyutils.m4         |   11 ++++
 configure.ac                |    4 ++
 utils/nfsidmap/Makefile.am  |    9 +++
 utils/nfsidmap/nfsidmap.c   |  118 +++++++++++++++++++++++++++++++++++++++++++
 utils/nfsidmap/nfsidmap.man |   60 ++++++++++++++++++++++
 5 files changed, 202 insertions(+), 0 deletions(-)
 create mode 100644 aclocal/keyutils.m4
 create mode 100644 utils/nfsidmap/Makefile.am
 create mode 100644 utils/nfsidmap/nfsidmap.c
 create mode 100644 utils/nfsidmap/nfsidmap.man

diff --git a/aclocal/keyutils.m4 b/aclocal/keyutils.m4
new file mode 100644
index 0000000..84bc112
--- /dev/null
+++ b/aclocal/keyutils.m4
@@ -0,0 +1,11 @@
+dnl Checks for keyutils library and headers
+dnl
+AC_DEFUN([AC_KEYUTILS], [
+
+  dnl Check for libkeyutils; do not add to LIBS if found
+  AC_CHECK_LIB([keyutils], [keyctl_instantiate], [LIBKEYUTILS=-lkeyutils], ,)
+  AC_SUBST(LIBKEYUTILS)
+
+  AC_CHECK_HEADERS([keyutils.h], ,
+  		   [AC_MSG_ERROR([keyutils.h header not found.])])
+])dnl
diff --git a/configure.ac b/configure.ac
index 5408e85..b39dbcd 100644
--- a/configure.ac
+++ b/configure.ac
@@ -247,6 +247,9 @@ if test "$enable_nfsv4" = yes; then
   dnl check for nfsidmap libraries and headers
   AC_LIBNFSIDMAP
 
+  dnl check for the keyutils libraries and headers
+  AC_KEYUTILS
+
   dnl librpcsecgss already has a dependency on libgssapi,
   dnl but we need to make sure we get the right version
   if test "$enable_gss" = yes; then
@@ -435,6 +438,7 @@ AC_CONFIG_FILES([
 	utils/mountd/Makefile
 	utils/nfsd/Makefile
 	utils/nfsstat/Makefile
+	utils/nfsidmap/Makefile
 	utils/showmount/Makefile
 	utils/statd/Makefile
 	tests/Makefile
diff --git a/utils/nfsidmap/Makefile.am b/utils/nfsidmap/Makefile.am
new file mode 100644
index 0000000..f837b91
--- /dev/null
+++ b/utils/nfsidmap/Makefile.am
@@ -0,0 +1,9 @@
+## Process this file with automake to produce Makefile.in
+
+man8_MANS = nfsidmap.man
+
+sbin_PROGRAMS	= nfsidmap
+nfsidmap_SOURCES = nfsidmap.c
+nfsidmap_LDADD = -lnfsidmap -lkeyutils
+
+MAINTAINERCLEANFILES = Makefile.in
diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
new file mode 100644
index 0000000..2d87381
--- /dev/null
+++ b/utils/nfsidmap/nfsidmap.c
@@ -0,0 +1,118 @@
+
+#include <stdarg.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+
+#include <pwd.h>
+#include <grp.h>
+#include <keyutils.h>
+#include <nfsidmap.h>
+
+#include <syslog.h>
+
+/* gcc nfsidmap.c -o nfsidmap -l nfsidmap -l keyutils */
+
+#define MAX_ID_LEN   11
+#define IDMAP_NAMESZ 128
+#define USER  1
+#define GROUP 0
+
+
+/*
+ * Find either a user or group id based on the name@domain string
+ */
+int id_lookup(char *name_at_domain, key_serial_t key, int type)
+{
+	char id[MAX_ID_LEN];
+	uid_t uid = 0;
+	gid_t gid = 0;
+	int rc;
+
+	if (type == USER) {
+		rc = nfs4_owner_to_uid(name_at_domain, &uid);
+		sprintf(id, "%u", uid);
+	} else {
+		rc = nfs4_group_owner_to_gid(name_at_domain, &gid);
+		sprintf(id, "%u", gid);
+	}
+
+	if (rc == 0)
+		rc = keyctl_instantiate(key, id, strlen(id) + 1, 0);
+
+	return rc;
+}
+
+/*
+ * Find the name@domain string from either a user or group id
+ */
+int name_lookup(char *id, key_serial_t key, int type)
+{
+	char name[IDMAP_NAMESZ];
+	char domain[NFS4_MAX_DOMAIN_LEN];
+	uid_t uid;
+	gid_t gid;
+	int rc;
+
+	rc = nfs4_get_default_domain(NULL, domain, NFS4_MAX_DOMAIN_LEN);
+	if (rc != 0) {
+		rc = -1;
+		goto out;
+	}
+
+	if (type == USER) {
+		uid = atoi(id);
+		rc = nfs4_uid_to_name(uid, domain, name, IDMAP_NAMESZ);
+	} else {
+		gid = atoi(id);
+		rc = nfs4_gid_to_name(gid, domain, name, IDMAP_NAMESZ);
+	}
+
+	if (rc == 0)
+		rc = keyctl_instantiate(key, &name, strlen(name), 0);
+
+out:
+	return rc;
+}
+
+int main(int argc, char **argv)
+{
+	char *arg;
+	char *value;
+	char *type;
+	int rc = 1;
+	int timeout = 600;
+	key_serial_t key;
+
+	if (argc < 3)
+		return 1;
+
+	arg = malloc(sizeof(char) * strlen(argv[2]) + 1);
+	strcpy(arg, argv[2]);
+	type = strtok(arg, ":");
+	value = strtok(NULL, ":");
+
+	if (argc == 4) {
+		timeout = atoi(argv[3]);
+		if (timeout < 0)
+			timeout = 0;
+	}
+
+	key = strtol(argv[1], NULL, 10);
+
+	if (strcmp(type, "uid") == 0)
+		rc = id_lookup(value, key, USER);
+	else if (strcmp(type, "gid") == 0)
+		rc = id_lookup(value, key, GROUP);
+	else if (strcmp(type, "user") == 0)
+		rc = name_lookup(value, key, USER);
+	else if (strcmp(type, "group") == 0)
+		rc = name_lookup(value, key, GROUP);
+
+	/* Set timeout to 5 (600 seconds) minutes */
+	if (rc == 0)
+		keyctl_set_timeout(key, timeout);
+
+	free(arg);
+	return rc;
+}
diff --git a/utils/nfsidmap/nfsidmap.man b/utils/nfsidmap/nfsidmap.man
new file mode 100644
index 0000000..6c1a2d4
--- /dev/null
+++ b/utils/nfsidmap/nfsidmap.man
@@ -0,0 +1,60 @@
+.\"
+.\"@(#)nfsidmap(8) - The NFS idmapper upcall program
+.\"
+.\" Copyright (C) 2010 Bryan Schumaker <bjschuma@netapp.com>
+.TH nfsidmap 5 "1 October 2010"
+.SH NAME
+nfsidmap \- The NFS idmapper upcall program
+.SH DESCRIPTION
+The file
+.I /usr/sbin/nfsidmap
+is used by the NFS idmapper to translate user and group ids into names, and to
+translate user and group names into ids. Idmapper uses request-key to perform
+the upcall and cache the result.
+.I /usr/sbin/nfsidmap
+should only be called by request-key, and will perform the translation and
+initialize a key with the resulting information.
+.PP
+NFS_USE_NEW_IDMAPPER must be selected when configuring the kernel to use this
+feature.
+.SH CONFIGURING
+The file
+.I /etc/request-key.conf
+will need to be modified so
+.I /sbin/request-key
+can properly direct the upcall. The following line should be added before a call
+to keyctl negate:
+.PP
+create	nfs_idmap	*	*	/usr/sbin/nfsidmap %k %d 600
+.PP
+This will direct all nfs_idmap requests to the program
+.I /usr/sbin/nfsidmap
+The last parameter, 600, defines how many seconds into the future the key will
+expire.  This is an optional parameter for
+.I /usr/sbin/nfsidmap
+and will default to 600 seconds when not specified.
+.PP
+The idmapper system uses four key descriptions:
+.PP
+	  uid: Find the UID for the given user
+.br
+	  gid: Find the GID for the given group
+.br
+	 user: Find the user name for the given UID
+.br
+	group: Find the group name for the given GID
+.PP
+You can choose to handle any of these individually, rather than using the
+generic upcall program.  If you would like to use your own program for a uid
+lookup then you would edit your request-key.conf so it looks similar to this:
+.PP
+create	nfs_idmap	uid:*	*	/some/other/program %k %d 600
+.br
+create	nfs_idmap	*		*	/usr/sbin/nfsidmap %k %d 600
+.PP
+Notice that the new line was added above the line for the generic program.
+request-key will find the first matching line and run the corresponding program.
+In this case, /some/other/program will handle all uid lookups, and
+/usr/sbin/nfsidmap will handle gid, user, and group lookups.
+.SH AUTHOR
+Bryan Schumaker, <bjschuma@netapp.com>
-- 
1.7.3.2

