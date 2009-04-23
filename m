From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/19] SUNRPC: Switch one_sock_name() to use snprintf()
Date: Thu, 23 Apr 2009 19:32:48 -0400
Message-ID: <20090423233247.17283.89259.stgit@ingres.1015granger.net>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:26936 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756622AbZDWXej (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 19:34:39 -0400
In-Reply-To: <20090423231550.17283.24432.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use snprintf() in one_sock_name() to prevent overflowing the output
buffer.  If the name doesn't fit in the buffer, the buffer is filled
in with an empty string, and -ENAMETOOLONG is returned.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svcsock.c |   25 ++++++++++++++++++-------
 1 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 032b52e..61d4a32 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -240,22 +240,27 @@ out:
 /*
  * Report socket names for nfsdfs
  */
-static int one_sock_name(char *buf, struct svc_sock *svsk)
+static int svc_one_sock_name(struct svc_sock *svsk, char *buf, int remaining)
 {
 	int len;
 
 	switch(svsk->sk_sk->sk_family) {
-	case AF_INET:
-		len = sprintf(buf, "ipv4 %s %pI4 %d\n",
+	case PF_INET:
+		len = snprintf(buf, remaining, "ipv4 %s %pI4 %d\n",
 			      svsk->sk_sk->sk_protocol == IPPROTO_UDP ?
 			      "udp" : "tcp",
 			      &inet_sk(svsk->sk_sk)->rcv_saddr,
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
 
@@ -282,15 +287,21 @@ int svc_sock_names(struct svc_serv *serv, char *buf, const size_t buflen,
 
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
@@ -1195,7 +1206,7 @@ int svc_addsock(struct svc_serv *serv, const int fd, char *name_return,
 		sockfd_put(so);
 		return err;
 	}
-	return one_sock_name(name_return, svsk);
+	return svc_one_sock_name(svsk, name_return, len);
 }
 EXPORT_SYMBOL_GPL(svc_addsock);
 

