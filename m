Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f53.google.com ([209.85.128.53]:39026 "EHLO
	mail-qe0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab3IZSlw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:41:52 -0400
Received: by mail-qe0-f53.google.com with SMTP id jy17so1106331qeb.26
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:41:52 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 29/49] pnfsd: support layout_type attribute
Date: Thu, 26 Sep 2013 14:41:48 -0400
Message-Id: <1380220908-14009-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

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
[pnfsd: test layout_type method in nfsd4_encode_fattr]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4xdr.c | 24 ++++++++++++++++++++++++
 fs/nfsd/nfsd.h    |  5 +++++
 2 files changed, 29 insertions(+)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index b9c4417..83f7147 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2560,6 +2560,30 @@ static int get_parent_attributes(struct svc_export *exp, struct kstat *stat)
 			get_parent_attributes(exp, &stat);
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
+		if (sb && sb->s_pnfs_op && sb->s_pnfs_op->layout_type)
+			type = sb->s_pnfs_op->layout_type(sb);
+		if (type) {
+			if ((buflen -= 4) < 0)	/* type */
+				goto out_resource;
+			WRITE32(1);	/* length */
+			WRITE32(type);  /* type */
+		} else
+			WRITE32(0);  /* length */
+	}
+#endif /* CONFIG_PNFSD */
 	if (bmval2 & FATTR4_WORD2_SECURITY_LABEL) {
 		status = nfsd4_encode_security_label(rqstp, context,
 				contextlen, &p, &buflen);
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 30f34ab..f49fb0b 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -321,8 +321,13 @@ static inline void nfs4_reset_lease(time_t leasetime) { }
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
1.8.3.1

