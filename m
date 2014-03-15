Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:9660 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755919AbaCONa4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 15 Mar 2014 09:30:56 -0400
Date: Sat, 15 Mar 2014 09:30:50 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Tom Tucker <tom@opengridcomputing.com>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org, swise@opengridcomputing.com,
        Tom Talpey <tmtalpey@gmail.com>
Subject: Re: [PATCH] svcrdma: fix offset calculation for non-page aligned
 sge entries
Message-ID: <20140315093050.3f1b0d5e@tlielax.poochiereds.net>
In-Reply-To: <20140312171832.33f04ee8@tlielax.poochiereds.net>
References: <1394635867-19089-1-git-send-email-jlayton@redhat.com>
	<5320C6DE.4090807@opengridcomputing.com>
	<20140312171832.33f04ee8@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 12 Mar 2014 17:18:32 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> On Wed, 12 Mar 2014 15:43:10 -0500
> Tom Tucker <tom@opengridcomputing.com> wrote:
> 
> > Hi Jeff,
> > 
> > 
> > On 3/12/14 9:51 AM, Jeff Layton wrote:
> > > The xdr_off value in dma_map_xdr gets passed to ib_dma_map_page as the
> > > offset into the page to be mapped. For the case of the pages array, the
> > > existing calculation always seems to end up at 0, which causes data
> > > corruption when a non-page-aligned READ request comes in. The server ends
> > > up doing the RDMA_WRITE from the wrong part of the page.
> > >
> > > Override the xdr_off value with the page_base in that situation to fix
> > > the issue. Obviously, this method can't contend with a page_base that is
> > > larger than PAGE_SIZE.
> > I think we saw page base > PAGE_SIZE when inter-operating with Sun, but 
> > maybe someone else on the list has a clearer recollection.
> > 
> 
> Ok, I may need to rejigger that logic to account for that case. I'll do
> that and send a v2 once I test it out...
> 

Self-NAK on this patch...

page_base I think is not so much a problem as the fact that we can get
a READ request that is not page-aligned and that spans multiple pages
in the array.

For instance, if you do (pseudocode):

    fd = open("/file/on/nfsordma", O_RDONLY|O_DIRECT);
    lseek(fd, 1024, SEEK_SET);
    read(fd, buf, PAGE_SIZE);

...then you get different data than if you didn't use O_DIRECT. I think
we could probably cook up a similar test using pynfs, fwiw...

The existing code doesn't handle that correctly, and neither does the
code after my patch. Fixing this correctly doesn't look trivial though,
as I think we'll have to push some awareness of the alignment of the
pages array farther up the call chain.


> > I am curious, however, why xdr_off was always zero if in fact, page_base 
> > was not page aligned.
> > 
> 
> Mostly I was testing with sub-page sized READ requests (which are of
> course done via RDMA_WRITE). Assume we have a READ request for 512
> bytes.
> 
> On the first pass into send_write, we call dma_map_xdr to map the
> head. On that call xdr_off is 0.
> 
> On the next pass, we go to send the page data. At that point,
> xdr_off == head[0].iov_len:
> 
> -------------------8<----------------------
>         } else {
>                 xdr_off -= xdr->head[0].iov_len;
>                 if (xdr_off < xdr->page_len) {
>                         /* This offset is in the page list */
>                         page = xdr->pages[xdr_off >> PAGE_SHIFT];
>                         xdr_off &= ~PAGE_MASK;
>                 } else {
> -------------------8<----------------------
> 
> ...so we subtract xdr->head[0].iov_len, and xdr_off is now 0.
> 
> The problem is that you can't determine where in the pages array the
> data to send actually starts just from the xdr_off. That just tells you
> how far into the xdr buffer you are. If the data you actually want
> isn't aligned to the start of the page (xdr->page_base !=0) then you
> can't tell from that.
> 
> That info is tracked inside the xdr->page_base, so we need use that to
> determine what the mapping offset should be.
> 


-- 
Jeff Layton <jlayton@redhat.com>
