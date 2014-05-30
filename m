Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.kundenserver.de ([212.227.17.24]:51969 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030501AbaE3UHd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 May 2014 16:07:33 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, joseph@codesourcery.com,
        john.stultz@linaro.org, hch@infradead.org, tglx@linutronix.de,
        geert@linux-m68k.org, lftan@altera.com, hpa@zytor.com,
        linux-fsdevel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: [RFC 07/32] fs/nfs: convert to struct inode_time
Date: Fri, 30 May 2014 22:01:31 +0200
Message-Id: <1401480116-1973111-8-git-send-email-arnd@arndb.de>
In-Reply-To: <1401480116-1973111-1-git-send-email-arnd@arndb.de>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This makes the nfs client and server code use 'struct inode_time'
instead of 'struct timespec', to lift the time stamp limitation
on 32-bit systems. With NFS version 2 and 3, this means we can
represent years up until 2106 rather than 2038. With NFS version
4, the on-wire representation allows 64-bit seconds.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
---
 fs/nfs/callback.h         |  4 ++--
 fs/nfs/callback_xdr.c     |  6 +++---
 fs/nfs/file.c             |  2 +-
 fs/nfs/fscache-index.c    |  8 ++++----
 fs/nfs/inode.c            | 10 +++++-----
 fs/nfs/internal.h         |  4 ++--
 fs/nfs/netns.h            |  2 +-
 fs/nfs/nfs2xdr.c          |  8 ++++----
 fs/nfs/nfs3xdr.c          | 10 +++++-----
 fs/nfs/nfs4xdr.c          | 20 ++++++++++----------
 fs/nfsd/nfs3xdr.c         |  6 +++---
 fs/nfsd/nfsfh.h           |  4 ++--
 fs/nfsd/nfsxdr.c          |  2 +-
 include/linux/nfs_fs_sb.h |  2 +-
 include/linux/nfs_xdr.h   | 14 +++++++-------
 15 files changed, 51 insertions(+), 51 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 84326e9..3a3e6b4 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -71,8 +71,8 @@ struct cb_getattrres {
 	uint32_t bitmap[2];
 	uint64_t size;
 	uint64_t change_attr;
-	struct timespec ctime;
-	struct timespec mtime;
+	struct inode_time ctime;
+	struct inode_time mtime;
 };
 
 struct cb_recallargs {
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index f4ccfe6..177a6f7 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -596,7 +596,7 @@ static __be32 encode_attr_size(struct xdr_stream *xdr, const uint32_t *bitmap, u
 	return 0;
 }
 
-static __be32 encode_attr_time(struct xdr_stream *xdr, const struct timespec *time)
+static __be32 encode_attr_time(struct xdr_stream *xdr, const struct inode_time *time)
 {
 	__be32 *p;
 
@@ -608,14 +608,14 @@ static __be32 encode_attr_time(struct xdr_stream *xdr, const struct timespec *ti
 	return 0;
 }
 
-static __be32 encode_attr_ctime(struct xdr_stream *xdr, const uint32_t *bitmap, const struct timespec *time)
+static __be32 encode_attr_ctime(struct xdr_stream *xdr, const uint32_t *bitmap, const struct inode_time *time)
 {
 	if (!(bitmap[1] & FATTR4_WORD1_TIME_METADATA))
 		return 0;
 	return encode_attr_time(xdr,time);
 }
 
-static __be32 encode_attr_mtime(struct xdr_stream *xdr, const uint32_t *bitmap, const struct timespec *time)
+static __be32 encode_attr_mtime(struct xdr_stream *xdr, const uint32_t *bitmap, const struct inode_time *time)
 {
 	if (!(bitmap[1] & FATTR4_WORD1_TIME_MODIFY))
 		return 0;
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 4042ff5..9bdd210 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -772,7 +772,7 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 }
 
 static int
-is_time_granular(struct timespec *ts) {
+is_time_granular(struct inode_time *ts) {
 	return ((ts->tv_sec == 0) && (ts->tv_nsec <= 1000));
 }
 
diff --git a/fs/nfs/fscache-index.c b/fs/nfs/fscache-index.c
index 7cf2c46..ae75bad 100644
--- a/fs/nfs/fscache-index.c
+++ b/fs/nfs/fscache-index.c
@@ -157,10 +157,10 @@ const struct fscache_cookie_def nfs_fscache_super_index_def = {
  * cache object.
  */
 struct nfs_fscache_inode_auxdata {
-	struct timespec	mtime;
-	struct timespec	ctime;
-	loff_t		size;
-	u64		change_attr;
+	struct inode_time	mtime;
+	struct inode_time	ctime;
+	loff_t			size;
+	u64			change_attr;
 };
 
 /*
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index c496f8a..99c9145 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1107,14 +1107,14 @@ static unsigned long nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr
 	/* If we have atomic WCC data, we may update some attributes */
 	if ((fattr->valid & NFS_ATTR_FATTR_PRECTIME)
 			&& (fattr->valid & NFS_ATTR_FATTR_CTIME)
-			&& timespec_equal(&inode->i_ctime, &fattr->pre_ctime)) {
+			&& inode_time_equal(&inode->i_ctime, &fattr->pre_ctime)) {
 		memcpy(&inode->i_ctime, &fattr->ctime, sizeof(inode->i_ctime));
 		ret |= NFS_INO_INVALID_ATTR;
 	}
 
 	if ((fattr->valid & NFS_ATTR_FATTR_PREMTIME)
 			&& (fattr->valid & NFS_ATTR_FATTR_MTIME)
-			&& timespec_equal(&inode->i_mtime, &fattr->pre_mtime)) {
+			&& inode_time_equal(&inode->i_mtime, &fattr->pre_mtime)) {
 		memcpy(&inode->i_mtime, &fattr->mtime, sizeof(inode->i_mtime));
 		if (S_ISDIR(inode->i_mode))
 			nfsi->cache_validity |= NFS_INO_INVALID_DATA;
@@ -1163,7 +1163,7 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 		invalid |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
 
 	/* Verify a few of the more important attributes */
-	if ((fattr->valid & NFS_ATTR_FATTR_MTIME) && !timespec_equal(&inode->i_mtime, &fattr->mtime))
+	if ((fattr->valid & NFS_ATTR_FATTR_MTIME) && !inode_time_equal(&inode->i_mtime, &fattr->mtime))
 		invalid |= NFS_INO_INVALID_ATTR;
 
 	if (fattr->valid & NFS_ATTR_FATTR_SIZE) {
@@ -1185,7 +1185,7 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 	if ((fattr->valid & NFS_ATTR_FATTR_NLINK) && inode->i_nlink != fattr->nlink)
 		invalid |= NFS_INO_INVALID_ATTR;
 
-	if ((fattr->valid & NFS_ATTR_FATTR_ATIME) && !timespec_equal(&inode->i_atime, &fattr->atime))
+	if ((fattr->valid & NFS_ATTR_FATTR_ATIME) && !inode_time_equal(&inode->i_atime, &fattr->atime))
 		invalid |= NFS_INO_INVALID_ATIME;
 
 	if (invalid != 0)
@@ -1199,7 +1199,7 @@ static int nfs_ctime_need_update(const struct inode *inode, const struct nfs_fat
 {
 	if (!(fattr->valid & NFS_ATTR_FATTR_CTIME))
 		return 0;
-	return timespec_compare(&fattr->ctime, &inode->i_ctime) > 0;
+	return inode_time_compare(&fattr->ctime, &inode->i_ctime) > 0;
 }
 
 static int nfs_size_need_update(const struct inode *inode, const struct nfs_fattr *fattr)
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 0e4e804..97e06f1 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -605,14 +605,14 @@ unsigned int nfs_page_array_len(unsigned int base, size_t len)
 }
 
 /*
- * Convert a struct timespec into a 64-bit change attribute
+ * Convert a struct inode_time into a 64-bit change attribute
  *
  * This does approximately the same thing as timespec_to_ns(),
  * but for calculation efficiency, we multiply the seconds by
  * 1024*1024*1024.
  */
 static inline
-u64 nfs_timespec_to_change_attr(const struct timespec *ts)
+u64 nfs_time_to_change_attr(const struct inode_time *ts)
 {
 	return ((u64)ts->tv_sec << 30) + ts->tv_nsec;
 }
diff --git a/fs/nfs/netns.h b/fs/nfs/netns.h
index 8ee1fab..f665fbd 100644
--- a/fs/nfs/netns.h
+++ b/fs/nfs/netns.h
@@ -28,7 +28,7 @@ struct nfs_net {
 	int cb_users[NFS4_MAX_MINOR_VERSION + 1];
 #endif
 	spinlock_t nfs_client_lock;
-	struct timespec boot_time;
+	struct inode_time boot_time;
 };
 
 extern int nfs_net_id;
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 62db136..984b7cd 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -222,7 +222,7 @@ out_overflow:
  *		unsigned int useconds;
  *	};
  */
-static __be32 *xdr_encode_time(__be32 *p, const struct timespec *timep)
+static __be32 *xdr_encode_time(__be32 *p, const struct inode_time *timep)
 {
 	*p++ = cpu_to_be32(timep->tv_sec);
 	if (timep->tv_nsec != 0)
@@ -240,14 +240,14 @@ static __be32 *xdr_encode_time(__be32 *p, const struct timespec *timep)
  * Illustrated" by Brent Callaghan, Addison-Wesley, ISBN 0-201-32750-5.
  */
 static __be32 *xdr_encode_current_server_time(__be32 *p,
-					      const struct timespec *timep)
+					      const struct inode_time *timep)
 {
 	*p++ = cpu_to_be32(timep->tv_sec);
 	*p++ = cpu_to_be32(1000000);
 	return p;
 }
 
-static __be32 *xdr_decode_time(__be32 *p, struct timespec *timep)
+static __be32 *xdr_decode_time(__be32 *p, struct inode_time *timep)
 {
 	timep->tv_sec = be32_to_cpup(p++);
 	timep->tv_nsec = be32_to_cpup(p++) * NSEC_PER_USEC;
@@ -315,7 +315,7 @@ static int decode_fattr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 	p = xdr_decode_time(p, &fattr->atime);
 	p = xdr_decode_time(p, &fattr->mtime);
 	xdr_decode_time(p, &fattr->ctime);
-	fattr->change_attr = nfs_timespec_to_change_attr(&fattr->ctime);
+	fattr->change_attr = nfs_time_to_change_attr(&fattr->ctime);
 
 	return 0;
 out_uid:
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index fa6d721..09c40f2 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -477,21 +477,21 @@ static void zero_nfs_fh3(struct nfs_fh *fh)
 }
 
 /*
- * nfstime3
+ * nfstime3 
  *
  *	struct nfstime3 {
  *		uint32	seconds;
  *		uint32	nseconds;
  *	};
  */
-static __be32 *xdr_encode_nfstime3(__be32 *p, const struct timespec *timep)
+static __be32 *xdr_encode_nfstime3(__be32 *p, const struct inode_time *timep)
 {
 	*p++ = cpu_to_be32(timep->tv_sec);
 	*p++ = cpu_to_be32(timep->tv_nsec);
 	return p;
 }
 
-static __be32 *xdr_decode_nfstime3(__be32 *p, struct timespec *timep)
+static __be32 *xdr_decode_nfstime3(__be32 *p, struct inode_time *timep)
 {
 	timep->tv_sec = be32_to_cpup(p++);
 	timep->tv_nsec = be32_to_cpup(p++);
@@ -675,7 +675,7 @@ static int decode_fattr3(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 	p = xdr_decode_nfstime3(p, &fattr->atime);
 	p = xdr_decode_nfstime3(p, &fattr->mtime);
 	xdr_decode_nfstime3(p, &fattr->ctime);
-	fattr->change_attr = nfs_timespec_to_change_attr(&fattr->ctime);
+	fattr->change_attr = nfs_time_to_change_attr(&fattr->ctime);
 
 	fattr->valid |= NFS_ATTR_FATTR_V3;
 	return 0;
@@ -739,7 +739,7 @@ static int decode_wcc_attr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 	p = xdr_decode_size3(p, &fattr->pre_size);
 	p = xdr_decode_nfstime3(p, &fattr->pre_mtime);
 	xdr_decode_nfstime3(p, &fattr->pre_ctime);
-	fattr->pre_change_attr = nfs_timespec_to_change_attr(&fattr->pre_ctime);
+	fattr->pre_change_attr = nfs_time_to_change_attr(&fattr->pre_ctime);
 
 	return 0;
 out_overflow:
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 73ce8d4..a41265b 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4073,7 +4073,7 @@ out_overflow:
 	return -EIO;
 }
 
-static int decode_attr_time(struct xdr_stream *xdr, struct timespec *time)
+static int decode_attr_time(struct xdr_stream *xdr, struct inode_time *time)
 {
 	__be32 *p;
 	uint64_t sec;
@@ -4084,7 +4084,7 @@ static int decode_attr_time(struct xdr_stream *xdr, struct timespec *time)
 		goto out_overflow;
 	p = xdr_decode_hyper(p, &sec);
 	nsec = be32_to_cpup(p);
-	time->tv_sec = (time_t)sec;
+	time->tv_sec = sec;
 	time->tv_nsec = (long)nsec;
 	return 0;
 out_overflow:
@@ -4092,7 +4092,7 @@ out_overflow:
 	return -EIO;
 }
 
-static int decode_attr_time_access(struct xdr_stream *xdr, uint32_t *bitmap, struct timespec *time)
+static int decode_attr_time_access(struct xdr_stream *xdr, uint32_t *bitmap, struct inode_time *time)
 {
 	int status = 0;
 
@@ -4106,11 +4106,11 @@ static int decode_attr_time_access(struct xdr_stream *xdr, uint32_t *bitmap, str
 			status = NFS_ATTR_FATTR_ATIME;
 		bitmap[1] &= ~FATTR4_WORD1_TIME_ACCESS;
 	}
-	dprintk("%s: atime=%ld\n", __func__, (long)time->tv_sec);
+	dprintk("%s: atime=%lld\n", __func__, (long long)time->tv_sec);
 	return status;
 }
 
-static int decode_attr_time_metadata(struct xdr_stream *xdr, uint32_t *bitmap, struct timespec *time)
+static int decode_attr_time_metadata(struct xdr_stream *xdr, uint32_t *bitmap, struct inode_time *time)
 {
 	int status = 0;
 
@@ -4124,12 +4124,12 @@ static int decode_attr_time_metadata(struct xdr_stream *xdr, uint32_t *bitmap, s
 			status = NFS_ATTR_FATTR_CTIME;
 		bitmap[1] &= ~FATTR4_WORD1_TIME_METADATA;
 	}
-	dprintk("%s: ctime=%ld\n", __func__, (long)time->tv_sec);
+	dprintk("%s: ctime=%lld\n", __func__, (long long)time->tv_sec);
 	return status;
 }
 
 static int decode_attr_time_delta(struct xdr_stream *xdr, uint32_t *bitmap,
-				  struct timespec *time)
+				  struct inode_time *time)
 {
 	int status = 0;
 
@@ -4141,7 +4141,7 @@ static int decode_attr_time_delta(struct xdr_stream *xdr, uint32_t *bitmap,
 		status = decode_attr_time(xdr, time);
 		bitmap[1] &= ~FATTR4_WORD1_TIME_DELTA;
 	}
-	dprintk("%s: time_delta=%ld %ld\n", __func__, (long)time->tv_sec,
+	dprintk("%s: time_delta=%lld %ld\n", __func__, (long long)time->tv_sec,
 		(long)time->tv_nsec);
 	return status;
 }
@@ -4196,7 +4196,7 @@ out_overflow:
 	return -EIO;
 }
 
-static int decode_attr_time_modify(struct xdr_stream *xdr, uint32_t *bitmap, struct timespec *time)
+static int decode_attr_time_modify(struct xdr_stream *xdr, uint32_t *bitmap, struct inode_time *time)
 {
 	int status = 0;
 
@@ -4210,7 +4210,7 @@ static int decode_attr_time_modify(struct xdr_stream *xdr, uint32_t *bitmap, str
 			status = NFS_ATTR_FATTR_MTIME;
 		bitmap[1] &= ~FATTR4_WORD1_TIME_MODIFY;
 	}
-	dprintk("%s: mtime=%ld\n", __func__, (long)time->tv_sec);
+	dprintk("%s: mtime=%lld\n", __func__, (long long)time->tv_sec);
 	return status;
 }
 
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index de6e39e..46d2eb1 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -30,14 +30,14 @@ static u32	nfs3_ftypes[] = {
  * XDR functions for basic NFS types
  */
 static __be32 *
-encode_time3(__be32 *p, struct timespec *time)
+encode_time3(__be32 *p, struct inode_time *time)
 {
 	*p++ = htonl((u32) time->tv_sec); *p++ = htonl(time->tv_nsec);
 	return p;
 }
 
 static __be32 *
-decode_time3(__be32 *p, struct timespec *time)
+decode_time3(__be32 *p, struct inode_time *time)
 {
 	time->tv_sec = ntohl(*p++);
 	time->tv_nsec = ntohl(*p++);
@@ -292,7 +292,7 @@ nfs3svc_decode_sattrargs(struct svc_rqst *rqstp, __be32 *p,
 	p = decode_sattr3(p, &args->attrs);
 
 	if ((args->check_guard = ntohl(*p++)) != 0) { 
-		struct timespec time; 
+		struct inode_time time; 
 		p = decode_time3(p, &time);
 		args->guardtime = time.tv_sec;
 	}
diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
index 2e89e70..a7eb5af 100644
--- a/fs/nfsd/nfsfh.h
+++ b/fs/nfsd/nfsfh.h
@@ -39,8 +39,8 @@ typedef struct svc_fh {
 
 	/* Pre-op attributes saved during fh_lock */
 	__u64			fh_pre_size;	/* size before operation */
-	struct timespec		fh_pre_mtime;	/* mtime before oper */
-	struct timespec		fh_pre_ctime;	/* ctime before oper */
+	struct inode_time	fh_pre_mtime;	/* mtime before oper */
+	struct inode_time	fh_pre_ctime;	/* ctime before oper */
 	/*
 	 * pre-op nfsv4 change attr: note must check IS_I_VERSION(inode)
 	 *  to find out if it is valid.
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 9c769a4..cfac45c 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -146,7 +146,7 @@ encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
 {
 	struct dentry	*dentry = fhp->fh_dentry;
 	int type;
-	struct timespec time;
+	struct inode_time time;
 	u32 f;
 
 	type = (stat->mode & S_IFMT);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 1150ea4..2370468 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -147,7 +147,7 @@ struct nfs_server {
 
 	struct nfs_fsid		fsid;
 	__u64			maxfilesize;	/* maximum file size */
-	struct timespec		time_delta;	/* smallest time granularity */
+	struct inode_time	time_delta;	/* smallest time granularity */
 	unsigned long		mount_time;	/* when this fs was mounted */
 	struct super_block	*super;		/* VFS super block */
 	dev_t			s_dev;		/* superblock dev numbers */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 6fb5b23..ae27bf4 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -61,14 +61,14 @@ struct nfs_fattr {
 	struct nfs_fsid		fsid;
 	__u64			fileid;
 	__u64			mounted_on_fileid;
-	struct timespec		atime;
-	struct timespec		mtime;
-	struct timespec		ctime;
+	struct inode_time	atime;
+	struct inode_time	mtime;
+	struct inode_time	ctime;
 	__u64			change_attr;	/* NFSv4 change attribute */
 	__u64			pre_change_attr;/* pre-op NFSv4 change attribute */
 	__u64			pre_size;	/* pre_op_attr.size	  */
-	struct timespec		pre_mtime;	/* pre_op_attr.mtime	  */
-	struct timespec		pre_ctime;	/* pre_op_attr.ctime	  */
+	struct inode_time	pre_mtime;	/* pre_op_attr.mtime	  */
+	struct inode_time	pre_ctime;	/* pre_op_attr.ctime	  */
 	unsigned long		time_start;
 	unsigned long		gencount;
 	struct nfs4_string	*owner_name;
@@ -137,7 +137,7 @@ struct nfs_fsinfo {
 	__u32			wtmult;	/* writes should be multiple of this */
 	__u32			dtpref;	/* pref. readdir transfer size */
 	__u64			maxfilesize;
-	struct timespec		time_delta; /* server time granularity */
+	struct inode_time	time_delta; /* server time granularity */
 	__u32			lease_time; /* in seconds */
 	__u32			layouttype; /* supported pnfs layout driver */
 	__u32			blksize; /* preferred pnfs io block size */
@@ -745,7 +745,7 @@ struct nfs3_sattrargs {
 	struct nfs_fh *		fh;
 	struct iattr *		sattr;
 	unsigned int		guard;
-	struct timespec		guardtime;
+	struct inode_time	guardtime;
 };
 
 struct nfs3_diropargs {
-- 
1.8.3.2

