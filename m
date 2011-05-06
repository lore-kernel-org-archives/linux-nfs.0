Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33659 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756674Ab1EFQuO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 May 2011 12:50:14 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 3/3] NFS: test and free stateids during recovery
Date: Fri,  6 May 2011 12:49:55 -0400
Message-Id: <1304700595-5040-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1304700595-5040-1-git-send-email-bjschuma@netapp.com>
References: <1304700595-5040-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Bryan Schumaker <bjschuma@netapp.com>

When recovering open files and locks, the stateid should be tested
against the server and freed if it is invalid.  This patch adds new
recovery functions for NFS v4.1.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4proc.c |   35 ++++++++++++++++++++++++++++++++---
 1 files changed, 32 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9eb6d2b..8f9cd91 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -80,7 +80,10 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
 			    struct nfs4_state *state);
-
+#ifdef CONFIG_NFS_V4_1
+static int nfs41_test_stateid(struct nfs_server *, struct nfs4_state *);
+static int nfs41_free_stateid(struct nfs_server *, struct nfs4_state *);
+#endif
 /* Prevent leaks of NFSv4 errors into userland */
 static int nfs4_map_errors(int err)
 {
@@ -1684,6 +1687,19 @@ static int nfs4_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *sta
 	return ret;
 }
 
+#if defined(CONFIG_NFS_V4_1)
+static int nfs41_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *state)
+{
+	int status;
+	struct nfs_server *server = NFS_SERVER(state->inode);
+
+	status = nfs41_test_stateid(server, state);
+	if (status != NFS_OK)
+		nfs41_free_stateid(server, state);
+	return nfs4_open_expired(sp, state);
+}
+#endif
+
 /*
  * on an EXCLUSIVE create, the server should send back a bitmask with FATTR4-*
  * fields corresponding to attributes that were used to store the verifier.
@@ -4424,6 +4440,19 @@ out:
 	return err;
 }
 
+#if defined(CONFIG_NFS_V4_1)
+static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *request)
+{
+	int status;
+	struct nfs_server *server = NFS_SERVER(state->inode);
+
+	status = nfs41_test_stateid(server, state);
+	if (status != NFS_OK)
+		nfs41_free_stateid(server, state);
+	return nfs4_lock_expired(state, request);
+}
+#endif
+
 static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
 {
 	struct nfs_inode *nfsi = NFS_I(state->inode);
@@ -5885,8 +5914,8 @@ struct nfs4_state_recovery_ops nfs40_nograce_recovery_ops = {
 struct nfs4_state_recovery_ops nfs41_nograce_recovery_ops = {
 	.owner_flag_bit = NFS_OWNER_RECLAIM_NOGRACE,
 	.state_flag_bit	= NFS_STATE_RECLAIM_NOGRACE,
-	.recover_open	= nfs4_open_expired,
-	.recover_lock	= nfs4_lock_expired,
+	.recover_open	= nfs41_open_expired,
+	.recover_lock	= nfs41_lock_expired,
 	.establish_clid = nfs41_init_clientid,
 	.get_clid_cred	= nfs4_get_exchange_id_cred,
 };
-- 
1.7.5.1

