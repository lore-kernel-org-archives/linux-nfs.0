Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:34904 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530AbcFAMz2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2016 08:55:28 -0400
Received: by mail-yw0-f193.google.com with SMTP id n16so2380813ywd.2
        for <linux-nfs@vger.kernel.org>; Wed, 01 Jun 2016 05:55:27 -0700 (PDT)
Message-ID: <1464785724.14439.4.camel@poochiereds.net>
Subject: Re: [RFC PATCH] nfsd: allow nfsd to advertise multiple layout types
From: Jeff Layton <jlayton@poochiereds.net>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: Weston Andros Adamson <dros@monkey.org>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        Tom Haynes <thomas.haynes@primarydata.com>,
        Christoph Hellwig <hch@lst.de>
Date: Wed, 01 Jun 2016 08:55:24 -0400
In-Reply-To: <20160601125107.GB3387@fieldses.org>
References: <1464555567-16055-1-git-send-email-jlayton@poochiereds.net>
 <643433762.15123359.1464623258309.JavaMail.zimbra@desy.de>
 <1464627098.8117.6.camel@poochiereds.net>
 <1373800959.15136324.1464627888132.JavaMail.zimbra@desy.de>
 <1464631520.13639.12.camel@poochiereds.net>
 <1457806307.15151735.1464633767657.JavaMail.zimbra@desy.de>
 <E916D988-C7AA-42C0-B552-CDA808605FE7@monkey.org>
 <1464659250.8117.25.camel@poochiereds.net>
 <703205520.15241153.1464699640808.JavaMail.zimbra@desy.de>
	 <20160601125107.GB3387@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-06-01 at 08:51 -0400, J. Bruce Fields wrote:
> On Tue, May 31, 2016 at 03:00:40PM +0200, Mkrtchyan, Tigran wrote:
> > Hi Jeff,
> > 
> > I have tested the patch. Works as expected.
> > I am able to use flexfiles with latest kernel
> > while older client use nfs4_file_layout. So
> 
> Please just add a comment documenting the issue with older clients
> and
> what we're doing to keep them working, so that we don't accidentally
> break that.
> 
> --b.
> 

Will do.

To be clear too...Tigran only tested the client side piece of this
patchset vs. his own server that hands out multiple layouts. He didn't
actually test the knfsd patch even though his response was to this
thread.

Sorry about the messy patch posting. I'll re-post the set once I've
retested the latest changes.

> > 
> > Teset-by:
> > 
> > Unrelated to you patch (as it now fails with my as well),
> > flex file layout hangs on write with 4.7-rc1 (and 4.6.0).
> > The same test works with nfs4_files. I will recompile with
> > an older version, where I tested in the past (4.5-rc3?).
> > 
> > I will start a new email with my discoveries.
> > 
> > Tigran.
> > 
> > ----- Original Message -----
> > > From: "Jeff Layton" <jlayton@poochiereds.net>
> > > To: "Weston Andros Adamson" <dros@monkey.org>, "Tigran Mkrtchyan"
> > > <tigran.mkrtchyan@desy.de>
> > > Cc: "linux-nfs list" <linux-nfs@vger.kernel.org>, "Tom Haynes" <t
> > > homas.haynes@primarydata.com>, "Christoph Hellwig"
> > > <hch@lst.de>
> > > Sent: Tuesday, May 31, 2016 3:47:30 AM
> > > Subject: Re: [RFC PATCH] nfsd: allow nfsd to advertise multiple
> > > layout types
> > 
> > > On Mon, 2016-05-30 at 21:10 -0400, Weston Andros Adamson wrote:
> > > > > 
> > > > > On May 30, 2016, at 2:42 PM, Mkrtchyan, Tigran  wrote:
> > > > > 
> > > > > 
> > > > > 
> > > > > You have explicit order in set_pnfs_layoutdriver function.
> > > > > Your patch looks like ot to me. I will try it with our
> > > > > server and will let you know.
> > > > > 
> > > > > Tigran.
> > > > > 
> > > > > ----- Original Message -----
> > > > > > From: "Jeff Layton" <jlayton@poochiereds.net>
> > > > > > To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
> > > > > > Cc: linux-nfs@vger.kernel.org, "Tom Haynes" , "Christoph
> > > > > > Hellwig" <hch@lst.de>
> > > > > > Sent: Monday, May 30, 2016 8:05:20 PM
> > > > > > Subject: Re: [RFC PATCH] nfsd: allow nfsd to advertise
> > > > > > multiple layout types
> > > > > 
> > > > > > On Mon, 2016-05-30 at 19:04 +0200, Mkrtchyan, Tigran wrote:
> > > > > > > 
> > > > > > > ----- Original Message -----
> > > > > > > > 
> > > > > > > > From: "Jeff Layton" <jlayton@poochiereds.net>
> > > > > > > > To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
> > > > > > > > Cc: linux-nfs@vger.kernel.org, "Tom Haynes" ,
> > > > > > > > "Christoph Hellwig" <hch@lst.de>
> > > > > > > > Sent: Monday, May 30, 2016 6:51:38 PM
> > > > > > > > Subject: Re: [RFC PATCH] nfsd: allow nfsd to advertise
> > > > > > > > multiple layout types
> > > > > > > > 
> > > > > > > > On Mon, 2016-05-30 at 17:47 +0200, Mkrtchyan, Tigran
> > > > > > > > wrote:
> > > > > > > > > 
> > > > > > > > > 
> > > > > > > > > ----- Original Message -----
> > > > > > > > > > 
> > > > > > > > > > From: "Jeff Layton" <jlayton@poochiereds.net>
> > > > > > > > > > To: linux-nfs@vger.kernel.org
> > > > > > > > > > Cc: "Tom Haynes" <thomas.haynes@primarydata.com>,
> > > > > > > > > > "Christoph Hellwig"
> > > > > > > > > > <hch@lst.de>
> > > > > > > > > > Sent: Sunday, May 29, 2016 11:06:14 PM
> > > > > > > > > > Subject: Re: [RFC PATCH] nfsd: allow nfsd to
> > > > > > > > > > advertise multiple layout types
> > > > > > > > > > 
> > > > > > > > > > On Sun, 2016-05-29 at 16:59 -0400, Jeff Layton
> > > > > > > > > > wrote:
> > > > > > > > > > > 
> > > > > > > > > > > If the underlying filesystem supports multiple
> > > > > > > > > > > layout types, then there
> > > > > > > > > > > is little reason not to advertise that fact to
> > > > > > > > > > > clients and let them
> > > > > > > > > > > choose what type to use.
> > > > > > > > > > > 
> > > > > > > > > > > Turn the ex_layout_type field into a bitfield.
> > > > > > > > > > > For each supported
> > > > > > > > > > > layout type, we set a bit in that field. When the
> > > > > > > > > > > client requests a
> > > > > > > > > > > layout, ensure that the bit for that layout type
> > > > > > > > > > > is set. When the
> > > > > > > > > > > client requests attributes, send back a list of
> > > > > > > > > > > supported types.
> > > > > > > > > > > 
> > > > > > > > > > > Signed-off-by: Jeff Layton <jeff.layton@primaryda
> > > > > > > > > > > ta.com>
> > > > > > > > > > > ---
> > > > > > > > > > >  fs/nfsd/export.c      |  4 ++--
> > > > > > > > > > >  fs/nfsd/export.h      |  2 +-
> > > > > > > > > > >  fs/nfsd/nfs4layouts.c |  6 +++---
> > > > > > > > > > >  fs/nfsd/nfs4proc.c    |  4 ++--
> > > > > > > > > > >  fs/nfsd/nfs4xdr.c     | 30 ++++++++++++++-------
> > > > > > > > > > > ---------
> > > > > > > > > > >  5 files changed, 22 insertions(+), 24
> > > > > > > > > > > deletions(-)
> > > > > > > > > > > 
> > > > > > > > > > > diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> > > > > > > > > > > index b4d84b579f20..f97ba49d5e66 100644
> > > > > > > > > > > --- a/fs/nfsd/export.c
> > > > > > > > > > > +++ b/fs/nfsd/export.c
> > > > > > > > > > > @@ -706,7 +706,7 @@ static void
> > > > > > > > > > > svc_export_init(struct cache_head *cnew, struct
> > > > > > > > > > > cache_head *citem)
> > > > > > > > > > >  	new->ex_fslocs.locations = NULL;
> > > > > > > > > > >  	new->ex_fslocs.locations_count = 0;
> > > > > > > > > > >  	new->ex_fslocs.migrated = 0;
> > > > > > > > > > > -	new->ex_layout_type = 0;
> > > > > > > > > > > +	new->ex_layout_types = 0;
> > > > > > > > > > >  	new->ex_uuid = NULL;
> > > > > > > > > > >  	new->cd = item->cd;
> > > > > > > > > > >  }
> > > > > > > > > > > @@ -731,7 +731,7 @@ static void
> > > > > > > > > > > export_update(struct cache_head *cnew, struct
> > > > > > > > > > > cache_head *citem)
> > > > > > > > > > >  	item->ex_fslocs.locations_count = 0;
> > > > > > > > > > >  	new->ex_fslocs.migrated = item-
> > > > > > > > > > > >ex_fslocs.migrated;
> > > > > > > > > > >  	item->ex_fslocs.migrated = 0;
> > > > > > > > > > > -	new->ex_layout_type = item-
> > > > > > > > > > > >ex_layout_type;
> > > > > > > > > > > +	new->ex_layout_types = item-
> > > > > > > > > > > >ex_layout_types;
> > > > > > > > > > >  	new->ex_nflavors = item->ex_nflavors;
> > > > > > > > > > >  	for (i = 0; i < MAX_SECINFO_LIST; i++) {
> > > > > > > > > > >  		new->ex_flavors[i] = item-
> > > > > > > > > > > >ex_flavors[i];
> > > > > > > > > > > diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
> > > > > > > > > > > index 2e315072bf3f..730f15eeb7ed 100644
> > > > > > > > > > > --- a/fs/nfsd/export.h
> > > > > > > > > > > +++ b/fs/nfsd/export.h
> > > > > > > > > > > @@ -57,7 +57,7 @@ struct svc_export {
> > > > > > > > > > >  	struct nfsd4_fs_locations ex_fslocs;
> > > > > > > > > > >  	uint32_t		ex_nflavors;
> > > > > > > > > > >  	struct exp_flavor_info	ex_flavors
> > > > > > > > > > > [MAX_SECINFO_LIST];
> > > > > > > > > > > -	enum pnfs_layouttype	ex_layout_ty
> > > > > > > > > > > pe;
> > > > > > > > > > > +	u32			ex_layout_typ
> > > > > > > > > > > es;
> > > > > > > > > > >  	struct nfsd4_deviceid_map *ex_devid_map;
> > > > > > > > > > >  	struct cache_detail	*cd;
> > > > > > > > > > >  };
> > > > > > > > > > > diff --git a/fs/nfsd/nfs4layouts.c
> > > > > > > > > > > b/fs/nfsd/nfs4layouts.c
> > > > > > > > > > > index 6d98d16b3354..2be9602b0221 100644
> > > > > > > > > > > --- a/fs/nfsd/nfs4layouts.c
> > > > > > > > > > > +++ b/fs/nfsd/nfs4layouts.c
> > > > > > > > > > > @@ -139,21 +139,21 @@ void
> > > > > > > > > > > nfsd4_setup_layout_type(struct svc_export *exp)
> > > > > > > > > > >  	 * otherwise advertise the block layout.
> > > > > > > > > > >  	 */
> > > > > > > > > > >  #ifdef CONFIG_NFSD_FLEXFILELAYOUT
> > > > > > > > > > > -	exp->ex_layout_type = LAYOUT_FLEX_FILES;
> > > > > > > > > > > +	exp->ex_layout_types |= 1 <<
> > > > > > > > > > > LAYOUT_FLEX_FILES;
> > > > > > > > > > >  #endif
> > > > > > > > > > >  #ifdef CONFIG_NFSD_BLOCKLAYOUT
> > > > > > > > > > >  	/* overwrite flex file layout selection
> > > > > > > > > > > if needed */
> > > > > > > > > > >  	if (sb->s_export_op->get_uuid &&
> > > > > > > > > > >  	    sb->s_export_op->map_blocks &&
> > > > > > > > > > >  	    sb->s_export_op->commit_blocks)
> > > > > > > > > > > -		exp->ex_layout_type =
> > > > > > > > > > > LAYOUT_BLOCK_VOLUME;
> > > > > > > > > > > +		exp->ex_layout_types |= 1 <<
> > > > > > > > > > > LAYOUT_BLOCK_VOLUME;
> > > > > > > > > > >  #endif
> > > > > > > > > > >  #ifdef CONFIG_NFSD_SCSILAYOUT
> > > > > > > > > > >  	/* overwrite block layout selection if
> > > > > > > > > > > needed */
> > > > > > > > > > >  	if (sb->s_export_op->map_blocks &&
> > > > > > > > > > >  	    sb->s_export_op->commit_blocks &&
> > > > > > > > > > >  	    sb->s_bdev && sb->s_bdev->bd_disk-
> > > > > > > > > > > >fops->pr_ops)
> > > > > > > > > > > -		exp->ex_layout_type =
> > > > > > > > > > > LAYOUT_SCSI;
> > > > > > > > > > > +		exp->ex_layout_types |= 1 <<
> > > > > > > > > > > LAYOUT_SCSI;
> > > > > > > > > > >  #endif
> > > > > > > > > > >  }
> > > > > > > > > > >  
> > > > > > > > > > > diff --git a/fs/nfsd/nfs4proc.c
> > > > > > > > > > > b/fs/nfsd/nfs4proc.c
> > > > > > > > > > > index 2ee2dc170327..719c620753e2 100644
> > > > > > > > > > > --- a/fs/nfsd/nfs4proc.c
> > > > > > > > > > > +++ b/fs/nfsd/nfs4proc.c
> > > > > > > > > > > @@ -1219,12 +1219,12 @@ nfsd4_verify(struct
> > > > > > > > > > > svc_rqst *rqstp, struct
> > > > > > > > > > > nfsd4_compound_state *cstate,
> > > > > > > > > > >  static const struct nfsd4_layout_ops *
> > > > > > > > > > >  nfsd4_layout_verify(struct svc_export *exp,
> > > > > > > > > > > unsigned int layout_type)
> > > > > > > > > > >  {
> > > > > > > > > > > -	if (!exp->ex_layout_type) {
> > > > > > > > > > > +	if (!exp->ex_layout_types) {
> > > > > > > > > > >  		dprintk("%s: export does not
> > > > > > > > > > > support pNFS\n", __func__);
> > > > > > > > > > >  		return NULL;
> > > > > > > > > > >  	}
> > > > > > > > > > >  
> > > > > > > > > > > -	if (exp->ex_layout_type != layout_type)
> > > > > > > > > > > {
> > > > > > > > > > > +	if (!(exp->ex_layout_types & (1 <<
> > > > > > > > > > > layout_type))) {
> > > > > > > > > > >  		dprintk("%s: layout type %d not
> > > > > > > > > > > supported\n",
> > > > > > > > > > >  			__func__, layout_type);
> > > > > > > > > > >  		return NULL;
> > > > > > > > > > > diff --git a/fs/nfsd/nfs4xdr.c
> > > > > > > > > > > b/fs/nfsd/nfs4xdr.c
> > > > > > > > > > > index 9df898ba648f..4d3ae75ad4c8 100644
> > > > > > > > > > > --- a/fs/nfsd/nfs4xdr.c
> > > > > > > > > > > +++ b/fs/nfsd/nfs4xdr.c
> > > > > > > > > > > @@ -2164,22 +2164,20 @@
> > > > > > > > > > > nfsd4_encode_aclname(struct xdr_stream *xdr,
> > > > > > > > > > > struct
> > > > > > > > > > > svc_rqst *rqstp,
> > > > > > > > > > >  }
> > > > > > > > > > >  
> > > > > > > > > > >  static inline __be32
> > > > > > > > > > > -nfsd4_encode_layout_type(struct xdr_stream *xdr,
> > > > > > > > > > > enum pnfs_layouttype
> > > > > > > > > > > layout_type)
> > > > > > > > > > > +nfsd4_encode_layout_types(struct xdr_stream
> > > > > > > > > > > *xdr, u32 layout_types)
> > > > > > > > > > >  {
> > > > > > > > > > > -	__be32 *p;
> > > > > > > > > > > +	__be32		*p;
> > > > > > > > > > > +	unsigned long	i =
> > > > > > > > > > > hweight_long(layout_types);
> > > > > > > > > > >  
> > > > > > > > > > > -	if (layout_type) {
> > > > > > > > > > > -		p = xdr_reserve_space(xdr, 8);
> > > > > > > > > > > -		if (!p)
> > > > > > > > > > > -			return nfserr_resource;
> > > > > > > > > > > -		*p++ = cpu_to_be32(1);
> > > > > > > > > > > -		*p++ = cpu_to_be32(layout_type);
> > > > > > > > > > > -	} else {
> > > > > > > > > > > -		p = xdr_reserve_space(xdr, 4);
> > > > > > > > > > > -		if (!p)
> > > > > > > > > > > -			return nfserr_resource;
> > > > > > > > > > > -		*p++ = cpu_to_be32(0);
> > > > > > > > > > > -	}
> > > > > > > > > > > +	p = xdr_reserve_space(xdr, 4 + 4 * i);
> > > > > > > > > > > +	if (!p)
> > > > > > > > > > > +		return nfserr_resource;
> > > > > > > > > > > +
> > > > > > > > > > > +	*p++ = cpu_to_be32(i);
> > > > > > > > > > > +
> > > > > > > > > > > +	for (i = LAYOUT_NFSV4_1_FILES; i <
> > > > > > > > > > > LAYOUT_TYPE_MAX; ++i)
> > > > > > > > > > > +		if (layout_types & (1 << i))
> > > > > > > > > > > +			*p++ = cpu_to_be32(i);
> > > > > > > > > > >  
> > > > > > > > > > >  	return 0;
> > > > > > > > > > >  }
> > > > > > > > > > > @@ -2754,13 +2752,13 @@ out_acl:
> > > > > > > > > > >  	}
> > > > > > > > > > >  #ifdef CONFIG_NFSD_PNFS
> > > > > > > > > > >  	if (bmval1 &
> > > > > > > > > > > FATTR4_WORD1_FS_LAYOUT_TYPES) {
> > > > > > > > > > > -		status =
> > > > > > > > > > > nfsd4_encode_layout_type(xdr, exp-
> > > > > > > > > > > >ex_layout_type);
> > > > > > > > > > > +		status =
> > > > > > > > > > > nfsd4_encode_layout_types(xdr, exp-
> > > > > > > > > > > >ex_layout_types);
> > > > > > > > > > >  		if (status)
> > > > > > > > > > >  			goto out;
> > > > > > > > > > >  	}
> > > > > > > > > > >  
> > > > > > > > > > >  	if (bmval2 & FATTR4_WORD2_LAYOUT_TYPES)
> > > > > > > > > > > {
> > > > > > > > > > > -		status =
> > > > > > > > > > > nfsd4_encode_layout_type(xdr, exp-
> > > > > > > > > > > >ex_layout_type);
> > > > > > > > > > > +		status =
> > > > > > > > > > > nfsd4_encode_layout_types(xdr, exp-
> > > > > > > > > > > >ex_layout_types);
> > > > > > > > > > >  		if (status)
> > > > > > > > > > >  			goto out;
> > > > > > > > > > >  	}
> > > > > > > > > > 
> > > > > > > > > > Just a (lightly-tested) RFC patch for now.
> > > > > > > > > > 
> > > > > > > > > > This seems to do the right thing WRT to GETATTR
> > > > > > > > > > response that requests
> > > > > > > > > > a layout types list. The current client code spews
> > > > > > > > > > this into the ring
> > > > > > > > > > buffer though:
> > > > > > > > > > 
> > > > > > > > > >     NFS: decode_first_pnfs_layout_type: Warning:
> > > > > > > > > > Multiple pNFS layout drivers per
> > > > > > > > > >     filesystem not supported
> > > > > > > > > > 
> > > > > > > > > > ...so that would need a little work. Wireshark also
> > > > > > > > > > seems to not parse
> > > > > > > > > > the layout types list correctly.
> > > > > > > > > Hi Jeff,
> > > > > > > > > 
> > > > > > > > > I had an attempt to add multi-layout support into the
> > > > > > > > > client:
> > > > > > > > > 
> > > > > > > > > https://github.com/0day-ci/linux/commit/e2d792dc32b82
> > > > > > > > > ffc511b009c0a8db5313126888e
> > > > > > > > > 
> > > > > > > > > I can't find it in the list archive. This explains
> > > > > > > > > why Trond never
> > > > > > > > > respond to it.
> > > > > > > > > 
> > > > > > > > > Tigran.
> > > > > > > > > 
> > > > > > > > Thanks. I had already rolled one up that does a
> > > > > > > > different approach of a
> > > > > > > > hardcoded selection order in the client code and sent
> > > > > > > > it as an RFC.
> > > > > > > > 
> > > > > > > > So...yours assumes that the server will send the
> > > > > > > > "default" one first in
> > > > > > > > the list, but AFAICT, the spec doesn't say anything
> > > > > > > > about the
> > > > > > > > fs_layout_type list being ordered in any way. I don't
> > > > > > > > think we can make
> > > > > > > > that assumption. Am I wrong there?
> > > > > > > Imagine a muti-layout server in a deployment, where some
> > > > > > > client are old (RHEL6)
> > > > > > > and some clients are new. RHEL6 will always take only the
> > > > > > > first one and fail, if
> > > > > > > it wasn't nfs4_file_layout. But, if we always return
> > > > > > > 'well-known' as a first
> > > > > > > one,
> > > > > > > then, then RHEL6 clients will be able to coexists with
> > > > > > > newer clients.
> > > > > > > 
> > > > > > > Our server can provide flexfile layouts, but 99% of our
> > > > > > > clients are
> > > > > > > RHEL6-clones.
> > > > > > > This stops us from enable flexfile support, unless we add
> > > > > > > per-client based
> > > > > > > control
> > > > > > > of layout type.
> > > > > > > 
> > > > > > > Tigran.
> > > > > > > 
> > > > > > 
> > > > > > Ahh ok, I see what you mean...
> > > > > > 
> > > > > > So yeah, I don't think the spec places any significance on
> > > > > > the order of
> > > > > > the list, but we some de-facto precedence due to legacy
> > > > > > clients. Not
> > > > > > much we can do about that. I guess all you can do for those
> > > > > > clients is
> > > > > > just ensure that the first entry is the one most likely to
> > > > > > be usable by
> > > > > > those clients.
> > > > > > 
> > > > > > This patch just orders the list by numerical value of the
> > > > > > layout type
> > > > > > constants. If someone can offer up a sane argument for
> > > > > > ordering the
> > > > > > list in a different fashion, then I'm OK with doing that.
> > > > > > 
> > > > > > --
> > > > > > Jeff Layton <jlayton@poochiereds.net>
> > > > > 
> > > > 
> > > > Jeff, this patch looks good to me.
> > > > 
> > > > As for backward compatibility, we could do some complicated
> > > > client
> > > > support detection (implementation ID based or fallback if
> > > > layout is rejected),
> > > > but that’s probably going overboard for now.
> > > > 
> > > 
> > > Yeah, this is a step in the right direction I think, but we may
> > > need to
> > > do something more elaborate eventually.
> > > 
> > > > Maybe we should just hardcode this array instead of building it
> > > > in the
> > > > order of the numerical value of each layout type. We could add
> > > > them in
> > > > the order that the client supported them.
> > > >  I think that would fix Tigran’s
> > > > problem. Maybe it’s already in this order as client support
> > > > quickly followed
> > > > layout type number allocation?
> > > > 
> > > 
> > > Hmm...knfsd only supports block, scsi and flexfiles (as of Tom's
> > > patches). We might want to re-sort the list so that scsi comes
> > > first,
> > > actually? OTOH...block was there first so maybe it ought to be
> > > first?
> > > Hard to know without knowing exactly what sort of clients you
> > > have.
> > > 
> > > Either way, the order of the array that the server sends and the
> > > preference of the client for various layouts can both definitely
> > > be
> > > changed.
> > > 
> > > Perhaps this isn't a one-size-fits-all situation and it needs to
> > > be
> > > configurable somehow at the client and/or server?
> > > --
> > > Jeff Layton <jlayton@poochiereds.net>
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-
> > > nfs" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.htm
> > > l
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-
> > nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jeff Layton <jlayton@poochiereds.net>
