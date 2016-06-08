Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47144 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1424116AbcFHNDQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jun 2016 09:03:16 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F144A12B25
	for <linux-nfs@vger.kernel.org>; Wed,  8 Jun 2016 13:03:10 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (vpn-49-78.rdu2.redhat.com [10.10.49.78])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u58D3APO032512
	for <linux-nfs@vger.kernel.org>; Wed, 8 Jun 2016 09:03:10 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsidmap: added the -h option
Date: Wed,  8 Jun 2016 09:03:09 -0400
Message-Id: <1465390989-10097-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsidmap/nfsidmap.c   | 7 +++++--
 utils/nfsidmap/nfsidmap.man | 5 +++++
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 2abefe9..6e946ec 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -17,7 +17,7 @@
 #include "conffile.h"
 
 int verbose = 0;
-char *usage = "Usage: %s [-v] [-c || [-u|-g|-r key] || -d || -l || [-t timeout] key desc]";
+char *usage = "Usage: %s [-vh] [-c || [-u|-g|-r key] || -d || -l || [-t timeout] key desc]";
 
 #define MAX_ID_LEN   11
 #define IDMAP_NAMESZ 128
@@ -369,7 +369,7 @@ int main(int argc, char **argv)
 
 	xlog_open(progname);
 
-	while ((opt = getopt(argc, argv, "du:g:r:ct:vl")) != -1) {
+	while ((opt = getopt(argc, argv, "hdu:g:r:ct:vl")) != -1) {
 		switch (opt) {
 		case 'd':
 			display++;
@@ -398,8 +398,11 @@ int main(int argc, char **argv)
 		case 't':
 			timeout = atoi(optarg);
 			break;
+		case 'h':
 		default:
 			xlog_warn(usage, progname);
+			if (opt == 'h')
+				exit(0);
 			break;
 		}
 	}
diff --git a/utils/nfsidmap/nfsidmap.man b/utils/nfsidmap/nfsidmap.man
index 0275bdf..2f17cf2 100644
--- a/utils/nfsidmap/nfsidmap.man
+++ b/utils/nfsidmap/nfsidmap.man
@@ -15,6 +15,8 @@ nfsidmap \- The NFS idmapper upcall program
 .B "nfsidmap -d"
 .br
 .B "nfsidmap -l"
+.br
+.B "nfsidmap -h"
 .SH DESCRIPTION
 The NFSv4 protocol represents the local system's UID and GID values
 on the wire as strings of the form
@@ -71,6 +73,9 @@ Display the system's effective NFSv4 domain name on
 .B -g user
 Revoke the gid key of the given user.
 .TP
+.B -h
+Display usage message.
+.TP
 .B -l
 Display on
 .I stdout
-- 
2.5.5

