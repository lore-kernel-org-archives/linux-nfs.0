Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35674 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932965AbcJUVNp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Oct 2016 17:13:45 -0400
Message-ID: <1477084423.7065.88.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH net-next v6 2/3] udp: implement memory accounting helpers
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
Date: Fri, 21 Oct 2016 14:13:43 -0700
In-Reply-To: <4d2e0fc8f5c3d1309b0fb71bc65a2719a8e82825.1477043395.git.pabeni@redhat.com>
References: <cover.1477043395.git.pabeni@redhat.com>
         <4d2e0fc8f5c3d1309b0fb71bc65a2719a8e82825.1477043395.git.pabeni@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-10-21 at 13:55 +0200, Paolo Abeni wrote:
> Avoid using the generic helpers.
> Use the receive queue spin lock to protect the memory
> accounting operation, both on enqueue and on dequeue.
> 
> On dequeue perform partial memory reclaiming, trying to
> leave a quantum of forward allocated memory.
> 
> On enqueue use a custom helper, to allow some optimizations:
> - use a plain spin_lock() variant instead of the slightly
>   costly spin_lock_irqsave(),
> - avoid dst_force check, since the calling code has already
>   dropped the skb dst
> - avoid orphaning the skb, since skb_steal_sock() already did
>   the work for us
> 
> The above needs custom memory reclaiming on shutdown, provided
> by the udp_destruct_sock().

Acked-by: Eric Dumazet <edumazet@google.com>


