Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:36744 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161626AbcE3Qvm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 May 2016 12:51:42 -0400
Received: by mail-yw0-f195.google.com with SMTP id l126so15449161ywe.3
        for <linux-nfs@vger.kernel.org>; Mon, 30 May 2016 09:51:42 -0700 (PDT)
Message-ID: <1464627098.8117.6.camel@poochiereds.net>
Subject: Re: [RFC PATCH] nfsd: allow nfsd to advertise multiple layout types
From: Jeff Layton <jlayton@poochiereds.net>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org, Tom Haynes <thomas.haynes@primarydata.com>,
        Christoph Hellwig <hch@lst.de>
Date: Mon, 30 May 2016 12:51:38 -0400
In-Reply-To: <643433762.15123359.1464623258309.JavaMail.zimbra@desy.de>
References: <1464555567-16055-1-git-send-email-jlayton@poochiereds.net>
	 <1464555974.7044.4.camel@poochiereds.net>
	 <643433762.15123359.1464623258309.JavaMail.zimbra@desy.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2016-05-30 at 17:47 +0200, Mkrtchyan, Tigran wrote:
> 
> ----- Original Message -----
> > From: "Jeff Layton" <jlayton@poochiereds.net>
> > To: linux-nfs@vger.kernel.org
> > Cc: "Tom Haynes" <thomas.haynes@primarydata.com>, "Christoph Hellwig" <hch@lst.de>
> > Sent: Sunday, May 29, 2016 11:06:14 PM
> > Subject: Re: [RFC PATCH] nfsd: allow nfsd to advertise multiple layout types
> 
> > On Sun, 2016-05-29 at 16:59 -0400, Jeff Layton wrote:
> > > If the underlying filesystem supports multiple layout types, then there
> > > is little reason not to advertise that fact to clients and let them
> > > choose what type to use.
> > > 
> > > Turn the ex_layout_type field into a bitfield. For each supported
> > > layout type, we set a bit in that field. When the client requests a
> > > layout, ensure that the bit for that layout type is set. When the
> > > client requests attributes, send back a list of supported types.
> > > 
> > > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> > > ---
> > >  fs/nfsd/export.c      |  4 ++--
> > >  fs/nfsd/export.h      |  2 +-
> > >  fs/nfsd/nfs4layouts.c |  6 +++---
> > >  fs/nfsd/nfs4proc.c    |  4 ++--
> > >  fs/nfsd/nfs4xdr.c     | 30 ++++++++++++++----------------
> > >  5 files changed, 22 insertions(+), 24 deletions(-)
> > > 
> > > diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> > > index b4d84b579f20..f97ba49d5e66 100644
> > > --- a/fs/nfsd/export.c
> > > +++ b/fs/nfsd/export.c
> > > @@ -706,7 +706,7 @@ static void svc_export_init(struct cache_head *cnew, struct
> > > cache_head *citem)
> > >  	new->ex_fslocs.locations = NULL;
> > >  	new->ex_fslocs.locations_count = 0;
> > >  	new->ex_fslocs.migrated = 0;
> > > -	new->ex_layout_type = 0;
> > > +	new->ex_layout_types = 0;
> > >  	new->ex_uuid = NULL;
> > >  	new->cd = item->cd;
> > >  }
> > > @@ -731,7 +731,7 @@ static void export_update(struct cache_head *cnew, struct
> > > cache_head *citem)
> > >  	item->ex_fslocs.locations_count = 0;
> > >  	new->ex_fslocs.migrated = item->ex_fslocs.migrated;
> > >  	item->ex_fslocs.migrated = 0;
> > > -	new->ex_layout_type = item->ex_layout_type;
> > > +	new->ex_layout_types = item->ex_layout_types;
> > >  	new->ex_nflavors = item->ex_nflavors;
> > >  	for (i = 0; i < MAX_SECINFO_LIST; i++) {
> > >  		new->ex_flavors[i] = item->ex_flavors[i];
> > > diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
> > > index 2e315072bf3f..730f15eeb7ed 100644
> > > --- a/fs/nfsd/export.h
> > > +++ b/fs/nfsd/export.h
> > > @@ -57,7 +57,7 @@ struct svc_export {
> > >  	struct nfsd4_fs_locations ex_fslocs;
> > >  	uint32_t		ex_nflavors;
> > >  	struct exp_flavor_info	ex_flavors[MAX_SECINFO_LIST];
> > > -	enum pnfs_layouttype	ex_layout_type;
> > > +	u32			ex_layout_types;
> > >  	struct nfsd4_deviceid_map *ex_devid_map;
> > >  	struct cache_detail	*cd;
> > >  };
> > > diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
> > > index 6d98d16b3354..2be9602b0221 100644
> > > --- a/fs/nfsd/nfs4layouts.c
> > > +++ b/fs/nfsd/nfs4layouts.c
> > > @@ -139,21 +139,21 @@ void nfsd4_setup_layout_type(struct svc_export *exp)
> > >  	 * otherwise advertise the block layout.
> > >  	 */
> > >  #ifdef CONFIG_NFSD_FLEXFILELAYOUT
> > > -	exp->ex_layout_type = LAYOUT_FLEX_FILES;
> > > +	exp->ex_layout_types |= 1 << LAYOUT_FLEX_FILES;
> > >  #endif
> > >  #ifdef CONFIG_NFSD_BLOCKLAYOUT
> > >  	/* overwrite flex file layout selection if needed */
> > >  	if (sb->s_export_op->get_uuid &&
> > >  	    sb->s_export_op->map_blocks &&
> > >  	    sb->s_export_op->commit_blocks)
> > > -		exp->ex_layout_type = LAYOUT_BLOCK_VOLUME;
> > > +		exp->ex_layout_types |= 1 << LAYOUT_BLOCK_VOLUME;
> > >  #endif
> > >  #ifdef CONFIG_NFSD_SCSILAYOUT
> > >  	/* overwrite block layout selection if needed */
> > >  	if (sb->s_export_op->map_blocks &&
> > >  	    sb->s_export_op->commit_blocks &&
> > >  	    sb->s_bdev && sb->s_bdev->bd_disk->fops->pr_ops)
> > > -		exp->ex_layout_type = LAYOUT_SCSI;
> > > +		exp->ex_layout_types |= 1 << LAYOUT_SCSI;
> > >  #endif
> > >  }
> > >  
> > > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > > index 2ee2dc170327..719c620753e2 100644
> > > --- a/fs/nfsd/nfs4proc.c
> > > +++ b/fs/nfsd/nfs4proc.c
> > > @@ -1219,12 +1219,12 @@ nfsd4_verify(struct svc_rqst *rqstp, struct
> > > nfsd4_compound_state *cstate,
> > >  static const struct nfsd4_layout_ops *
> > >  nfsd4_layout_verify(struct svc_export *exp, unsigned int layout_type)
> > >  {
> > > -	if (!exp->ex_layout_type) {
> > > +	if (!exp->ex_layout_types) {
> > >  		dprintk("%s: export does not support pNFS\n", __func__);
> > >  		return NULL;
> > >  	}
> > >  
> > > -	if (exp->ex_layout_type != layout_type) {
> > > +	if (!(exp->ex_layout_types & (1 << layout_type))) {
> > >  		dprintk("%s: layout type %d not supported\n",
> > >  			__func__, layout_type);
> > >  		return NULL;
> > > diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> > > index 9df898ba648f..4d3ae75ad4c8 100644
> > > --- a/fs/nfsd/nfs4xdr.c
> > > +++ b/fs/nfsd/nfs4xdr.c
> > > @@ -2164,22 +2164,20 @@ nfsd4_encode_aclname(struct xdr_stream *xdr, struct
> > > svc_rqst *rqstp,
> > >  }
> > >  
> > >  static inline __be32
> > > -nfsd4_encode_layout_type(struct xdr_stream *xdr, enum pnfs_layouttype
> > > layout_type)
> > > +nfsd4_encode_layout_types(struct xdr_stream *xdr, u32 layout_types)
> > >  {
> > > -	__be32 *p;
> > > +	__be32		*p;
> > > +	unsigned long	i = hweight_long(layout_types);
> > >  
> > > -	if (layout_type) {
> > > -		p = xdr_reserve_space(xdr, 8);
> > > -		if (!p)
> > > -			return nfserr_resource;
> > > -		*p++ = cpu_to_be32(1);
> > > -		*p++ = cpu_to_be32(layout_type);
> > > -	} else {
> > > -		p = xdr_reserve_space(xdr, 4);
> > > -		if (!p)
> > > -			return nfserr_resource;
> > > -		*p++ = cpu_to_be32(0);
> > > -	}
> > > +	p = xdr_reserve_space(xdr, 4 + 4 * i);
> > > +	if (!p)
> > > +		return nfserr_resource;
> > > +
> > > +	*p++ = cpu_to_be32(i);
> > > +
> > > +	for (i = LAYOUT_NFSV4_1_FILES; i < LAYOUT_TYPE_MAX; ++i)
> > > +		if (layout_types & (1 << i))
> > > +			*p++ = cpu_to_be32(i);
> > >  
> > >  	return 0;
> > >  }
> > > @@ -2754,13 +2752,13 @@ out_acl:
> > >  	}
> > >  #ifdef CONFIG_NFSD_PNFS
> > >  	if (bmval1 & FATTR4_WORD1_FS_LAYOUT_TYPES) {
> > > -		status = nfsd4_encode_layout_type(xdr, exp->ex_layout_type);
> > > +		status = nfsd4_encode_layout_types(xdr, exp->ex_layout_types);
> > >  		if (status)
> > >  			goto out;
> > >  	}
> > >  
> > >  	if (bmval2 & FATTR4_WORD2_LAYOUT_TYPES) {
> > > -		status = nfsd4_encode_layout_type(xdr, exp->ex_layout_type);
> > > +		status = nfsd4_encode_layout_types(xdr, exp->ex_layout_types);
> > >  		if (status)
> > >  			goto out;
> > >  	}
> > 
> > 
> > Just a (lightly-tested) RFC patch for now.
> > 
> > This seems to do the right thing WRT to GETATTR response that requests
> > a layout types list. The current client code spews this into the ring
> > buffer though:
> > 
> >     NFS: decode_first_pnfs_layout_type: Warning: Multiple pNFS layout drivers per
> >     filesystem not supported
> > 
> > ...so that would need a little work. Wireshark also seems to not parse
> > the layout types list correctly.
> 
> Hi Jeff,
> 
> I had an attempt to add multi-layout support into the client:
> 
> https://github.com/0day-ci/linux/commit/e2d792dc32b82ffc511b009c0a8db5313126888e
> 
> I can't find it in the list archive. This explains why Trond never
> respond to it.
> 
> Tigran.
> 

Thanks. I had already rolled one up that does a different approach of a
hardcoded selection order in the client code and sent it as an RFC.

So...yours assumes that the server will send the "default" one first in
the list, but AFAICT, the spec doesn't say anything about the
fs_layout_type list being ordered in any way. I don't think we can make
that assumption. Am I wrong there?

What we probably ought to do is to plumb the selection in at a
different layer -- i.e., when you go to actually do the I/O. That way,
you could get a SCSI or block layout, figure out that you don't
actually have access to the device and fall back to using flexfiles or
files.
-- 
Jeff Layton <jlayton@poochiereds.net>
