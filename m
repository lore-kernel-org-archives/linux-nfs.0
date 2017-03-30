Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:49081 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934431AbdC3PaZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Mar 2017 11:30:25 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2 05/13] svcrdma: Introduce local rdma_rw API helpers
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170330123014.GA32364@infradead.org>
Date: Thu, 30 Mar 2017 10:29:41 -0500
Cc: List Linux RDMA Mailing <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <370FEB6E-1E2C-4578-91FC-A035ADF16F78@oracle.com>
References: <20170327132329.5585.98465.stgit@klimt.1015granger.net> <20170327134835.5585.76603.stgit@klimt.1015granger.net> <20170330123014.GA32364@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 30, 2017, at 7:30 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
>> +	spinlock_t	     sc_rw_ctxt_lock;
>> +	struct list_head     sc_rw_ctxts;
> 
> It's a little sad that we always need a list and a spinlock when
> most requests should need a single context only.

The current code needs resources protected by several
spinlocks, some of which disable bottom-halfs. This rewrite
takes it down to just this one plain vanilla spinlock which
picks up all the svcrdma layer resources needed for the I/O
at once.

There are some common cases which can require more than one
of these.

My point is, I think this is better than trips to a memory
allocator, because those frequently require at least one
BH-disabled or irqsave spinlock, which helps prevent
latency outliers and, rarely, allocation failures.

That said, I will happily consider any solution that does
not require critical sections!


>> + * Each WR chain handles a single contiguous server-side buffer,
>> + * because some registration modes (eg. FRWR) do not support a
>> + * discontiguous scatterlist.
> 
> Both FRWR and FMR have no problem with a discontiguous page list,
> they only have a problem with any segment but the first not starting
> page aligned.  For NFS you'll need vectored direct I/O to hit that
> case.

I'll rewrite the comment.

For the Write chunk path, each RDMA segment in the chunk
can have a different R_key. So each non-empty segment gets
its own rdma_rw chain. If the client is good, it will use
a single large segment, but not all of them do.

The Reply chunk case occurs commonly, and can require
three or more separate scatterlists, due to the alignment
constraint. Each RPC Reply resides in an xdr_buf, each of
which has up to three portions:

1. A head, which is not necessarily page-aligned,
2. A page list, which does not have to be page-aligned, and
3. A tail, which is frequently but not always in the same page
as the head (and is thus not expected to be page-aligned).

The client can provide multiple segments, each with its
own R_key. The server has to fit the RDMA Writes into both
the alignment constraints of the xdr_buf components, and
the segments provided by the client.

This is why I organized the "write the reply chunk" path
this way.

Thanks to both you and Sagi for excellent review comments.


--
Chuck Lever



