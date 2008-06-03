From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 0/3] have pooled sunrpc services make more intelligent
	allocations
Date: Tue, 03 Jun 2008 11:53:42 -0500
Message-ID: <1212512022.29133.18.camel@trinity.ogc.int>
References: <20080603110549.8631.46647.stgit@dantu.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	bfields@fieldses.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:49984 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751377AbYFCQs5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jun 2008 12:48:57 -0400
In-Reply-To: <20080603110549.8631.46647.stgit-LRazzElzaNIFmhoHi+V13ACJwEvxM/w9@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff:

This brings up an interesting issue with the RDMA transport and
RDMA_READ. RDMA_READ is submitted as part of fetching an RPC from the
client (e.g. NFS_WRITE). The xpo_recvfrom function doesn't block waiting
for the RDMA_READ to complete, but rather queues the RPC for subsequent
processing when the I/O completes and returns 0. 

I can use these new services to allocate CPU local pages for this I/O.
So far, so good. However, when the I/O completes, and the transport is
rescheduled for subsequent RPC completion processing, the pool/CPU that
is elected doesn't have any affinity for the CPU on which the I/O was
initially submitted. I think this means that the svc_process/reply steps
may occur on a CPU far away from the memory in which the data resides.

Am I making sense here? If so, any thoughts on what could/should be
done?

Thanks,
Tom

On Tue, 2008-06-03 at 07:16 -0400, Jeff Layton wrote:
> The sunrpc code has had some support for spreading pooled services over
> different NUMA nodes and CPUs for some time. So far though, this support
> has been for CPU masks only. Memory allocated for these services is
> generally done by whatever CPU happens to be running the init script
> that starts the services and so most of it ends up on the same NUMA node.
> This means that nfsd's end up wasting a lot of time updating remote
> memory on a different memory node.
> 
> This patchset attempts to remedy that by having pooled services make
> per-thread allocations that are on their local memory node. I have no
> hard performance numbers for this particular patchset, but Greg Banks
> sent me a different patch that has a similar effect and claims that
> there is a significant performance gain.
> 
> Comments and suggestions appreciated...
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

