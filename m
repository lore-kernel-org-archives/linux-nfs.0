Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17119 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757328Ab1BKQzA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 11:55:00 -0500
Received: from localhost.localdomain (manjua-lxp.hq.netapp.com [10.58.49.248] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p1BGshZ5002533
	for <linux-nfs@vger.kernel.org>; Fri, 11 Feb 2011 08:54:44 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/7] wave4: Send lseg down through nfs_write_rpcsetup into nfs_initiate_write
Date: Fri, 11 Feb 2011 11:54:34 -0500
Message-Id: <1297443279-19813-3-git-send-email-iisaman@netapp.com>
In-Reply-To: <1297443279-19813-1-git-send-email-iisaman@netapp.com>
References: <1297443279-19813-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We grab the lseg sent in to the doio function and attach it to
each struct nfs_write_data created.  This is how the lseg will be
sent to the layout driver.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/write.c          |    7 +++++--
 include/linux/nfs_xdr.h |    1 +
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 5604854..fa92fad 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -98,6 +98,7 @@ void nfs_writedata_free(struct nfs_write_data *p)
 static void nfs_writedata_release(struct nfs_write_data *wdata)
 {
 	put_nfs_open_context(wdata->args.context);
+	put_lseg(wdata->lseg);
 	nfs_writedata_free(wdata);
 }
 
@@ -840,6 +841,7 @@ static int nfs_write_rpcsetup(struct nfs_page *req,
 		struct nfs_write_data *data,
 		const struct rpc_call_ops *call_ops,
 		unsigned int count, unsigned int offset,
+		struct pnfs_layout_segment *lseg,
 		int how)
 {
 	struct inode *inode = req->wb_context->path.dentry->d_inode;
@@ -850,6 +852,7 @@ static int nfs_write_rpcsetup(struct nfs_page *req,
 	data->req = req;
 	data->inode = inode = req->wb_context->path.dentry->d_inode;
 	data->cred = req->wb_context->cred;
+	data->lseg = get_lseg(lseg);
 
 	data->args.fh     = NFS_FH(inode);
 	data->args.offset = req_offset(req) + offset;
@@ -930,7 +933,7 @@ static int nfs_flush_multi(struct inode *inode, struct list_head *head, unsigned
 		if (nbytes < wsize)
 			wsize = nbytes;
 		ret2 = nfs_write_rpcsetup(req, data, &nfs_write_partial_ops,
-				   wsize, offset, how);
+					  wsize, offset, lseg, how);
 		if (ret == 0)
 			ret = ret2;
 		offset += wsize;
@@ -978,7 +981,7 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned i
 	req = nfs_list_entry(data->pages.next);
 
 	/* Set up the argument struct */
-	return nfs_write_rpcsetup(req, data, &nfs_write_full_ops, count, 0, how);
+	return nfs_write_rpcsetup(req, data, &nfs_write_full_ops, count, 0, lseg, how);
  out_bad:
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 4121c3e..d60ec32 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1038,6 +1038,7 @@ struct nfs_write_data {
 	unsigned int		npages;		/* Max length of pagevec */
 	struct nfs_writeargs	args;		/* argument struct */
 	struct nfs_writeres	res;		/* result struct */
+	struct pnfs_layout_segment *lseg;
 #ifdef CONFIG_NFS_V4
 	unsigned long		timestamp;	/* For lease renewal */
 #endif
-- 
1.7.2.1

