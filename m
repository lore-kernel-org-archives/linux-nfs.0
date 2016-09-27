Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35928 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751496AbcI0SmQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Sep 2016 14:42:16 -0400
Message-ID: <1475001734.28155.62.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH net-next v2 3/3] udp: use it's own memory accounting
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
Date: Tue, 27 Sep 2016 11:42:14 -0700
In-Reply-To: <bc55b0885e0f93895c211168561a6b3403bade10.1474995024.git.pabeni@redhat.com>
References: <cover.1474995024.git.pabeni@redhat.com>
         <bc55b0885e0f93895c211168561a6b3403bade10.1474995024.git.pabeni@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2016-09-27 at 18:58 +0200, Paolo Abeni wrote:


> 
> Since the new memory accounting model does not require socket
> locking, remove the lock on enqueue and free and avoid using the
> backlog on enqueue.


...

>  	__UDP_INC_STATS(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
> @@ -2345,6 +2325,7 @@ struct proto udp_prot = {
>  	.connect	   = ip4_datagram_connect,
>  	.disconnect	   = udp_disconnect,
>  	.ioctl		   = udp_ioctl,
> +	.init		   = udp_init_sock,
>  	.destroy	   = udp_destroy_sock,
>  	.setsockopt	   = udp_setsockopt,
>  	.getsockopt	   = udp_getsockopt,
> @@ -2357,7 +2338,10 @@ struct proto udp_prot = {
>  	.unhash		   = udp_lib_unhash,
>  	.rehash		   = udp_v4_rehash,
>  	.get_port	   = udp_v4_get_port,
> +	.enter_memory_pressure = udp_enter_memory_pressure,
> +	.sockets_allocated = &udp_sockets_allocated,
>  	.memory_allocated  = &udp_memory_allocated,
> +	.memory_pressure   = &udp_memory_pressure,
>  	.sysctl_mem	   = sysctl_udp_mem,
>  	.sysctl_wmem	   = &sysctl_udp_wmem_min,
>  	.sysctl_rmem	   = &sysctl_udp_rmem_min,


I find disturbing you did not remove 

	.backlog_rcv       = __udp_queue_rcv_skb,


