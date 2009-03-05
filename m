From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/23] SUNRPC: Clean up one_sock_name()
Date: Thu, 05 Mar 2009 16:33:23 -0500
Message-ID: <20090305213323.21342.9252.stgit@ingres.1015granger.net>
References: <20090305212823.21342.38352.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:22521 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754265AbZCEVdn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 16:33:43 -0500
In-Reply-To: <20090305212823.21342.38352.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up svc_one_sock_name() by setting up automatic variables for
frequently used expressions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svcsock.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 6d19ef3..2033dfa 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -242,26 +242,27 @@ out:
  */
 static int svc_one_sock_name(struct svc_sock *svsk, char *buf, int remaining)
 {
+	const struct sock *sk = svsk->sk_sk;
+	const char *proto_name = sk->sk_protocol == IPPROTO_UDP ?
+							"udp" : "tcp";
 	int len;
 
-	switch(svsk->sk_sk->sk_family) {
+	switch (sk->sk_family) {
 	case PF_INET:
 		len = snprintf(buf, remaining, "ipv4 %s %pI4 %d\n",
-			      svsk->sk_sk->sk_protocol == IPPROTO_UDP ?
-			      "udp" : "tcp",
-			      &inet_sk(svsk->sk_sk)->rcv_saddr,
-			      inet_sk(svsk->sk_sk)->num);
+				proto_name,
+				&inet_sk(sk)->rcv_saddr,
+				inet_sk(sk)->num);
 		break;
 	case PF_INET6:
 		len = snprintf(buf, remaining, "ipv6 %s %pI6 %d\n",
-				svsk->sk_sk->sk_protocol == IPPROTO_UDP ?
-				"udp" : "tcp",
-				&inet6_sk(svsk->sk_sk)->rcv_saddr,
-				inet_sk(svsk->sk_sk)->num);
+				proto_name,
+				&inet6_sk(sk)->rcv_saddr,
+				inet_sk(sk)->num);
 		break;
 	default:
 		len = snprintf(buf, remaining, "*unknown-%d*\n",
-			       svsk->sk_sk->sk_family);
+				sk->sk_family);
 	}
 
 	if (len >= remaining) {

