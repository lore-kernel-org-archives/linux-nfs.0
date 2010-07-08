Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from msux-gh1-uea02.nsa.gov ([63.239.65.40]:36168 "EHLO
	msux-gh1-uea02.nsa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754399Ab0GHNfz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jul 2010 09:35:55 -0400
Subject: Re: [PATCH 10/10] NFSD: Server implementation of MAC Labeling
From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: hch@infradead.org, viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
        sds@tycho.nsa.gov, matthew.dodd@sparta.com, trond.myklebust@fys.uio.no,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-nfs@vger.kernel.org
In-Reply-To: <20100707192431.GK28815@fieldses.org>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
	 <1278513086-23964-11-git-send-email-dpquigl@tycho.nsa.gov>
	 <20100707172100.GE28815@fieldses.org>
	 <1278525801.2494.162.camel@moss-terrapins.epoch.ncsc.mil>
	 <20100707192431.GK28815@fieldses.org>
Content-Type: text/plain
Date: Thu, 08 Jul 2010 09:27:37 -0400
Message-Id: <1278595657.2494.182.camel@moss-terrapins.epoch.ncsc.mil>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-07-07 at 15:24 -0400, J. Bruce Fields wrote:
> On Wed, Jul 07, 2010 at 02:03:21PM -0400, David P. Quigley wrote:
> > Comments inline
> > 
> > On Wed, 2010-07-07 at 13:21 -0400, J. Bruce Fields wrote:
> > > On Wed, Jul 07, 2010 at 10:31:26AM -0400, David P. Quigley wrote:
> > > > This patch adds the ability to encode and decode file labels on the server for
> > > >  static __be32
> > > >  nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
> > > > -		   struct iattr *iattr, struct nfs4_acl **acl)
> > > > +		   struct iattr *iattr, struct nfs4_acl **acl,
> > > > +		   struct nfs4_label **label)
> > > 
> > > As we add more arguments, I wonder if at some point it becomes worth
> > > creating something like
> > > 
> > > 	struct nfsd4_attrs {
> > > 		struct iattr iattr;
> > > 		struct nfs4_acl *acl;
> > > 		...
> > > 	}
> > > 
> > > and passing that instead?
> > 
> > I can definitely submit something like that as a stand alone patch and
> > then add our nfs4_label stuff to that instead.
> 
> Not a big deal, but welcome if such a thing looks more generally useful
> (say, if the same arguments are passed elsewhere).
> 
> > > > +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> > > > +	if (bmval[1] & FATTR4_WORD1_SECURITY_LABEL) {
> > > > +		uint32_t lfs;
> > > > +
> > > > +		READ_BUF(4);
> > > > +		len += 4;
> > > > +		READ32(lfs);
> > > > +		READ_BUF(4);
> > > > +		len += 4;
> > > > +		READ32(dummy32);
> > > > +		READ_BUF(dummy32);
> > > > +		len += (XDR_QUADLEN(dummy32) << 2);
> > > > +		READMEM(buf, dummy32);
> > > > +
> > > > +		if (dummy32 > NFS4_MAXLABELLEN)
> > > > +			return nfserr_resource;
> > > > +
> > > > +		*label = kzalloc(sizeof(struct nfs4_label), GFP_KERNEL);
> > > 
> > > Could we allocate this some toher way (it's small, right?) and avoid the
> > > extra dynamic allocation here, just for simplicity's sake?
> > 
> > How would you suggest going about doing that?
> 
> Maybe make op_label, cr_label, etc., a struct nfs4_label instead of a
> struct nfs4_label *?

I'll look into this. Since the structure contains a void * for the label
data it might not be necessary to have to allocate the label structure
itself just make sure its zeroed out so we can check to see if its
initialized with anything.

> 
> > 
> > > 
> > > > +		if (*label == NULL) {
> > > > +			host_err = -ENOMEM;
> > > > +			goto out_nfserr;
> > > > +		}
> > > > +
> > > > +		(*label)->label = kmalloc(dummy32 + 1, GFP_KERNEL);
> > > 
> > > Might be nice to arrange NFS4_MAXLABELLEN to ensure this is never a
> > > higher-order allocation.
> > 
> > This should never be more than 4096. Under what circumstances would this
> > become a higher-order allocation?
> 
> Can't dummy32+1 be 4097?

You're right. My mistake. NFS4_MAXLABELLEN is supposed to include the
null termination. I'll fix this. I wonder if its better to just redefine
NFS4_MAXLABELLEN to be 4095 so when we use the extra null terminator it
will be a page size max.
> 
> --b.

