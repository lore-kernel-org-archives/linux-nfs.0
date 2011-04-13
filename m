Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61808 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753897Ab1DMOCf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Apr 2011 10:02:35 -0400
Date: Wed, 13 Apr 2011 10:02:28 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        khoa@us.ibm.com
Subject: Re: [RFC][PATCH] Vector read/write support for NFS (DIO) client
Message-ID: <20110413100228.680ace66@tlielax.poochiereds.net>
In-Reply-To: <4DA5A899.3040202@us.ibm.com>
References: <1302622335.3877.62.camel@badari-desktop>
	<0DC51758-AE6C-4DD2-A959-8C8E701FEA4E@oracle.com>
	<1302624935.3877.66.camel@badari-desktop>
	<FF1EE11E-62EB-42B9-A4C9-7A2FE4C60D2F@oracle.com>
	<1302630360.3877.72.camel@badari-desktop>
	<20110413083656.12e54a91@tlielax.poochiereds.net>
	<4DA5A899.3040202@us.ibm.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 13 Apr 2011 06:43:53 -0700
Badari Pulavarty <pbadari@us.ibm.com> wrote:

> On 4/13/2011 5:36 AM, Jeff Layton wrote:
> > On Tue, 12 Apr 2011 10:46:00 -0700
> > Badari Pulavarty<pbadari@us.ibm.com>  wrote:
> >
> >    
> >> On Tue, 2011-04-12 at 12:42 -0400, Chuck Lever wrote:
> >>      
> >>> On Apr 12, 2011, at 12:15 PM, Badari Pulavarty wrote:
> >>>
> >>>        
> >>>> On Tue, 2011-04-12 at 11:36 -0400, Chuck Lever wrote:
> >>>>          
> >>>>> On Apr 12, 2011, at 11:32 AM, Badari Pulavarty wrote:
> >>>>>
> >>>>>            
> >>>>>> Hi,
> >>>>>>
> >>>>>> We recently ran into serious performance issue with NFS client.
> >>>>>> It turned out that its due to lack of readv/write support for
> >>>>>> NFS (O_DIRECT) client.
> >>>>>>
> >>>>>> Here is our use-case:
> >>>>>>
> >>>>>> In our cloud environment, our storage is over NFS. Files
> >>>>>> on NFS are passed as a blockdevices to the guest (using
> >>>>>> O_DIRECT). When guest is doing IO on these block devices,
> >>>>>> they will end up as O_DIRECT writes to NFS (on KVM host).
> >>>>>>
> >>>>>> QEMU (on the host) gets a vector from virtio-ring and
> >>>>>> submits them. Old versions of QEMU, linearized the vector
> >>>>>> it got from KVM (copied them into a buffer) and submits
> >>>>>> the buffer. So, NFS client always received a single buffer.
> >>>>>>
> >>>>>> Later versions of QEMU, eliminated this copy and submits
> >>>>>> a vector directly using preadv/pwritev().
> >>>>>>
> >>>>>> NFS client loops through the vector and submits each
> >>>>>> vector as separate request for each IO<  wsize. In our
> >>>>>> case (negotiated wsize=1MB), for 256K IO - we get 64
> >>>>>> vectors, each 4K. So, we end up submitting 64 4K FILE_SYNC IOs.
> >>>>>> Server end up doing each 4K synchronously. This causes
> >>>>>> serious performance degrade. We are trying to see if the
> >>>>>> performance improves if we convert IOs to ASYNC - but
> >>>>>> our initial results doesn't look good.
> >>>>>>
> >>>>>> readv/writev support NFS client for all possible cases is
> >>>>>> hard. Instead, if all vectors are page-aligned and
> >>>>>> iosizes page-multiple - it fits the current code easily.
> >>>>>> Luckily, QEMU use-case fits these requirements.
> >>>>>>
> >>>>>> Here is the patch to add this support. Comments ?
> >>>>>>              
> >>>>> Restricting buffer alignment requirements would be an onerous API change, IMO.
> >>>>>            
> >>>> I am not suggesting an API change at all. All I am doing is, if all
> >>>> the IOs are aligned - we can do a fast path as we can do in a single
> >>>> IO request. (as if we got a single buffer). Otherwise, we do hard
> >>>> way as today - loop through each one and do them individually.
> >>>>          
> >>> Thanks for the clarification.  That means you don't also address the problem of doing multiple small segments with FILE_SYNC writes.
> >>>
> >>>        
> >>>>> If the NFS write path is smart enough not to set FILE_SYNC when there are multiple segments to write, then the problem should be mostly fixed.  I think Jeff Layton already has a patch that does this.
> >>>>>            
> >>>> We are trying that patch. It does improve the performance by little,
> >>>> but not anywhere close to doing it as a single vector/buffer.
> >>>>
> >>>> Khoa, can you share your performance data for all the
> >>>> suggestions/patches you tried so far ?
> >>>>          
> >>> The individual WRITEs should be submitted in parallel.  If there is additional performance overhead, it is probably due to the small RPC slot table size.  Have you tried increasing it?
> >>>        
> >> We haven't tried both fixes together (RPC slot increase, Turn into
> >> ASYNC). Each one individually didn't help much. We will try them
> >> together.
> >>
> >>      
> > I must have missed some of these emails, but here's the patch that
> > Chuck mentioned and based on his suggestion. It may be reasonable as a
> > stopgap solution until Trond's overhaul of the DIO code is complete.
> >
> > With this + a larger slot table size, I would think you'd have a
> > substantial write performance improvement. Probably not as good as if
> > the writes were coalesced, but it should help.
> >
> > Badari, if you can let us know whether this plus increasing the slot
> > table size helps, then I'll plan to "officially" submit it. This one is
> > against RHEL6 but it should apply to mainline kernels with a small
> > offset.
> >
> > -----------------[snip]-----------------
> >
> > BZ#694309: nfs: use unstable writes for bigger groups of DIO writes
> >
> > Currently, the client uses FILE_SYNC whenever it's writing less than or
> > equal data to the wsize. This is a problem though if we have a bunch
> > of small iovec's batched up in a single writev call. The client will
> > iterate over them and do a single FILE_SYNC WRITE for each.
> >
> > Instead, change the code to do unstable writes when we'll need to do
> > multiple WRITE RPC's in order to satisfy the request. While we're at
> > it, optimize away the allocation of commit_data when we aren't going
> > to use it anyway.
> >
> > Signed-off-by: Jeff Layton<jlayton@redhat.com>
> >    
> 
> Khoa is running tests with this + RPC table change. Single thread 
> performance improved,
> but multi-thread tests doesn't scale (I guess running out of RPC table 
> entires even with 128 ?).
> He will share the results shortly.
> 
> Thanks,
> Badari
> 

Ok, good to know.

I tend to think that the whole slot table concept needs some
reconsideration anyway. Off the top of my head...

We could put the rpc_rqst's into a slabcache, and give each rpc_xprt a
mempool with a minimum number of slots. Have them all be allocated with
GFP_NOWAIT. If it gets a NULL pointer back, then the task can sleep on
the waitqueue like it does today. Then, the clients can allocate
rpc_rqst's as they need as long as memory holds out for it.

We have the reserve_xprt stuff to handle congestion control anyway so I
don't really see the value in the artificial limits that the slot table
provides.

Maybe I should hack up a patchset for this...

-- 
Jeff Layton <jlayton@redhat.com>
