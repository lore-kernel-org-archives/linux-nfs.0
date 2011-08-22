Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:46183 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753812Ab1HVXwZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Aug 2011 19:52:25 -0400
Message-ID: <4E52EBAC.8070908@panasas.com>
Date: Mon, 22 Aug 2011 16:52:12 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Peng Tao <bergwolf@gmail.com>
CC: Benny Halevy <bhalevy@tonian.com>, <linux-nfs@vger.kernel.org>,
        Peng Tao <peng_tao@emc.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH] pnfsblock: init pg_bsize properly
References: <1313197450-4595-1-git-send-email-bergwolf@gmail.com> <4E4ADBA1.1000005@panasas.com> <4E4B6A81.2010204@tonian.com> <CA+a=Yy6BSmEWurZuFN-8axTS0gfeXaguw5tcayeVjJmcFAztOQ@mail.gmail.com>
In-Reply-To: <CA+a=Yy6BSmEWurZuFN-8axTS0gfeXaguw5tcayeVjJmcFAztOQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/17/2011 02:35 AM, Peng Tao wrote:
> Hi, Benny and Boaz,
> 
<snip>

> In pnfs_do_multiple_reads/pnfs_do_multiple_writes, data->mds_ops will
> be set as desc->pg_rpc_callops, which is determined in
> nfs_generic_flush/nfs_generic_pagein according to desc->pg_bsize. For
> blocklayout, we wouldn't want to set data->mds_ops to
> partial_read/write ops, so I write the patch to use lseg length as
> pg_bsize.
> 

Do you mean in the case where MDS sets (pg_bsize < PAGE_SIZE) ?

Right, that is a problem. (Theoretically, because the pNFSD-Linux server
does not do that. Do you have a Server that does?)

> LD can override pg_bsize in pg_init because
> nfs_pageio_reset_read_mds/nfs_pageio_reset_write_mds will reset it to
> server rsize/wsize if pnfs is not tried.
> 

So if it is the "pg_bsize < PAGE_SIZE" but pNFS-IO case then I don't
like your patch, at all. We should fix the generic code to behave
properly, and not let LDs hack their way out. (For example what about
objects and files LDs)

There is a few ways you can fix the generic code. One is override the
desc->pg_rpc_callops for the pNFS case to always be the same one. Or
override the test for (pg_bsize < PAGE_SIZE) in the pNFS case if we have
a lseg. Or some other clean way.

But please don't fix it like that, inside each LD driver.

[ Trond Fred
  One thing I do not understand about the files-layout operations. You
  have explained in the passed that r/wsize sent from the MDS is also the
  same one for each DS. So if we take an example of rsize beeing 2MB
  and there is a stripping of 2 DS for that layout.(Say strip_unit==rsize)
  Then we need to read 1/2 of that page from one DS and the 2/2 half from the
  second. Will current partial_read/write work if going through files-LD?
]

Thanks
Boaz
