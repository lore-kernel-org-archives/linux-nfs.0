Return-Path: linux-nfs-owner@vger.kernel.org
Received: from peace.netnation.com ([204.174.223.2]:40245 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136Ab2ISWBt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Sep 2012 18:01:49 -0400
Date: Wed, 19 Sep 2012 15:01:48 -0700
From: Simon Kirby <sim@hostway.ca>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Yan-Pai Chen <yanpai.chen@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [3.2.5] NFSv3 CLOSE_WAIT hang
Message-ID: <20120919220148.GA8249@hostway.ca>
References: <6cb9.5049fd40.b47c1@altium.nl>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908F8E302@SACEXCMBX04-PRD.hq.netapp.com>
 <447c.504a05c9.dd0a9@altium.nl>
 <447c.504a05c9.dd0a9@altium.nl>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908F8E833@SACEXCMBX04-PRD.hq.netapp.com>
 <74c7.504b9d45.a5956@altium.nl>
 <loom.20120910T105944-416@post.gmane.org>
 <20120911194051.GB11160@hostway.ca>
 <1347401844.15208.17.camel@lade.trondhjem.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908F9F734@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908F9F734@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 11, 2012 at 10:17:25PM +0000, Myklebust, Trond wrote:

> Does the "if (test_and_set_bit(XPRT_LOCK) == 0)" condition immediately
> following that succeed so that queue_work() is called?

Yes, it seems to:

[146957.793093] RPC: server initated shutdown -- state 8 conn 1 dead 0 zapped 1 sk_shutdown 1
[146957.793418] xprt_force_disconnect(): setting XPRT_CLOSE_WAIT
[146957.799288] xprt_force_disconnect(): setting XPRT_LOCKED worked, calling queue_work()

On Wed, Sep 12, 2012 at 08:54:14PM +0000, Myklebust, Trond wrote:

> On Tue, 2012-09-11 at 18:17 -0400, Trond Myklebust wrote:
> 
> Hi Simon,
> 
> Can you try the following patch, and see if it addresses the TCP "server
> hangs" case?
> 
> Cheers
>   Trond
> 8<----------------------------------------------------------------------
> From 99330d09cc1074fbdc64089fa0a3f8dbdc74daaf Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Wed, 12 Sep 2012 16:49:15 -0400
> Subject: [PATCH] SUNRPC: Ensure that the TCP socket is closed when in
>  CLOSE_WAIT
> 
> Instead of doing a shutdown() call, we need to do an actual close().
> Ditto if/when the server is sending us junk RPC headers.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  net/sunrpc/xprtsock.c | 21 ++++++++++++++++-----
>  1 file changed, 16 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index a35b8e5..d1988cf 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1025,6 +1025,16 @@ static void xs_udp_data_ready(struct sock *sk, int len)
>  	read_unlock_bh(&sk->sk_callback_lock);
>  }
>  
> +/*
> + * Helper function to force a TCP close if the server is sending
> + * junk and/or it has put us in CLOSE_WAIT
> + */
> +static void xs_tcp_force_close(struct rpc_xprt *xprt)
> +{
> +	set_bit(XPRT_CONNECTION_CLOSE, &xprt->state);
> +	xprt_force_disconnect(xprt);
> +}
> +
>  static inline void xs_tcp_read_fraghdr(struct rpc_xprt *xprt, struct xdr_skb_reader *desc)
>  {
>  	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
> @@ -1051,7 +1061,7 @@ static inline void xs_tcp_read_fraghdr(struct rpc_xprt *xprt, struct xdr_skb_rea
>  	/* Sanity check of the record length */
>  	if (unlikely(transport->tcp_reclen < 8)) {
>  		dprintk("RPC:       invalid TCP record fragment length\n");
> -		xprt_force_disconnect(xprt);
> +		xs_tcp_force_close(xprt);
>  		return;
>  	}
>  	dprintk("RPC:       reading TCP record fragment of length %d\n",
> @@ -1132,7 +1142,7 @@ static inline void xs_tcp_read_calldir(struct sock_xprt *transport,
>  		break;
>  	default:
>  		dprintk("RPC:       invalid request message type\n");
> -		xprt_force_disconnect(&transport->xprt);
> +		xs_tcp_force_close(&transport->xprt);
>  	}
>  	xs_tcp_check_fraghdr(transport);
>  }
> @@ -1455,6 +1465,8 @@ static void xs_tcp_cancel_linger_timeout(struct rpc_xprt *xprt)
>  static void xs_sock_mark_closed(struct rpc_xprt *xprt)
>  {
>  	smp_mb__before_clear_bit();
> +	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
> +	clear_bit(XPRT_CONNECTION_CLOSE, &xprt->state);
>  	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
>  	clear_bit(XPRT_CLOSING, &xprt->state);
>  	smp_mb__after_clear_bit();
> @@ -1512,8 +1524,8 @@ static void xs_tcp_state_change(struct sock *sk)
>  		break;
>  	case TCP_CLOSE_WAIT:
>  		/* The server initiated a shutdown of the socket */
> -		xprt_force_disconnect(xprt);
>  		xprt->connect_cookie++;
> +		xs_tcp_force_close(xprt);
>  	case TCP_CLOSING:
>  		/*
>  		 * If the server closed down the connection, make sure that
> @@ -2199,8 +2211,7 @@ static void xs_tcp_setup_socket(struct work_struct *work)
>  		/* We're probably in TIME_WAIT. Get rid of existing socket,
>  		 * and retry
>  		 */
> -		set_bit(XPRT_CONNECTION_CLOSE, &xprt->state);
> -		xprt_force_disconnect(xprt);
> +		xs_tcp_force_close(xprt);
>  		break;
>  	case -ECONNREFUSED:
>  	case -ECONNRESET:
> -- 
> 1.7.11.4

Yes, based on data collected today, this seems to fix the problem!
Awesome! :)

Simon-
