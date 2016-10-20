Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36503 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757163AbcJTByx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Oct 2016 21:54:53 -0400
Message-ID: <1476928470.5650.84.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH net-next v4 3/3] udp: use it's own memory accounting
 schema
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Paolo Abeni <pabeni@redhat.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>, Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Edward Cree <ecree@solarflare.com>, linux-nfs@vger.kernel.org
Date: Wed, 19 Oct 2016 18:54:30 -0700
In-Reply-To: <33ab5953606ae34a04c3a88a9439a31475b5a496.1476877189.git.pabeni@redhat.com>
References: <cover.1476877189.git.pabeni@redhat.com>
         <33ab5953606ae34a04c3a88a9439a31475b5a496.1476877189.git.pabeni@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-10-19 at 14:47 +0200, Paolo Abeni wrote:
> Completely avoid default sock memory accounting and replace it
> with udp-specific accounting.
> 
> Since the new memory accounting model encapsulates completely
> the required locking, remove the socket lock on both enqueue and
> dequeue, and avoid using the backlog on enqueue.
> 
> Be sure to clean-up rx queue memory on socket destruction, using
> udp its own sk_destruct.
> 
> Tested using pktgen with random src port, 64 bytes packet,
> wire-speed on a 10G link as sender and udp_sink as the receiver,
> using an l4 tuple rxhash to stress the contention, and one or more
> udp_sink instances with reuseport.
> 
> nr readers      Kpps (vanilla)  Kpps (patched)
> 1               170             420
> 3               1250            1900
> 6               3000            3500
> 9               4200            4400
> 12              5700            6100
> 
> v3 -> v4:
>   - remove useless sk_rcvqueues_full() call
> 
> v2 -> v3:
>   - do not set the now unsed backlog_rcv callback
> 
> v1 -> v2:
>   - add memory pressure support
>   - fixed dropwatch accounting for ipv6
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  net/ipv4/udp.c        | 42 ++++++++----------------------------------
>  net/ipv6/udp.c        | 34 ++++++++--------------------------
>  net/sunrpc/svcsock.c  | 20 ++++++++++++++++----
>  net/sunrpc/xprtsock.c |  2 +-
>  4 files changed, 33 insertions(+), 65 deletions(-)
> 
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 7047bb3..1925ca7 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1312,13 +1312,8 @@ static int first_packet_length(struct sock *sk)
>  	res = skb ? skb->len : -1;
>  	spin_unlock_bh(&rcvq->lock);
>  
> -	if (!skb_queue_empty(&list_kill)) {
> -		bool slow = lock_sock_fast(sk);
> -
> +	if (!skb_queue_empty(&list_kill))
>  		__skb_queue_purge(&list_kill);
> -		sk_mem_reclaim_partial(sk);
> -		unlock_sock_fast(sk, slow);
> -	}

Simply call __skb_queue_purge(&list_kill);

(without testing if list_kill is empty or not)

>  	return res;
>  }
>  

We also could remove list_kill and directly call kfree_skb() in the
loop.






