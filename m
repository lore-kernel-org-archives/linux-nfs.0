Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34545 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752741AbbHUCAI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 22:00:08 -0400
Received: by paom9 with SMTP id m9so7049092pao.1
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 19:00:08 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFSv4: Add a tracepoint for CB_GETATTR
Date: Thu, 20 Aug 2015 21:00:04 -0500
Message-Id: <1440122405-30530-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1440122405-30530-1-git-send-email-trond.myklebust@primarydata.com>
References: <1440122405-30530-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c |  6 ++++-
 fs/nfs/nfs4trace.h     | 59 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 64 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 624bef79ba7c..07258d269e5a 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -40,8 +40,11 @@ __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
 		rpc_peeraddr2str(cps->clp->cl_rpcclient, RPC_DISPLAY_ADDR));
 
 	inode = nfs_delegation_find_inode(cps->clp, &args->fh);
-	if (inode == NULL)
+	if (inode == NULL) {
+		trace_nfs4_cb_getattr(cps->clp, &args->fh, inode,
+				-ntohl(res->status));
 		goto out;
+	}
 	nfsi = NFS_I(inode);
 	rcu_read_lock();
 	delegation = rcu_dereference(nfsi->delegation);
@@ -60,6 +63,7 @@ __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
 	res->status = 0;
 out_iput:
 	rcu_read_unlock();
+	trace_nfs4_cb_getattr(cps->clp, &args->fh, inode, -ntohl(res->status));
 	iput(inode);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(res->status));
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 0b67f7825d00..1aa096b665dc 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -884,6 +884,65 @@ DEFINE_NFS4_GETATTR_EVENT(nfs4_getattr);
 DEFINE_NFS4_GETATTR_EVENT(nfs4_lookup_root);
 DEFINE_NFS4_GETATTR_EVENT(nfs4_fsinfo);
 
+DECLARE_EVENT_CLASS(nfs4_inode_callback_event,
+		TP_PROTO(
+			const struct nfs_client *clp,
+			const struct nfs_fh *fhandle,
+			const struct inode *inode,
+			int error
+		),
+
+		TP_ARGS(clp, fhandle, inode, error),
+
+		TP_STRUCT__entry(
+			__field(int, error)
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+			__string(dstaddr, clp ?
+				rpc_peeraddr2str(clp->cl_rpcclient,
+					RPC_DISPLAY_ADDR) : "unknown")
+		),
+
+		TP_fast_assign(
+			__entry->error = error;
+			__entry->fhandle = nfs_fhandle_hash(fhandle);
+			if (inode != NULL) {
+				__entry->fileid = NFS_FILEID(inode);
+				__entry->dev = inode->i_sb->s_dev;
+			} else {
+				__entry->fileid = 0;
+				__entry->dev = 0;
+			}
+			__assign_str(dstaddr, clp ?
+				rpc_peeraddr2str(clp->cl_rpcclient,
+					RPC_DISPLAY_ADDR) : "unknown")
+		),
+
+		TP_printk(
+			"error=%d (%s) fileid=%02x:%02x:%llu fhandle=0x%08x "
+			"dstaddr=%s",
+			__entry->error,
+			show_nfsv4_errors(__entry->error),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle,
+			__get_str(dstaddr)
+		)
+);
+
+#define DEFINE_NFS4_INODE_CALLBACK_EVENT(name) \
+	DEFINE_EVENT(nfs4_inode_callback_event, name, \
+			TP_PROTO( \
+				const struct nfs_client *clp, \
+				const struct nfs_fh *fhandle, \
+				const struct inode *inode, \
+				int error \
+			), \
+			TP_ARGS(clp, fhandle, inode, error))
+DEFINE_NFS4_INODE_CALLBACK_EVENT(nfs4_cb_getattr);
+
+
 DECLARE_EVENT_CLASS(nfs4_idmap_event,
 		TP_PROTO(
 			const char *name,
-- 
2.4.3

