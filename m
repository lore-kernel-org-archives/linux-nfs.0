Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35218 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752855AbcI1KxG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Sep 2016 06:53:06 -0400
From: Paolo Abeni <pabeni@redhat.com>
To: netdev@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>, Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Edward Cree <ecree@solarflare.com>, linux-nfs@vger.kernel.org
Subject: [PATCH net-next v3 0/3] udp: refactor memory accounting
Date: Wed, 28 Sep 2016 12:52:50 +0200
Message-Id: <cover.1475048434.git.pabeni@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch series refactor the udp memory accounting, replacing the
generic implementation with a custom one, in order to remove the needs for
locking the socket on the enqueue and dequeue operations. The socket backlog
usage is dropped, as well.

The first patch factor out core pieces of some queue and memory management
socket helpers, so that they can later be used by the udp memory accounting
functions.
The second patch adds the memory account helpers, without using them.
The third patch replacse the old rx memory accounting path for udp over ipv4 and
udp over ipv6. In kernel UDP users are updated, as well.

The memory accounting schema is described in detail in the individual patch
commit message.

The performance gain depends on the specific scenario; with few flows (and
little contention in the original code) the differences are in the noise range,
while with several flows contending the same socket, the measured speed-up
is relevant (e.g. even over 100% in case of extreme contention)

v2 -> v3:
 - do not set the now unsed backlog_rcv callback

v1 -> v2:
 - changed slighly the memory accounting schema, we now perform lazy reclaim
 - fixed forward_alloc updating issue
 - fixed memory counter integer overflows

Paolo Abeni (3):
  net/socket: factor out helpers for memory and queue manipulation
  udp: implement memory accounting helpers
  udp: use it's own memory accounting schema

 include/linux/udp.h   |   2 +
 include/net/sock.h    |   5 ++
 include/net/udp.h     |   7 ++
 net/core/datagram.c   |  36 ++++++----
 net/core/sock.c       |  96 ++++++++++++++++++---------
 net/ipv4/udp.c        | 179 ++++++++++++++++++++++++++++++++++++++++++--------
 net/ipv6/udp.c        |  33 ++++------
 net/sunrpc/svcsock.c  |  20 ++++--
 net/sunrpc/xprtsock.c |   2 +-
 9 files changed, 279 insertions(+), 101 deletions(-)

-- 
1.8.3.1

