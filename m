Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:36647 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbbICTyV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Sep 2015 15:54:21 -0400
Received: by ykcf206 with SMTP id f206so164782ykc.3
        for <linux-nfs@vger.kernel.org>; Thu, 03 Sep 2015 12:54:20 -0700 (PDT)
Date: Thu, 3 Sep 2015 15:54:17 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: add a new nowcc export option to disable WCC
 attrs in v3 replies
Message-ID: <20150903155417.468aaca0@tlielax.poochiereds.net>
In-Reply-To: <20150903191914.GF10088@fieldses.org>
References: <1441301594-17293-1-git-send-email-jeff.layton@primarydata.com>
	<20150903184327.GC10088@fieldses.org>
	<20150903145225.3a3a3776@tlielax.poochiereds.net>
	<20150903191914.GF10088@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 3 Sep 2015 15:19:14 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Sep 03, 2015 at 02:52:25PM -0400, Jeff Layton wrote:
> > On Thu, 3 Sep 2015 14:43:27 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Thu, Sep 03, 2015 at 01:33:14PM -0400, Jeff Layton wrote:
> > > > There are cases with NFSv3 where the client doesn't actually care about
> > > > WCC attributes in replies. If the server is mainly acting as a DS for
> > > > flexfiles, then the client just throws out those attributes anyway.
> > > > Also, in the case where the client is primarily doing direct I/O, post
> > > > op attributes aren't terribly useful
> > > >
> > > > Another reason to allow turning these off is that NFS will flush all
> > > > buffered writes prior to issuing a GETATTR, and it also takes the
> > > > i_mutex in its ->getattr operation.
> > > >
> > > > If we're doing a vfs_getattr after most RPCs, then we can end up
> > > > deadlocking or (at best) prematurely flushing buffered writes, which
> > > > kills performance.
> > > 
> > > So you're talking about the NFS re-export case?  Do we know of any other
> > > case when a ->getattr is so expensive?
> > > 
> > 
> > That's the main one that I have experience with, but getattr can be
> > pretty expensive in clustered filesystems. For instance, on ceph:
> > 
> >         err = ceph_do_getattr(inode, CEPH_STAT_CAP_INODE_ALL, false);
> >         if (!err) {
> >                 generic_fillattr(inode, stat);
> >                 stat->ino = ceph_translate_ino(inode->i_sb, inode->i_ino);
> > 
> > 
> > ...and it looks like ceph_do_getattr can issue a request on the network
> > (though I'm not familiar with that code and I imagine that it's
> > sometimes optimized out).
> 
> OK.  Could we get something like that in the changelog?  The change
> really needs to stand on the non-NFS case alone as long as NFS
> reexport's not upstream.  For that reason (and because without the
> context that second paragraph's kind of confusing), it'd be helpful to
> preface the NFS discussion by smoething like "In the (out-of-tree) NFS
> re-export case".
> 

Yeah, no problem. I'll respin the changelog on both patches and resend
within the next day or two.

> What's keeping that out of upstream, anyway?  Apparently there's some
> use case, and if it's inspiring a lot of changes in generic code, then
> it'd simplify life to have it upstream.
> 
> 

There are several problems. Here are few but there are others:

1) it is at least somewhat of a potential security concern. By mounting
on a box that has access and then reexporting it, you can circumvent
the export restrictions on the original server. Granted you can do that
today with samba or something, but still -- it's a little sketchy.

2) getattrs: We're working around the problem with this new export
option, but if you don't use that then you can potentially deadlock
with NFS. It wants to take the i_mutex in its ->getattr operation but
knfsd calls vfs_getattr with that held to do post-op attrs. My initial
workaround was to drop the i_mutex before calling fh_getattr instead of
after, but then I hit the performance problem I described.

3) locking: proxying v3 locking is a painful mess. If the reexporter
reboots, it'll lose its lease on the main server, which will kick out
all of its state. At that point you can end up with another client
racing and getting your lock before the reexporter can come back up and
reclaim it.

Our main use-case for this is pretty limited and doesn't involve file
locking (so far!). We'll probably have to code up some mechanism to
deal with that at some point, but that won't be an in-kernel solution.

Once we ship this thing, the kernel changes will be GPLed of course for
anyone who wants to use them, but I'm not sure any of us really want the
headache of merging this upstream as a first-class feature.

> > 
> > 
> > > 
> > > > This patch adds a new export option -- "nowcc" that disables the
> > > > return of WCC attributes in NFSv3 replies. I also have a userland
> > > > patch that adds support for the same option to nfs-utils that I'll
> > > > send along as well.
> > > > 
> > > > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> > > > ---
> > > >  fs/nfsd/export.c                 | 1 +
> > > >  fs/nfsd/nfs3xdr.c                | 5 ++++-
> > > >  fs/nfsd/nfsfh.c                  | 4 ++++
> > > >  fs/nfsd/nfsfh.h                  | 5 ++++-
> > > >  include/uapi/linux/nfsd/export.h | 3 ++-
> > > >  5 files changed, 15 insertions(+), 3 deletions(-)
> > > > 
> > > > diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> > > > index b4d84b579f20..97258009ce1e 100644
> > > > --- a/fs/nfsd/export.c
> > > > +++ b/fs/nfsd/export.c
> > > > @@ -1092,6 +1092,7 @@ static struct flags {
> > > >  	{ NFSEXP_NOAUTHNLM, {"insecure_locks", ""}},
> > > >  	{ NFSEXP_V4ROOT, {"v4root", ""}},
> > > >  	{ NFSEXP_PNFS, {"pnfs", ""}},
> > > > +	{ NFSEXP_NOWCC, {"nowcc", ""}},
> > > >  	{ 0, {"", ""}}
> > > >  };
> > > >  
> > > > diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> > > > index 01dcd494f781..c30c8c604e2a 100644
> > > > --- a/fs/nfsd/nfs3xdr.c
> > > > +++ b/fs/nfsd/nfs3xdr.c
> > > > @@ -203,7 +203,7 @@ static __be32 *
> > > >  encode_post_op_attr(struct svc_rqst *rqstp, __be32 *p, struct
> > > > svc_fh *fhp) {
> > > >  	struct dentry *dentry = fhp->fh_dentry;
> > > > -	if (dentry && d_really_is_positive(dentry)) {
> > > > +	if (!fhp->fh_no_wcc && dentry &&
> > > > d_really_is_positive(dentry)) { __be32 err;
> > > >  		struct kstat stat;
> > > >  
> > > > @@ -256,6 +256,9 @@ void fill_post_wcc(struct svc_fh *fhp)
> > > >  {
> > > >  	__be32 err;
> > > >  
> > > > +	if (fhp->fh_no_wcc)
> > > > +		return;
> > > > +
> > > >  	if (fhp->fh_post_saved)
> > > >  		printk("nfsd: inode locked twice during
> > > > operation.\n"); 
> > > > diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
> > > > index 350041a40fe5..32093b7dce55 100644
> > > > --- a/fs/nfsd/nfsfh.c
> > > > +++ b/fs/nfsd/nfsfh.c
> > > > @@ -267,6 +267,9 @@ static __be32 nfsd_set_fh_dentry(struct
> > > > svc_rqst *rqstp, struct svc_fh *fhp) 
> > > >  	fhp->fh_dentry = dentry;
> > > >  	fhp->fh_export = exp;
> > > > +	if (exp->ex_flags & NFSEXP_NOWCC && rqstp->rq_vers == 3)
> > > > +		fhp->fh_no_wcc = true;
> > > > +
> > > >  	return 0;
> > > >  out:
> > > >  	exp_put(exp);
> > > > @@ -641,6 +644,7 @@ fh_put(struct svc_fh *fhp)
> > > >  		exp_put(exp);
> > > >  		fhp->fh_export = NULL;
> > > >  	}
> > > > +	fhp->fh_no_wcc = false;
> > > >  	return;
> > > >  }
> > > >  
> > > > diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
> > > > index 1e90dad4926b..9ddead4d98f8 100644
> > > > --- a/fs/nfsd/nfsfh.h
> > > > +++ b/fs/nfsd/nfsfh.h
> > > > @@ -32,6 +32,7 @@ typedef struct svc_fh {
> > > >  
> > > >  	unsigned char		fh_locked;	/* inode
> > > > locked by us */ unsigned char
> > > > fh_want_write;	/* remount protection taken */
> > > > +	bool			fh_no_wcc;	/* no wcc
> > > > data needed */ 
> > > >  #ifdef CONFIG_NFSD_V3
> > > >  	unsigned char		fh_post_saved;	/*
> > > > post-op attrs saved */ @@ -51,7 +52,6 @@ typedef struct svc_fh {
> > > >  	struct kstat		fh_post_attr;	/* full
> > > > attrs after operation */ u64
> > > > fh_post_change; /* nfsv4 change; see above */ #endif /*
> > > > CONFIG_NFSD_V3 */ -
> > > >  } svc_fh;
> > > >  
> > > >  enum nfsd_fsid {
> > > > @@ -225,6 +225,9 @@ fill_pre_wcc(struct svc_fh *fhp)
> > > >  {
> > > >  	struct inode    *inode;
> > > >  
> > > > +	if (fhp->fh_no_wcc)
> > > > +		return;
> > > > +
> > > >  	inode = d_inode(fhp->fh_dentry);
> > > >  	if (!fhp->fh_pre_saved) {
> > > >  		fhp->fh_pre_mtime = inode->i_mtime;
> > > > diff --git a/include/uapi/linux/nfsd/export.h
> > > > b/include/uapi/linux/nfsd/export.h index 0df7bd5d2fb1..4c132290f414
> > > > 100644 --- a/include/uapi/linux/nfsd/export.h
> > > > +++ b/include/uapi/linux/nfsd/export.h
> > > > @@ -51,9 +51,10 @@
> > > >   */
> > > >  #define	NFSEXP_V4ROOT		0x10000
> > > >  #define NFSEXP_PNFS		0x20000
> > > > +#define NFSEXP_NOWCC		0x40000
> > > >  
> > > >  /* All flags that we claim to support.  (Note we don't support
> > > > NOACL.) */ -#define NFSEXP_ALLFLAGS		0x3FE7F
> > > > +#define NFSEXP_ALLFLAGS		0x7FE7F
> > > >  
> > > >  /* The flags that may vary depending on security flavor: */
> > > >  #define NFSEXP_SECINFO_FLAGS	(NFSEXP_READONLY |
> > > > NFSEXP_ROOTSQUASH \ -- 
> > > > 2.4.3
> > 
> > 
> > -- 
> > Jeff Layton <jlayton@poochiereds.net>


-- 
Jeff Layton <jlayton@poochiereds.net>
