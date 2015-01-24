Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:47948 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534AbbAXFji (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jan 2015 00:39:38 -0500
Received: by mail-ie0-f174.google.com with SMTP id vy18so1074935iec.5
        for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2015 21:39:38 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] NFSv4.1: Allow parallel OPEN/OPEN_DOWNGRADE/CLOSE
Date: Sat, 24 Jan 2015 00:39:28 -0500
Message-Id: <1422077968-116473-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1422077968-116473-5-git-send-email-trond.myklebust@primarydata.com>
References: <1422077968-116473-1-git-send-email-trond.myklebust@primarydata.com>
 <1422077968-116473-2-git-send-email-trond.myklebust@primarydata.com>
 <1422077968-116473-3-git-send-email-trond.myklebust@primarydata.com>
 <1422077968-116473-4-git-send-email-trond.myklebust@primarydata.com>
 <1422077968-116473-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove the serialisation of OPEN/OPEN_DOWNGRADE and CLOSE calls for the
case of NFSv4.1 and newer.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4_fs.h  |  3 +++
 fs/nfs/nfs4proc.c | 17 +++++++++++++++--
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index a08178764cf9..e57290a66b76 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -44,6 +44,7 @@ enum nfs4_client_state {
 #define NFS4_RENEW_TIMEOUT		0x01
 #define NFS4_RENEW_DELEGATION_CB	0x02
 
+struct nfs_seqid_counter;
 struct nfs4_minor_version_ops {
 	u32	minor_version;
 	unsigned init_caps;
@@ -56,6 +57,8 @@ struct nfs4_minor_version_ops {
 			struct nfs_fsinfo *);
 	void	(*free_lock_state)(struct nfs_server *,
 			struct nfs4_lock_state *);
+	struct nfs_seqid *
+		(*alloc_seqid)(struct nfs_seqid_counter *, gfp_t);
 	const struct rpc_call_ops *call_sync_ops;
 	const struct nfs4_state_recovery_ops *reboot_recovery_ops;
 	const struct nfs4_state_recovery_ops *nograce_recovery_ops;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c9c38077075c..0a279ad5421f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -977,6 +977,7 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	struct dentry *parent = dget_parent(dentry);
 	struct inode *dir = parent->d_inode;
 	struct nfs_server *server = NFS_SERVER(dir);
+	struct nfs_seqid *(*alloc_seqid)(struct nfs_seqid_counter *, gfp_t);
 	struct nfs4_opendata *p;
 
 	p = kzalloc(sizeof(*p), gfp_mask);
@@ -987,7 +988,8 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	if (IS_ERR(p->f_label))
 		goto err_free_p;
 
-	p->o_arg.seqid = nfs_alloc_seqid(&sp->so_seqid, gfp_mask);
+	alloc_seqid = server->nfs_client->cl_mvops->alloc_seqid;
+	p->o_arg.seqid = alloc_seqid(&sp->so_seqid, gfp_mask);
 	if (IS_ERR(p->o_arg.seqid))
 		goto err_free_label;
 	nfs_sb_active(dentry->d_sb);
@@ -2751,6 +2753,7 @@ static bool nfs4_roc(struct inode *inode)
 int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
+	struct nfs_seqid *(*alloc_seqid)(struct nfs_seqid_counter *, gfp_t);
 	struct nfs4_closedata *calldata;
 	struct nfs4_state_owner *sp = state->owner;
 	struct rpc_task *task;
@@ -2778,7 +2781,8 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
 	calldata->state = state;
 	calldata->arg.fh = NFS_FH(state->inode);
 	/* Serialization for the sequence id */
-	calldata->arg.seqid = nfs_alloc_seqid(&state->owner->so_seqid, gfp_mask);
+	alloc_seqid = server->nfs_client->cl_mvops->alloc_seqid;
+	calldata->arg.seqid = alloc_seqid(&state->owner->so_seqid, gfp_mask);
 	if (IS_ERR(calldata->arg.seqid))
 		goto out_free_calldata;
 	calldata->arg.fmode = 0;
@@ -8414,6 +8418,7 @@ static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 	.match_stateid = nfs4_match_stateid,
 	.find_root_sec = nfs4_find_root_sec,
 	.free_lock_state = nfs4_release_lockowner,
+	.alloc_seqid = nfs_alloc_seqid,
 	.call_sync_ops = &nfs40_call_sync_ops,
 	.reboot_recovery_ops = &nfs40_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs40_nograce_recovery_ops,
@@ -8422,6 +8427,12 @@ static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 };
 
 #if defined(CONFIG_NFS_V4_1)
+static struct nfs_seqid *
+nfs_alloc_no_seqid(struct nfs_seqid_counter *arg1, gfp_t arg2)
+{
+	return NULL;
+}
+
 static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 	.minor_version = 1,
 	.init_caps = NFS_CAP_READDIRPLUS
@@ -8435,6 +8446,7 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 	.match_stateid = nfs41_match_stateid,
 	.find_root_sec = nfs41_find_root_sec,
 	.free_lock_state = nfs41_free_lock_state,
+	.alloc_seqid = nfs_alloc_no_seqid,
 	.call_sync_ops = &nfs41_call_sync_ops,
 	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
@@ -8461,6 +8473,7 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 	.find_root_sec = nfs41_find_root_sec,
 	.free_lock_state = nfs41_free_lock_state,
 	.call_sync_ops = &nfs41_call_sync_ops,
+	.alloc_seqid = nfs_alloc_no_seqid,
 	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
 	.state_renewal_ops = &nfs41_state_renewal_ops,
-- 
2.1.0

