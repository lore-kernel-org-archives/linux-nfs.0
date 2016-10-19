Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40892 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932977AbcJSTQK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Oct 2016 15:16:10 -0400
Date: Wed, 19 Oct 2016 15:16:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: nfsd: managing pages under network I/O
Message-ID: <20161019191608.GD23282@fieldses.org>
References: <BD4A3DBB-71B5-4C30-8976-43F4DD58CBBE@oracle.com>
 <20161019172611.GA22783@fieldses.org>
 <CFE1B548-5AC0-451E-BC9D-253395443355@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CFE1B548-5AC0-451E-BC9D-253395443355@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 19, 2016 at 02:28:40PM -0400, Chuck Lever wrote:
> 
> > On Oct 19, 2016, at 1:26 PM, bfields@fieldses.org wrote:
> > 
> > On Wed, Oct 12, 2016 at 01:42:26PM -0400, Chuck Lever wrote:
> >> I'm studying the way that the ->recvfrom and ->sendto calls work
> >> for RPC-over-RDMA.
> >> 
> >> The ->sendto path moves pages out of the svc_rqst before posting
> >> I/O (RDMA Write and Send). Once the work is posted, ->sendto
> >> returns, and looks like svc_rqst is released at that point. The
> >> subsequent completion of the Send then releases those moved pages.
> >> 
> >> I'm wondering if the transport can be simplified: instead of
> >> moving pages around, ->sendto could just wait until the Write and
> >> Send activity is complete, then return. The upper layer then
> >> releases everything.
> > 
> > I don't understand what problem you're trying to fix.  Is "moving pages
> > around" really especially complicated or expensive?
> 
> Moving pages is complicated and undocumented, and adds host CPU and
> memory costs (loads and stores). There is also a whole lot of page
> allocator traffic in this code, and that will be enabling and
> disabling interrupts and bottom-halves with some frequency.

I thought "moving pages around" here is basically just this, from
isvc_rdma_sendto.c:send_reply():

	pages = rqstp->rq_next_page - rqstp->rq_respages;
        for (page_no = 0; page_no < pages; page_no++) {
                ctxt->pages[page_no+1] = rqstp->rq_respages[page_no];
		...
                rqstp->rq_respages[page_no] = NULL;
		...
	}

So we're just copying an array of page pointers from one place to
another, and zeroing out the source array.

For a short reply that could be 1 page or even none.  In the worst case
(a 1MB read result) that could be 256 8-byte pointers, so 2K.

Am I missing something?  Has that up-to-2K operation been a problem?

--b.

> 
> The less involvement by the host CPU the better. The current RDMA
> transport code documents the RPC-over-RDMA protocol to some extent,
> but the need for moving the pages is to the reader's imagination.
> 
> From my code audit:
> 
> The svc_rqst is essentially a static piece of memory, and the calling
> NFSD kthread will re-use it immediately when svc_sendto() returns. It
> cannot be manipulated asynchronously. The recvfrom calls and the
> sendto call for one RPC request can each use a different svc_rqst,
> for example. So if the transport needs to use pages for longer the
> length of one svc_sendto call (for example, to wait for RDMA Write to
> complete) then it has to move those pages out of the svc_rqst before
> it returns. (Let me know if I've got this wrong).
> 
> I'm falling back to looking at ways to clean up and document the
> movement of these pages so it is better understood why it is done.
> There also could be some opportunity to share page movement helpers
> between the RDMA read and write path (and perhaps the TCP transport
> too).
> 
> HTH.
> 
> 
> > --b.
> > 
> >> 
> >> Another option would be for ->sendto to return a value that means
> >> the transport will release the svc_rqst and pages.
> >> 
> >> Or, the svc_rqst could be reference counted.
> >> 
> >> Anyone have thoughts about this?
> 
> 
> --
> Chuck Lever
> 
> 
