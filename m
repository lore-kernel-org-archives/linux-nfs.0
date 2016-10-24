Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:38904 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752360AbcJXPYm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Oct 2016 11:24:42 -0400
Received: by mail-qk0-f173.google.com with SMTP id v138so1787200qka.5
        for <linux-nfs@vger.kernel.org>; Mon, 24 Oct 2016 08:24:42 -0700 (PDT)
Message-ID: <1477322680.14828.6.camel@redhat.com>
Subject: Re: upstream server crash
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Eryu Guan <guaneryu@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Mon, 24 Oct 2016 11:24:40 -0400
In-Reply-To: <1477322377.14828.4.camel@redhat.com>
References: <20161023182115.GA14481@fieldses.org>
         <20161024031519.GN2462@eguan.usersys.redhat.com>
         <1477315868.2625.37.camel@redhat.com>
         <7B3F94BF-CAA1-4001-BEBC-C93965A81DE4@oracle.com>
         <1477322377.14828.4.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2016-10-24 at 11:19 -0400, Jeff Layton wrote:
> On Mon, 2016-10-24 at 09:51 -0400, Chuck Lever wrote:
> > 
> > > 
> > > 
> > > On Oct 24, 2016, at 9:31 AM, Jeff Layton <jlayton@redhat.com> wrote:
> > > 
> > > On Mon, 2016-10-24 at 11:15 +0800, Eryu Guan wrote:
> > > > 
> > > > 
> > > > On Sun, Oct 23, 2016 at 02:21:15PM -0400, J. Bruce Fields wrote:
> > > > > 
> > > > > 
> > > > > 
> > > > > I'm getting an intermittent crash in the nfs server as of
> > > > > 68778945e46f143ed7974b427a8065f69a4ce944 "SUNRPC: Separate buffer
> > > > > pointers for RPC Call and Reply messages".
> > > > > 
> > > > > I haven't tried to understand that commit or why it would be a problem yet, I
> > > > > don't see an obvious connection--I can take a closer look Monday.
> > > > > 
> > > > > Could even be that I just landed on this commit by chance, the problem is a
> > > > > little hard to reproduce so I don't completely trust my testing.
> > > > 
> > > > I've hit the same crash on 4.9-rc1 kernel, and it's reproduced for me
> > > > reliably by running xfstests generic/013 case, on a loopback mounted
> > > > NFSv4.1 (or NFSv4.2), XFS is the underlying exported fs. More details
> > > > please see
> > > > 
> > > > http://marc.info/?l=linux-nfs&m=147714320129362&w=2
> > > > 
> > > 
> > > Looks like you landed at the same commit as Bruce, so that's probably
> > > legit. That commit is very small though. The only real change that
> > > doesn't affect the new field is this:
> > > 
> > > 
> > > @@ -1766,7 +1766,7 @@ rpc_xdr_encode(struct rpc_task *task)
> > >                      req->rq_buffer,
> > >                      req->rq_callsize);
> > >         xdr_buf_init(&req->rq_rcv_buf,
> > > -                    (char *)req->rq_buffer + req->rq_callsize,
> > > +                    req->rq_rbuffer,
> > >                      req->rq_rcvsize);
> > > 
> > > 
> > > So I'm guessing this is breaking the callback channel somehow?
> > 
> > Could be the TCP backchannel code is using rq_buffer in a different
> > way than RDMA backchannel or the forward channel code.
> > 
> 
> Well, it basically allocates a page per rpc_rqst and then maps that.
> 
> One thing I notice is that this patch ensures that rq_rbuffer gets set
> up in rpc_malloc and xprt_rdma_allocate, but it looks like
> xprt_alloc_bc_req didn't get the same treatment.
> 
> I suspect that that may be the problem...
> 
In fact, maybe we just need this here? (untested and probably
whitespace damaged):

diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index ac701c28f44f..c561aa8ce05b 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -100,6 +100,7 @@ struct rpc_rqst *xprt_alloc_bc_req(struct rpc_xprt *xprt, gfp_t gfp_flags)
                goto out_free;
        }
        req->rq_rcv_buf.len = PAGE_SIZE;
+       req->rq_rbuffer = req->rq_rcv_buf.head[0].iov_base;
 
        /* Preallocate one XDR send buffer */
        if (xprt_alloc_xdr_buf(&req->rq_snd_buf, gfp_flags) < 0) {
