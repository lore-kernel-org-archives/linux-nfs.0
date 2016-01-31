Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:34625 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757497AbcAaOUP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Jan 2016 09:20:15 -0500
Received: by mail-wm0-f47.google.com with SMTP id 128so38186183wmz.1
        for <linux-nfs@vger.kernel.org>; Sun, 31 Jan 2016 06:20:14 -0800 (PST)
Message-ID: <56AE181A.8030908@plexistor.com>
Date: Sun, 31 Jan 2016 16:20:10 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
To: Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Chuck Lever <chuck.lever@oracle.com>,
        lsf-pc@lists.linux-foundation.org,
        Dan Williams <dan.j.williams@intel.com>,
        Yigal Korman <yigal@plexistor.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>,
        Ric Wheeler <rwheeler@redhat.com>
Subject: Re: [LSF/MM TOPIC/ATTEND] RDMA passive target
References: <06414D5A-0632-4C74-B76C-038093E8AED3@oracle.com> <56A8F646.5020003@plexistor.com> <56A8FE10.7000309@dev.mellanox.co.il>
In-Reply-To: <56A8FE10.7000309@dev.mellanox.co.il>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/27/2016 07:27 PM, Sagi Grimberg wrote:
> Hey Boaz,
> 
>> RDMA passive target
>> ~~~~~~~~~~~~~~~~~~~
>>
>> The idea is to have a storage brick that exports a very
>> low level pure RDMA API to access its memory based storage.
>> The brick might be battery backed volatile based memory, or
>> pmem based. In any case the brick might utilize a much higher
>> capacity then memory by utilizing a "tiering" to slower media,
>> which is enabled by the API.
>>
>> The API is simple:
>>
>> 1. Alloc_2M_block_at_virtual_address (ADDR_64_BIT)
>>     ADDR_64_BIT is any virtual address and defines the logical ID of the block.
>>     If the ID is already allocated an error is returned.
>>     If storage is exhausted return => ENOSPC
>> 2. Free_2M_block_at_virtual_address (ADDR_64_BIT)
>>     Space for logical ID is returned to free store and the ID becomes free for
>>     a new allocation.
>> 3. map_virtual_address(ADDR_64_BIT, flags) => RDMA handle
>>     previously allocated virtual address is locked in memory and an RDMA handle
>>     is returned.
>>     Flags: read-only, read-write, shared and so on...
>> 4. unmap__virtual_address(ADDR_64_BIT)
>>     At this point the brick can write data to slower storage if memory space
>>     is needed. The RDMA handle from [3] is revoked.
>> 5. List_mapped_IDs
>>     An extent based list of all allocated ranges. (This is usually used on
>>     mount or after a crash)
> 
> My understanding is that you're describing a wire protocol correct?
> 

Almost. Not yet a wire protocol, Just an high level functionality description.
first. But yes a wire protocol in the sense that I want an open source library
that will be good for Kernel and Usermode. Any none Linux platform should be
able to port the code base and use it.
That said at some early point we should lock the wire protocol for inter version
compatibility or at least have a fixture negotiation when things get evolved.

>> The dumb brick is not the Network allocator / storage manager at all. and it
>> is not a smart target / server. like an iser-target or pnfs-DS. A SW defined
>> application can do that, on top of the Dumb-brick. The motivation is a low level
>> very low latency API+library, which can be built upon for higher protocols or
>> used directly for very low latency cluster.
>> It does however mange a virtual allocation map of logical to physical mapping
>> of the 2M blocks.
> 
> The challenge in my mind would be to have persistence semantics in
> place.
> 

Ok Thanks for bringing this up.

So there is two separate issues here. Which are actually not related to the
above API. It is more an Initiator issue. Since once the server did the above
map_virtual_address() and return a key to client machine it is out of the way.

On the initiator what we do is: All RDMA async sends. Once the user did an fsync
we do a sync-read(0, 1); so to guaranty both initiator and Server's nicks flush all
write buffers, to Server's PCIE controller.

But here lays the problem: In modern servers the PCIE/memory_controller chooses
to write fast PCIE data (or actually any PCI data) directly to L3 cache on the
principal that receiving application will access that memory very soon.
This is what is called DDIO.
Now here there is big uncertainty. and we are still investigating. The only working
ADR machine we have with an old NvDIMM-type-12 legacy BIOS. (All the newer type-6
none NFIT BIOS systems never worked and had various problems with persistence)
So that only working system, though advertised as DDIO machine does not exhibit
the above problem.
	On a test of RDMA-SEND x X; RDMA-READ(0,1); POWER-OFF;
We always are fine and never get a compare error between the machines.
[I guess it depends on the specific system and the depth of the ADR flushing
 on power-off, there are 15 milliseconds of power to work with]

But the Intel documentation says different. And it says that in a DDIO system
persistence is not Guaranteed.

There are two ways to solve this:
1. Put a remote procedure on the passive machine that will do a CLFLUSH of
   all written regions. We hate that in our system and will not want to do
   so, this is CPU intensive and will kill our latencies.
   So NO!
2. Disable the DDIO for the NIC we use for storage.
   [In our setup we can do this because there is a 10G management NIC for
    regular trafic, and a 40/100G Melanox card dedicated to storage, so for
    the storage NIC DDIO may be disabled. (Though again it makes not difference
    for us because in our lab with or without it works the same)
   ]
3. There is a future option that we asked Intel to do, which we should talk about
   here. Set a per packet HEADER flag which says DDIO-off/on, and a way for the
   PCIE card to enforce it. Intel guys where positive for this initiative and said
   They will support it in the next chipsets.
   But I do not have any specifics on this option.

For us. Only option two is viable right now.

In any way to answer your question at the Initiator we assume that after a sync-read
of a single byte from an RDMA channel, all previous writes are persistent.
[With the DDIO flag set to off when 3. is available]

But this is only the very little Information I was able to gather and the
little experimentation we did here in the lab. A real working NvDIMM ADR
system is very scarce so far and all Vendors came out short for us with
real off-the-shelf systems.
	I was hoping you might have more information for me.

>>
>> Currently both drivers initiator and target are in Kernel, but with
>> latest advancement by Dan Williams it can be implemented in user-mode as well,
>> Almost.
>>
>> The almost is because:
>> 1. If the target is over a /dev/pmemX then all is fine we have 2M contiguous
>>     memory blocks.
>> 2. If the target is over an FS, we have a proposal pending for an falloc_2M_flag
>>     to ask the FS for a contiguous 2M allocations only. If any of the 2M allocations
>>     fail then return ENOSPC from falloc. This way we guaranty that each 2M block can be
>>     mapped by a single RDAM handle.
> 
> Umm, you don't need the 2M to be contiguous in order to represent them
> as a single RDMA handle. If that was true iSER would have never worked.
> Or I misunderstood what you meant...
> 

OK I will let our RDMA guy Yigal Korman answer that, I guess you might be right.

But regardless of this little detail we would like to keep everything 2M. Yes
virtually on the wire protocol. But even on the Server Internal configuration
we would like to see a single TLB 2M mapping of all Target's pmem. Also on the
PCIE it is nice a scatter-list with 2M single entry, instead of the 4k.
And I think it is nice for DAX systems to fallocate and guaranty 2M contiguous
allocations of heavy accessed / mmap files.

Thank you for your interest.
Boaz

