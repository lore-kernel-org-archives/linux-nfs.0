Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:16131 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755943Ab2CDXDM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 4 Mar 2012 18:03:12 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 06/11] NFSv4: Rename nfs4_copy_stateid()
Date: Sun,  4 Mar 2012 18:02:58 -0500
Message-Id: <1330902183-18879-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1330902183-18879-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1330902183-18879-1-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-2-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-3-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-4-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is really a function for selecting the correct stateid to use in a
read or write situation.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h   |    2 +-
 fs/nfs/nfs4proc.c  |    2 +-
 fs/nfs/nfs4state.c |    2 +-
 fs/nfs/nfs4xdr.c   |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 9c05799..e76f17c 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -327,7 +327,7 @@ extern void nfs41_handle_server_scope(struct nfs_client *,
 				      struct server_scope **);
 extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
 extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl);
-extern void nfs4_copy_stateid(nfs4_stateid *, struct nfs4_state *, fl_owner_t, pid_t);
+extern void nfs4_select_rw_stateid(nfs4_stateid *, struct nfs4_state *, fl_owner_t, pid_t);
 
 extern struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter, gfp_t gfp_mask);
 extern int nfs_wait_on_sequence(struct nfs_seqid *seqid, struct rpc_task *task);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a79f623..9200327 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1916,7 +1916,7 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	if (nfs4_copy_delegation_stateid(&arg.stateid, inode)) {
 		/* Use that stateid */
 	} else if (state != NULL) {
-		nfs4_copy_stateid(&arg.stateid, state, current->files, current->tgid);
+		nfs4_select_rw_stateid(&arg.stateid, state, current->files, current->tgid);
 	} else
 		memcpy(&arg.stateid, &zero_stateid, sizeof(arg.stateid));
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 2f76060..b59b39e 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -888,7 +888,7 @@ int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl)
  * Byte-range lock aware utility to initialize the stateid of read/write
  * requests.
  */
-void nfs4_copy_stateid(nfs4_stateid *dst, struct nfs4_state *state, fl_owner_t fl_owner, pid_t fl_pid)
+void nfs4_select_rw_stateid(nfs4_stateid *dst, struct nfs4_state *state, fl_owner_t fl_owner, pid_t fl_pid)
 {
 	struct nfs4_lock_state *lsp;
 	int seq;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c03ba77..38736dc 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1546,7 +1546,7 @@ static void encode_open_stateid(struct xdr_stream *xdr, const struct nfs_open_co
 	nfs4_stateid stateid;
 
 	if (ctx->state != NULL) {
-		nfs4_copy_stateid(&stateid, ctx->state, l_ctx->lockowner, l_ctx->pid);
+		nfs4_select_rw_stateid(&stateid, ctx->state, l_ctx->lockowner, l_ctx->pid);
 		if (zero_seqid)
 			stateid.stateid.seqid = 0;
 		encode_nfs4_stateid(xdr, &stateid);
-- 
1.7.7.6

