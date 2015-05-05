Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:40427 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965729AbbEERKm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 May 2015 13:10:42 -0400
Message-ID: <5548F98F.5050601@Netapp.com>
Date: Tue, 5 May 2015 13:10:39 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Stefan Hajnoczi <stefanha@redhat.com>, <linux-nfs@vger.kernel.org>
CC: Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] SUNRPC: drop stale setup_socket doc comments
References: <1430835480-29982-1-git-send-email-stefanha@redhat.com>
In-Reply-To: <1430835480-29982-1-git-send-email-stefanha@redhat.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Stefan,

On 05/05/2015 10:18 AM, Stefan Hajnoczi wrote:
> xs_local_setup_socket() and xs_tcp_setup_socket() have outdated
> arguments listed in the doc comments.  Drop arguments that no longer
> exist.

Can you please fix up xs_local_data_ready(), xs_udp_data_ready(), and xs_tcp_data_ready() while you're at it?

Thanks!
Anna

> 
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> ---
>  net/sunrpc/xprtsock.c | 5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 66891e3..a8d6c6e 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1886,9 +1886,7 @@ static int xs_local_finish_connecting(struct rpc_xprt *xprt,
>  
>  /**
>   * xs_local_setup_socket - create AF_LOCAL socket, connect to a local endpoint
> - * @xprt: RPC transport to connect
>   * @transport: socket transport to connect
> - * @create_sock: function to create a socket of the correct type
>   */
>  static int xs_local_setup_socket(struct sock_xprt *transport)
>  {
> @@ -2125,9 +2123,6 @@ out:
>  
>  /**
>   * xs_tcp_setup_socket - create a TCP socket and connect to a remote endpoint
> - * @xprt: RPC transport to connect
> - * @transport: socket transport to connect
> - * @create_sock: function to create a socket of the correct type
>   *
>   * Invoked by a work queue tasklet.
>   */
> 

