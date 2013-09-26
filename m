Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f41.google.com ([209.85.216.41]:58561 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab3IZSm3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:42:29 -0400
Received: by mail-qa0-f41.google.com with SMTP id ii20so4643317qab.14
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:42:29 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 38/49] pnfsd: nfsd4_pnfs_dlm_layoutget
Date: Thu, 26 Sep 2013 14:42:26 -0400
Message-Id: <1380220946-14439-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Export nfsd4_pnfs_dlm_layoutget for dlm cluster file system use.

Use the number of data servers as a hash mask and hash inode i_ino
to choose the layout's first_stripe_index.

Always give out whole file layouts.

Always give out IOMODE_READ layouts. DLM locking semantics want to stripe
only READs with WRITEs going through the MDS.

[was pnfsd: hardwire DLM file layout layoutget]
[was pnfs-gfs2: initial LAYOUT* work for pNFS/GFS2 integration]
    Frank Filz's work on the layout_type() and layout_get() export operations,
    with stubs for layout_commit() and layout_return().  Tested at Connectathon.
Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
Signed-off-by: David M. Richter <richterd@citi.umich.edu>
[pnfs-gfs2: convert to using new pnfs export api]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: gfs2 layout_type interface]
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
[Since GFS2 only uses a stripe of one, changed lg_commit_through_mds from
 true to false.]
[pnfsd: move and rename nfsd4_pnfs_fl_layoutget]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: get rid of layout encoding function vector]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Acked-by: Steven Whitehouse <swhiteho@redhat.com>
[pnfsd: rename deviceid_t struct pnfs_deviceid]
[pnfsd: clean up layoutget export API]
[add requried headers]
[pnfsd: rename device fsid member to sbid]
[pnfsd: fixup DLM layout_get return type to u32]
[pnfsd: DLM file layout return only nfs errors on layout_get]
[pnfsd: files layout: change layout_get return type to enum nfsstat4]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: fix DLM file layout no device return]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: dlm: fixup LAYOUT_NFSV4_1_FILES]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsdlm.c | 92 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 92 insertions(+)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index 4c2ab87..7ed8156 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -28,6 +28,7 @@
 #include <linux/nfsd/nfs4layoutxdr.h>
 #include <linux/sunrpc/addr.h>
 
+#include "nfsfh.h"
 #include "nfsd.h"
 
 #define NFSDDBG_FACILITY                NFSDDBG_FILELAYOUT
@@ -351,9 +352,100 @@ static int nfsd4_pnfs_dlm_getdevinfo(struct super_block *sb,
 	return err;
 }
 
+static int get_stripe_unit(int blocksize)
+{
+	if (blocksize >= NFSSVC_MAXBLKSIZE)
+		return blocksize;
+	return NFSSVC_MAXBLKSIZE - (NFSSVC_MAXBLKSIZE % blocksize);
+}
+
+/*
+ * Look up inode block device in pnfs_dlm_device list.
+ * Hash on the inode->i_ino and number of data servers.
+ */
+static int dlm_ino_hash(struct inode *ino)
+{
+	struct dlm_device_entry *de;
+	u32 hash_mask = 0;
+
+	/* If can't find the inode block device in the pnfs_dlm_deivce list
+	 * then don't hand out a layout
+	 */
+	de = nfsd4_find_pnfs_dlm_device(ino->i_sb);
+	if (!de)
+		return -1;
+	hash_mask = de->num_ds - 1;
+	return ino->i_ino & hash_mask;
+}
+
+static enum nfsstat4 nfsd4_pnfs_dlm_layoutget(struct inode *inode,
+			   struct exp_xdr_stream *xdr,
+			   const struct nfsd4_pnfs_layoutget_arg *args,
+			   struct nfsd4_pnfs_layoutget_res *res)
+{
+	struct pnfs_filelayout_layout *layout = NULL;
+	struct knfsd_fh *fhp = NULL;
+	int index;
+	enum nfsstat4 rc = NFS4_OK;
+
+	dprintk("%s: LAYOUT_GET\n", __func__);
+
+	index = dlm_ino_hash(inode);
+	dprintk("%s first stripe index %d i_ino %lu\n", __func__, index,
+		inode->i_ino);
+	if (index < 0)
+		return NFS4ERR_LAYOUTUNAVAILABLE;
+
+	res->lg_seg.layout_type = LAYOUT_NFSV4_1_FILES;
+	/* Always give out whole file layouts */
+	res->lg_seg.offset = 0;
+	res->lg_seg.length = NFS4_MAX_UINT64;
+	/* Always give out READ ONLY layouts */
+	res->lg_seg.iomode = IOMODE_READ;
+
+	layout = kzalloc(sizeof(*layout), GFP_KERNEL);
+	if (layout == NULL) {
+		rc = NFS4ERR_LAYOUTTRYLATER;
+		goto error;
+	}
+
+	/* Set file layout response args */
+	layout->lg_layout_type = LAYOUT_NFSV4_1_FILES;
+	layout->lg_stripe_type = STRIPE_SPARSE;
+	layout->lg_commit_through_mds = false;
+	layout->lg_stripe_unit = get_stripe_unit(inode->i_sb->s_blocksize);
+	layout->lg_fh_length = 1;
+	layout->device_id.sbid = args->lg_sbid;
+	layout->device_id.devid = 1;                                /*FSFTEMP*/
+	layout->lg_first_stripe_index = index;                      /*FSFTEMP*/
+	layout->lg_pattern_offset = 0;
+
+	fhp = kmalloc(sizeof(*fhp), GFP_KERNEL);
+	if (fhp == NULL) {
+		rc = NFS4ERR_LAYOUTTRYLATER;
+		goto error;
+	}
+
+	memcpy(fhp, args->lg_fh, sizeof(*fhp));
+	pnfs_fh_mark_ds(fhp);
+	layout->lg_fh_list = fhp;
+
+	/* Call nfsd to encode layout */
+	rc = filelayout_encode_layout(xdr, layout);
+exit:
+	kfree(layout);
+	kfree(fhp);
+	return rc;
+
+error:
+	res->lg_seg.length = 0;
+	goto exit;
+}
+
 /* For use by DLM cluster file systems exported by pNFSD */
 const struct pnfs_export_operations pnfs_dlm_export_ops = {
 	.get_device_info = nfsd4_pnfs_dlm_getdevinfo,
 	.get_device_iter = nfsd4_pnfs_dlm_getdeviter,
+	.layout_get = nfsd4_pnfs_dlm_layoutget,
 };
 EXPORT_SYMBOL(pnfs_dlm_export_ops);
-- 
1.8.3.1

