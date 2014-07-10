Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f42.google.com ([209.85.216.42]:51840 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbaGJMga (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 08:36:30 -0400
Received: by mail-qa0-f42.google.com with SMTP id j15so1310886qaq.1
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 05:36:29 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 10 Jul 2014 08:36:28 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 017/100] nfsd: make deny mode enforcement more
 efficient and close races in it
Message-ID: <20140710083628.4bec674e@tlielax.poochiereds.net>
In-Reply-To: <20140710104927.GC6935@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
	<1404842668-22521-18-git-send-email-jlayton@primarydata.com>
	<20140710104927.GC6935@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 10 Jul 2014 03:49:27 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> > +__nfs4_file_get_access(struct nfs4_file *fp, u32 access)
> >  {
> > -	WARN_ON_ONCE(!(fp->fi_fds[oflag] || fp->fi_fds[O_RDWR]));
> > -	atomic_inc(&fp->fi_access[oflag]);
> > +	int oflag = nfs4_access_to_omode(access);
> > +
> > +	if (oflag == O_RDWR) {
> > +		atomic_inc(&fp->fi_access[O_RDONLY]);
> > +		atomic_inc(&fp->fi_access[O_WRONLY]);
> > +	} else
> > +		atomic_inc(&fp->fi_access[oflag]);
> >  }
> 
> Miught be worth to simply kill the old, simple
> __nfs4_file_get_access/__nfs4_file_put_access helper that just wrap
> the atomic ops in your earlier patch instead of reshuffling everything
> here again.
> 

Maybe.

> > +nfs4_file_get_access(struct nfs4_file *fp, u32 access)
> >  {
> >  	lockdep_assert_held(&fp->fi_lock);
> >  
> >  	/* Note: relies on NFS4_SHARE_ACCESS_BOTH == READ|WRITE */
> >  	access &= NFS4_SHARE_ACCESS_BOTH;
> > +
> > +	/* Does this access mask make sense? */
> >  	if (access == 0)
> > +		return nfserr_inval;
> >  
> > +	/* Does it conflict with a deny mode already set? */
> > +	if ((access & fp->fi_share_deny) != 0)
> > +		return nfserr_share_denied;
> > +
> > +	__nfs4_file_get_access(fp, access);
> > +	return nfs_ok;
> 
> Why bother clearing out the inval bits from access?  Just do a:
> 
> 	if (access & ~NFS4_SHARE_ACCESS_BOTH)
> 		return nfserr_inval;
> 
> also that check doesn't really belong in here, might be better to add it
> to the initial nfs4_file_get_access refactor.
> 

Ok, good point.

> > +static __be32 nfs4_file_check_deny(struct nfs4_file *fp, u32 deny)
> > +{
> > +	/* Common case is that there is no deny mode. */
> > +	deny &= NFS4_SHARE_DENY_BOTH;
> > +	if (deny) {
> 
> No need to reject invalid ones here unlike the access case?  Any reason
> to handle them differently?
> 
> Otherwise again no need to clear them out, that just makes the code
> harder to read.
> 

Yeah, makes sense. I'll fix it to throw back an error if there are
extra bits set.

> > +		/* Note: relies on NFS4_SHARE_DENY_BOTH == READ|WRITE */
> 
> READ should be NFS4_SHARE_DENY_READ and same for write I guess?  I don't
> really think you need these comments anyway, as this is part of the
> protocol.
> 

Ok.

> >  
> > +/*
> > + * A stateid that had a deny mode associated with it is being released
> > + * or downgraded. Recalculate the deny mode on the file.
> > + */
> > +static void
> > +recalculate_deny_mode(struct nfs4_file *fp)
> > +{
> > +	struct nfs4_ol_stateid *stp;
> > +
> > +	spin_lock(&fp->fi_lock);
> > +	fp->fi_share_deny = 0;
> > +	list_for_each_entry(stp, &fp->fi_stateids, st_perfile)
> > +		fp->fi_share_deny |= bmap_to_share_mode(stp->st_deny_bmap);
> 
> Seems like bmap_to_share_mode is superflous with your change of
> st_deny_bmap to a char, this could become:
> 
> 		fp->fi_share_deny |= stp->st_deny_bmap;
> 

No. Again, take a look at the comments above bmap_to_share_mode.

fi_share_deny will hold NFS_SHARE_DENY_* bits that are the union of all
the stateids attached to it, but the st_deny_bmap has to track the
individual NFS_SHARE_DENY_* modes that have been used.

> >  /* release all access and file references for a given stateid */
> >  static void
> >  release_all_access(struct nfs4_ol_stateid *stp)
> >  {
> >  	int i;
> > +	struct nfs4_file *fp = stp->st_file;
> > +
> > +	if (fp && stp->st_deny_bmap != 0)
> > +		recalculate_deny_mode(fp);
> 
> Can fp be zero here?
> 

At this point in the series, no. After later patches go in, yes.

> > +out_put_access:
> > +	stp->st_access_bmap = old_access_bmap;
> > +	nfs4_file_put_access(fp, open->op_share_access);
> > +	reset_union_bmap_deny(bmap_to_share_mode(old_deny_bmap), stp);
> 
> Instead of setting stp->st_access_bmap to the old bmap and then passing
> it to reset_union_bmap_deny just pass the bitmap there directly?  Or
> just kill reset_union_bmap_denyand inline it given how simple it should have
> become with my previous comments addressed.
> 
> 

We can't get rid of reset_union_bmap_deny for the reasons I explained
above and we'd still need to do an extra conversion in
nfsd4_open_downgrade if we do that. I'd rather leave any extra work to
the error case (which is why I did it this way).

> >  static __be32
> >  nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *cur_fh, struct nfs4_ol_stateid *stp, struct nfsd4_open *open)
> >  {
> >  	__be32 status;
> > +	unsigned char old_deny_bmap;
> >  
> >  	if (!test_access(open->op_share_access, stp))
> > +		return nfs4_get_vfs_file(rqstp, fp, cur_fh, stp, open);
> >  
> > +	/* test and set deny mode */
> > +	spin_lock(&fp->fi_lock);
> > +	status = nfs4_file_check_deny(fp, open->op_share_deny);
> > +	if (status == nfs_ok) {
> > +		old_deny_bmap = stp->st_deny_bmap;
> > +		set_deny(open->op_share_deny, stp);
> 
> Maybe set_deny should return the old bitmap given that quite a few
> callers care?  Maybe the set_deny should even move into
> nfs4_file_check_deny which could return the old one, making it an check
> and set operation.
> 

Yeah, I considered that, I'll see if that will help things, but it
might be best to leave that extra cleanup to a different patchset. This
set is all about removing the client_mutex, not so much about cleaning
up deny mode handling (even fixing that atomicity is a necessary step).

> > @@ -4603,7 +4673,7 @@ static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
> >  
> >  	if (test_access(access, lock_stp))
> >  		return;
> > -	nfs4_file_get_access(fp, access);
> > +	__nfs4_file_get_access(fp, access);
> >  	set_access(access, lock_stp);
> 
> Why do we not bother with checking the deny mode here?
> 

Lock stateids inherit the access and deny modes from the open stateids.
The open stateid has already checked both the access and deny modes, so
there's no need to do it again.

Doing so also becomes problematic with the change to use fi_share_deny.
If an open sets an fi_share_deny bit, then we'd have to account for
that here since the lock stateid associated with that open should not
conflict with that bit. Best to just avoid trying to check deny bits in
the LOCK codepath.

-- 
Jeff Layton <jlayton@primarydata.com>
