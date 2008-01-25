From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 035/100] nfsd4: recognize callback channel failure earlier
Date: Fri, 25 Jan 2008 18:16:15 -0500
Message-ID: <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47386 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762058AbYAYXRg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:36 -0500
In-Reply-To: <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the callback channel fails, we inform the client of that by
returning a cb_path_down error the next time it tries to renew its
lease.

If we wait most of a lease period before deciding that a callback has
failed and that the callback channel is down, then we decrease the
chances that the client will find out in time to do anything about it.

So, mark the channel down as soon as we recognize that an rpc has
failed.  However, continue trying to recall delegations anyway, in hopes
it will come back up.  This will prevent more delegations from being
given out, and ensure cb_path_down is returned to renew calls earlier,
while still making the best effort to deliver recalls of existing
delegations.

Also fix a couple comments and remove a dprink that doesn't seem likely
to be useful.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   13 +++++--------
 fs/nfsd/nfs4state.c    |    5 ++++-
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 6eb5cd2..aae2b29 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -457,9 +457,6 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
 	int retries = 1;
 	int status = 0;
 
-	if ((!atomic_read(&clp->cl_callback.cb_set)) || !clnt)
-		return;
-
 	cbr->cbr_trunc = 0; /* XXX need to implement truncate optimization */
 	cbr->cbr_dp = dp;
 
@@ -468,6 +465,7 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
 		switch (status) {
 			case -EIO:
 				/* Network partition? */
+				atomic_set(&clp->cl_callback.cb_set, 0);
 			case -EBADHANDLE:
 			case -NFS4ERR_BAD_STATEID:
 				/* Race: client probably got cb_recall
@@ -480,11 +478,10 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
 		status = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT);
 	}
 out_put_cred:
-	if (status == -EIO)
-		atomic_set(&clp->cl_callback.cb_set, 0);
-	/* Success or failure, now we're either waiting for lease expiration
-	 * or deleg_return. */
-	dprintk("NFSD: nfs4_cb_recall: dp %p dl_flock %p dl_count %d\n",dp, dp->dl_flock, atomic_read(&dp->dl_count));
+	/*
+	 * Success or failure, now we're either waiting for lease expiration
+	 * or deleg_return.
+	 */
 	put_nfs4_client(clp);
 	nfs4_put_delegation(dp);
 	return;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1c72b23..409fa35 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -361,8 +361,11 @@ shutdown_callback_client(struct nfs4_client *clp)
 {
 	struct rpc_clnt *clnt = clp->cl_callback.cb_client;
 
-	/* shutdown rpc client, ending any outstanding recall rpcs */
 	if (clnt) {
+		/*
+		 * Callback threads take a reference on the client, so there
+		 * should be no outstanding callbacks at this point.
+		 */
 		clp->cl_callback.cb_client = NULL;
 		rpc_shutdown_client(clnt);
 	}
-- 
1.5.4.rc2.60.gb2e62

