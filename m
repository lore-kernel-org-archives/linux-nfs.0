From: Neil Brown <neilb@suse.de>
Subject: [PATCH] nfsd: be creative with time stmaps so that NFS client can reliably discover changes
Date: Sun, 22 Feb 2009 17:59:10 +1100
Message-ID: <18848.63422.177485.115103@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:50673 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751239AbZBVG7R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 22 Feb 2009 01:59:17 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Bruce,
 here is my current version if the [cm]time fiddling patch for your
 consideration.
 If you like it, you can pull it from
      git://neil.brown.name/linux-2.6 nfsd-devel
 (or just extract it from the email)

Thanks,
NeilBrown


>From 97574eaf53b3acce45379b6df4351bcb1f32936f Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.de>
Date: Sun, 22 Feb 2009 08:19:21 +1100
Subject: [PATCH] nfsd: be creative with time stmaps so that NFS client can reliably discover changes

For NFS, mtime/ctime are used as the main mechanism for cache
flushing - when mtime changes, we flush the cache.  This is equally
true for NFSv4, though the timestamp is hidden in the changeid.

However with many filesystems the granularity of mtime is one second,
and multiple changes can occur in one second.

This makes it unwise to ever return "now" for the [cm]time of a file,
as quite some time later there may have been a change since that time
was returned, but the time will still be the same.

So if a timestamp is "now" - to the granularity of the filesystem,
adjust it backwards the smallest possible amount.   Then when a
subsequent GETATTR checks the time, it will no longer be 'now', so
the correct time will be returned, and the client will notice that
the file could have changed.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfsd/nfs3xdr.c         |   19 +++++++++++++++----
 fs/nfsd/nfs4xdr.c         |    1 +
 fs/nfsd/nfsxdr.c          |    7 +++++--
 fs/nfsd/vfs.c             |   29 +++++++++++++++++++++++++++++
 include/linux/nfsd/nfsd.h |    3 +++
 include/linux/nfsd/xdr4.h |   13 +++++++++----
 6 files changed, 62 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 17d0dd9..98d4be0 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -47,6 +47,17 @@ encode_time3(__be32 *p, struct timespec *time)
 }
 
 static __be32 *
+encode_adjusted_time3(__be32 *p, struct timespec *time,
+		      struct svc_fh *fhp, int nanoseconds)
+{
+	struct timespec tm = *time;
+	nfsd_adjust_time(&tm, fhp, 1);
+	*p++ = htonl((u32) tm.tv_sec);
+	*p++ = htonl(tm.tv_nsec);
+	return p;
+}
+
+static __be32 *
 decode_time3(__be32 *p, struct timespec *time)
 {
 	time->tv_sec = ntohl(*p++);
@@ -191,8 +202,8 @@ encode_fattr3(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
 	p = encode_fsid(p, fhp);
 	p = xdr_encode_hyper(p, stat->ino);
 	p = encode_time3(p, &stat->atime);
-	p = encode_time3(p, &stat->mtime);
-	p = encode_time3(p, &stat->ctime);
+	p = encode_adjusted_time3(p, &stat->mtime, fhp, 1);
+	p = encode_adjusted_time3(p, &stat->ctime, fhp, 1);
 
 	return p;
 }
@@ -248,8 +259,8 @@ encode_wcc_data(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp)
 		if (fhp->fh_pre_saved) {
 			*p++ = xdr_one;
 			p = xdr_encode_hyper(p, (u64) fhp->fh_pre_size);
-			p = encode_time3(p, &fhp->fh_pre_mtime);
-			p = encode_time3(p, &fhp->fh_pre_ctime);
+			p = encode_adjusted_time3(p, &fhp->fh_pre_mtime, fhp, 1);
+			p = encode_adjusted_time3(p, &fhp->fh_pre_ctime, fhp, 1);
 		} else {
 			*p++ = xdr_zero;
 		}
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index f65953b..65126be 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1518,6 +1518,7 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 		 */
 		if ((buflen -= 8) < 0)
 			goto out_resource;
+		nfsd_adjust_time(&stat.ctime, fhp, 1);
 		WRITE32(stat.ctime.tv_sec);
 		WRITE32(stat.ctime.tv_nsec);
 	}
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index afd08e2..a7db164 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -195,10 +195,13 @@ encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
 	*p++ = htonl((u32) stat->atime.tv_sec);
 	*p++ = htonl(stat->atime.tv_nsec ? stat->atime.tv_nsec / 1000 : 0);
 	lease_get_mtime(dentry->d_inode, &time); 
+	nfsd_adjust_time(&time, fhp, 1000);
+	*p++ = htonl((u32) time.tv_sec);
+	*p++ = htonl(time.tv_nsec ? time.tv_nsec / 1000 : 0); 
+	time = stat->ctime;
+	nfsd_adjust_time(&time, fhp, 1000);
 	*p++ = htonl((u32) time.tv_sec);
 	*p++ = htonl(time.tv_nsec ? time.tv_nsec / 1000 : 0); 
-	*p++ = htonl((u32) stat->ctime.tv_sec);
-	*p++ = htonl(stat->ctime.tv_nsec ? stat->ctime.tv_nsec / 1000 : 0);
 
 	return p;
 }
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6e50aaa..b69f3ea 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -404,6 +404,35 @@ out_nfserr:
 	goto out;
 }
 
+void nfsd_adjust_time(struct timespec *time, struct svc_fh *fhp,
+		      int nanoseconds)
+{
+	/* because we use time stamps for caching, and because the
+	 * granularity of ctime/mtime might be fairly large (e.g. 1
+	 * second) it is unsafe to ever report 'now' as a timestamp -
+	 * as then we might report two timestmaps that are the same
+	 * despite there being a change to the file between them, and
+	 * then continue to report that same timestamp for a long
+	 * time.
+	 * So if a timestamp would correspond to 'now', change it to
+	 * one nanosecond/microsecond ago so that after 'now' as moved
+	 * on, the client will be able to see a new timestamp and will
+	 * update its cache.
+	 */
+	struct timespec now;
+	now = current_fs_time(fhp->fh_dentry->d_inode->i_sb);
+	if (time->tv_sec == now.tv_sec &&
+	    time->tv_nsec == now.tv_nsec) {
+		if (time->tv_nsec >= nanoseconds)
+			time->tv_nsec -= nanoseconds;
+		else {
+			time->tv_nsec = 1000000000 - nanoseconds;
+			time->tv_sec -= 1;
+		}
+	}
+}
+
+
 #if defined(CONFIG_NFSD_V2_ACL) || \
     defined(CONFIG_NFSD_V3_ACL) || \
     defined(CONFIG_NFSD_V4)
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index e19f459..99be485 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -132,6 +132,9 @@ __be32		nfsd_permission(struct svc_rqst *, struct svc_export *,
 				struct dentry *, int);
 int		nfsd_sync_dir(struct dentry *dp);
 
+void		nfsd_adjust_time(struct timespec *time, struct svc_fh *fhp,
+				 int nanoseconds);
+
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
 #ifdef CONFIG_NFSD_V2_ACL
 extern struct svc_version nfsd_acl_version2;
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 27bd3e3..116fe9e 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -424,12 +424,17 @@ struct nfsd4_compoundres {
 static inline void
 set_change_info(struct nfsd4_change_info *cinfo, struct svc_fh *fhp)
 {
+	struct timespec tm;
 	BUG_ON(!fhp->fh_pre_saved || !fhp->fh_post_saved);
 	cinfo->atomic = 1;
-	cinfo->before_ctime_sec = fhp->fh_pre_ctime.tv_sec;
-	cinfo->before_ctime_nsec = fhp->fh_pre_ctime.tv_nsec;
-	cinfo->after_ctime_sec = fhp->fh_post_attr.ctime.tv_sec;
-	cinfo->after_ctime_nsec = fhp->fh_post_attr.ctime.tv_nsec;
+	tm = fhp->fh_pre_ctime;
+	nfsd_adjust_time(&tm, fhp, 1);
+	cinfo->before_ctime_sec = tm.tv_sec;
+	cinfo->before_ctime_nsec = tm.tv_nsec;
+	tm = fhp->fh_post_attr.ctime;
+	nfsd_adjust_time(&tm, fhp, 1);
+	cinfo->after_ctime_sec = tm.tv_sec;
+	cinfo->after_ctime_nsec = tm.tv_nsec;
 }
 
 int nfs4svc_encode_voidres(struct svc_rqst *, __be32 *, void *);
-- 
1.6.1.3

