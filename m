From: andros@netapp.com
Subject: [PATCH 05/14] SQUASHME pnfs_submit: remove xdr macros
Date: Thu,  8 Apr 2010 15:54:01 -0400
Message-ID: <1270756450-5570-6-git-send-email-andros@netapp.com>
References: <1270756450-5570-1-git-send-email-andros@netapp.com>
 <1270756450-5570-2-git-send-email-andros@netapp.com>
 <1270756450-5570-3-git-send-email-andros@netapp.com>
 <1270756450-5570-4-git-send-email-andros@netapp.com>
 <1270756450-5570-5-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59475 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933260Ab0DHTy5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 15:54:57 -0400
In-Reply-To: <1270756450-5570-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

As per the rest of the nfs client, remove the old xdr macros

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c    |   16 +++++++++-------
 fs/nfs/nfs4filelayout.h    |   11 -----------
 fs/nfs/nfs4filelayoutdev.c |   25 +++++++++++++------------
 3 files changed, 22 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index abdf691..20b3ae2 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -459,8 +459,9 @@ filelayout_set_layout(struct nfs4_filelayout *flo,
 
 	dprintk("%s: set_layout_map Begin\n", __func__);
 
-	COPYMEM(&fl->dev_id, NFS4_PNFS_DEVICEID4_SIZE);
-	READ32(nfl_util);
+	memcpy(&fl->dev_id, p, NFS4_PNFS_DEVICEID4_SIZE);
+	p += XDR_QUADLEN(NFS4_PNFS_DEVICEID4_SIZE);
+	nfl_util = be32_to_cpup(p++);
 	if (nfl_util & NFL4_UFLG_COMMIT_THRU_MDS)
 		fl->commit_through_mds = 1;
 	if (nfl_util & NFL4_UFLG_DENSE)
@@ -477,9 +478,9 @@ filelayout_set_layout(struct nfs4_filelayout *flo,
 		flo->stripe_unit = fl->stripe_unit;
 	}
 
-	READ32(fl->first_stripe_index);
-	READ64(fl->pattern_offset);
-	READ32(fl->num_fh);
+	fl->first_stripe_index = be32_to_cpup(p++);
+	p = xdr_decode_hyper(p, &fl->pattern_offset);
+	fl->num_fh = be32_to_cpup(p++);
 
 	dprintk("%s: nfl_util 0x%X num_fh %u fsi %u po %llu dev_id %s\n",
 		__func__, nfl_util, fl->num_fh, fl->first_stripe_index,
@@ -499,7 +500,7 @@ filelayout_set_layout(struct nfs4_filelayout *flo,
 
 	for (i = 0; i < fl->num_fh; i++) {
 		/* fh */
-		READ32(fl->fh_array[i].size);
+		fl->fh_array[i].size = be32_to_cpup(p++);
 		if (sizeof(struct nfs_fh) < fl->fh_array[i].size) {
 			printk(KERN_ERR "Too big fh %d received %d\n",
 				i, fl->fh_array[i].size);
@@ -509,7 +510,8 @@ filelayout_set_layout(struct nfs4_filelayout *flo,
 			fl->num_fh = 0;
 			break;
 		}
-		COPYMEM(fl->fh_array[i].data, fl->fh_array[i].size);
+		memcpy(fl->fh_array[i].data, p, fl->fh_array[i].size);
+		p += XDR_QUADLEN(fl->fh_array[i].size);
 		dprintk("DEBUG: %s: fh len %d\n", __func__,
 					fl->fh_array[i].size);
 	}
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 0df1eaf..04cca7e 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -105,17 +105,6 @@ int nfs4_pnfs_dserver_get(struct pnfs_layout_segment *lseg,
 u32 filelayout_dserver_get_index(loff_t offset,
 				 struct nfs4_file_layout_dsaddr *di,
 				 struct nfs4_filelayout_segment *layout);
-
-#define READ32(x)         (x) = ntohl(*p++)
-#define READ64(x)         do {			\
-	(x) = (u64)ntohl(*p++) << 32;		\
-	(x) |= ntohl(*p++);			\
-} while (0)
-#define COPYMEM(x,nbytes) do {			\
-	memcpy((x), p, nbytes);			\
-	p += XDR_QUADLEN(nbytes);		\
-} while (0)
-
 struct nfs4_file_layout_dsaddr *
 nfs4_pnfs_device_item_find(struct nfs4_pnfs_dev_hlist *hlist,
 			   struct pnfs_deviceid *dev_id);
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index cda0bce..99a7ceb 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -88,8 +88,8 @@ deviceid_fmt(const struct pnfs_deviceid *dev_id)
 	uint32_t *p = (uint32_t *)dev_id->data;
 	uint64_t major, minor;
 
-	READ64(major);
-	READ64(minor);
+	p = xdr_decode_hyper(p, &major);
+	p = xdr_decode_hyper(p, &minor);
 
 	sprintf(buf, "%08llu %08llu", major, minor);
 	return buf;
@@ -467,7 +467,7 @@ decode_and_add_ds(uint32_t **pp, struct filelayout_mount_type *mt)
 
 	dprintk("%s enter\n", __func__);
 	/* check and skip r_netid */
-	READ32(len);
+	len = be32_to_cpup(p++);
 	/* "tcp" */
 	if (len != 3) {
 		printk("%s: ERROR: non TCP r_netid len %d\n",
@@ -476,15 +476,16 @@ decode_and_add_ds(uint32_t **pp, struct filelayout_mount_type *mt)
 	}
 	/* Read the bytes into a temporary buffer */
 	/* XXX: should probably sanity check them */
-	READ32(tmp[0]);
+	tmp[0] = be32_to_cpup(p++);
 
-	READ32(len);
+	len = be32_to_cpup(p++);
 	if (len > 29) {
 		printk("%s: ERROR: Device ip/port too long (%d)\n",
 			__func__, len);
 		goto out_err;
 	}
-	COPYMEM(r_addr, len);
+	memcpy(r_addr, p, len);
+	p += XDR_QUADLEN(len);
 	*pp = p;
 	r_addr[len] = '\0';
 	sscanf(r_addr, "%d.%d.%d.%d.%d.%d", &tmp[0], &tmp[1],
@@ -513,7 +514,7 @@ decode_device(struct filelayout_mount_type *mt, struct pnfs_device *pdev)
 	struct nfs4_file_layout_dsaddr *dsaddr;
 
 	/* Get the stripe count (number of stripe index) */
-	READ32(cnt);
+	cnt = be32_to_cpup(p++);
 	dprintk("%s stripe count  %d\n", __func__, cnt);
 	if (cnt > NFS4_PNFS_MAX_STRIPE_CNT) {
 		printk(KERN_WARNING "%s: stripe count %d greater than "
@@ -525,7 +526,7 @@ decode_device(struct filelayout_mount_type *mt, struct pnfs_device *pdev)
 	/* Check the multipath list count */
 	indicesp = p;
 	p += XDR_QUADLEN(cnt << 2);
-	READ32(num);
+	num = be32_to_cpup(p++);
 	dprintk("%s ds_num %u\n", __func__, num);
 	if (num > NFS4_PNFS_MAX_MULTI_CNT) {
 		printk(KERN_WARNING "%s: multipath count %d greater than "
@@ -552,7 +553,7 @@ decode_device(struct filelayout_mount_type *mt, struct pnfs_device *pdev)
 	p = indicesp;
 	indexp = &dsaddr->stripe_indices[0];
 	for (i = 0; i < dsaddr->stripe_count; i++) {
-		READ32(dummy);
+		dummy = be32_to_cpup(p++);
 		*indexp = dummy; /* bound by NFS4_PNFS_MAX_MULTI_CNT */
 		indexp++;
 	}
@@ -562,7 +563,7 @@ decode_device(struct filelayout_mount_type *mt, struct pnfs_device *pdev)
 	for (i = 0; i < dsaddr->ds_num; i++) {
 		int j;
 
-		READ32(dummy); /* multipath count */
+		dummy = be32_to_cpup(p++); /* multipath count */
 		if (dummy > 1) {
 			printk(KERN_WARNING
 			       "%s: Multipath count %d not supported, "
@@ -577,9 +578,9 @@ decode_device(struct filelayout_mount_type *mt, struct pnfs_device *pdev)
 			} else {
 				u32 len;
 				/* skip extra multipath */
-				READ32(len);
+				len = be32_to_cpup(p++);
 				p += XDR_QUADLEN(len);
-				READ32(len);
+				len = be32_to_cpup(p++);
 				p += XDR_QUADLEN(len);
 				continue;
 			}
-- 
1.6.6

