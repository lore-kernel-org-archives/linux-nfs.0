Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46794 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753103Ab2HUU5f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 16:57:35 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 04/14] svcrpc: share some setup of listening sockets
Date: Tue, 21 Aug 2012 16:57:22 -0400
Message-Id: <1345582652-18476-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1345582652-18476-1-git-send-email-bfields@redhat.com>
References: <1345582652-18476-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

There's some duplicate code here.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 include/linux/sunrpc/svc_xprt.h |    1 +
 net/sunrpc/svc_xprt.c           |   16 ++++++++++------
 net/sunrpc/svcsock.c            |    6 +-----
 3 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index b3f64b1..73c7a68 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -124,6 +124,7 @@ struct	svc_xprt *svc_find_xprt(struct svc_serv *serv, const char *xcl_name,
 			struct net *net, const sa_family_t af,
 			const unsigned short port);
 int	svc_xprt_names(struct svc_serv *serv, char *buf, const int buflen);
+void	svc_add_new_perm_xprt(struct svc_serv *serv, struct svc_xprt *xprt);
 
 static inline void svc_xprt_get(struct svc_xprt *xprt)
 {
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 4801fda..ee15663 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -208,6 +208,15 @@ static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
 	return xcl->xcl_ops->xpo_create(serv, net, sap, len, flags);
 }
 
+void svc_add_new_perm_xprt(struct svc_serv *serv, struct svc_xprt *new)
+{
+	clear_bit(XPT_TEMP, &new->xpt_flags);
+	spin_lock_bh(&serv->sv_lock);
+	list_add(&new->xpt_list, &serv->sv_permsocks);
+	spin_unlock_bh(&serv->sv_lock);
+	svc_xprt_received(new);
+}
+
 int svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
 		    struct net *net, const int family,
 		    const unsigned short port, int flags)
@@ -232,13 +241,8 @@ int svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
 			module_put(xcl->xcl_owner);
 			return PTR_ERR(newxprt);
 		}
-
-		clear_bit(XPT_TEMP, &newxprt->xpt_flags);
-		spin_lock_bh(&serv->sv_lock);
-		list_add(&newxprt->xpt_list, &serv->sv_permsocks);
-		spin_unlock_bh(&serv->sv_lock);
+		svc_add_new_perm_xprt(serv, newxprt);
 		newport = svc_xprt_local_port(newxprt);
-		svc_xprt_received(newxprt);
 		return newport;
 	}
  err:
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index bf10b72..c7a7b14 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1478,11 +1478,7 @@ int svc_addsock(struct svc_serv *serv, const int fd, char *name_return,
 	}
 	if (kernel_getsockname(svsk->sk_sock, sin, &salen) == 0)
 		svc_xprt_set_local(&svsk->sk_xprt, sin, salen);
-	clear_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags);
-	spin_lock_bh(&serv->sv_lock);
-	list_add(&svsk->sk_xprt.xpt_list, &serv->sv_permsocks);
-	spin_unlock_bh(&serv->sv_lock);
-	svc_xprt_received(&svsk->sk_xprt);
+	svc_add_new_perm_xprt(serv, &svsk->sk_xprt);
 	return svc_one_sock_name(svsk, name_return, len);
 out:
 	sockfd_put(so);
-- 
1.7.9.5

