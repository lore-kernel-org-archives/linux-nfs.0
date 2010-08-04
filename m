From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 02/24] Removed warnings from rpcdispatch.c
Date: Wed,  4 Aug 2010 11:11:58 -0400
Message-ID: <1280934740-11366-3-git-send-email-steved@redhat.com>
References: <1280934740-11366-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:54504 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752855Ab0HDPMZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 11:12:25 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1Ogfdm-0002SZ-0n
	for linux-nfs@vger.kernel.org; Wed, 04 Aug 2010 11:12:22 -0400
In-Reply-To: <1280934740-11366-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpcdispatch.c: In function 'rpc_dispatch':
rpcdispatch.c:30: warning: comparison between signed and unsigned
     integer expressions
rpcdispatch.c:35: warning: comparison between signed and unsigned
     integer expressions

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/nfs/rpcdispatch.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/support/nfs/rpcdispatch.c b/support/nfs/rpcdispatch.c
index 502fc5f..984c646 100644
--- a/support/nfs/rpcdispatch.c
+++ b/support/nfs/rpcdispatch.c
@@ -27,12 +27,12 @@ rpc_dispatch(struct svc_req *rqstp, SVCXPRT *transp,
 {
 	struct rpc_dentry	*dent;
 
-	if (rqstp->rq_vers > nvers) {
+	if (((int)rqstp->rq_vers) > nvers) {
 		svcerr_progvers(transp, 1, nvers);
 		return;
 	}
 	dtable += (rqstp->rq_vers - 1);
-	if (rqstp->rq_proc > dtable->nproc) {
+	if (((int)rqstp->rq_proc) > dtable->nproc) {
 		svcerr_noproc(transp);
 		return;
 	}
-- 
1.7.2

