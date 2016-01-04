Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:36029 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbcADSVt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jan 2016 13:21:49 -0500
Received: by mail-ig0-f182.google.com with SMTP id ph11so250739703igc.1
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jan 2016 10:21:49 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 06/18] NFSv4: List stateid information in the callback tracepoints
Date: Mon,  4 Jan 2016 13:21:04 -0500
Message-Id: <1451931676-68481-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451931676-68481-5-git-send-email-trond.myklebust@primarydata.com>
References: <1451931676-68481-1-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-2-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-3-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-4-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The stateid is extremely valuable when debugging.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c | 16 +++++++++---
 fs/nfs/nfs4trace.h     | 69 ++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 79 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 724a9b756ab0..e4dbab5dce6e 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -83,8 +83,11 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
 
 	res = htonl(NFS4ERR_BADHANDLE);
 	inode = nfs_delegation_find_inode(cps->clp, &args->fh);
-	if (inode == NULL)
+	if (inode == NULL) {
+		trace_nfs4_cb_recall(cps->clp, &args->fh, NULL,
+				&args->stateid, -ntohl(res));
 		goto out;
+	}
 	/* Set up a helper thread to actually return the delegation */
 	switch (nfs_async_inode_return_delegation(inode, &args->stateid)) {
 	case 0:
@@ -96,7 +99,8 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
 	default:
 		res = htonl(NFS4ERR_RESOURCE);
 	}
-	trace_nfs4_recall_delegation(inode, -ntohl(res));
+	trace_nfs4_cb_recall(cps->clp, &args->fh, inode,
+			&args->stateid, -ntohl(res));
 	iput(inode);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(res));
@@ -185,8 +189,11 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	LIST_HEAD(free_me_list);
 
 	lo = get_layout_by_fh(clp, &args->cbl_fh, &args->cbl_stateid);
-	if (!lo)
+	if (!lo) {
+		trace_nfs4_cb_layoutrecall_file(clp, &args->cbl_fh, NULL,
+				&args->cbl_stateid, -rv);
 		goto out;
+	}
 
 	ino = lo->plh_inode;
 
@@ -227,7 +234,8 @@ unlock:
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&free_me_list);
 	pnfs_put_layout_hdr(lo);
-	trace_nfs4_cb_layoutrecall_inode(clp, &args->cbl_fh, ino, -rv);
+	trace_nfs4_cb_layoutrecall_file(clp, &args->cbl_fh, ino,
+			&args->cbl_stateid, -rv);
 	iput(ino);
 out:
 	return rv;
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index d08d0c84b778..88b6b14ce71b 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -982,7 +982,6 @@ DEFINE_NFS4_INODE_EVENT(nfs4_set_acl);
 DEFINE_NFS4_INODE_EVENT(nfs4_get_security_label);
 DEFINE_NFS4_INODE_EVENT(nfs4_set_security_label);
 #endif /* CONFIG_NFS_V4_SECURITY_LABEL */
-DEFINE_NFS4_INODE_EVENT(nfs4_recall_delegation);
 
 DECLARE_EVENT_CLASS(nfs4_inode_stateid_event,
 		TP_PROTO(
@@ -1145,8 +1144,74 @@ DECLARE_EVENT_CLASS(nfs4_inode_callback_event,
 			), \
 			TP_ARGS(clp, fhandle, inode, error))
 DEFINE_NFS4_INODE_CALLBACK_EVENT(nfs4_cb_getattr);
-DEFINE_NFS4_INODE_CALLBACK_EVENT(nfs4_cb_layoutrecall_inode);
 
+DECLARE_EVENT_CLASS(nfs4_inode_stateid_callback_event,
+		TP_PROTO(
+			const struct nfs_client *clp,
+			const struct nfs_fh *fhandle,
+			const struct inode *inode,
+			const nfs4_stateid *stateid,
+			int error
+		),
+
+		TP_ARGS(clp, fhandle, inode, stateid, error),
+
+		TP_STRUCT__entry(
+			__field(int, error)
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+			__string(dstaddr, clp ?
+				rpc_peeraddr2str(clp->cl_rpcclient,
+					RPC_DISPLAY_ADDR) : "unknown")
+			__field(int, stateid_seq)
+			__field(u32, stateid_hash)
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
+			__entry->stateid_seq =
+				be32_to_cpu(stateid->seqid);
+			__entry->stateid_hash =
+				nfs_stateid_hash(stateid);
+		),
+
+		TP_printk(
+			"error=%d (%s) fileid=%02x:%02x:%llu fhandle=0x%08x "
+			"stateid=%d:0x%08x dstaddr=%s",
+			__entry->error,
+			show_nfsv4_errors(__entry->error),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle,
+			__entry->stateid_seq, __entry->stateid_hash,
+			__get_str(dstaddr)
+		)
+);
+
+#define DEFINE_NFS4_INODE_STATEID_CALLBACK_EVENT(name) \
+	DEFINE_EVENT(nfs4_inode_stateid_callback_event, name, \
+			TP_PROTO( \
+				const struct nfs_client *clp, \
+				const struct nfs_fh *fhandle, \
+				const struct inode *inode, \
+				const nfs4_stateid *stateid, \
+				int error \
+			), \
+			TP_ARGS(clp, fhandle, inode, stateid, error))
+DEFINE_NFS4_INODE_STATEID_CALLBACK_EVENT(nfs4_cb_recall);
+DEFINE_NFS4_INODE_STATEID_CALLBACK_EVENT(nfs4_cb_layoutrecall_file);
 
 DECLARE_EVENT_CLASS(nfs4_idmap_event,
 		TP_PROTO(
-- 
2.5.0

