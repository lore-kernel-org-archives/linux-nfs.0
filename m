From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: The recent kref_put warning (was: [PATCH] sunrpc: remove
	unnecessary svc_xprt_put)
Date: Mon, 1 Mar 2010 09:50:16 -0500
Message-ID: <20100301145015.GE17660@fieldses.org>
References: <19336.19524.469529.431210@notabene.brown> <20100226225416.GF26598@fieldses.org> <4B886A1A.7060106@opengridcomputing.com> <20100227123537.6289e326@notabene.brown> <20100227165913.53718449@notabene.brown> <20100228210553.GA27965@fieldses.org> <20100228220723.GB27965@fieldses.org> <20100301105734.7fe935b0@notabene.brown> <20100301034647.GA8462@fieldses.org> <20100301165114.74d2797b@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>, linux-nfs@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48645 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750808Ab0CAOtJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Mar 2010 09:49:09 -0500
In-Reply-To: <20100301165114.74d2797b-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 01, 2010 at 04:51:14PM +1100, Neil Brown wrote:
> On Sun, 28 Feb 2010 22:46:47 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Mon, Mar 01, 2010 at 10:57:34AM +1100, Neil Brown wrote:
> > > No, you are correct.  "return 0" is wrong, it should be "return -EAGAIN",
> > > both in the XPT_CLOSE case and the XPT_LISTENER case.
> > > 
> > > I observed that in both those cases, 'len' remained at 0 and we didn't do
> > > much else but 'return len', so I optimised.
> > > I forgot to factor in:
> > > 
> > > 	if (len == 0 || len == -EAGAIN) {
> > > 		rqstp->rq_res.len = 0;
> > > 		svc_xprt_release(rqstp);
> > > 		return -EAGAIN;
> > > 	}
> > > 
> > > So the svc_xprt_release needs to be moved in there as well, I'm not sure
> > > about the rq_res.len = 0.
> > > Maybe that was a bad case of premature-optimisation :-)
> > > 
> > > We should probably leave that last else clause as it is and just have a
> > > single return from the function.
> > 
> > OK, so the below is what I'm thinking of sending, after some testing;
> > really just a split-up version of your patches (uh, so credits may be
> > wrong) with the final cleanup removed:
> 
> Credits and code look OK the me, thanks.

Thanks, and I'll add S-o-b/acked-by for you as appropriate assuming no
objection.

> > 	1. remove the extra put from svc_delete_xprt().
> > 	2,3. Revert 2 problematic patches which caused the oops people
> > 	are seeing.
> > 	4. Fix the original bug from the rdma series.
> > 
> > And the first 3 will go to stable as well.  The 4th might eventually
> > too, it just seems less urgent.
> > 
> > I also agree with the cleanup that moves the svc_xprt_received to one
> > place, I'm just hoping you won't mind regenerating it against this.
> 
> See below.
> There is still room to tidy up svc_recv, including getting the xpo_recvfrom
> routines to report -EAGAIN when that is what they mean, rather than '0',
> but I'm not really happy with what I have so-far so I won't post it yet.

OK, thanks again!

--b.

> 
> NeilBrown
> 
> 
> From 1e75b9d1232957cd44e0d8ea704c9af431cc85be Mon Sep 17 00:00:00 2001
> From: NeilBrown <neilb@suse.de>
> Date: Mon, 1 Mar 2010 15:49:11 +1100
> Subject: [PATCH] sunrpc: centralise most calls to svc_xprt_received
> 
> svc_xprt_received must be called when ->xpo_recvfrom has finished
> receiving a message, so that the XPT_BUSY flag will be cleared and
> if necessary, requeued for further work.
> 
> This call is currently made in each ->xpo_recvfrom function, often
> from multiple different point, in each case it is the earliest point
> on a particular path where it is known that the protection provided by
> XPT_BUSY is no longer needed.
> 
> However there are (still) some error paths which do not call
> svc_xprt_received, and requiring each ->xpo_recvfrom to make the call
> does not encourage robustness.
> 
> So: move the svc_xprt_received call to be made just after the
> call to ->xpo_recvfrom(), and move it of the various ->xpo_recvfrom
> methods.
> 
> This means that it may not be called at the earliest possible instant,
> but this is unlikely to be a measurable performance issue.
> 
> Note that there are still other calls to svc_xprt_received as it is
> also needed when an xprt is newly created.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 6bd41a9..70b74be 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -736,8 +736,10 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
>  		if (rqstp->rq_deferred) {
>  			svc_xprt_received(xprt);
>  			len = svc_deferred_recv(rqstp);
> -		} else
> +		} else {
>  			len = xprt->xpt_ops->xpo_recvfrom(rqstp);
> +			svc_xprt_received(xprt);
> +		}
>  		dprintk("svc: got len=%d\n", len);
>  	}
>  
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 528efef..7425029 100644
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
> @@ -961,14 +953,11 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
>  
>  	return len;
>   error:
> -	if (len == -EAGAIN) {
> +	if (len == -EAGAIN)
>  		dprintk("RPC: TCP recv_record got EAGAIN\n");
> -		svc_xprt_received(&svsk->sk_xprt);
> -	}
>  	return len;
>   err_delete:
>  	set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
> -	svc_xprt_received(&svsk->sk_xprt);
>   err_again:
>  	return -EAGAIN;
>  }
> @@ -1110,7 +1099,6 @@ out:
>  	svsk->sk_tcplen = 0;
>  
>  	svc_xprt_copy_addrs(rqstp, &svsk->sk_xprt);
> -	svc_xprt_received(&svsk->sk_xprt);
>  	if (serv->sv_stats)
>  		serv->sv_stats->nettcpcnt++;
>  
> @@ -1119,7 +1107,6 @@ out:
>  err_again:
>  	if (len == -EAGAIN) {
>  		dprintk("RPC: TCP recvfrom got EAGAIN\n");
> -		svc_xprt_received(&svsk->sk_xprt);
>  		return len;
>  	}
>  error:
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
