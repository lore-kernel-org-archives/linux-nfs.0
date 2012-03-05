Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e9.ny.us.ibm.com ([32.97.182.139]:58738 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757617Ab2CEU1F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 15:27:05 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Mon, 5 Mar 2012 15:27:04 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 623C86E804C
	for <linux-nfs@vger.kernel.org>; Mon,  5 Mar 2012 15:27:03 -0500 (EST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q25KR2EV203840
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 15:27:02 -0500
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q25KQuev001947
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 13:26:56 -0700
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: treinish@linux.vnet.ibm.com
Subject: [PATCH/RFC v3 01/10] Add support for FH_EXPIRE_TYPE attribute.
Date: Mon,  5 Mar 2012 15:26:42 -0500
Message-Id: <1330979211-894-2-git-send-email-treinish@linux.vnet.ibm.com>
In-Reply-To: <1330979211-894-1-git-send-email-treinish@linux.vnet.ibm.com>
References: <1330979211-894-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FH_EXPIRE_TYPE is used by the client to determine
what type of file handle the server is providing for a
particular filesystem.

I added the bitmask to fsinfo since the bitmask is
set per filesystem.

Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
---
 fs/nfs/client.c           |    2 ++
 fs/nfs/nfs4proc.c         |    3 ++-
 fs/nfs/nfs4xdr.c          |   27 +++++++++++++++++++++++++++
 include/linux/nfs_fs_sb.h |    1 +
 include/linux/nfs_xdr.h   |    1 +
 5 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8563585..2f96f9d 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -976,6 +976,8 @@ static void nfs_server_set_fsinfo(struct nfs_server *server,
 
 	server->time_delta = fsinfo->time_delta;
 
+	server->fhexpiretype = fsinfo->fhexpiretype;
+
 	/* We're airborne Set socket buffersize */
 	rpc_setbufsize(server->client, server->wsize + 100, server->rsize + 100);
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 87c584d..ca5e3cd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -146,7 +146,8 @@ const u32 nfs4_pathconf_bitmap[2] = {
 const u32 nfs4_fsinfo_bitmap[3] = { FATTR4_WORD0_MAXFILESIZE
 			| FATTR4_WORD0_MAXREAD
 			| FATTR4_WORD0_MAXWRITE
-			| FATTR4_WORD0_LEASE_TIME,
+			| FATTR4_WORD0_LEASE_TIME
+			| FATTR4_WORD0_FH_EXPIRE_TYPE,
 			FATTR4_WORD1_TIME_DELTA
 			| FATTR4_WORD1_FS_LAYOUT_TYPES,
 			FATTR4_WORD2_LAYOUT_BLKSIZE
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index ae78343..7b1f729 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4524,6 +4524,30 @@ static int decode_attr_layout_blksize(struct xdr_stream *xdr, uint32_t *bitmap,
 	return 0;
 }
 
+/*
+ * The VFH expire type bitmask
+ */
+
+static int decode_attr_fh_expire_type(struct xdr_stream *xdr, uint32_t *bitmap,
+					uint32_t *res)
+{
+	__be32 *p;
+
+	dprintk("%s: bitmap %x\n", __func__, bitmap[0]);
+	*res = 0;
+	if (bitmap[0] & FATTR4_WORD0_FH_EXPIRE_TYPE) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p)) {
+			print_overflow_msg(__func__, xdr);
+			return -EIO;
+		}
+		*res = be32_to_cpup(p);
+		bitmap[0] &= ~FATTR4_WORD0_FH_EXPIRE_TYPE;
+	}
+	return 0;
+
+}
+
 static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 {
 	__be32 *savep;
@@ -4539,6 +4563,9 @@ static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 
 	fsinfo->rtmult = fsinfo->wtmult = 512;	/* ??? */
 
+	if ((status = decode_attr_fh_expire_type(xdr, bitmap, &fsinfo->fhexpiretype)) != 0)
+		goto xdr_error;
+
 	if ((status = decode_attr_lease_time(xdr, bitmap, &fsinfo->lease_time)) != 0)
 		goto xdr_error;
 	if ((status = decode_attr_maxfilesize(xdr, bitmap, &fsinfo->maxfilesize)) != 0)
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 3bf4766..15a2056 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -114,6 +114,7 @@ struct nfs_server {
 	unsigned int		dtsize;		/* readdir size */
 	unsigned short		port;		/* "port=" setting */
 	unsigned int		bsize;		/* server block size */
+	unsigned int		fhexpiretype;   /* VFH attributes */
 	unsigned int		acregmin;	/* attr cache timeouts */
 	unsigned int		acregmax;
 	unsigned int		acdirmin;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index adbc84a..b96f8d3 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -131,6 +131,7 @@ struct nfs_fsinfo {
 	__u32			lease_time; /* in seconds */
 	__u32			layouttype; /* supported pnfs layout driver */
 	__u32			blksize; /* preferred pnfs io block size */
+	__u32			fhexpiretype; /* VFH attributes */
 };
 
 struct nfs_fsstat {
-- 
1.7.4.4

