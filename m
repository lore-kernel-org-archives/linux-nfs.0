From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 0/3] have pooled sunrpc services make more intelligent
	allocations
Date: Tue, 03 Jun 2008 13:37:25 -0500
Message-ID: <1212518245.29133.25.camel@trinity.ogc.int>
References: <20080603110549.8631.46647.stgit@dantu.usersys.redhat.com>
	 <1212512022.29133.18.camel@trinity.ogc.int>
	 <20080603134257.1de3a1c3@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	bfields@fieldses.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:46983 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753387AbYFCScj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jun 2008 14:32:39 -0400
In-Reply-To: <20080603134257.1de3a1c3-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-06-03 at 13:42 -0400, Jeff Layton wrote:
> On Tue, 03 Jun 2008 11:53:42 -0500
> Tom Tucker <tom@opengridcomputing.com> wrote:
> 
> > Jeff:
> > 
> > This brings up an interesting issue with the RDMA transport and
> > RDMA_READ. RDMA_READ is submitted as part of fetching an RPC from the
> > client (e.g. NFS_WRITE). The xpo_recvfrom function doesn't block waiting
> > for the RDMA_READ to complete, but rather queues the RPC for subsequent
> > processing when the I/O completes and returns 0. 
> > 
> > I can use these new services to allocate CPU local pages for this I/O.
> > So far, so good. However, when the I/O completes, and the transport is
> > rescheduled for subsequent RPC completion processing, the pool/CPU that
> > is elected doesn't have any affinity for the CPU on which the I/O was
> > initially submitted. I think this means that the svc_process/reply steps
> > may occur on a CPU far away from the memory in which the data resides.
> > 
> > Am I making sense here? If so, any thoughts on what could/should be
> > done?
> > 
> > Thanks,
> > Tom
> > 
> 
> I confess I didn't think hard about the RDMA case here (and haven't
> been paying as much attention as I probably should to the design of
> it). So take my thoughts with a large chunk of salt...
> 
> On a NUMA box, the pages have to live _somewhere_ and some CPUs will be
> closer to them than others. If we're concerned about making sure that
> the post-RDMA_READ processing is done on a CPU close to the memory,
> then we don't have much choice but to try to make sure that this
> processing is only done on CPUs that are close to that memory.
> 
> Assuming that this post-processing is done by nfsd, I suppose we'd need
> to tag the post-RDMA_READ RPC with a poolid or something and make sure
> that only nfsds running on CPUs close to the memory pick it up. Perhaps
> there could be a per-pool queue for these RPC's or something...
> 
> Either way, the big question is whether that will be a net win or loss
> for throughput. i.e. are we better off waiting for the right nfsd to
> become available or allowing the first nfsd that becomes available to
> make the crosscalls needed to do the RPC? It's hard to say...

Not only that, but it would lead to more disorder in the RPC processing
which might kill write-behind.

> 
> In the near term, I doubt this patchset will harm the RDMA case. 

Agreed. 

> After
> all, the distribution of memory allocations is pretty lumpy now. On
> a NUMA box with RDMA you're probably doing a lot of crosscalls with
> the current code.

Probably no worse than the socket's transport since the skbuf's aren't
necessarily allocated on the CPU calling svc_recv.

> 



