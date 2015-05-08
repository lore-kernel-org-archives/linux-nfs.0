Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49284 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752214AbbEHQP7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 May 2015 12:15:59 -0400
Date: Fri, 8 May 2015 12:15:58 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under pseudo
 root
Message-ID: <20150508161558.GA18851@fieldses.org>
References: <20150429125728.69ddfc6c@notabene.brown>
 <20150429191934.GA23980@fieldses.org>
 <20150430075225.21a71056@notabene.brown>
 <20150430213602.GB9509@fieldses.org>
 <20150501115326.51f5613a@notabene.brown>
 <20150504220130.GB16827@fieldses.org>
 <5548CBA3.9080608@gmail.com>
 <20150505141801.GB27106@fieldses.org>
 <20150505155203.GD27106@fieldses.org>
 <20150506082628.0dd049c7@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150506082628.0dd049c7@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 06, 2015 at 08:26:28AM +1000, NeilBrown wrote:
> On Tue, 5 May 2015 11:52:03 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> > diff --git a/fs/namei.c b/fs/namei.c
> > index 4a8d998b7274..0f554bf41dea 100644
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -2139,6 +2139,8 @@ static struct dentry *lookup_hash(struct nameidata *nd)
> >   *
> >   * Note that this routine is purely a helper for filesystem usage and should
> >   * not be called by generic code.
> > + *
> > + * Must be called with the parented i_mutex held.
> 
> "parented"?
> 
>     * base->i_mutex must be held by caller.
> 
> ??

Thanks.

> > +struct dentry *lookup_one_len_unlocked(const char *name,
...
> > +	ret = __d_lookup(base, &this);
> > +	if (ret)
> > +		return ret;
> 
> __d_lookup() is a little too low level, as it doesn't call d_revalidate() and
> it doesn't retry if the rename_lock seqlock says it should.
> 
> The latter doesn't really matter as we would fall through to the safe
> mutex-protected version.
> The former isn't much of an issue for most filesystems under nfsd, but still
> needs to be handled to some extent.
> Also, the comment for __d_lookup says
> 
>  * __d_lookup callers must be commented.
> 
> The simplest resolution would be:
> 
> 	/* __d_lookup() is used to try to get a quick answer and avoid the
> 	 * mutex.  A false-negative does no harm.
> 	 */
> 	ret = __d_lookup(base, &this);
> 	if (ret && ret->d_flags & DCACHE_OP_REVALIDATE) {
> 		dput(ret);
> 		ret = NULL;
> 	}
> 	if (ret)
> 		return ret;

That looks right to me....  I'll probably take the simple option.

> > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > index a30e79900086..4accdb00976b 100644
> > --- a/fs/nfsd/vfs.c
> > +++ b/fs/nfsd/vfs.c
> > @@ -217,6 +217,13 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
> >  		host_err = PTR_ERR(dentry);
> >  		if (IS_ERR(dentry))
> >  			goto out_nfserr;
> > +		if (!(d_inode(dentry) && S_ISREG(d_inode(dentry)->i_mode))) {
> > +			/*
> > +			 * Never mind, we're not going to open this
> > +			 * anyway.  And we don't want to hold it over
> > +			 * the userspace upcalls in nfsd_mountpoint. */
> > +			fh_unlock(fhp);
> > +		}
> 
> You could avoid the test by just putting the fh_unlock(fhp) inside the 
> 
> 		if (nfsd_mountpoint(dentry, exp)) {
> 
> block.  It might also be appropriate for nfsd_mountpoint to fail on
> non-directories.

If check_export()'s to be believed, our support for regular-file
exports is intentional. So even if nfsd_mountpoint() is true, it's
possible we might still be about to open the result.

But I think we're OK:
 
The only reason for keeping the i_mutex here in the open case is to
avoid the situation where a client does OPEN(dirfh, "foo") and gets a
reply that grants a delegation even though the file has actually been
renamed to "bar".  (Thus violating the protocol, since the delegation's
supposed to guarantee you'll be notified before the file's renamed.)

(So the i_mutex is actually overkill, it would be enough to detect a
rename and then refuse the delegation (which we're always allowed to
do).)

But actually, if this is a mountpoint then I suppose we're safe from a
rename.  So, right, we can just move that unlock into the mountpoint
case.

--b.
