Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56590 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932203AbcKDK3R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 4 Nov 2016 06:29:17 -0400
From: Paolo Abeni <pabeni@redhat.com>
To: netdev@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        linux-nfs@vger.kernel.org
Subject: [PATCH net-next 0/2] udp: do fwd memory scheduling on dequeue
Date: Fri,  4 Nov 2016 11:28:57 +0100
Message-Id: <cover.1478254512.git.pabeni@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After commit 850cbaddb52d ("udp: use it's own memory accounting schema"),
the udp code needs to acquire twice the receive queue spinlock on dequeue.

This patch series remove the need for the second lock at skb free time,
moving the udp memory scheduling inside the dequeue operation; the skb
destructor field is not used anymore and an additional sk argument is added
to ip_cmsg_recv_offset() to cope with null skb->sk after dequeue.

Many thanks to Eric Dumazed for suggesting pretty all much the above.

Paolo Abeni (2):
  net/sock: add an explicit sk argument for ip_cmsg_recv_offset()
  udp: do fwd memory scheduling on dequeue

 include/linux/skbuff.h |  4 ++++
 include/net/ip.h       |  5 +++--
 include/net/udp.h      | 15 +++++++++++++++
 net/core/datagram.c    | 17 ++++++++++++-----
 net/ipv4/ip_sockglue.c |  6 +++---
 net/ipv4/udp.c         | 44 +++++++++++++++++++++++++-------------------
 net/ipv6/udp.c         |  5 ++---
 net/rxrpc/input.c      |  7 +++----
 net/sunrpc/svcsock.c   |  2 +-
 net/sunrpc/xprtsock.c  |  2 +-
 net/unix/af_unix.c     |  4 ++--
 11 files changed, 71 insertions(+), 40 deletions(-)

-- 
1.8.3.1

