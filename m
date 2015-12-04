Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:34842 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754185AbbLDPaQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Dec 2015 10:30:16 -0500
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH v1 3/8] svcrdma: Add svc_rdma_get_context() API that is allowed to fail
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20151124065522.GC29141@infradead.org>
Date: Fri, 4 Dec 2015 10:29:45 -0500
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <E41A0933-FDF0-4995-B676-83B648D35F46@oracle.com>
References: <20151123221738.13040.26277.stgit@klimt.1015granger.net> <20151123222038.13040.61285.stgit@klimt.1015granger.net> <20151124065522.GC29141@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 24, 2015, at 1:55 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
>> +struct svc_rdma_op_ctxt *svc_rdma_get_context_gfp(struct svcxprt_rdma *xprt,
>> +						  gfp_t flags)
>> +{
>> +	struct svc_rdma_op_ctxt *ctxt;
>> +
>> +	ctxt = kmem_cache_alloc(svc_rdma_ctxt_cachep, flags);
>> +	if (!ctxt)
>> +		return NULL;
>> +	svc_rdma_init_context(xprt, ctxt);
>> +	return ctxt;
>> +}
>> +
>> +struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
>> +{
>> +	struct svc_rdma_op_ctxt *ctxt;
>> +
>> +	ctxt = kmem_cache_alloc(svc_rdma_ctxt_cachep,
>> +				GFP_KERNEL | __GFP_NOFAIL);
>> +	svc_rdma_init_context(xprt, ctxt);
>> 	return ctxt;
> 
> Sounds like you should have just added a gfp_t argument to
> svc_rdma_get_context.  And if we have any way to avoid the __GFP_NOFAIL
> I'd really appreciate if we could give that a try.

Changed my mind on this.

struct svc_rdma_op_ctxt used to be smaller than a page, so these
allocations were not likely to fail. But since the maximum NFS
READ and WRITE payload for NFS/RDMA has been increased to 1MB,
struct svc_rdma_op_ctxt has grown to more than 6KB, thus it is
no longer an order 0 memory allocation.

Some ideas:

1. Pre-allocate these per connection in svc_rdma_accept().
There will never be more than sc_sq_depth of these. But that
could be a large number to allocate during connection
establishment.

2. Once allocated, cache them. If traffic doesn’t manage to
allocate sc_sq_depth of these over time, allocation can still
fail during a traffic burst in very low memory scenarios.

3. Use a mempool. This reserves a few of these which may never
be used. But allocation can still fail once the reserve is
consumed (same as 2).

4. Break out the sge and pages arrays into separate allocations
so the allocation requests are order 0.

1 seems like the most robust solution, and it would be fast.
svc_rdma_get_context is a very common operation.


--
Chuck Lever




