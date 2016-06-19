Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35517 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386AbcFSJsy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Jun 2016 05:48:54 -0400
Subject: Re: [PATCH v2 01/24] mlx4-ib: Use coherent memory for priv pages
To: Chuck Lever <chuck.lever@oracle.com>
References: <20160615030626.14794.43805.stgit@manet.1015granger.net>
 <20160615031525.14794.69066.stgit@manet.1015granger.net>
 <20160615042849.GR5408@leon.nu>
 <68F7CD80-0092-4B55-9FAD-4C54D284BCA3@oracle.com>
 <20160616143518.GX5408@leon.nu> <576315C9.30002@gmail.com>
 <652EBA09-2978-414C-8606-38A96C63365A@oracle.com>
Cc: leon@kernel.org, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Sagi Grimberg <sagigrim@gmail.com>
Message-ID: <57666A83.8050502@gmail.com>
Date: Sun, 19 Jun 2016 12:48:51 +0300
MIME-Version: 1.0
In-Reply-To: <652EBA09-2978-414C-8606-38A96C63365A@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>> First of all, IIRC the patch author was Christoph wasn't he.
>>
>> Plus, you do realize that this patch makes the pages allocation
>> in granularity of pages. In systems with a large page size this
>> is completely redundant, it might even be harmful as the storage
>> ULPs need lots of MRs.
>
> I agree that the official fix should take a conservative
> approach to allocating this resource; there will be lots
> of MRs in an active system. This fix doesn't seem too
> careful.
>
>
>> Also, I don't see how that solves the issue, I'm not sure I even
>> understand the issue. Do you? Were you able to reproduce it?
>
> The issue is that dma_map_single() does not seem to DMA map
> portions of a memory region that are past the end of the first
> page of that region. Maybe that's a bug?

That seems weird to me, from looking at the code I didn't see
any indication that such a mapping would fail. Maybe we are seeing
a mlx4 specific issue? If this is some kind of generic dma-mapping
bug mlx5 would suffer from the same problem right? does it?

> This patch works around that behavior by guaranteeing that
>
> a) the memory region starts at the beginning of a page, and
> b) the memory region is never larger than a page
>
> This patch is not sufficient to repair mlx5, because b)
> cannot be satisfied in that case; the array of __be64's can
> be larger than 512 entries.

If a single page boundary is indeed the root-cause then I agree
this would not solve the problem for mlx5.

>> IFF the pages buffer end not being aligned to a cacheline is problematic
>> then why not extent it to end in a cacheline? Why in the next full page?
>
> I think the patch description justifies the choice of
> solution, but does not describe the original issue at
> all. The original issue had nothing to do with cacheline
> alignment.
>
> Lastly, this patch should remove the definition of
> MLX4_MR_PAGES_ALIGN.

The mlx4 PRM explicitly states that the translation (pages) vector
should align to 64 bytes and this is where this define comes from,
hence I don't think it should be removed from the code.
