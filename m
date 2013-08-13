Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:8875 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759174Ab3HMUhr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Aug 2013 16:37:47 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 2/7] nfs4.1: Add state protection handler
Date: Tue, 13 Aug 2013 16:37:33 -0400
Message-ID: <1376426258-28244-3-git-send-email-dros@netapp.com>
In-Reply-To: <1376426258-28244-1-git-send-email-dros@netapp.com>
References: <1376426258-28244-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add nfs4_state_protect - the function responsible for switching to the machine
credential and the correct rpc client when SP4_MACH_CRED is in use.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4_fs.h | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index d7bb59d..77b5c9f 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -272,6 +272,35 @@ is_ds_client(struct nfs_client *clp)
 {
 	return clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS;
 }
+
+/*
+ * Function responsible for determining if an rpc_message should use the
+ * machine cred under SP4_MACH_CRED and if so switching the credential and
+ * authflavor (using the nfs_client's rpc_clnt which will be krb5i/p).
+ * Should be called before rpc_call_sync/rpc_call_async.
+ */
+static inline void
+nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
+		   struct rpc_clnt **clntp, struct rpc_message *msg)
+{
+	struct rpc_cred *newcred = NULL;
+	rpc_authflavor_t flavor;
+
+	if (test_bit(sp4_mode, &clp->cl_sp4_flags)) {
+		spin_lock(&clp->cl_lock);
+		if (clp->cl_machine_cred != NULL)
+			newcred = get_rpccred(clp->cl_machine_cred);
+		spin_unlock(&clp->cl_lock);
+		if (msg->rpc_cred)
+			put_rpccred(msg->rpc_cred);
+		msg->rpc_cred = newcred;
+
+		flavor = clp->cl_rpcclient->cl_auth->au_flavor;
+		WARN_ON(flavor != RPC_AUTH_GSS_KRB5I &&
+			flavor != RPC_AUTH_GSS_KRB5P);
+		*clntp = clp->cl_rpcclient;
+	}
+}
 #else /* CONFIG_NFS_v4_1 */
 static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *server)
 {
@@ -297,6 +326,12 @@ is_ds_client(struct nfs_client *clp)
 {
 	return false;
 }
+
+static inline void
+nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_flags,
+		   struct rpc_clnt **clntp, struct rpc_message *msg)
+{
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 extern const struct nfs4_minor_version_ops *nfs_v4_minor_ops[];
-- 
1.7.12.4 (Apple Git-37)

