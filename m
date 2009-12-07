From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 25/35] pnfsd: nfsd4_pnfs_dlm_getdeviter
Date: Mon,  7 Dec 2009 11:35:20 +0200
Message-ID: <1260178520-15798-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	"David M. Richter" <richterd@citi.umich.edu>,
	Frank Filz <ffilzlnx@us.ibm.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-fsdevel-owner@vger.kernel.org
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
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4pnfsdlm.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index 9d91721..617a2f4 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -23,6 +23,7 @@
 
 #include <linux/nfsd/debug.h>
 #include <linux/nfsd/nfs4pnfsdlm.h>
+#include <linux/nfsd/nfs4layoutxdr.h>
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
@@ -160,3 +161,23 @@ void nfsd4_pnfs_dlm_shutdown(void)
 	}
 	spin_unlock(&dlm_device_list_lock);
 }
+
+static int nfsd4_pnfs_dlm_getdeviter(struct super_block *sb,
+				     u32 layout_type,
+				     struct nfsd4_pnfs_dev_iter_res *res)
+{
+	if (layout_type != LAYOUT_NFSV4_FILES) {
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
-- 
1.6.5.1

