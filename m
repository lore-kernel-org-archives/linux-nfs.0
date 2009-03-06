From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfsd: be creative with time stmaps so that NFS client can reliably discover changes
Date: Fri, 6 Mar 2009 17:12:21 +1100
Message-ID: <18864.48837.701952.150752@notabene.brown>
References: <18848.63422.177485.115103@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:46052 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751324AbZCFGMf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Mar 2009 01:12:35 -0500
In-Reply-To: message from Neil Brown on Sunday February 22
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sunday February 22, neilb@suse.de wrote:
> 
> Hi Bruce,
>  here is my current version if the [cm]time fiddling patch for your
>  consideration.
>  If you like it, you can pull it from
>       git://neil.brown.name/linux-2.6 nfsd-devel
>  (or just extract it from the email)
> 

It turned out that there was a problem with that patch.
Making the mtime of a file appear 1 nanosecond in the past for the first
second of its existence confuses (at least) tar.
When tar extracts a symlink that begins with '/', it first creates a
place-holder file and then when the whole archive has been extracted
it goes around checking all the place holder files to make sure they
haven't changed.  If they haven't they are replaced with the symlink.
This is some kind of protection against malicious tar archives which
could create a symlink, then install a file through it to some place
that the users isn't expecting.

Anyway, the previous nfsd patch causes tar to think that (almost) all
those place holder files had been changed and so the symlinks aren't
extracted.

I guess it isn't unreasonable for an application to expect that the
mtime of a file isn't going to change unexpectedly.  So there goes
some of my clever idea.

I think it is still safe to fiddle ctime on directories.  I believe
ctime is much less frequently checked, and directories are much more
likely to be changed independently by multiple programs.

Further, directories are the particular need.  If files change
multiple times in a second it is very likely that their size will
change as well and that will invalidate cached values.  Also locking
can be used to force the client to flush the cache where as that is
not possible with directories.

It is tempting to leave the effect on files but just modify ctime.
However having been burned by the 'tar' experience I feel like being
caution.

NFSv4 doesn't suffer these problems as the 'change-id' is sent
separately from the app-visible [cm]time.  So we do fiddle the time
on all objects for NFSv4

If you like, that patch can still be pulled from
       git://neil.brown.name/linux-2.6 nfsd-devel

Thanks for your consideration,
NeilBrown


>From 1f0adead843604a24e926eb2f934a9fd91401deb Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.de>
Date: Fri, 6 Mar 2009 17:09:32 +1100
Subject: [PATCH] nfsd: be creative with time stamps so that NFS clients can reliably discover changes

For NFS, mtime/ctime are used as the main mechanism for cache flushing
- when the time stamp changes, we flush the cache.  This is equally
true for NFSv4, though the timestamp is hidden in the changeid.

However with many filesystems the granularity of time stamps is one
second, and multiple changes can occur in one second.

This makes it unwise to ever return "now" for the [cm]time of a file,
as quite some time later there may have been a change since that time
was returned, but the time will still be the same.

However, some applications can get confused if they create a file,
check the timestamp, and then a little while later, find that the
timestamp has changed.

This is most likely to be a problem for files, and for the mtime.
So if we just fiddle the ctime on directories we are fairly safe
and still benefit (files are less of an issue as locking can be used
to ensure consistency, and file sizes very often change when the
contents change, unlike directories).

So if the ctime on a directory is "now" - to the granularity of the
filesystem, adjust it backwards the smallest possible amount.  Then
when a subsequent GETATTR checks the time, it will no longer be 'now',
so the correct time will be returned, and the client will notice that
the file could have changed.

This removes a possible directory cache consistency problem were a
client can cache an old version of a directories contents and never
discover that it is out-of-date (because neither ctime nor mtime
change).  The client must use ctime to validate directory caches for
this to work.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfsd/nfs3xdr.c         |   15 +++++++++++++--
 fs/nfsd/nfs4xdr.c         |    1 +
 fs/nfsd/nfsxdr.c          |    6 ++++--
 fs/nfsd/vfs.c             |   44 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfsd/nfsd.h |    3 +++
 include/linux/nfsd/xdr4.h |   13 +++++++++----
 6 files changed, 74 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 17d0dd9..e5f0097 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -47,6 +47,17 @@ encode_time3(__be32 *p, struct timespec *time)
 }
 
 static __be32 *
+encode_adjusted_time3(__be32 *p, struct timespec *time,
+		      struct svc_fh *fhp)
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
@@ -192,7 +203,7 @@ encode_fattr3(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
 	p = xdr_encode_hyper(p, stat->ino);
 	p = encode_time3(p, &stat->atime);
 	p = encode_time3(p, &stat->mtime);
-	p = encode_time3(p, &stat->ctime);
+	p = encode_adjusted_time3(p, &stat->ctime, fhp);
 
 	return p;
 }
@@ -249,7 +260,7 @@ encode_wcc_data(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp)
 			*p++ = xdr_one;
 			p = xdr_encode_hyper(p, (u64) fhp->fh_pre_size);
 			p = encode_time3(p, &fhp->fh_pre_mtime);
-			p = encode_time3(p, &fhp->fh_pre_ctime);
+			p = encode_adjusted_time3(p, &fhp->fh_pre_ctime, fhp);
 		} else {
 			*p++ = xdr_zero;
 		}
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index f65953b..95511b8 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1518,6 +1518,7 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 		 */
 		if ((buflen -= 8) < 0)
 			goto out_resource;
+		nfsd_adjust_time(&stat.ctime, fhp, 0);
 		WRITE32(stat.ctime.tv_sec);
 		WRITE32(stat.ctime.tv_nsec);
 	}
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index afd08e2..ac28b0e 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -197,8 +197,10 @@ encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
 	lease_get_mtime(dentry->d_inode, &time); 
 	*p++ = htonl((u32) time.tv_sec);
 	*p++ = htonl(time.tv_nsec ? time.tv_nsec / 1000 : 0); 
-	*p++ = htonl((u32) stat->ctime.tv_sec);
-	*p++ = htonl(stat->ctime.tv_nsec ? stat->ctime.tv_nsec / 1000 : 0);
+	time = stat->ctime;
+	nfsd_adjust_time(&time, fhp, 1000);
+	*p++ = htonl((u32) time.tv_sec);
+	*p++ = htonl(time.tv_nsec ? time.tv_nsec / 1000 : 0); 
 
 	return p;
 }
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6e50aaa..cd4d3ba 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -404,6 +404,50 @@ out_nfserr:
 	goto out;
 }
 
+void nfsd_adjust_time(struct timespec *time, struct svc_fh *fhp,
+		      int nanoseconds)
+{
+	/* because we use time stamps for caching, and because the
+	 * granularity of ctime might be fairly large (e.g. 1
+	 * second) it is unsafe to ever report 'now' as a timestamp -
+	 * as then we might report two timestmaps that are the same
+	 * despite there being a change to the file between them, and
+	 * then continue to report that same timestamp for a long
+	 * time.
+	 * So if a timestamp would correspond to 'now', change it to
+	 * one nanosecond/microsecond ago so that after 'now' as moved
+	 * on, the client will be able to see a new timestamp and will
+	 * update its cache.
+	 *
+	 * Note that we only do this for directories, and only for 
+	 * the 'ctime'.
+	 * Applications can get confused if times change unexpectedly.
+	 * ctime on directories is the least likely to confuse, and is
+	 * sufficient to remove most consequences of low-resolution
+	 * time stamps.
+	 *
+	 * We use a special nanoseconds value of '0' for NFSv4 to tell
+	 * us to skip the directory check.
+	 */
+	struct timespec now;
+
+	if (nanoseconds && !S_ISDIR(fhp->fh_dentry->d_inode->i_mode))
+		return;
+	if (!nanoseconds)
+		nanoseconds = 1;
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
index 27bd3e3..34f14da 100644
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
+	nfsd_adjust_time(&tm, fhp, 0);
+	cinfo->before_ctime_sec = tm.tv_sec;
+	cinfo->before_ctime_nsec = tm.tv_nsec;
+	tm = fhp->fh_post_attr.ctime;
+	nfsd_adjust_time(&tm, fhp, 0);
+	cinfo->after_ctime_sec = tm.tv_sec;
+	cinfo->after_ctime_nsec = tm.tv_nsec;
 }
 
 int nfs4svc_encode_voidres(struct svc_rqst *, __be32 *, void *);
-- 
1.6.1.3

