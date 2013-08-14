Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:4678 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932361Ab3HNXZQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Aug 2013 19:25:16 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 08/13] NFSv4: Add tracepoints for debugging delegations
Date: Wed, 14 Aug 2013 19:24:53 -0400
Message-ID: <1376522698-44596-9-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1376522698-44596-8-git-send-email-Trond.Myklebust@netapp.com>
References: <1376522698-44596-1-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-2-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-3-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-4-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-5-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-6-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-7-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-8-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Set up tracepoints to track when delegations are set, reclaimed,
returned by the client, or recalled by the server.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/callback_proc.c |  2 ++
 fs/nfs/delegation.c    |  3 +++
 fs/nfs/nfs4proc.c      |  1 +
 fs/nfs/nfs4trace.h     | 37 +++++++++++++++++++++++++++++++++++++
 4 files changed, 43 insertions(+)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index e6ebc4c..c074930 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -15,6 +15,7 @@
 #include "internal.h"
 #include "pnfs.h"
 #include "nfs4session.h"
+#include "nfs4trace.h"
 
 #ifdef NFS_DEBUG
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
@@ -93,6 +94,7 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
 	default:
 		res = htonl(NFS4ERR_RESOURCE);
 	}
+	trace_nfs4_recall_delegation(inode, -ntohl(res));
 	iput(inode);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(res));
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 7ec4814..ef792f2 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -20,6 +20,7 @@
 #include "nfs4_fs.h"
 #include "delegation.h"
 #include "internal.h"
+#include "nfs4trace.h"
 
 static void nfs_free_delegation(struct nfs_delegation *delegation)
 {
@@ -160,6 +161,7 @@ void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred,
 			spin_unlock(&delegation->lock);
 			put_rpccred(oldcred);
 			rcu_read_unlock();
+			trace_nfs4_reclaim_delegation(inode, res->delegation_type);
 		} else {
 			/* We appear to have raced with a delegation return. */
 			spin_unlock(&delegation->lock);
@@ -344,6 +346,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	spin_lock(&inode->i_lock);
 	nfsi->cache_validity |= NFS_INO_REVAL_FORCED;
 	spin_unlock(&inode->i_lock);
+	trace_nfs4_set_delegation(inode, res->delegation_type);
 
 out:
 	spin_unlock(&clp->cl_lock);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1b39139..7f6c801 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4909,6 +4909,7 @@ int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4
 	int err;
 	do {
 		err = _nfs4_proc_delegreturn(inode, cred, stateid, issync);
+		trace_nfs4_delegreturn(inode, err);
 		switch (err) {
 			case -NFS4ERR_STALE_STATEID:
 			case -NFS4ERR_EXPIRED:
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index d707366..c4d9e70 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -391,6 +391,41 @@ DEFINE_NFS4_LOCK_EVENT(nfs4_lock_reclaim);
 DEFINE_NFS4_LOCK_EVENT(nfs4_lock_expired);
 DEFINE_NFS4_LOCK_EVENT(nfs4_unlock);
 
+DECLARE_EVENT_CLASS(nfs4_set_delegation_event,
+		TP_PROTO(const struct inode *inode,
+			fmode_t fmode),
+
+		TP_ARGS(inode, fmode),
+
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+			__field(fmode_t, fmode)
+		),
+
+		TP_fast_assign(
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = NFS_FILEID(inode);
+			__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
+			__entry->fmode = fmode;
+		),
+
+		TP_printk("mode=%s fileid=%02x:%02x:%lld, fhandle=%0x08x",
+			show_fmode_flags(__entry->fmode),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle
+		)
+);
+#define DEFINE_NFS4_SET_DELEGATION_EVENT(name)		\
+DEFINE_EVENT(nfs4_set_delegation_event, name,		\
+		TP_PROTO(const struct inode *inode,	\
+			fmode_t fmode),			\
+		TP_ARGS(inode, fmode))
+DEFINE_NFS4_SET_DELEGATION_EVENT(nfs4_set_delegation);
+DEFINE_NFS4_SET_DELEGATION_EVENT(nfs4_reclaim_delegation);
+
 DECLARE_EVENT_CLASS(nfs4_lookup_event,
 		TP_PROTO(const struct inode *dir,
 			const struct qstr *name,
@@ -532,6 +567,8 @@ DEFINE_NFS4_INODE_EVENT(nfs4_set_acl);
 DEFINE_NFS4_INODE_EVENT(nfs4_get_security_label);
 DEFINE_NFS4_INODE_EVENT(nfs4_set_security_label);
 #endif /* CONFIG_NFS_V4_SECURITY_LABEL */
+DEFINE_NFS4_INODE_EVENT(nfs4_recall_delegation);
+DEFINE_NFS4_INODE_EVENT(nfs4_delegreturn);
 
 #endif /* _TRACE_NFS4_H */
 
-- 
1.8.3.1

