From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 09/10] SUNRPC: Ensure that we read all available tcp data
Date: Wed, 27 Feb 2008 10:21:34 -0800
Message-ID: <47C5AA2E.8020408@oracle.com>
References: <20080226172308.10383.49081.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <20080226172308.10383.82368.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060200050506010807090206"
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:47706 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757790AbYB0SWC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Feb 2008 13:22:02 -0500
In-Reply-To: <20080226172308.10383.82368.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060200050506010807090206
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> Don't stop until we run out of data, or we hit an error.

I don't understand how this patch is related to the others.

> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  net/sunrpc/xprtsock.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 30e7ac2..8bd3b0f 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1073,6 +1073,7 @@ static void xs_tcp_data_ready(struct sock *sk, int bytes)
>  {
>  	struct rpc_xprt *xprt;
>  	read_descriptor_t rd_desc;
> +	int read;
>  
>  	dprintk("RPC:       xs_tcp_data_ready...\n");
>  
> @@ -1084,8 +1085,10 @@ static void xs_tcp_data_ready(struct sock *sk, int bytes)
>  
>  	/* We use rd_desc to pass struct xprt to xs_tcp_data_recv */
>  	rd_desc.arg.data = xprt;
> -	rd_desc.count = 65536;
> -	tcp_read_sock(sk, &rd_desc, xs_tcp_data_recv);
> +	do {
> +		rd_desc.count = 65536;
> +		read = tcp_read_sock(sk, &rd_desc, xs_tcp_data_recv);
> +	} while (read > 0);

Why are we looping instead of simply setting rd_desc.count to a larger 
value (say, a megabyte)?

(If we keep this, it would be nice to replace the "65536" with a macro, 
and to add a comment explaining the need for the loop).

>  out:
>  	read_unlock(&sk->sk_callback_lock);
>  }

--------------060200050506010807090206
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck_lever.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="chuck_lever.vcf"

YmVnaW46dmNhcmQNCmZuOkNodWNrIExldmVyDQpuOkxldmVyO0NodWNrDQpvcmc6T3JhY2xl
IENvcnBvcmF0aW9uO0NvcnBvcmF0ZSBBcmNoaXRlY3R1cmU6IExpbnV4IFByb2plY3RzIEdy
b3VwDQphZHI6OzsxMDE1IEdyYW5nZXIgQXZlbnVlO0FubiBBcmJvcjtNSTs0ODEwNDtVU0EN
CnRpdGxlOlByaW5jaXBhbCBNZW1iZXIgb2YgU3RhZmYNCnRlbDt3b3JrOisxIDI0OCA2MTQg
NTA5MQ0KeC1tb3ppbGxhLWh0bWw6RkFMU0UNCnZlcnNpb246Mi4xDQplbmQ6dmNhcmQNCg0K

--------------060200050506010807090206--
