Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36477 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753327AbcIQFNu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Sep 2016 01:13:50 -0400
Received: by mail-it0-f66.google.com with SMTP id n143so1844766ita.3
        for <linux-nfs@vger.kernel.org>; Fri, 16 Sep 2016 22:13:50 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v5 15/25] NFSv4: nfs_inode_find_delegation_state_and_recover() should check all stateids
Date: Sat, 17 Sep 2016 01:13:23 -0400
Message-Id: <1474089213-104014-16-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474089213-104014-15-git-send-email-trond.myklebust@primarydata.com>
References: <1474089213-104014-1-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-2-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-3-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-4-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-5-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-6-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-7-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-8-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-9-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-10-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-11-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-12-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-13-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-14-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-15-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Modify the helper nfs_inode_find_delegation_state_and_recover() so that it
can check all stateids for whether or not they need recovery.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 18 ++++++++++++++++++
 fs/nfs/delegation.h |  2 ++
 fs/nfs/nfs4state.c  | 44 +++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 59 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 34aa5dfbe99e..11d49e1aa41b 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -992,6 +992,24 @@ restart:
 	rcu_read_unlock();
 }
 
+void nfs_inode_find_delegation_state_and_recover(struct inode *inode,
+		const nfs4_stateid *stateid)
+{
+	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
+	struct nfs_delegation *delegation;
+	bool found = false;
+
+	rcu_read_lock();
+	delegation = rcu_dereference(NFS_I(inode)->delegation);
+	if (delegation && nfs4_stateid_match(&delegation->stateid, stateid)) {
+		nfs_mark_test_expired_delegation(NFS_SERVER(inode), delegation);
+		found = true;
+	}
+	rcu_read_unlock();
+	if (found)
+		nfs4_schedule_state_manager(clp);
+}
+
 /**
  * nfs_delegations_present - check for existence of delegations
  * @clp: client state handle
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 1442e3b1521d..e9d555796873 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -66,6 +66,8 @@ void nfs_mark_delegation_referenced(struct nfs_delegation *delegation);
 int nfs4_have_delegation(struct inode *inode, fmode_t flags);
 int nfs4_check_delegation(struct inode *inode, fmode_t flags);
 bool nfs4_delegation_flush_on_close(const struct inode *inode);
+void nfs_inode_find_delegation_state_and_recover(struct inode *inode,
+		const nfs4_stateid *stateid);
 
 #endif
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 63da0411e2af..609643f31e7a 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1337,6 +1337,35 @@ int nfs4_schedule_stateid_recovery(const struct nfs_server *server, struct nfs4_
 }
 EXPORT_SYMBOL_GPL(nfs4_schedule_stateid_recovery);
 
+static struct nfs4_lock_state *
+nfs_state_find_lock_state_by_stateid(struct nfs4_state *state,
+		const nfs4_stateid *stateid)
+{
+	struct nfs4_lock_state *pos;
+
+	list_for_each_entry(pos, &state->lock_states, ls_locks) {
+		if (!test_bit(NFS_LOCK_INITIALIZED, &pos->ls_flags))
+			continue;
+		if (nfs4_stateid_match(&pos->ls_stateid, stateid))
+			return pos;
+	}
+	return NULL;
+}
+
+static bool nfs_state_lock_state_matches_stateid(struct nfs4_state *state,
+		const nfs4_stateid *stateid)
+{
+	bool found = false;
+
+	if (test_bit(LK_STATE_IN_USE, &state->flags)) {
+		spin_lock(&state->state_lock);
+		if (nfs_state_find_lock_state_by_stateid(state, stateid))
+			found = true;
+		spin_unlock(&state->state_lock);
+	}
+	return found;
+}
+
 void nfs_inode_find_state_and_recover(struct inode *inode,
 		const nfs4_stateid *stateid)
 {
@@ -1351,14 +1380,19 @@ void nfs_inode_find_state_and_recover(struct inode *inode,
 		state = ctx->state;
 		if (state == NULL)
 			continue;
-		if (!test_bit(NFS_DELEGATED_STATE, &state->flags))
-			continue;
-		if (!nfs4_stateid_match(&state->stateid, stateid))
+		if (nfs4_stateid_match(&state->stateid, stateid)) {
+			nfs4_state_mark_reclaim_nograce(clp, state);
+			found = true;
 			continue;
-		nfs4_state_mark_reclaim_nograce(clp, state);
-		found = true;
+		}
+		if (nfs_state_lock_state_matches_stateid(state, stateid)) {
+			nfs4_state_mark_reclaim_nograce(clp, state);
+			found = true;
+		}
 	}
 	spin_unlock(&inode->i_lock);
+
+	nfs_inode_find_delegation_state_and_recover(inode, stateid);
 	if (found)
 		nfs4_schedule_state_manager(clp);
 }
-- 
2.7.4

