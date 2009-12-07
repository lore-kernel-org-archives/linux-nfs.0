From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 27/35] pnfsd: nfsd4_pnfs_dlm_layoutget
Date: Mon,  7 Dec 2009 11:35:47 +0200
Message-ID: <1260178547-15878-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Frank Filz <ffilzlnx@us.ibm.com>,
	"David M. Richter" <richterd@citi.umich.edu>,
	Benny Halevy <bhalevy@panasas.com>,
	Marc Eshel <eshel@almaden.ibm.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:52329 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934911AbZLGJev (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 04:34:51 -0500
In-Reply-To: <4B1CCA52.8020900@panasas.com>
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
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4pnfsdlm.c |   89 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 89 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index 5ed542f..db3ae1d 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -289,3 +289,92 @@ out:
 	dprintk("<-- %s returns %d\n", __func__, err);
 	return err;
 }
+
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
+	de = nfsd4_find_pnfs_dlm_device(ino->i_sb->s_bdev->bd_disk->disk_name);
+	if (!de)
+		return -EINVAL;
+	hash_mask = de->num_ds - 1;
+	return ino->i_ino & hash_mask;
+}
+
+static int nfsd4_pnfs_dlm_layoutget(struct inode *inode,
+			   struct exp_xdr_stream *xdr,
+			   const struct nfsd4_pnfs_layoutget_arg *args,
+			   struct nfsd4_pnfs_layoutget_res *res)
+{
+	struct pnfs_filelayout_layout *layout = NULL;
+	struct knfsd_fh *fhp = NULL;
+	int rc = 0, index;
+
+	dprintk("%s: LAYOUT_GET\n", __func__);
+
+	index = dlm_ino_hash(inode);
+	dprintk("%s first stripe index %d i_ino %lu\n", __func__, index,
+		inode->i_ino);
+	if (index < 0)
+		return index;
+
+	res->lg_seg.layout_type = LAYOUT_NFSV4_FILES;
+	/* Always give out whole file layouts */
+	res->lg_seg.offset = 0;
+	res->lg_seg.length = NFS4_MAX_UINT64;
+	/* Always give out READ ONLY layouts */
+	res->lg_seg.iomode = IOMODE_READ;
+
+	layout = kzalloc(sizeof(*layout), GFP_KERNEL);
+	if (layout == NULL) {
+		rc = -ENOMEM;
+		goto error;
+	}
+
+	/* Set file layout response args */
+	layout->lg_layout_type = LAYOUT_NFSV4_FILES;
+	layout->lg_stripe_type = STRIPE_SPARSE;
+	layout->lg_commit_through_mds = false;
+	layout->lg_stripe_unit = get_stripe_unit(inode->i_sb->s_blocksize);
+	layout->lg_fh_length = 1;
+	layout->device_id.fsid = args->lg_fsid;
+	layout->device_id.devid = 1;                                /*FSFTEMP*/
+	layout->lg_first_stripe_index = index;                      /*FSFTEMP*/
+	layout->lg_pattern_offset = 0;
+
+	fhp = kmalloc(sizeof(*fhp), GFP_KERNEL);
+	if (fhp == NULL) {
+		rc = -ENOMEM;
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
-- 
1.6.5.1

