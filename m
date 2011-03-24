Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41615 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932341Ab1CXUss (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Mar 2011 16:48:48 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, dros@netapp.com
Subject: [PATCH] Cleanup XDR parsing for LAYOUTGET, GETDEVICEINFO
Date: Thu, 24 Mar 2011 16:48:21 -0400
Message-Id: <1300999701-2244-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

changes LAYOUTGET and GETDEVICEINFO XDR parsing to:
 - not use vmap, which doesn't work on incoherent archs
 - use xdr_stream parsing for all xdr

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4filelayout.c    |   53 +++++++++++--
 fs/nfs/nfs4filelayoutdev.c |  180 ++++++++++++++++++++++++++++++--------------
 fs/nfs/nfs4proc.c          |    9 +--
 fs/nfs/nfs4xdr.c           |   30 +++++---
 fs/nfs/pnfs.c              |   39 ++++++++++
 fs/nfs/pnfs.h              |    1 -
 include/linux/nfs_xdr.h    |    6 +-
 7 files changed, 232 insertions(+), 86 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 07ec59e..7325717 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -441,12 +441,33 @@ filelayout_decode_layout(struct pnfs_layout_hdr *flo,
 			 struct nfs4_layoutget_res *lgr,
 			 struct nfs4_deviceid *id)
 {
-	uint32_t *p = (uint32_t *)lgr->layout.buf;
+	struct xdr_stream stream;
+	struct xdr_buf buf = {
+		.pages =  lgr->layoutp->pages,
+		.page_len =  lgr->layoutp->len,
+		.buflen =  lgr->layoutp->len,
+		.len = lgr->layoutp->len,
+	};
+	struct page *scratch;
+	__be32 *p;
 	uint32_t nfl_util;
 	int i;
 
 	dprintk("%s: set_layout_map Begin\n", __func__);
 
+	scratch = alloc_page(GFP_KERNEL);
+	if (!scratch)
+		return -ENOMEM;
+
+	xdr_init_decode(&stream, &buf, NULL);
+	xdr_set_scratch_buffer(&stream, page_address(scratch), PAGE_SIZE);
+
+	/* 20 = ufl_util (4), first_stripe_index (4), pattern_offset (8),
+	 * num_fh (4) */
+	p = xdr_inline_decode(&stream, NFS4_DEVICEID4_SIZE + 20);
+	if (unlikely(!p))
+		goto out_err;
+
 	memcpy(id, p, sizeof(*id));
 	p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
 	print_deviceid(id);
@@ -468,32 +489,46 @@ filelayout_decode_layout(struct pnfs_layout_hdr *flo,
 		__func__, nfl_util, fl->num_fh, fl->first_stripe_index,
 		fl->pattern_offset);
 
+	if (!fl->num_fh)
+		goto out_err;
+
 	fl->fh_array = kzalloc(fl->num_fh * sizeof(struct nfs_fh *),
 			       GFP_KERNEL);
 	if (!fl->fh_array)
-		return -ENOMEM;
+		goto out_err;
 
 	for (i = 0; i < fl->num_fh; i++) {
 		/* Do we want to use a mempool here? */
 		fl->fh_array[i] = kmalloc(sizeof(struct nfs_fh), GFP_KERNEL);
-		if (!fl->fh_array[i]) {
-			filelayout_free_fh_array(fl);
-			return -ENOMEM;
-		}
+		if (!fl->fh_array[i])
+			goto out_err_free;
+
+		p = xdr_inline_decode(&stream, 4);
+		if (unlikely(!p))
+			goto out_err_free;
 		fl->fh_array[i]->size = be32_to_cpup(p++);
 		if (sizeof(struct nfs_fh) < fl->fh_array[i]->size) {
 			printk(KERN_ERR "Too big fh %d received %d\n",
 			       i, fl->fh_array[i]->size);
-			filelayout_free_fh_array(fl);
-			return -EIO;
+			goto out_err_free;
 		}
+
+		p = xdr_inline_decode(&stream, fl->fh_array[i]->size);
+		if (unlikely(!p))
+			goto out_err_free;
 		memcpy(fl->fh_array[i]->data, p, fl->fh_array[i]->size);
-		p += XDR_QUADLEN(fl->fh_array[i]->size);
 		dprintk("DEBUG: %s: fh len %d\n", __func__,
 			fl->fh_array[i]->size);
 	}
 
+	__free_page(scratch);
 	return 0;
+
+out_err_free:
+	filelayout_free_fh_array(fl);
+out_err:
+	__free_page(scratch);
+	return -EIO;
 }
 
 static struct pnfs_layout_segment *
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 433204f..414c7e9 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -261,7 +261,7 @@ out:
  * Currently only support ipv4, and one multi-path address.
  */
 static struct nfs4_pnfs_ds *
-decode_and_add_ds(__be32 **pp, struct inode *inode)
+decode_and_add_ds(struct xdr_stream *streamp, struct inode *inode)
 {
 	struct nfs4_pnfs_ds *ds = NULL;
 	char *buf;
@@ -269,25 +269,34 @@ decode_and_add_ds(__be32 **pp, struct inode *inode)
 	u32 ip_addr, port;
 	int nlen, rlen, i;
 	int tmp[2];
-	__be32 *r_netid, *r_addr, *p = *pp;
+	__be32 *p;
 
 	/* r_netid */
+	p = xdr_inline_decode(streamp, 4);
+	if (unlikely(!p))
+		goto out_err;
 	nlen = be32_to_cpup(p++);
-	r_netid = p;
-	p += XDR_QUADLEN(nlen);
 
-	/* r_addr */
-	rlen = be32_to_cpup(p++);
-	r_addr = p;
-	p += XDR_QUADLEN(rlen);
-	*pp = p;
+	p = xdr_inline_decode(streamp, nlen);
+	if (unlikely(!p))
+		goto out_err;
 
 	/* Check that netid is "tcp" */
-	if (nlen != 3 ||  memcmp((char *)r_netid, "tcp", 3)) {
+	if (nlen != 3 ||  memcmp((char *)p, "tcp", 3)) {
 		dprintk("%s: ERROR: non ipv4 TCP r_netid\n", __func__);
 		goto out_err;
 	}
 
+	/* r_addr */
+	p = xdr_inline_decode(streamp, 4);
+	if (unlikely(!p))
+		goto out_err;
+	rlen = be32_to_cpup(p);
+
+	p = xdr_inline_decode(streamp, rlen);
+	if (unlikely(!p))
+		goto out_err;
+
 	/* ipv6 length plus port is legal */
 	if (rlen > INET6_ADDRSTRLEN + 8) {
 		dprintk("%s: Invalid address, length %d\n", __func__,
@@ -295,8 +304,10 @@ decode_and_add_ds(__be32 **pp, struct inode *inode)
 		goto out_err;
 	}
 	buf = kmalloc(rlen + 1, GFP_KERNEL);
+	if (unlikely(!buf))
+		goto out_err;
 	buf[rlen] = '\0';
-	memcpy(buf, r_addr, rlen);
+	memcpy(buf, p, rlen);
 
 	/* replace the port dots with dashes for the in4_pton() delimiter*/
 	for (i = 0; i < 2; i++) {
@@ -332,90 +343,154 @@ out_err:
 static struct nfs4_file_layout_dsaddr*
 decode_device(struct inode *ino, struct pnfs_device *pdev)
 {
-	int i, dummy;
+	int i;
 	u32 cnt, num;
 	u8 *indexp;
-	__be32 *p = (__be32 *)pdev->area, *indicesp;
-	struct nfs4_file_layout_dsaddr *dsaddr;
+	__be32 *p;
+	u8 *stripe_indices;
+	u8 max_stripe_index;
+	struct nfs4_file_layout_dsaddr *dsaddr = NULL;
+	struct xdr_stream stream;
+	struct xdr_buf buf = {
+		.pages = pdev->pages,
+		.page_len = pdev->pglen,
+		.buflen = pdev->pglen,
+		.len = pdev->pglen,
+	};
+	struct page *scratch;
+
+	/* set up xdr stream */
+	scratch = alloc_page(GFP_KERNEL);
+	if (!scratch)
+		goto out_err;
+
+	xdr_init_decode(&stream, &buf, NULL);
+	xdr_set_scratch_buffer(&stream, page_address(scratch), PAGE_SIZE);
 
 	/* Get the stripe count (number of stripe index) */
-	cnt = be32_to_cpup(p++);
+	p = xdr_inline_decode(&stream, 4);
+	if (unlikely(!p))
+		goto out_err_free_scratch;
+
+	cnt = be32_to_cpup(p);
 	dprintk("%s stripe count  %d\n", __func__, cnt);
 	if (cnt > NFS4_PNFS_MAX_STRIPE_CNT) {
 		printk(KERN_WARNING "%s: stripe count %d greater than "
 		       "supported maximum %d\n", __func__,
 			cnt, NFS4_PNFS_MAX_STRIPE_CNT);
-		goto out_err;
+		goto out_err_free_scratch;
+	}
+
+	/* read stripe indices */
+	stripe_indices = kcalloc(cnt, sizeof(u8), GFP_KERNEL);
+	if (!stripe_indices)
+		goto out_err_free_scratch;
+
+	p = xdr_inline_decode(&stream, cnt << 2);
+	if (unlikely(!p))
+		goto out_err_free_stripe_indices;
+
+	indexp = &stripe_indices[0];
+	max_stripe_index = 0;
+	for (i = 0; i < cnt; i++) {
+		*indexp = be32_to_cpup(p++);
+		max_stripe_index = max(max_stripe_index, *indexp);
+		indexp++;
 	}
 
 	/* Check the multipath list count */
-	indicesp = p;
-	p += XDR_QUADLEN(cnt << 2);
-	num = be32_to_cpup(p++);
+	p = xdr_inline_decode(&stream, 4);
+	if (unlikely(!p))
+		goto out_err_free_stripe_indices;
+
+	num = be32_to_cpup(p);
 	dprintk("%s ds_num %u\n", __func__, num);
 	if (num > NFS4_PNFS_MAX_MULTI_CNT) {
 		printk(KERN_WARNING "%s: multipath count %d greater than "
 			"supported maximum %d\n", __func__,
 			num, NFS4_PNFS_MAX_MULTI_CNT);
-		goto out_err;
+		goto out_err_free_stripe_indices;
 	}
+
+	/* validate stripe indices are all < num */
+	if (max_stripe_index >= num) {
+		printk(KERN_WARNING "%s: stripe index %u >= num ds %u\n",
+			__func__, max_stripe_index, num);
+		goto out_err_free_stripe_indices;
+	}
+
 	dsaddr = kzalloc(sizeof(*dsaddr) +
 			(sizeof(struct nfs4_pnfs_ds *) * (num - 1)),
 			GFP_KERNEL);
 	if (!dsaddr)
-		goto out_err;
-
-	dsaddr->stripe_indices = kzalloc(sizeof(u8) * cnt, GFP_KERNEL);
-	if (!dsaddr->stripe_indices)
-		goto out_err_free;
+		goto out_err_free_stripe_indices;
 
 	dsaddr->stripe_count = cnt;
+	dsaddr->stripe_indices = stripe_indices;
+	stripe_indices = NULL;
 	dsaddr->ds_num = num;
 
 	memcpy(&dsaddr->deviceid, &pdev->dev_id, sizeof(pdev->dev_id));
 
-	/* Go back an read stripe indices */
-	p = indicesp;
-	indexp = &dsaddr->stripe_indices[0];
-	for (i = 0; i < dsaddr->stripe_count; i++) {
-		*indexp = be32_to_cpup(p++);
-		if (*indexp >= num)
-			goto out_err_free;
-		indexp++;
-	}
-	/* Skip already read multipath list count */
-	p++;
-
 	for (i = 0; i < dsaddr->ds_num; i++) {
 		int j;
+		u32 mp_count;
+
+		p = xdr_inline_decode(&stream, 4);
+		if (unlikely(!p))
+			goto out_err_free_deviceid;
 
-		dummy = be32_to_cpup(p++); /* multipath count */
-		if (dummy > 1) {
+		mp_count = be32_to_cpup(p); /* multipath count */
+		if (mp_count > 1) {
 			printk(KERN_WARNING
 			       "%s: Multipath count %d not supported, "
 			       "skipping all greater than 1\n", __func__,
-				dummy);
+				mp_count);
 		}
-		for (j = 0; j < dummy; j++) {
+		for (j = 0; j < mp_count; j++) {
 			if (j == 0) {
-				dsaddr->ds_list[i] = decode_and_add_ds(&p, ino);
+				dsaddr->ds_list[i] = decode_and_add_ds(&stream,
+					ino);
 				if (dsaddr->ds_list[i] == NULL)
-					goto out_err_free;
+					goto out_err_free_deviceid;
 			} else {
 				u32 len;
 				/* skip extra multipath */
-				len = be32_to_cpup(p++);
-				p += XDR_QUADLEN(len);
-				len = be32_to_cpup(p++);
-				p += XDR_QUADLEN(len);
-				continue;
+
+				/* read len, skip */
+				p = xdr_inline_decode(&stream, 4);
+				if (unlikely(!p))
+					goto out_err_free_deviceid;
+				len = be32_to_cpup(p);
+
+				p = xdr_inline_decode(&stream, len);
+				if (unlikely(!p))
+					goto out_err_free_deviceid;
+
+				/* read len, skip */
+				p = xdr_inline_decode(&stream, 4);
+				if (unlikely(!p))
+					goto out_err_free_deviceid;
+				len = be32_to_cpup(p);
+
+				p = xdr_inline_decode(&stream, len);
+				if (unlikely(!p))
+					goto out_err_free_deviceid;
 			}
 		}
 	}
+
+	__free_page(scratch);
 	return dsaddr;
 
-out_err_free:
+out_err_free_deviceid:
 	nfs4_fl_free_deviceid(dsaddr);
+	/* stripe_indicies was part of dsaddr */
+	goto out_err_free_scratch;
+out_err_free_stripe_indices:
+	kfree(stripe_indices);
+out_err_free_scratch:
+	__free_page(scratch);
 out_err:
 	dprintk("%s ERROR: returning NULL\n", __func__);
 	return NULL;
@@ -494,11 +569,6 @@ get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id)
 			goto out_free;
 	}
 
-	/* set pdev->area */
-	pdev->area = vmap(pages, max_pages, VM_MAP, PAGE_KERNEL);
-	if (!pdev->area)
-		goto out_free;
-
 	memcpy(&pdev->dev_id, dev_id, sizeof(*dev_id));
 	pdev->layout_type = LAYOUT_NFSV4_1_FILES;
 	pdev->pages = pages;
@@ -517,8 +587,6 @@ get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id)
 	 */
 	dsaddr = decode_and_add_device(inode, pdev);
 out_free:
-	if (pdev->area != NULL)
-		vunmap(pdev->area);
 	for (i = 0; i < max_pages; i++)
 		__free_page(pages[i]);
 	kfree(pages);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1369884..a305e40 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5460,8 +5460,6 @@ static void nfs4_layoutget_release(void *calldata)
 	struct nfs4_layoutget *lgp = calldata;
 
 	dprintk("--> %s\n", __func__);
-	if (lgp->res.layout.buf != NULL)
-		free_page((unsigned long) lgp->res.layout.buf);
 	put_nfs_open_context(lgp->args.ctx);
 	kfree(calldata);
 	dprintk("<-- %s\n", __func__);
@@ -5493,12 +5491,7 @@ int nfs4_proc_layoutget(struct nfs4_layoutget *lgp)
 
 	dprintk("--> %s\n", __func__);
 
-	lgp->res.layout.buf = (void *)__get_free_page(GFP_NOFS);
-	if (lgp->res.layout.buf == NULL) {
-		nfs4_layoutget_release(lgp);
-		return -ENOMEM;
-	}
-
+	lgp->res.layoutp = &lgp->args.layout;
 	lgp->res.seq_res.sr_slot = NULL;
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 0f2dcfb..1814f6e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2604,6 +2604,10 @@ static void nfs4_xdr_enc_layoutget(struct rpc_rqst *req,
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, NFS_FH(args->inode), &hdr);
 	encode_layoutget(xdr, args, &hdr);
+
+	xdr_inline_pages(&req->rq_rcv_buf, hdr.replen << 2,
+	    args->layout.pages, 0, args->layout.pglen);
+
 	encode_nops(&hdr);
 }
 #endif /* CONFIG_NFS_V4_1 */
@@ -4952,6 +4956,9 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
 	__be32 *p;
 	int status;
 	u32 layout_count;
+	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
+	struct kvec *iov = rcvbuf->head;
+	u32 hdrlen, recvd;
 
 	status = decode_op_hdr(xdr, OP_LAYOUTGET);
 	if (status)
@@ -4968,17 +4975,14 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
 		return -EINVAL;
 	}
 
-	p = xdr_inline_decode(xdr, 24);
+	p = xdr_inline_decode(xdr, 28);
 	if (unlikely(!p))
 		goto out_overflow;
 	p = xdr_decode_hyper(p, &res->range.offset);
 	p = xdr_decode_hyper(p, &res->range.length);
 	res->range.iomode = be32_to_cpup(p++);
 	res->type = be32_to_cpup(p++);
-
-	status = decode_opaque_inline(xdr, &res->layout.len, (char **)&p);
-	if (unlikely(status))
-		return status;
+	res->layoutp->len = be32_to_cpup(p);
 
 	dprintk("%s roff:%lu rlen:%lu riomode:%d, lo_type:0x%x, lo.len:%d\n",
 		__func__,
@@ -4986,12 +4990,18 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
 		(unsigned long)res->range.length,
 		res->range.iomode,
 		res->type,
-		res->layout.len);
+		res->layoutp->len);
+
+	hdrlen = (u8 *) xdr->p - (u8 *) iov->iov_base;
+	recvd = req->rq_rcv_buf.len - hdrlen;
+	if (res->layoutp->len > recvd) {
+		dprintk("NFS: server cheating in layoutget reply: "
+				"layout len %u > recvd %u\n",
+				res->layoutp->len, recvd);
+		return -EINVAL;
+	}
 
-	/* nfs4_proc_layoutget allocated a single page */
-	if (res->layout.len > PAGE_SIZE)
-		return -ENOMEM;
-	memcpy(res->layout.buf, p, res->layout.len);
+	xdr_read_pages(xdr, res->layoutp->len);
 
 	if (layout_count > 1) {
 		/* We only handle a length one array at the moment.  Any
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f38813a..89b28c7 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -471,6 +471,9 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	struct nfs_server *server = NFS_SERVER(ino);
 	struct nfs4_layoutget *lgp;
 	struct pnfs_layout_segment *lseg = NULL;
+	struct page **pages = NULL;
+	int i;
+	u32 max_resp_sz, max_pages;
 
 	dprintk("--> %s\n", __func__);
 
@@ -478,6 +481,21 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	lgp = kzalloc(sizeof(*lgp), GFP_KERNEL);
 	if (lgp == NULL)
 		return NULL;
+
+	/* allocate pages for xdr post processing */
+	max_resp_sz = server->nfs_client->cl_session->fc_attrs.max_resp_sz;
+	max_pages = max_resp_sz >> PAGE_SHIFT;
+
+	pages = kzalloc(max_pages * sizeof(struct page *), GFP_KERNEL);
+	if (!pages)
+		goto out_err_free;
+
+	for (i = 0; i < max_pages; i++) {
+		pages[i] = alloc_page(GFP_KERNEL);
+		if (!pages[i])
+			goto out_err_free;
+	}
+
 	lgp->args.minlength = NFS4_MAX_UINT64;
 	lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
 	lgp->args.range.iomode = iomode;
@@ -486,6 +504,8 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	lgp->args.type = server->pnfs_curr_ld->id;
 	lgp->args.inode = ino;
 	lgp->args.ctx = get_nfs_open_context(ctx);
+	lgp->args.layout.pages = pages;
+	lgp->args.layout.pglen = max_pages * PAGE_SIZE;
 	lgp->lsegpp = &lseg;
 
 	/* Synchronously retrieve layout information from server and
@@ -496,7 +516,26 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 		/* remember that LAYOUTGET failed and suspend trying */
 		set_bit(lo_fail_bit(iomode), &lo->plh_flags);
 	}
+
+	/* free xdr pages */
+	for (i = 0; i < max_pages; i++)
+		__free_page(pages[i]);
+	kfree(pages);
+
 	return lseg;
+
+out_err_free:
+	/* free any allocated xdr pages, lgp as it's not used */
+	if (pages) {
+		for (i = 0; i < max_pages; i++) {
+			if (!pages[i])
+				break;
+			__free_page(pages[i]);
+		}
+		kfree(pages);
+	}
+	kfree(lgp);
+	return NULL;
 }
 
 bool pnfs_roc(struct inode *ino)
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 6380b94..ad12bfd 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -100,7 +100,6 @@ struct pnfs_device {
 	unsigned int  layout_type;
 	unsigned int  mincount;
 	struct page **pages;
-	void          *area;
 	unsigned int  pgbase;
 	unsigned int  pglen;
 };
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 3440f5a..ede1ecb 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -190,8 +190,9 @@ struct nfs4_get_lease_time_res {
 #define PNFS_LAYOUT_MAXSIZE 4096
 
 struct nfs4_layoutdriver_data {
+	struct page **pages;
+	__u32 pglen;
 	__u32 len;
-	void *buf;
 };
 
 struct pnfs_layout_range {
@@ -209,6 +210,7 @@ struct nfs4_layoutget_args {
 	struct nfs_open_context *ctx;
 	struct nfs4_sequence_args seq_args;
 	nfs4_stateid stateid;
+	struct nfs4_layoutdriver_data layout;
 };
 
 struct nfs4_layoutget_res {
@@ -216,8 +218,8 @@ struct nfs4_layoutget_res {
 	struct pnfs_layout_range range;
 	__u32 type;
 	nfs4_stateid stateid;
-	struct nfs4_layoutdriver_data layout;
 	struct nfs4_sequence_res seq_res;
+	struct nfs4_layoutdriver_data *layoutp;
 };
 
 struct nfs4_layoutget {
-- 
1.7.4.1

