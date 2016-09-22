Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34235 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965694AbcIVRjj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 13:39:39 -0400
Received: by mail-io0-f196.google.com with SMTP id y139so5620978ioy.1
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 10:39:38 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v7 08/31] NFSv4.x: Allow callers of nfs_remove_bad_delegation() to specify a stateid
Date: Thu, 22 Sep 2016 13:38:58 -0400
Message-Id: <1474565961-21303-9-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474565961-21303-8-git-send-email-trond.myklebust@primarydata.com>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-2-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-3-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-4-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-5-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-6-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-7-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-8-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the callers of nfs_remove_bad_delegation() to specify the stateid
that needs to be marked as bad.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c                    | 30 +++++++++++++++++++++++-------
 fs/nfs/delegation.h                    |  2 +-
 fs/nfs/flexfilelayout/flexfilelayout.c |  2 +-
 fs/nfs/nfs4proc.c                      | 14 ++++++++------
 4 files changed, 33 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index b9c65421ed81..e5212e5c73d2 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -652,23 +652,39 @@ static void nfs_client_mark_return_unused_delegation_types(struct nfs_client *cl
 	rcu_read_unlock();
 }
 
-static void nfs_revoke_delegation(struct inode *inode)
+static void nfs_mark_delegation_revoked(struct nfs_server *server,
+		struct nfs_delegation *delegation)
+{
+	set_bit(NFS_DELEGATION_REVOKED, &delegation->flags);
+	nfs_mark_return_delegation(server, delegation);
+}
+
+static bool nfs_revoke_delegation(struct inode *inode,
+		const nfs4_stateid *stateid)
 {
 	struct nfs_delegation *delegation;
+	bool ret = false;
+
 	rcu_read_lock();
 	delegation = rcu_dereference(NFS_I(inode)->delegation);
-	if (delegation != NULL) {
-		set_bit(NFS_DELEGATION_REVOKED, &delegation->flags);
-		nfs_mark_return_delegation(NFS_SERVER(inode), delegation);
-	}
+	if (delegation == NULL)
+		goto out;
+	if (stateid && !nfs4_stateid_match(stateid, &delegation->stateid))
+		goto out;
+	nfs_mark_delegation_revoked(NFS_SERVER(inode), delegation);
+	ret = true;
+out:
 	rcu_read_unlock();
+	return ret;
 }
 
-void nfs_remove_bad_delegation(struct inode *inode)
+void nfs_remove_bad_delegation(struct inode *inode,
+		const nfs4_stateid *stateid)
 {
 	struct nfs_delegation *delegation;
 
-	nfs_revoke_delegation(inode);
+	if (!nfs_revoke_delegation(inode, stateid))
+		return;
 	delegation = nfs_inode_detach_delegation(inode);
 	if (delegation) {
 		nfs_inode_find_state_and_recover(inode, &delegation->stateid);
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 64724d252a79..d40827af5913 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -47,7 +47,7 @@ void nfs_expire_unused_delegation_types(struct nfs_client *clp, fmode_t flags);
 void nfs_expire_unreferenced_delegations(struct nfs_client *clp);
 int nfs_client_return_marked_delegations(struct nfs_client *clp);
 int nfs_delegations_present(struct nfs_client *clp);
-void nfs_remove_bad_delegation(struct inode *inode);
+void nfs_remove_bad_delegation(struct inode *inode, const nfs4_stateid *stateid);
 
 void nfs_delegation_mark_reclaim(struct nfs_client *clp);
 void nfs_delegation_reap_unclaimed(struct nfs_client *clp);
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 51b51369704c..98ace127bf86 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1080,7 +1080,7 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
 	case -NFS4ERR_BAD_STATEID:
 		if (state == NULL)
 			break;
-		nfs_remove_bad_delegation(state->inode);
+		nfs_remove_bad_delegation(state->inode, NULL);
 	case -NFS4ERR_OPENMODE:
 		if (state == NULL)
 			break;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0ade81441ac2..9c203c221876 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2385,9 +2385,10 @@ static int nfs4_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *sta
 	return ret;
 }
 
-static void nfs_finish_clear_delegation_stateid(struct nfs4_state *state)
+static void nfs_finish_clear_delegation_stateid(struct nfs4_state *state,
+		const nfs4_stateid *stateid)
 {
-	nfs_remove_bad_delegation(state->inode);
+	nfs_remove_bad_delegation(state->inode, stateid);
 	write_seqlock(&state->seqlock);
 	nfs4_stateid_copy(&state->stateid, &state->open_stateid);
 	write_sequnlock(&state->seqlock);
@@ -2397,7 +2398,7 @@ static void nfs_finish_clear_delegation_stateid(struct nfs4_state *state)
 static void nfs40_clear_delegation_stateid(struct nfs4_state *state)
 {
 	if (rcu_access_pointer(NFS_I(state->inode)->delegation) != NULL)
-		nfs_finish_clear_delegation_stateid(state);
+		nfs_finish_clear_delegation_stateid(state, NULL);
 }
 
 static int nfs40_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *state)
@@ -2443,19 +2444,20 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
 		rcu_read_unlock();
 		return;
 	}
+
+	nfs4_stateid_copy(&stateid, &delegation->stateid);
 	if (test_bit(NFS_DELEGATION_REVOKED, &delegation->flags)) {
 		rcu_read_unlock();
-		nfs_finish_clear_delegation_stateid(state);
+		nfs_finish_clear_delegation_stateid(state, &stateid);
 		return;
 	}
 
-	nfs4_stateid_copy(&stateid, &delegation->stateid);
 	cred = get_rpccred(delegation->cred);
 	rcu_read_unlock();
 	status = nfs41_test_and_free_expired_stateid(server, &stateid, cred);
 	trace_nfs4_test_delegation_stateid(state, NULL, status);
 	if (status != NFS_OK)
-		nfs_finish_clear_delegation_stateid(state);
+		nfs_finish_clear_delegation_stateid(state, &stateid);
 
 	put_rpccred(cred);
 }
-- 
2.7.4

