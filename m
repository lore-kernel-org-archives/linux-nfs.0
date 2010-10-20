Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22398 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751128Ab0JTESN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Oct 2010 00:18:13 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 05/12] NFS: ask for layouttypes during v4 fsinfo call
Date: Wed, 20 Oct 2010 00:17:57 -0400
Message-Id: <1287548284-28374-6-git-send-email-iisaman@netapp.com>
In-Reply-To: <1287548284-28374-1-git-send-email-iisaman@netapp.com>
References: <1287548284-28374-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

This information will be used to determine which layout driver,
if any, to use for subsequent IO on this filesystem.  Each driver
is assigned an integer id, with 0 reserved to indicate no driver.

The server can in theory return multiple ids.  However, our current
client implementation only notes the first entry and ignores the
rest.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c       |    2 +-
 fs/nfs/nfs4xdr.c        |   57 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_xdr.h |    1 +
 3 files changed, 59 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 88a9d93..52a486b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -129,7 +129,7 @@ const u32 nfs4_fsinfo_bitmap[2] = { FATTR4_WORD0_MAXFILESIZE
 			| FATTR4_WORD0_MAXREAD
 			| FATTR4_WORD0_MAXWRITE
 			| FATTR4_WORD0_LEASE_TIME,
-			0
+			FATTR4_WORD1_FS_LAYOUT_TYPES
 };
 
 const u32 nfs4_fs_locations_bitmap[2] = {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 6ea5c93..28c2475 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3868,6 +3868,60 @@ xdr_error:
 	return status;
 }
 
+/*
+ * Decode potentially multiple layout types. Currently we only support
+ * one layout driver per file system.
+ */
+static int decode_first_pnfs_layout_type(struct xdr_stream *xdr,
+					 uint32_t *layouttype)
+{
+	uint32_t *p;
+	int num;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	num = be32_to_cpup(p);
+
+	/* pNFS is not supported by the underlying file system */
+	if (num == 0) {
+		*layouttype = 0;
+		return 0;
+	}
+	if (num > 1)
+		printk(KERN_INFO "%s: Warning: Multiple pNFS layout drivers "
+			"per filesystem not supported\n", __func__);
+
+	/* Decode and set first layout type, move xdr->p past unused types */
+	p = xdr_inline_decode(xdr, num * 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	*layouttype = be32_to_cpup(p);
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+/*
+ * The type of file system exported.
+ * Note we must ensure that layouttype is set in any non-error case.
+ */
+static int decode_attr_pnfstype(struct xdr_stream *xdr, uint32_t *bitmap,
+				uint32_t *layouttype)
+{
+	int status = 0;
+
+	dprintk("%s: bitmap is %x\n", __func__, bitmap[1]);
+	if (unlikely(bitmap[1] & (FATTR4_WORD1_FS_LAYOUT_TYPES - 1U)))
+		return -EIO;
+	if (bitmap[1] & FATTR4_WORD1_FS_LAYOUT_TYPES) {
+		status = decode_first_pnfs_layout_type(xdr, layouttype);
+		bitmap[1] &= ~FATTR4_WORD1_FS_LAYOUT_TYPES;
+	} else
+		*layouttype = 0;
+	return status;
+}
 
 static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 {
@@ -3894,6 +3948,9 @@ static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 	if ((status = decode_attr_maxwrite(xdr, bitmap, &fsinfo->wtmax)) != 0)
 		goto xdr_error;
 	fsinfo->wtpref = fsinfo->wtmax;
+	status = decode_attr_pnfstype(xdr, bitmap, &fsinfo->layouttype);
+	if (status)
+		goto xdr_error;
 
 	status = verify_attr_len(xdr, savep, attrlen);
 xdr_error:
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 5772b2c..d89920c 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -113,6 +113,7 @@ struct nfs_fsinfo {
 	__u32			dtpref;	/* pref. readdir transfer size */
 	__u64			maxfilesize;
 	__u32			lease_time; /* in seconds */
+	__u32			layouttype; /* supported pnfs layout driver */
 };
 
 struct nfs_fsstat {
-- 
1.7.2.1

