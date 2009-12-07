From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 26/35] pnfsd: nfsd4_pnfs_dlm_getdevinfo
Date: Mon,  7 Dec 2009 11:35:34 +0200
Message-ID: <1260178534-15842-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:41893 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934905AbZLGJeh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 04:34:37 -0500
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Export nfsd4_pnfs_dlm_getdevinfo for dlm cluster file system use.

[was pnfsd: hardwire DLM cluster file layout get device info]
[pnfsd: move and rename nfsd4_pnfs_fl_getdevinfo]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: get rid of devinfo encoding function vector]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: fix pnfs_dlm_device string parsing]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: more fixes for pnfs_dlm_device string parsing]
[pnfsd: filelayout: get rid of getdevinfo notify_types]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Acked-by: Steven Whitehouse <swhiteho@redhat.com>
[pnfsd: rename deviceid_t struct pnfs_deviceid]
[pnfsd: clean up getdeviceinfo export op API]
[pnfsd: getdeviceinfo deviceid needs to be const.]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4pnfsdlm.c |  108 +++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4proc.c    |    1 +
 2 files changed, 109 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index 617a2f4..5ed542f 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -181,3 +181,111 @@ static int nfsd4_pnfs_dlm_getdeviter(struct super_block *sb,
 	res->gd_devid = 1;
 	return 0;
 }
+
+static int nfsd4_pnfs_dlm_getdevinfo(struct super_block *sb,
+				     struct exp_xdr_stream *xdr,
+				     u32 layout_type,
+				     const struct nfsd4_pnfs_deviceid *devid)
+{
+	int err, len, i = 0;
+	struct pnfs_filelayout_device fdev;
+	struct pnfs_filelayout_devaddr *daddr;
+	struct dlm_device_entry *dlm_pdev;
+	char   *bufp;
+
+	err = -ENOTSUPP;
+	if (layout_type != LAYOUT_NFSV4_FILES) {
+		dprintk("%s: ERROR: layout type isn't 'file' "
+			"(type: %x)\n", __func__, layout_type);
+		return err;
+	}
+
+	/* We only hand out a deviceid of 1 in LAYOUTGET, so a GETDEVICEINFO
+	 * with a gdia_device_id != 1 is invalid.
+	 */
+	err = -EINVAL;
+	if (devid->devid != 1) {
+		dprintk("%s: WARNING: didn't receive a deviceid of "
+			"1 (got: 0x%llx)\n", __func__, devid->devid);
+		return err;
+	}
+
+	/*
+	 * If the DS list has not been established, return -EINVAL
+	 */
+	dlm_pdev = nfsd4_find_pnfs_dlm_device(sb->s_bdev->bd_disk->disk_name);
+	if (!dlm_pdev) {
+		dprintk("%s: DEBUG: disk %s Not Found\n", __func__,
+			sb->s_bdev->bd_disk->disk_name);
+		return err;
+	}
+
+	dprintk("%s: Found disk %s with DS list |%s|\n",
+		__func__, dlm_pdev->disk_name, dlm_pdev->ds_list);
+
+	memset(&fdev, '\0', sizeof(fdev));
+	fdev.fl_device_length = dlm_pdev->num_ds;
+
+	err = -ENOMEM;
+	len = sizeof(*fdev.fl_device_list) * fdev.fl_device_length;
+	fdev.fl_device_list = kzalloc(len, GFP_KERNEL);
+	if (!fdev.fl_device_list) {
+		printk(KERN_ERR "%s: ERROR: unable to kmalloc a device list "
+			"buffer for %d DSes.\n", __func__, i);
+		goto out;
+	}
+
+	/* Set a simple stripe indicie */
+	fdev.fl_stripeindices_length = fdev.fl_device_length;
+	fdev.fl_stripeindices_list = kzalloc(sizeof(u32) *
+				     fdev.fl_stripeindices_length, GFP_KERNEL);
+
+	if (!fdev.fl_stripeindices_list) {
+		printk(KERN_ERR "%s: ERROR: unable to kmalloc a stripeindices "
+			"list buffer for %d DSes.\n", __func__, i);
+		goto out;
+	}
+	for (i = 0; i < fdev.fl_stripeindices_length; i++)
+		fdev.fl_stripeindices_list[i] = i;
+
+	/* Transfer the data server list with a single multipath entry */
+	bufp = dlm_pdev->ds_list;
+	for (i = 0; i < fdev.fl_device_length; i++) {
+		daddr = kmalloc(sizeof(*daddr), GFP_KERNEL);
+		if (!daddr) {
+			printk(KERN_ERR "%s: ERROR: unable to kmalloc a device "
+				"addr buffer.\n", __func__);
+			goto out;
+		}
+
+		daddr->r_netid.data = "tcp";
+		daddr->r_netid.len = 3;
+
+		len = strcspn(bufp, ",");
+		daddr->r_addr.data = kmalloc(len + 4, GFP_KERNEL);
+		memcpy(daddr->r_addr.data, bufp, len);
+		/*
+		 * append the port number.  interpreted as two more bytes
+		 * beyond the quad: ".8.1" -> 0x08.0x01 -> 0x0801 = port 2049.
+		 */
+		memcpy(daddr->r_addr.data + len, ".8.1", 4);
+		daddr->r_addr.len = len + 4;
+
+		fdev.fl_device_list[i].fl_multipath_length = 1;
+		fdev.fl_device_list[i].fl_multipath_list = daddr;
+
+		dprintk("%s: encoding DS |%s|\n", __func__, bufp);
+
+		bufp += len + 1;
+	}
+
+	/* have nfsd encode the device info */
+	err = filelayout_encode_devinfo(xdr, &fdev);
+out:
+	for (i = 0; i < fdev.fl_device_length; i++)
+		kfree(fdev.fl_device_list[i].fl_multipath_list);
+	kfree(fdev.fl_device_list);
+	kfree(fdev.fl_stripeindices_list);
+	dprintk("<-- %s returns %d\n", __func__, err);
+	return err;
+}
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index b7e910f..0336037 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -939,6 +939,7 @@ nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 }
 
 #if defined(CONFIG_PNFSD)
+
 static __be32
 nfsd4_layout_verify(struct super_block *sb, struct svc_export *exp,
 		    unsigned int layout_type)
-- 
1.6.5.1

