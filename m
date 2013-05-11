Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f176.google.com ([74.125.82.176]:42480 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756823Ab3EKCnE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:43:04 -0400
Received: by mail-we0-f176.google.com with SMTP id p60so4400775wes.7
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:43:03 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id f2sm1144952wiv.11.2013.05.10.19.43.02
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:43:03 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 08/38] Revert "pnfsd: Notify device ID changes"
Date: Sat, 11 May 2013 05:42:58 +0300
Message-Id: <1368240178-32035-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 1a4f72df8cd69c8175677feaf7dd498edb6ff675.

Conflicts:
	fs/nfsd/nfs4callback.c
	fs/nfsd/nfs4pnfsd.c
	include/linux/nfsd/nfsd4_pnfs.h
---
 fs/nfsd/export.c                |   1 -
 fs/nfsd/nfs4callback.c          | 172 ----------------------------------------
 fs/nfsd/nfs4pnfsd.c             |  76 ------------------
 fs/nfsd/pnfsd.h                 |  13 ---
 include/linux/nfsd/nfsd4_pnfs.h |  14 ----
 5 files changed, 276 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index e54dccf..698ca5c 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -346,7 +346,6 @@ static int svc_export_upcall(struct cache_detail *cd, struct cache_head *h)
 #if defined(CONFIG_PNFSD)
 static struct pnfsd_cb_operations pnfsd_cb_op = {
 	.cb_layout_recall = nfsd_layout_recall_cb,
-	.cb_device_notify = nfsd_device_notify_cb,
 
 	.cb_get_state = nfs4_pnfs_cb_get_state,
 	.cb_change_state = nfs4_pnfs_cb_change_state,
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 89a671f..3ab44f7 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -52,7 +52,6 @@ enum {
 	NFSPROC4_CLNT_CB_RECALL,
 	NFSPROC4_CLNT_CB_SEQUENCE,
 	NFSPROC4_CLNT_CB_LAYOUT,
-	NFSPROC4_CLNT_CB_DEVICE,
 };
 
 #define NFS4_MAXTAGLEN		20
@@ -85,12 +84,6 @@ enum {
 #define NFS4_dec_cb_layout_sz		(cb_compound_dec_hdr_sz  +      \
 					cb_sequence_dec_sz +            \
 					op_dec_sz)
-#define NFS4_enc_cb_device_sz		(cb_compound_enc_hdr_sz +       \
-					cb_sequence_enc_sz +            \
-					1 + 6)
-#define NFS4_dec_cb_device_sz		(cb_compound_dec_hdr_sz  +      \
-					cb_sequence_dec_sz +            \
-					op_dec_sz)
 
 struct nfs4_cb_compound_hdr {
 	/* args */
@@ -460,67 +453,6 @@ static void encode_cb_layout4args(struct xdr_stream *xdr,
 	}
 	hdr->nops++;
 }
-
-/*
- * CB_NOTIFY_DEVICEID4args
- *
- *     typedef opaque notifylist4<>;
- *
- *     struct notify4 {
- *             bitmap4         notify_mask;
- *             notifylist4     notify_vals;
- *     };
- *
- *     struct CB_NOTIFY_DEVICEID4args {
- *             notify4 cnda_changes<>;
- *     };
- */
-static void encode_cb_device4args(struct xdr_stream *xdr,
-				  const struct nfs4_notify_device *nd,
-				  struct nfs4_cb_compound_hdr *hdr)
-{
-	u32 *p;
-	int i;
-	int len					= nd->nd_list->cbd_len;
-	struct nfsd4_pnfs_cb_dev_item *cbd	= nd->nd_list->cbd_list;
-
-	dprintk("NFSD %s: --> num %d\n", __func__, len);
-
-	BUG_ON(hdr->minorversion == 0);
-
-	p = xdr_reserve_space(xdr, 2 * 4);
-	*p++ = cpu_to_be32(OP_CB_NOTIFY_DEVICEID);
-	/* notify4 cnda_changes<>; */
-	*p = cpu_to_be32(len);
-	for (i = 0; i < len; i++) {
-		dprintk("%s: nt %d lt %d devid x%llx-x%llx im %d i %d\n",
-			__func__, cbd[i].cbd_notify_type,
-			cbd[i].cbd_layout_type,
-			cbd[i].cbd_devid.sbid,
-			cbd[i].cbd_devid.devid,
-			cbd[i].cbd_immediate, i);
-
-		BUG_ON(cbd[i].cbd_notify_type != NOTIFY_DEVICEID4_CHANGE &&
-		       cbd[i].cbd_notify_type != NOTIFY_DEVICEID4_DELETE);
-		p = xdr_reserve_space(xdr, 4 * 4 + 2 * 8);
-		/* bitmap4         notify_mask; */
-		*p++ = cpu_to_be32(1);
-		*p++ = cpu_to_be32(cbd[i].cbd_notify_type);
-		/* opaque     notify_vals<>; */
-		if (cbd[i].cbd_notify_type == NOTIFY_DEVICEID4_CHANGE)
-			*p++ = cpu_to_be32(24);
-		else
-			*p++ = cpu_to_be32(20);
-		*p++ = cpu_to_be32(cbd[i].cbd_layout_type);
-		p = nfsd4_encode_deviceid(p, &cbd[i].cbd_devid);
-
-		if (cbd[i].cbd_notify_type == NOTIFY_DEVICEID4_CHANGE) {
-			p = xdr_reserve_space(xdr, 4);
-			*p = cpu_to_be32(cbd[i].cbd_immediate);
-		}
-	}
-	hdr->nops++;
-}
 #endif /* CONFIG_PNFSD */
 
 /*
@@ -703,22 +635,6 @@ static void nfs4_xdr_enc_cb_layout(struct rpc_rqst *req,
 	encode_cb_layout4args(xdr, args, &hdr);
 	encode_cb_nops(&hdr);
 }
-
-static void nfs4_xdr_enc_cb_device(struct rpc_rqst *req,
-				   struct xdr_stream *xdr,
-				   const struct nfsd4_callback *cb)
-{
-	struct nfs4_notify_device *args =  cb->cb_op;
-	struct nfs4_cb_compound_hdr hdr = {
-		.ident = 0,
-		.minorversion = cb->cb_minorversion,
-	};
-
-	encode_cb_compound4args(xdr, &hdr);
-	encode_cb_sequence4args(xdr, cb, &hdr);
-	encode_cb_device4args(xdr, args, &hdr);
-	encode_cb_nops(&hdr);
-}
 #endif /* CONFIG_PNFSD */
 
 /*
@@ -791,31 +707,6 @@ static int nfs4_xdr_dec_cb_layout(struct rpc_rqst *rqstp,
 out:
 	return status;
 }
-
-static int nfs4_xdr_dec_cb_device(struct rpc_rqst *rqstp,
-				  struct xdr_stream *xdr,
-				  struct nfsd4_callback *cb)
-{
-	struct nfs4_cb_compound_hdr hdr;
-	enum nfsstat4 nfserr;
-	int status;
-
-	status = decode_cb_compound4res(xdr, &hdr);
-	if (unlikely(status))
-		goto out;
-	if (cb) {
-		status = decode_cb_sequence4res(xdr, cb);
-		if (unlikely(status))
-			goto out;
-	}
-	status = decode_cb_op_status(xdr, OP_CB_NOTIFY_DEVICEID, &nfserr);
-	if (unlikely(status))
-		goto out;
-	if (unlikely(nfserr != NFS4_OK))
-		status = nfs_cb_stat_to_errno(nfserr);
-out:
-	return status;
-}
 #endif /* CONFIG_PNFSD */
 
 /*
@@ -837,7 +728,6 @@ static int nfs4_xdr_dec_cb_device(struct rpc_rqst *rqstp,
 	PROC(CB_RECALL,	COMPOUND,	cb_recall,	cb_recall),
 #if defined(CONFIG_PNFSD)
 	PROC(CB_LAYOUT,	COMPOUND,	cb_layout,	cb_layout),
-	PROC(CB_DEVICE,	COMPOUND,	cb_device,	cb_device),
 #endif
 };
 
@@ -1431,66 +1321,4 @@ static void nfsd4_cb_layout_release(void *calldata)
 	cb->cb_ops = &nfsd4_cb_layout_ops;
 	run_nfsd4_cb(cb);
 }
-
-static void nfsd4_cb_device_prepare(struct rpc_task *task, void *calldata)
-{
-	struct nfsd4_callback *cb = calldata;
-	struct nfs4_notify_device *cbnd = container_of(cb, struct nfs4_notify_device, nd_recall);
-
-	nfsd4_cb_prepare_sequence(task, cb, cbnd->nd_client);
-}
-
-static void nfsd4_cb_device_done(struct rpc_task *task, void *calldata)
-{
-	struct nfsd4_callback *cb = calldata;
-	struct nfs4_notify_device *cbnd = container_of(cb, struct nfs4_notify_device, nd_recall);
-	struct nfs4_client *clp = cbnd->nd_client;
-
-	nfsd4_cb_done_sequence(task, clp);
-
-	dprintk("%s: clp %p cb_client %p: status %d\n",
-	       __func__,
-	       clp,
-	       clp->cl_cb_client,
-	       task->tk_status);
-
-	if (task->tk_status == -EIO) {
-		/* Network partition? */
-		nfsd4_mark_cb_down(clp, task->tk_status);
-	}
-	cb->cb_done = true;
-}
-
-static void nfsd4_cb_device_release(void *calldata)
-{
-	struct nfsd4_callback *cb = calldata;
-	struct nfs4_notify_device *cbnd = container_of(cb, struct nfs4_notify_device, nd_recall);
-
-	kfree(cbnd);
-}
-
-static const struct rpc_call_ops nfsd4_cb_device_ops = {
-	.rpc_call_prepare = nfsd4_cb_device_prepare,
-	.rpc_call_done = nfsd4_cb_device_done,
-	.rpc_release = nfsd4_cb_device_release,
-};
-
-/*
- * Called with state lock.
- */
-void
-nfsd4_cb_notify_device(struct nfs4_notify_device *cbnd)
-{
-	struct nfsd4_callback *cb = &cbnd->nd_recall;
-
-	cb->cb_op = cbnd;
-	cb->cb_clp = cbnd->nd_client;
-	cb->cb_msg.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_DEVICE];
-	cb->cb_msg.rpc_argp = cb;
-	cb->cb_msg.rpc_resp = cb;
-	cb->cb_msg.rpc_cred = callback_cred;
-
-	cb->cb_ops = &nfsd4_cb_device_ops;
-	run_nfsd4_cb(cb);
-}
 #endif /* CONFIG_PNFSD */
diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 8653719..85d0733 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -1552,79 +1552,3 @@ struct create_recall_list_arg {
 {
 	return _nfsd_layout_recall_cb(sb, inode, cbl, false);
 }
-
-struct create_device_notify_list_arg {
-	struct list_head *todolist;
-	struct nfsd4_pnfs_cb_dev_list *ndl;
-};
-
-static int
-create_device_notify_per_cl(struct nfs4_client *clp, void *p)
-{
-	struct nfs4_notify_device *cbnd;
-	struct create_device_notify_list_arg *arg = p;
-
-	cbnd = kzalloc(sizeof(*cbnd), GFP_KERNEL);
-	if (!cbnd)
-		return -ENOMEM;
-
-	cbnd->nd_list = arg->ndl;
-	cbnd->nd_client = clp;
-	INIT_WORK(&cbnd->nd_recall.cb_work, nfsd4_do_callback_rpc);
-	list_add(&cbnd->nd_perclnt, arg->todolist);
-	return 0;
-}
-
-/* Create a list of clients to send device notifications. */
-int
-create_device_notify_list(struct list_head *todolist,
-			  struct nfsd4_pnfs_cb_dev_list *ndl)
-{
-	int status;
-	struct create_device_notify_list_arg arg = {
-		.todolist = todolist,
-		.ndl = ndl,
-	};
-
-	nfs4_lock_state();
-	status = filter_confirmed_clients(create_device_notify_per_cl, &arg);
-	nfs4_unlock_state();
-
-	return status;
-}
-
-/*
- * For each client that a device, send a device notification.
- * XXX: Need to track which clients have which devices.
- */
-int nfsd_device_notify_cb(struct super_block *sb,
-			  struct nfsd4_pnfs_cb_dev_list *ndl)
-{
-	struct nfs4_notify_device *cbnd;
-	unsigned int notify_num = 0;
-	int status = 0;
-	struct list_head todolist;
-
-	BUG_ON(!ndl || ndl->cbd_len == 0 || !ndl->cbd_list);
-
-	dprintk("NFSD %s: cbl %p len %u\n", __func__, ndl, ndl->cbd_len);
-
-	if (nfsd_serv == NULL)
-		return -ENOENT;
-
-	INIT_LIST_HEAD(&todolist);
-
-	status = create_device_notify_list(&todolist, ndl);
-
-	while (!list_empty(&todolist)) {
-		cbnd = list_entry(todolist.next, struct nfs4_notify_device,
-				  nd_perclnt);
-		list_del_init(&cbnd->nd_perclnt);
-		nfsd4_cb_notify_device(cbnd);
-		notify_num++;
-	}
-
-	dprintk("NFSD %s: status %d clients %u\n",
-		__func__, status, notify_num);
-	return status;
-}
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 5b3657c..458e095 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -101,16 +101,6 @@ struct pnfs_mds_id {
 	struct kref		di_ref;
 };
 
-/* notify device request (from exported filesystem) */
-struct nfs4_notify_device {
-	struct nfsd4_pnfs_cb_dev_list  *nd_list;
-	struct nfs4_client	       *nd_client;
-	struct list_head	        nd_perclnt;
-
-	/* nfsd internal */
-	struct nfsd4_callback		nd_recall;
-};
-
 u64 find_create_sbid(struct super_block *);
 struct super_block *find_sbid_id(u64);
 __be32 nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *, struct exp_xdr_stream *);
@@ -128,9 +118,6 @@ int _nfsd_layout_recall_cb(struct super_block *, struct inode *,
 			  bool with_nfs4_state_lock);
 int nfsd_layout_recall_cb(struct super_block *, struct inode *,
 			  struct nfsd4_pnfs_cb_layout *);
-int nfsd_device_notify_cb(struct super_block *,
-			  struct nfsd4_pnfs_cb_dev_list *);
-void nfsd4_cb_notify_device(struct nfs4_notify_device *);
 
 static inline struct nfs4_layout_state *layoutstateid(struct nfs4_stid *s)
 {
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index ecb412e..95b8b6e 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -253,18 +253,6 @@ struct nfs4_layoutrecall {
 	struct nfsd4_callback		clr_recall;
 };
 
-struct nfsd4_pnfs_cb_dev_item {
-	u32			cbd_notify_type;	/* request */
-	u32			cbd_layout_type;	/* request */
-	struct nfsd4_pnfs_deviceid cbd_devid;		/* request */
-	u32			cbd_immediate;		/* request */
-};
-
-struct nfsd4_pnfs_cb_dev_list {
-	u32				cbd_len;  /* request */
-	struct nfsd4_pnfs_cb_dev_item  *cbd_list; /* request */
-};
-
 /*
  * callbacks provided by the nfsd
  */
@@ -272,8 +260,6 @@ struct pnfsd_cb_operations {
 	/* Generic callbacks */
 	int (*cb_layout_recall) (struct super_block *, struct inode *,
 				 struct nfsd4_pnfs_cb_layout *);
-	int (*cb_device_notify) (struct super_block *,
-				 struct nfsd4_pnfs_cb_dev_list *);
 
 	/* pNFS Files layout specific callbacks */
 
-- 
1.7.11.7

