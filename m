Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:4877 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932119Ab2IXT6b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Sep 2012 15:58:31 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 13/28] NFSv4.1: Simplify the pNFS return-on-close code
Date: Mon, 24 Sep 2012 15:56:31 -0400
Message-Id: <1348516606-22721-13-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348516606-22721-12-git-send-email-Trond.Myklebust@netapp.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Confine it to the nfs4_do_close() code.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h   | 2 +-
 fs/nfs/nfs4proc.c  | 6 ++----
 fs/nfs/nfs4state.c | 7 ++-----
 3 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 71d407f..9cacc13 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -223,7 +223,7 @@ extern int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred);
 extern int nfs4_destroy_clientid(struct nfs_client *clp);
 extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred *);
-extern int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait, bool roc);
+extern int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait);
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
 extern int nfs4_proc_fs_locations(struct rpc_clnt *, struct inode *, const struct qstr *,
 				  struct nfs4_fs_locations *, struct page *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 49d5c7d..d9d67b3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2204,7 +2204,7 @@ static const struct rpc_call_ops nfs4_close_ops = {
  *
  * NOTE: Caller must be holding the sp->so_owner semaphore!
  */
-int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait, bool roc)
+int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
 	struct nfs4_closedata *calldata;
@@ -2240,7 +2240,7 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait, bool roc)
 	calldata->res.fattr = &calldata->fattr;
 	calldata->res.seqid = calldata->arg.seqid;
 	calldata->res.server = server;
-	calldata->roc = roc;
+	calldata->roc = pnfs_roc(state->inode);
 	nfs_sb_active(calldata->inode->i_sb);
 
 	msg.rpc_argp = &calldata->arg;
@@ -2257,8 +2257,6 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait, bool roc)
 out_free_calldata:
 	kfree(calldata);
 out:
-	if (roc)
-		pnfs_roc_release(state->inode);
 	nfs4_put_open_state(state);
 	nfs4_put_state_owner(sp);
 	return status;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index fc6cfe6..a5331ec 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -729,11 +729,8 @@ static void __nfs4_close(struct nfs4_state *state,
 	if (!call_close) {
 		nfs4_put_open_state(state);
 		nfs4_put_state_owner(owner);
-	} else {
-		bool roc = pnfs_roc(state->inode);
-
-		nfs4_do_close(state, gfp_mask, wait, roc);
-	}
+	} else
+		nfs4_do_close(state, gfp_mask, wait);
 }
 
 void nfs4_close_state(struct nfs4_state *state, fmode_t fmode)
-- 
1.7.11.4

