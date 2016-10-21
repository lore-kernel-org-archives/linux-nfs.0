Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34709 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932965AbcJUVOk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Oct 2016 17:14:40 -0400
Message-ID: <1477084478.7065.89.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH net-next v6 3/3] udp: use it's own memory accounting
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
Date: Fri, 21 Oct 2016 14:14:38 -0700
In-Reply-To: <530de0874eb7bbe1dbdaa4e8ccbb56d917ee598f.1477043395.git.pabeni@redhat.com>
References: <cover.1477043395.git.pabeni@redhat.com>
         <530de0874eb7bbe1dbdaa4e8ccbb56d917ee598f.1477043395.git.pabeni@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-10-21 at 13:55 +0200, Paolo Abeni wrote:
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
> 1               170             440

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks a lot guys.


