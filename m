Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44115 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753092AbbJGUl4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Oct 2015 16:41:56 -0400
Date: Wed, 7 Oct 2015 16:41:55 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Doug Ledford <dledford@redhat.com>
Cc: Steve Wise <swise@opengridcomputing.com>, linux-nfs@vger.kernel.org,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH RESEND] svcrdma: handle rdma read with a non-zero initial
 page offset
Message-ID: <20151007204155.GB28136@fieldses.org>
References: <20150928214605.17900.50257.stgit@build2.ogc.int>
 <56140879.3040000@redhat.com>
 <20151007170151.GB26514@fieldses.org>
 <56155751.7010903@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <56155751.7010903@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 07, 2015 at 01:33:05PM -0400, Doug Ledford wrote:
> On 10/07/2015 01:01 PM, J. Bruce Fields wrote:
> > On Tue, Oct 06, 2015 at 01:44:25PM -0400, Doug Ledford wrote:
> >> On 09/28/2015 05:46 PM, Steve Wise wrote:
> >>> The server rdma_read_chunk_lcl() and rdma_read_chunk_frmr() functions
> >>> were not taking into account the initial page_offset when determining
> >>> the rdma read length.  This resulted in a read who's starting address
> >>> and length exceeded the base/bounds of the frmr.
> >>>
> >>> Most work loads don't tickle this bug apparently, but one test hit it
> >>> every time: building the linux kernel on a 16 core node with 'make -j
> >>> 16 O=/mnt/0' where /mnt/0 is a ramdisk mounted via NFSRDMA.
> >>>
> >>> This bug seems to only be tripped with devices having small fastreg page
> >>> list depths.  I didn't see it with mlx4, for instance.
> >>
> >> Bruce, what's you're take on this?  Do you want to push this through or
> >> would you care if I push it through my tree?
> > 
> > Whoops, sorry, I meant to send a pull request for that last week.  Uh, I
> > think I'll go ahead and do that now if it's OK with you.
> 
> Fine with me.  I was just trying to make sure it didn't get forgotten ;-)

Understood, thanks!  I've sent the pull request.--b.

> 
> > --b.
> > 
> >>
> >>> Fixes: 0bf4828983df ('svcrdma: refactor marshalling logic')
> >>> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> >>> Tested-by: Chuck Lever <chuck.lever@oracle.com>
> >>> ---
> >>>
> >>>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    6 ++++--
> >>>  1 files changed, 4 insertions(+), 2 deletions(-)
> >>>
> >>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> >>> index cb51742..5f6ca47 100644
> >>> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> >>> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> >>> @@ -136,7 +136,8 @@ int rdma_read_chunk_lcl(struct svcxprt_rdma *xprt,
> >>>  	ctxt->direction = DMA_FROM_DEVICE;
> >>>  	ctxt->read_hdr = head;
> >>>  	pages_needed = min_t(int, pages_needed, xprt->sc_max_sge_rd);
> >>> -	read = min_t(int, pages_needed << PAGE_SHIFT, rs_length);
> >>> +	read = min_t(int, (pages_needed << PAGE_SHIFT) - *page_offset,
> >>> +		     rs_length);
> >>>  
> >>>  	for (pno = 0; pno < pages_needed; pno++) {
> >>>  		int len = min_t(int, rs_length, PAGE_SIZE - pg_off);
> >>> @@ -235,7 +236,8 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
> >>>  	ctxt->direction = DMA_FROM_DEVICE;
> >>>  	ctxt->frmr = frmr;
> >>>  	pages_needed = min_t(int, pages_needed, xprt->sc_frmr_pg_list_len);
> >>> -	read = min_t(int, pages_needed << PAGE_SHIFT, rs_length);
> >>> +	read = min_t(int, (pages_needed << PAGE_SHIFT) - *page_offset,
> >>> +		     rs_length);
> >>>  
> >>>  	frmr->kva = page_address(rqstp->rq_arg.pages[pg_no]);
> >>>  	frmr->direction = DMA_FROM_DEVICE;
> >>>
> >>> --
> >>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> >>> the body of a message to majordomo@vger.kernel.org
> >>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>>
> >>
> >>
> >> -- 
> >> Doug Ledford <dledford@redhat.com>
> >>               GPG KeyID: 0E572FDD
> >>
> >>
> > 
> > 
> 
> 
> -- 
> Doug Ledford <dledford@redhat.com>
>               GPG KeyID: 0E572FDD
> 
> 


