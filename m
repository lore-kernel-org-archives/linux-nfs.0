Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34446 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540AbcFSHF1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Jun 2016 03:05:27 -0400
Subject: Re: [PATCH v2 01/24] mlx4-ib: Use coherent memory for priv pages
To: leon@kernel.org
References: <20160615030626.14794.43805.stgit@manet.1015granger.net>
 <20160615031525.14794.69066.stgit@manet.1015granger.net>
 <20160615042849.GR5408@leon.nu>
 <68F7CD80-0092-4B55-9FAD-4C54D284BCA3@oracle.com>
 <20160616143518.GX5408@leon.nu> <576315C9.30002@gmail.com>
 <20160617090541.GY5408@leon.nu>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <57664433.8060206@grimberg.me>
Date: Sun, 19 Jun 2016 10:05:23 +0300
MIME-Version: 1.0
In-Reply-To: <20160617090541.GY5408@leon.nu>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>> First of all, IIRC the patch author was Christoph wasn't he.
>
> Do you think that author's name can provide different results in
> verification/bug reproduction? We didn't send this patch officially
> yet and all relevant authors will be acknowledged and honored when the
> official (second round of IB fixes) will come.

Not sure what you mean here. what different results?

>> Plus, you do realize that this patch makes the pages allocation
>> in granularity of pages. In systems with a large page size this
>> is completely redundant, it might even be harmful as the storage
>> ULPs need lots of MRs.
>
> I see proper execution of the driver as an important goal which goes
> before various micro optimizations, which will come after.

I still don't understand how this fixes the original bug report from
Chuck. I sent a patch to make the pages allocation dma coherent
which fixes the issue. Yishai is the driver maintainer, he should
decide how this issue should be addressed.

In any event, if we end-up aligning to page size I would expect to
see a FIXME comment saying we can do better...

> id you ask yourself, why are not so many users use that ARCH_KMALLOC_MINALIGN?
>
> ➜  linux-rdma git:(master) grep -rI ARCH_KMALLOC_MINALIGN drivers/*
> drivers/infiniband/hw/mlx4/mr.c:        add_size = max_t(int, MLX4_MR_PAGES_ALIGN - ARCH_KMALLOC_MINALIGN, 0);
> drivers/infiniband/hw/mlx5/mr.c:        add_size = max_t(int, MLX5_UMR_ALIGN - ARCH_KMALLOC_MINALIGN, 0);
> drivers/md/dm-crypt.c:                ARCH_KMALLOC_MINALIGN);
> drivers/usb/core/buffer.c:       * ARCH_KMALLOC_MINALIGN.
> drivers/usb/core/buffer.c:      if (ARCH_KMALLOC_MINALIGN <= 32)
> drivers/usb/core/buffer.c:      else if (ARCH_KMALLOC_MINALIGN <= 64)
> drivers/usb/core/buffer.c:      else if (ARCH_KMALLOC_MINALIGN <= 128)
> drivers/usb/misc/usbtest.c:     return (unsigned long)buf & (ARCH_KMALLOC_MINALIGN - 1);
>

Not sure how to answer that, the use of it comes to make the allocation
padding just as much as we need it to be in order to align the pointer.

>>
>> Also, I don't see how that solves the issue, I'm not sure I even
>> understand the issue. Do you? Were you able to reproduce it?
>
> Yes, the issue is that address supplied to dma_map_single wasn't aligned
> to DMA cacheline size.

Thats not true Leon, the address is always aligned to
MLX4_MR_PAGES_ALIGN which is 64B.

>
> And as the one, who wrote this code for mlx5, it will be great if you
> can give me a pointer. Why did you chose to use MLX5_UMR_ALIGN in that
> function? This will add 2048 bytes instead of 64 for mlx4.

The PRM states that the data descriptors array (MTT/KLM) pointer
must be aligned to 2K. I wish it didn't but it does. You can see in the
code that each registration that goes via UMR does the exact same thing.

>> IFF the pages buffer end not being aligned to a cacheline is problematic
>> then why not extent it to end in a cacheline? Why in the next full page?
>
> It will fit in one page.

Yea, but that single page can be 64K for a 128 pointers array...
