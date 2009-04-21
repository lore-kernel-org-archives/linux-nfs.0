From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Thoughts about cache consistency and directories in particular.
Date: Tue, 21 Apr 2009 17:43:49 -0400
Message-ID: <20090421214349.GD27411@fieldses.org>
References: <18846.4842.625445.980681@notabene.brown> <20090220182350.GB1104@fieldses.org> <18847.2286.101191.989726@notabene.brown> <20090220201424.GG1104@fieldses.org> <18847.6886.50844.260910@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, Theodore Tso <tytso@mit.edu>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:59939 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754909AbZDUVny (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2009 17:43:54 -0400
In-Reply-To: <18847.6886.50844.260910-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 21, 2009 at 08:04:38AM +1100, Neil Brown wrote:
> On Friday February 20, bfields@fieldses.org wrote:
> > On Sat, Feb 21, 2009 at 06:47:58AM +1100, Neil Brown wrote:
Once upon a time, I said:
> > > > By the way, I have one sadly neglected todo here: ext4 has a real nfsv4
> > > > changeattribute, which needs to be hooked up to the nfsd code.
> > > 
> > > Does it?
> > > I just had a quick look, found that it stores a 64 bit number on disk
> > > which is stored in inode->i_version.
> > > And this is incremented for directory operations.  But it doesn't seem
> > > to be changed for file operations.
> > > 
> > > But maybe I missed something.
> > 
> > After some mucking around with git and git grep... looks like the
> > inode_inc_iversion() calls do the job.  Note there's an i_version mount
> > option that's required.
> 
> Ahh.... Now if only they had called that function
> "inode_inc_i_version", then my grep would have found it...
> 
> So in nfsd we can simply do:
> 
>  if (IS_I_VERSION(fhp->fh_dentry->d_inode)) {
> 	change_attribute = fhp->fh_dentry->d_inode->i_version;
>  } else {
>         change_attribute = kstat.ctime;
>  }
> 
> ??

There's also the pre-/post- op attributes to take care of.  I'm thinking
of applying something like the following.

Actually, I did this and then realized: I'm using IS_I_VERSION(inode) to
turn on use of the i_version as the change attribute on both files and
directories.  But it actually only makes a difference for files.

So I guess I should just be using i_version as the change attribute
unconditionally for directories?  (Will that work on any filesystem?)

--b.

commit 6bc1eaa4eb1bb8af1878be354962e6cedcaece60
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Thu Apr 16 17:33:25 2009 -0400

    nfsd: support ext4 i_version
    
    ext4 supports a real NFSv4 change attribute, which is bumped whenever
    the ctime would be updated, including times when two updates arrive
    within a jiffy of each other.  (Note that although ext4 has space for
    nanosecond-precision ctime, the real resolution is lower: it actually
    uses jiffies as the time-source.)  This ensures clients will invalidate
    their caches when they need to.
    
    There is some fear that keeping the i_version up-to-date could have
    performance drawbacks, so for now it's turned on only by a mount option.
    We hope to do something better eventually.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Cc: Theodore Tso <tytso@mit.edu>

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 17d0dd9..01d4ec1 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -272,6 +272,7 @@ void fill_post_wcc(struct svc_fh *fhp)
 
 	err = vfs_getattr(fhp->fh_export->ex_path.mnt, fhp->fh_dentry,
 			&fhp->fh_post_attr);
+	fhp->fh_post_change = fhp->fh_dentry->d_inode->i_version;
 	if (err)
 		fhp->fh_post_saved = 0;
 	else
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 4a71fcd..12d36a7 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1490,13 +1490,41 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	memcpy(p, ptr, nbytes);					\
 	p += XDR_QUADLEN(nbytes);				\
 }} while (0)
-#define WRITECINFO(c)		do {				\
-	*p++ = htonl(c.atomic);					\
-	*p++ = htonl(c.before_ctime_sec);				\
-	*p++ = htonl(c.before_ctime_nsec);				\
-	*p++ = htonl(c.after_ctime_sec);				\
-	*p++ = htonl(c.after_ctime_nsec);				\
-} while (0)
+
+static void write32(__be32 **p, u32 n)
+{
+	*(*p)++ = n;
+}
+
+static void write64(__be32 **p, u64 n)
+{
+	write32(p, (u32)(n >> 32));
+	write32(p, (u32)n);
+}
+
+static void write_change(__be32 **p, struct kstat *stat, struct inode *inode)
+{
+	if (IS_I_VERSION(inode)) {
+		write64(p, inode->i_version);
+	} else {
+		write32(p, stat->ctime.tv_sec);
+		write32(p, stat->ctime.tv_nsec);
+	}
+}
+
+static void write_cinfo(__be32 **p, struct nfsd4_change_info *c)
+{
+	write32(p, c->atomic);
+	if (c->change_supported) {
+		write64(p, c->before_change);
+		write64(p, c->after_change);
+	} else {
+		write32(p, c->before_ctime_sec);
+		write32(p, c->before_ctime_nsec);
+		write32(p, c->after_ctime_sec);
+		write32(p, c->after_ctime_nsec);
+	}
+}
 
 #define RESERVE_SPACE(nbytes)	do {				\
 	p = resp->p;						\
@@ -1849,16 +1877,9 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 			WRITE32(NFS4_FH_PERSISTENT|NFS4_FH_VOL_RENAME);
 	}
 	if (bmval0 & FATTR4_WORD0_CHANGE) {
-		/*
-		 * Note: This _must_ be consistent with the scheme for writing
-		 * change_info, so any changes made here must be reflected there
-		 * as well.  (See xdr4.h:set_change_info() and the WRITECINFO()
-		 * macro above.)
-		 */
 		if ((buflen -= 8) < 0)
 			goto out_resource;
-		WRITE32(stat.ctime.tv_sec);
-		WRITE32(stat.ctime.tv_nsec);
+		write_change(&p, &stat, dentry->d_inode);
 	}
 	if (bmval0 & FATTR4_WORD0_SIZE) {
 		if ((buflen -= 8) < 0)
@@ -2364,7 +2385,7 @@ nfsd4_encode_create(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 
 	if (!nfserr) {
 		RESERVE_SPACE(32);
-		WRITECINFO(create->cr_cinfo);
+		write_cinfo(&p, &create->cr_cinfo);
 		WRITE32(2);
 		WRITE32(create->cr_bmval[0]);
 		WRITE32(create->cr_bmval[1]);
@@ -2475,7 +2496,7 @@ nfsd4_encode_link(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_li
 
 	if (!nfserr) {
 		RESERVE_SPACE(20);
-		WRITECINFO(link->li_cinfo);
+		write_cinfo(&p, &link->li_cinfo);
 		ADJUST_ARGS();
 	}
 	return nfserr;
@@ -2493,7 +2514,7 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 
 	nfsd4_encode_stateid(resp, &open->op_stateid);
 	RESERVE_SPACE(40);
-	WRITECINFO(open->op_cinfo);
+	write_cinfo(&p, &open->op_cinfo);
 	WRITE32(open->op_rflags);
 	WRITE32(2);
 	WRITE32(open->op_bmval[0]);
@@ -2771,7 +2792,7 @@ nfsd4_encode_remove(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 
 	if (!nfserr) {
 		RESERVE_SPACE(20);
-		WRITECINFO(remove->rm_cinfo);
+		write_cinfo(&p, &remove->rm_cinfo);
 		ADJUST_ARGS();
 	}
 	return nfserr;
@@ -2784,8 +2805,8 @@ nfsd4_encode_rename(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 
 	if (!nfserr) {
 		RESERVE_SPACE(40);
-		WRITECINFO(rename->rn_sinfo);
-		WRITECINFO(rename->rn_tinfo);
+		write_cinfo(&p, &rename->rn_sinfo);
+		write_cinfo(&p, &rename->rn_tinfo);
 		ADJUST_ARGS();
 	}
 	return nfserr;
diff --git a/include/linux/nfsd/nfsfh.h b/include/linux/nfsd/nfsfh.h
index afa1901..8f641c9 100644
--- a/include/linux/nfsd/nfsfh.h
+++ b/include/linux/nfsd/nfsfh.h
@@ -151,9 +151,15 @@ typedef struct svc_fh {
 	__u64			fh_pre_size;	/* size before operation */
 	struct timespec		fh_pre_mtime;	/* mtime before oper */
 	struct timespec		fh_pre_ctime;	/* ctime before oper */
+	/*
+	 * pre-op nfsv4 change attr: note must check IS_I_VERSION(inode)
+	 *  to find out if it is valid.
+	 */
+	u64			fh_pre_change;
 
 	/* Post-op attributes saved in fh_unlock */
 	struct kstat		fh_post_attr;	/* full attrs after operation */
+	u64			fh_post_change; /* nfsv4 change; see above */
 #endif /* CONFIG_NFSD_V3 */
 
 } svc_fh;
@@ -298,6 +304,7 @@ fill_pre_wcc(struct svc_fh *fhp)
 		fhp->fh_pre_mtime = inode->i_mtime;
 		fhp->fh_pre_ctime = inode->i_ctime;
 		fhp->fh_pre_size  = inode->i_size;
+		fhp->fh_pre_change = inode->i_version;
 		fhp->fh_pre_saved = 1;
 	}
 }
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index f80d601..d0f050f 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -64,10 +64,13 @@ static inline bool nfsd4_has_session(struct nfsd4_compound_state *cs)
 
 struct nfsd4_change_info {
 	u32		atomic;
+	bool		change_supported;
 	u32		before_ctime_sec;
 	u32		before_ctime_nsec;
+	u64		before_change;
 	u32		after_ctime_sec;
 	u32		after_ctime_nsec;
+	u64		after_change;
 };
 
 struct nfsd4_access {
@@ -503,10 +506,16 @@ set_change_info(struct nfsd4_change_info *cinfo, struct svc_fh *fhp)
 {
 	BUG_ON(!fhp->fh_pre_saved || !fhp->fh_post_saved);
 	cinfo->atomic = 1;
-	cinfo->before_ctime_sec = fhp->fh_pre_ctime.tv_sec;
-	cinfo->before_ctime_nsec = fhp->fh_pre_ctime.tv_nsec;
-	cinfo->after_ctime_sec = fhp->fh_post_attr.ctime.tv_sec;
-	cinfo->after_ctime_nsec = fhp->fh_post_attr.ctime.tv_nsec;
+	cinfo->change_supported = IS_I_VERSION(fhp->fh_dentry->d_inode);
+	if (cinfo->change_supported) {
+		cinfo->before_change = fhp->fh_pre_change;
+		cinfo->after_change = fhp->fh_post_change;
+	} else {
+		cinfo->before_ctime_sec = fhp->fh_pre_ctime.tv_sec;
+		cinfo->before_ctime_nsec = fhp->fh_pre_ctime.tv_nsec;
+		cinfo->after_ctime_sec = fhp->fh_post_attr.ctime.tv_sec;
+		cinfo->after_ctime_nsec = fhp->fh_post_attr.ctime.tv_nsec;
+	}
 }
 
 int nfs4svc_encode_voidres(struct svc_rqst *, __be32 *, void *);
