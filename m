Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:47312 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab3IZSmV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:42:21 -0400
Received: by mail-qc0-f171.google.com with SMTP id x19so1032854qcw.16
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:42:21 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 36/49] pnfsd: nfsd4_pnfs_dlm_getdevinfo
Date: Thu, 26 Sep 2013 14:42:16 -0400
Message-Id: <1380220936-14346-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Export nfsd4_pnfs_dlm_getdevinfo for dlm cluster file system use.

Decide whether or not to send tcp or tcp6 in the netid field of GETDEVICEINFO
replies by checking for the presence of a colon in the address.

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
[pnfsd: dlm: fixup LAYOUT_NFSV4_1_FILES]
[pnfsd-files: prevent NULL deref in nfsd4_pnfs_dlm_getdevinfo]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: Correctly set netid to tcp or tcp6 for non-local exports]
Signed-off-by: Michael Groshans <groshans@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[fix bug in DS tcp/tcp6 address string]
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsdlm.c | 110 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 110 insertions(+)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index 0a14f06..19002c1 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -204,8 +204,118 @@ static int nfsd4_pnfs_dlm_getdeviter(struct super_block *sb,
 	return 0;
 }
 
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
+	if (layout_type != LAYOUT_NFSV4_1_FILES) {
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
+		fdev.fl_device_length = 0;
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
+		daddr->r_netid.data = "tcp6";
+		daddr->r_netid.len = strnchr(daddr->r_addr.data, len, ':') ? 4 : 3;
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
+
 /* For use by DLM cluster file systems exported by pNFSD */
 const struct pnfs_export_operations pnfs_dlm_export_ops = {
+	.get_device_info = nfsd4_pnfs_dlm_getdevinfo,
 	.get_device_iter = nfsd4_pnfs_dlm_getdeviter,
 };
 EXPORT_SYMBOL(pnfs_dlm_export_ops);
-- 
1.8.3.1

