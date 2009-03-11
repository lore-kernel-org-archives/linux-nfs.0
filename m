From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 07/30] NFS: Fix the type of struct nfs_fattr->mode
Date: Wed, 11 Mar 2009 14:41:07 -0400
Message-ID: <20090311184107.5578.12568.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43206 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754612AbZCKSoK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:44:10 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIi3YI021751
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:44:08 -0700 (PDT)
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is no point in using anything other than umode_t, since we copy the
content pretty much directly into inode->i_mode.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/getroot.c        |    4 ++--
 fs/nfs/nfs2xdr.c        |    7 +++----
 fs/nfs/nfs3xdr.c        |   31 +++++++++++++------------------
 fs/nfs/nfs4xdr.c        |   40 +++++++++++++++++++---------------------
 include/linux/nfs_xdr.h |    3 +--
 5 files changed, 38 insertions(+), 47 deletions(-)


diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index b7c9b2d..46177cb 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -156,7 +156,7 @@ int nfs4_path_walk(struct nfs_server *server,
 		return ret;
 	}
 
-	if (fattr.type != NFDIR) {
+	if (!S_ISDIR(fattr.mode)) {
 		printk(KERN_ERR "nfs4_get_root:"
 		       " getroot encountered non-directory\n");
 		return -ENOTDIR;
@@ -213,7 +213,7 @@ eat_dot_dir:
 		return ret;
 	}
 
-	if (fattr.type != NFDIR) {
+	if (!S_ISDIR(fattr.mode)) {
 		printk(KERN_ERR "nfs4_get_root:"
 		       " lookupfh encountered non-directory\n");
 		return -ENOTDIR;
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index bea9999..c862c93 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -120,8 +120,8 @@ xdr_decode_time(__be32 *p, struct timespec *timep)
 static __be32 *
 xdr_decode_fattr(__be32 *p, struct nfs_fattr *fattr)
 {
-	u32 rdev;
-	fattr->type = (enum nfs_ftype) ntohl(*p++);
+	u32 rdev, type;
+	type = ntohl(*p++);
 	fattr->mode = ntohl(*p++);
 	fattr->nlink = ntohl(*p++);
 	fattr->uid = ntohl(*p++);
@@ -138,8 +138,7 @@ xdr_decode_fattr(__be32 *p, struct nfs_fattr *fattr)
 	p = xdr_decode_time(p, &fattr->ctime);
 	fattr->valid |= NFS_ATTR_FATTR_V2;
 	fattr->rdev = new_decode_dev(rdev);
-	if (fattr->type == NFCHR && rdev == NFS2_FIFO_DEV) {
-		fattr->type = NFFIFO;
+	if (type == NFCHR && rdev == NFS2_FIFO_DEV) {
 		fattr->mode = (fattr->mode & ~S_IFMT) | S_IFIFO;
 		fattr->rdev = 0;
 	}
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index c0f7d02..e6a1932 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -91,19 +91,15 @@
 /*
  * Map file type to S_IFMT bits
  */
-static struct {
-	unsigned int	mode;
-	unsigned int	nfs2type;
-} nfs_type2fmt[] = {
-      { 0,		NFNON	},
-      { S_IFREG,	NFREG	},
-      { S_IFDIR,	NFDIR	},
-      { S_IFBLK,	NFBLK	},
-      { S_IFCHR,	NFCHR	},
-      { S_IFLNK,	NFLNK	},
-      { S_IFSOCK,	NFSOCK	},
-      { S_IFIFO,	NFFIFO	},
-      { 0,		NFBAD	}
+static const umode_t nfs_type2fmt[] = {
+	[NF3BAD] = 0,
+	[NF3REG] = S_IFREG,
+	[NF3DIR] = S_IFDIR,
+	[NF3BLK] = S_IFBLK,
+	[NF3CHR] = S_IFCHR,
+	[NF3LNK] = S_IFLNK,
+	[NF3SOCK] = S_IFSOCK,
+	[NF3FIFO] = S_IFIFO,
 };
 
 /*
@@ -148,13 +144,12 @@ static __be32 *
 xdr_decode_fattr(__be32 *p, struct nfs_fattr *fattr)
 {
 	unsigned int	type, major, minor;
-	int		fmode;
+	umode_t		fmode;
 
 	type = ntohl(*p++);
-	if (type >= NF3BAD)
-		type = NF3BAD;
-	fmode = nfs_type2fmt[type].mode;
-	fattr->type = nfs_type2fmt[type].nfs2type;
+	if (type > NF3FIFO)
+		type = NF3NON;
+	fmode = nfs_type2fmt[type];
 	fattr->mode = (ntohl(*p++) & ~S_IFMT) | fmode;
 	fattr->nlink = ntohl(*p++);
 	fattr->uid = ntohl(*p++);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 9f1df83..c1906d2 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -522,20 +522,17 @@ static int nfs4_stat_to_errno(int);
 				 decode_lookup_maxsz + \
 				 decode_fs_locations_maxsz)
 
-static struct {
-	unsigned int	mode;
-	unsigned int	nfs2type;
-} nfs_type2fmt[] = {
-	{ 0,		NFNON	     },
-	{ S_IFREG,	NFREG	     },
-	{ S_IFDIR,	NFDIR	     },
-	{ S_IFBLK,	NFBLK	     },
-	{ S_IFCHR,	NFCHR	     },
-	{ S_IFLNK,	NFLNK	     },
-	{ S_IFSOCK,	NFSOCK	     },
-	{ S_IFIFO,	NFFIFO	     },
-	{ 0,		NFNON	     },
-	{ 0,		NFNON	     },
+static const umode_t nfs_type2fmt[] = {
+	[NF4BAD] = 0,
+	[NF4REG] = S_IFREG,
+	[NF4DIR] = S_IFDIR,
+	[NF4BLK] = S_IFBLK,
+	[NF4CHR] = S_IFCHR,
+	[NF4LNK] = S_IFLNK,
+	[NF4SOCK] = S_IFSOCK,
+	[NF4FIFO] = S_IFIFO,
+	[NF4ATTRDIR] = 0,
+	[NF4NAMEDATTR] = 0,
 };
 
 struct compound_hdr {
@@ -2173,7 +2170,7 @@ static int decode_attr_type(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *
 		}
 		bitmap[0] &= ~FATTR4_WORD0_TYPE;
 	}
-	dprintk("%s: type=0%o\n", __func__, nfs_type2fmt[*type].nfs2type);
+	dprintk("%s: type=0%o\n", __func__, nfs_type2fmt[*type]);
 	return 0;
 }
 
@@ -2580,8 +2577,9 @@ static int decode_attr_maxwrite(struct xdr_stream *xdr, uint32_t *bitmap, uint32
 	return status;
 }
 
-static int decode_attr_mode(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *mode)
+static int decode_attr_mode(struct xdr_stream *xdr, uint32_t *bitmap, umode_t *mode)
 {
+	uint32_t tmp;
 	__be32 *p;
 
 	*mode = 0;
@@ -2589,8 +2587,8 @@ static int decode_attr_mode(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_MODE)) {
 		READ_BUF(4);
-		READ32(*mode);
-		*mode &= ~S_IFMT;
+		READ32(tmp);
+		*mode = tmp & ~S_IFMT;
 		bitmap[1] &= ~FATTR4_WORD1_MODE;
 	}
 	dprintk("%s: file mode=0%o\n", __func__, (unsigned int)*mode);
@@ -2994,7 +2992,8 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr, cons
 	uint32_t attrlen,
 		 bitmap[2] = {0},
 		 type;
-	int status, fmode = 0;
+	int status;
+	umode_t fmode = 0;
 	uint64_t fileid;
 
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
@@ -3008,8 +3007,7 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr, cons
 
 	if ((status = decode_attr_type(xdr, bitmap, &type)) != 0)
 		goto xdr_error;
-	fattr->type = nfs_type2fmt[type].nfs2type;
-	fattr->mode = nfs_type2fmt[type].mode;
+	fattr->mode = nfs_type2fmt[type];
 
 	if ((status = decode_attr_change(xdr, bitmap, &fattr->change_attr)) != 0)
 		goto xdr_error;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 6013acb..0691b9c 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -28,8 +28,7 @@ static inline int nfs_fsid_equal(const struct nfs_fsid *a, const struct nfs_fsid
 
 struct nfs_fattr {
 	unsigned int		valid;		/* which fields are valid */
-	enum nfs_ftype		type;		/* always use NFSv2 types */
-	__u32			mode;
+	umode_t			mode;
 	__u32			nlink;
 	__u32			uid;
 	__u32			gid;

