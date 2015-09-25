Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35515 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753313AbbIYK0Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Sep 2015 06:26:16 -0400
Received: by pacfv12 with SMTP id fv12so104360236pac.2
        for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2015 03:26:15 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 4/6] nfs: get clone_blksize when probing fsinfo
Date: Sat, 26 Sep 2015 02:24:37 +0800
Message-Id: <1443205479-13563-5-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1443205479-13563-1-git-send-email-tao.peng@primarydata.com>
References: <1443205479-13563-1-git-send-email-tao.peng@primarydata.com>
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
index 3eca973..e7c3e37 100644
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
index 868472b..9f65679 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4764,6 +4764,28 @@ static int decode_attr_layout_blksize(struct xdr_stream *xdr, uint32_t *bitmap,
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
@@ -4798,6 +4820,9 @@ static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
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
index a50de10..2469ab0 100644
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
index ac678b7..92ff445 100644
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

