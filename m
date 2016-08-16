Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:19181 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932206AbcHPBZA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Aug 2016 21:25:00 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 02/22] SUNRPC: Refactor rpc_xdr_buf_init()
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <0750E5E3-335B-4D49-8B17-45DC0A616225@primarydata.com>
Date: Mon, 15 Aug 2016 21:24:54 -0400
Cc: List Linux RDMA Mailing <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <C38EAEDC-8CAD-48CB-9245-E33BA416047D@oracle.com>
References: <20160815195649.11652.32252.stgit@manet.1015granger.net> <20160815205030.11652.6620.stgit@manet.1015granger.net> <0750E5E3-335B-4D49-8B17-45DC0A616225@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 15, 2016, at 5:51 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
>> 
>> On Aug 15, 2016, at 16:50, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>> Clean up: there is some XDR initialization logic that is commoon
>> to the forward channel and backchannel. Move it to an XDR header
>> so it can be shared.
>> 
>> rpc_rqst::rq_buffer points to a buffer containing big-endian data.
>> Update its annotation as part of the clean up.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> include/linux/sunrpc/xdr.h        |   10 ++++++++++
>> include/linux/sunrpc/xprt.h       |    2 +-
>> net/sunrpc/backchannel_rqst.c     |    8 +-------
>> net/sunrpc/clnt.c                 |   24 ++++++------------------
>> net/sunrpc/xprtrdma/backchannel.c |   12 +-----------
>> 5 files changed, 19 insertions(+), 37 deletions(-)
>> 
>> diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
>> index 70c6b92..551569c 100644
>> --- a/include/linux/sunrpc/xdr.h
>> +++ b/include/linux/sunrpc/xdr.h
>> @@ -67,6 +67,16 @@ struct xdr_buf {
>> 			len;		/* Length of XDR encoded message */
>> };
>> 
>> +static inline void
>> +xdr_buf_init(struct xdr_buf *buf, __be32 *start, size_t len)
>> +{
>> +	memset(buf, 0, sizeof(*buf));
> 
> Can we please leave this as it was. There is no need to zero out unused fields such as the pages pointer, the tail iov_base, etc.

In the next version, I'll make this look exactly like rpc_xdr_buf_init().


>> +
>> +	buf->head[0].iov_base = start;
>> +	buf->head[0].iov_len = len;
>> +	buf->buflen = len;
>> +}
>> +
>> /*
>> * pre-xdr'ed macros.
>> */
>> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
>> index a16070d..559dad3 100644
>> --- a/include/linux/sunrpc/xprt.h
>> +++ b/include/linux/sunrpc/xprt.h
>> @@ -83,7 +83,7 @@ struct rpc_rqst {
>> 	void (*rq_release_snd_buf)(struct rpc_rqst *); /* release rq_enc_pages */
>> 	struct list_head	rq_list;
>> 
>> -	__u32 *			rq_buffer;	/* XDR encode buffer */
>> +	__be32			*rq_buffer;	/* Call XDR encode buffer */
> 
> If changing it, why not make it a void* ? Nothing should ever be touching the contents of this buffer directly.

I'll consider void *, I think that can be assigned to
without an explicit type cast.


>> 	size_t			rq_callsize,
>> 				rq_rcvsize;
>> 	size_t			rq_xmit_bytes_sent;	/* total bytes sent */
>> diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
>> index 229956b..ac701c2 100644
>> --- a/net/sunrpc/backchannel_rqst.c
>> +++ b/net/sunrpc/backchannel_rqst.c
>> @@ -76,13 +76,7 @@ static int xprt_alloc_xdr_buf(struct xdr_buf *buf, gfp_t gfp_flags)
>> 	page = alloc_page(gfp_flags);
>> 	if (page == NULL)
>> 		return -ENOMEM;
>> -	buf->head[0].iov_base = page_address(page);
>> -	buf->head[0].iov_len = PAGE_SIZE;
>> -	buf->tail[0].iov_base = NULL;
>> -	buf->tail[0].iov_len = 0;
>> -	buf->page_len = 0;
>> -	buf->len = 0;
>> -	buf->buflen = PAGE_SIZE;
>> +	xdr_buf_init(buf, page_address(page), PAGE_SIZE);
>> 	return 0;
>> }
>> 
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index 7f79fb7..0e75369 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -1748,18 +1748,6 @@ rpc_task_force_reencode(struct rpc_task *task)
>> 	task->tk_rqstp->rq_bytes_sent = 0;
>> }
>> 
>> -static inline void
>> -rpc_xdr_buf_init(struct xdr_buf *buf, void *start, size_t len)
>> -{
>> -	buf->head[0].iov_base = start;
>> -	buf->head[0].iov_len = len;
>> -	buf->tail[0].iov_len = 0;
>> -	buf->page_len = 0;
>> -	buf->flags = 0;
>> -	buf->len = 0;
>> -	buf->buflen = len;
>> -}
>> -
>> /*
>> * 3.	Encode arguments of an RPC call
>> */
>> @@ -1772,12 +1760,12 @@ rpc_xdr_encode(struct rpc_task *task)
>> 
>> 	dprint_status(task);
>> 
>> -	rpc_xdr_buf_init(&req->rq_snd_buf,
>> -			 req->rq_buffer,
>> -			 req->rq_callsize);
>> -	rpc_xdr_buf_init(&req->rq_rcv_buf,
>> -			 (char *)req->rq_buffer + req->rq_callsize,
>> -			 req->rq_rcvsize);
>> +	xdr_buf_init(&req->rq_snd_buf,
>> +		     req->rq_buffer,
>> +		     req->rq_callsize);
>> +	xdr_buf_init(&req->rq_rcv_buf,
>> +		     (__be32 *)((char *)req->rq_buffer + req->rq_callsize),
>> +		     req->rq_rcvsize);
>> 
>> 	p = rpc_encode_header(task);
>> 	if (p == NULL) {
>> diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
>> index 5f60ab2..d3cfaf2 100644
>> --- a/net/sunrpc/xprtrdma/backchannel.c
>> +++ b/net/sunrpc/xprtrdma/backchannel.c
>> @@ -38,7 +38,6 @@ static int rpcrdma_bc_setup_rqst(struct rpcrdma_xprt *r_xprt,
>> 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
>> 	struct rpcrdma_regbuf *rb;
>> 	struct rpcrdma_req *req;
>> -	struct xdr_buf *buf;
>> 	size_t size;
>> 
>> 	req = rpcrdma_create_req(r_xprt);
>> @@ -60,16 +59,7 @@ static int rpcrdma_bc_setup_rqst(struct rpcrdma_xprt *r_xprt,
>> 	req->rl_sendbuf = rb;
>> 	/* so that rpcr_to_rdmar works when receiving a request */
>> 	rqst->rq_buffer = (void *)req->rl_sendbuf->rg_base;
>> -
>> -	buf = &rqst->rq_snd_buf;
>> -	buf->head[0].iov_base = rqst->rq_buffer;
>> -	buf->head[0].iov_len = 0;
>> -	buf->tail[0].iov_base = NULL;
>> -	buf->tail[0].iov_len = 0;
>> -	buf->page_len = 0;
>> -	buf->len = 0;
>> -	buf->buflen = size;
>> -
>> +	xdr_buf_init(&rqst->rq_snd_buf, rqst->rq_buffer, size);
>> 	return 0;
>> 
>> out_fail:
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



