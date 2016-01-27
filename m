Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24209 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752884AbcA0Pzp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jan 2016 10:55:45 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Remote access to pmem on storage targets
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160127000404.GN6033@dastard>
Date: Wed, 27 Jan 2016 10:55:36 -0500
Cc: Jan Kara <jack@suse.cz>, lsf-pc@lists.linux-foundation.org,
        Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D1002C60-C01D-410C-ABD4-7BDDB82E0CC1@oracle.com>
References: <06414D5A-0632-4C74-B76C-038093E8AED3@oracle.com> <20160126082533.GR24938@quack.suse.cz> <F0E2108B-891C-4570-B486-7DC7C4FB59C4@oracle.com> <20160127000404.GN6033@dastard>
To: Dave Chinner <david@fromorbit.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 26, 2016, at 7:04 PM, Dave Chinner <david@fromorbit.com> wrote:
> 
> On Tue, Jan 26, 2016 at 10:58:44AM -0500, Chuck Lever wrote:
>> It is not going to be like the well-worn paradigm that
>> involves a page cache on the storage target backed by
>> slow I/O operations. The protocol layers on storage
>> targets need a way to discover memory addresses of
>> persistent memory that will be used as source/sink
>> buffers for RDMA operations.
>> 
>> And making data durable after a write is going to need
>> some thought. So I believe some new plumbing will be
>> necessary.
> 
> Haven't we already solve this for the pNFS file driver that XFS
> implements? i.e. these export operations:
> 
>        int (*get_uuid)(struct super_block *sb, u8 *buf, u32 *len, u64 *offset);
>        int (*map_blocks)(struct inode *inode, loff_t offset,
>                          u64 len, struct iomap *iomap,
>                          bool write, u32 *device_generation);
>        int (*commit_blocks)(struct inode *inode, struct iomap *iomaps,
>                             int nr_iomaps, struct iattr *iattr);
> 
> so mapping/allocation of file offset to sector mappings, which can
> then trivially be used to grab the memory address through the bdev
> ->direct_access method, yes?

Thanks, that makes sense. How would such addresses be
utilized?

I'll speak about the NFS/RDMA server for this example, as
I am more familiar with that than with block targets. When
I say "NFS server" here I mean the software service on the
storage target that speaks the NFS protocol.

In today's RDMA-enabled storage protocols, an initiator
exposes its memory (in small segments) to storage targets,
sends a request, and the target's network transport performs
RDMA Read and Write operations to move the payload data in
that request.

Assuming the NFS server is somehow aware that what it is
getting from ->direct_access is a persistent memory address
and not an LBA, it would then have to pass it down to the
transport layer (svcrdma) so that the address can be used
as a source or sink buffer for RDMA operations.

For an NFS READ, this should be straightforward. An RPC
request comes in, the NFS server identifies the memory that
is to source the READ reply and passes the address of that
memory to the transport, which then pushes the data in
that memory via an RDMA Write to the client.

NFS WRITES are more difficult. An RPC request comes in,
and today the transport layer gathers incoming payload data
in anonymous pages before the NFS server even knows there
is an incoming RPC. We'd have to add some kind of hook to
enable the NFS server and the underlying filesystem to
provide appropriate sink buffers to the transport.

After the NFS WRITE request has been wholly received, the
NFS server today uses vfs_writev to put that data into the
target file. We'd probably want something more efficient
for pmem-backed filesystems. We want something more
efficient for traditional page cache-based filesystems
anyway.

Every NFS WRITE larger than a page would be essentially
CoW, since the filesystem would need to provide "anonymous"
blocks to sink incoming WRITE data and then transition
those blocks into the target file? Not sure how this works
for pNFS with block devices.

Finally a client needs to perform an NFS COMMIT to ensure
that the written data is at rest on durable storage. We
could insist that all NFS WRITE operations to pmem will
be DATA_SYNC or better (in other words, abandon UNSTABLE
mode). If not, then a separate NFS COMMIT/LAYOUTCOMMIT
is necessary to flush memory caches and ensure data
durability. An extra RPC round trip is likely not a good
idea when the cost structure of NFS WRITE is so much
different than it is for traditional block devices.

NFS WRITE is really the thing we want to go as fast as
possible, btw. NFS READ on RDMA is already faster, for
reasons I won't go into here. Aside from that, NFS READ
results are frequently cached on clients, and some of the
cost of NFS READ is already hidden by read-ahead. Because
read(2) is often satisfied from a local cache, application
progress is more frequently blocked by pending write(2)
calls than by reads.

A fully generic solution would have to provide NFS service
for transports that do not enable direct data placement
(eg TCP), and for filesystems that are legacy page
cache-based (anything residing on a traditional block
device).

I imagine that the issues are similar for block targets, if
they assume block devices are fronted by a memory cache.


--
Chuck Lever




