Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:35454 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932578AbbHGR4P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Aug 2015 13:56:15 -0400
Received: by ykcq64 with SMTP id q64so89782016ykc.2
        for <linux-nfs@vger.kernel.org>; Fri, 07 Aug 2015 10:56:14 -0700 (PDT)
Date: Fri, 7 Aug 2015 13:56:10 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 16/18] nfsd: add a fh_compose_shallow
Message-ID: <20150807135610.2990d1ac@synchrony.poochiereds.net>
In-Reply-To: <55C4CFE6.1080300@gmail.com>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
	<1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
	<1438809216-4846-17-git-send-email-jeff.layton@primarydata.com>
	<55C4CFE6.1080300@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 7 Aug 2015 23:33:58 +0800
Kinglong Mee <kinglongmee@gmail.com> wrote:

> On 8/6/2015 05:13, Jeff Layton wrote:
> > In a later patch, we'll need to be able to cook up a knfsd_fh from a
> > dentry/export combo. Usually nfsd works with svc_fh's, but that takes
> > a lot of extra baggage that we don't really need here.
> > 
> > Add a routine that encodes the filehandle directly into a knfsd_fh
> > instead. Much like we have a fh_copy_shallow, the new routine is called
> > fh_compose_shallow.
> > 
> > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> > ---
> >  fs/nfsd/nfsfh.c | 112 +++++++++++++++++++++++++++++---------------------------
> >  fs/nfsd/nfsfh.h |   2 +
> >  2 files changed, 60 insertions(+), 54 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
> > index b601f291d825..ee6d4b746467 100644
> > --- a/fs/nfsd/nfsfh.c
> > +++ b/fs/nfsd/nfsfh.c
> > @@ -511,32 +511,64 @@ retry:
> >  }
> >  
> >  __be32
> > -fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
> > -	   struct svc_fh *ref_fh)
> > +fh_compose_shallow(struct knfsd_fh *kfh, int maxsize, struct svc_export *exp,
> > +			struct dentry *dentry, struct svc_fh *ref_fh)
> >  {
> > -	/* ref_fh is a reference file handle.
> > -	 * if it is non-null and for the same filesystem, then we should compose
> > -	 * a filehandle which is of the same version, where possible.
> > -	 * Currently, that means that if ref_fh->fh_handle.fh_version == 0xca
> > -	 * Then create a 32byte filehandle using nfs_fhbase_old
> > -	 *
> > -	 */
> > +	struct inode	*inode = d_inode(dentry);
> > +	dev_t		ex_dev = exp_sb(exp)->s_dev;
> >  
> > -	struct inode * inode = d_inode(dentry);
> > -	dev_t ex_dev = exp_sb(exp)->s_dev;
> > -
> > -	dprintk("nfsd: fh_compose(exp %02x:%02x/%ld %pd2, ino=%ld)\n",
> > -		MAJOR(ex_dev), MINOR(ex_dev),
> > +	dprintk("nfsd: %s(exp %02x:%02x/%ld %pd2, ino=%ld)\n",
> > +		__func__, MAJOR(ex_dev), MINOR(ex_dev),
> >  		(long) d_inode(exp->ex_path.dentry)->i_ino,
> > -		dentry,
> > -		(inode ? inode->i_ino : 0));
> > +		dentry, (inode ? inode->i_ino : 0));
> >  
> > -	/* Choose filehandle version and fsid type based on
> > -	 * the reference filehandle (if it is in the same export)
> > -	 * or the export options.
> > +	/*
> > +	 * Choose filehandle version and fsid type based on the reference
> > +	 * filehandle (if it is in the same export) or the export options.
> >  	 */
> > -	 set_version_and_fsid_type(&fhp->fh_handle, fhp->fh_maxsize,
> > -				   exp, ref_fh);
> > +	set_version_and_fsid_type(kfh, maxsize, exp, ref_fh);
> > +	if (kfh->fh_version == 0xca) {
> > +		/* old style filehandle please */
> > +		memset(&kfh->fh_base, 0, NFS_FHSIZE);
> > +		kfh->fh_size = NFS_FHSIZE;
> > +		kfh->ofh_dcookie = 0xfeebbaca;
> > +		kfh->ofh_dev =  old_encode_dev(ex_dev);
> > +		kfh->ofh_xdev = kfh->ofh_dev;
> > +		kfh->ofh_xino =
> > +			ino_t_to_u32(d_inode(exp->ex_path.dentry)->i_ino);
> > +		kfh->ofh_dirino = ino_t_to_u32(parent_ino(dentry));
> > +		if (inode)
> > +			_fh_update_old(dentry, exp, kfh);
> > +	} else {
> > +		kfh->fh_size = key_len(kfh->fh_fsid_type) + 4;
> > +		kfh->fh_auth_type = 0;
> > +
> > +		mk_fsid(kfh->fh_fsid_type, kfh->fh_fsid, ex_dev,
> > +			d_inode(exp->ex_path.dentry)->i_ino,
> > +			exp->ex_fsid, exp->ex_uuid);
> > +
> > +		if (inode)
> > +			_fh_update(kfh, maxsize, exp, dentry);
> > +
> > +		if (kfh->fh_fileid_type == FILEID_INVALID)
> > +			return nfserr_opnotsupp;
> > +	}
> > +	return nfs_ok;
> > +}
> > +
> > +/*
> > + * ref_fh is a reference file handle.
> > + * if it is non-null and for the same filesystem, then we should compose
> > + * a filehandle which is of the same version, where possible.
> > + * Currently, that means that if ref_fh->fh_handle.fh_version == 0xca
> > + * Then create a 32byte filehandle using nfs_fhbase_old
> > + *
> > + */
> > +__be32
> > +fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
> > +	   struct svc_fh *ref_fh)
> > +{
> > +	__be32		status;
> >  
> >  	if (ref_fh == fhp)
> >  		fh_put(ref_fh);
> 
> set_version_and_fsid_type will use fh_dentry in ref_fh, 
> So it *must* be used with a valid ref_fh.
> 
> With this patch, fh_put(ref_fh) will put fh_dentry and set to NULL!!!
> 
> Also, pynfs4.1's LKPP1d failed as, 
> LKPP1d   st_lookupp.testLookupp                                   : FAILURE
>            LOOKUPP returned
>            '\x01\x00\x07\x00\x02\x00\x00\x00\x00\x00\x00\x004\x93\x1f\x04L*C\x9b\x95L]\x83\x0f\xa4\xbe\x8c',
>            expected '\x01\x00\x01\x00\x00\x00\x00\x00'
> 
> Move set_version_and_fsid_type back, before fh_put(ref_fh).
> 
> thanks,
> Kinglong Mee
> 

Ahh ok, it took me a minute but I see what you're saying now. Yes, this
is broken. I'll fix it, but I'm yet convinced that that is the best way.

Thanks,
Jeff

> > @@ -553,39 +585,11 @@ fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
> >  	fhp->fh_dentry = dget(dentry); /* our internal copy */
> >  	fhp->fh_export = exp_get(exp);
> >  
> > -	if (fhp->fh_handle.fh_version == 0xca) {
> > -		/* old style filehandle please */
> > -		memset(&fhp->fh_handle.fh_base, 0, NFS_FHSIZE);
> > -		fhp->fh_handle.fh_size = NFS_FHSIZE;
> > -		fhp->fh_handle.ofh_dcookie = 0xfeebbaca;
> > -		fhp->fh_handle.ofh_dev =  old_encode_dev(ex_dev);
> > -		fhp->fh_handle.ofh_xdev = fhp->fh_handle.ofh_dev;
> > -		fhp->fh_handle.ofh_xino =
> > -			ino_t_to_u32(d_inode(exp->ex_path.dentry)->i_ino);
> > -		fhp->fh_handle.ofh_dirino = ino_t_to_u32(parent_ino(dentry));
> > -		if (inode)
> > -			_fh_update_old(dentry, exp, &fhp->fh_handle);
> > -	} else {
> > -		fhp->fh_handle.fh_size =
> > -			key_len(fhp->fh_handle.fh_fsid_type) + 4;
> > -		fhp->fh_handle.fh_auth_type = 0;
> > -
> > -		mk_fsid(fhp->fh_handle.fh_fsid_type,
> > -			fhp->fh_handle.fh_fsid,
> > -			ex_dev,
> > -			d_inode(exp->ex_path.dentry)->i_ino,
> > -			exp->ex_fsid, exp->ex_uuid);
> > -
> > -		if (inode)
> > -			_fh_update(&fhp->fh_handle, fhp->fh_maxsize,
> > -					exp, dentry);
> > -		if (fhp->fh_handle.fh_fileid_type == FILEID_INVALID) {
> > -			fh_put(fhp);
> > -			return nfserr_opnotsupp;
> > -		}
> > -	}
> > -
> > -	return 0;
> > +	status = fh_compose_shallow(&fhp->fh_handle, fhp->fh_maxsize, exp,
> > +					dentry, ref_fh);
> > +	if (status != nfs_ok)
> > +		fh_put(fhp);
> > +	return status;
> >  }
> >  
> >  /*
> > diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
> > index 1e90dad4926b..dec472131588 100644
> > --- a/fs/nfsd/nfsfh.h
> > +++ b/fs/nfsd/nfsfh.h
> > @@ -159,6 +159,8 @@ extern char * SVCFH_fmt(struct svc_fh *fhp);
> >   * Function prototypes
> >   */
> >  __be32	fh_verify(struct svc_rqst *, struct svc_fh *, umode_t, int);
> > +__be32	fh_compose_shallow(struct knfsd_fh *, int, struct svc_export *,
> > +			   struct dentry *, struct svc_fh *);
> >  __be32	fh_compose(struct svc_fh *, struct svc_export *, struct dentry *, struct svc_fh *);
> >  __be32	fh_update(struct svc_fh *);
> >  void	fh_put(struct svc_fh *);
> > 


-- 
Jeff Layton <jlayton@poochiereds.net>
