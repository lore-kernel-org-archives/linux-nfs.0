Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailx.hitachi.co.jp ([133.145.228.49]:37813 "EHLO
	mailx.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753653Ab1IBDow (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Sep 2011 23:44:52 -0400
From: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
Subject: [PATCH net-next-2.6 ] Fix overflow of socket buffer in sunrpc
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        "David S. Miller" <davem@davemloft.net>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, yrl.pp-manager.tt@hitachi.com,
        Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        "David S. Miller" <davem@davemloft.net>
Date: Fri, 02 Sep 2011 12:41:38 +0900
Message-ID: <20110902034138.22595.9759.stgit@ltc219.sdl.hitachi.co.jp>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The sk_sndbuf and sk_rcvbuf fields of struct sock are sizes of send and
receive socket buffers respectively, and are defined as integer.
The sunrpc which is used in NFSD and any other applications can change them
via svc_sock_setbufsize(). It, however, sets them as unsigned integer and
may cause overflow of integer. This leads to a degradation of networking
capability.

This patch adds integer-overflow check into svc_sock_setbufsize() before
both fields are set, and limits their maximum sizes to INT_MAX.

Signed-off-by: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Neil Brown <neilb@suse.de>
Cc: "David S. Miller" <davem@davemloft.net>
---

 net/sunrpc/svcsock.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 767d494..bd66775 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -54,6 +54,7 @@
 #include "sunrpc.h"
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
+#define MAX_SKBUFSIZ	INT_MAX
 
 
 static struct svc_sock *svc_setup_socket(struct svc_serv *, struct socket *,
@@ -435,6 +436,11 @@ static void svc_sock_setbufsize(struct socket *sock, unsigned int snd,
 	 * on not having CAP_SYS_RESOURCE or similar, we go direct...
 	 * DaveM said I could!
 	 */
+	if (snd > MAX_SKBUFSIZ/2)
+		snd = MAX_SKBUFSIZ/2;
+	if (rcv > MAX_SKBUFSIZ/2)
+		rcv = MAX_SKBUFSIZ/2;
+
 	lock_sock(sock->sk);
 	sock->sk->sk_sndbuf = snd * 2;
 	sock->sk->sk_rcvbuf = rcv * 2;

