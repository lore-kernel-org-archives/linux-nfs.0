Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:31516 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524AbcFQT4H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jun 2016 15:56:07 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2 01/24] mlx4-ib: Use coherent memory for priv pages
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160617092018.GZ5408@leon.nu>
Date: Fri, 17 Jun 2016 15:55:56 -0400
Cc: Sagi Grimberg <sagigrim@gmail.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <4D23496A-FE01-4693-B125-82CD03B8F2D4@oracle.com>
References: <20160615030626.14794.43805.stgit@manet.1015granger.net> <20160615031525.14794.69066.stgit@manet.1015granger.net> <20160615042849.GR5408@leon.nu> <68F7CD80-0092-4B55-9FAD-4C54D284BCA3@oracle.com> <20160616143518.GX5408@leon.nu> <576315C9.30002@gmail.com> <652EBA09-2978-414C-8606-38A96C63365A@oracle.com> <20160617092018.GZ5408@leon.nu>
To: leon@kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 17, 2016, at 5:20 AM, Leon Romanovsky <leon@kernel.org> wrote:
> 
> On Thu, Jun 16, 2016 at 05:58:29PM -0400, Chuck Lever wrote:
>> 
>>> On Jun 16, 2016, at 5:10 PM, Sagi Grimberg <sagigrim@gmail.com> wrote:
>> 
>>> First of all, IIRC the patch author was Christoph wasn't he.
>>> 
>>> Plus, you do realize that this patch makes the pages allocation
>>> in granularity of pages. In systems with a large page size this
>>> is completely redundant, it might even be harmful as the storage
>>> ULPs need lots of MRs.
>> 
>> I agree that the official fix should take a conservative
>> approach to allocating this resource; there will be lots
>> of MRs in an active system. This fix doesn't seem too
>> careful.
> 
> In mlx5 system, we always added 2048 bytes to such allocations, for
> reasons unknown to me. And it doesn't seem as a conservative approach
> either.

The mlx5 approach is much better than allocating a whole
page, when you consider platforms with 64KB pages.

A 1MB payload (for NFS) on such a platform comprises just
16 pages. So xprtrdma will allocate MRs with support for
16 pages. That's a priv pages array of 128 bytes, and you
just put it in a 64KB page all by itself.

So maybe adding 2048 bytes is not optimal either. But I
think sticking with kmalloc here is a more optimal choice.


>>> Also, I don't see how that solves the issue, I'm not sure I even
>>> understand the issue. Do you? Were you able to reproduce it?
>> 
>> The issue is that dma_map_single() does not seem to DMA map
>> portions of a memory region that are past the end of the first
>> page of that region. Maybe that's a bug?
> 
> No, I didn't find support for that. Function dma_map_single expects
> contiguous memory aligned to cache line, there is no limitation to be
> page bounded.

There certainly isn't, but that doesn't mean there can't
be a bug somewhere ;-) and maybe not in dma_map_single.
It could be that the "array on one page only" limitation
is somewhere else in the mlx4 driver, or even in the HCA
firmware.


>> This patch works around that behavior by guaranteeing that
>> 
>> a) the memory region starts at the beginning of a page, and
>> b) the memory region is never larger than a page
> 
> b) the memory region ends on cache line.

I think we demonstrated pretty clearly that the issue
occurs only when the end of the priv pages array crosses
into a new page.

We didn't see any problem otherwise.


>> This patch is not sufficient to repair mlx5, because b)
>> cannot be satisfied in that case; the array of __be64's can
>> be larger than 512 entries.
>> 
>> 
>>> IFF the pages buffer end not being aligned to a cacheline is problematic
>>> then why not extent it to end in a cacheline? Why in the next full page?
>> 
>> I think the patch description justifies the choice of
>> solution, but does not describe the original issue at
>> all. The original issue had nothing to do with cacheline
>> alignment.
> 
> I disagree, kmalloc with supplied flags will return contiguous memory
> which is enough for dma_map_single. It is cache line alignment.

The reason I find this hard to believe is that there is
no end alignment guarantee at all in this code, but it
works without issue when SLUB debugging is not enabled.

xprtrdma allocates 256 elements in this array on x86.
The code makes the array start on an 0x40 byte boundary.
I'm pretty sure that means the end of that array will
also be on at least an 0x40 byte boundary, and thus
aligned to the DMA cacheline, whether or not SLUB
debugging is enabled.

Notice that in the current code, if the consumer requests
an odd number of SGs, that array can't possibly end on
an alignment boundary. But we've never had a complaint.

SLUB debugging changes the alignment of lots of things,
but mlx4_alloc_priv_pages is the only breakage that has
been reported.

DMA-API.txt says:

> [T]he mapped region must begin exactly on a cache line
> boundary and end exactly on one (to prevent two separately
> mapped regions from sharing a single cache line)

The way I read this, cacheline alignment shouldn't be
an issue at all, as long as DMA cachelines aren't
shared between mappings.

If I simply increase the memory allocation size a little
and ensure the end of the mapping is aligned, that should
be enough to prevent DMA cacheline sharing with another
memory allocation on the same page. But I still see Local
Protection Errors when SLUB debugging is enabled, on my
system (with patches to allocate more pages per MR).

I'm not convinced this has anything to do with DMA
cacheline alignment. The reason your patch fixes this
issue is because it keeps the entire array on one page.


--
Chuck Lever



