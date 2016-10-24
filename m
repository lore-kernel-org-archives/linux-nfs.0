Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47418 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757257AbcJXUkZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Oct 2016 16:40:25 -0400
Date: Mon, 24 Oct 2016 16:40:22 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Eryu Guan <guaneryu@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: upstream server crash
Message-ID: <20161024204022.GB27359@fieldses.org>
References: <20161023182115.GA14481@fieldses.org>
 <20161024031519.GN2462@eguan.usersys.redhat.com>
 <1477315868.2625.37.camel@redhat.com>
 <7B3F94BF-CAA1-4001-BEBC-C93965A81DE4@oracle.com>
 <1477322377.14828.4.camel@redhat.com>
 <1477322680.14828.6.camel@redhat.com>
 <20161024180858.GA27359@fieldses.org>
 <1477336654.21854.9.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1477336654.21854.9.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 24, 2016 at 03:17:34PM -0400, Jeff Layton wrote:
> On Mon, 2016-10-24 at 14:08 -0400, J. Bruce Fields wrote:
> > On Mon, Oct 24, 2016 at 11:24:40AM -0400, Jeff Layton wrote:
> > > 
> > > On Mon, 2016-10-24 at 11:19 -0400, Jeff Layton wrote:
> > > > 
> > > > On Mon, 2016-10-24 at 09:51 -0400, Chuck Lever wrote:
> > > > > 
> > > > > 
> > > > > > 
> > > > > > 
> > > > > > 
> > > > > > On Oct 24, 2016, at 9:31 AM, Jeff Layton <jlayton@redhat.com> wrote:
> > > > > > 
> > > > > > On Mon, 2016-10-24 at 11:15 +0800, Eryu Guan wrote:
> > > > > > > 
> > > > > > > 
> > > > > > > 
> > > > > > > On Sun, Oct 23, 2016 at 02:21:15PM -0400, J. Bruce Fields wrote:
> > > > > > > > 
> > > > > > > > 
> > > > > > > > 
> > > > > > > > 
> > > > > > > > I'm getting an intermittent crash in the nfs server as of
> > > > > > > > 68778945e46f143ed7974b427a8065f69a4ce944 "SUNRPC: Separate buffer
> > > > > > > > pointers for RPC Call and Reply messages".
> > > > > > > > 
> > > > > > > > I haven't tried to understand that commit or why it would be a problem yet, I
> > > > > > > > don't see an obvious connection--I can take a closer look Monday.
> > > > > > > > 
> > > > > > > > Could even be that I just landed on this commit by chance, the problem is a
> > > > > > > > little hard to reproduce so I don't completely trust my testing.
> > > > > > > 
> > > > > > > I've hit the same crash on 4.9-rc1 kernel, and it's reproduced for me
> > > > > > > reliably by running xfstests generic/013 case, on a loopback mounted
> > > > > > > NFSv4.1 (or NFSv4.2), XFS is the underlying exported fs. More details
> > > > > > > please see
> > > > > > > 
> > > > > > > http://marc.info/?l=linux-nfs&m=147714320129362&w=2
> > > > > > > 
> > > > > > 
> > > > > > Looks like you landed at the same commit as Bruce, so that's probably
> > > > > > legit. That commit is very small though. The only real change that
> > > > > > doesn't affect the new field is this:
> > > > > > 
> > > > > > 
> > > > > > @@ -1766,7 +1766,7 @@ rpc_xdr_encode(struct rpc_task *task)
> > > > > >                      req->rq_buffer,
> > > > > >                      req->rq_callsize);
> > > > > >         xdr_buf_init(&req->rq_rcv_buf,
> > > > > > -                    (char *)req->rq_buffer + req->rq_callsize,
> > > > > > +                    req->rq_rbuffer,
> > > > > >                      req->rq_rcvsize);
> > > > > > 
> > > > > > 
> > > > > > So I'm guessing this is breaking the callback channel somehow?
> > > > > 
> > > > > Could be the TCP backchannel code is using rq_buffer in a different
> > > > > way than RDMA backchannel or the forward channel code.
> > > > > 
> > > > 
> > > > Well, it basically allocates a page per rpc_rqst and then maps that.
> > > > 
> > > > One thing I notice is that this patch ensures that rq_rbuffer gets set
> > > > up in rpc_malloc and xprt_rdma_allocate, but it looks like
> > > > xprt_alloc_bc_req didn't get the same treatment.
> > > > 
> > > > I suspect that that may be the problem...
> > > > 
> > > In fact, maybe we just need this here? (untested and probably
> > > whitespace damaged):
> > 
> > No change in results for me.
> > 
> > --b.
> > > 
> > > 
> > > diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
> > > index ac701c28f44f..c561aa8ce05b 100644
> > > --- a/net/sunrpc/backchannel_rqst.c
> > > +++ b/net/sunrpc/backchannel_rqst.c
> > > @@ -100,6 +100,7 @@ struct rpc_rqst *xprt_alloc_bc_req(struct rpc_xprt *xprt, gfp_t gfp_flags)
> > >                 goto out_free;
> > >         }
> > >         req->rq_rcv_buf.len = PAGE_SIZE;
> > > +       req->rq_rbuffer = req->rq_rcv_buf.head[0].iov_base;
> > >  
> > >         /* Preallocate one XDR send buffer */
> > >         if (xprt_alloc_xdr_buf(&req->rq_snd_buf, gfp_flags) < 0) {
> 
> Ahh ok, I think I see.
> 
> We probably also need to set rq_rbuffer in bc_malloc and and
> xprt_rdma_bc_allocate.
> 
> My guess is that we're ending up in rpc_xdr_encode with a NULL
> rq_rbuffer pointer, so the right fix would seem to be to ensure that it
> is properly set whenever rq_buffer is set.
> 
> So I think this may be what we want, actually. I'll plan to test it out
> but may not get to it before tomorrow.

It passes here.

--b.

> 
> -- 
> Jeff Layton <jlayton@redhat.com>

> From ef2a391bc4d8f6b729aacee7cde8d9baf86767c3 Mon Sep 17 00:00:00 2001
> From: Jeff Layton <jlayton@redhat.com>
> Date: Mon, 24 Oct 2016 15:13:40 -0400
> Subject: [PATCH] sunrpc: fix some missing rq_rbuffer assignments
> 
> I think we basically need to set rq_rbuffer whenever rq_buffer is set.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  net/sunrpc/xprtrdma/svc_rdma_backchannel.c | 1 +
>  net/sunrpc/xprtsock.c                      | 1 +
>  2 files changed, 2 insertions(+)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> index 2d8545c34095..fc4535ead7c2 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> @@ -182,6 +182,7 @@ xprt_rdma_bc_allocate(struct rpc_task *task)
>  		return -ENOMEM;
>  
>  	rqst->rq_buffer = page_address(page);
> +	rqst->rq_rbuffer = (char *)rqst->rq_buffer + rqst->rq_callsize;
>  	return 0;
>  }
>  
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 0137af1c0916..e01c825bc683 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -2563,6 +2563,7 @@ static int bc_malloc(struct rpc_task *task)
>  	buf->len = PAGE_SIZE;
>  
>  	rqst->rq_buffer = buf->data;
> +	rqst->rq_rbuffer = (char *)rqst->rq_buffer + rqst->rq_callsize;
>  	return 0;
>  }
>  
> -- 
> 2.7.4
> 

