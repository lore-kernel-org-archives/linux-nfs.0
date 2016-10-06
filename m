Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59882 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755575AbcJFNKq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Oct 2016 09:10:46 -0400
Date: Thu, 6 Oct 2016 09:10:44 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: fdmanana@kernel.org, linux-btrfs@vger.kernel.org,
        NFS List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] exportfs: be careful to only return expected errors.
Message-ID: <20161006131044.GA11036@fieldses.org>
References: <1465491191-28102-1-git-send-email-fdmanana@kernel.org>
 <874m7i8oou.fsf@notabene.neil.brown.name>
 <20160722015904.GB29969@fieldses.org>
 <87bn1q75ut.fsf@notabene.neil.brown.name>
 <20160722200843.GA7463@fieldses.org>
 <877fbxperp.fsf@notabene.neil.brown.name>
 <87h98q3rs3.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87h98q3rs3.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 06, 2016 at 05:39:24PM +1100, NeilBrown wrote:
> On Thu, Aug 04 2016, NeilBrown wrote:
> 
> >
> >
> > When nfsd calls fh_to_dentry, it expect ESTALE or ENOMEM as errors.
> > In particular it can be tempting to return ENOENT, but this is not
> > handled well by nfsd.
> >
> > Rather than requiring strict adherence to error code code filesystems,
> > treat all unexpected error codes the same as ESTALE.  This is safest.
> >
> > Signed-off-by: NeilBrown <neilb@suse.com>
> > ---
> >
> > I didn't add a dprintk for unexpected error messages, partly
> > because dprintk isn't usable in exportfs.  I could have used pr_debug()
> > but I really didn't see much value.
> >
> > This has been tested together with the btrfs change, and it restores
> > correct functionality.
> >
> > Thanks,
> > NeilBrown
> 
> 
> Hi Bruce,
>  I notice that this patch isn't in -next, but the btrfs change which
>  motivated it is.
>  That means, unless there is some other work around somewhere, btrfs
>  might start having problems with nfs export.

Whoops, I wonder what happened.  Looking back....  Oh, I think I set it
aside pending a response from Christoph, but I don't think that's really
necessary.

>  Can we get this patch into 4.9-rc??
> 
>  Or has someone fixed it a different way?

No, I'll just apply.

I need to send a pull request soon, I just have to make up my mind on
COPY first.

--b.

> Thanks,
> NeilBrown
> 
> 
> >
> >  fs/exportfs/expfs.c      | 10 ++++++----
> >  include/linux/exportfs.h | 13 +++++++------
> >  2 files changed, 13 insertions(+), 10 deletions(-)
> >
> > diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
> > index 207ba8d627ca..a4b531be9168 100644
> > --- a/fs/exportfs/expfs.c
> > +++ b/fs/exportfs/expfs.c
> > @@ -428,10 +428,10 @@ struct dentry *exportfs_decode_fh(struct vfsmount *mnt, struct fid *fid,
> >  	if (!nop || !nop->fh_to_dentry)
> >  		return ERR_PTR(-ESTALE);
> >  	result = nop->fh_to_dentry(mnt->mnt_sb, fid, fh_len, fileid_type);
> > -	if (!result)
> > -		result = ERR_PTR(-ESTALE);
> > -	if (IS_ERR(result))
> > -		return result;
> > +	if (PTR_ERR(result) == -ENOMEM)
> > +		return ERR_CAST(result);
> > +	if (IS_ERR_OR_NULL(result))
> > +		return ERR_PTR(-ESTALE);
> >  
> >  	if (d_is_dir(result)) {
> >  		/*
> > @@ -541,6 +541,8 @@ struct dentry *exportfs_decode_fh(struct vfsmount *mnt, struct fid *fid,
> >  
> >   err_result:
> >  	dput(result);
> > +	if (err != -ENOMEM)
> > +		err = -ESTALE;
> >  	return ERR_PTR(err);
> >  }
> >  EXPORT_SYMBOL_GPL(exportfs_decode_fh);
> > diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
> > index b03c0625fa6e..5ab958cdc50b 100644
> > --- a/include/linux/exportfs.h
> > +++ b/include/linux/exportfs.h
> > @@ -157,12 +157,13 @@ struct fid {
> >   *    @fh_to_dentry is given a &struct super_block (@sb) and a file handle
> >   *    fragment (@fh, @fh_len). It should return a &struct dentry which refers
> >   *    to the same file that the file handle fragment refers to.  If it cannot,
> > - *    it should return a %NULL pointer if the file was found but no acceptable
> > - *    &dentries were available, or an %ERR_PTR error code indicating why it
> > - *    couldn't be found (e.g. %ENOENT or %ENOMEM).  Any suitable dentry can be
> > - *    returned including, if necessary, a new dentry created with d_alloc_root.
> > - *    The caller can then find any other extant dentries by following the
> > - *    d_alias links.
> > + *    it should return a %NULL pointer if the file cannot be found, or an
> > + *    %ERR_PTR error code of %ENOMEM if a memory allocation failure occurred.
> > + *    Any other error code is treated like %NULL, and will cause an %ESTALE error
> > + *    for callers of exportfs_decode_fh().
> > + *    Any suitable dentry can be returned including, if necessary, a new dentry
> > + *    created with d_alloc_root.  The caller can then find any other extant
> > + *    dentries by following the d_alias links.
> >   *
> >   * fh_to_parent:
> >   *    Same as @fh_to_dentry, except that it returns a pointer to the parent
> > -- 
> > 2.9.2


