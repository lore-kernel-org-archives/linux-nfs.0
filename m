Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f45.google.com ([209.85.215.45]:56522 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753401AbaATO1Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jan 2014 09:27:24 -0500
Received: by mail-la0-f45.google.com with SMTP id b8so5603889lan.18
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jan 2014 06:27:23 -0800 (PST)
Message-ID: <52DD3247.6090108@cogentembedded.com>
Date: Mon, 20 Jan 2014 18:27:19 +0400
From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
MIME-Version: 1.0
To: shaobingqing <shaobingqing@bwstor.com.cn>, trond.myklebust@primarydata.com,
        bfields@redhat.com, davem@davemloft.net
CC: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Allow one callback request to be received from
 two sk_buff
References: <n> <1390201154-20815-1-git-send-email-shaobingqing@bwstor.com.cn>
In-Reply-To: <1390201154-20815-1-git-send-email-shaobingqing@bwstor.com.cn>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello.

On 20-01-2014 10:59, shaobingqing wrote:

> In current code, there only one struct rpc_rqst is prealloced. If one
> callback request is received from two sk_buff, the xprt_alloc_bc_request
> would be execute two times with the same transport->xid. The first time
> xprt_alloc_bc_request will alloc one struct rpc_rqst and the TCP_RCV_COPY_DATA
> bit of transport->tcp_flags will not be cleared. The second time
> xprt_alloc_bc_request could not alloc struct rpc_rqst any more and NULL
> pointer will be returned, then xprt_force_disconnect occur. I think one
> callback request can be allowed to be received from two sk_buff.

> Signed-off-by: shaobingqing <shaobingqing@bwstor.com.cn>
> ---
>   net/sunrpc/xprtsock.c |   11 +++++++++--
>   1 files changed, 9 insertions(+), 2 deletions(-)

> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index ee03d35..606950d 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
[...]
> @@ -1297,7 +1303,8 @@ static inline int xs_tcp_read_callback(struct rpc_xprt *xprt,
>   		list_add(&req->rq_bc_list, &bc_serv->sv_cb_list);
>   		spin_unlock(&bc_serv->sv_cb_lock);
>   		wake_up(&bc_serv->sv_cb_waitq);
> -	}
> +	} else
> +		req_partial = req;

    {} is needed in the *else* branch since it's already used in another 
branch of *if* -- see Documentation/CodingStyle.

WBR, Sergei

