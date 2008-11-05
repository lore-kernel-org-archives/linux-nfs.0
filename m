From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/13] SUNRPC: Clean up one_sock_name()
Date: Wed, 05 Nov 2008 12:29:28 -0500
Message-ID: <20081105172928.7330.38614.stgit@ingres.1015granger.net>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:36950 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752859AbYKERaU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:30:20 -0500
In-Reply-To: <20081105172351.7330.50739.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up svc_one_sock_name() by setting up automatic variables for
frequently used expressions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svcsock.c |   26 +++++++++++++++-----------
 1 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 98cee11..62d65bb 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -246,26 +246,30 @@ out:
  */
 static int svc_one_sock_name(struct svc_sock *svsk, char *buf, int remaining)
 {
+	struct sock *sk = svsk->sk_sk;
+	char *proto_name;
 	int len;
 
-	switch(svsk->sk_sk->sk_family) {
+	proto_name = "tcp";
+	if (sk->sk_protocol == IPPROTO_UDP)
+		proto_name = "udp";
+
+	switch (sk->sk_family) {
 	case AF_INET:
-		len = snprintf(buf, remaining, "ipv4 %s %u.%u.%u.%u %d\n",
-			      svsk->sk_sk->sk_protocol==IPPROTO_UDP?
-			      "udp" : "tcp",
-			      NIPQUAD(inet_sk(svsk->sk_sk)->rcv_saddr),
-			      inet_sk(svsk->sk_sk)->num);
+		len = snprintf(buf, remaining, "ipv4 %s " NIPQUAD_FMT " %d\n",
+				proto_name,
+				NIPQUAD(inet_sk(sk)->rcv_saddr),
+				inet_sk(sk)->num);
 		break;
 	case AF_INET6:
 		len = snprintf(buf, remaining, "ipv6 %s " NIP6_FMT " %d\n",
-				svsk->sk_sk->sk_protocol == IPPROTO_UDP ?
-				"udp" : "tcp",
-				NIP6(inet6_sk(svsk->sk_sk)->rcv_saddr),
-				inet_sk(svsk->sk_sk)->num);
+				proto_name,
+				NIP6(inet6_sk(sk)->rcv_saddr),
+				inet_sk(sk)->num);
 		break;
 	default:
 		len = snprintf(buf, remaining, "*unknown-%d*\n",
-			       svsk->sk_sk->sk_family);
+				sk->sk_family);
 	}
 
 	if (len >= remaining) {

