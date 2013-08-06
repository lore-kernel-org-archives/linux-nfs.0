Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21769 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755330Ab3HFVJc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Aug 2013 17:09:32 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 2/5] nfs4.1: add state protection handler
Date: Tue, 6 Aug 2013 17:08:28 -0400
Message-ID: <1375823311-18457-3-git-send-email-dros@netapp.com>
In-Reply-To: <1375823311-18457-1-git-send-email-dros@netapp.com>
References: <1375823311-18457-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add nfs4_state_protect - the function responsible for switching to the machine
credential and the correct rpcclnt when SP4_MACH_CRED is in use.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4_fs.h | 36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ee81e35..3cf422f 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -273,6 +273,36 @@ is_ds_client(struct nfs_client *clp)
 {
 	return clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS;
 }
+
+/*
+ * Function responsible for determining if an rpc_message should use the
+ * machine cred under SP4_MACH_CRED and if so switching the credential and
+ * authflavor (using the nfs_client's rpc_clnt which will be krb5i/p).
+ */
+static inline void
+nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
+		   struct rpc_clnt **clntp, struct rpc_message *msg)
+{
+	struct rpc_cred *newcred = NULL;
+	rpc_authflavor_t flavor;
+
+	if (test_bit(sp4_mode, &clp->cl_sp4_flags)) {
+		dfprintk(PROC, "NFS: using machine cred for operation %s\n",
+			msg->rpc_proc->p_name);
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
@@ -298,6 +328,12 @@ is_ds_client(struct nfs_client *clp)
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

