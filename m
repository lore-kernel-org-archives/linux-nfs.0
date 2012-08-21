Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46788 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751725Ab2HUU5e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 16:57:34 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 01/14] svcrpc: standardize svc_setup_socket return convention
Date: Tue, 21 Aug 2012 16:57:19 -0400
Message-Id: <1345582652-18476-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1345582652-18476-1-git-send-email-bfields@redhat.com>
References: <1345582652-18476-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Use the kernel-standard ptr-or-error return convention instead of
passing a pointer to the error.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svcsock.c |   40 ++++++++++++++++++++++------------------
 1 file changed, 22 insertions(+), 18 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 998aa8c..d028b51 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -59,7 +59,7 @@
 
 
 static struct svc_sock *svc_setup_socket(struct svc_serv *, struct socket *,
-					 int *errp, int flags);
+					 int flags);
 static void		svc_udp_data_ready(struct sock *, int);
 static int		svc_udp_recvfrom(struct svc_rqst *);
 static int		svc_udp_sendto(struct svc_rqst *);
@@ -900,8 +900,9 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	 */
 	newsock->sk->sk_sndtimeo = HZ*30;
 
-	if (!(newsvsk = svc_setup_socket(serv, newsock, &err,
-				 (SVC_SOCK_ANONYMOUS | SVC_SOCK_TEMPORARY))))
+	newsvsk = svc_setup_socket(serv, newsock,
+				 (SVC_SOCK_ANONYMOUS | SVC_SOCK_TEMPORARY));
+	if (IS_ERR(newsvsk))
 		goto failed;
 	svc_xprt_set_remote(&newsvsk->sk_xprt, sin, slen);
 	err = kernel_getsockname(newsock, sin, &slen);
@@ -1383,29 +1384,29 @@ EXPORT_SYMBOL_GPL(svc_sock_update_bufs);
  */
 static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 						struct socket *sock,
-						int *errp, int flags)
+						int flags)
 {
 	struct svc_sock	*svsk;
 	struct sock	*inet;
 	int		pmap_register = !(flags & SVC_SOCK_ANONYMOUS);
+	int		err = 0;
 
 	dprintk("svc: svc_setup_socket %p\n", sock);
-	if (!(svsk = kzalloc(sizeof(*svsk), GFP_KERNEL))) {
-		*errp = -ENOMEM;
-		return NULL;
-	}
+	svsk = kzalloc(sizeof(*svsk), GFP_KERNEL);
+	if (!svsk)
+		return ERR_PTR(-ENOMEM);
 
 	inet = sock->sk;
 
 	/* Register socket with portmapper */
-	if (*errp >= 0 && pmap_register)
-		*errp = svc_register(serv, sock_net(sock->sk), inet->sk_family,
+	if (pmap_register)
+		err = svc_register(serv, sock_net(sock->sk), inet->sk_family,
 				     inet->sk_protocol,
 				     ntohs(inet_sk(inet)->inet_sport));
 
-	if (*errp < 0) {
+	if (err < 0) {
 		kfree(svsk);
-		return NULL;
+		return ERR_PTR(err);
 	}
 
 	inet->sk_user_data = svsk;
@@ -1463,10 +1464,12 @@ int svc_addsock(struct svc_serv *serv, const int fd, char *name_return,
 	else {
 		if (!try_module_get(THIS_MODULE))
 			err = -ENOENT;
-		else
-			svsk = svc_setup_socket(serv, so, &err,
-						SVC_SOCK_DEFAULTS);
-		if (svsk) {
+		else {
+			svsk = svc_setup_socket(serv, so, SVC_SOCK_DEFAULTS);
+			if (IS_ERR(svsk))
+				err = PTR_ERR(svsk);
+		}
+		if (err == 0) {
 			struct sockaddr_storage addr;
 			struct sockaddr *sin = (struct sockaddr *)&addr;
 			int salen;
@@ -1563,11 +1566,12 @@ static struct svc_xprt *svc_create_socket(struct svc_serv *serv,
 			goto bummer;
 	}
 
-	if ((svsk = svc_setup_socket(serv, sock, &error, flags)) != NULL) {
+	svsk = svc_setup_socket(serv, sock, flags);
+	if (!IS_ERR(svsk)) {
 		svc_xprt_set_local(&svsk->sk_xprt, newsin, newlen);
 		return (struct svc_xprt *)svsk;
 	}
-
+	error = PTR_ERR(svsk);
 bummer:
 	dprintk("svc: svc_create_socket error = %d\n", -error);
 	sock_release(sock);
-- 
1.7.9.5

