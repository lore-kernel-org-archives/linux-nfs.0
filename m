Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49695 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753081AbcD2QN7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Apr 2016 12:13:59 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8DBE88E3D4
	for <linux-nfs@vger.kernel.org>; Fri, 29 Apr 2016 16:13:58 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2] exportfs: add the debug option
Date: Fri, 29 Apr 2016 12:13:57 -0400
Message-Id: <1461946437-2740-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since calling xlog(D_GENERAL) will cause exportfs to exit with a status
of 1, there really should be a way to see those messages for debugging
purposes.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/exportfs/exportfs.c   | 7 +++++--
 utils/exportfs/exportfs.man | 3 +++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index a9151ff..5db348b 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -108,11 +108,14 @@ main(int argc, char **argv)
 	xlog_stderr(1);
 	xlog_syslog(0);
 
-	while ((c = getopt(argc, argv, "afhio:ruvs")) != EOF) {
+	while ((c = getopt(argc, argv, "ad:fhio:ruvs")) != EOF) {
 		switch(c) {
 		case 'a':
 			f_all = 1;
 			break;
+		case 'd':
+			xlog_sconfig(optarg, 1);
+			break;
 		case 'f':
 			force_flush = 1;
 			break;
@@ -878,6 +881,6 @@ error(nfs_export *exp, int err)
 static void
 usage(const char *progname, int n)
 {
-	fprintf(stderr, "usage: %s [-afhioruvs] [host:/path]\n", progname);
+	fprintf(stderr, "usage: %s [-adfhioruvs] [host:/path]\n", progname);
 	exit(n);
 }
diff --git a/utils/exportfs/exportfs.man b/utils/exportfs/exportfs.man
index 75d952a..fdf9260 100644
--- a/utils/exportfs/exportfs.man
+++ b/utils/exportfs/exportfs.man
@@ -88,6 +88,9 @@ appropriate export entry for the host given in
 to be added to the kernel's export table.
 .SH OPTIONS
 .TP
+.B \-d kind " or " \-\-debug kind
+Turn on debugging. Valid kinds are: all, auth, call, general and parse.
+.TP
 .B -a
 Export or unexport all directories.
 .TP
-- 
2.4.11

