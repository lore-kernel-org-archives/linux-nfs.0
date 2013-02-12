Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41343 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752214Ab3BLWc3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2013 17:32:29 -0500
Date: Tue, 12 Feb 2013 17:32:26 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Steve Dickson <SteveD@redhat.com>, "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 06/15] NFSv4: Introduce new label structure
Message-ID: <20130212223226.GL10267@fieldses.org>
References: <1360327163-20360-1-git-send-email-SteveD@redhat.com>
 <1360327163-20360-7-git-send-email-SteveD@redhat.com>
 <20130212220741.GJ10267@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91F3CE55C@sacexcmbx05-prd.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91F3CE55C@sacexcmbx05-prd.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 12, 2013 at 10:28:16PM +0000, Myklebust, Trond wrote:
> On Tue, 2013-02-12 at 17:07 -0500, J. Bruce Fields wrote:
> > On Fri, Feb 08, 2013 at 07:39:14AM -0500, Steve Dickson wrote:
> > > From: David Quigley <dpquigl@davequigley.com>
> > > 
> > > In order to mimic the way that NFSv4 ACLs are implemented we have created a
> > > structure to be used to pass label data up and down the call chain. This patch
> > > adds the new structure and new members to the required NFSv4 call structures.
> > > 
> > > Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
> > > Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
> > > Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
> > > Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
> > > ---
> > >  fs/nfs/inode.c            | 33 +++++++++++++++++++++++++++++++++
> > >  include/linux/nfs4.h      |  7 +++++++
> > >  include/linux/nfs_fs.h    | 17 +++++++++++++++++
> > >  include/linux/nfs_xdr.h   | 21 +++++++++++++++++++++
> > >  include/uapi/linux/nfs4.h |  2 +-
> > >  5 files changed, 79 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> > > index ebeb94c..8d5f01b 100644
> > > --- a/fs/nfs/inode.c
> > > +++ b/fs/nfs/inode.c
> > > @@ -255,6 +255,39 @@ nfs_init_locked(struct inode *inode, void *opaque)
> > >  	return 0;
> > >  }
> > >  
> > > +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
> > > +struct nfs4_label *nfs4_label_alloc(struct nfs_server *server, gfp_t flags)
> > > +{
> > > +	struct nfs4_label *label = NULL;
> > > +
> > > +	if (!(server->caps & NFS_CAP_SECURITY_LABEL))
> > > +		return label;
> > > +
> > > +	label = kzalloc(NFS4_MAXLABELLEN, flags);
> > > +	if (label == NULL)
> > > +		return ERR_PTR(-ENOMEM);
> > > +
> > > +	label->label = (char *)(label + 1);
> > > +	label->len = NFS4_MAXLABELLEN;
> > 
> > If you're expecting to be able to store up to NFS4_MAXLABELLEN of data
> > after the end of the struct, then you want:
> > 
> > 	label = kzalloc(sizeof(struct nfs4_label) + NFS4_MAXLABELLEN, flags);
> 
> Sigh... No.
> 
> I keep telling Steve that the 'label' needs to be defined as an array,

Yeah, I know, he said in 0/15 that he couldn't do that, so I've been
reading through these on the assumption I'll find out why not at some
point....  (Still not seeing it, though.)

--b.

> not a pointer. Having it be a pointer gives rise to a completely
> unnecessary extra indirection (the CPU first needs to look up the
> content of 'label->label', then dereference that pointer)...
> 
> IOW: we should just be defining struct nfs4_label as
> 
> struct nfs4_label {
> 
> 	.... lots of definitions ...
> 
> 	char label[NFS4_MAXLABELLEN];
> };
> 
> in which case the above allocation becomes a trivial
> 
> 	label = kzalloc(sizeof(*label), flags);
> 
> 
> 
> > > +
> > > +	return label;
> > > +}
> > > +EXPORT_SYMBOL_GPL(nfs4_label_alloc);
> > > +
> > > +void nfs4_label_init(struct nfs4_label *label)
> > > +{
> > > +	if (label && label->label) {
> > > +		/* 0 is the null format meaning that the data is not
> > > +		to be translated */
> > > +		label->lfs = 0;
> > > +		label->pi = 0;
> > > +		label->len = NFS4_MAXLABELLEN;
> > 
> > This logic seems a little odd to me; why would we pass NULL to this?
> > Why would we skip the other initialization in the !label->label case?
> > Why is NFS4_MAXLABELLEN the default?  (And wasn't that just set in
> > nfs4_label_alloc?)
> > 
> > But OK maybe I need to read the rest of the patches.
> > 
> > > +	}
> > > +	return;
> > > +}
> > > +EXPORT_SYMBOL_GPL(nfs4_label_init);
> > > +#endif
> > 
> > > diff --git a/include/uapi/linux/nfs4.h b/include/uapi/linux/nfs4.h
> > > index 788128e..b8014a2 100644
> > > --- a/include/uapi/linux/nfs4.h
> > > +++ b/include/uapi/linux/nfs4.h
> > > @@ -25,7 +25,7 @@
> > >  #define NFS4_MAXNAMLEN		NAME_MAX
> > >  #define NFS4_OPAQUE_LIMIT	1024
> > >  #define NFS4_MAX_SESSIONID_LEN	16
> > > -
> > > +#define NFS4_MAXLABELLEN (4095 - offsetof(struct nfs4_label , label))
> > 
> > The way you've defined things, that should be just
> > 
> > 			    (4095 - sizeof(struct nfs4_label))
> 
> No. See above. If the 'label' field is an array, then the offsetof() is
> 100% correct.
> 
> > (Is there typically some more alloc overhead that would push this
> > allocation over 4k?  I don't know well enough how the allocator(s) work
> > to answer that.)
> > 
> > --b.
> > 
> > >  #define NFS4_ACCESS_READ        0x0001
> > >  #define NFS4_ACCESS_LOOKUP      0x0002
> > >  #define NFS4_ACCESS_MODIFY      0x0004
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
