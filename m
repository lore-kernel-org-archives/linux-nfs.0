From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 29/35] pnfsd: dlm pnfs_export_operations
Date: Mon,  7 Dec 2009 11:36:13 +0200
Message-ID: <1260178573-15949-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Declare a global pnfs_export_operations struct for use with DLM cluster
file systems who wish to be exported by pnfs.

Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: define dlm export ops for the !CONFIG_PNFSD case]
[gfs2: set pnfs_dlm_export_ops only for CONFIG_PNFSD]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Acked-by: Steven Whitehouse <swhiteho@redhat.com>
---
 fs/nfsd/nfs4pnfsdlm.c            |    9 +++++++++
 include/linux/nfsd/nfs4pnfsdlm.h |    3 +++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index 162afaf..ccab22f 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -384,3 +384,12 @@ nfsd4_pnfs_dlm_layouttype(struct super_block *sb)
 {
 	return LAYOUT_NFSV4_FILES;
 }
+
+/* For use by DLM cluster file systems exported by pNFSD */
+const struct pnfs_export_operations pnfs_dlm_export_ops = {
+	.layout_type = nfsd4_pnfs_dlm_layouttype,
+	.get_device_info = nfsd4_pnfs_dlm_getdevinfo,
+	.get_device_iter = nfsd4_pnfs_dlm_getdeviter,
+	.layout_get = nfsd4_pnfs_dlm_layoutget,
+};
+EXPORT_SYMBOL(pnfs_dlm_export_ops);
diff --git a/include/linux/nfsd/nfs4pnfsdlm.h b/include/linux/nfsd/nfs4pnfsdlm.h
index 63248aa..a961c1e 100644
--- a/include/linux/nfsd/nfs4pnfsdlm.h
+++ b/include/linux/nfsd/nfs4pnfsdlm.h
@@ -35,6 +35,9 @@
 
 #ifdef CONFIG_PNFSD
 
+/* For use by DLM cluster file systems exported by pNFSD */
+extern const struct pnfs_export_operations pnfs_dlm_export_ops;
+
 int nfsd4_set_pnfs_dlm_device(char *pnfs_dlm_device, int len);
 
 void nfsd4_pnfs_dlm_shutdown(void);
-- 
1.6.5.1

