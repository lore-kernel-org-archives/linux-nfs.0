Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:37036 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965115AbbDXLFn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 07:05:43 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC v3 36/45] NFSv4: Fix GETATTR bitmap verification
Date: Fri, 24 Apr 2015 13:04:33 +0200
Message-Id: <8d601ee8babe5239b7926542c713c58502b15e35.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFSv4 client sends the server GETATTR requests with different sets of
requested attributes depending on the situation.  The requested set of
attributes is encoded in a bitmap; the server replies with the set of
attributes it could return.  These bitmaps can be several words wide.  The
bitmap returned by the server is a subset of the bitmap sent by the client.

While decoding the reply, the client tries to verify the reply bitmap: it
checks if any previous, unexpected attributes are left in the same word of the
bitmap for each attribute it tries to decode, then it clears the current
attribute's bit in the bitmap for the next decode function.

The client fails to detect when unexpected attributes are sent after the last
expected attribute in each word in the bitmap.

Fix this by checking the entire bitmap for unexpected attributes first.  The
server can still send attributes which the client understands but which it
didn't request; this doesn't cause any harm.

Because we don't verify the bitmap one bit at a time anymore, there is no need
for clearing bitmap bits anymore.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/nfs/nfs4xdr.c | 186 +++++++++++++++++++------------------------------------
 1 file changed, 63 insertions(+), 123 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 5c399ec..36b5e95 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3151,7 +3151,6 @@ static int decode_attr_supported(struct xdr_stream *xdr, uint32_t *bitmap, uint3
 		ret = decode_attr_bitmap(xdr, bitmask);
 		if (unlikely(ret < 0))
 			return ret;
-		bitmap[0] &= ~FATTR4_WORD0_SUPPORTED_ATTRS;
 	} else
 		bitmask[0] = bitmask[1] = bitmask[2] = 0;
 	dprintk("%s: bitmask=%08x:%08x:%08x\n", __func__,
@@ -3165,8 +3164,6 @@ static int decode_attr_type(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *
 	int ret = 0;
 
 	*type = 0;
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_TYPE - 1U)))
-		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_TYPE)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
@@ -3176,7 +3173,6 @@ static int decode_attr_type(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *
 			dprintk("%s: bad type %d\n", __func__, *type);
 			return -EIO;
 		}
-		bitmap[0] &= ~FATTR4_WORD0_TYPE;
 		ret = NFS_ATTR_FATTR_TYPE;
 	}
 	dprintk("%s: type=0%o\n", __func__, nfs_type2fmt[*type]);
@@ -3192,14 +3188,11 @@ static int decode_attr_fh_expire_type(struct xdr_stream *xdr,
 	__be32 *p;
 
 	*type = 0;
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_FH_EXPIRE_TYPE - 1U)))
-		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FH_EXPIRE_TYPE)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
 		*type = be32_to_cpup(p);
-		bitmap[0] &= ~FATTR4_WORD0_FH_EXPIRE_TYPE;
 	}
 	dprintk("%s: expire type=0x%x\n", __func__, *type);
 	return 0;
@@ -3214,14 +3207,11 @@ static int decode_attr_change(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t
 	int ret = 0;
 
 	*change = 0;
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_CHANGE - 1U)))
-		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_CHANGE)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
 		xdr_decode_hyper(p, change);
-		bitmap[0] &= ~FATTR4_WORD0_CHANGE;
 		ret = NFS_ATTR_FATTR_CHANGE;
 	}
 	dprintk("%s: change attribute=%Lu\n", __func__,
@@ -3238,14 +3228,11 @@ static int decode_attr_size(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *
 	int ret = 0;
 
 	*size = 0;
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_SIZE - 1U)))
-		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_SIZE)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
 		xdr_decode_hyper(p, size);
-		bitmap[0] &= ~FATTR4_WORD0_SIZE;
 		ret = NFS_ATTR_FATTR_SIZE;
 	}
 	dprintk("%s: file size=%Lu\n", __func__, (unsigned long long)*size);
@@ -3260,14 +3247,11 @@ static int decode_attr_link_support(struct xdr_stream *xdr, uint32_t *bitmap, ui
 	__be32 *p;
 
 	*res = 0;
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_LINK_SUPPORT - 1U)))
-		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_LINK_SUPPORT)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
 		*res = be32_to_cpup(p);
-		bitmap[0] &= ~FATTR4_WORD0_LINK_SUPPORT;
 	}
 	dprintk("%s: link support=%s\n", __func__, *res == 0 ? "false" : "true");
 	return 0;
@@ -3281,14 +3265,11 @@ static int decode_attr_symlink_support(struct xdr_stream *xdr, uint32_t *bitmap,
 	__be32 *p;
 
 	*res = 0;
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_SYMLINK_SUPPORT - 1U)))
-		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_SYMLINK_SUPPORT)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
 		*res = be32_to_cpup(p);
-		bitmap[0] &= ~FATTR4_WORD0_SYMLINK_SUPPORT;
 	}
 	dprintk("%s: symlink support=%s\n", __func__, *res == 0 ? "false" : "true");
 	return 0;
@@ -3304,15 +3285,12 @@ static int decode_attr_fsid(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs
 
 	fsid->major = 0;
 	fsid->minor = 0;
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_FSID - 1U)))
-		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FSID)) {
 		p = xdr_inline_decode(xdr, 16);
 		if (unlikely(!p))
 			goto out_overflow;
 		p = xdr_decode_hyper(p, &fsid->major);
 		xdr_decode_hyper(p, &fsid->minor);
-		bitmap[0] &= ~FATTR4_WORD0_FSID;
 		ret = NFS_ATTR_FATTR_FSID;
 	}
 	dprintk("%s: fsid=(0x%Lx/0x%Lx)\n", __func__,
@@ -3329,14 +3307,11 @@ static int decode_attr_lease_time(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	__be32 *p;
 
 	*res = 60;
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_LEASE_TIME - 1U)))
-		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_LEASE_TIME)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
 		*res = be32_to_cpup(p);
-		bitmap[0] &= ~FATTR4_WORD0_LEASE_TIME;
 	}
 	dprintk("%s: file size=%u\n", __func__, (unsigned int)*res);
 	return 0;
@@ -3349,13 +3324,10 @@ static int decode_attr_error(struct xdr_stream *xdr, uint32_t *bitmap, int32_t *
 {
 	__be32 *p;
 
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_RDATTR_ERROR - 1U)))
-		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_RDATTR_ERROR)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
-		bitmap[0] &= ~FATTR4_WORD0_RDATTR_ERROR;
 		*res = -be32_to_cpup(p);
 	}
 	return 0;
@@ -3372,8 +3344,6 @@ static int decode_attr_filehandle(struct xdr_stream *xdr, uint32_t *bitmap, stru
 	if (fh != NULL)
 		memset(fh, 0, sizeof(*fh));
 
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_FILEHANDLE - 1U)))
-		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FILEHANDLE)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
@@ -3388,7 +3358,6 @@ static int decode_attr_filehandle(struct xdr_stream *xdr, uint32_t *bitmap, stru
 			memcpy(fh->data, p, len);
 			fh->size = len;
 		}
-		bitmap[0] &= ~FATTR4_WORD0_FILEHANDLE;
 	}
 	return 0;
 out_overflow:
@@ -3401,14 +3370,11 @@ static int decode_attr_aclsupport(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	__be32 *p;
 
 	*res = 0;
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_ACLSUPPORT - 1U)))
-		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_ACLSUPPORT)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
 		*res = be32_to_cpup(p);
-		bitmap[0] &= ~FATTR4_WORD0_ACLSUPPORT;
 	}
 	dprintk("%s: ACLs supported=%u\n", __func__, (unsigned int)*res);
 	return 0;
@@ -3423,14 +3389,11 @@ static int decode_attr_fileid(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t
 	int ret = 0;
 
 	*fileid = 0;
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_FILEID - 1U)))
-		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FILEID)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
 		xdr_decode_hyper(p, fileid);
-		bitmap[0] &= ~FATTR4_WORD0_FILEID;
 		ret = NFS_ATTR_FATTR_FILEID;
 	}
 	dprintk("%s: fileid=%Lu\n", __func__, (unsigned long long)*fileid);
@@ -3446,14 +3409,11 @@ static int decode_attr_mounted_on_fileid(struct xdr_stream *xdr, uint32_t *bitma
 	int ret = 0;
 
 	*fileid = 0;
-	if (unlikely(bitmap[1] & (FATTR4_WORD1_MOUNTED_ON_FILEID - 1U)))
-		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_MOUNTED_ON_FILEID)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
 		xdr_decode_hyper(p, fileid);
-		bitmap[1] &= ~FATTR4_WORD1_MOUNTED_ON_FILEID;
 		ret = NFS_ATTR_FATTR_MOUNTED_ON_FILEID;
 	}
 	dprintk("%s: fileid=%Lu\n", __func__, (unsigned long long)*fileid);
@@ -3469,14 +3429,11 @@ static int decode_attr_files_avail(struct xdr_stream *xdr, uint32_t *bitmap, uin
 	int status = 0;
 
 	*res = 0;
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_FILES_AVAIL - 1U)))
-		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FILES_AVAIL)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
 		xdr_decode_hyper(p, res);
-		bitmap[0] &= ~FATTR4_WORD0_FILES_AVAIL;
 	}
 	dprintk("%s: files avail=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
@@ -3491,14 +3448,11 @@ static int decode_attr_files_free(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	int status = 0;
 
 	*res = 0;
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_FILES_FREE - 1U)))
-		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FILES_FREE)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
 		xdr_decode_hyper(p, res);
-		bitmap[0] &= ~FATTR4_WORD0_FILES_FREE;
 	}
 	dprintk("%s: files free=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
@@ -3513,14 +3467,11 @@ static int decode_attr_files_total(struct xdr_stream *xdr, uint32_t *bitmap, uin
 	int status = 0;
 
 	*res = 0;
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_FILES_TOTAL - 1U)))
-		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FILES_TOTAL)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
 		xdr_decode_hyper(p, res);
-		bitmap[0] &= ~FATTR4_WORD0_FILES_TOTAL;
 	}
 	dprintk("%s: files total=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
@@ -3578,11 +3529,8 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 {
 	int n;
 	__be32 *p;
-	int status = -EIO;
+	int status = 0;
 
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_FS_LOCATIONS -1U)))
-		goto out;
-	status = 0;
 	if (unlikely(!(bitmap[0] & FATTR4_WORD0_FS_LOCATIONS)))
 		goto out;
 	status = -EIO;
@@ -3659,14 +3607,11 @@ static int decode_attr_maxfilesize(struct xdr_stream *xdr, uint32_t *bitmap, uin
 	int status = 0;
 
 	*res = 0;
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_MAXFILESIZE - 1U)))
-		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXFILESIZE)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
 		xdr_decode_hyper(p, res);
-		bitmap[0] &= ~FATTR4_WORD0_MAXFILESIZE;
 	}
 	dprintk("%s: maxfilesize=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
@@ -3681,14 +3626,11 @@ static int decode_attr_maxlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 	int status = 0;
 
 	*maxlink = 1;
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_MAXLINK - 1U)))
-		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXLINK)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
 		*maxlink = be32_to_cpup(p);
-		bitmap[0] &= ~FATTR4_WORD0_MAXLINK;
 	}
 	dprintk("%s: maxlink=%u\n", __func__, *maxlink);
 	return status;
@@ -3703,14 +3645,11 @@ static int decode_attr_maxname(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 	int status = 0;
 
 	*maxname = 1024;
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_MAXNAME - 1U)))
-		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXNAME)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
 		*maxname = be32_to_cpup(p);
-		bitmap[0] &= ~FATTR4_WORD0_MAXNAME;
 	}
 	dprintk("%s: maxname=%u\n", __func__, *maxname);
 	return status;
@@ -3725,8 +3664,6 @@ static int decode_attr_maxread(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 	int status = 0;
 
 	*res = 1024;
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_MAXREAD - 1U)))
-		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXREAD)) {
 		uint64_t maxread;
 		p = xdr_inline_decode(xdr, 8);
@@ -3736,7 +3673,6 @@ static int decode_attr_maxread(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 		if (maxread > 0x7FFFFFFF)
 			maxread = 0x7FFFFFFF;
 		*res = (uint32_t)maxread;
-		bitmap[0] &= ~FATTR4_WORD0_MAXREAD;
 	}
 	dprintk("%s: maxread=%lu\n", __func__, (unsigned long)*res);
 	return status;
@@ -3751,8 +3687,6 @@ static int decode_attr_maxwrite(struct xdr_stream *xdr, uint32_t *bitmap, uint32
 	int status = 0;
 
 	*res = 1024;
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_MAXWRITE - 1U)))
-		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXWRITE)) {
 		uint64_t maxwrite;
 		p = xdr_inline_decode(xdr, 8);
@@ -3762,7 +3696,6 @@ static int decode_attr_maxwrite(struct xdr_stream *xdr, uint32_t *bitmap, uint32
 		if (maxwrite > 0x7FFFFFFF)
 			maxwrite = 0x7FFFFFFF;
 		*res = (uint32_t)maxwrite;
-		bitmap[0] &= ~FATTR4_WORD0_MAXWRITE;
 	}
 	dprintk("%s: maxwrite=%lu\n", __func__, (unsigned long)*res);
 	return status;
@@ -3778,15 +3711,12 @@ static int decode_attr_mode(struct xdr_stream *xdr, uint32_t *bitmap, umode_t *m
 	int ret = 0;
 
 	*mode = 0;
-	if (unlikely(bitmap[1] & (FATTR4_WORD1_MODE - 1U)))
-		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_MODE)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
 		tmp = be32_to_cpup(p);
 		*mode = tmp & ~S_IFMT;
-		bitmap[1] &= ~FATTR4_WORD1_MODE;
 		ret = NFS_ATTR_FATTR_MODE;
 	}
 	dprintk("%s: file mode=0%o\n", __func__, (unsigned int)*mode);
@@ -3802,14 +3732,11 @@ static int decode_attr_nlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t
 	int ret = 0;
 
 	*nlink = 1;
-	if (unlikely(bitmap[1] & (FATTR4_WORD1_NUMLINKS - 1U)))
-		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_NUMLINKS)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
 		*nlink = be32_to_cpup(p);
-		bitmap[1] &= ~FATTR4_WORD1_NUMLINKS;
 		ret = NFS_ATTR_FATTR_NLINK;
 	}
 	dprintk("%s: nlink=%u\n", __func__, (unsigned int)*nlink);
@@ -3828,8 +3755,6 @@ static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap,
 	int ret = 0;
 
 	*uid = make_kuid(&init_user_ns, -2);
-	if (unlikely(bitmap[1] & (FATTR4_WORD1_OWNER - 1U)))
-		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_OWNER)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
@@ -3853,7 +3778,6 @@ static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap,
 		} else
 			dprintk("%s: name too long (%u)!\n",
 					__func__, len);
-		bitmap[1] &= ~FATTR4_WORD1_OWNER;
 	}
 	dprintk("%s: uid=%d\n", __func__, (int)from_kuid(&init_user_ns, *uid));
 	return ret;
@@ -3871,8 +3795,6 @@ static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap,
 	int ret = 0;
 
 	*gid = make_kgid(&init_user_ns, -2);
-	if (unlikely(bitmap[1] & (FATTR4_WORD1_OWNER_GROUP - 1U)))
-		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_OWNER_GROUP)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
@@ -3896,7 +3818,6 @@ static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap,
 		} else
 			dprintk("%s: name too long (%u)!\n",
 					__func__, len);
-		bitmap[1] &= ~FATTR4_WORD1_OWNER_GROUP;
 	}
 	dprintk("%s: gid=%d\n", __func__, (int)from_kgid(&init_user_ns, *gid));
 	return ret;
@@ -3912,8 +3833,6 @@ static int decode_attr_rdev(struct xdr_stream *xdr, uint32_t *bitmap, dev_t *rde
 	int ret = 0;
 
 	*rdev = MKDEV(0,0);
-	if (unlikely(bitmap[1] & (FATTR4_WORD1_RAWDEV - 1U)))
-		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_RAWDEV)) {
 		dev_t tmp;
 
@@ -3925,7 +3844,6 @@ static int decode_attr_rdev(struct xdr_stream *xdr, uint32_t *bitmap, dev_t *rde
 		tmp = MKDEV(major, minor);
 		if (MAJOR(tmp) == major && MINOR(tmp) == minor)
 			*rdev = tmp;
-		bitmap[1] &= ~ FATTR4_WORD1_RAWDEV;
 		ret = NFS_ATTR_FATTR_RDEV;
 	}
 	dprintk("%s: rdev=(0x%x:0x%x)\n", __func__, major, minor);
@@ -3941,14 +3859,11 @@ static int decode_attr_space_avail(struct xdr_stream *xdr, uint32_t *bitmap, uin
 	int status = 0;
 
 	*res = 0;
-	if (unlikely(bitmap[1] & (FATTR4_WORD1_SPACE_AVAIL - 1U)))
-		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_SPACE_AVAIL)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
 		xdr_decode_hyper(p, res);
-		bitmap[1] &= ~FATTR4_WORD1_SPACE_AVAIL;
 	}
 	dprintk("%s: space avail=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
@@ -3963,14 +3878,11 @@ static int decode_attr_space_free(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	int status = 0;
 
 	*res = 0;
-	if (unlikely(bitmap[1] & (FATTR4_WORD1_SPACE_FREE - 1U)))
-		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_SPACE_FREE)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
 		xdr_decode_hyper(p, res);
-		bitmap[1] &= ~FATTR4_WORD1_SPACE_FREE;
 	}
 	dprintk("%s: space free=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
@@ -3985,14 +3897,11 @@ static int decode_attr_space_total(struct xdr_stream *xdr, uint32_t *bitmap, uin
 	int status = 0;
 
 	*res = 0;
-	if (unlikely(bitmap[1] & (FATTR4_WORD1_SPACE_TOTAL - 1U)))
-		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_SPACE_TOTAL)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
 		xdr_decode_hyper(p, res);
-		bitmap[1] &= ~FATTR4_WORD1_SPACE_TOTAL;
 	}
 	dprintk("%s: space total=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
@@ -4007,14 +3916,11 @@ static int decode_attr_space_used(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	int ret = 0;
 
 	*used = 0;
-	if (unlikely(bitmap[1] & (FATTR4_WORD1_SPACE_USED - 1U)))
-		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_SPACE_USED)) {
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
 		xdr_decode_hyper(p, used);
-		bitmap[1] &= ~FATTR4_WORD1_SPACE_USED;
 		ret = NFS_ATTR_FATTR_SPACE_USED;
 	}
 	dprintk("%s: space used=%Lu\n", __func__,
@@ -4050,13 +3956,10 @@ static int decode_attr_time_access(struct xdr_stream *xdr, uint32_t *bitmap, str
 
 	time->tv_sec = 0;
 	time->tv_nsec = 0;
-	if (unlikely(bitmap[1] & (FATTR4_WORD1_TIME_ACCESS - 1U)))
-		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_TIME_ACCESS)) {
 		status = decode_attr_time(xdr, time);
 		if (status == 0)
 			status = NFS_ATTR_FATTR_ATIME;
-		bitmap[1] &= ~FATTR4_WORD1_TIME_ACCESS;
 	}
 	dprintk("%s: atime=%ld\n", __func__, (long)time->tv_sec);
 	return status;
@@ -4068,13 +3971,10 @@ static int decode_attr_time_metadata(struct xdr_stream *xdr, uint32_t *bitmap, s
 
 	time->tv_sec = 0;
 	time->tv_nsec = 0;
-	if (unlikely(bitmap[1] & (FATTR4_WORD1_TIME_METADATA - 1U)))
-		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_TIME_METADATA)) {
 		status = decode_attr_time(xdr, time);
 		if (status == 0)
 			status = NFS_ATTR_FATTR_CTIME;
-		bitmap[1] &= ~FATTR4_WORD1_TIME_METADATA;
 	}
 	dprintk("%s: ctime=%ld\n", __func__, (long)time->tv_sec);
 	return status;
@@ -4087,12 +3987,8 @@ static int decode_attr_time_delta(struct xdr_stream *xdr, uint32_t *bitmap,
 
 	time->tv_sec = 0;
 	time->tv_nsec = 0;
-	if (unlikely(bitmap[1] & (FATTR4_WORD1_TIME_DELTA - 1U)))
-		return -EIO;
-	if (likely(bitmap[1] & FATTR4_WORD1_TIME_DELTA)) {
+	if (likely(bitmap[1] & FATTR4_WORD1_TIME_DELTA))
 		status = decode_attr_time(xdr, time);
-		bitmap[1] &= ~FATTR4_WORD1_TIME_DELTA;
-	}
 	dprintk("%s: time_delta=%ld %ld\n", __func__, (long)time->tv_sec,
 		(long)time->tv_nsec);
 	return status;
@@ -4107,8 +4003,6 @@ static int decode_attr_security_label(struct xdr_stream *xdr, uint32_t *bitmap,
 	__be32 *p;
 	int status = 0;
 
-	if (unlikely(bitmap[2] & (FATTR4_WORD2_SECURITY_LABEL - 1U)))
-		return -EIO;
 	if (likely(bitmap[2] & FATTR4_WORD2_SECURITY_LABEL)) {
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
@@ -4133,7 +4027,6 @@ static int decode_attr_security_label(struct xdr_stream *xdr, uint32_t *bitmap,
 				label->lfs = lfs;
 				status = NFS_ATTR_FATTR_V4_SECURITY_LABEL;
 			}
-			bitmap[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
 		} else
 			printk(KERN_WARNING "%s: label too long (%u)!\n",
 					__func__, len);
@@ -4154,13 +4047,10 @@ static int decode_attr_time_modify(struct xdr_stream *xdr, uint32_t *bitmap, str
 
 	time->tv_sec = 0;
 	time->tv_nsec = 0;
-	if (unlikely(bitmap[1] & (FATTR4_WORD1_TIME_MODIFY - 1U)))
-		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_TIME_MODIFY)) {
 		status = decode_attr_time(xdr, time);
 		if (status == 0)
 			status = NFS_ATTR_FATTR_MTIME;
-		bitmap[1] &= ~FATTR4_WORD1_TIME_MODIFY;
 	}
 	dprintk("%s: mtime=%ld\n", __func__, (long)time->tv_sec);
 	return status;
@@ -4183,6 +4073,15 @@ static int verify_attr_len(struct xdr_stream *xdr, unsigned int savep, uint32_t
 	return 0;
 }
 
+static int verify_attrs_allowed(uint32_t *bitmap, const uint32_t *attrs_allowed)
+{
+	if (unlikely(bitmap[0] & ~attrs_allowed[0] ||
+		     bitmap[1] & ~attrs_allowed[1] ||
+		     bitmap[2] & ~attrs_allowed[2]))
+		return -EIO;
+	return 0;
+}
+
 static int decode_change_info(struct xdr_stream *xdr, struct nfs4_change_info *cinfo)
 {
 	__be32 *p;
@@ -4296,6 +4195,11 @@ out_overflow:
 
 static int decode_server_caps(struct xdr_stream *xdr, struct nfs4_server_caps_res *res)
 {
+	static const uint32_t attrs_allowed[3] = {
+		[0] = FATTR4_WORD0_SUPPORTED_ATTRS | FATTR4_WORD0_FH_EXPIRE_TYPE |
+		      FATTR4_WORD0_LINK_SUPPORT | FATTR4_WORD0_SYMLINK_SUPPORT |
+		      FATTR4_WORD0_ACLSUPPORT,
+	};
 	unsigned int savep;
 	uint32_t attrlen, bitmap[3] = {0};
 	int status;
@@ -4304,6 +4208,8 @@ static int decode_server_caps(struct xdr_stream *xdr, struct nfs4_server_caps_re
 		goto xdr_error;
 	if ((status = decode_attr_bitmap(xdr, bitmap)) != 0)
 		goto xdr_error;
+	if ((status = verify_attrs_allowed(bitmap, attrs_allowed)) != 0)
+		goto xdr_error;
 	if ((status = decode_attr_length(xdr, &attrlen, &savep)) != 0)
 		goto xdr_error;
 	if ((status = decode_attr_supported(xdr, bitmap, res->attr_bitmask)) != 0)
@@ -4325,6 +4231,12 @@ xdr_error:
 
 static int decode_statfs(struct xdr_stream *xdr, struct nfs_fsstat *fsstat)
 {
+	static const uint32_t attrs_allowed[3] = {
+		[0] = FATTR4_WORD0_FILES_AVAIL | FATTR4_WORD0_FILES_FREE |
+		      FATTR4_WORD0_FILES_TOTAL,
+		[1] = FATTR4_WORD1_SPACE_AVAIL | FATTR4_WORD1_SPACE_FREE |
+		      FATTR4_WORD1_SPACE_TOTAL,
+	};
 	unsigned int savep;
 	uint32_t attrlen, bitmap[3] = {0};
 	int status;
@@ -4333,6 +4245,8 @@ static int decode_statfs(struct xdr_stream *xdr, struct nfs_fsstat *fsstat)
 		goto xdr_error;
 	if ((status = decode_attr_bitmap(xdr, bitmap)) != 0)
 		goto xdr_error;
+	if ((status = verify_attrs_allowed(bitmap, attrs_allowed)) != 0)
+		goto xdr_error;
 	if ((status = decode_attr_length(xdr, &attrlen, &savep)) != 0)
 		goto xdr_error;
 
@@ -4357,6 +4271,9 @@ xdr_error:
 
 static int decode_pathconf(struct xdr_stream *xdr, struct nfs_pathconf *pathconf)
 {
+	static const uint32_t attrs_allowed[3] = {
+		[0] = FATTR4_WORD0_MAXLINK | FATTR4_WORD0_MAXNAME,
+	};
 	unsigned int savep;
 	uint32_t attrlen, bitmap[3] = {0};
 	int status;
@@ -4365,6 +4282,8 @@ static int decode_pathconf(struct xdr_stream *xdr, struct nfs_pathconf *pathconf
 		goto xdr_error;
 	if ((status = decode_attr_bitmap(xdr, bitmap)) != 0)
 		goto xdr_error;
+	if ((status = verify_attrs_allowed(bitmap, attrs_allowed)) != 0)
+		goto xdr_error;
 	if ((status = decode_attr_length(xdr, &attrlen, &savep)) != 0)
 		goto xdr_error;
 
@@ -4462,8 +4381,6 @@ static int decode_attr_mdsthreshold(struct xdr_stream *xdr,
 	int status = 0;
 	uint32_t num;
 
-	if (unlikely(bitmap[2] & (FATTR4_WORD2_MDSTHRESHOLD - 1U)))
-		return -EIO;
 	if (bitmap[2] & FATTR4_WORD2_MDSTHRESHOLD) {
 		/* Did the server return an unrequested attribute? */
 		if (unlikely(res == NULL))
@@ -4480,7 +4397,6 @@ static int decode_attr_mdsthreshold(struct xdr_stream *xdr,
 				__func__);
 
 		status = decode_first_threshold_item4(xdr, res);
-		bitmap[2] &= ~FATTR4_WORD2_MDSTHRESHOLD;
 	}
 	return status;
 out_overflow:
@@ -4493,11 +4409,28 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 		struct nfs4_fs_locations *fs_loc, struct nfs4_label *label,
 		const struct nfs_server *server)
 {
+	static const uint32_t attrs_allowed[3] = {
+		[0] = FATTR4_WORD0_TYPE | FATTR4_WORD0_CHANGE |
+		      FATTR4_WORD0_SIZE | FATTR4_WORD0_FSID |
+		      FATTR4_WORD0_RDATTR_ERROR | FATTR4_WORD0_FILEHANDLE |
+		      FATTR4_WORD0_FILEID | FATTR4_WORD0_FS_LOCATIONS,
+		[1] = FATTR4_WORD1_MODE | FATTR4_WORD1_NUMLINKS |
+		      FATTR4_WORD1_OWNER | FATTR4_WORD1_OWNER_GROUP |
+		      FATTR4_WORD1_RAWDEV | FATTR4_WORD1_SPACE_USED |
+		      FATTR4_WORD1_TIME_ACCESS | FATTR4_WORD1_TIME_METADATA |
+		      FATTR4_WORD1_TIME_MODIFY |
+		      FATTR4_WORD1_MOUNTED_ON_FILEID,
+		[2] = FATTR4_WORD2_MDSTHRESHOLD | FATTR4_WORD2_SECURITY_LABEL,
+	};
 	int status;
 	umode_t fmode = 0;
 	uint32_t type;
 	int32_t err;
 
+	status = verify_attrs_allowed(bitmap, attrs_allowed);
+	if (status != 0)
+		goto xdr_error;
+
 	status = decode_attr_type(xdr, bitmap, &type);
 	if (status < 0)
 		goto xdr_error;
@@ -4699,12 +4632,9 @@ static int decode_attr_pnfstype(struct xdr_stream *xdr, uint32_t *bitmap,
 	int status = 0;
 
 	dprintk("%s: bitmap is %x\n", __func__, bitmap[1]);
-	if (unlikely(bitmap[1] & (FATTR4_WORD1_FS_LAYOUT_TYPES - 1U)))
-		return -EIO;
-	if (bitmap[1] & FATTR4_WORD1_FS_LAYOUT_TYPES) {
+	if (bitmap[1] & FATTR4_WORD1_FS_LAYOUT_TYPES)
 		status = decode_first_pnfs_layout_type(xdr, layouttype);
-		bitmap[1] &= ~FATTR4_WORD1_FS_LAYOUT_TYPES;
-	} else
+	else
 		*layouttype = 0;
 	return status;
 }
@@ -4726,13 +4656,18 @@ static int decode_attr_layout_blksize(struct xdr_stream *xdr, uint32_t *bitmap,
 			return -EIO;
 		}
 		*res = be32_to_cpup(p);
-		bitmap[2] &= ~FATTR4_WORD2_LAYOUT_BLKSIZE;
 	}
 	return 0;
 }
 
 static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 {
+	static const uint32_t attrs_allowed[3] = {
+		[0] = FATTR4_WORD0_LEASE_TIME | FATTR4_WORD0_MAXFILESIZE |
+		      FATTR4_WORD0_MAXREAD | FATTR4_WORD0_MAXWRITE,
+		[1] = FATTR4_WORD1_TIME_DELTA | FATTR4_WORD1_FS_LAYOUT_TYPES,
+		[2] = FATTR4_WORD2_LAYOUT_BLKSIZE,
+	};
 	unsigned int savep;
 	uint32_t attrlen, bitmap[3];
 	int status;
@@ -4741,6 +4676,8 @@ static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 		goto xdr_error;
 	if ((status = decode_attr_bitmap(xdr, bitmap)) != 0)
 		goto xdr_error;
+	if ((status = verify_attrs_allowed(bitmap, attrs_allowed) != 0))
+		goto xdr_error;
 	if ((status = decode_attr_length(xdr, &attrlen, &savep)) != 0)
 		goto xdr_error;
 
@@ -5203,6 +5140,9 @@ decode_restorefh(struct xdr_stream *xdr)
 static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 			 struct nfs_getaclres *res)
 {
+	static const uint32_t attrs_allowed[3] = {
+		[0] = FATTR4_WORD0_ACL,
+	};
 	unsigned int savep;
 	uint32_t attrlen,
 		 bitmap[3] = {0};
@@ -5220,11 +5160,11 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 
 	if ((status = decode_attr_bitmap(xdr, bitmap)) != 0)
 		goto out;
+	if ((status = verify_attrs_allowed(bitmap, attrs_allowed)) != 0)
+		goto out;
 	if ((status = decode_attr_length(xdr, &attrlen, &savep)) != 0)
 		goto out;
 
-	if (unlikely(bitmap[0] & (FATTR4_WORD0_ACL - 1U)))
-		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_ACL)) {
 
 		/* The bitmap (xdr len + bitmaps) and the attr xdr len words
-- 
2.1.0

