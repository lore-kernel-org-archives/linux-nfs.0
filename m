Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15962 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755125Ab2JPQbL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 12:31:11 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 15/25] SUNRPC: remove BUG_ON()s from *_reclassify_socket*
Date: Tue, 16 Oct 2012 12:30:33 -0400
Message-Id: <1350405043-39316-15-git-send-email-dros@netapp.com>
In-Reply-To: <1350405043-39316-1-git-send-email-dros@netapp.com>
References: <1350405043-39316-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace multiple BUG_ON() calls with WARN_ON_ONCE() and early return when
sanity checking socket ownership (lock). The bind call will fail if the
socket was unsuccessfully reclassified.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/svcsock.c  |    6 +++++-
 net/sunrpc/xprtsock.c |    7 ++++---
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 03827ce..cc3020d 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -84,7 +84,11 @@ static struct lock_class_key svc_slock_key[2];
 static void svc_reclassify_socket(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
-	BUG_ON(sock_owned_by_user(sk));
+
+	WARN_ON_ONCE(sock_owned_by_user(sk));
+	if (sock_owned_by_user(sk))
+		return;
+
 	switch (sk->sk_family) {
 	case AF_INET:
 		sock_lock_init_class_and_name(sk, "slock-AF_INET-NFSD",
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index aaaadfb..4e76d38 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1762,7 +1762,6 @@ static inline void xs_reclassify_socketu(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 
-	BUG_ON(sock_owned_by_user(sk));
 	sock_lock_init_class_and_name(sk, "slock-AF_LOCAL-RPC",
 		&xs_slock_key[1], "sk_lock-AF_LOCAL-RPC", &xs_key[1]);
 }
@@ -1771,7 +1770,6 @@ static inline void xs_reclassify_socket4(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 
-	BUG_ON(sock_owned_by_user(sk));
 	sock_lock_init_class_and_name(sk, "slock-AF_INET-RPC",
 		&xs_slock_key[0], "sk_lock-AF_INET-RPC", &xs_key[0]);
 }
@@ -1780,13 +1778,16 @@ static inline void xs_reclassify_socket6(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 
-	BUG_ON(sock_owned_by_user(sk));
 	sock_lock_init_class_and_name(sk, "slock-AF_INET6-RPC",
 		&xs_slock_key[1], "sk_lock-AF_INET6-RPC", &xs_key[1]);
 }
 
 static inline void xs_reclassify_socket(int family, struct socket *sock)
 {
+	WARN_ON_ONCE(sock_owned_by_user(sock->sk));
+	if (sock_owned_by_user(sock->sk))
+		return;
+
 	switch (family) {
 	case AF_LOCAL:
 		xs_reclassify_socketu(sock);
-- 
1.7.9.6 (Apple Git-31.1)

