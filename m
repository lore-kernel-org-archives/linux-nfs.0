Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:56651 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754213AbcFGM0S convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 08:26:18 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 86464280A5E
	for <linux-nfs@vger.kernel.org>; Tue,  7 Jun 2016 14:26:13 +0200 (CEST)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 5E96F13E86
	for <linux-nfs@vger.kernel.org>; Tue,  7 Jun 2016 14:26:12 +0200 (MEST)
Date: Tue, 7 Jun 2016 14:26:12 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Trond Myklebust <trondmy@primarydata.com>, linux-nfs@vger.kernel.org,
        Anna Schumaker <Anna.Schumaker@netapp.com>, hch@infradead.org
Message-ID: <797047869.16381632.1465302372374.JavaMail.zimbra@desy.de>
In-Reply-To: <1464865459.18407.4.camel@poochiereds.net>
References: <1464626102-13100-1-git-send-email-jlayton@poochiereds.net> <58537471-DDCA-413F-AD22-1269A4301FBA@primarydata.com> <1464728975.3019.3.camel@poochiereds.net> <5E21BE07-5263-4309-A9B3-CB6364C12987@primarydata.com> <1464731641.3019.10.camel@poochiereds.net> <1464817983.14439.18.camel@poochiereds.net> <1077353647.15633587.1464851550355.JavaMail.zimbra@desy.de> <1464865459.18407.4.camel@poochiereds.net>
Subject: Re: [RFC PATCH] nfs: allow nfs client to handle servers that hand
 out multiple layout types
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "Jeff Layton" <jlayton@poochiereds.net>
> To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
> Cc: "Trond Myklebust" <trondmy@primarydata.com>, linux-nfs@vger.kernel.org, "Anna Schumaker"
> <Anna.Schumaker@netapp.com>, hch@infradead.org
> Sent: Thursday, June 2, 2016 1:04:19 PM
> Subject: Re: [RFC PATCH] nfs: allow nfs client to handle servers that hand out multiple layout types

> On Thu, 2016-06-02 at 09:12 +0200, Mkrtchyan, Tigran wrote:
>> 
>> ----- Original Message -----
>> > From: "Jeff Layton" <jlayton@poochiereds.net>
>> > To: "Trond Myklebust" <trondmy@primarydata.com>, linux-nfs@vger.kernel.org
>> > Cc: "tigran mkrtchyan" <tigran.mkrtchyan@desy.de>, "Anna Schumaker"
>> > <Anna.Schumaker@netapp.com>, hch@infradead.org
>> > Sent: Wednesday, June 1, 2016 11:53:03 PM
>> > Subject: Re: [RFC PATCH] nfs: allow nfs client to handle servers that hand out
>> > multiple layout types
>> 
>> > On Tue, 2016-05-31 at 17:54 -0400, Jeff Layton wrote:
>> > > On Tue, 2016-05-31 at 21:41 +0000, Trond Myklebust wrote:
>> > > > 
>> > > > 
>> > > > On 5/31/16, 17:09, "Jeff Layton" <jlayton@poochiereds.net> wrote:
>> > > > 
>> > > > > On Tue, 2016-05-31 at 16:03 +0000, Trond Myklebust wrote:
>> > > > > >  
>> > > > > > On 5/30/16, 12:35, "Jeff Layton" <jlayton@poochiereds.net> wrote:
>> > > > > >  
>> > > > > > > Allow the client to deal with servers that hand out multiple layout
>> > > > > > > types for the same filesystem. When this happens, we pick the "best" one,
>> > > > > > > based on a hardcoded assumed order in the client code.
>> > > > > > >  
>> > > > > > > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
>> > > > > > > ---
>> > > > > > > fs/nfs/client.c | 2 +-
>> > > > > > > fs/nfs/nfs4proc.c | 2 +-
>> > > > > > > fs/nfs/nfs4xdr.c | 41 +++++++++++++-------------
>> > > > > > > fs/nfs/pnfs.c | 76 ++++++++++++++++++++++++++++++++++++++-----------
>> > > > > > > include/linux/nfs_xdr.h | 2 +-
>> > > > > > > 5 files changed, 85 insertions(+), 38 deletions(-)
>> > > > > > >  
>> > > > > > > diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>> > > > > > > index 0c96528db94a..53b41f4bd45a 100644
>> > > > > > > --- a/fs/nfs/client.c
>> > > > > > > +++ b/fs/nfs/client.c
>> > > > > > > @@ -787,7 +787,7 @@ int nfs_probe_fsinfo(struct nfs_server *server, struct
>> > > > > > > nfs_fh *mntfh, struct nfs
>> > > > > > > }
>> > > > > > >  
>> > > > > > > fsinfo.fattr = fattr;
>> > > > > > > -	fsinfo.layouttype = 0;
>> > > > > > > +	fsinfo.layouttypes = 0;
>> > > > > > > error = clp->rpc_ops->fsinfo(server, mntfh, &fsinfo);
>> > > > > > > if (error < 0)
>> > > > > > > goto out_error;
>> > > > > > > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> > > > > > > index de97567795a5..9446aef89b48 100644
>> > > > > > > --- a/fs/nfs/nfs4proc.c
>> > > > > > > +++ b/fs/nfs/nfs4proc.c
>> > > > > > > @@ -4252,7 +4252,7 @@ static int nfs4_proc_fsinfo(struct nfs_server *server,
>> > > > > > > struct nfs_fh *fhandle, s
>> > > > > > > if (error == 0) {
>> > > > > > > /* block layout checks this! */
>> > > > > > > server->pnfs_blksize = fsinfo->blksize;
>> > > > > > > -	 set_pnfs_layoutdriver(server, fhandle, fsinfo->layouttype);
>> > > > > > > +	 set_pnfs_layoutdriver(server, fhandle, fsinfo->layouttypes);
>> > > > > > > }
>> > > > > > >  
>> > > > > > > return error;
>> > > > > > > diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> > > > > > > index 661e753fe1c9..876a80802c1d 100644
>> > > > > > > --- a/fs/nfs/nfs4xdr.c
>> > > > > > > +++ b/fs/nfs/nfs4xdr.c
>> > > > > > > @@ -4723,33 +4723,36 @@ static int decode_getfattr(struct xdr_stream *xdr,
>> > > > > > > struct nfs_fattr *fattr,
>> > > > > > > * Decode potentially multiple layout types. Currently we only support
>> > > > > > > * one layout driver per file system.
>> > > > > > > */
>> > > > > > > -static int decode_first_pnfs_layout_type(struct xdr_stream *xdr,
>> > > > > > > -	 uint32_t *layouttype)
>> > > > > > > +static int decode_pnfs_layout_types(struct xdr_stream *xdr, u32 *layouttypes)
>> > > > > > > {
>> > > > > > > __be32 *p;
>> > > > > > > int num;
>> > > > > > > +	u32 type;
>> > > > > > >  
>> > > > > > > p = xdr_inline_decode(xdr, 4);
>> > > > > > > if (unlikely(!p))
>> > > > > > > goto out_overflow;
>> > > > > > > num = be32_to_cpup(p);
>> > > > > > >  
>> > > > > > > -	/* pNFS is not supported by the underlying file system */
>> > > > > > > -	if (num == 0) {
>> > > > > > > -	 *layouttype = 0;
>> > > > > > > -	 return 0;
>> > > > > > > -	}
>> > > > > > > -	if (num > 1)
>> > > > > > > -	 printk(KERN_INFO "NFS: %s: Warning: Multiple pNFS layout "
>> > > > > > > -	 "drivers per filesystem not supported\n", __func__);
>> > > > > > > +	*layouttypes = 0;
>> > > > > > >  
>> > > > > > > -	/* Decode and set first layout type, move xdr->p past unused types */
>> > > > > > > -	p = xdr_inline_decode(xdr, num * 4);
>> > > > > > > -	if (unlikely(!p))
>> > > > > > > -	 goto out_overflow;
>> > > > > > > -	*layouttype = be32_to_cpup(p);
>> > > > > > > +	for (; num; --num) {
>> > > > > > > +	 p = xdr_inline_decode(xdr, 4);
>> > > > > > > +
>> > > > > > > +	 if (unlikely(!p))
>> > > > > > > +	 goto out_overflow;
>> > > > > > > +
>> > > > > > > +	 type = be32_to_cpup(p);
>> > > > > > > +
>> > > > > > > +	 /* Ignore any that we don't understand */
>> > > > > > > +	 if (unlikely(type >= LAYOUT_TYPE_MAX))
>> > > > > >  
>> > > > > > This will in effect hard code the layouts that the client supports.
>> > > > > > LAYOUT_TYPE_MAX is something that applies to knfsd only for now.
>> > > > > > Let’s not leak it into the client. I suggest just making this
>> > > > > > 8*sizeof(*layouttypes).
>> > > > > >  
>> > > > > 
>> > > > > Fair enough. I'll make that change.
>> > > > > 
>> > > > > That said...LAYOUT_TYPE_MAX is a value in the pnfs_layouttype enum, and
>> > > > > that enum is used in both the client and the server code, AFAICT. If we
>> > > > > add a new LAYOUT_* value to that enum for the client, then we'll need
>> > > > > to increase that value anyway. So, I'm not sure I understand how this
>> > > > > limits the client in any way...
>> > > > 
>> > > > No, the client doesn’t use enum pnfs_layouttype anywhere. If you look
>> > > > at set_pnfs_layoutdriver(), you’ll note that we currently support all
>> > > > values for the layout type.
>> > > > 
>> > > 
>> > > Ok, I see. So if someone were to (for instance) create a 3rd party
>> > > layout driver module that had used a value above LAYOUT_TYPE_MAX then
>> > > this would prevent it from working.
>> > > 
>> > > Hmmm...so even if I make the change that you're suggesting, this will
>> > > still limit the client to working with layout types that are below a
>> > > value of 32. Is that also a problem? If so, then maybe I should respin
>> > > this to be more like the one Tigran had: make an array or something to
>> > > hold those values.
>> > > 
>> > > Thoughts?
>> > > 
>> > 
>> > Yecchhhhh...ok after thinking about this, the whole out-of-tree layout
>> > driver possibility really throws a wrench into this plan...
>> > 
>> > Suppose someone creates such a layout driver, drops the module onto the
>> > client and the core kernel knows nothing about it.  With the current
>> > patch, it'd be ignored. I don't think that's what we want though.
>> > 
>> > Where should that driver fit in the selection order in
>> > set_pnfs_layoutdriver?
>> > 
>> > Tigran's patch had the client start with the second element and only
>> > pick the first one in the list if nothing else worked. That's sort of
>> > icky though.
>> > 
>> > Another idea might be to just attempt unrecognized ones as the driver
>> > of last resort, when no other driver has worked?
>> > 
>> > Alternately, we could add a mount option or something that would affect
>> > the selection order? If so, how should such an option work?
>> > 
>> > I'm really open to suggestions here -- I've no idea what the right
>> > thing to do is at this point...sigh.
>> 
>> 
>> There are two things in my patch what I don't like:
>> 
>>   - an int array to store layouts, which mostly will be used by a single element
>>   only
>>   - server must know client implementation to achieve desired result
>> 
> 
> Meh, the array is not too big a deal. We only allocate a fsinfo struct
> to handle the call. Once we've selected the layout type, it gets
> discarded. The second problem is the bigger one, IMO.
> 
>> In your approach other two problems:
>> 
>>   - max layout type id 32
>>   - hard coded supported layout types and the order
>> 
> 
> Right, both are problems. For now, I'm not too worried about getting
> _official_ layout type values that are above 32, but the spec says:
> 
>   Types within the range 0x00000001-0x7FFFFFFF are
>   globally unique and are assigned according to the description in
>   Section 22.4; they are maintained by IANA.  Types within the range
>   0x80000000-0xFFFFFFFF are site specific and for private use only.
> 
> So both of the above problems in my RFC patch make it difficult to
> experiment with new layout types.
> 
>> Any of them will help in adoption of flexfile layout, especially if we get it
>> into
>> RHEL7.
>> 
>> In discussion with Christoph Hellwig back in March, I have proposed a mount
>> option:
>> 
>>    mount -o preferred_layout=nfs4_file,vers=4.1
>> 
>> or may be even an nfs kernel module option.
>> 
> 
>> This will allow server to send layout in any order, but let client to re-order
>> them by it's own rules.
>> 
> 
> Yeah, I was thinking something along the same lines.
> 
> The problem with a mount option is that you can transit to different
> filesystems in multiple ways with NFS these days (referrals, etc...).
> Propagating and handling mount options in those cases can quickly
> become quite messy.
> 
> A module option to set the selection order might be best. For instance:
> 
>    nfs4.pnfs_layout_order=0x80000006:scsi:block:object:flexfile:file

Hi Jeff,

after some mental exercises around this topic, I came to a conclusion, that
module option is a wrong approach. The module configuration is a global
setting for kernel nfs client. Imagine a situation in which you want to use
flexfiles with one server and nfs4_files with another server, but both
support both layout types.

Looks like there is no way around mount option.

Tigran.


> 
> Then the client could pick the best one based on that order. The
> default could be the order that I set up in the proposed patch (or
> something else, fwiw).
> 
> Either way, I'd like Trond and/or Anna to weigh in on what they'd find
> acceptable before we go down either of those roads.
> 
> --
> Jeff Layton <jlayton@poochiereds.net>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
