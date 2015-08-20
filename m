Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:33255 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751094AbbHTEGv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 00:06:51 -0400
Received: by pdrh1 with SMTP id h1so9326577pdr.0
        for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2015 21:06:50 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Enable delegated opens even when reboot recovery is pending
Date: Wed, 19 Aug 2015 23:06:48 -0500
Message-Id: <1440043608-37453-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Unlike the previous attempt, this takes into account the fact that
we may be calling it from the recovery thread itself. Detect this
by looking at what kind of open we're doing, and checking the state
of the NFS_DELEGATION_NEED_RECLAIM if it turns out we're doing a
reboot reclaim-type open.

Cc: Olga Kornievskaia <aglo@umich.edu>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c       | 27 +++++++++++++++++++--------
 include/linux/nfs_xdr.h |  2 +-
 2 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 95c5e8d39bef..6e988fd92f69 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1150,16 +1150,25 @@ out:
 	return ret;
 }
 
-static int can_open_delegated(struct nfs_delegation *delegation, fmode_t fmode)
+static int can_open_delegated(struct nfs_delegation *delegation, fmode_t fmode,
+		enum open_claim_type4 claim)
 {
 	if (delegation == NULL)
 		return 0;
 	if ((delegation->type & fmode) != fmode)
 		return 0;
-	if (test_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags))
-		return 0;
 	if (test_bit(NFS_DELEGATION_RETURNING, &delegation->flags))
 		return 0;
+	switch (claim) {
+	case NFS4_OPEN_CLAIM_NULL:
+	case NFS4_OPEN_CLAIM_FH:
+		break;
+	case NFS4_OPEN_CLAIM_PREVIOUS:
+		if (!test_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags))
+			break;
+	default:
+		return 0;
+	}
 	nfs_mark_delegation_referenced(delegation);
 	return 1;
 }
@@ -1378,6 +1387,7 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 	struct nfs_delegation *delegation;
 	int open_mode = opendata->o_arg.open_flags;
 	fmode_t fmode = opendata->o_arg.fmode;
+	enum open_claim_type4 claim = opendata->o_arg.claim;
 	nfs4_stateid stateid;
 	int ret = -EAGAIN;
 
@@ -1391,7 +1401,7 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 		spin_unlock(&state->owner->so_lock);
 		rcu_read_lock();
 		delegation = rcu_dereference(nfsi->delegation);
-		if (!can_open_delegated(delegation, fmode)) {
+		if (!can_open_delegated(delegation, fmode, claim)) {
 			rcu_read_unlock();
 			break;
 		}
@@ -1854,6 +1864,7 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 	struct nfs4_opendata *data = calldata;
 	struct nfs4_state_owner *sp = data->owner;
 	struct nfs_client *clp = sp->so_server->nfs_client;
+	enum open_claim_type4 claim = data->o_arg.claim;
 
 	if (nfs_wait_on_sequence(data->o_arg.seqid, task) != 0)
 		goto out_wait;
@@ -1868,15 +1879,15 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 			goto out_no_action;
 		rcu_read_lock();
 		delegation = rcu_dereference(NFS_I(data->state->inode)->delegation);
-		if (data->o_arg.claim != NFS4_OPEN_CLAIM_DELEGATE_CUR &&
-		    data->o_arg.claim != NFS4_OPEN_CLAIM_DELEG_CUR_FH &&
-		    can_open_delegated(delegation, data->o_arg.fmode))
+		if (can_open_delegated(delegation, data->o_arg.fmode, claim))
 			goto unlock_no_action;
 		rcu_read_unlock();
 	}
 	/* Update client id. */
 	data->o_arg.clientid = clp->cl_clientid;
-	switch (data->o_arg.claim) {
+	switch (claim) {
+	default:
+		break;
 	case NFS4_OPEN_CLAIM_PREVIOUS:
 	case NFS4_OPEN_CLAIM_DELEG_CUR_FH:
 	case NFS4_OPEN_CLAIM_DELEG_PREV_FH:
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 7bbe50504211..b9b530409ff7 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -389,7 +389,7 @@ struct nfs_openargs {
 	const struct nfs_server *server;	 /* Needed for ID mapping */
 	const u32 *		bitmask;
 	const u32 *		open_bitmap;
-	__u32			claim;
+	enum open_claim_type4	claim;
 	enum createmode4	createmode;
 	const struct nfs4_label *label;
 };
-- 
2.4.3

