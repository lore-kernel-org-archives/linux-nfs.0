Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37454 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754032AbcA0R1t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jan 2016 12:27:49 -0500
Received: by mail-wm0-f53.google.com with SMTP id n5so37447913wmn.0
        for <linux-nfs@vger.kernel.org>; Wed, 27 Jan 2016 09:27:49 -0800 (PST)
Subject: Re: [LSF/MM TOPIC/ATTEND] RDMA passive target
To: Boaz Harrosh <boaz@plexistor.com>, Chuck Lever <chuck.lever@oracle.com>,
        lsf-pc@lists.linux-foundation.org,
        Dan Williams <dan.j.williams@intel.com>,
        Yigal Korman <yigal@plexistor.com>
References: <06414D5A-0632-4C74-B76C-038093E8AED3@oracle.com>
 <56A8F646.5020003@plexistor.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>,
        Ric Wheeler <rwheeler@redhat.com>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <56A8FE10.7000309@dev.mellanox.co.il>
Date: Wed, 27 Jan 2016 19:27:44 +0200
MIME-Version: 1.0
In-Reply-To: <56A8F646.5020003@plexistor.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Boaz,

> RDMA passive target
> ~~~~~~~~~~~~~~~~~~~
>
> The idea is to have a storage brick that exports a very
> low level pure RDMA API to access its memory based storage.
> The brick might be battery backed volatile based memory, or
> pmem based. In any case the brick might utilize a much higher
> capacity then memory by utilizing a "tiering" to slower media,
> which is enabled by the API.
>
> The API is simple:
>
> 1. Alloc_2M_block_at_virtual_address (ADDR_64_BIT)
>     ADDR_64_BIT is any virtual address and defines the logical ID of the block.
>     If the ID is already allocated an error is returned.
>     If storage is exhausted return => ENOSPC
> 2. Free_2M_block_at_virtual_address (ADDR_64_BIT)
>     Space for logical ID is returned to free store and the ID becomes free for
>     a new allocation.
> 3. map_virtual_address(ADDR_64_BIT, flags) => RDMA handle
>     previously allocated virtual address is locked in memory and an RDMA handle
>     is returned.
>     Flags: read-only, read-write, shared and so on...
> 4. unmap__virtual_address(ADDR_64_BIT)
>     At this point the brick can write data to slower storage if memory space
>     is needed. The RDMA handle from [3] is revoked.
> 5. List_mapped_IDs
>     An extent based list of all allocated ranges. (This is usually used on
>     mount or after a crash)

My understanding is that you're describing a wire protocol correct?

> The dumb brick is not the Network allocator / storage manager at all. and it
> is not a smart target / server. like an iser-target or pnfs-DS. A SW defined
> application can do that, on top of the Dumb-brick. The motivation is a low level
> very low latency API+library, which can be built upon for higher protocols or
> used directly for very low latency cluster.
> It does however mange a virtual allocation map of logical to physical mapping
> of the 2M blocks.

The challenge in my mind would be to have persistence semantics in
place.

>
> Currently both drivers initiator and target are in Kernel, but with
> latest advancement by Dan Williams it can be implemented in user-mode as well,
> Almost.
>
> The almost is because:
> 1. If the target is over a /dev/pmemX then all is fine we have 2M contiguous
>     memory blocks.
> 2. If the target is over an FS, we have a proposal pending for an falloc_2M_flag
>     to ask the FS for a contiguous 2M allocations only. If any of the 2M allocations
>     fail then return ENOSPC from falloc. This way we guaranty that each 2M block can be
>     mapped by a single RDAM handle.

Umm, you don't need the 2M to be contiguous in order to represent them
as a single RDMA handle. If that was true iSER would have never worked.
Or I misunderstood what you meant...
