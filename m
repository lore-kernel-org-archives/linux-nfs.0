Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33447 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755967AbcKDMia (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2016 08:38:30 -0400
Message-ID: <1478263108.7065.460.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH net-next v2 2/2] udp: do fwd memory scheduling on dequeue
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Paolo Abeni <pabeni@redhat.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        linux-nfs@vger.kernel.org
Date: Fri, 04 Nov 2016 05:38:28 -0700
In-Reply-To: <762f142043b48daf282316dd88ff099fbd9729e4.1478254512.git.pabeni@redhat.com>
References: <cover.1478254512.git.pabeni@redhat.com>
         <762f142043b48daf282316dd88ff099fbd9729e4.1478254512.git.pabeni@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-11-04 at 11:28 +0100, Paolo Abeni wrote:
> A new argument is added to __skb_recv_datagram to provide
> an explicit skb destructor, invoked under the receive queue
> lock.
> The UDP protocol uses such argument to perform memory
> reclaiming on dequeue, so that the UDP protocol does not
> set anymore skb->desctructor.
> Instead explicit memory reclaiming is performed at close() time and
> when skbs are removed from the receive queue.
> The in kernel UDP protocol users now need to call a
> skb_recv_udp() variant instead of skb_recv_datagram() to
> properly perform memory accounting on dequeue.
> 
> Overall, this allows acquiring only once the receive queue
> lock on dequeue.
> 
> Tested using pktgen with random src port, 64 bytes packet,
> wire-speed on a 10G link as sender and udp_sink as the receiver,
> using an l4 tuple rxhash to stress the contention, and one or more
> udp_sink instances with reuseport.
> 
> nr sinks	vanilla		patched
> 1		440		560
> 3		2150		2300
> 6		3650		3800
> 9		4450		4600
> 12		6250		6450
> 
> v1 -> v2:
>  - do rmem and allocated memory scheduling under the receive lock
>  - do bulk scheduling in first_packet_length() and in udp_destruct_sock()
>  - avoid the typdef for the dequeue callback
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
> @Eric, please add your signed off by when you feel comfortable with the patch
> as you authored some of the code

SGTM, thanks Paolo and Hannes !

Acked-by: Eric Dumazet <edumazet@google.com>


