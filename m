Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f54.google.com ([209.85.216.54]:37708 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab3IZSmQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:42:16 -0400
Received: by mail-qa0-f54.google.com with SMTP id bv4so1092824qab.6
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:42:15 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 35/49] pnfsd: nfsd4_pnfs_dlm_getdeviter
Date: Thu, 26 Sep 2013 14:42:12 -0400
Message-Id: <1380220932-14302-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Export nfsd4_pnfs_dlm_getdeviter for dlm cluster file system use.

[was pnfsd: hardwire DLM cluster file layout get device iterator]
Signed-off-by: David M. Richter <richterd@citi.umich.edu>
Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
[pnfs-gfs2: return correct error value in GETDEVICEINFO]
Signed-off-by: David M. Richter <richterd@citi.umich.edu>
[Use the GFS2 iterator as the default file layout iterator.]
Signed-off-by: Andy Adamson <andros@netapp.com>
[Add the pnfsd default file layout getdevice info]
Signed-off-by: David M. Richter <richterd@citi.umich.edu>
Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
[pnfs-gfs2: return correct error value in GETDEVICEINFO]
Signed-off-by: David M. Richter <richterd@citi.umich.edu>
[pnfsd: move and rename nfsd4_pnfs_fl_getdeviter]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Acked-by: Steven Whitehouse <swhiteho@redhat.com>
[pnfsd: dev_iter: clean up export API]
[pnfsd: dlm: fixup LAYOUT_NFSV4_1_FILES]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsdlm.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index ddc2188..0a14f06 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -21,8 +21,11 @@
  *
  ******************************************************************************/
 
+#include <linux/nfs4.h>
+#include <linux/export.h>
 #include <linux/nfsd/debug.h>
 #include <linux/nfsd/nfs4pnfsdlm.h>
+#include <linux/nfsd/nfs4layoutxdr.h>
 #include <linux/sunrpc/addr.h>
 
 #define NFSDDBG_FACILITY                NFSDDBG_FILELAYOUT
@@ -180,3 +183,29 @@ void nfsd4_pnfs_dlm_shutdown(void)
 	}
 	spin_unlock(&dlm_device_list_lock);
 }
+
+static int nfsd4_pnfs_dlm_getdeviter(struct super_block *sb,
+				     u32 layout_type,
+				     struct nfsd4_pnfs_dev_iter_res *res)
+{
+	if (layout_type != LAYOUT_NFSV4_1_FILES) {
+		printk(KERN_ERR "%s: ERROR: layout type isn't 'file' "
+			"(type: %x)\n", __func__, layout_type);
+		return -ENOTSUPP;
+	}
+
+	res->gd_eof = 1;
+	if (res->gd_cookie)
+		return -ENOENT;
+
+	res->gd_cookie = 1;
+	res->gd_verf = 1;
+	res->gd_devid = 1;
+	return 0;
+}
+
+/* For use by DLM cluster file systems exported by pNFSD */
+const struct pnfs_export_operations pnfs_dlm_export_ops = {
+	.get_device_iter = nfsd4_pnfs_dlm_getdeviter,
+};
+EXPORT_SYMBOL(pnfs_dlm_export_ops);
-- 
1.8.3.1

