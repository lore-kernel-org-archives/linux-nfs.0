From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 22/35] pnfsd: support layout_type attribute
Date: Mon,  7 Dec 2009 11:34:41 +0200
Message-ID: <1260178481-15692-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>,
	Marc Eshel <eshel@almaden.ibm.com>,
	Andy Adamson <andros@netapp.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Provide for getting the (read-only) layout_type attribute

[extraced from pnfsd: Initial pNFS server implementation.]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: Add super block to layout_type()]
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
[pnfsd: convert generic code to use new pnfs api]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[Remove the use of struct pnfs_export_operations.]
[pnfsd: support layout_type attribute all layout types]
[pnfsd: check ex_pnfs in nfsd4_verify_layout]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: handle s_pnfs_op==NULL]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4xdr.c |   24 ++++++++++++++++++++++++
 fs/nfsd/nfsd.h    |    5 +++++
 2 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2760564..40c794a 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2196,6 +2196,30 @@ out_acl:
 		}
 		WRITE64(stat.ino);
 	}
+#if defined(CONFIG_PNFSD)
+	if (bmval1 & FATTR4_WORD1_FS_LAYOUT_TYPES) {
+		struct super_block *sb = dentry->d_inode->i_sb;
+		int type = 0;
+
+		/* Query the filesystem for supported pNFS layout types.
+		 * Currently, we only support one layout type per file system.
+		 * The export_ops->layout_type() returns the pnfs_layouttype4.
+		 */
+		buflen -= 4;
+		if (buflen < 0)		/* length */
+			goto out_resource;
+
+		if (sb && sb->s_pnfs_op)
+			type = sb->s_pnfs_op->layout_type(sb);
+		if (type) {
+			if ((buflen -= 4) < 0)	/* type */
+				goto out_resource;
+			WRITE32(1); 	/* length */
+			WRITE32(type);  /* type */
+		} else
+			WRITE32(0);  /* length */
+	}
+#endif /* CONFIG_PNFSD */
 	if (bmval2 & FATTR4_WORD2_SUPPATTR_EXCLCREAT) {
 		WRITE32(3);
 		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD0);
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index ac121ad..a402854 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -287,8 +287,13 @@ extern struct timeval	nfssvc_boot;
 #define NFSD4_1_SUPPORTED_ATTRS_WORD0 \
 	NFSD4_SUPPORTED_ATTRS_WORD0
 
+#if defined(CONFIG_PNFSD)
+#define NFSD4_1_SUPPORTED_ATTRS_WORD1 \
+	(NFSD4_SUPPORTED_ATTRS_WORD1 | FATTR4_WORD1_FS_LAYOUT_TYPES)
+#else /* CONFIG_PNFSD */
 #define NFSD4_1_SUPPORTED_ATTRS_WORD1 \
 	NFSD4_SUPPORTED_ATTRS_WORD1
+#endif /* CONFIG_PNFSD */
 
 #define NFSD4_1_SUPPORTED_ATTRS_WORD2 \
 	(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT)
-- 
1.6.5.1

