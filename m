Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:37417 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756943Ab2CLTwl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2012 15:52:41 -0400
Message-ID: <4F5E5400.3000800@panasas.com>
Date: Mon, 12 Mar 2012 12:52:32 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: Bug in the pNFS OSD layout driver
References: <1331487447.2496.10.camel@lade.trondhjem.org>
In-Reply-To: <1331487447.2496.10.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/11/2012 10:37 AM, Myklebust, Trond wrote:
> Hi Boaz,
> 
> When I run 'sparse' on the object layout driver, I get the following
> errors:
> 
> fs/nfs/objlayout/objio_osd.c:210:37: error: bad constant expression
> fs/nfs/objlayout/objio_osd.c:211:39: error: bad constant expression
> fs/nfs/objlayout/objio_osd.c:315:59: error: bad constant expression
> 

Then sparse is broken

> which boils down to the following section of code:
> 
> int __alloc_objio_seg(unsigned numdevs, gfp_t gfp_flags,
>                        struct objio_segment **pseg)
> {
>         struct __alloc_objio_segment {
>                 struct objio_segment olseg;
>                 struct ore_dev *ods[numdevs];
> 		^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>                 struct ore_comp comps[numdevs];
> 		^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>         } *aolseg;
> 
>         aolseg = kzalloc(sizeof(*aolseg), gfp_flags);
> 
> 
> Dynamically allocated arrays such as the above are a GNU C compiler
> feature that we cannot use in kernel code. If the above array sizes need
> to be dynamically determined, then please use the kcalloc() interface to
> allocate them.

I am using kzalloc to do a single allocation. The *ods[numdevs] is only
used for the sizeof() expression it does not allocate anything actually.

We use gcc extensions all over the place. From the simple __func__ to
the famous typeof().

I don't understand why you decide to pick on this one in particular.

> I.e. something like
> 
>         struct __alloc_objio_segment {
>                 struct objio_segment olseg;
>                 struct ore_dev **ods;
>                 struct ore_comp *comps;
> 		^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>         } *aolseg;
> 
>         aolseg = kzalloc(sizeof(*aolseg), gfp_flags);
> 	if (aolseg) {
> 		aolseg->ods = kcalloc(numdevs, sizeof(struct ore_dev *), gfp_flags);
> 		aolseg->ore_comp = kcalloc(numdevs, sizeof(struct ore_comp), gfp_flags);

This is not the same code. It is three allocations instead of one. And it is an
extra pointer reference instead of just pointer offsetting.

If it would change it would change to:

         aolseg = kzalloc(sizeof(*aolseg) + 
		          numdevs * sizeof(struct ore_dev *),
			  numdevs * sizeof(struct ore_comp), 
			  gfp_flags);

And all the pointer arithmetic that follow. But why the very ugly code
when there is an elegant, type-safe, and self documenting way. It's
beautifully clear this way what is the in memory structure of the
allocation.

> 		if (!aolseg->ods || !aolseg->ore_comp)
> 			.... clean up and report error...
> 	}
> 

Again, we use gcc extensions all over the place. Why not this one?
BTW variable arrays is also supported by M$-vcc.

> Cheers
>   Trond

Thanks
Boaz
