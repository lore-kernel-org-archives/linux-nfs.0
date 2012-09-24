Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60227 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757570Ab2IXUAO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Sep 2012 16:00:14 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 28/28] NFSv4.1: nfs4_proc_layoutreturn must always drop the plh_block_lgets count
Date: Mon, 24 Sep 2012 15:56:46 -0400
Message-Id: <1348516606-22721-28-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348516606-22721-27-git-send-email-Trond.Myklebust@netapp.com>
References: <1348516606-22721-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-3-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-4-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-5-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-6-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-7-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-8-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-9-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-10-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-11-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-12-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-13-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-14-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-15-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-16-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-17-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-18-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-19-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-20-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-21-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-22-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-23-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-24-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-25-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-26-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-27-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently it does not do so if the RPC call failed to start. Fix is to
move the decrement of plh_block_lgets into nfs4_layoutreturn_release.

Also remove a redundant test of task->tk_status in nfs4_layoutreturn_done:
if lrp->res.lrs_present is set, then obviously the RPC call succeeded.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d9d67b3..6e95b20 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6346,7 +6346,6 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutreturn *lrp = calldata;
 	struct nfs_server *server;
-	struct pnfs_layout_hdr *lo = lrp->args.layout;
 
 	dprintk("--> %s\n", __func__);
 
@@ -6358,19 +6357,20 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 		rpc_restart_call_prepare(task);
 		return;
 	}
-	spin_lock(&lo->plh_inode->i_lock);
-	if (task->tk_status == 0 && lrp->res.lrs_present)
-		pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
-	lo->plh_block_lgets--;
-	spin_unlock(&lo->plh_inode->i_lock);
 	dprintk("<-- %s\n", __func__);
 }
 
 static void nfs4_layoutreturn_release(void *calldata)
 {
 	struct nfs4_layoutreturn *lrp = calldata;
+	struct pnfs_layout_hdr *lo = lrp->args.layout;
 
 	dprintk("--> %s\n", __func__);
+	spin_lock(&lo->plh_inode->i_lock);
+	if (lrp->res.lrs_present)
+		pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
+	lo->plh_block_lgets--;
+	spin_unlock(&lo->plh_inode->i_lock);
 	pnfs_put_layout_hdr(lrp->args.layout);
 	kfree(calldata);
 	dprintk("<-- %s\n", __func__);
-- 
1.7.11.4

