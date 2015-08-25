Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33352 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932416AbbHYPfc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 11:35:32 -0400
Received: by pacti10 with SMTP id ti10so54532074pac.0
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 08:35:31 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>, bfields@fieldses.org,
        Jeff Layton <jeff.layton@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH RFC 08/11] nfs: get clone_blksize when probing fsinfo
Date: Tue, 25 Aug 2015 23:33:46 +0800
Message-Id: <1440516829-116041-9-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
References: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv42 CLONE operation is supposed to respect it.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/client.c           |  1 +
 fs/nfs/nfs4proc.c         |  1 +
 fs/nfs/nfs4xdr.c          | 25 +++++++++++++++++++++++++
 include/linux/nfs4.h      |  1 +
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   |  1 +
 6 files changed, 30 insertions(+)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 57c5a02..d6d5d2a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -764,6 +764,7 @@ static void nfs_server_set_fsinfo(struct nfs_server *server,
 
 	server->time_delta = fsinfo->time_delta;
 
+	server->clone_blksize = fsinfo->clone_blksize;
 	/* We're airborne Set socket buffersize */
 	rpc_setbufsize(server->client, server->wsize + 100, server->rsize + 100);
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index fb51b75..ecf792c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -239,6 +239,7 @@ const u32 nfs4_fsinfo_bitmap[3] = { FATTR4_WORD0_MAXFILESIZE
 			FATTR4_WORD1_TIME_DELTA
 			| FATTR4_WORD1_FS_LAYOUT_TYPES,
 			FATTR4_WORD2_LAYOUT_BLKSIZE
+			| FATTR4_WORD2_CLONE_BLKSIZE
 };
 
 const u32 nfs4_fs_locations_bitmap[3] = {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index a453bd1..f0dce533 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4737,6 +4737,28 @@ static int decode_attr_layout_blksize(struct xdr_stream *xdr, uint32_t *bitmap,
 	return 0;
 }
 
+/*
+ * The granularity of a CLONE operation.
+ */
+static int decode_attr_clone_blksize(struct xdr_stream *xdr, uint32_t *bitmap,
+				     uint32_t *res)
+{
+	__be32 *p;
+
+	dprintk("%s: bitmap is %x\n", __func__, bitmap[2]);
+	*res = 0;
+	if (bitmap[2] & FATTR4_WORD2_CLONE_BLKSIZE) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p)) {
+			print_overflow_msg(__func__, xdr);
+			return -EIO;
+		}
+		*res = be32_to_cpup(p);
+		bitmap[2] &= ~FATTR4_WORD2_CLONE_BLKSIZE;
+	}
+	return 0;
+}
+
 static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 {
 	unsigned int savep;
@@ -4771,6 +4793,9 @@ static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 	status = decode_attr_layout_blksize(xdr, bitmap, &fsinfo->blksize);
 	if (status)
 		goto xdr_error;
+	status = decode_attr_clone_blksize(xdr, bitmap, &fsinfo->clone_blksize);
+	if (status)
+		goto xdr_error;
 
 	status = verify_attr_len(xdr, savep, attrlen);
 xdr_error:
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index c0c695b..e7e7853 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -422,6 +422,7 @@ enum lock_type4 {
 #define FATTR4_WORD2_LAYOUT_TYPES       (1UL << 0)
 #define FATTR4_WORD2_LAYOUT_BLKSIZE     (1UL << 1)
 #define FATTR4_WORD2_MDSTHRESHOLD       (1UL << 4)
+#define FATTR4_WORD2_CLONE_BLKSIZE	(1UL << 13)
 #define FATTR4_WORD2_SECURITY_LABEL     (1UL << 16)
 
 /* MDS threshold bitmap bits */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 2fb163a..db00311 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -147,6 +147,7 @@ struct nfs_server {
 	unsigned int		acdirmax;
 	unsigned int		namelen;
 	unsigned int		options;	/* extra options enabled by mount */
+	unsigned int		clone_blksize;	/* granularity of a CLONE operation */
 #define NFS_OPTION_FSCACHE	0x00000001	/* - local caching enabled */
 #define NFS_OPTION_MIGRATION	0x00000002	/* - NFSv4 migration enabled */
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 79918d6..e89dafd 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -141,6 +141,7 @@ struct nfs_fsinfo {
 	__u32			lease_time; /* in seconds */
 	__u32			layouttype; /* supported pnfs layout driver */
 	__u32			blksize; /* preferred pnfs io block size */
+	__u32			clone_blksize; /* granularity of a CLONE operation */
 };
 
 struct nfs_fsstat {
-- 
1.8.3.1

