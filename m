Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from msux-gh1-uea02.nsa.gov ([63.239.65.40]:33770 "EHLO
	msux-gh1-uea02.nsa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754839Ab0GGSLS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jul 2010 14:11:18 -0400
Subject: Re: [PATCH 10/10] NFSD: Server implementation of MAC Labeling
From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: hch@infradead.org, viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
        sds@tycho.nsa.gov, matthew.dodd@sparta.com, trond.myklebust@fys.uio.no,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-nfs@vger.kernel.org
In-Reply-To: <20100707172100.GE28815@fieldses.org>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
	 <1278513086-23964-11-git-send-email-dpquigl@tycho.nsa.gov>
	 <20100707172100.GE28815@fieldses.org>
Content-Type: text/plain
Date: Wed, 07 Jul 2010 14:03:21 -0400
Message-Id: <1278525801.2494.162.camel@moss-terrapins.epoch.ncsc.mil>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Comments inline

On Wed, 2010-07-07 at 13:21 -0400, J. Bruce Fields wrote:
> On Wed, Jul 07, 2010 at 10:31:26AM -0400, David P. Quigley wrote:
> > This patch adds the ability to encode and decode file labels on the server for
> >  static __be32
> >  nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
> > -		   struct iattr *iattr, struct nfs4_acl **acl)
> > +		   struct iattr *iattr, struct nfs4_acl **acl,
> > +		   struct nfs4_label **label)
> 
> As we add more arguments, I wonder if at some point it becomes worth
> creating something like
> 
> 	struct nfsd4_attrs {
> 		struct iattr iattr;
> 		struct nfs4_acl *acl;
> 		...
> 	}
> 
> and passing that instead?

I can definitely submit something like that as a stand alone patch and
then add our nfs4_label stuff to that instead.

> 
> > +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> > +	if (bmval[1] & FATTR4_WORD1_SECURITY_LABEL) {
> > +		uint32_t lfs;
> > +
> > +		READ_BUF(4);
> > +		len += 4;
> > +		READ32(lfs);
> > +		READ_BUF(4);
> > +		len += 4;
> > +		READ32(dummy32);
> > +		READ_BUF(dummy32);
> > +		len += (XDR_QUADLEN(dummy32) << 2);
> > +		READMEM(buf, dummy32);
> > +
> > +		if (dummy32 > NFS4_MAXLABELLEN)
> > +			return nfserr_resource;
> > +
> > +		*label = kzalloc(sizeof(struct nfs4_label), GFP_KERNEL);
> 
> Could we allocate this some toher way (it's small, right?) and avoid the
> extra dynamic allocation here, just for simplicity's sake?

How would you suggest going about doing that?

> 
> > +		if (*label == NULL) {
> > +			host_err = -ENOMEM;
> > +			goto out_nfserr;
> > +		}
> > +
> > +		(*label)->label = kmalloc(dummy32 + 1, GFP_KERNEL);
> 
> Might be nice to arrange NFS4_MAXLABELLEN to ensure this is never a
> higher-order allocation.

This should never be more than 4096. Under what circumstances would this
become a higher-order allocation?
> 
> > +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> > +static inline __be32
> > +nfsd4_encode_security_label(struct svc_rqst *rqstp, struct dentry *dentry, __be32 **pp, int *buflen)
> > +{
> > +	void *context;
> > +	int err;
> > +	int len;
> > +	uint32_t lfs = 0;
> > +	__be32 *p = *pp;
> > +
> > +	err = 0;
> > +	(void)security_inode_getsecctx(dentry->d_inode, &context, &len);
> > +	if (len < 0)
> > +		return nfserrno(len);
> > +
> > +	if (*buflen < ((XDR_QUADLEN(len) << 2) + 4 +4)) {
> 
> We could use better helpers for this; it's kind of lame to have to do
> this by hand.

Give me an idea of what you'd like it to look like and I can try to code
it up.

> 
> > +		err = nfserr_resource;
> > +		goto out;
> > +	}
> > +
> > +	/* XXX: A call to the translation code should be placed here
> > +	 * for now send 0  until we have that to indicate the null
> > +	 * translation */ 
> 
> I guess I should try to understand what that is some day.

Ahh. Sorry that was a place holder for me. The idea is that in order to
allow for multiple models and policies we will have a deamon similar to
idmapd except to handle label translations. An example of this would be
if we have an SELinux box with an MLS policy and a FreeBSD box with
their MLS MAC module. If we want to ensure that they can both talk to
each other we have them agree ahead of time to a label format which is
just MLS label information. The translation daemon on the SELinux side
would take the label strip out the SELinux specific stuff and encode it
into the MLS label (probably a CALIPSO label) to send across the wire.
Then when the BSD box receives it they have their translation daemon
take the label convert it into something that makes sense to them
locally filling in whatever information they need outside of the MLS
label.


> 
> > +
> > +	if ((*buflen -= 4) < 0)
> 
> Redundant?

I don't think so. I'll go back and double check just to be safe.

> 
> --b.

