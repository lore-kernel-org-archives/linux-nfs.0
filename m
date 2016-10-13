Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:18219 "EHLO
        userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751638AbcJMOeK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Oct 2016 10:34:10 -0400
Received: from userp1040.oracle.com (userp1040.oracle.com [156.151.31.81])
        by userp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u9DEXrlU027362
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Thu, 13 Oct 2016 14:33:53 GMT
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: nfsd: managing pages under network I/O
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4242E0B7-498C-4846-830F-835E1F347F85@oracle.com>
Date: Thu, 13 Oct 2016 10:32:23 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D958B5C8-D367-4B03-A729-29892C2D29BB@oracle.com>
References: <BD4A3DBB-71B5-4C30-8976-43F4DD58CBBE@oracle.com> <20161013063535.GA7149@infradead.org> <4242E0B7-498C-4846-830F-835E1F347F85@oracle.com>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 13, 2016, at 9:36 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Oct 13, 2016, at 2:35 AM, Christoph Hellwig <hch@infradead.org> wrote:
>> 
>> On Wed, Oct 12, 2016 at 01:42:26PM -0400, Chuck Lever wrote:
>>> I'm studying the way that the ->recvfrom and ->sendto calls work
>>> for RPC-over-RDMA.
>>> 
>>> The ->sendto path moves pages out of the svc_rqst before posting
>>> I/O (RDMA Write and Send). Once the work is posted, ->sendto
>>> returns, and looks like svc_rqst is released at that point. The
>>> subsequent completion of the Send then releases those moved pages.
>>> 
>>> I'm wondering if the transport can be simplified: instead of
>>> moving pages around, ->sendto could just wait until the Write and
>>> Send activity is complete, then return. The upper layer then
>>> releases everything.
>> 
>> I'd prefer not block for no reason at all.
> 
> The reason to block is to wait for I/O to complete. Can you
> elaborate: for example, are you leery of an extra context
> switch?
> 
> Note that in the Read/recvfrom case, RDMA Reads are posted,
> and then svc_rdma_recvfrom returns "deferred." When the Reads
> complete, the completion handler enqueues the work on the
> svc_xprt and svc_rdma_recvfrom is called again. Can someone
> explain why svc_rdma_recvfrom doesn't just wait for the
> RDMA Reads to complete?
> 
> What is the purpose of pulling the pages out of the svc_rqst
> while waiting for the RDMA Reads?
> 
> 
>>> Another option would be for ->sendto to return a value that means
>>> the transport will release the svc_rqst and pages.
>> 
>> Or just let the transport always release it.  We only have two
>> different implementations of the relevant ops anyway.
> 
> If each transport is responsible for releasing svc_rqst and
> pages, code is duplicated. Both transports need to do this
> releasing, so it should be done in common code (the svc RPC
> code).
> 
> I'd prefer not to have to touch the TCP transport in order
> to improve the RDMA transport implementation. However, some
> clean-up and refactoring in this area may be unavoidable.

svc_send does this:

 938         mutex_lock(&xprt->xpt_mutex);

 943                 len = xprt->xpt_ops->xpo_sendto(rqstp);
 944         mutex_unlock(&xprt->xpt_mutex);
 945         rpc_wake_up(&xprt->xpt_bc_pending);
 946         svc_xprt_release(rqstp);

Thus waiting in sendto is indeed not good: it would hold up
other replies.

But I think you're suggesting that svc_xprt_release() should
be invoked by the transport, and not by svc_send(). That
could work if there isn't a hidden dependency on the ordering
of lines 944-946.

The socket transport appears to be able to complete send
processing synchronously. Invoking svc_xprt_release() inside
the mutex critical section would probably have a negative
performance impact.

We could add another xpo callout here. For sockets it would
invoke svc_xprt_release, and for RDMA it would be a no-op.
RDMA would then be responsible for invoking svc_xprt_release
in its send completion handler.


--
Chuck Lever



