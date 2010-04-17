From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd4: consistent session flag setting
Date: Fri, 16 Apr 2010 21:47:12 -0400
Message-ID: <20100417014712.GA5697@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60770 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754540Ab0DQBrN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 21:47:13 -0400
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1O2x7o-0001UI-QU
	for linux-nfs@vger.kernel.org; Fri, 16 Apr 2010 21:47:12 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We should clear these flags on any new create_session, not just on the
first one.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0b44bf6..dabc6a3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1308,12 +1308,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		cs_slot->sl_seqid++; /* from 0 to 1 */
 		move_to_confirmed(unconf);
 
-		/*
-		 * We do not support RDMA or persistent sessions
-		 */
-		cr_ses->flags &= ~SESSION4_PERSIST;
-		cr_ses->flags &= ~SESSION4_RDMA;
-
 		if (cr_ses->flags & SESSION4_BACK_CHAN) {
 			unconf->cl_cb_conn.cb_xprt = rqstp->rq_xprt;
 			unconf->cl_xpt_user.callback = nfsd4_backchannel_lost;
@@ -1334,6 +1328,12 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		goto out;
 	}
 
+	/*
+	 * We do not support RDMA or persistent sessions
+	 */
+	cr_ses->flags &= ~SESSION4_PERSIST;
+	cr_ses->flags &= ~SESSION4_RDMA;
+
 	status = alloc_init_session(rqstp, conf, cr_ses);
 	if (status)
 		goto out;
