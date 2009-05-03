From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd4: track recall retries in nfs4_delegation
Date: Sun,  3 May 2009 14:16:38 -0400
Message-ID: <1241374599-20348-13-git-send-email-bfields@fieldses.org>
References: <1241374599-20348-1-git-send-email-bfields@fieldses.org>
 <1241374599-20348-2-git-send-email-bfields@fieldses.org>
 <1241374599-20348-3-git-send-email-bfields@fieldses.org>
 <1241374599-20348-4-git-send-email-bfields@fieldses.org>
 <1241374599-20348-5-git-send-email-bfields@fieldses.org>
 <1241374599-20348-6-git-send-email-bfields@fieldses.org>
 <1241374599-20348-7-git-send-email-bfields@fieldses.org>
 <1241374599-20348-8-git-send-email-bfields@fieldses.org>
 <1241374599-20348-9-git-send-email-bfields@fieldses.org>
 <1241374599-20348-10-git-send-email-bfields@fieldses.org>
 <1241374599-20348-11-git-send-email-bfields@fieldses.org>
 <1241374599-20348-12-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:58617 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754210AbZECSQj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 May 2009 14:16:39 -0400
In-Reply-To: <1241374599-20348-12-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

Move this out of a local variable into the nfs4_delegation object in
preparation for making this an async rpc call (at which point we'll need
any state like this in a common object that's preserved across function
calls).

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c     |    4 ++--
 include/linux/nfsd/state.h |    1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 0420b5e..b88b207 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -507,11 +507,11 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
 		.rpc_argp = dp,
 		.rpc_cred = clp->cl_cb_conn.cb_cred
 	};
-	int retries = 1;
 	int status = 0;
 
+	dp->dl_retries = 1;
 	status = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT);
-	while (retries--) {
+	while (dp->dl_retries--) {
 		switch (status) {
 			case -EIO:
 				/* Network partition? */
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 346b603..c0c4921 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -76,6 +76,7 @@ struct nfs4_delegation {
 	u32			dl_ident;
 	stateid_t		dl_stateid;
 	struct knfsd_fh		dl_fh;
+	int			dl_retries;
 };
 
 /* client delegation callback info */
-- 
1.6.0.4

