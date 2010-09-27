Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:30031 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753079Ab0I0KJt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Sep 2010 06:09:49 -0400
Message-ID: <4CA06D62.4040703@parallels.com>
Date: Mon, 27 Sep 2010 14:09:38 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 7/8] net: Export __sock_create
References: <4CA06C7A.5060307@parallels.com>
In-Reply-To: <4CA06C7A.5060307@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Can we can do it not through the Dave's tree?

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/linux/net.h |    2 ++
 net/socket.c        |    3 ++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index dee0b11..16faa13 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -229,6 +229,8 @@ enum {
 extern int	     sock_wake_async(struct socket *sk, int how, int band);
 extern int	     sock_register(const struct net_proto_family *fam);
 extern void	     sock_unregister(int family);
+extern int	     __sock_create(struct net *net, int family, int type, int proto,
+				 struct socket **res, int kern);
 extern int	     sock_create(int family, int type, int proto,
 				 struct socket **res);
 extern int	     sock_create_kern(int family, int type, int proto,
diff --git a/net/socket.c b/net/socket.c
index 2270b94..0c37b00 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1144,7 +1144,7 @@ call_kill:
 }
 EXPORT_SYMBOL(sock_wake_async);
 
-static int __sock_create(struct net *net, int family, int type, int protocol,
+int __sock_create(struct net *net, int family, int type, int protocol,
 			 struct socket **res, int kern)
 {
 	int err;
@@ -1256,6 +1256,7 @@ out_release:
 	rcu_read_unlock();
 	goto out_sock_release;
 }
+EXPORT_SYMBOL(__sock_create);
 
 int sock_create(int family, int type, int protocol, struct socket **res)
 {
-- 
1.5.5.6

