Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:54874 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726031AbeIFXei (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Sep 2018 19:34:38 -0400
Received: by mail-it0-f67.google.com with SMTP id f14-v6so16879040ita.4
        for <linux-nfs@vger.kernel.org>; Thu, 06 Sep 2018 11:57:49 -0700 (PDT)
Message-ID: <53b44ea582204ab36bb63428a8444def777972a4.camel@gmail.com>
Subject: Re: [PATCH v2 20/34] SUNRPC: Treat the task and request as separate
 in the xprt_ops->send_request()
From: Trond Myklebust <trondmy@gmail.com>
To: "Schumaker, Anna" <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Thu, 06 Sep 2018 14:57:22 -0400
In-Reply-To: <7b354356492977b7ff948182907de28f0f67f308.camel@netapp.com>
References: <20180904210549.81673-1-trond.myklebust@hammerspace.com>
         <20180904210549.81673-2-trond.myklebust@hammerspace.com>
         <20180904210549.81673-3-trond.myklebust@hammerspace.com>
         <20180904210549.81673-4-trond.myklebust@hammerspace.com>
         <20180904210549.81673-5-trond.myklebust@hammerspace.com>
         <20180904210549.81673-6-trond.myklebust@hammerspace.com>
         <20180904210549.81673-7-trond.myklebust@hammerspace.com>
         <20180904210549.81673-8-trond.myklebust@hammerspace.com>
         <20180904210549.81673-9-trond.myklebust@hammerspace.com>
         <20180904210549.81673-10-trond.myklebust@hammerspace.com>
         <20180904210549.81673-11-trond.myklebust@hammerspace.com>
         <20180904210549.81673-12-trond.myklebust@hammerspace.com>
         <20180904210549.81673-13-trond.myklebust@hammerspace.com>
         <20180904210549.81673-14-trond.myklebust@hammerspace.com>
         <20180904210549.81673-15-trond.myklebust@hammerspace.com>
         <20180904210549.81673-16-trond.myklebust@hammerspace.com>
         <20180904210549.81673-17-trond.myklebust@hammerspace.com>
         <20180904210549.81673-18-trond.myklebust@hammerspace.com>
         <20180904210549.81673-19-trond.myklebust@hammerspace.com>
         <20180904210549.81673-20-trond.myklebust@hammerspace.com>
         <20180904210549.81673-21-trond.myklebust@hammerspace.com>
         <7b354356492977b7ff948182907de28f0f67f308.camel@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2018-09-06 at 18:49 +0000, Schumaker, Anna wrote:
> Hi Trond,
> 
> On Tue, 2018-09-04 at 17:05 -0400, Trond Myklebust wrote:
> > When we shift to using the transmit queue, then the task that holds
> > the
> > write lock will not necessarily be the same as the one being
> > transmitted.
> > 
> > Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> > ---
> >  include/linux/sunrpc/xprt.h                |  2 +-
> >  net/sunrpc/xprt.c                          |  2 +-
> >  net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  3 +--
> >  net/sunrpc/xprtrdma/transport.c            |  5 ++--
> >  net/sunrpc/xprtsock.c                      | 27 +++++++++++-------
> > ----
> >  5 files changed, 18 insertions(+), 21 deletions(-)
> > 
> > diff --git a/include/linux/sunrpc/xprt.h
> > b/include/linux/sunrpc/xprt.h
> > index 81a6c2c8dfc7..6d91acfe0644 100644
> > --- a/include/linux/sunrpc/xprt.h
> > +++ b/include/linux/sunrpc/xprt.h
> > @@ -140,7 +140,7 @@ struct rpc_xprt_ops {
> >  	void		(*connect)(struct rpc_xprt *xprt, struct
> > rpc_task
> > *task);
> >  	int		(*buf_alloc)(struct rpc_task *task);
> >  	void		(*buf_free)(struct rpc_task *task);
> > -	int		(*send_request)(struct rpc_task *task);
> > +	int		(*send_request)(struct rpc_rqst *req, struct
> > rpc_task
> > *task);
> >  	void		(*set_retrans_timeout)(struct rpc_task
> > *task);
> >  	void		(*timer)(struct rpc_xprt *xprt, struct
> > rpc_task
> > *task);
> >  	void		(*release_request)(struct rpc_task *task);
> > diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> > index 8e8c345eedf7..7c80f93562e5 100644
> > --- a/net/sunrpc/xprt.c
> > +++ b/net/sunrpc/xprt.c
> > @@ -1170,7 +1170,7 @@ void xprt_transmit(struct rpc_task *task)
> >  	}
> >  
> >  	connect_cookie = xprt->connect_cookie;
> > -	status = xprt->ops->send_request(task);
> > +	status = xprt->ops->send_request(req, task);
> >  	trace_xprt_transmit(xprt, req->rq_xid, status);
> >  	if (status != 0) {
> >  		task->tk_status = status;
> > diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> > b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> > index 09b12b7568fe..d1618c70edb4 100644
> > --- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> > +++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> > @@ -215,9 +215,8 @@ rpcrdma_bc_send_request(struct svcxprt_rdma
> > *rdma, struct
> > rpc_rqst *rqst)
> >   * connection.
> >   */
> >  static int
> > -xprt_rdma_bc_send_request(struct rpc_task *task)
> > +xprt_rdma_bc_send_request(struct rpc_rqst *rqst, struct rpc_task
> > *task)
> >  {
> > -	struct rpc_rqst *rqst = task->tk_rqstp;
> >  	struct svc_xprt *sxprt = rqst->rq_xprt->bc_xprt;
> >  	struct svcxprt_rdma *rdma;
> >  	int ret;
> > diff --git a/net/sunrpc/xprtrdma/transport.c
> > b/net/sunrpc/xprtrdma/transport.c
> > index 143ce2579ba9..fa684bf4d090 100644
> > --- a/net/sunrpc/xprtrdma/transport.c
> > +++ b/net/sunrpc/xprtrdma/transport.c
> > @@ -706,9 +706,8 @@ xprt_rdma_free(struct rpc_task *task)
> >   *		sent. Do not try to send this message again.
> >   */
> >  static int
> > -xprt_rdma_send_request(struct rpc_task *task)
> > +xprt_rdma_send_request(struct rpc_rqst *rqst, struct rpc_task
> > *task)
> >  {
> > -	struct rpc_rqst *rqst = task->tk_rqstp;
> >  	struct rpc_xprt *xprt = rqst->rq_xprt;
> >  	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
> >  	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
> > @@ -741,7 +740,7 @@ xprt_rdma_send_request(struct rpc_task *task)
> >  	/* An RPC with no reply will throw off credit accounting,
> >  	 * so drop the connection to reset the credit grant.
> >  	 */
> > -	if (!rpc_reply_expected(task))
> > +	if (!rpc_reply_expected(rqst->rq_task))
> >  		goto drop_connection;
> >  	return 0;
> >  
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index 8d6404259ff9..b8143eded4af 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -449,12 +449,12 @@ static void xs_nospace_callback(struct
> > rpc_task *task)
> >  
> >  /**
> >   * xs_nospace - place task on wait queue if transmit was
> > incomplete
> > + * @req: pointer to RPC request
> >   * @task: task to put to sleep
> >   *
> >   */
> > -static int xs_nospace(struct rpc_task *task)
> > +static int xs_nospace(struct rpc_rqst *req, struct rpc_task *task)
> >  {
> > -	struct rpc_rqst *req = task->tk_rqstp;
> >  	struct rpc_xprt *xprt = req->rq_xprt;
> >  	struct sock_xprt *transport = container_of(xprt, struct
> > sock_xprt,
> > xprt);
> >  	struct sock *sk = transport->inet;
> > @@ -513,6 +513,7 @@ static inline void
> > xs_encode_stream_record_marker(struct
> > xdr_buf *buf)
> >  
> >  /**
> >   * xs_local_send_request - write an RPC request to an AF_LOCAL
> > socket
> > + * @req: pointer to RPC request
> >   * @task: RPC task that manages the state of an RPC request
> >   *
> >   * Return values:
> > @@ -522,9 +523,8 @@ static inline void
> > xs_encode_stream_record_marker(struct
> > xdr_buf *buf)
> >   * ENOTCONN:	Caller needs to invoke connect logic then call
> > again
> >   *    other:	Some other error occured, the request was not
> > sent
> >   */
> > -static int xs_local_send_request(struct rpc_task *task)
> > +static int xs_local_send_request(struct rpc_rqst *req, struct
> > rpc_task *task)
> >  {
> > -	struct rpc_rqst *req = task->tk_rqstp;
> >  	struct rpc_xprt *xprt = req->rq_xprt;
> >  	struct sock_xprt *transport =
> >  				container_of(xprt, struct sock_xprt,
> > xprt);
> > @@ -569,7 +569,7 @@ static int xs_local_send_request(struct
> > rpc_task *task)
> >  	case -ENOBUFS:
> >  		break;
> >  	case -EAGAIN:
> > -		status = xs_nospace(task);
> > +		status = xs_nospace(req, task);
> >  		break;
> >  	default:
> >  		dprintk("RPC:       sendmsg returned unrecognized error
> > %d\n",
> > @@ -585,6 +585,7 @@ static int xs_local_send_request(struct
> > rpc_task *task)
> >  
> >  /**
> >   * xs_udp_send_request - write an RPC request to a UDP socket
> > + * @req: pointer to RPC request
> >   * @task: address of RPC task that manages the state of an RPC
> > request
> >   *
> >   * Return values:
> > @@ -594,9 +595,8 @@ static int xs_local_send_request(struct
> > rpc_task *task)
> >   * ENOTCONN:	Caller needs to invoke connect logic then call
> > again
> >   *    other:	Some other error occurred, the request was not
> > sent
> >   */
> > -static int xs_udp_send_request(struct rpc_task *task)
> > +static int xs_udp_send_request(struct rpc_rqst *req, struct
> > rpc_task *task)
> >  {
> > -	struct rpc_rqst *req = task->tk_rqstp;
> >  	struct rpc_xprt *xprt = req->rq_xprt;
> >  	struct sock_xprt *transport = container_of(xprt, struct
> > sock_xprt,
> > xprt);
> >  	struct xdr_buf *xdr = &req->rq_snd_buf;
> > @@ -638,7 +638,7 @@ static int xs_udp_send_request(struct rpc_task
> > *task)
> >  		/* Should we call xs_close() here? */
> >  		break;
> >  	case -EAGAIN:
> > -		status = xs_nospace(task);
> > +		status = xs_nospace(req, task);
> >  		break;
> >  	case -ENETUNREACH:
> >  	case -ENOBUFS:
> > @@ -658,6 +658,7 @@ static int xs_udp_send_request(struct rpc_task
> > *task)
> >  
> >  /**
> >   * xs_tcp_send_request - write an RPC request to a TCP socket
> > + * @req: pointer to RPC request
> >   * @task: address of RPC task that manages the state of an RPC
> > request
> >   *
> >   * Return values:
> > @@ -670,9 +671,8 @@ static int xs_udp_send_request(struct rpc_task
> > *task)
> >   * XXX: In the case of soft timeouts, should we eventually give up
> >   *	if sendmsg is not able to make progress?
> >   */
> > -static int xs_tcp_send_request(struct rpc_task *task)
> > +static int xs_tcp_send_request(struct rpc_rqst *req, struct
> > rpc_task *task)
> >  {
> > -	struct rpc_rqst *req = task->tk_rqstp;
> >  	struct rpc_xprt *xprt = req->rq_xprt;
> >  	struct sock_xprt *transport = container_of(xprt, struct
> > sock_xprt,
> > xprt);
> >  	struct xdr_buf *xdr = &req->rq_snd_buf;
> > @@ -697,7 +697,7 @@ static int xs_tcp_send_request(struct rpc_task
> > *task)
> >  	 * completes while the socket holds a reference to the pages,
> >  	 * then we may end up resending corrupted data.
> >  	 */
> > -	if (task->tk_flags & RPC_TASK_SENT)
> > +	if (req->rq_task->tk_flags & RPC_TASK_SENT)
> 
> Can req or rq_task be null coming into this function?  I'm seeing the
> following
> null pointer dereference while running connectathon tests on v4.1
> after this
> patch:

The backchannels do need PATCH 24/34
