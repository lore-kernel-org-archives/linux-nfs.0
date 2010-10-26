From: Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH] nfs-utils: add nfs.idmap
Date: Tue, 26 Oct 2010 08:48:48 -0400
Message-ID: <4CC6CE30.90105@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: SteveD@redhat.com, "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47558 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932079Ab0JZMst (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Oct 2010 08:48:49 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This patch adds the nfs.idmap program to nfs-utils.  This program is called by
the nfs idmapper through request-keys to map between uid / user name and
gid / group name.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
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
index 3058be6..0907f72 100644
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
+	utils/nfs.idmap/Makefile
 	utils/showmount/Makefile
 	utils/statd/Makefile
 	tests/Makefile
diff --git a/utils/Makefile.am b/utils/Makefile.am
index 8665183..332ecff 100644
--- a/utils/Makefile.am
+++ b/utils/Makefile.am
@@ -4,6 +4,7 @@ OPTDIRS =
 
 if CONFIG_NFSV4
 OPTDIRS += idmapd
+OPTDIRS += nfs.idmap
 endif
 
 if CONFIG_GSS
diff --git a/utils/nfs.idmap/Makefile.am b/utils/nfs.idmap/Makefile.am
new file mode 100644
index 0000000..29e17af
--- /dev/null
+++ b/utils/nfs.idmap/Makefile.am
@@ -0,0 +1,9 @@
+## Process this file with automake to produce Makefile.in
+
+man8_MANS = nfs.idmap.man
+
+sbin_PROGRAMS	= nfs.idmap
+nfs_idmap_SOURCES = nfs.idmap.c
+nfs_idmap_LDADD = -lnfsidmap -lkeyutils
+
+MAINTAINERCLEANFILES = Makefile.in
diff --git a/utils/nfs.idmap/nfs.idmap.c b/utils/nfs.idmap/nfs.idmap.c
new file mode 100644
index 0000000..abbcb65
--- /dev/null
+++ b/utils/nfs.idmap/nfs.idmap.c
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
+/* gcc nfs.idmap.c -o nfs.idmap -l nfsidmap -l keyutils */
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
diff --git a/utils/nfs.idmap/nfs.idmap.man b/utils/nfs.idmap/nfs.idmap.man
new file mode 100644
index 0000000..9008dd9
--- /dev/null
+++ b/utils/nfs.idmap/nfs.idmap.man
@@ -0,0 +1,60 @@
+.\"
+.\"@(#)nfs.idmap(8) - The NFS idmapper upcall program
+.\"
+.\" Copyright (C) 2010 Bryan Schumaker <bjschuma@netapp.com>
+.TH nfs.idmap 5 "1 October 2010"
+.SH NAME
+nfs.idmap \- The NFS idmapper upcall program
+.SH DESCRIPTION
+The file
+.I /usr/sbin/nfs.idmap
+is used by the NFS idmapper to translate user and group ids into names, and to
+translate user and group names into ids. Idmapper uses request-key to perform
+the upcall and cache the result.
+.I /usr/sbin/nfs.idmap
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
+create	nfs_idmap	*	*	/usr/sbin/nfs.idmap %k %d 600
+.PP
+This will direct all nfs_idmap requests to the program
+.I /usr/sbin/nfs.idmap
+The last parameter, 600, defines how many seconds into the future the key will
+expire.  This is an optional parameter for
+.I /usr/sbin/nfs.idmap
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
+create	nfs_idmap	*		*	/usr/sbin/nfs.idmap %k %d 600
+.PP
+Notice that the new line was added above the line for the generic program.
+request-key will find the first matching line and run the corresponding program.
+In this case, /some/other/program will handle all uid lookups, and
+/usr/sbin/nfs.idmap will handle gid, user, and group lookups.
+.SH AUTHOR
+Bryan Schumaker, <bjschuma@netapp.com>
