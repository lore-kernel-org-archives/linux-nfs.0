Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:12416 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754410Ab3JBRTu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Oct 2013 13:19:50 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r92HJokA004735
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 2 Oct 2013 13:19:50 -0400
Received: from tasleson.csb (vpn-239-58.phx2.redhat.com [10.3.239.58])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r92HJnVQ005776
	for <linux-nfs@vger.kernel.org>; Wed, 2 Oct 2013 13:19:49 -0400
From: Tony Asleson <tasleson@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] exportfs: Add -s option.
Date: Wed,  2 Oct 2013 12:19:49 -0500
Message-Id: <1380734389-8202-1-git-send-email-tasleson@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adds '-s' option which outputs the current exports in a format
suitable for /etc/exports.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 utils/exportfs/exportfs.c   | 23 ++++++++++++++---------
 utils/exportfs/exportfs.man |  5 ++++-
 2 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 4331697..52fc03d 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -38,7 +38,7 @@ static void	export_all(int verbose);
 static void	exportfs(char *arg, char *options, int verbose);
 static void	unexportfs(char *arg, int verbose);
 static void	exports_update(int verbose);
-static void	dump(int verbose);
+static void	dump(int verbose, int export_format);
 static void	error(nfs_export *exp, int err);
 static void	usage(const char *progname, int n);
 static void	validate_export(nfs_export *exp);
@@ -88,6 +88,7 @@ main(int argc, char **argv)
 	int	f_export = 1;
 	int	f_all = 0;
 	int	f_verbose = 0;
+	int	f_export_format = 0;
 	int	f_reexport = 0;
 	int	f_ignore = 0;
 	int	i, c;
@@ -105,7 +106,7 @@ main(int argc, char **argv)
 
 	export_errno = 0;
 
-	while ((c = getopt(argc, argv, "afhio:ruv")) != EOF) {
+	while ((c = getopt(argc, argv, "afhio:ruvs")) != EOF) {
 		switch(c) {
 		case 'a':
 			f_all = 1;
@@ -132,6 +133,9 @@ main(int argc, char **argv)
 		case 'v':
 			f_verbose = 1;
 			break;
+		case 's':
+			f_export_format = 1;
+			break;
 		default:
 			usage(progname, 1);
 			break;
@@ -164,7 +168,7 @@ main(int argc, char **argv)
 			return 0;
 		} else {
 			xtab_export_read();
-			dump(f_verbose);
+			dump(f_verbose, f_export_format);
 			return 0;
 		}
 	}
@@ -634,7 +638,7 @@ dumpopt(char c, char *fmt, ...)
 }
 
 static void
-dump(int verbose)
+dump(int verbose, int export_format)
 {
 	nfs_export	*exp;
 	struct exportent *ep;
@@ -647,14 +651,15 @@ dump(int verbose)
 			if (!exp->m_xtabent)
 			    continue; /* neilb */
 			if (htype == MCL_ANONYMOUS)
-				hname = "<world>";
+				hname = (export_format) ? "*" : "<world>";
 			else
 				hname = ep->e_hostname;
-			if (strlen(ep->e_path) > 14)
+			if (strlen(ep->e_path) > 14 && !export_format)
 				printf("%-14s\n\t\t%s", ep->e_path, hname);
 			else
-				printf("%-14s\t%s", ep->e_path, hname);
-			if (!verbose) {
+				printf(((export_format)? "%s %s" : "%-14s\t%s"), ep->e_path, hname);
+
+			if (!verbose && !export_format) {
 				printf("\n");
 				continue;
 			}
@@ -728,6 +733,6 @@ error(nfs_export *exp, int err)
 static void
 usage(const char *progname, int n)
 {
-	fprintf(stderr, "usage: %s [-afhioruv] [host:/path]\n", progname);
+	fprintf(stderr, "usage: %s [-afhioruvs] [host:/path]\n", progname);
 	exit(n);
 }
diff --git a/utils/exportfs/exportfs.man b/utils/exportfs/exportfs.man
index 8853486..590f9cf 100644
--- a/utils/exportfs/exportfs.man
+++ b/utils/exportfs/exportfs.man
@@ -3,7 +3,7 @@
 .\" Copyright (C) 1995 Olaf Kirch <okir@monad.swb.de>
 .\" Modifications 1999-2003 Neil Brown <neilb@cse.unsw.edu.au>
 .\"
-.TH exportfs 8 "31 December 2009"
+.TH exportfs 8 "30 September 2013"
 .SH NAME
 exportfs \- maintain table of exported NFS file systems
 .SH SYNOPSIS
@@ -133,6 +133,9 @@ when they make their next NFS mount request.
 Be verbose. When exporting or unexporting, show what's going on. When
 displaying the current export list, also display the list of export
 options.
+.TP
+.B -s
+Display the current export list suitable for /etc/exports.
 .SH DISCUSSION
 .SS Exporting Directories
 The first synopsis shows how to invoke
-- 
1.8.2.1

