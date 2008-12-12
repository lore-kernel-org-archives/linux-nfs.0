From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/22] SUNRPC: Switch one_sock_name() to use snprintf()
Date: Fri, 12 Dec 2008 16:58:12 -0500
Message-ID: <20081212215812.24332.50090.stgit@ingres.1015granger.net>
References: <20081212215340.24332.88416.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aime.le-rouzic@bull.net, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:36247 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753549AbYLLV6s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Dec 2008 16:58:48 -0500
In-Reply-To: <20081212215340.24332.88416.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use snprintf() in one_sock_name() to help prevent buffer overflows.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svcsock.c |   23 +++++++++++++++++------
 1 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 39f5015..fa11944 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -244,22 +244,27 @@ out:
 /*
  * Report socket names for nfsdfs
  */
-static int one_sock_name(char *buf, struct svc_sock *svsk)
+static int svc_one_sock_name(struct svc_sock *svsk, char *buf, int remaining)
 {
 	int len;
 
 	switch(svsk->sk_sk->sk_family) {
 	case AF_INET:
-		len = sprintf(buf, "ipv4 %s %u.%u.%u.%u %d\n",
+		len = snprintf(buf, remaining, "ipv4 %s %u.%u.%u.%u %d\n",
 			      svsk->sk_sk->sk_protocol==IPPROTO_UDP?
 			      "udp" : "tcp",
 			      NIPQUAD(inet_sk(svsk->sk_sk)->rcv_saddr),
 			      inet_sk(svsk->sk_sk)->num);
 		break;
 	default:
-		len = sprintf(buf, "*unknown-%d*\n",
+		len = snprintf(buf, remaining, "*unknown-%d*\n",
 			       svsk->sk_sk->sk_family);
 	}
+
+	if (len >= remaining) {
+		*buf = '\0';
+		return -ENAMETOOLONG;
+	}
 	return len;
 }
 
@@ -286,15 +291,21 @@ int svc_sock_names(struct svc_serv *serv, char *buf, size_t buflen,
 
 	if (!serv)
 		return 0;
+
 	spin_lock_bh(&serv->sv_lock);
 	list_for_each_entry(svsk, &serv->sv_permsocks, sk_xprt.xpt_list) {
-		int onelen = one_sock_name(buf+len, svsk);
-		if (toclose && strcmp(toclose, buf+len) == 0)
+		int onelen = svc_one_sock_name(svsk, buf + len, buflen - len);
+		if (onelen < 0) {
+			len = onelen;
+			break;
+		}
+		if (toclose && strcmp(toclose, buf + len) == 0)
 			closesk = svsk;
 		else
 			len += onelen;
 	}
 	spin_unlock_bh(&serv->sv_lock);
+
 	if (closesk)
 		/* Should unregister with portmap, but you cannot
 		 * unregister just one protocol...
@@ -1231,7 +1242,7 @@ int svc_addsock(struct svc_serv *serv, int fd, char *name_return, size_t len)
 		sockfd_put(so);
 		return err;
 	}
-	return one_sock_name(name_return, svsk);
+	return svc_one_sock_name(svsk, name_return, len);
 }
 EXPORT_SYMBOL_GPL(svc_addsock);
 

