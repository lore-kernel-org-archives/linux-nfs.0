Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33132 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751414AbcI1Hni (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Sep 2016 03:43:38 -0400
Message-ID: <1475048613.4693.1.camel@redhat.com>
Subject: Re: [PATCH net-next v2 3/3] udp: use it's own memory accounting
 schema
From: Paolo Abeni <pabeni@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>, Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Edward Cree <ecree@solarflare.com>, linux-nfs@vger.kernel.org
Date: Wed, 28 Sep 2016 09:43:33 +0200
In-Reply-To: <1475001734.28155.62.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1474995024.git.pabeni@redhat.com>
         <bc55b0885e0f93895c211168561a6b3403bade10.1474995024.git.pabeni@redhat.com>
         <1475001734.28155.62.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2016-09-27 at 11:42 -0700, Eric Dumazet wrote:
> On Tue, 2016-09-27 at 18:58 +0200, Paolo Abeni wrote:
> 
> 
> > 
> > Since the new memory accounting model does not require socket
> > locking, remove the lock on enqueue and free and avoid using the
> > backlog on enqueue.
> 
> 
> ...
> 
> >  	__UDP_INC_STATS(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
> > @@ -2345,6 +2325,7 @@ struct proto udp_prot = {
> >  	.connect	   = ip4_datagram_connect,
> >  	.disconnect	   = udp_disconnect,
> >  	.ioctl		   = udp_ioctl,
> > +	.init		   = udp_init_sock,
> >  	.destroy	   = udp_destroy_sock,
> >  	.setsockopt	   = udp_setsockopt,
> >  	.getsockopt	   = udp_getsockopt,
> > @@ -2357,7 +2338,10 @@ struct proto udp_prot = {
> >  	.unhash		   = udp_lib_unhash,
> >  	.rehash		   = udp_v4_rehash,
> >  	.get_port	   = udp_v4_get_port,
> > +	.enter_memory_pressure = udp_enter_memory_pressure,
> > +	.sockets_allocated = &udp_sockets_allocated,
> >  	.memory_allocated  = &udp_memory_allocated,
> > +	.memory_pressure   = &udp_memory_pressure,
> >  	.sysctl_mem	   = sysctl_udp_mem,
> >  	.sysctl_wmem	   = &sysctl_udp_wmem_min,
> >  	.sysctl_rmem	   = &sysctl_udp_rmem_min,
> 
> 
> I find disturbing you did not remove 
> 
> 	.backlog_rcv       = __udp_queue_rcv_skb,

oops, left-over. I'll remove it in v3.

Thank you for pointing it out,

Paolo


