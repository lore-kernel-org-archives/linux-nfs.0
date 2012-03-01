Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:59257 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932228Ab2CAWCY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Mar 2012 17:02:24 -0500
Received: by yenl12 with SMTP id l12so547007yen.19
        for <linux-nfs@vger.kernel.org>; Thu, 01 Mar 2012 14:02:24 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/15] NFS: Fix some minor problems with nfs4_deviceids
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 01 Mar 2012 17:02:22 -0500
Message-ID: <20120301220222.2138.65095.stgit@degas.1015granger.net>
In-Reply-To: <20120301215755.2138.73488.stgit@degas.1015granger.net>
References: <20120301215755.2138.73488.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up due to code review.

sizeof(struct nfs4_deviceid) is the size of the in-core device ID data
structure, but NFS4_DEVICEID4_SIZE is the number of octets in an XDR'd
device ID.  The two are not interchangeable, even if they happen to
have the same value.  If struct nfs4_deviceid is padded by the
compiler, sizeof(struct nfs4_deviceid) may not be the same as the
XDR'd size.  Not likely, but still.

Ensure that the data field is aligned to the largest pointer type that
is used to access it: in this case, that's u64.  Type-punning among
types with different alignment has been discouraged in user space and
the kernel, to avoid unneeded pointer aliasing.  The use of a union
is preferred instead.

Ensure that XDR'ing and comparing is done via one of the union's data
fields, and not via the whole struct, again in case the compiler pads
the struct.

As a micro-optimization, this change also ensures that the compiler
may perform memcpy() and memcmp() operations on these fields in
larger, more efficient, chunks.

This patch needs review and testing by pnfs layout specialists.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/blocklayout/blocklayout.c    |    2 +-
 fs/nfs/blocklayout/blocklayoutdev.c |    8 ++++----
 fs/nfs/blocklayout/extents.c        |    5 +++--
 fs/nfs/callback_xdr.c               |    2 +-
 fs/nfs/nfs4filelayout.c             |    3 +--
 fs/nfs/nfs4xdr.c                    |    4 ++--
 fs/nfs/objlayout/pnfs_osd_xdr_cli.c |    8 ++++----
 fs/nfs/pnfs_dev.c                   |    7 ++++---
 include/linux/nfs4.h                |    7 ++++++-
 include/linux/pnfs_osd_xdr.h        |    4 ++--
 10 files changed, 28 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 783ebd5..3b730bf 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -901,7 +901,7 @@ nfs4_blk_get_deviceinfo(struct nfs_server *server, const struct nfs_fh *fh,
 	dev->pglen = PAGE_SIZE * max_pages;
 	dev->mincount = 0;
 
-	dprintk("%s: dev_id: %s\n", __func__, dev->dev_id.data);
+	dprintk("%s: dev_id: %s\n", __func__, dev->dev_id.u.data);
 	rc = nfs4_proc_getdeviceinfo(server, dev);
 	dprintk("%s getdevice info returns %d\n", __func__, rc);
 	if (rc) {
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index b48f782..2dafca5 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -124,8 +124,8 @@ nfs4_blk_decode_device(struct nfs_server *server,
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
 
 	dprintk("%s CREATING PIPEFS MESSAGE\n", __func__);
-	dprintk("%s: deviceid: %s, mincount: %d\n", __func__, dev->dev_id.data,
-		dev->mincount);
+	dprintk("%s: deviceid: %s, mincount: %d\n", __func__,
+		dev->dev_id.u.data, dev->mincount);
 
 	memset(&msg, 0, sizeof(msg));
 	msg.data = kzalloc(sizeof(bl_msg) + dev->mincount, GFP_NOFS);
@@ -206,7 +206,7 @@ static struct block_device *translate_devid(struct pnfs_layout_hdr *lo,
 	mid = BLK_ID(lo);
 	spin_lock(&mid->bm_lock);
 	list_for_each_entry(dev, &mid->bm_devlist, bm_node) {
-		if (memcmp(id->data, dev->bm_mdevid.data,
+		if (memcmp(id->u.data, dev->bm_mdevid.u.data,
 			   NFS4_DEVICEID4_SIZE) == 0) {
 			rv = dev->bm_mdev;
 			goto out;
@@ -323,7 +323,7 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 			status = -ENOMEM;
 			goto out_err;
 		}
-		memcpy(&be->be_devid, p, NFS4_DEVICEID4_SIZE);
+		memcpy(&be->be_devid.u.data, p, NFS4_DEVICEID4_SIZE);
 		p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
 		be->be_mdev = translate_devid(lo, &be->be_devid);
 		if (!be->be_mdev)
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 1f9a603..52b747c 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -675,10 +675,11 @@ encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 	if (!xdr_start)
 		goto out;
 	list_for_each_entry_safe(lce, save, &bl->bl_commit, bse_node) {
-		p = xdr_reserve_space(xdr, 7 * 4 + sizeof(lce->bse_devid.data));
+		p = xdr_reserve_space(xdr, 7 * 4 + NFS4_DEVICEID4_SIZE);
 		if (!p)
 			break;
-		p = xdr_encode_opaque_fixed(p, lce->bse_devid.data, NFS4_DEVICEID4_SIZE);
+		p = xdr_encode_opaque_fixed(p, lce->bse_devid.u.data,
+					    NFS4_DEVICEID4_SIZE);
 		p = xdr_encode_hyper(p, lce->bse_f_offset << SECTOR_SHIFT);
 		p = xdr_encode_hyper(p, lce->bse_length << SECTOR_SHIFT);
 		p = xdr_encode_hyper(p, 0LL);
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 5466829..6061322 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -347,7 +347,7 @@ __be32 decode_devicenotify_args(struct svc_rqst *rqstp,
 			goto err;
 		}
 		dev->cbd_layout_type = ntohl(*p++);
-		memcpy(dev->cbd_dev_id.data, p, NFS4_DEVICEID4_SIZE);
+		memcpy(dev->cbd_dev_id.u.data, p, NFS4_DEVICEID4_SIZE);
 		p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
 
 		if (dev->cbd_layout_type == NOTIFY_DEVICEID4_CHANGE) {
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 47e8f34..f0c6ba0 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -550,8 +550,7 @@ filelayout_decode_layout(struct pnfs_layout_hdr *flo,
 	if (unlikely(!p))
 		goto out_err;
 
-	memcpy(id, p, sizeof(*id));
-	p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
+	p = xdr_decode_opaque_fixed(p, id->u.data, NFS4_DEVICEID4_SIZE);
 	nfs4_print_deviceid(id);
 
 	nfl_util = be32_to_cpup(p++);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 80ba010..91020ea 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1946,7 +1946,7 @@ encode_getdeviceinfo(struct xdr_stream *xdr,
 
 	p = reserve_space(xdr, 16 + NFS4_DEVICEID4_SIZE);
 	*p++ = cpu_to_be32(OP_GETDEVICEINFO);
-	p = xdr_encode_opaque_fixed(p, args->pdev->dev_id.data,
+	p = xdr_encode_opaque_fixed(p, args->pdev->dev_id.u.data,
 				    NFS4_DEVICEID4_SIZE);
 	*p++ = cpu_to_be32(args->pdev->layout_type);
 	*p++ = cpu_to_be32(args->pdev->pglen);		/* gdia_maxcount */
@@ -5492,7 +5492,7 @@ static int decode_getdevicelist(struct xdr_stream *xdr,
 	if (unlikely(!p))
 		goto out_overflow;
 	for (i = 0; i < res->num_devs; i++)
-		p = xdr_decode_opaque_fixed(p, res->dev_id[i].data,
+		p = xdr_decode_opaque_fixed(p, res->dev_id[i].u.data,
 					    NFS4_DEVICEID4_SIZE);
 	res->eof = be32_to_cpup(p);
 	return 0;
diff --git a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
index b3918f7..99a1e89 100644
--- a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
+++ b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
@@ -55,8 +55,8 @@
 static __be32 *
 _osd_xdr_decode_objid(__be32 *p, struct pnfs_osd_objid *objid)
 {
-	p = xdr_decode_opaque_fixed(p, objid->oid_device_id.data,
-				    sizeof(objid->oid_device_id.data));
+	p = xdr_decode_opaque_fixed(p, objid->oid_device_id.u.data,
+				    NFS4_DEVICEID4_SIZE);
 
 	p = xdr_decode_hyper(p, &objid->oid_partition_id);
 	p = xdr_decode_hyper(p, &objid->oid_object_id);
@@ -377,8 +377,8 @@ pnfs_osd_xdr_encode_layoutupdate(struct xdr_stream *xdr,
 static inline __be32 *
 pnfs_osd_xdr_encode_objid(__be32 *p, struct pnfs_osd_objid *object_id)
 {
-	p = xdr_encode_opaque_fixed(p, &object_id->oid_device_id.data,
-				    sizeof(object_id->oid_device_id.data));
+	p = xdr_encode_opaque_fixed(p, &object_id->oid_device_id.u.data,
+				    NFS4_DEVICEID4_SIZE);
 	p = xdr_encode_hyper(p, object_id->oid_partition_id);
 	p = xdr_encode_hyper(p, object_id->oid_object_id);
 
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index 4f359d2..6c6ab81 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -46,7 +46,7 @@ static DEFINE_SPINLOCK(nfs4_deviceid_lock);
 void
 nfs4_print_deviceid(const struct nfs4_deviceid *id)
 {
-	u32 *p = (u32 *)id;
+	const u32 *p = id->u.data32;
 
 	dprintk("%s: device id= [%x%x%x%x]\n", __func__,
 		p[0], p[1], p[2], p[3]);
@@ -56,7 +56,7 @@ EXPORT_SYMBOL_GPL(nfs4_print_deviceid);
 static inline u32
 nfs4_deviceid_hash(const struct nfs4_deviceid *id)
 {
-	unsigned char *cptr = (unsigned char *)id->data;
+	const unsigned char *cptr = id->u.data;
 	unsigned int nbytes = NFS4_DEVICEID4_SIZE;
 	u32 x = 0;
 
@@ -77,7 +77,8 @@ _lookup_deviceid(const struct pnfs_layoutdriver_type *ld,
 
 	hlist_for_each_entry_rcu(d, n, &nfs4_deviceid_cache[hash], node)
 		if (d->ld == ld && d->nfs_client == clp &&
-		    !memcmp(&d->deviceid, id, sizeof(*id))) {
+		    !memcmp(&d->deviceid.u.data, id->u.data,
+						NFS4_DEVICEID4_SIZE)) {
 			if (atomic_read(&d->ref))
 				return d;
 			else
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index b1e6b64..979f607 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -649,9 +649,14 @@ enum filelayout_hint_care4 {
 #define NFS4_DEVICEID4_SIZE 16
 
 struct nfs4_deviceid {
-	char data[NFS4_DEVICEID4_SIZE];
+	union {
+		unsigned char	data[NFS4_DEVICEID4_SIZE];
+		u32		data32[NFS4_DEVICEID4_SIZE / sizeof(u32)];
+		u64		data64[NFS4_DEVICEID4_SIZE / sizeof(u64)];
+	} u;
 };
 
+
 #endif
 #endif
 
diff --git a/include/linux/pnfs_osd_xdr.h b/include/linux/pnfs_osd_xdr.h
index 435dd5f..11b4af9 100644
--- a/include/linux/pnfs_osd_xdr.h
+++ b/include/linux/pnfs_osd_xdr.h
@@ -91,10 +91,10 @@ struct pnfs_osd_objid {
  * BE style
  */
 #define _DEVID_LO(oid_device_id) \
-	(unsigned long long)be64_to_cpup((__be64 *)(oid_device_id)->data)
+	(unsigned long long)be64_to_cpup((__be64 *)(oid_device_id)->u.data64)
 
 #define _DEVID_HI(oid_device_id) \
-	(unsigned long long)be64_to_cpup(((__be64 *)(oid_device_id)->data) + 1)
+	(unsigned long long)be64_to_cpup(((__be64 *)(oid_device_id)->u.data64) + 1)
 
 enum pnfs_osd_version {
 	PNFS_OSD_MISSING              = 0,

