From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/23] SUNRPC: Support PF_INET6 in one_sock_name()
Date: Thu, 05 Mar 2009 16:33:16 -0500
Message-ID: <20090305213315.21342.58441.stgit@ingres.1015granger.net>
References: <20090305212823.21342.38352.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:36094 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754207AbZCEVdj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 16:33:39 -0500
In-Reply-To: <20090305212823.21342.38352.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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
index a1bf142..6d19ef3 100644
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

