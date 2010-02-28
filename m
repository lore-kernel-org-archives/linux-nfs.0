From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: The recent kref_put warning
Date: Sat, 27 Feb 2010 18:46:55 -0600
Message-ID: <4B89BCFF.10405@opengridcomputing.com>
References: <19336.19524.469529.431210@notabene.brown>	<20100226225416.GF26598@fieldses.org>	<4B886A1A.7060106@opengridcomputing.com>	<20100227123537.6289e326@notabene.brown> <20100227165913.53718449@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, Wei Yongjun <yjwei@cn.fujitsu.com>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:44648 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031001Ab0B1ArE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Feb 2010 19:47:04 -0500
In-Reply-To: <20100227165913.53718449-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Makes sense to me.

Neil Brown wrote:
> On Sat, 27 Feb 2010 12:35:37 +1100
> Neil Brown <neilb@suse.de> wrote:
>
>   
>>  So if XPT_CLOSE is set while xpo_recvfrom is being called, which I think
>>  is possible, and if ->xpo_recvfrom returns non-zero, then we end up
>>  processing a request on a dead socket, which doesn't sound like the right
>>  thing to do.  I don't think it can cause the present problem, but
>>  it looks wrong.  That last 'if' should just be an 'else'.
>>  I guess that would effectively reverse b0401d7253, though - not that
>>  that patch seems entirely right to me - if there is a problem I probably
>>  would have fixed it differently, though I'm not sure how.
>>  So maybe change "if (XPT_CLOSE)" to "if (len <= 0 && XPT_CLOSE)" ???
>>     
>
> OK, I think I've nailed it.  I think  b0401d7253 is the culprit.
> Now let me see if I can convince you (and me).
>
> Firstly, why is this patch wrong.
> It claims:
>     
>     sunrpc: "Move close processing to a single place"
>     (d7979ae4a050a45b78af51832475001b68263d2a) moved the
>     close processing before the recvfrom method. This may
>     cause the close processing never to execute. So this
>     patch moves it to the right place.
>     
> The referenced commit did *not* move the close processing before the
> recvfrom method - it was already there.  The close processing was previously
> at the top of the individual recvfrom methods.  It was split out and common
> code with placed before the now-slightly-reduced recvfrom methods.
> This is functionally a null change.
>
> However that doesn't explain why sometimes "the close processing [would]]
> never .. execute".
> The reason for this is subtle.  One the changes in commit d7979ae4a is
>
>   err_delete:
> -       svc_delete_socket(svsk);
> +       set_bit(SK_CLOSE, &svsk->sk_flags);
>         return -EAGAIN;
>
> This is insufficient. The recvfrom methods must always call svc_xprt_received
> on completion so that the socket gets re-queued if there is any more work to
> do.  This particular path did not make that call because it actually
> destroyed the svsk, making requeue pointless.  When the svc_delete_socket was
> change to just set a bit, we should have added a call to svc_xprt_received,
> but we didn't.  Sorry.  As I said, it was subtle.
>
> So how is the b0401d7253 patch causing a problem?
>
> svc_tcp_state_change - which can be called at any time - sets XPT_CLOSE.
> If this happens while svc_tcp_recvfrom is running and before one of the
> calls to svc_xprt_received, then svc_xprt_received will requeue the svsk for
> further processing (to handle the close).
> As soon a svc_tcp_recvfrom completes, svc_recv will notice that XPT_CLOSE is
> set and will close the socket, dropping the last refcount.  Subsequently the
> thread which the socket was queued to wakes up, calls svc_recv, and triggers
> the warning.
>
> So the fix I propose is:
>  - make the XPT_CLOSE case in svc_recv once more exclusive with the
>    ->recvfrom case
>  - make sure all paths out of all recvfrom methods call svc_xprt_received.
>    Maybe it should be called after the ->xpo_recvfrom call instead.
>
> So something like this?  I've made quite a few changes here - it might be
> worth splitting them up.  One worth noting is that we now don't re-queue a udp
> socket at the earliest opportunity, but possibly do a
> csum_partial_copy_to_xdr before the requeue which could reduce performance
> slightly with udp on a multiprocessor.  I have no idea what the actual
> performance effect would be, but I think it makes the code a lot more robust
> (move the svc_xprt_received to just one place).
>
> NeilBrown
>
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 4f30336..2d99fb8 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -699,8 +699,12 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
>  	spin_unlock_bh(&pool->sp_lock);
>  
>  	len = 0;
> -	if (test_bit(XPT_LISTENER, &xprt->xpt_flags) &&
> -	    !test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
> +
> +	if (test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
> +		dprintk("svc_recv: found XPT_CLOSE\n");
> +		svc_delete_xprt(xprt);
> +		return 0;
> +	} else if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
>  		struct svc_xprt *newxpt;
>  		newxpt = xprt->xpt_ops->xpo_accept(xprt);
>  		if (newxpt) {
> @@ -726,23 +730,19 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
>  			svc_xprt_received(newxpt);
>  		}
>  		svc_xprt_received(xprt);
> -	} else if (!test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
> -		dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
> -			rqstp, pool->sp_id, xprt,
> -			atomic_read(&xprt->xpt_ref.refcount));
> -		rqstp->rq_deferred = svc_deferred_dequeue(xprt);
> -		if (rqstp->rq_deferred) {
> -			svc_xprt_received(xprt);
> -			len = svc_deferred_recv(rqstp);
> -		} else
> -			len = xprt->xpt_ops->xpo_recvfrom(rqstp);
> -		dprintk("svc: got len=%d\n", len);
> +		return 0;
>  	}
>  
> -	if (test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
> -		dprintk("svc_recv: found XPT_CLOSE\n");
> -		svc_delete_xprt(xprt);
> -	}
> +	dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
> +		rqstp, pool->sp_id, xprt,
> +		atomic_read(&xprt->xpt_ref.refcount));
> +	rqstp->rq_deferred = svc_deferred_dequeue(xprt);
> +	if (rqstp->rq_deferred)
> +		len = svc_deferred_recv(rqstp);
> +	else
> +		len = xprt->xpt_ops->xpo_recvfrom(rqstp);
> +	dprintk("svc: got len=%d\n", len);
> +	svc_xprt_received(xprt);
>  
>  	/* No data, incomplete (TCP) read, or accept() */
>  	if (len == 0 || len == -EAGAIN) {
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 870929e..22d9904 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -547,7 +547,6 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
>  			dprintk("svc: recvfrom returned error %d\n", -err);
>  			set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
>  		}
> -		svc_xprt_received(&svsk->sk_xprt);
>  		return -EAGAIN;
>  	}
>  	len = svc_addr_len(svc_addr(rqstp));
> @@ -562,11 +561,6 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
>  	svsk->sk_sk->sk_stamp = skb->tstamp;
>  	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags); /* there may be more data... */
>  
> -	/*
> -	 * Maybe more packets - kick another thread ASAP.
> -	 */
> -	svc_xprt_received(&svsk->sk_xprt);
> -
>  	len  = skb->len - sizeof(struct udphdr);
>  	rqstp->rq_arg.len = len;
>  
> @@ -917,7 +911,6 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
>  		if (len < want) {
>  			dprintk("svc: short recvfrom while reading record "
>  				"length (%d of %d)\n", len, want);
> -			svc_xprt_received(&svsk->sk_xprt);
>  			goto err_again; /* record header not complete */
>  		}
>  
> @@ -953,7 +946,6 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
>  	if (len < svsk->sk_reclen) {
>  		dprintk("svc: incomplete TCP record (%d of %d)\n",
>  			len, svsk->sk_reclen);
> -		svc_xprt_received(&svsk->sk_xprt);
>  		goto err_again;	/* record not complete */
>  	}
>  	len = svsk->sk_reclen;
> @@ -961,10 +953,9 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
>  
>  	return len;
>   error:
> -	if (len == -EAGAIN) {
> +	if (len == -EAGAIN)
>  		dprintk("RPC: TCP recv_record got EAGAIN\n");
> -		svc_xprt_received(&svsk->sk_xprt);
> -	}
> +
>  	return len;
>   err_delete:
>  	set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
> @@ -1109,18 +1100,14 @@ out:
>  	svsk->sk_tcplen = 0;
>  
>  	svc_xprt_copy_addrs(rqstp, &svsk->sk_xprt);
> -	svc_xprt_received(&svsk->sk_xprt);
>  	if (serv->sv_stats)
>  		serv->sv_stats->nettcpcnt++;
>  
>  	return len;
>  
>  err_again:
> -	if (len == -EAGAIN) {
> +	if (len == -EAGAIN)
>  		dprintk("RPC: TCP recvfrom got EAGAIN\n");
> -		svc_xprt_received(&svsk->sk_xprt);
> -		return len;
> -	}
>  error:
>  	if (len != -EAGAIN) {
>  		printk(KERN_NOTICE "%s: recvfrom returned errno %d\n",
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index f92e37e..0194de8 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -566,7 +566,6 @@ static int rdma_read_complete(struct svc_rqst *rqstp,
>  		ret, rqstp->rq_arg.len,	rqstp->rq_arg.head[0].iov_base,
>  		rqstp->rq_arg.head[0].iov_len);
>  
> -	svc_xprt_received(rqstp->rq_xprt);
>  	return ret;
>  }
>  
> @@ -665,7 +664,6 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
>  		rqstp->rq_arg.head[0].iov_len);
>  	rqstp->rq_prot = IPPROTO_MAX;
>  	svc_xprt_copy_addrs(rqstp, xprt);
> -	svc_xprt_received(xprt);
>  	return ret;
>  
>   close_out:
> @@ -678,6 +676,5 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
>  	 */
>  	set_bit(XPT_CLOSE, &xprt->xpt_flags);
>  defer:
> -	svc_xprt_received(xprt);
>  	return 0;
>  }
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

