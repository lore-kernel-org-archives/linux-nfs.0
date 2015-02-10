Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx141.netapp.com ([216.240.21.12]:58855 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751074AbbBJPyV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Feb 2015 10:54:21 -0500
Message-ID: <54DA29AA.7060702@Netapp.com>
Date: Tue, 10 Feb 2015 10:54:18 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 11/15] SUNRPC: Make xs_tcp_close() do a socket shutdown
 rather than a sock_release
References: <1423522091-35365-1-git-send-email-trond.myklebust@primarydata.com> <1423522091-35365-2-git-send-email-trond.myklebust@primarydata.com> <1423522091-35365-3-git-send-email-trond.myklebust@primarydata.com> <1423522091-35365-4-git-send-email-trond.myklebust@primarydata.com> <1423522091-35365-5-git-send-email-trond.myklebust@primarydata.com> <1423522091-35365-6-git-send-email-trond.myklebust@primarydata.com> <1423522091-35365-7-git-send-email-trond.myklebust@primarydata.com> <1423522091-35365-8-git-send-email-trond.myklebust@primarydata.com> <1423522091-35365-9-git-send-email-trond.myklebust@primarydata.com> <1423522091-35365-10-git-send-email-trond.myklebust@primarydata.com> <1423522091-35365-11-git-send-email-trond.myklebust@primarydata.com> <1423522091-35365-12-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423522091-35365-12-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On 02/09/2015 05:48 PM, Trond Myklebust wrote:
> Use of socket shutdown() means that we monitor the shutdown process
> through the xs_tcp_state_change() callback, so it is preferable to
> a full close in all cases unless we're destroying the transport.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  net/sunrpc/xprtsock.c | 6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 3d83cbd32ef2..0279e8ffb14a 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -857,10 +857,7 @@ static void xs_close(struct rpc_xprt *xprt)
>  
>  static void xs_tcp_close(struct rpc_xprt *xprt)
>  {
> -	if (test_and_clear_bit(XPRT_CONNECTION_CLOSE, &xprt->state))
> -		xs_close(xprt);
> -	else
> -		xs_tcp_shutdown(xprt);
> +	xs_tcp_shutdown(xprt);

Can we remove xs_tcp_close() and call tcp_shutdown() directly instead?

Anna
>  }
>  
>  static void xs_xprt_free(struct rpc_xprt *xprt)
> @@ -1033,7 +1030,6 @@ static void xs_udp_data_ready(struct sock *sk)
>   */
>  static void xs_tcp_force_close(struct rpc_xprt *xprt)
>  {
> -	set_bit(XPRT_CONNECTION_CLOSE, &xprt->state);
>  	xprt_force_disconnect(xprt);
>  }
>  
> 

