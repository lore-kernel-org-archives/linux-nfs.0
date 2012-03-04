Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:16131 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755943Ab2CDXDJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 4 Mar 2012 18:03:09 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/11] NFSv4: Further clean-ups of delegation stateid validation
Date: Sun,  4 Mar 2012 18:02:54 -0500
Message-Id: <1330902183-18879-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1330902183-18879-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1330902183-18879-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the name to reflect what we're really doing: testing two
stateids for whether or not they match according the the rules in
RFC3530 and RFC5661.
Move the code from callback_proc.c to nfs4proc.c

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/callback_proc.c |   24 ------------------------
 fs/nfs/delegation.c    |    2 +-
 fs/nfs/nfs4_fs.h       |    2 +-
 fs/nfs/nfs4proc.c      |   27 +++++++++++++++++++++++++--
 4 files changed, 27 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index ea83219..1b5d809 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -98,14 +98,6 @@ out:
 	return res;
 }
 
-int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation, const nfs4_stateid *stateid)
-{
-	if (delegation == NULL || memcmp(delegation->stateid.data, stateid->data,
-					 sizeof(delegation->stateid.data)) != 0)
-		return 0;
-	return 1;
-}
-
 #if defined(CONFIG_NFS_V4_1)
 
 /*
@@ -319,22 +311,6 @@ out:
 	return res;
 }
 
-int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation, const nfs4_stateid *stateid)
-{
-	if (delegation == NULL)
-		return 0;
-
-	if (stateid->stateid.seqid != 0 &&
-	    stateid->stateid.seqid != delegation->stateid.stateid.seqid)
-		return 0;
-	if (memcmp(delegation->stateid.stateid.other,
-		   stateid->stateid.other,
-		   NFS4_STATEID_OTHER_SIZE))
-		return 0;
-
-	return 1;
-}
-
 /*
  * Validate the sequenceID sent by the server.
  * Return success if the sequenceID is one more than what we last saw on
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 1596098..9722e15 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -545,7 +545,7 @@ int nfs_async_inode_return_delegation(struct inode *inode,
 	rcu_read_lock();
 	delegation = rcu_dereference(NFS_I(inode)->delegation);
 
-	if (!clp->cl_mvops->validate_stateid(delegation, stateid)) {
+	if (!clp->cl_mvops->match_stateid(&delegation->stateid, stateid)) {
 		rcu_read_unlock();
 		return -ENOENT;
 	}
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 19079ec..9c05799 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -43,7 +43,7 @@ struct nfs4_minor_version_ops {
 			struct nfs4_sequence_args *args,
 			struct nfs4_sequence_res *res,
 			int cache_reply);
-	int	(*validate_stateid)(struct nfs_delegation *,
+	bool	(*match_stateid)(const nfs4_stateid *,
 			const nfs4_stateid *);
 	int	(*find_root_sec)(struct nfs_server *, struct nfs_fh *,
 			struct nfs_fsinfo *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ea7adfc..a79f623 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6257,8 +6257,31 @@ static int nfs41_free_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 	} while (exception.retry);
 	return err;
 }
+
+static bool nfs41_match_stateid(const nfs4_stateid *s1,
+		const nfs4_stateid *s2)
+{
+	if (memcmp(s1->stateid.other, s2->stateid.other,
+		   sizeof(s1->stateid.other)) != 0)
+		return false;
+
+	if (s1->stateid.seqid == s2->stateid.seqid)
+		return true;
+	if (s1->stateid.seqid == 0 || s1->stateid.seqid == 0)
+		return true;
+
+	return false;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
+static bool nfs4_match_stateid(const nfs4_stateid *s1,
+		const nfs4_stateid *s2)
+{
+	return memcmp(s1->data, s2->data, sizeof(s1->data)) == 0;
+}
+
+
 struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
 	.owner_flag_bit = NFS_OWNER_RECLAIM_REBOOT,
 	.state_flag_bit	= NFS_STATE_RECLAIM_REBOOT,
@@ -6317,7 +6340,7 @@ struct nfs4_state_maintenance_ops nfs41_state_renewal_ops = {
 static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 	.minor_version = 0,
 	.call_sync = _nfs4_call_sync,
-	.validate_stateid = nfs4_validate_delegation_stateid,
+	.match_stateid = nfs4_match_stateid,
 	.find_root_sec = nfs4_find_root_sec,
 	.reboot_recovery_ops = &nfs40_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs40_nograce_recovery_ops,
@@ -6328,7 +6351,7 @@ static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 	.minor_version = 1,
 	.call_sync = _nfs4_call_sync_session,
-	.validate_stateid = nfs41_validate_delegation_stateid,
+	.match_stateid = nfs41_match_stateid,
 	.find_root_sec = nfs41_find_root_sec,
 	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
-- 
1.7.7.6

