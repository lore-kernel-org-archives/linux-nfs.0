From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/13] SUNRPC: Support AF_INET6 in one_sock_name()
Date: Wed, 05 Nov 2008 12:29:21 -0500
Message-ID: <20081105172921.7330.75374.stgit@ingres.1015granger.net>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:36947 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826AbYKERaT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:30:19 -0500
In-Reply-To: <20081105172351.7330.50739.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add an arm to the switch statement in svc_one_sock_name() so it can
construct the name of PF_INET6 sockets properly.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svcsock.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index db5eb7d..98cee11 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -256,6 +256,13 @@ static int svc_one_sock_name(struct svc_sock *svsk, char *buf, int remaining)
 			      NIPQUAD(inet_sk(svsk->sk_sk)->rcv_saddr),
 			      inet_sk(svsk->sk_sk)->num);
 		break;
+	case AF_INET6:
+		len = snprintf(buf, remaining, "ipv6 %s " NIP6_FMT " %d\n",
+				svsk->sk_sk->sk_protocol == IPPROTO_UDP ?
+				"udp" : "tcp",
+				NIP6(inet6_sk(svsk->sk_sk)->rcv_saddr),
+				inet_sk(svsk->sk_sk)->num);
+		break;
 	default:
 		len = snprintf(buf, remaining, "*unknown-%d*\n",
 			       svsk->sk_sk->sk_family);

