Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37233 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932263AbcA0Qye (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jan 2016 11:54:34 -0500
Received: by mail-wm0-f51.google.com with SMTP id n5so35974288wmn.0
        for <linux-nfs@vger.kernel.org>; Wed, 27 Jan 2016 08:54:34 -0800 (PST)
Message-ID: <56A8F646.5020003@plexistor.com>
Date: Wed, 27 Jan 2016 18:54:30 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, lsf-pc@lists.linux-foundation.org,
        Dan Williams <dan.j.williams@intel.com>,
        Yigal Korman <yigal@plexistor.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>,
        Ric Wheeler <rwheeler@redhat.com>
Subject: [LSF/MM TOPIC/ATTEND] RDMA passive target
References: <06414D5A-0632-4C74-B76C-038093E8AED3@oracle.com>
In-Reply-To: <06414D5A-0632-4C74-B76C-038093E8AED3@oracle.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/25/2016 11:19 PM, Chuck Lever wrote:
> I'd like to propose a discussion of how to take advantage of
> persistent memory in network-attached storage scenarios.
> 
> RDMA runs on high speed network fabrics and offloads data
> transfer from host CPUs. Thus it is a good match to the
> performance characteristics of persistent memory.
> 
> Today Linux supports iSER, SRP, and NFS/RDMA on RDMA
> fabrics. What kind of changes are needed in the Linux I/O
> stack (in particular, storage targets) and in these storage
> protocols to get the most benefit from ultra-low latency
> storage?
> 
> There have been recent proposals about how storage protocols
> and implementations might need to change (eg. Tom Talpey's
> SNIA proposals for changing to a push data transfer model,
> Sagi's proposal to utilize DAX under the NFS/RDMA server,
> and my proposal for a new pNFS layout to drive RDMA data
> transfer directly).
> 
> The outcome of the discussion would be to understand what
> people are working on now and what is the desired
> architectural approach in order to determine where storage
> developers should be focused.
> 
> This could be either a BoF or a session during the main
> tracks. There is sure to be a narrow segment of each
> track's attendees that would have interest in this topic.
> 

I would like to attend this talk, and also talk about
a target we have been developing / utilizing that we would like
to propose as a Linux standard driver.
(It would be very important for me to also attend the other
 pmem talks in LSF, as well as some of the MM and FS talks
 proposed so far)

RDMA passive target
~~~~~~~~~~~~~~~~~~~

The idea is to have a storage brick that exports a very
low level pure RDMA API to access its memory based storage.
The brick might be battery backed volatile based memory, or
pmem based. In any case the brick might utilize a much higher
capacity then memory by utilizing a "tiering" to slower media,
which is enabled by the API.

The API is simple:

1. Alloc_2M_block_at_virtual_address (ADDR_64_BIT)
   ADDR_64_BIT is any virtual address and defines the logical ID of the block.
   If the ID is already allocated an error is returned.
   If storage is exhausted return => ENOSPC
2. Free_2M_block_at_virtual_address (ADDR_64_BIT)
   Space for logical ID is returned to free store and the ID becomes free for
   a new allocation.
3. map_virtual_address(ADDR_64_BIT, flags) => RDMA handle
   previously allocated virtual address is locked in memory and an RDMA handle
   is returned.
   Flags: read-only, read-write, shared and so on...
4. unmap__virtual_address(ADDR_64_BIT)
   At this point the brick can write data to slower storage if memory space
   is needed. The RDMA handle from [3] is revoked.
5. List_mapped_IDs
   An extent based list of all allocated ranges. (This is usually used on
   mount or after a crash)

The dumb brick is not the Network allocator / storage manager at all. and it
is not a smart target / server. like an iser-target or pnfs-DS. A SW defined
application can do that, on top of the Dumb-brick. The motivation is a low level
very low latency API+library, which can be built upon for higher protocols or
used directly for very low latency cluster.
It does however mange a virtual allocation map of logical to physical mapping
of the 2M blocks.

Currently both drivers initiator and target are in Kernel, but with
latest advancement by Dan Williams it can be implemented in user-mode as well,
Almost.

The almost is because:
1. If the target is over a /dev/pmemX then all is fine we have 2M contiguous
   memory blocks.
2. If the target is over an FS, we have a proposal pending for an falloc_2M_flag
   to ask the FS for a contiguous 2M allocations only. If any of the 2M allocations
   fail then return ENOSPC from falloc. This way we guaranty that each 2M block can be
   mapped by a single RDAM handle.
   An FS for this purpose is nice for an over-allocated / dynamic space usage by
   a target and other resources in the server.


RDMA Initiator
~~~~~~~~~~~~~~~~~~~

The initiator is just a simple library. Both usermode and Kernel side should
be available, for direct access to the RDMA-passive-brick.

Thanks.
Boaz

> --
> Chuck Lever
> 

