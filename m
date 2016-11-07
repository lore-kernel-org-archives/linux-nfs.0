Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39406 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932846AbcKGSZa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Nov 2016 13:25:30 -0500
Date: Mon, 07 Nov 2016 13:24:58 -0500 (EST)
Message-Id: <20161107.132458.256635426505538931.davem@davemloft.net>
To: pabeni@redhat.com
Cc: netdev@vger.kernel.org, edumazet@google.com,
        hannes@stressinduktion.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH net-next 0/2] udp: do fwd memory scheduling on dequeue
From: David Miller <davem@davemloft.net>
In-Reply-To: <cover.1478254512.git.pabeni@redhat.com>
References: <cover.1478254512.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Fri,  4 Nov 2016 11:28:57 +0100

> After commit 850cbaddb52d ("udp: use it's own memory accounting schema"),
> the udp code needs to acquire twice the receive queue spinlock on dequeue.
> 
> This patch series remove the need for the second lock at skb free time,
> moving the udp memory scheduling inside the dequeue operation; the skb
> destructor field is not used anymore and an additional sk argument is added
> to ip_cmsg_recv_offset() to cope with null skb->sk after dequeue.
> 
> Many thanks to Eric Dumazed for suggesting pretty all much the above.

Series applied, thanks.
