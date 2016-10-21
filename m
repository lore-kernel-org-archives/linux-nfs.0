Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33761 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754883AbcJUNli (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Oct 2016 09:41:38 -0400
Message-ID: <1477057295.7065.68.camel@edumazet-glaptop3.roam.corp.google.com>
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
Date: Fri, 21 Oct 2016 06:41:35 -0700
In-Reply-To: <1477056841.4606.36.camel@redhat.com>
References: <cover.1477043395.git.pabeni@redhat.com>
         <4d2e0fc8f5c3d1309b0fb71bc65a2719a8e82825.1477043395.git.pabeni@redhat.com>
         <1477052642.7065.63.camel@edumazet-glaptop3.roam.corp.google.com>
         <1477056841.4606.36.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-10-21 at 15:34 +0200, Paolo Abeni wrote:

> Updating sk_rmem_alloc would still need an atomic operation,
> because it is touched also by the error queue path: we will end up
> adding an atomic operation (or two, when reclaiming the fwd allocated
> memory) inside the critical section. The contention will likely
> increase.
> 
> The above is going to be quite intrusive: we need to pass an
> additional argument all the way up to __skb_try_recv_datagram() and
> change the function behavior according to its value.
> 
> If you are otherwise satisfied with the series in the current shape,
> can't we instead build incrementally on top of it ? it will simplify
> both reviews and re-factor tasks.

I certainly can provide an incremental patch, it might be easier for
both of us ;)



