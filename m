Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:43290 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752908Ab1FROCF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Jun 2011 10:02:05 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc Devel List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] Do not skip records with nonblocking connections (take 2)
Date: Sat, 18 Jun 2011 10:01:46 -0400
Message-Id: <1308405706-3467-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

With non-blocking connections, do not skip records when receiving
the streams since entire value messages can be ignored which
in cause the entire stream to become out of sync.

For example, two mounts simultaneously send two unmaps
commands. The first one is read, then the second thrown
away due to skipping the record. Skipping this record
will cause XDR error later in processing of the stream.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/svc_vc.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/src/svc_vc.c b/src/svc_vc.c
index aaaf2d7..87406f1 100644
--- a/src/svc_vc.c
+++ b/src/svc_vc.c
@@ -610,7 +610,11 @@ svc_vc_recv(xprt, msg)
 	}
 
 	xdrs->x_op = XDR_DECODE;
-	(void)xdrrec_skiprecord(xdrs);
+	/*
+	 * No need skip records with nonblocking connections
+	 */
+	if (cd->nonblock == FALSE)
+		(void)xdrrec_skiprecord(xdrs);
 	if (xdr_callmsg(xdrs, msg)) {
 		cd->x_id = msg->rm_xid;
 		return (TRUE);
-- 
1.7.4.4

