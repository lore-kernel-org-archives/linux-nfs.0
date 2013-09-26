Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f46.google.com ([209.85.128.46]:40098 "EHLO
	mail-qe0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078Ab3IZSlQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:41:16 -0400
Received: by mail-qe0-f46.google.com with SMTP id x7so1088715qeu.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:41:15 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 20/49] pnfsd: filelayout: layout encoding
Date: Thu, 26 Sep 2013 14:41:12 -0400
Message-Id: <1380220872-13597-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

[extracted from: pnfsd: Initial pNFS server implementation.]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: update pNFS server ops to draft 13]
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
[pnfsd: Check for dense layout in layout encode.]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
[pnfsd: Fix server GETDEVICELIST to comply with NFSv4.1 Draft 13]
Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
[pnfsd: Fix file layout layoutget export op for d13]
[pnfsd: Simplify layout get export interface.]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
[pnfsd: improve nfs4_pnfs_get_layout dprintks]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: initialize layoutget return_on_close]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: Use 128 bit deviceid on server]
[pnfsd: update server layout xdr for draft 19.]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
[pnfsd: filelayout: use nfsd4_compoundres pointer in pnfs_xdr_info]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: filelayout: get rid of xdr encoding macros for file layout xdr]
[pnfsd: get rid of layout encoding function vector]
[pnfsd: filelayout: strictly define filelayout_encode_layout]
[pnfsd: filelayout: convert to using exp_xdr]
[include nfsd4_pnfs.h from nfs4layoutxdr.h for deviceid_t]
[pnfsd: rename deviceid_t struct pnfs_deviceid]
[pnfsd: fix cosmetic checkpatch warnings]
[pnfsd: rename device fsid member to sbid]
[pnfsd: fixup filelayout_encode_layout return type to u32]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: nfsd4_pnfs_dlm_layoutget]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/exportfs/nfs4filelayoutxdr.c    | 85 ++++++++++++++++++++++++++++++++++++++
 include/linux/exportfs.h           |  4 +-
 include/linux/nfsd/nfs4layoutxdr.h | 18 ++++++++
 3 files changed, 105 insertions(+), 2 deletions(-)

diff --git a/fs/exportfs/nfs4filelayoutxdr.c b/fs/exportfs/nfs4filelayoutxdr.c
index 4801bfe..f63c311 100644
--- a/fs/exportfs/nfs4filelayoutxdr.c
+++ b/fs/exportfs/nfs4filelayoutxdr.c
@@ -31,6 +31,8 @@
  */
 #include <linux/exp_xdr.h>
 #include <linux/module.h>
+#include <linux/nfs4.h>
+#include <linux/nfsd/nfsfh.h>
 #include <linux/nfsd/nfs4layoutxdr.h>
 
 /* We do our-own dprintk so filesystems are not dependent on sunrpc */
@@ -131,3 +133,86 @@ static int fl_devinfo_xdr_words(const struct pnfs_filelayout_device *fdev)
 	return error;
 }
 EXPORT_SYMBOL(filelayout_encode_devinfo);
+
+/* Encodes the loc_body structure from draft 13
+ * on the response stream.
+ * Use linux error codes (not nfs) since these values are being
+ * returned to the file system.
+ */
+enum nfsstat4
+filelayout_encode_layout(struct exp_xdr_stream *xdr,
+			 const struct pnfs_filelayout_layout *flp)
+{
+	u32 len = 0, nfl_util, fhlen, i;
+	u32 *layoutlen_p;
+	enum nfsstat4 nfserr;
+	__be32 *p;
+
+	dprintk("%s: device_id %llx:%llx fsi %u, numfh %u\n",
+		__func__,
+		flp->device_id.pnfs_fsid,
+		flp->device_id.pnfs_devid,
+		flp->lg_first_stripe_index,
+		flp->lg_fh_length);
+
+	/* Ensure file system added at least one file handle */
+	if (flp->lg_fh_length <= 0) {
+		dprintk("%s: File Layout has no file handles!!\n", __func__);
+		nfserr = NFS4ERR_LAYOUTUNAVAILABLE;
+		goto out;
+	}
+
+	/* Ensure room for len, devid, util, first_stripe_index,
+	 * pattern_offset, number of filehandles */
+	p = layoutlen_p = exp_xdr_reserve_qwords(xdr, 1+2+2+1+1+2+1);
+	if (!p) {
+		nfserr = NFS4ERR_TOOSMALL;
+		goto out;
+	}
+
+	/* save spot for opaque file layout length, fill-in later*/
+	p++;
+
+	/* encode device id */
+	p = exp_xdr_encode_u64(p, flp->device_id.sbid);
+	p = exp_xdr_encode_u64(p, flp->device_id.devid);
+
+	/* set and encode flags */
+	nfl_util = flp->lg_stripe_unit;
+	if (flp->lg_commit_through_mds)
+		nfl_util |= NFL4_UFLG_COMMIT_THRU_MDS;
+	if (flp->lg_stripe_type == STRIPE_DENSE)
+		nfl_util |= NFL4_UFLG_DENSE;
+	p = exp_xdr_encode_u32(p, nfl_util);
+
+	/* encode first stripe index */
+	p = exp_xdr_encode_u32(p, flp->lg_first_stripe_index);
+
+	/* encode striping pattern start */
+	p = exp_xdr_encode_u64(p, flp->lg_pattern_offset);
+
+	/* encode number of file handles */
+	p = exp_xdr_encode_u32(p, flp->lg_fh_length);
+
+	/* encode file handles */
+	for (i = 0; i < flp->lg_fh_length; i++) {
+		fhlen = flp->lg_fh_list[i].fh_size;
+		p = exp_xdr_reserve_space(xdr, 4 + fhlen);
+		if (!p) {
+			nfserr = NFS4ERR_TOOSMALL;
+			goto out;
+		}
+		p = exp_xdr_encode_opaque(p, &flp->lg_fh_list[i].fh_base, fhlen);
+	}
+
+	/* Set number of bytes encoded =  total_bytes_encoded - length var */
+	len = (char *)p - (char *)layoutlen_p;
+	exp_xdr_encode_u32(layoutlen_p, len - 4);
+
+	nfserr = NFS4_OK;
+out:
+	dprintk("%s: End err %u xdrlen %d\n",
+		__func__, nfserr, len);
+	return nfserr;
+}
+EXPORT_SYMBOL(filelayout_encode_layout);
diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
index 017f1753..8e8b6a7 100644
--- a/include/linux/exportfs.h
+++ b/include/linux/exportfs.h
@@ -218,7 +218,7 @@ extern struct dentry *generic_fh_to_parent(struct super_block *sb,
 
 extern int filelayout_encode_devinfo(struct exp_xdr_stream *xdr,
 				     const struct pnfs_filelayout_device *fdev);
-extern int filelayout_encode_layout(struct exp_xdr_stream *xdr,
-				    const struct pnfs_filelayout_layout *flp);
+extern enum nfsstat4 filelayout_encode_layout(struct exp_xdr_stream *xdr,
+				      const struct pnfs_filelayout_layout *flp);
 #endif /* defined(CONFIG_EXPORTFS_FILE_LAYOUT) */
 #endif /* LINUX_EXPORTFS_H */
diff --git a/include/linux/nfsd/nfs4layoutxdr.h b/include/linux/nfsd/nfs4layoutxdr.h
index 752055f..dc7831a 100644
--- a/include/linux/nfsd/nfs4layoutxdr.h
+++ b/include/linux/nfsd/nfs4layoutxdr.h
@@ -35,6 +35,7 @@
 #define NFSD_NFS4LAYOUTXDR_H
 
 #include <linux/sunrpc/xdr.h>
+#include <linux/nfsd/nfsd4_pnfs.h>
 
 /* the nfsd4_pnfs_devlist dev_addr for the file layout type */
 struct pnfs_filelayout_devaddr {
@@ -55,4 +56,21 @@ struct pnfs_filelayout_device {
 	struct pnfs_filelayout_multipath	*fl_device_list;
 };
 
+struct pnfs_filelayout_layout {
+	u32                             lg_layout_type; /* response */
+	u32                             lg_stripe_type; /* response */
+	u32                             lg_commit_through_mds; /* response */
+	u64                             lg_stripe_unit; /* response */
+	u64                             lg_pattern_offset; /* response */
+	u32                             lg_first_stripe_index;	/* response */
+	struct nfsd4_pnfs_deviceid	device_id;		/* response */
+	u32                             lg_fh_length;		/* response */
+	struct knfsd_fh                 *lg_fh_list;		/* response */
+};
+
+enum stripetype4 {
+	STRIPE_SPARSE = 1,
+	STRIPE_DENSE = 2
+};
+
 #endif /* NFSD_NFS4LAYOUTXDR_H */
-- 
1.8.3.1

