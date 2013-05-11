Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53418 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752530Ab3EKSdh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 11 May 2013 14:33:37 -0400
Date: Sat, 11 May 2013 14:33:19 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 16/17] NFSD: Server implementation of MAC Labeling
Message-ID: <20130511183318.GB15765@fieldses.org>
References: <1367515151-31015-1-git-send-email-SteveD@redhat.com>
 <1367515151-31015-17-git-send-email-SteveD@redhat.com>
 <20130509015033.GI23747@fieldses.org>
 <518E6174.7010602@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <518E6174.7010602@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 11, 2013 at 11:19:16AM -0400, Steve Dickson wrote:
> 
> 
> On 08/05/13 21:50, J. Bruce Fields wrote:
> > This also doesn't handle the unsupported case correctly.
> > 
> > Applying the following fix to my tree.
> > 
> > --b.
> > 
> > commit 4438e5f801c43cc0f383fdc85f3ec294a4155df1
> > Author: J. Bruce Fields <bfields@redhat.com>
> > Date:   Wed May 8 21:38:00 2013 -0400
> > 
> >     nfsd4: fix handling of case when labels are unsupported
> >     
> >     Copy the logic in the ACL case to ensure that we just turn off the
> >     bitmap in the getattr case instead of erroring out, and to ensure that
> >     we get the supported_attributes attribute right.
> >     
> >     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > 
> > diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> > index 6e96c0d..3b4e59c 100644
> > --- a/fs/nfsd/nfs4xdr.c
> > +++ b/fs/nfsd/nfs4xdr.c
> > @@ -2010,29 +2010,21 @@ nfsd4_encode_aclname(struct svc_rqst *rqstp, struct nfs4_ace *ace,
> >  
> >  #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> >  static inline __be32
> > -nfsd4_encode_security_label(struct svc_rqst *rqstp, struct dentry *dentry, __be32 **pp, int *buflen)
> > +nfsd4_encode_security_label(struct svc_rqst *rqstp, void *context, int len, __be32 **pp, int *buflen)
> >  {
> > -	void *context;
> > -	int host_err;
> > -	__be32 err = nfserr_resource;
> > -	u32 len;
> >  	uint32_t pi = 0;
> >  	uint32_t lfs = 0;
> >  	__be32 *p = *pp;
> >  
> > -	host_err = security_inode_getsecctx(dentry->d_inode, &context, &len);
> > -	if (host_err)
> > -		return nfserrno(host_err);
> > -
> >  	if (*buflen < ((XDR_QUADLEN(len) << 2) + 4 + 4 + 4))
> > -		goto out;
> > +		return nfserr_resource;
> >  
> >  	/*
> >  	 * For now we use a 0 here to indicate the null translation; in
> >  	 * the future we may place a call to translation code here.
> >  	 */
> >  	if ((*buflen -= 8) < 0)
> > -		goto out;
> > +		return nfserr_resource;
> >  
> >  	WRITE32(lfs);
> >  	WRITE32(pi);
> > @@ -2040,10 +2032,7 @@ nfsd4_encode_security_label(struct svc_rqst *rqstp, struct dentry *dentry, __be3
> >  	*buflen -= (XDR_QUADLEN(len) << 2) + 4;
> >  
> >  	*pp = p;
> > -	err = 0;
> > -out:
> > -	security_release_secctx(context, len);
> > -	return err;
> > +	return 0;
> >  }
> >  #else
> >  static inline __be32
> > @@ -2110,6 +2099,9 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
> >  	int err;
> >  	int aclsupport = 0;
> >  	struct nfs4_acl *acl = NULL;
> > +	void *context = NULL;
> > +	int contextlen;
> > +	bool contextsupport = false;
> >  	struct nfsd4_compoundres *resp = rqstp->rq_resp;
> >  	u32 minorversion = resp->cstate.minorversion;
> >  	struct path path = {
> > @@ -2163,6 +2155,21 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
> >  		}
> >  	}
> >  
> > +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> > +	if ((bmval[2] & FATTR4_WORD2_SECURITY_LABEL) ||
> > +			bmval[0] & FATTR4_WORD0_SUPPORTED_ATTRS) {
> > +		err = security_inode_getsecctx(dentry->d_inode,
> > +						&context, &contextlen);
> > +		contextsupport = (err = 0);
> Don't you really mean "contextsupport = (err == 0);" ?
> Otherwise contextsupport will never be set to 1.

Whoops, thanks!  Fixed.--b.

> 
> steved.
> 
> > +		if (bmval2 & FATTR4_WORD2_SECURITY_LABEL) {
> > +			if (err == -EOPNOTSUPP)
> > +				bmval2 &= ~FATTR4_WORD2_SECURITY_LABEL;
> > +			else if (err)
> > +				goto out_nfserr;
> > +		}
> > +	}
> > +#endif /* CONFIG_NFSD_V4_SECURITY_LABEL */
> > +
> >  	if (bmval2) {
> >  		if ((buflen -= 16) < 0)
> >  			goto out_resource;
> > @@ -2191,6 +2198,8 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
> >  
> >  		if (!aclsupport)
> >  			word0 &= ~FATTR4_WORD0_ACL;
> > +		if (!contextsupport)
> > +			word2 &= ~FATTR4_WORD2_SECURITY_LABEL;
> >  		if (!word2) {
> >  			if ((buflen -= 12) < 0)
> >  				goto out_resource;
> > @@ -2499,8 +2508,8 @@ out_acl:
> >  		WRITE64(stat.ino);
> >  	}
> >  	if (bmval2 & FATTR4_WORD2_SECURITY_LABEL) {
> > -		status = nfsd4_encode_security_label(rqstp, dentry,
> > -				&p, &buflen);
> > +		status = nfsd4_encode_security_label(rqstp, context,
> > +				contextlen, &p, &buflen);
> >  		if (status)
> >  			goto out;
> >  	}
> > @@ -2516,6 +2525,8 @@ out_acl:
> >  	status = nfs_ok;
> >  
> >  out:
> > +	if (context)
> > +		security_release_secctx(context, contextlen);
> >  	kfree(acl);
> >  	if (fhp == &tempfh)
> >  		fh_put(&tempfh);
> > 
