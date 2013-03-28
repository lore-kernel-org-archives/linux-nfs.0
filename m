Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33954 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751453Ab3C1TTV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Mar 2013 15:19:21 -0400
Date: Thu, 28 Mar 2013 15:19:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 13/14] NFSD: Server implementation of MAC Labeling
Message-ID: <20130328191918.GA14748@fieldses.org>
References: <1364478845-29796-1-git-send-email-SteveD@redhat.com>
 <1364478845-29796-14-git-send-email-SteveD@redhat.com>
 <20130328185845.GI7080@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130328185845.GI7080@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dave, I think these are both questions for you?

--b.

On Thu, Mar 28, 2013 at 02:58:45PM -0400, bfields wrote:
> On Thu, Mar 28, 2013 at 09:54:04AM -0400, Steve Dickson wrote:
> > @@ -1988,6 +2044,50 @@ nfsd4_encode_aclname(struct svc_rqst *rqstp, struct nfs4_ace *ace,
> >  			      FATTR4_WORD0_RDATTR_ERROR)
> >  #define WORD1_ABSENT_FS_ATTRS FATTR4_WORD1_MOUNTED_ON_FILEID
> >  
> > +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> > +static inline __be32
> > +nfsd4_encode_security_label(struct svc_rqst *rqstp, struct dentry *dentry, __be32 **pp, int *buflen)
> > +{
> > +	void *context;
> > +	int err;
> > +	int len;
> > +	uint32_t pi = 0;
> > +	uint32_t lfs = 0;
> > +	__be32 *p = *pp;
> > +
> > +	err = 0;
> > +	(void)security_inode_getsecctx(dentry->d_inode, &context, &len);
> > +	if (len < 0)
> > +		return nfserrno(len);
> > +
> > +	if (*buflen < ((XDR_QUADLEN(len) << 2) + 4 + 4 + 4)) {
> > +		err = nfserr_resource;
> > +		goto out;
> > +	}
> > +
> > +	/* XXX: A call to the translation code should be placed here
> > +	 * for now send 0  until we have that to indicate the null
> > +	 * translation */ 
> 
> Could we better a better comment here?
...
> > +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> > +__be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
> > +		struct nfs4_label *label)
> > +{
> > +	__be32 error;
> > +	int host_error;
> > +	struct dentry *dentry;
> > +
> > +	/* XXX: should we have a MAY_SSECCTX? */
> 
> Again: could we get an answer to this question?
> 
> --b.
