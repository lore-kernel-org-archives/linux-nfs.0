Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37752 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755626AbcH3Q2M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 Aug 2016 12:28:12 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Paolo Abeni" <pabeni@redhat.com>
Cc: netdev@vger.kernel.org,
        "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "Jeff Layton" <jlayton@poochiereds.net>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        "Jan Stancek" <jstancek@redhat.com>
Subject: Re: [PATCH net] sunrpc: fix UDP memory accounting
Date: Tue, 30 Aug 2016 12:28:07 -0400
Message-ID: <F9224521-4FC7-4647-8BB8-C92A841EE23D@redhat.com>
In-Reply-To: <32a391a2469b4161dc2375c6b6374b8229b3dd37.1472126188.git.pabeni@redhat.com>
References: <32a391a2469b4161dc2375c6b6374b8229b3dd37.1472126188.git.pabeni@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 25 Aug 2016, at 12:42, Paolo Abeni wrote:

> The commit f9b2ee714c5c ("SUNRPC: Move UDP receive data path
> into a workqueue context"), as a side effect, moved the
> skb_free_datagram() call outside the scope of the related socket
> lock, but UDP sockets require such lock to be held for proper
> memory accounting.
> Fix it by replacing skb_free_datagram() with
> skb_free_datagram_locked().
>
> Fixes: f9b2ee714c5c ("SUNRPC: Move UDP receive data path into a 
> workqueue context")
> Reported-and-tested-by: Jan Stancek <jstancek@redhat.com>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Thanks for finding this. A similar fix in 2009 for svcsock.c was done by 
Eric Dumazet:
9d410c796067 ("net: fix sk_forward_alloc corruption")

skb_free_datagram_locked() is used for all xprt types in svcsock.c, 
should we use
it for the xs_local_transport as well in xprtsock.c?

Ben

> ---
>  net/sunrpc/xprtsock.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 8ede3bc..bf16883 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1074,7 +1074,7 @@ static void xs_udp_data_receive(struct sock_xprt 
> *transport)
>  		skb = skb_recv_datagram(sk, 0, 1, &err);
>  		if (skb != NULL) {
>  			xs_udp_data_read_skb(&transport->xprt, sk, skb);
> -			skb_free_datagram(sk, skb);
> +			skb_free_datagram_locked(sk, skb);
>  			continue;
>  		}
>  		if (!test_and_clear_bit(XPRT_SOCK_DATA_READY, 
> &transport->sock_state))
> -- 
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" 
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
