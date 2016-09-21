Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55004 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752360AbcIURX7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Sep 2016 13:23:59 -0400
From: Paolo Abeni <pabeni@redhat.com>
To: netdev@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>, Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        linux-nfs@vger.kernel.org
Subject: [PATCH net-next 0/3] udp: refactor memory accounting
Date: Wed, 21 Sep 2016 19:23:13 +0200
Message-Id: <cover.1474477902.git.pabeni@redhat.com>
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

Paolo Abeni (3):
  net/socket: factor out helpers for memory and queue manipulation
  udp: implement memory accounting helpers
  udp: use it's own memory accounting schema

 include/linux/skbuff.h |   2 +-
 include/linux/udp.h    |   2 +
 include/net/sock.h     |   5 ++
 include/net/udp.h      |   5 ++
 net/core/datagram.c    |  36 ++++++----
 net/core/skbuff.c      |   3 +-
 net/core/sock.c        |  96 ++++++++++++++++---------
 net/ipv4/udp.c         | 190 +++++++++++++++++++++++++++++++++++++++++--------
 net/ipv6/udp.c         |  28 +++-----
 net/sunrpc/svcsock.c   |  22 ++++--
 net/sunrpc/xprtsock.c  |   2 +-
 11 files changed, 290 insertions(+), 101 deletions(-)

-- 
1.8.3.1

