Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:47865 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756705Ab1DLRnv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Apr 2011 13:43:51 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3CHcLga029953
	for <linux-nfs@vger.kernel.org>; Tue, 12 Apr 2011 11:38:21 -0600
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3CHhlgv095418
	for <linux-nfs@vger.kernel.org>; Tue, 12 Apr 2011 11:43:48 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3CHhlxD026045
	for <linux-nfs@vger.kernel.org>; Tue, 12 Apr 2011 11:43:47 -0600
Subject: Re: [RFC][PATCH] Vector read/write support for NFS (DIO) client
From: Badari Pulavarty <pbadari@us.ibm.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, khoa@us.ibm.com
In-Reply-To: <FF1EE11E-62EB-42B9-A4C9-7A2FE4C60D2F@oracle.com>
References: <1302622335.3877.62.camel@badari-desktop>
	 <0DC51758-AE6C-4DD2-A959-8C8E701FEA4E@oracle.com>
	 <1302624935.3877.66.camel@badari-desktop>
	 <FF1EE11E-62EB-42B9-A4C9-7A2FE4C60D2F@oracle.com>
Content-Type: text/plain
Date: Tue, 12 Apr 2011 10:46:00 -0700
Message-Id: <1302630360.3877.72.camel@badari-desktop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-04-12 at 12:42 -0400, Chuck Lever wrote:
> On Apr 12, 2011, at 12:15 PM, Badari Pulavarty wrote:
> 
> > On Tue, 2011-04-12 at 11:36 -0400, Chuck Lever wrote:
> >> On Apr 12, 2011, at 11:32 AM, Badari Pulavarty wrote:
> >> 
> >>> Hi,
> >>> 
> >>> We recently ran into serious performance issue with NFS client.
> >>> It turned out that its due to lack of readv/write support for
> >>> NFS (O_DIRECT) client.
> >>> 
> >>> Here is our use-case:
> >>> 
> >>> In our cloud environment, our storage is over NFS. Files
> >>> on NFS are passed as a blockdevices to the guest (using
> >>> O_DIRECT). When guest is doing IO on these block devices,
> >>> they will end up as O_DIRECT writes to NFS (on KVM host).
> >>> 
> >>> QEMU (on the host) gets a vector from virtio-ring and
> >>> submits them. Old versions of QEMU, linearized the vector
> >>> it got from KVM (copied them into a buffer) and submits
> >>> the buffer. So, NFS client always received a single buffer.
> >>> 
> >>> Later versions of QEMU, eliminated this copy and submits
> >>> a vector directly using preadv/pwritev().
> >>> 
> >>> NFS client loops through the vector and submits each
> >>> vector as separate request for each IO < wsize. In our
> >>> case (negotiated wsize=1MB), for 256K IO - we get 64 
> >>> vectors, each 4K. So, we end up submitting 64 4K FILE_SYNC IOs. 
> >>> Server end up doing each 4K synchronously. This causes
> >>> serious performance degrade. We are trying to see if the
> >>> performance improves if we convert IOs to ASYNC - but
> >>> our initial results doesn't look good.
> >>> 
> >>> readv/writev support NFS client for all possible cases is
> >>> hard. Instead, if all vectors are page-aligned and 
> >>> iosizes page-multiple - it fits the current code easily.
> >>> Luckily, QEMU use-case fits these requirements.
> >>> 
> >>> Here is the patch to add this support. Comments ?
> >> 
> >> Restricting buffer alignment requirements would be an onerous API change, IMO.
> > 
> > I am not suggesting an API change at all. All I am doing is, if all
> > the IOs are aligned - we can do a fast path as we can do in a single
> > IO request. (as if we got a single buffer). Otherwise, we do hard
> > way as today - loop through each one and do them individually.
> 
> Thanks for the clarification.  That means you don't also address the problem of doing multiple small segments with FILE_SYNC writes.
> 
> >> If the NFS write path is smart enough not to set FILE_SYNC when there are multiple segments to write, then the problem should be mostly fixed.  I think Jeff Layton already has a patch that does this.
> > 
> > We are trying that patch. It does improve the performance by little,
> > but not anywhere close to doing it as a single vector/buffer.
> > 
> > Khoa, can you share your performance data for all the
> > suggestions/patches you tried so far ?
> 
> The individual WRITEs should be submitted in parallel.  If there is additional performance overhead, it is probably due to the small RPC slot table size.  Have you tried increasing it?

We haven't tried both fixes together (RPC slot increase, Turn into
ASYNC). Each one individually didn't help much. We will try them
together.

Thanks,
Badari

