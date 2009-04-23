From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/19] SUNRPC: Support PF_INET6 in one_sock_name()
Date: Thu, 23 Apr 2009 19:32:55 -0400
Message-ID: <20090423233255.17283.6145.stgit@ingres.1015granger.net>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:46610 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756217AbZDWXeh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 19:34:37 -0400
In-Reply-To: <20090423231550.17283.24432.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add an arm to the switch statement in svc_one_sock_name() so it can
construct the name of PF_INET6 sockets properly.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aime Le Rouzic <aime.le-rouzic@bull.net>
---

 net/sunrpc/svcsock.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 61d4a32..983bfa9 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -252,6 +252,13 @@ static int svc_one_sock_name(struct svc_sock *svsk, char *buf, int remaining)
 			      &inet_sk(svsk->sk_sk)->rcv_saddr,
 			      inet_sk(svsk->sk_sk)->num);
 		break;
+	case PF_INET6:
+		len = snprintf(buf, remaining, "ipv6 %s %pI6 %d\n",
+				svsk->sk_sk->sk_protocol == IPPROTO_UDP ?
+				"udp" : "tcp",
+				&inet6_sk(svsk->sk_sk)->rcv_saddr,
+				inet_sk(svsk->sk_sk)->num);
+		break;
 	default:
 		len = snprintf(buf, remaining, "*unknown-%d*\n",
 			       svsk->sk_sk->sk_family);

