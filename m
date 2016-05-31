Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:33455 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755886AbcEaVyF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 May 2016 17:54:05 -0400
Received: by mail-yw0-f196.google.com with SMTP id y6so146457ywe.0
        for <linux-nfs@vger.kernel.org>; Tue, 31 May 2016 14:54:04 -0700 (PDT)
Message-ID: <1464731641.3019.10.camel@poochiereds.net>
Subject: Re: [RFC PATCH] nfs: allow nfs client to handle servers that hand
 out multiple layout types
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: "tigran.mkrtchyan@desy.de" <tigran.mkrtchyan@desy.de>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "hch@infradead.org" <hch@infradead.org>
Date: Tue, 31 May 2016 17:54:01 -0400
In-Reply-To: <5E21BE07-5263-4309-A9B3-CB6364C12987@primarydata.com>
References: <1464626102-13100-1-git-send-email-jlayton@poochiereds.net>
 <58537471-DDCA-413F-AD22-1269A4301FBA@primarydata.com>
 <1464728975.3019.3.camel@poochiereds.net>
	 <5E21BE07-5263-4309-A9B3-CB6364C12987@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2016-05-31 at 21:41 +0000, Trond Myklebust wrote:
> 
> 
> On 5/31/16, 17:09, "Jeff Layton" <jlayton@poochiereds.net> wrote:
> 
> >On Tue, 2016-05-31 at 16:03 +0000, Trond Myklebust wrote:
> >> 
> >> On 5/30/16, 12:35, "Jeff Layton" <jlayton@poochiereds.net> wrote:
> >> 
> >> > Allow the client to deal with servers that hand out multiple layout
> >> > types for the same filesystem. When this happens, we pick the "best" one,
> >> > based on a hardcoded assumed order in the client code.
> >> > 
> >> > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> >> > ---
> >> > fs/nfs/client.c | 2 +-
> >> > fs/nfs/nfs4proc.c | 2 +-
> >> > fs/nfs/nfs4xdr.c | 41 +++++++++++++-------------
> >> > fs/nfs/pnfs.c | 76 ++++++++++++++++++++++++++++++++++++++-----------
> >> > include/linux/nfs_xdr.h | 2 +-
> >> > 5 files changed, 85 insertions(+), 38 deletions(-)
> >> > 
> >> > diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> >> > index 0c96528db94a..53b41f4bd45a 100644
> >> > --- a/fs/nfs/client.c
> >> > +++ b/fs/nfs/client.c
> >> > @@ -787,7 +787,7 @@ int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, struct nfs
> >> > }
> >> > 
> >> > fsinfo.fattr = fattr;
> >> > -	fsinfo.layouttype = 0;
> >> > +	fsinfo.layouttypes = 0;
> >> > error = clp->rpc_ops->fsinfo(server, mntfh, &fsinfo);
> >> > if (error < 0)
> >> > goto out_error;
> >> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> >> > index de97567795a5..9446aef89b48 100644
> >> > --- a/fs/nfs/nfs4proc.c
> >> > +++ b/fs/nfs/nfs4proc.c
> >> > @@ -4252,7 +4252,7 @@ static int nfs4_proc_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle, s
> >> > if (error == 0) {
> >> > /* block layout checks this! */
> >> > server->pnfs_blksize = fsinfo->blksize;
> >> > -	 set_pnfs_layoutdriver(server, fhandle, fsinfo->layouttype);
> >> > +	 set_pnfs_layoutdriver(server, fhandle, fsinfo->layouttypes);
> >> > }
> >> > 
> >> > return error;
> >> > diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> >> > index 661e753fe1c9..876a80802c1d 100644
> >> > --- a/fs/nfs/nfs4xdr.c
> >> > +++ b/fs/nfs/nfs4xdr.c
> >> > @@ -4723,33 +4723,36 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
> >> > * Decode potentially multiple layout types. Currently we only support
> >> > * one layout driver per file system.
> >> > */
> >> > -static int decode_first_pnfs_layout_type(struct xdr_stream *xdr,
> >> > -	 uint32_t *layouttype)
> >> > +static int decode_pnfs_layout_types(struct xdr_stream *xdr, u32 *layouttypes)
> >> > {
> >> > __be32 *p;
> >> > int num;
> >> > +	u32 type;
> >> > 
> >> > p = xdr_inline_decode(xdr, 4);
> >> > if (unlikely(!p))
> >> > goto out_overflow;
> >> > num = be32_to_cpup(p);
> >> > 
> >> > -	/* pNFS is not supported by the underlying file system */
> >> > -	if (num == 0) {
> >> > -	 *layouttype = 0;
> >> > -	 return 0;
> >> > -	}
> >> > -	if (num > 1)
> >> > -	 printk(KERN_INFO "NFS: %s: Warning: Multiple pNFS layout "
> >> > -	 "drivers per filesystem not supported\n", __func__);
> >> > +	*layouttypes = 0;
> >> > 
> >> > -	/* Decode and set first layout type, move xdr->p past unused types */
> >> > -	p = xdr_inline_decode(xdr, num * 4);
> >> > -	if (unlikely(!p))
> >> > -	 goto out_overflow;
> >> > -	*layouttype = be32_to_cpup(p);
> >> > +	for (; num; --num) {
> >> > +	 p = xdr_inline_decode(xdr, 4);
> >> > +
> >> > +	 if (unlikely(!p))
> >> > +	 goto out_overflow;
> >> > +
> >> > +	 type = be32_to_cpup(p);
> >> > +
> >> > +	 /* Ignore any that we don't understand */
> >> > +	 if (unlikely(type >= LAYOUT_TYPE_MAX))
> >> 
> >> This will in effect hard code the layouts that the client supports.
> >> LAYOUT_TYPE_MAX is something that applies to knfsd only for now.
> >> Let’s not leak it into the client. I suggest just making this
> >> 8*sizeof(*layouttypes).
> >> 
> >
> >Fair enough. I'll make that change.
> >
> >That said...LAYOUT_TYPE_MAX is a value in the pnfs_layouttype enum, and
> >that enum is used in both the client and the server code, AFAICT. If we
> >add a new LAYOUT_* value to that enum for the client, then we'll need
> >to increase that value anyway. So, I'm not sure I understand how this
> >limits the client in any way...
> 
> No, the client doesn’t use enum pnfs_layouttype anywhere. If you look
> at set_pnfs_layoutdriver(), you’ll note that we currently support all
> values for the layout type.
> 

Ok, I see. So if someone were to (for instance) create a 3rd party
layout driver module that had used a value above LAYOUT_TYPE_MAX then
this would prevent it from working.

Hmmm...so even if I make the change that you're suggesting, this will
still limit the client to working with layout types that are below a
value of 32. Is that also a problem? If so, then maybe I should respin
this to be more like the one Tigran had: make an array or something to
hold those values.

Thoughts?

> >
> >
> >> > +	 continue;
> >> > +
> >> > +	 *layouttypes |= 1 << type;
> >> > +	}
> >> > return 0;
> >> > out_overflow:
> >> > +	*layouttypes = 0;
> >> > print_overflow_msg(__func__, xdr);
> >> > return -EIO;
> >> > }
> >> > @@ -4759,7 +4762,7 @@ out_overflow:
> >> > * Note we must ensure that layouttype is set in any non-error case.
> >> > */
> >> > static int decode_attr_pnfstype(struct xdr_stream *xdr, uint32_t *bitmap,
> >> > -	 uint32_t *layouttype)
> >> > +	 __u32 *layouttypes)
> >> > {
> >> > int status = 0;
> >> > 
> >> > @@ -4767,10 +4770,10 @@ static int decode_attr_pnfstype(struct xdr_stream *xdr, uint32_t *bitmap,
> >> > if (unlikely(bitmap[1] & (FATTR4_WORD1_FS_LAYOUT_TYPES - 1U)))
> >> > return -EIO;
> >> > if (bitmap[1] & FATTR4_WORD1_FS_LAYOUT_TYPES) {
> >> > -	 status = decode_first_pnfs_layout_type(xdr, layouttype);
> >> > +	 status = decode_pnfs_layout_types(xdr, layouttypes);
> >> > bitmap[1] &= ~FATTR4_WORD1_FS_LAYOUT_TYPES;
> >> > } else
> >> > -	 *layouttype = 0;
> >> > +	 *layouttypes = 0;
> >> > return status;
> >> > }
> >> > 
> >> > @@ -4851,7 +4854,7 @@ static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
> >> > status = decode_attr_time_delta(xdr, bitmap, &fsinfo->time_delta);
> >> > if (status != 0)
> >> > goto xdr_error;
> >> > -	status = decode_attr_pnfstype(xdr, bitmap, &fsinfo->layouttype);
> >> > +	status = decode_attr_pnfstype(xdr, bitmap, &fsinfo->layouttypes);
> >> > if (status != 0)
> >> > goto xdr_error;
> >> > 
> >> > diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> >> > index 0c7e0d45a4de..20b7b1f4e041 100644
> >> > --- a/fs/nfs/pnfs.c
> >> > +++ b/fs/nfs/pnfs.c
> >> > @@ -70,7 +70,7 @@ out:
> >> > }
> >> > 
> >> > static struct pnfs_layoutdriver_type *
> >> > -find_pnfs_driver(u32 id)
> >> > +__find_pnfs_driver(u32 id)
> >> > {
> >> > struct pnfs_layoutdriver_type *local;
> >> > 
> >> > @@ -84,6 +84,22 @@ find_pnfs_driver(u32 id)
> >> > return local;
> >> > }
> >> > 
> >> > +static struct pnfs_layoutdriver_type *
> >> > +find_pnfs_driver(u32 id)
> >> > +{
> >> > +	struct pnfs_layoutdriver_type *ld_type;
> >> > +
> >> > +	ld_type = __find_pnfs_driver(id);
> >> > +	if (!ld_type) {
> >> > +	 request_module("%s-%u", LAYOUT_NFSV4_1_MODULE_PREFIX, id);
> >> > +	 ld_type = __find_pnfs_driver(id);
> >> > +	 if (!ld_type)
> >> > +	 dprintk("%s: No pNFS module found for %u.\n",
> >> > +	 __func__, id);
> >> > +	}
> >> > +	return ld_type;
> >> > +}
> >> > +
> >> > void
> >> > unset_pnfs_layoutdriver(struct nfs_server *nfss)
> >> > {
> >> > @@ -102,44 +118,72 @@ unset_pnfs_layoutdriver(struct nfs_server *nfss)
> >> > * Try to set the server's pnfs module to the pnfs layout type specified by id.
> >> > * Currently only one pNFS layout driver per filesystem is supported.
> >> > *
> >> > - * @id layout type. Zero (illegal layout type) indicates pNFS not in use.
> >> > + * @layouttypes: bitfield showing what layout types server supports
> >> > */
> >> > void
> >> > set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
> >> > -	 u32 id)
> >> > +	 u32 layouttypes)
> >> > {
> >> > struct pnfs_layoutdriver_type *ld_type = NULL;
> >> > 
> >> > -	if (id == 0)
> >> > +	if (layouttypes == 0)
> >> > goto out_no_driver;
> >> > if (!(server->nfs_client->cl_exchange_flags &
> >> > (EXCHGID4_FLAG_USE_NON_PNFS | EXCHGID4_FLAG_USE_PNFS_MDS))) {
> >> > -	 printk(KERN_ERR "NFS: %s: id %u cl_exchange_flags 0x%x\n",
> >> > -	 __func__, id, server->nfs_client->cl_exchange_flags);
> >> > +	 printk(KERN_ERR "NFS: %s: layouttypes 0x%x cl_exchange_flags 0x%x\n",
> >> > +	 __func__, layouttypes, server->nfs_client->cl_exchange_flags);
> >> > goto out_no_driver;
> >> > }
> >> > -	ld_type = find_pnfs_driver(id);
> >> > -	if (!ld_type) {
> >> > -	 request_module("%s-%u", LAYOUT_NFSV4_1_MODULE_PREFIX, id);
> >> > -	 ld_type = find_pnfs_driver(id);
> >> > -	 if (!ld_type) {
> >> > -	 dprintk("%s: No pNFS module found for %u.\n",
> >> > -	 __func__, id);
> >> > +
> >> > +	/*
> >> > +	 * See if one of the layout types that we got handed is usable. We
> >> > +	 * attempt in a hardcoded order of preference, in order of (assumed)
> >> > +	 * decreasing speeds and functionality.
> >> > +	 *
> >> > +	 * FIXME: should this order be configurable in some fashion?
> >> > +	 */
> >> > +	if (layouttypes & (1 << LAYOUT_SCSI)) {
> >> > +	 ld_type = find_pnfs_driver(LAYOUT_SCSI);
> >> > +	 if (ld_type)
> >> > +	 goto set_driver;
> >> > +	}
> >> > +
> >> > +	if (layouttypes & (1 << LAYOUT_BLOCK_VOLUME)) {
> >> > +	 ld_type = find_pnfs_driver(LAYOUT_BLOCK_VOLUME);
> >> > +	 if (ld_type)
> >> > +	 goto set_driver;
> >> > +	}
> >> > +
> >> > +	if (layouttypes & (1 << LAYOUT_OSD2_OBJECTS)) {
> >> > +	 ld_type = find_pnfs_driver(LAYOUT_OSD2_OBJECTS);
> >> > +	 if (ld_type)
> >> > +	 goto set_driver;
> >> > +	}
> >> > +
> >> > +	if (layouttypes & (1 << LAYOUT_FLEX_FILES)) {
> >> > +	 ld_type = find_pnfs_driver(LAYOUT_FLEX_FILES);
> >> > +	 if (ld_type)
> >> > +	 goto set_driver;
> >> > +	}
> >> > +
> >> > +	if (layouttypes & (1 << LAYOUT_NFSV4_1_FILES)) {
> >> > +	 ld_type = find_pnfs_driver(LAYOUT_NFSV4_1_FILES);
> >> > +	 if (!ld_type)
> >> > goto out_no_driver;
> >> > -	 }
> >> > }
> >> > +set_driver:
> >> > server->pnfs_curr_ld = ld_type;
> >> > if (ld_type->set_layoutdriver
> >> > && ld_type->set_layoutdriver(server, mntfh)) {
> >> > printk(KERN_ERR "NFS: %s: Error initializing pNFS layout "
> >> > -	 "driver %u.\n", __func__, id);
> >> > +	 "driver %u.\n", __func__, ld_type->id);
> >> > module_put(ld_type->owner);
> >> > goto out_no_driver;
> >> > }
> >> > /* Bump the MDS count */
> >> > atomic_inc(&server->nfs_client->cl_mds_count);
> >> > 
> >> > -	dprintk("%s: pNFS module for %u set\n", __func__, id);
> >> > +	dprintk("%s: pNFS module for %u set\n", __func__, ld_type->id);
> >> > return;
> >> > 
> >> > out_no_driver:
> >> > diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> >> > index c304a11b5b1a..1f6bb59f05f2 100644
> >> > --- a/include/linux/nfs_xdr.h
> >> > +++ b/include/linux/nfs_xdr.h
> >> > @@ -139,7 +139,7 @@ struct nfs_fsinfo {
> >> > __u64	 maxfilesize;
> >> > struct timespec	 time_delta; /* server time granularity */
> >> > __u32	 lease_time; /* in seconds */
> >> > -	__u32	 layouttype; /* supported pnfs layout driver */
> >> > +	__u32	 layouttypes; /* supported pnfs layout drivers */
> >> > __u32	 blksize; /* preferred pnfs io block size */
> >> > __u32	 clone_blksize; /* granularity of a CLONE operation */
> >> > };
> >> > -- 
> >> > 2.5.5
> >> > 
> >> 
> >> NrybXǧv^)޺{.n+{"^nrz?h&?Gh?(階ݢj"??mzޖfh~m
> >-- 
> >Jeff Layton <jlayton@poochiereds.net>
> >
> 
> 
> Disclaimer
> The information contained in this communication from the sender is confidential. It is intended solely for use by the recipient and others authorized to receive it. If you are not the recipient, you are hereby notified that any disclosure, copying, distribution or taking action in relation of the contents of this information is strictly prohibited and may be unlawful.
-- 
Jeff Layton <jlayton@poochiereds.net>
