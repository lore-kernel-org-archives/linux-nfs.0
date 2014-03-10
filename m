Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59131 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752663AbaCJSax (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Mar 2014 14:30:53 -0400
Date: Mon, 10 Mar 2014 14:30:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] svcrdma: fix printk when memory allocation fails
Message-ID: <20140310183052.GC28006@fieldses.org>
References: <1394465628-457-1-git-send-email-jlayton@redhat.com>
 <20140310183024.GB28006@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140310183024.GB28006@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 10, 2014 at 02:30:24PM -0400, J. Bruce Fields wrote:
> On Mon, Mar 10, 2014 at 11:33:48AM -0400, Jeff Layton wrote:
> > It retries in 1s, not 1000 jiffies.
> 
> Queueing for 3.14, thanks.--b.

(Um, 3.15.  I lose track.)

--b.

> 
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c | 3 +--
> >  1 file changed, 1 insertion(+), 2 deletions(-)
> > 
> > diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> > index 62e4f9bcc387..25688fa2207f 100644
> > --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> > +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> > @@ -477,8 +477,7 @@ struct page *svc_rdma_get_page(void)
> >  
> >  	while ((page = alloc_page(GFP_KERNEL)) == NULL) {
> >  		/* If we can't get memory, wait a bit and try again */
> > -		printk(KERN_INFO "svcrdma: out of memory...retrying in 1000 "
> > -		       "jiffies.\n");
> > +		printk(KERN_INFO "svcrdma: out of memory...retrying in 1s\n");
> >  		schedule_timeout_uninterruptible(msecs_to_jiffies(1000));
> >  	}
> >  	return page;
> > -- 
> > 1.8.5.3
> > 
