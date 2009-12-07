From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 09/35] pnfsd: layout verify
Date: Mon,  7 Dec 2009 11:31:43 +0200
Message-ID: <1260178303-14957-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>,
	Dean Hildebrand <seattleplus@gmail.com>,
	Marc Eshel <eshel@almaden.ibm.com>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Andy Adamson <andros@netapp.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Verify whether the server and file system support the given layout type.

[was pnfsd: Streamline error code checking for non-pnfs filesystems]
Signed-off-by: Dean Hildebrand <seattleplus@gmail.com>
[pnfsd: Add super block to layout_type()]
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
[pnfsd: Fix order of ops in nfsd4_layout_verify]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
[pnfsd: convert generic code to use new pnfs api]
[pnfsd: define pnfs_export_operations]
[pnfsd: obliterate old vfs api]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: layout verify all layout types]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: tone nfsd4_layout_verify printk down to dprintk]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: check ex_pnfs in nfsd4_verify_layout]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: handle s_pnfs_op==NULL]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/export.c                |    6 ++++++
 fs/nfsd/nfs4proc.c              |   34 ++++++++++++++++++++++++++++++++++
 fs/nfsd/pnfsd.h                 |    2 ++
 include/linux/nfsd/nfsd4_pnfs.h |    3 ++-
 4 files changed, 44 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index ca745cc..7c3fa87 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -397,6 +397,12 @@ static int check_export(struct inode *inode, int flags, unsigned char *uuid,
 		return 0;
 	}
 
+	if (inode->i_sb->s_pnfs_op &&
+	    !inode->i_sb->s_pnfs_op->layout_type) {
+		dprintk("exp_export: export of invalid fs pnfs export ops.\n");
+		return -EINVAL;
+	}
+
 	return 0;
 
 }
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e2b5666..4c78642 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -39,6 +39,7 @@
 #include "cache.h"
 #include "xdr4.h"
 #include "vfs.h"
+#include "pnfsd.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
@@ -936,6 +937,39 @@ nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return status == nfserr_same ? nfs_ok : status;
 }
 
+#if defined(CONFIG_PNFSD)
+static __be32
+nfsd4_layout_verify(struct super_block *sb, struct svc_export *exp,
+		    unsigned int layout_type)
+{
+	int status, type;
+
+	/* check to see if pNFS  is supported. */
+	status = nfserr_layoutunavailable;
+	if (exp->ex_pnfs == 0 || !sb->s_pnfs_op || !sb->s_pnfs_op->layout_type) {
+		dprintk("%s: Underlying file system "
+			"does not support pNFS\n", __func__);
+		goto out;
+	}
+
+	type = sb->s_pnfs_op->layout_type(sb);
+
+	/* check to see if requested layout type is supported. */
+	status = nfserr_unknown_layouttype;
+	if (!type)
+		dprintk("BUG: %s: layout_type 0 is reserved and must not be "
+			"used by filesystem\n", __func__);
+	else if (type != layout_type)
+		dprintk("%s: requested layout type %d "
+		       "does not match supported type %d\n",
+			__func__, layout_type, type);
+	else
+		status = nfs_ok;
+out:
+	return status;
+}
+#endif /* CONFIG_PNFSD */
+
 /*
  * NULL call.
  */
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 65fb57e..7c46791 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -34,4 +34,6 @@
 #ifndef LINUX_NFSD_PNFSD_H
 #define LINUX_NFSD_PNFSD_H
 
+#include <linux/nfsd/nfsd4_pnfs.h>
+
 #endif /* LINUX_NFSD_PNFSD_H */
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index ff6613e..c44e13d 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -45,7 +45,8 @@
  * All other methods are optional and can be set to NULL if not implemented.
  */
 struct pnfs_export_operations {
-	/* stub */
+	/* Returns the supported pnfs_layouttype4. */
+	int (*layout_type) (struct super_block *);
 };
 
 #endif /* _LINUX_NFSD_NFSD4_PNFS_H */
-- 
1.6.5.1

