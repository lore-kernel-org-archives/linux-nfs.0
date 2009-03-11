From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 09/30] NFSv4: Make decode_getfattr() set fattr->valid to
 reflect what was decoded
Date: Wed, 11 Mar 2009 14:41:07 -0400
Message-ID: <20090311184107.5578.50684.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54011 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754345AbZCKSoL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:44:11 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIi45I012186
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:44:08 -0700 (PDT)
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4xdr.c |   92 +++++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 73 insertions(+), 19 deletions(-)


diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 43c6e50..1690f0e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2157,6 +2157,7 @@ static int decode_attr_supported(struct xdr_stream *xdr, uint32_t *bitmap, uint3
 static int decode_attr_type(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *type)
 {
 	__be32 *p;
+	int ret = 0;
 
 	*type = 0;
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_TYPE - 1U)))
@@ -2169,14 +2170,16 @@ static int decode_attr_type(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *
 			return -EIO;
 		}
 		bitmap[0] &= ~FATTR4_WORD0_TYPE;
+		ret = NFS_ATTR_FATTR_TYPE;
 	}
 	dprintk("%s: type=0%o\n", __func__, nfs_type2fmt[*type]);
-	return 0;
+	return ret;
 }
 
 static int decode_attr_change(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *change)
 {
 	__be32 *p;
+	int ret = 0;
 
 	*change = 0;
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_CHANGE - 1U)))
@@ -2185,15 +2188,17 @@ static int decode_attr_change(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t
 		READ_BUF(8);
 		READ64(*change);
 		bitmap[0] &= ~FATTR4_WORD0_CHANGE;
+		ret = NFS_ATTR_FATTR_CHANGE;
 	}
 	dprintk("%s: change attribute=%Lu\n", __func__,
 			(unsigned long long)*change);
-	return 0;
+	return ret;
 }
 
 static int decode_attr_size(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *size)
 {
 	__be32 *p;
+	int ret = 0;
 
 	*size = 0;
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_SIZE - 1U)))
@@ -2202,9 +2207,10 @@ static int decode_attr_size(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *
 		READ_BUF(8);
 		READ64(*size);
 		bitmap[0] &= ~FATTR4_WORD0_SIZE;
+		ret = NFS_ATTR_FATTR_SIZE;
 	}
 	dprintk("%s: file size=%Lu\n", __func__, (unsigned long long)*size);
-	return 0;
+	return ret;
 }
 
 static int decode_attr_link_support(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *res)
@@ -2242,6 +2248,7 @@ static int decode_attr_symlink_support(struct xdr_stream *xdr, uint32_t *bitmap,
 static int decode_attr_fsid(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs_fsid *fsid)
 {
 	__be32 *p;
+	int ret = 0;
 
 	fsid->major = 0;
 	fsid->minor = 0;
@@ -2252,11 +2259,12 @@ static int decode_attr_fsid(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs
 		READ64(fsid->major);
 		READ64(fsid->minor);
 		bitmap[0] &= ~FATTR4_WORD0_FSID;
+		ret = NFS_ATTR_FATTR_FSID;
 	}
 	dprintk("%s: fsid=(0x%Lx/0x%Lx)\n", __func__,
 			(unsigned long long)fsid->major,
 			(unsigned long long)fsid->minor);
-	return 0;
+	return ret;
 }
 
 static int decode_attr_lease_time(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *res)
@@ -2294,6 +2302,7 @@ static int decode_attr_aclsupport(struct xdr_stream *xdr, uint32_t *bitmap, uint
 static int decode_attr_fileid(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *fileid)
 {
 	__be32 *p;
+	int ret = 0;
 
 	*fileid = 0;
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_FILEID - 1U)))
@@ -2302,14 +2311,16 @@ static int decode_attr_fileid(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t
 		READ_BUF(8);
 		READ64(*fileid);
 		bitmap[0] &= ~FATTR4_WORD0_FILEID;
+		ret = NFS_ATTR_FATTR_FILEID;
 	}
 	dprintk("%s: fileid=%Lu\n", __func__, (unsigned long long)*fileid);
-	return 0;
+	return ret;
 }
 
 static int decode_attr_mounted_on_fileid(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *fileid)
 {
 	__be32 *p;
+	int ret = 0;
 
 	*fileid = 0;
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_MOUNTED_ON_FILEID - 1U)))
@@ -2318,9 +2329,10 @@ static int decode_attr_mounted_on_fileid(struct xdr_stream *xdr, uint32_t *bitma
 		READ_BUF(8);
 		READ64(*fileid);
 		bitmap[1] &= ~FATTR4_WORD1_MOUNTED_ON_FILEID;
+		ret = NFS_ATTR_FATTR_FILEID;
 	}
 	dprintk("%s: fileid=%Lu\n", __func__, (unsigned long long)*fileid);
-	return 0;
+	return ret;
 }
 
 static int decode_attr_files_avail(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *res)
@@ -2476,6 +2488,8 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 		if (res->nlocations < NFS4_FS_LOCATIONS_MAXENTRIES)
 			res->nlocations++;
 	}
+	if (res->nlocations != 0)
+		status = NFS_ATTR_FATTR_V4_REFERRAL;
 out:
 	dprintk("%s: fs_locations done, error = %d\n", __func__, status);
 	return status;
@@ -2581,6 +2595,7 @@ static int decode_attr_mode(struct xdr_stream *xdr, uint32_t *bitmap, umode_t *m
 {
 	uint32_t tmp;
 	__be32 *p;
+	int ret = 0;
 
 	*mode = 0;
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_MODE - 1U)))
@@ -2590,14 +2605,16 @@ static int decode_attr_mode(struct xdr_stream *xdr, uint32_t *bitmap, umode_t *m
 		READ32(tmp);
 		*mode = tmp & ~S_IFMT;
 		bitmap[1] &= ~FATTR4_WORD1_MODE;
+		ret = NFS_ATTR_FATTR_MODE;
 	}
 	dprintk("%s: file mode=0%o\n", __func__, (unsigned int)*mode);
-	return 0;
+	return ret;
 }
 
 static int decode_attr_nlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *nlink)
 {
 	__be32 *p;
+	int ret = 0;
 
 	*nlink = 1;
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_NUMLINKS - 1U)))
@@ -2606,15 +2623,17 @@ static int decode_attr_nlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t
 		READ_BUF(4);
 		READ32(*nlink);
 		bitmap[1] &= ~FATTR4_WORD1_NUMLINKS;
+		ret = NFS_ATTR_FATTR_NLINK;
 	}
 	dprintk("%s: nlink=%u\n", __func__, (unsigned int)*nlink);
-	return 0;
+	return ret;
 }
 
 static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs_client *clp, uint32_t *uid)
 {
 	uint32_t len;
 	__be32 *p;
+	int ret = 0;
 
 	*uid = -2;
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_OWNER - 1U)))
@@ -2624,7 +2643,9 @@ static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 		READ32(len);
 		READ_BUF(len);
 		if (len < XDR_MAX_NETOBJ) {
-			if (nfs_map_name_to_uid(clp, (char *)p, len, uid) != 0)
+			if (nfs_map_name_to_uid(clp, (char *)p, len, uid) == 0)
+				ret = NFS_ATTR_FATTR_OWNER;
+			else
 				dprintk("%s: nfs_map_name_to_uid failed!\n",
 						__func__);
 		} else
@@ -2633,13 +2654,14 @@ static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 		bitmap[1] &= ~FATTR4_WORD1_OWNER;
 	}
 	dprintk("%s: uid=%d\n", __func__, (int)*uid);
-	return 0;
+	return ret;
 }
 
 static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs_client *clp, uint32_t *gid)
 {
 	uint32_t len;
 	__be32 *p;
+	int ret = 0;
 
 	*gid = -2;
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_OWNER_GROUP - 1U)))
@@ -2649,7 +2671,9 @@ static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 		READ32(len);
 		READ_BUF(len);
 		if (len < XDR_MAX_NETOBJ) {
-			if (nfs_map_group_to_gid(clp, (char *)p, len, gid) != 0)
+			if (nfs_map_group_to_gid(clp, (char *)p, len, gid) == 0)
+				ret = NFS_ATTR_FATTR_GROUP;
+			else
 				dprintk("%s: nfs_map_group_to_gid failed!\n",
 						__func__);
 		} else
@@ -2658,13 +2682,14 @@ static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 		bitmap[1] &= ~FATTR4_WORD1_OWNER_GROUP;
 	}
 	dprintk("%s: gid=%d\n", __func__, (int)*gid);
-	return 0;
+	return ret;
 }
 
 static int decode_attr_rdev(struct xdr_stream *xdr, uint32_t *bitmap, dev_t *rdev)
 {
 	uint32_t major = 0, minor = 0;
 	__be32 *p;
+	int ret = 0;
 
 	*rdev = MKDEV(0,0);
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_RAWDEV - 1U)))
@@ -2679,9 +2704,10 @@ static int decode_attr_rdev(struct xdr_stream *xdr, uint32_t *bitmap, dev_t *rde
 		if (MAJOR(tmp) == major && MINOR(tmp) == minor)
 			*rdev = tmp;
 		bitmap[1] &= ~ FATTR4_WORD1_RAWDEV;
+		ret = NFS_ATTR_FATTR_RDEV;
 	}
 	dprintk("%s: rdev=(0x%x:0x%x)\n", __func__, major, minor);
-	return 0;
+	return ret;
 }
 
 static int decode_attr_space_avail(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *res)
@@ -2738,6 +2764,7 @@ static int decode_attr_space_total(struct xdr_stream *xdr, uint32_t *bitmap, uin
 static int decode_attr_space_used(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *used)
 {
 	__be32 *p;
+	int ret = 0;
 
 	*used = 0;
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_SPACE_USED - 1U)))
@@ -2746,10 +2773,11 @@ static int decode_attr_space_used(struct xdr_stream *xdr, uint32_t *bitmap, uint
 		READ_BUF(8);
 		READ64(*used);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_USED;
+		ret = NFS_ATTR_FATTR_SPACE_USED;
 	}
 	dprintk("%s: space used=%Lu\n", __func__,
 			(unsigned long long)*used);
-	return 0;
+	return ret;
 }
 
 static int decode_attr_time(struct xdr_stream *xdr, struct timespec *time)
@@ -2776,6 +2804,8 @@ static int decode_attr_time_access(struct xdr_stream *xdr, uint32_t *bitmap, str
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_TIME_ACCESS)) {
 		status = decode_attr_time(xdr, time);
+		if (status == 0)
+			status = NFS_ATTR_FATTR_ATIME;
 		bitmap[1] &= ~FATTR4_WORD1_TIME_ACCESS;
 	}
 	dprintk("%s: atime=%ld\n", __func__, (long)time->tv_sec);
@@ -2792,6 +2822,8 @@ static int decode_attr_time_metadata(struct xdr_stream *xdr, uint32_t *bitmap, s
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_TIME_METADATA)) {
 		status = decode_attr_time(xdr, time);
+		if (status == 0)
+			status = NFS_ATTR_FATTR_CTIME;
 		bitmap[1] &= ~FATTR4_WORD1_TIME_METADATA;
 	}
 	dprintk("%s: ctime=%ld\n", __func__, (long)time->tv_sec);
@@ -2808,6 +2840,8 @@ static int decode_attr_time_modify(struct xdr_stream *xdr, uint32_t *bitmap, str
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_TIME_MODIFY)) {
 		status = decode_attr_time(xdr, time);
+		if (status == 0)
+			status = NFS_ATTR_FATTR_MTIME;
 		bitmap[1] &= ~FATTR4_WORD1_TIME_MODIFY;
 	}
 	dprintk("%s: mtime=%ld\n", __func__, (long)time->tv_sec);
@@ -3012,76 +3046,96 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr, cons
 	status = decode_attr_type(xdr, bitmap, &type);
 	if (status < 0)
 		goto xdr_error;
-	fattr->mode = nfs_type2fmt[type];
+	fattr->mode = 0;
+	if (status != 0) {
+		fattr->mode |= nfs_type2fmt[type];
+		fattr->valid |= status;
+	}
 
 	status = decode_attr_change(xdr, bitmap, &fattr->change_attr);
 	if (status < 0)
 		goto xdr_error;
+	fattr->valid |= status;
 
 	status = decode_attr_size(xdr, bitmap, &fattr->size);
 	if (status < 0)
 		goto xdr_error;
+	fattr->valid |= status;
 
 	status = decode_attr_fsid(xdr, bitmap, &fattr->fsid);
 	if (status < 0)
 		goto xdr_error;
+	fattr->valid |= status;
 
 	status = decode_attr_fileid(xdr, bitmap, &fattr->fileid);
 	if (status < 0)
 		goto xdr_error;
+	fattr->valid |= status;
 
 	status = decode_attr_fs_locations(xdr, bitmap, container_of(fattr,
 						struct nfs4_fs_locations,
 						fattr));
 	if (status < 0)
 		goto xdr_error;
+	fattr->valid |= status;
 
 	status = decode_attr_mode(xdr, bitmap, &fmode);
 	if (status < 0)
 		goto xdr_error;
-	fattr->mode |= fmode;
+	if (status != 0) {
+		fattr->mode |= fmode;
+		fattr->valid |= status;
+	}
 
 	status = decode_attr_nlink(xdr, bitmap, &fattr->nlink);
 	if (status < 0)
 		goto xdr_error;
+	fattr->valid |= status;
 
 	status = decode_attr_owner(xdr, bitmap, server->nfs_client, &fattr->uid);
 	if (status < 0)
 		goto xdr_error;
+	fattr->valid |= status;
 
 	status = decode_attr_group(xdr, bitmap, server->nfs_client, &fattr->gid);
 	if (status < 0)
 		goto xdr_error;
+	fattr->valid |= status;
 
 	status = decode_attr_rdev(xdr, bitmap, &fattr->rdev);
 	if (status < 0)
 		goto xdr_error;
+	fattr->valid |= status;
 
 	status = decode_attr_space_used(xdr, bitmap, &fattr->du.nfs3.used);
 	if (status < 0)
 		goto xdr_error;
+	fattr->valid |= status;
 
 	status = decode_attr_time_access(xdr, bitmap, &fattr->atime);
 	if (status < 0)
 		goto xdr_error;
+	fattr->valid |= status;
 
 	status = decode_attr_time_metadata(xdr, bitmap, &fattr->ctime);
 	if (status < 0)
 		goto xdr_error;
+	fattr->valid |= status;
 
 	status = decode_attr_time_modify(xdr, bitmap, &fattr->mtime);
 	if (status < 0)
 		goto xdr_error;
+	fattr->valid |= status;
 
 	status = decode_attr_mounted_on_fileid(xdr, bitmap, &fileid);
 	if (status < 0)
 		goto xdr_error;
-	if (fattr->fileid == 0 && fileid != 0)
+	if (status != 0 && !(fattr->valid & status)) {
 		fattr->fileid = fileid;
+		fattr->valid |= status;
+	}
 
 	status = verify_attr_len(xdr, savep, attrlen);
-	if (status == 0)
-		fattr->valid = NFS_ATTR_FATTR_V4;
 xdr_error:
 	dprintk("%s: xdr returned %d\n", __func__, -status);
 	return status;

