From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 21/38] svc: Change svc_sock_received to svc_xprt_received and export it
Date: Fri, 30 Nov 2007 16:33:06 -0500
Message-ID: <7E88BE3B-F35C-44B1-AE84-E5DE62E4EFA5@oracle.com>
References: <20071129223917.14563.77633.stgit@dell3.ogc.int> <20071129224037.14563.69171.stgit@dell3.ogc.int>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:56540 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752227AbXK3VeG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Nov 2007 16:34:06 -0500
In-Reply-To: <20071129224037.14563.69171.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 29, 2007, at 5:40 PM, Tom Tucker wrote:
> All fields touched by svc_sock_received are now transport independent.
> Change it to use svc_xprt directly. This function is called from
> transport dependent code, so export it.
>
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
>
>  include/linux/sunrpc/svc_xprt.h |    2 +-
>  net/sunrpc/svcsock.c            |   37 +++++++++++++++++ 
> +-------------------
>  2 files changed, 19 insertions(+), 20 deletions(-)
>
> diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/ 
> svc_xprt.h
> index d5ef902..c416d05 100644
> --- a/include/linux/sunrpc/svc_xprt.h
> +++ b/include/linux/sunrpc/svc_xprt.h
> @@ -62,8 +62,8 @@ int	svc_unreg_xprt_class(struct svc_xprt_class *);
>  void	svc_xprt_init(struct svc_xprt_class *, struct svc_xprt *,
>  		      struct svc_serv *);
>  int	svc_create_xprt(struct svc_serv *, char *, unsigned short, int);
> +void	svc_xprt_received(struct svc_xprt *);
>  void	svc_xprt_put(struct svc_xprt *xprt);
> -
>  static inline void svc_xprt_get(struct svc_xprt *xprt)
>  {
>  	kref_get(&xprt->xpt_ref);
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 5666541..0015839 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -347,14 +347,14 @@ svc_sock_dequeue(struct svc_pool *pool)
>   * Note: XPT_DATA only gets cleared when a read-attempt finds
>   * no (or insufficient) data.
>   */
> -static inline void
> -svc_sock_received(struct svc_sock *svsk)
> +void
> +svc_xprt_received(struct svc_xprt *xprt)

Style police again.  I notice several of these patches add new  
functions with the return value split onto a separate line.

>  {
> -	svsk->sk_xprt.xpt_pool = NULL;
> -	clear_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags);
> -	svc_xprt_enqueue(&svsk->sk_xprt);
> +	xprt->xpt_pool = NULL;
> +	clear_bit(XPT_BUSY, &xprt->xpt_flags);
> +	svc_xprt_enqueue(xprt);
>  }
> -
> +EXPORT_SYMBOL_GPL(svc_xprt_received);

When I submitted the RPC client-side transport switch, Trond  
suggested we add the EXPORTs later when it was clear why they are  
needed.  This may be a personal preference of the server maintainer,  
but I just thought I'd mention the possibility; it seems to make  
sense here too.

>  /**
>   * svc_reserve - change the space reserved for the reply to a  
> request.
> @@ -783,7 +783,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
>  				(serv->sv_nrthreads+3) * serv->sv_max_mesg);
>
>  	if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk))) {
> -		svc_sock_received(svsk);
> +		svc_xprt_received(&svsk->sk_xprt);
>  		return svc_deferred_recv(rqstp);
>  	}
>
> @@ -800,7 +800,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
>  			dprintk("svc: recvfrom returned error %d\n", -err);
>  			set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
>  		}
> -		svc_sock_received(svsk);
> +		svc_xprt_received(&svsk->sk_xprt);
>  		return -EAGAIN;
>  	}
>  	rqstp->rq_addrlen = sizeof(rqstp->rq_addr);
> @@ -815,7 +815,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
>  	/*
>  	 * Maybe more packets - kick another thread ASAP.
>  	 */
> -	svc_sock_received(svsk);
> +	svc_xprt_received(&svsk->sk_xprt);
>
>  	len  = skb->len - sizeof(struct udphdr);
>  	rqstp->rq_arg.len = len;
> @@ -1123,8 +1123,6 @@ static struct svc_xprt *svc_tcp_accept(struct  
> svc_xprt *xprt)
>  	}
>  	memcpy(&newsvsk->sk_local, sin, slen);
>
> -	svc_sock_received(newsvsk);
> -

I assume it's OK to remove svc_sock_received() here (rather than  
replacing it with svc_xprt_received()) because you are adding a call  
to xvs_xprt_received() below in svc_recv().

I think this is a non-trivial change amongst a whole bunch of trivial  
ones in this patch.  Thus it would be nicer if we did this in a  
separate patch so you can document your rationale for this change.   
(Yeah, I think we went over this in e-mail some time ago, but still...)

>  	if (serv->sv_stats)
>  		serv->sv_stats->nettcpconn++;
>
> @@ -1153,7 +1151,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  		test_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags));
>
>  	if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk))) {
> -		svc_sock_received(svsk);
> +		svc_xprt_received(&svsk->sk_xprt);
>  		return svc_deferred_recv(rqstp);
>  	}
>
> @@ -1193,7 +1191,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  		if (len < want) {
>  			dprintk("svc: short recvfrom while reading record length (%d of  
> %lu)\n",
>  				len, want);
> -			svc_sock_received(svsk);
> +			svc_xprt_received(&svsk->sk_xprt);
>  			return -EAGAIN; /* record header not complete */
>  		}
>
> @@ -1229,7 +1227,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  	if (len < svsk->sk_reclen) {
>  		dprintk("svc: incomplete TCP record (%d of %d)\n",
>  			len, svsk->sk_reclen);
> -		svc_sock_received(svsk);
> +		svc_xprt_received(&svsk->sk_xprt);
>  		return -EAGAIN;	/* record not complete */
>  	}
>  	len = svsk->sk_reclen;
> @@ -1269,7 +1267,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  	svsk->sk_reclen = 0;
>  	svsk->sk_tcplen = 0;
>
> -	svc_sock_received(svsk);
> +	svc_xprt_received(&svsk->sk_xprt);
>  	if (serv->sv_stats)
>  		serv->sv_stats->nettcpcnt++;
>
> @@ -1282,7 +1280,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
>   error:
>  	if (len == -EAGAIN) {
>  		dprintk("RPC: TCP recvfrom got EAGAIN\n");
> -		svc_sock_received(svsk);
> +		svc_xprt_received(&svsk->sk_xprt);
>  	} else {
>  		printk(KERN_NOTICE "%s: recvfrom returned errno %d\n",
>  		       svsk->sk_xprt.xpt_server->sv_name, -len);
> @@ -1607,8 +1605,9 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
>  			 */
>  			__module_get(newxpt->xpt_class->xcl_owner);
>  			svc_check_conn_limits(svsk->sk_xprt.xpt_server);
> +			svc_xprt_received(newxpt);
>  		}
> -		svc_sock_received(svsk);
> +		svc_xprt_received(&svsk->sk_xprt);
>  	} else {
>  		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
>  			rqstp, pool->sp_id, svsk,
> @@ -1827,7 +1826,7 @@ int svc_addsock(struct svc_serv *serv,
>  	else {
>  		svsk = svc_setup_socket(serv, so, &err, SVC_SOCK_DEFAULTS);
>  		if (svsk) {
> -			svc_sock_received(svsk);
> +			svc_xprt_received(&svsk->sk_xprt);
>  			err = 0;
>  		}
>  	}
> @@ -1882,7 +1881,7 @@ svc_create_socket(struct svc_serv *serv, int  
> protocol,
>  	}
>
>  	if ((svsk = svc_setup_socket(serv, sock, &error, flags)) != NULL) {
> -		svc_sock_received(svsk);
> +		svc_xprt_received(&svsk->sk_xprt);
>  		return (struct svc_xprt *)svsk;
>  	}
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
