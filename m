Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46091 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756290Ab0LHBMl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Dec 2010 20:12:41 -0500
Date: Tue, 7 Dec 2010 20:12:39 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Suresh Jayaraman <sjayaraman@suse.de>
Cc: Neil Brown <neilb@suse.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: Fix possible BUG_ON firing in set_change_info
Message-ID: <20101208011239.GB30196@fieldses.org>
References: <20101202111430.57275603@notabene.brown>
 <4CF73AC6.4020105@suse.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CF73AC6.4020105@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Dec 02, 2010 at 11:50:54AM +0530, Suresh Jayaraman wrote:
> On 12/02/2010 05:44 AM, Neil Brown wrote:
> > 
> > If vfs_getattr in fill_post_wcc returns an error, we don't
> > set fh_post_change.
>       ^^^ Did you mean fh_post_saved?
> 
> > For NFSv4, this can result in set_change_info triggering a BUG_ON.
> > i.e. fh_post_saved being zero isn't really a bug.
> > 
> > So:
> >  - instead of BUGging when fh_post_saved is zero, just clear ->atomic.
> >  - if vfs_getattr fails in fill_post_wcc, take a copy of i_ctime anyway.
> >    This will be used i seg_change_info, but not overly trusted.
> >  - While we are there, remove the pointless 'if' statements in set_change_info.
> >    There is no harm setting all the values.
> 
> The 'if' statement was introduced when ext4 i_version support was added
> via commit c654b8a9. While there is no harm setting all the values, it
> may not really be required.

If you mean that you interpret the spec as allowing us to return garbage
changeattr values in the non-atomic case, no, I don't agree.

It's true that a client that tries to use them must be aware of the
potential pitfalls, but not true that we therefore have license to
return inaccurate post-op attributes.

--b.

> 
> >From the spec:
> 
> 	"For a client to use the change_info4 information
> appropriately and correctly, the server must report the pre- and
> post-operation change attribute values atomically. When the server
> is unable to report the before and after values atomically with
> respect to the directory operation, the server must indicate that
> fact in the change_info4 return value. When the information is not
> atomically reported, the client should not assume that other clients
> have not changed the directory."
> 
> Though the spec doesn't talk about the case we have specifically, it
> appears to me that the proposed behavior is the best we could aim for.
> 
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > 
> > --
> > 
> > If you think the code is clearer with the if() structure, feel free
> > to leave that part unchanged.
> > 
> > NeilBrown
> > 
> > diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> > index 2a533a0..7e84a85 100644
> > --- a/fs/nfsd/nfs3xdr.c
> > +++ b/fs/nfsd/nfs3xdr.c
> > @@ -260,9 +260,11 @@ void fill_post_wcc(struct svc_fh *fhp)
> >  	err = vfs_getattr(fhp->fh_export->ex_path.mnt, fhp->fh_dentry,
> >  			&fhp->fh_post_attr);
> >  	fhp->fh_post_change = fhp->fh_dentry->d_inode->i_version;
> > -	if (err)
> > +	if (err) {
> >  		fhp->fh_post_saved = 0;
> > -	else
> > +		/* Grab the ctime anyway - set_change_info might use it */
> > +		fhp->fh_post_attr.ctime = fhp->fh_dentry->d_inode->i_ctime;
> > +	} else
> >  		fhp->fh_post_saved = 1;
> >  }
> >  
> > diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> > index 4d476ff..60fce3d 100644
> > --- a/fs/nfsd/xdr4.h
> > +++ b/fs/nfsd/xdr4.h
> > @@ -484,18 +484,17 @@ static inline bool nfsd4_not_cached(struct nfsd4_compoundres *resp)
> >  static inline void
> >  set_change_info(struct nfsd4_change_info *cinfo, struct svc_fh *fhp)
> >  {
> > -	BUG_ON(!fhp->fh_pre_saved || !fhp->fh_post_saved);
> > -	cinfo->atomic = 1;
> > +	BUG_ON(!fhp->fh_pre_saved);
> > +	cinfo->atomic = fhp->fh_post_saved;
> >  	cinfo->change_supported = IS_I_VERSION(fhp->fh_dentry->d_inode);
> > -	if (cinfo->change_supported) {
> > -		cinfo->before_change = fhp->fh_pre_change;
> > -		cinfo->after_change = fhp->fh_post_change;
> > -	} else {
> > -		cinfo->before_ctime_sec = fhp->fh_pre_ctime.tv_sec;
> > -		cinfo->before_ctime_nsec = fhp->fh_pre_ctime.tv_nsec;
> > -		cinfo->after_ctime_sec = fhp->fh_post_attr.ctime.tv_sec;
> > -		cinfo->after_ctime_nsec = fhp->fh_post_attr.ctime.tv_nsec;
> > -	}
> > +
> > +	cinfo->before_change = fhp->fh_pre_change;
> > +	cinfo->after_change = fhp->fh_post_change;
> > +	cinfo->before_ctime_sec = fhp->fh_pre_ctime.tv_sec;
> > +	cinfo->before_ctime_nsec = fhp->fh_pre_ctime.tv_nsec;
> > +	cinfo->after_ctime_sec = fhp->fh_post_attr.ctime.tv_sec;
> > +	cinfo->after_ctime_nsec = fhp->fh_post_attr.ctime.tv_nsec;
> > +
> >  }
> >  
> >  int nfs4svc_encode_voidres(struct svc_rqst *, __be32 *, void *);
> 
> 
> -- 
> Suresh Jayaraman
