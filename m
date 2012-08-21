Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46790 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752126Ab2HUU5e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 16:57:34 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 02/14] svcrpc: clean up control flow
Date: Tue, 21 Aug 2012 16:57:20 -0400
Message-Id: <1345582652-18476-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1345582652-18476-1-git-send-email-bfields@redhat.com>
References: <1345582652-18476-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Mainly, use the kernel standard

	err = -ERROR;
	if (something_bad)
		goto out;
	normal case;

rather than

	if (something_bad)
		err = -ERROR
	else {
		normal case;
	}

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svcsock.c |   69 +++++++++++++++++++++++++-------------------------
 1 file changed, 34 insertions(+), 35 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index d028b51..bf10b72 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1451,44 +1451,42 @@ int svc_addsock(struct svc_serv *serv, const int fd, char *name_return,
 	int err = 0;
 	struct socket *so = sockfd_lookup(fd, &err);
 	struct svc_sock *svsk = NULL;
+	struct sockaddr_storage addr;
+	struct sockaddr *sin = (struct sockaddr *)&addr;
+	int salen;
 
 	if (!so)
 		return err;
+	err = -EAFNOSUPPORT;
 	if ((so->sk->sk_family != PF_INET) && (so->sk->sk_family != PF_INET6))
-		err =  -EAFNOSUPPORT;
-	else if (so->sk->sk_protocol != IPPROTO_TCP &&
+		goto out;
+	err =  -EPROTONOSUPPORT;
+	if (so->sk->sk_protocol != IPPROTO_TCP &&
 	    so->sk->sk_protocol != IPPROTO_UDP)
-		err =  -EPROTONOSUPPORT;
-	else if (so->state > SS_UNCONNECTED)
-		err = -EISCONN;
-	else {
-		if (!try_module_get(THIS_MODULE))
-			err = -ENOENT;
-		else {
-			svsk = svc_setup_socket(serv, so, SVC_SOCK_DEFAULTS);
-			if (IS_ERR(svsk))
-				err = PTR_ERR(svsk);
-		}
-		if (err == 0) {
-			struct sockaddr_storage addr;
-			struct sockaddr *sin = (struct sockaddr *)&addr;
-			int salen;
-			if (kernel_getsockname(svsk->sk_sock, sin, &salen) == 0)
-				svc_xprt_set_local(&svsk->sk_xprt, sin, salen);
-			clear_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags);
-			spin_lock_bh(&serv->sv_lock);
-			list_add(&svsk->sk_xprt.xpt_list, &serv->sv_permsocks);
-			spin_unlock_bh(&serv->sv_lock);
-			svc_xprt_received(&svsk->sk_xprt);
-			err = 0;
-		} else
-			module_put(THIS_MODULE);
-	}
-	if (err) {
-		sockfd_put(so);
-		return err;
+		goto out;
+	err = -EISCONN;
+	if (so->state > SS_UNCONNECTED)
+		goto out;
+	err = -ENOENT;
+	if (!try_module_get(THIS_MODULE))
+		goto out;
+	svsk = svc_setup_socket(serv, so, SVC_SOCK_DEFAULTS);
+	if (IS_ERR(svsk)) {
+		module_put(THIS_MODULE);
+		err = PTR_ERR(svsk);
+		goto out;
 	}
+	if (kernel_getsockname(svsk->sk_sock, sin, &salen) == 0)
+		svc_xprt_set_local(&svsk->sk_xprt, sin, salen);
+	clear_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags);
+	spin_lock_bh(&serv->sv_lock);
+	list_add(&svsk->sk_xprt.xpt_list, &serv->sv_permsocks);
+	spin_unlock_bh(&serv->sv_lock);
+	svc_xprt_received(&svsk->sk_xprt);
 	return svc_one_sock_name(svsk, name_return, len);
+out:
+	sockfd_put(so);
+	return err;
 }
 EXPORT_SYMBOL_GPL(svc_addsock);
 
@@ -1567,11 +1565,12 @@ static struct svc_xprt *svc_create_socket(struct svc_serv *serv,
 	}
 
 	svsk = svc_setup_socket(serv, sock, flags);
-	if (!IS_ERR(svsk)) {
-		svc_xprt_set_local(&svsk->sk_xprt, newsin, newlen);
-		return (struct svc_xprt *)svsk;
+	if (IS_ERR(svsk)) {
+		error = PTR_ERR(svsk);
+		goto bummer;
 	}
-	error = PTR_ERR(svsk);
+	svc_xprt_set_local(&svsk->sk_xprt, newsin, newlen);
+	return (struct svc_xprt *)svsk;
 bummer:
 	dprintk("svc: svc_create_socket error = %d\n", -error);
 	sock_release(sock);
-- 
1.7.9.5

