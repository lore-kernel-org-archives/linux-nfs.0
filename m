Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:64166 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751217Ab2CORYS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Mar 2012 13:24:18 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q2FHOI91031800
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 15 Mar 2012 13:24:18 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q2FHOHft025715
	for <linux-nfs@vger.kernel.org>; Thu, 15 Mar 2012 13:24:17 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] nfsd: Warn when no servers are specified on the command line
Date: Thu, 15 Mar 2012 13:23:43 -0400
Message-Id: <1331832223-20737-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the number of servers are not specified
on the command, log a warning message that the
default number of services will be started

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsd/nfsd.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 8bc5d3a..c744ee1 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -188,6 +188,8 @@ main(int argc, char **argv)
 		}
 	}
 
+	xlog_open(progname);
+
 	if (optind < argc) {
 		if ((count = atoi(argv[optind])) < 0) {
 			/* insane # of servers */
@@ -203,10 +205,11 @@ main(int argc, char **argv)
 			socket_up = 1;
 			goto set_threads;
 		}
+	} else {
+		xlog(L_WARNING, "No server number specified. '%d' nfsd will be started",
+			count);
 	}
 
-	xlog_open(progname);
-
 	nfsd_enable_protos(&proto4, &proto6);
 
 	if (!NFSCTL_TCPISSET(protobits)) {
-- 
1.7.7.6

