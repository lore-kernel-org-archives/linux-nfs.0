From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH] svcsock: Add a reference to sunrpc in svc_addsock
Date: Sun, 23 Nov 2008 08:08:36 -0600
Message-ID: <1227449316-27946-1-git-send-email-tom@opengridcomputing.com>
Cc: jlayton@redhat.com, jmoyer@redhat.com, linux-nfs@vger.kernel.org,
	Tom Tucker <tom@opengridcomputing.com>
To: tom@opengridcomputing.com, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:43718 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758210AbYKWOIg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Nov 2008 09:08:36 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The svc_addsock function adds transport instances without taking a
reference on the sunrpc.ko module, however, the generic transport
destruction code drops a reference when a transport instance
is destroyed.

Add a try_module_get call to the svc_addsock function for transport
instances added by this function.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
 net/sunrpc/svcsock.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 95293f5..a1951dc 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1183,7 +1183,11 @@ int svc_addsock(struct svc_serv *serv,
 	else if (so->state > SS_UNCONNECTED)
 		err = -EISCONN;
 	else {
-		svsk = svc_setup_socket(serv, so, &err, SVC_SOCK_DEFAULTS);
+		if (!try_module_get(THIS_MODULE))
+			err = -ENOENT;
+		else
+			svsk = svc_setup_socket(serv, so, &err,
+						SVC_SOCK_DEFAULTS);
 		if (svsk) {
 			struct sockaddr_storage addr;
 			struct sockaddr *sin = (struct sockaddr *)&addr;
@@ -1196,7 +1200,8 @@ int svc_addsock(struct svc_serv *serv,
 			spin_unlock_bh(&serv->sv_lock);
 			svc_xprt_received(&svsk->sk_xprt);
 			err = 0;
-		}
+		} else
+			module_put(THIS_MODULE);
 	}
 	if (err) {
 		sockfd_put(so);
