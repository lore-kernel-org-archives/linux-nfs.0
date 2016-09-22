Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35523 "EHLO
        mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757854AbcIVQav (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 12:30:51 -0400
Message-ID: <1474561848.23058.133.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH net-next 2/3] udp: implement memory accounting helpers
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Paolo Abeni <pabeni@redhat.com>
Cc: Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>, Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        linux-nfs@vger.kernel.org
Date: Thu, 22 Sep 2016 09:30:48 -0700
In-Reply-To: <1474560864.4845.78.camel@redhat.com>
References: <cover.1474477902.git.pabeni@redhat.com>
         <93ccb49b7f037461ef436a50b907185744b093d8.1474477902.git.pabeni@redhat.com>
         <1474500682.23058.88.camel@edumazet-glaptop3.roam.corp.google.com>
         <1474540415.4845.69.camel@redhat.com>
         <589839b3-5930-2527-b0a3-315be254a175@solarflare.com>
         <1474560864.4845.78.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-09-22 at 18:14 +0200, Paolo Abeni wrote:

> I think that the idea behind using atomic ops directly on
> sk_forward_alloc is to avoid adding other fields to the udp_socket. 
> 
> If we can add some fields to the udp_sock structure, the schema proposed
> in this patch should fit better (modulo bugs ;-), always requiring a
> single atomic operation at memory reclaiming time and at memory
> allocation time.

But do we want any additional atomic to begin with ?

Given typical number of UDP sockets on a host, we could reserve/forward
alloc at socket creation time, and when SO_RCVBUF is changed.

I totally understand that this schem does not work with TCP, because TCP
BDP mandates xx MB of buffers per socket, and we really handle millions
of TCP sockets per host,

But for UDP, most applications are working well with a default limit,
and we hardly have more than 1000 UDP sockets.

cat /proc/sys/net/core/rmem_default
212992



