Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:37635 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbaICEg0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Sep 2014 00:36:26 -0400
Received: from [64.134.221.109] (helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XP2Iy-0003bU-Od
	for linux-nfs@vger.kernel.org; Wed, 03 Sep 2014 04:36:25 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/6] pnfs: enable CB_NOTIFY_DEVICEID support
Date: Tue,  2 Sep 2014 21:38:34 -0700
Message-Id: <1409719119-2110-2-git-send-email-hch@lst.de>
In-Reply-To: <1409719119-2110-1-git-send-email-hch@lst.de>
References: <1409719119-2110-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This code has been around for a while, but never was enabled.  Turns out it
really does work out of the box at least for the block layout driver, so
we just need to wire it up, and in case of NOTIFY_DEVICEID4_CHANGE remove
a conditional that returns an error.

Note that we implement NOTIFY_DEVICEID4_CHANGE identical to
NOTIFY_DEVICEID4_DELETE.  Given that in either case we can't do anything
but preventing further lookups of a given device ID there isn't much difference
in semantics for the two.  For the delete case the server MUST ensure that
there are no outstanding layouts, while for the change case it doesn't, but
that has little relevance to the client.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/callback_proc.c |  3 ---
 fs/nfs/nfs4xdr.c       | 35 +++++++++++++++++++++++++++--------
 fs/nfs/pnfs.h          |  2 ++
 fs/nfs/pnfs_dev.c      |  1 +
 4 files changed, 30 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 86541e0..1cdd345 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -287,9 +287,6 @@ __be32 nfs4_callback_devicenotify(struct cb_devicenotifyargs *args,
 		}
 
 	found:
-		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE)
-			dprintk("%s: NOTIFY_DEVICEID4_CHANGE not supported, "
-				"deleting instead\n", __func__);
 		nfs4_delete_deviceid(server->pnfs_curr_ld, clp, &dev->cbd_dev_id);
 	}
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index f2cd957..65864ec 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -373,14 +373,19 @@ static int nfs4_stat_to_errno(int);
 					    NFS4_DEVICEID4_SIZE) \
 				  /* gdlr_deviceid_list */ + \
 				1 /* bool gdlr_eof */)
-#define encode_getdeviceinfo_maxsz (op_encode_hdr_maxsz + 4 + \
-				XDR_QUADLEN(NFS4_DEVICEID4_SIZE))
+#define encode_getdeviceinfo_maxsz (op_encode_hdr_maxsz + \
+				XDR_QUADLEN(NFS4_DEVICEID4_SIZE) + \
+				1 /* layout type */ + \
+				1 /* maxcount */ + \
+				1 /* bitmap size */ + \
+				1 /* notification bitmap length */ + \
+				1 /* notification bitmap, word 0 */)
 #define decode_getdeviceinfo_maxsz (op_decode_hdr_maxsz + \
 				1 /* layout type */ + \
 				1 /* opaque devaddr4 length */ + \
 				  /* devaddr4 payload is read into page */ \
 				1 /* notification bitmap length */ + \
-				1 /* notification bitmap */)
+				1 /* notification bitmap, word 0 */)
 #define encode_layoutget_maxsz	(op_encode_hdr_maxsz + 10 + \
 				encode_stateid_maxsz)
 #define decode_layoutget_maxsz	(op_decode_hdr_maxsz + 8 + \
@@ -1955,12 +1960,20 @@ encode_getdeviceinfo(struct xdr_stream *xdr,
 	__be32 *p;
 
 	encode_op_hdr(xdr, OP_GETDEVICEINFO, decode_getdeviceinfo_maxsz, hdr);
-	p = reserve_space(xdr, 12 + NFS4_DEVICEID4_SIZE);
+	p = reserve_space(xdr, NFS4_DEVICEID4_SIZE + 4 + 4);
 	p = xdr_encode_opaque_fixed(p, args->pdev->dev_id.data,
 				    NFS4_DEVICEID4_SIZE);
 	*p++ = cpu_to_be32(args->pdev->layout_type);
 	*p++ = cpu_to_be32(args->pdev->maxcount);	/* gdia_maxcount */
-	*p++ = cpu_to_be32(0);				/* bitmap length 0 */
+
+	if (args->pdev->notify_types) {
+		p = reserve_space(xdr, 4 + 4);
+		*p++ = cpu_to_be32(1);			/* bitmap length */
+		*p++ = cpu_to_be32(args->pdev->notify_types);
+	} else {
+		p = reserve_space(xdr, 4);
+		*p++ = cpu_to_be32(0);
+	}
 }
 
 static void
@@ -5870,9 +5883,15 @@ static int decode_getdeviceinfo(struct xdr_stream *xdr,
 		p = xdr_inline_decode(xdr, 4 * len);
 		if (unlikely(!p))
 			goto out_overflow;
-		for (i = 0; i < len; i++, p++) {
-			if (be32_to_cpup(p)) {
-				dprintk("%s: notifications not supported\n",
+
+		if (be32_to_cpup(p++) & ~pdev->notify_types) {
+			dprintk("%s: no notification support\n",
+				__func__);
+		}
+
+		for (i = 1; i < len; i++) {
+			if (be32_to_cpup(p++)) {
+				dprintk("%s: unsupported notification\n",
 					__func__);
 				return -EIO;
 			}
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 4746ede..a5d3067 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -84,6 +84,7 @@ struct pnfs_layoutdriver_type {
 	const char *name;
 	struct module *owner;
 	unsigned flags;
+	unsigned notify_types;
 	unsigned max_deviceinfo_size;
 
 	int (*set_layoutdriver) (struct nfs_server *, const struct nfs_fh *);
@@ -161,6 +162,7 @@ struct pnfs_layout_hdr {
 struct pnfs_device {
 	struct nfs4_deviceid dev_id;
 	unsigned int  layout_type;
+	unsigned int  notify_types;
 	unsigned int  mincount;
 	unsigned int  maxcount;	/* gdia_maxcount */
 	struct page **pages;
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index 82c2836..d44334a 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -132,6 +132,7 @@ nfs4_get_device_info(struct nfs_server *server,
 
 	memcpy(&pdev->dev_id, dev_id, sizeof(*dev_id));
 	pdev->layout_type = server->pnfs_curr_ld->id;
+	pdev->notify_types = server->pnfs_curr_ld->notify_types;
 	pdev->pages = pages;
 	pdev->pgbase = 0;
 	pdev->pglen = max_resp_sz;
-- 
1.9.1

