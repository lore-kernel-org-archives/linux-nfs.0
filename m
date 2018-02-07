Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:55146 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754327AbeBGVa6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Feb 2018 16:30:58 -0500
From: Kenneth Dsouza <kdsouza@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: bfields@fieldses.org
Subject: [PATCH] Add support for -R option in nfs4_getfacl so we can list the ACLs of all files and directories recursively.
Date: Thu,  8 Feb 2018 03:00:55 +0530
Message-Id: <20180207213055.18211-1-kdsouza@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Kenneth D'souza <kdsouza@redhat.com>
---
 libnfs4acl/nfs4_acl_for_path.c |  4 ++--
 man/man1/nfs4_getfacl.1        | 10 ++++++++--
 nfs4_getfacl/nfs4_getfacl.c    | 41 ++++++++++++++++++++++++++++++++---------
 3 files changed, 42 insertions(+), 13 deletions(-)

diff --git a/libnfs4acl/nfs4_acl_for_path.c b/libnfs4acl/nfs4_acl_for_path.c
index 7461005..a51dc34 100644
--- a/libnfs4acl/nfs4_acl_for_path.c
+++ b/libnfs4acl/nfs4_acl_for_path.c
@@ -95,11 +95,11 @@ static int nfs4_getxattr(const char *path, void *value, size_t size)
 		fprintf(stderr,"An internal NFS server error code (%d) was returned; this should never happen.\n",res);
 	} else if (res < 0) {
 		if (errno == ENOATTR)
-			fprintf(stderr,"Attribute not found on file.\n");
+			fprintf(stderr,"Attribute not found on file: %s\n", path);
 		else if (errno == EREMOTEIO)
 		    fprintf(stderr,"An NFS server error occurred.\n");
 		else if (errno == EOPNOTSUPP)
-			fprintf(stderr,"Operation to request attribute not supported.\n");
+			fprintf(stderr,"Operation to request attribute not supported: %s\n", path);
 		else
 			perror("Failed getxattr operation");
 	}
diff --git a/man/man1/nfs4_getfacl.1 b/man/man1/nfs4_getfacl.1
index 81c542d..f85d50e 100644
--- a/man/man1/nfs4_getfacl.1
+++ b/man/man1/nfs4_getfacl.1
@@ -8,7 +8,7 @@
 .SH NAME
 nfs4_getfacl \- get NFSv4 file/directory access control lists
 .SH SYNOPSIS
-.B nfs4_getfacl [-H]
+.B nfs4_getfacl [-HR]
 file ...
 .SH DESCRIPTION
 .B nfs4_getfacl 
@@ -18,9 +18,15 @@ support ACLs.
 
 If the 
 .BR -H / --more-help
+flag is specified,
+.B nfs4_getfacl
+will print some information about NFSv4 ACLs and the fields used in ACEs.
+
+If the
+.BR -R / --recursive
 flag is specified, 
 .B nfs4_getfacl
-will print some information about NFSv4 ACLs and the fields used in ACEs.  
+will list the NFSv4 ACLs of all files and directories recursively.
 
 The output format for an NFSv4 file ACL, e.g., is:
 .RS
diff --git a/nfs4_getfacl/nfs4_getfacl.c b/nfs4_getfacl/nfs4_getfacl.c
index 610fe16..1705d35 100644
--- a/nfs4_getfacl/nfs4_getfacl.c
+++ b/nfs4_getfacl/nfs4_getfacl.c
@@ -39,14 +39,21 @@
 #include <sys/types.h>
 #include <libgen.h>
 #include "libacl_nfs4.h"
+#include <ftw.h>
 
 static void usage(int);
 static void more_help();
 static char *execname;
+static void print_acl_from_path();
+
+static int recursive(const char *fpath, const struct stat *sb, int tflag, struct FTW *ftwbuf)
+{
+	print_acl_from_path(fpath);
+	return 0;
+}
 
 int main(int argc, char **argv)
 {
-	struct nfs4_acl *acl;
 	int res = 1;
 	int counter = 1;
 	
@@ -64,25 +71,41 @@ int main(int argc, char **argv)
 		more_help();
 		res = 0;
 		goto out;
+	} else if (!strcmp(argv[1], "-R") || !strcmp(argv[1], "--recursive")) {
+		if (argc < 3)
+			usage(1);
+		for(counter = 2; counter < argc; counter++) {
+			if (nftw(argv[counter], recursive, 20, 0) == -1) {
+				printf("Invalid filename: %s\n", argv[counter]);
+			}
+		}
+		res = 0;
+		goto out;
 	}
 	for (counter = 1; counter < argc; counter++) {
-		acl = nfs4_acl_for_path(argv[counter]);
-		if (acl != NULL) {
-			printf("\n# file: %s\n",argv[counter]);
-			nfs4_print_acl(stdout, acl);
-			nfs4_free_acl(acl);
-			res = 0;
-               }
+		print_acl_from_path(argv[counter]);
+		res = 0;
 	}
 out:
 	return res;
 }
 
+static void print_acl_from_path(const char *fpath)
+{
+	struct nfs4_acl *acl;
+	acl = nfs4_acl_for_path(fpath);
+	if (acl != NULL) {
+		printf("\n# file: %s\n", fpath);
+		nfs4_print_acl(stdout, acl);
+		nfs4_free_acl(acl);
+	}
+}
+
 static void usage(int label)
 {
 	if (label)
 		fprintf(stderr, "%s %s -- get NFSv4 file or directory access control lists.\n", execname, VERSION);
-	fprintf(stderr, "Usage: %s file\n  -H, --more-help\tdisplay ACL format information\n  -?, -h, --help\tdisplay this help text\n", execname);
+	fprintf(stderr, "Usage: %s file\n  -H, --more-help\tdisplay ACL format information\n  -?, -h, --help\tdisplay this help text\n  -R --recursive\trecurse into subdirectories\n", execname);
 }
 
 static void more_help()
-- 
2.9.5

