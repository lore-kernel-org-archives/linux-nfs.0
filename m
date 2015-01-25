Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:39090 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbbAYAR2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jan 2015 19:17:28 -0500
Received: by mail-ig0-f176.google.com with SMTP id hl2so3218778igb.3
        for <linux-nfs@vger.kernel.org>; Sat, 24 Jan 2015 16:17:28 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] NFSv4.1: Allow parallel LOCK/LOCKU calls
Date: Sat, 24 Jan 2015 19:17:21 -0500
Message-Id: <1422145041-81669-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1422145041-81669-5-git-send-email-trond.myklebust@primarydata.com>
References: <1422145041-81669-1-git-send-email-trond.myklebust@primarydata.com>
 <1422145041-81669-2-git-send-email-trond.myklebust@primarydata.com>
 <1422145041-81669-3-git-send-email-trond.myklebust@primarydata.com>
 <1422145041-81669-4-git-send-email-trond.myklebust@primarydata.com>
 <1422145041-81669-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Note, however, that we still serialise on the open stateid if the lock
stateid is unconfirmed. Hopefully that will not prove too much of a
burden for first time locks; it should leave the ability to parallelise
OPENs unchanged, since they no longer call the serialisation primitives.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9f6baf98942c..66befb0dd241 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5517,6 +5517,7 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
 	struct nfs_seqid *seqid;
 	struct nfs4_lock_state *lsp;
 	struct rpc_task *task;
+	struct nfs_seqid *(*alloc_seqid)(struct nfs_seqid_counter *, gfp_t);
 	int status = 0;
 	unsigned char fl_flags = request->fl_flags;
 
@@ -5540,7 +5541,8 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
 	lsp = request->fl_u.nfs4_fl.owner;
 	if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) == 0)
 		goto out;
-	seqid = nfs_alloc_seqid(&lsp->ls_seqid, GFP_KERNEL);
+	alloc_seqid = NFS_SERVER(inode)->nfs_client->cl_mvops->alloc_seqid;
+	seqid = alloc_seqid(&lsp->ls_seqid, GFP_KERNEL);
 	status = -ENOMEM;
 	if (IS_ERR(seqid))
 		goto out;
@@ -5575,6 +5577,7 @@ static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
 	struct nfs4_lockdata *p;
 	struct inode *inode = lsp->ls_state->inode;
 	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs_seqid *(*alloc_seqid)(struct nfs_seqid_counter *, gfp_t);
 
 	p = kzalloc(sizeof(*p), gfp_mask);
 	if (p == NULL)
@@ -5585,7 +5588,8 @@ static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
 	p->arg.open_seqid = nfs_alloc_seqid(&lsp->ls_state->owner->so_seqid, gfp_mask);
 	if (IS_ERR(p->arg.open_seqid))
 		goto out_free;
-	p->arg.lock_seqid = nfs_alloc_seqid(&lsp->ls_seqid, gfp_mask);
+	alloc_seqid = server->nfs_client->cl_mvops->alloc_seqid;
+	p->arg.lock_seqid = alloc_seqid(&lsp->ls_seqid, gfp_mask);
 	if (IS_ERR(p->arg.lock_seqid))
 		goto out_free_seqid;
 	p->arg.lock_owner.clientid = server->nfs_client->cl_clientid;
-- 
2.1.0

