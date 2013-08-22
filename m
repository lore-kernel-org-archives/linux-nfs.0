Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:32090 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752981Ab3HVAYa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Aug 2013 20:24:30 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 15/21] NFSv4: Add tracepoints for debugging delegations
Date: Wed, 21 Aug 2013 20:24:13 -0400
Message-ID: <1377131059-40121-16-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377131059-40121-15-git-send-email-Trond.Myklebust@netapp.com>
References: <1377131059-40121-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-4-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-5-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-6-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-7-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-8-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-9-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-10-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-11-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-12-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-13-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-14-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-15-git-send-email-Trond.Myklebust@netapp.com>
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
 fs/nfs/nfs4proc.c      |  2 ++
 fs/nfs/nfs4trace.h     | 72 ++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 79 insertions(+)

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
index 3910ee6..e3ac877 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4798,6 +4798,7 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return;
 
+	trace_nfs4_delegreturn_exit(&data->args, &data->res, task->tk_status);
 	switch (task->tk_status) {
 	case -NFS4ERR_STALE_STATEID:
 	case -NFS4ERR_EXPIRED:
@@ -4901,6 +4902,7 @@ int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4
 	int err;
 	do {
 		err = _nfs4_proc_delegreturn(inode, cred, stateid, issync);
+		trace_nfs4_delegreturn(inode, err);
 		switch (err) {
 			case -NFS4ERR_STALE_STATEID:
 			case -NFS4ERR_EXPIRED:
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 6388db8..900f233 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -411,6 +411,76 @@ DEFINE_NFS4_LOCK_EVENT(nfs4_lock_reclaim);
 DEFINE_NFS4_LOCK_EVENT(nfs4_lock_expired);
 DEFINE_NFS4_LOCK_EVENT(nfs4_unlock);
 
+DECLARE_EVENT_CLASS(nfs4_set_delegation_event,
+		TP_PROTO(
+			const struct inode *inode,
+			fmode_t fmode
+		),
+
+		TP_ARGS(inode, fmode),
+
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+			__field(unsigned int, fmode)
+		),
+
+		TP_fast_assign(
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = NFS_FILEID(inode);
+			__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
+			__entry->fmode = (__force unsigned int)fmode;
+		),
+
+		TP_printk(
+			"fmode=%s fileid=%02x:%02x:%llu fhandle=0x%08x",
+			show_fmode_flags(__entry->fmode),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle
+		)
+);
+#define DEFINE_NFS4_SET_DELEGATION_EVENT(name) \
+	DEFINE_EVENT(nfs4_set_delegation_event, name, \
+			TP_PROTO( \
+				const struct inode *inode, \
+				fmode_t fmode \
+			), \
+			TP_ARGS(inode, fmode))
+DEFINE_NFS4_SET_DELEGATION_EVENT(nfs4_set_delegation);
+DEFINE_NFS4_SET_DELEGATION_EVENT(nfs4_reclaim_delegation);
+
+TRACE_EVENT(nfs4_delegreturn_exit,
+		TP_PROTO(
+			const struct nfs4_delegreturnargs *args,
+			const struct nfs4_delegreturnres *res,
+			int error
+		),
+
+		TP_ARGS(args, res, error),
+
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(int, error)
+		),
+
+		TP_fast_assign(
+			__entry->dev = res->server->s_dev;
+			__entry->fhandle = nfs_fhandle_hash(args->fhandle);
+			__entry->error = error;
+		),
+
+		TP_printk(
+			"error=%d (%s) dev=%02x:%02x fhandle=0x%08x",
+			__entry->error,
+			show_nfsv4_errors(__entry->error),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			__entry->fhandle
+		)
+);
+
 DECLARE_EVENT_CLASS(nfs4_lookup_event,
 		TP_PROTO(
 			const struct inode *dir,
@@ -554,6 +624,8 @@ DEFINE_NFS4_INODE_EVENT(nfs4_set_acl);
 DEFINE_NFS4_INODE_EVENT(nfs4_get_security_label);
 DEFINE_NFS4_INODE_EVENT(nfs4_set_security_label);
 #endif /* CONFIG_NFS_V4_SECURITY_LABEL */
+DEFINE_NFS4_INODE_EVENT(nfs4_recall_delegation);
+DEFINE_NFS4_INODE_EVENT(nfs4_delegreturn);
 
 #endif /* _TRACE_NFS4_H */
 
-- 
1.8.3.1

