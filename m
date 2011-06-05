Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:48628 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753211Ab1FEPoA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Jun 2011 11:44:00 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc Devel List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] Do not skip records with nonblocking connections
Date: Sun,  5 Jun 2011 11:43:58 -0400
Message-Id: <1307288638-32215-1-git-send-email-steved@redhat.com>
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
 src/svc_vc.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/src/svc_vc.c b/src/svc_vc.c
index aaaf2d7..15dac18 100644
--- a/src/svc_vc.c
+++ b/src/svc_vc.c
@@ -610,6 +610,11 @@ svc_vc_recv(xprt, msg)
 	}
 
 	xdrs->x_op = XDR_DECODE;
+	/*
+	 * No need skip records with nonblocking connections
+	 */
+	if (cd->nonblock == FALSE)
+		(void)xdrrec_skiprecord(xdrs);
 	(void)xdrrec_skiprecord(xdrs);
 	if (xdr_callmsg(xdrs, msg)) {
 		cd->x_id = msg->rm_xid;
-- 
1.7.4.4

