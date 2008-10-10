From: Benny Halevy <bhalevy@panasas.com>
Subject: cb_recall error handling on server
Date: Fri, 10 Oct 2008 11:50:38 +0200
Message-ID: <48EF256E.3060806@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:3202 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751765AbYJJJuq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Oct 2008 05:50:46 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce, I was looking into nfsd4_cb_recall and I noticed
that in case the first try erred with -EIO we
retry via the following path:

	while (retries--) {
		switch (status) {
		case -EIO:
			/* Network partition? */
			atomic_set(&clp->cl_callback.cb_set, 0);
		case -EBADHANDLE:
		case -NFS4ERR_BAD_STATEID:
			/* Race: client probably got cb_recall
			 * before open reply granting delegation */
			break;

The problem I see is that nobody seem to set clp->cl_callback.cb_set
back to one in case the retry succeeds.

How about this:

From: Benny Halevy <bhalevy@panasas.com>
Date: Fri, 10 Oct 2008 11:49:12 +0200
Subject: [PATCH] nfsd: reset cl_callback.cb_set only if all retries failed

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index e198ead..aec4a34 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -467,7 +467,6 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
 		switch (status) {
 			case -EIO:
 				/* Network partition? */
-				atomic_set(&clp->cl_callback.cb_set, 0);
 			case -EBADHANDLE:
 			case -NFS4ERR_BAD_STATEID:
 				/* Race: client probably got cb_recall
@@ -479,6 +478,8 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
 		ssleep(2);
 		status = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT);
 	}
+	if (status == -EIO)
+		atomic_set(&clp->cl_callback.cb_set, 0);
 out_put_cred:
 	/*
 	 * Success or failure, now we're either waiting for lease expiration
-- 
1.6.0.2

