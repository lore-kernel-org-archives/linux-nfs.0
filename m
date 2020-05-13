Return-Path: <SRS0=+TNs=63=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF7D2C433E2
	for <linux-nfs@archiver.kernel.org>; Wed, 13 May 2020 21:00:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id E7E2B20659
	for <linux-nfs@archiver.kernel.org>; Wed, 13 May 2020 21:00:58 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726076AbgEMVAv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 13 May 2020 17:00:51 -0400
Received: from smtprelay0154.hostedemail.com ([216.40.44.154]:51208 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1725977AbgEMVAu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 13 May 2020 17:00:50 -0400
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
        by smtprelay08.hostedemail.com (Postfix) with ESMTP id CA6F0182CED34;
        Wed, 13 May 2020 21:00:48 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: mist41_5dde648048f06
X-Filterd-Recvd-Size: 3554
Received: from XPS-9350.home (unknown [47.151.136.130])
        (Authenticated sender: joe@perches.com)
        by omf01.hostedemail.com (Postfix) with ESMTPA;
        Wed, 13 May 2020 21:00:44 +0000 (UTC)
Message-ID: <0ee5acfaca4cf32d4efad162046b858981a4dae3.camel@perches.com>
Subject: Re: [PATCH 20/33] ipv4: add ip_sock_set_recverr
From:   Joe Perches <joe@perches.com>
To:     Christoph Hellwig <hch@lst.de>,
        "David S. Miller" <davem@davemloft.net>,
        Jakub Kicinski <kuba@kernel.org>
Cc:     Eric Dumazet <edumazet@google.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Jon Maloy <jmaloy@redhat.com>,
        Ying Xue <ying.xue@windriver.com>, drbd-dev@lists.linbit.com,
        linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-nvme@lists.infradead.org,
        target-devel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-cifs@vger.kernel.org, cluster-devel@redhat.com,
        ocfs2-devel@oss.oracle.com, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org, ceph-devel@vger.kernel.org,
        rds-devel@oss.oracle.com, linux-nfs@vger.kernel.org
Date:   Wed, 13 May 2020 14:00:43 -0700
In-Reply-To: <20200513062649.2100053-21-hch@lst.de>
References: <20200513062649.2100053-1-hch@lst.de>
         <20200513062649.2100053-21-hch@lst.de>
Content-Type: text/plain; charset="ISO-8859-1"
User-Agent: Evolution 3.36.1-2 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 2020-05-13 at 08:26 +0200, Christoph Hellwig wrote:
> Add a helper to directly set the IP_RECVERR sockopt from kernel space
> without going through a fake uaccess.

This seems used only with true as the second arg.
Is there reason to have that argument at all?

> diff --git a/include/net/ip.h b/include/net/ip.h
[]
> @@ -767,5 +767,6 @@ static inline bool inetdev_valid_mtu(unsigned int mtu)
>  
>  void ip_sock_set_tos(struct sock *sk, int val);
>  void ip_sock_set_freebind(struct sock *sk, bool val);
> +void ip_sock_set_recverr(struct sock *sk, bool val);
>  
>  #endif	/* _IP_H */
> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> index 0c40887a817f8..9abecc3195520 100644
> --- a/net/ipv4/ip_sockglue.c
> +++ b/net/ipv4/ip_sockglue.c
> @@ -589,6 +589,16 @@ void ip_sock_set_freebind(struct sock *sk, bool val)
>  }
>  EXPORT_SYMBOL(ip_sock_set_freebind);
>  
> +void ip_sock_set_recverr(struct sock *sk, bool val)
> +{
> +	lock_sock(sk);
> +	inet_sk(sk)->recverr = val;
> +	if (!val)
> +		skb_queue_purge(&sk->sk_error_queue);
> +	release_sock(sk);
> +}
> +EXPORT_SYMBOL(ip_sock_set_recverr);
> +
>  /*
>   *	Socket option code for IP. This is the end of the line after any
>   *	TCP,UDP etc options on an IP socket.
> diff --git a/net/rxrpc/local_object.c b/net/rxrpc/local_object.c
> index 562ea36c96b0f..1b87b8a9ff725 100644
> --- a/net/rxrpc/local_object.c
> +++ b/net/rxrpc/local_object.c
> @@ -171,13 +171,7 @@ static int rxrpc_open_socket(struct rxrpc_local *local, struct net *net)
>  		/* Fall through */
>  	case AF_INET:
>  		/* we want to receive ICMP errors */
> -		opt = 1;
> -		ret = kernel_setsockopt(local->socket, SOL_IP, IP_RECVERR,
> -					(char *) &opt, sizeof(opt));
> -		if (ret < 0) {
> -			_debug("setsockopt failed");
> -			goto error;
> -		}
> +		ip_sock_set_recverr(local->socket->sk, true);
>  
>  		/* we want to set the don't fragment bit */
>  		opt = IP_PMTUDISC_DO;

