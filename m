Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:37072 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933947AbcECS3r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 May 2016 14:29:47 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH 2/2] NFS: Merge _nfs4_state_protect() and nfs4_state_protect()
Date: Tue, 3 May 2016 14:29:42 -0400
Message-ID: <1462300182-24738-2-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1462300182-24738-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1462300182-24738-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We can have nfs4_state_protect() do the work directly, rather than
passing through the arguments without adding or modifying anything.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4_fs.h | 25 +++++++++----------------
 1 file changed, 9 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 4afdee4..7eba033 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -290,9 +290,15 @@ is_ds_client(struct nfs_client *clp)
 	return clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS;
 }
 
+/*
+ * Function responsible for determining if an rpc_message should use the
+ * machine cred under SP4_MACH_CRED and if so switching the credential and
+ * authflavor (using the nfs_client's rpc_clnt which will be krb5i/p).
+ * Should be called before rpc_call_sync/rpc_call_async.
+ */
 static inline bool
-_nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
-		    struct rpc_clnt **clntp, struct rpc_message *msg)
+nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
+		   struct rpc_clnt **clntp, struct rpc_message *msg)
 {
 	struct rpc_cred *newcred = NULL;
 	rpc_authflavor_t flavor;
@@ -317,19 +323,6 @@ _nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
 }
 
 /*
- * Function responsible for determining if an rpc_message should use the
- * machine cred under SP4_MACH_CRED and if so switching the credential and
- * authflavor (using the nfs_client's rpc_clnt which will be krb5i/p).
- * Should be called before rpc_call_sync/rpc_call_async.
- */
-static inline void
-nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
-		   struct rpc_clnt **clntp, struct rpc_message *msg)
-{
-	_nfs4_state_protect(clp, sp4_mode, clntp, msg);
-}
-
-/*
  * Special wrapper to nfs4_state_protect for write.
  * If WRITE can use machine cred but COMMIT cannot, make sure all writes
  * that use machine cred use NFS_FILE_SYNC.
@@ -338,7 +331,7 @@ static inline void
 nfs4_state_protect_write(struct nfs_client *clp, struct rpc_clnt **clntp,
 			 struct rpc_message *msg, struct nfs_pgio_header *hdr)
 {
-	if (_nfs4_state_protect(clp, NFS_SP4_MACH_CRED_WRITE, clntp, msg) &&
+	if (nfs4_state_protect(clp, NFS_SP4_MACH_CRED_WRITE, clntp, msg) &&
 	    !test_bit(NFS_SP4_MACH_CRED_COMMIT, &clp->cl_sp4_flags))
 		hdr->args.stable = NFS_FILE_SYNC;
 }
-- 
2.8.2

