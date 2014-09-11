Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:53143 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753891AbaIKAfZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2014 20:35:25 -0400
Received: from ip-64-134-224-54.public.wayport.net ([64.134.224.54] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XRsM8-00084C-Kf
	for linux-nfs@vger.kernel.org; Thu, 11 Sep 2014 00:35:24 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] pnfs: enable CB_NOTIFY_DEVICEID support
Date: Wed, 10 Sep 2014 17:37:28 -0700
Message-Id: <1410395848-2437-6-git-send-email-hch@lst.de>
In-Reply-To: <1410395848-2437-1-git-send-email-hch@lst.de>
References: <1410395848-2437-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This code has been around for a while, but never was enabled, although
it is in a working shape.

Note that we implement NOTIFY_DEVICEID4_CHANGE identical to
NOTIFY_DEVICEID4_DELETE.  Given that in either case we can't do anything
but preventing further lookups of a given device ID there isn't much difference
in semantics for the two.  For the delete case the server MUST ensure that
there are no outstanding layouts, while for the change case it doesn't, but
that has little relevance to the client.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/callback_proc.c |  3 ---
 fs/nfs/nfs4xdr.c       | 31 +++++++++++++++++++++++--------
 2 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 56bd0ea..73466b9 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -289,9 +289,6 @@ __be32 nfs4_callback_devicenotify(struct cb_devicenotifyargs *args,
 		}
 
 	found:
-		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE)
-			dprintk("%s: NOTIFY_DEVICEID4_CHANGE not supported, "
-				"deleting instead\n", __func__);
 		nfs4_delete_deviceid(server->pnfs_curr_ld, clp, &dev->cbd_dev_id);
 	}
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b8165ea..005d03c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -362,14 +362,19 @@ static int nfs4_stat_to_errno(int);
 				XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 5)
 #define encode_reclaim_complete_maxsz	(op_encode_hdr_maxsz + 4)
 #define decode_reclaim_complete_maxsz	(op_decode_hdr_maxsz + 4)
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
@@ -1918,12 +1923,15 @@ encode_getdeviceinfo(struct xdr_stream *xdr,
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
+	p = reserve_space(xdr, 4 + 4);
+	*p++ = cpu_to_be32(1);			/* bitmap length */
+	*p++ = cpu_to_be32(NOTIFY_DEVICEID4_CHANGE | NOTIFY_DEVICEID4_DELETE);
 }
 
 static void
@@ -5767,9 +5775,16 @@ static int decode_getdeviceinfo(struct xdr_stream *xdr,
 		p = xdr_inline_decode(xdr, 4 * len);
 		if (unlikely(!p))
 			goto out_overflow;
-		for (i = 0; i < len; i++, p++) {
-			if (be32_to_cpup(p)) {
-				dprintk("%s: notifications not supported\n",
+
+		if (be32_to_cpup(p++) &
+		    ~(NOTIFY_DEVICEID4_CHANGE | NOTIFY_DEVICEID4_DELETE)) {
+			dprintk("%s: unsupported notification\n",
+				__func__);
+		}
+
+		for (i = 1; i < len; i++) {
+			if (be32_to_cpup(p++)) {
+				dprintk("%s: unsupported notification\n",
 					__func__);
 				return -EIO;
 			}
-- 
1.9.1

