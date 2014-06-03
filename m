Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f172.google.com ([209.85.213.172]:37392 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752117AbaFCEVv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jun 2014 00:21:51 -0400
Received: by mail-ig0-f172.google.com with SMTP id uy17so4235824igb.5
        for <linux-nfs@vger.kernel.org>; Mon, 02 Jun 2014 21:21:51 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [nfs:devel 41/48] nls_iso8859-1.c:undefined reference to `__aeabi_uldivmod'
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <1401375457.6543.1.camel@leira.trondhjem.org>
Date: Tue, 3 Jun 2014 00:21:48 -0400
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <EB4DE0E3-2D28-4063-9475-C1C913142572@primarydata.com>
References: <538745be.7mlU/ffncT1nxA17%fengguang.wu@intel.com> <1401375457.6543.1.camel@leira.trondhjem.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks great, thanks for taking care of that while I was on vacation!

-dros

On May 29, 2014, at 10:57 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Thu, 2014-05-29 at 22:35 +0800, kbuild test robot wrote:
>> tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git devel
>> head:   c75c3b0bfffdb21daecb7dadbd30eb2e353fe66d
>> commit: fa1165eda0eeaee57c292df3af1c98e10223f0f5 [41/48] pnfs: filelayout: support non page aligned layouts
>> config: make ARCH=arm kzm9g_defconfig
>> 
>> All error/warnings:
>> 
>>   fs/built-in.o: In function `filelayout_pg_test':
>>>> nls_iso8859-1.c:(.text+0x9cf3c): undefined reference to `__aeabi_uldivmod'
>> 
>> ---
>> 0-DAY kernel build testing backend              Open Source Technology Center
>> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation
> 
> Hi Dros,
> 
> I'm applying the following patch to fix this up:
> 
> From 64060d5dd6bf8d6d611c342f9a42a2ad7640ed4a Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Thu, 29 May 2014 10:49:12 -0400
> Subject: [PATCH] fixup! pnfs: filelayout: support non page aligned layouts
> 
> ---
> fs/nfs/nfs4filelayout.c | 4 +++-
> 1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 9419061b6d1b..63a16375660a 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -950,7 +950,9 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
> 	}
> 
> 	/* calculate remaining bytes in the current stripe */
> -	stripe_offset = ((u64)req_offset(req) - segment_offset) % stripe_unit;
> +	div_u64_rem((u64)req_offset(req) - segment_offset,
> +			stripe_unit,
> +			&stripe_offset);
> 	WARN_ON_ONCE(stripe_offset > stripe_unit);
> 	if (stripe_offset >= stripe_unit)
> 		return 0;
> -- 
> 1.9.3
> 
> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
> 
> 

