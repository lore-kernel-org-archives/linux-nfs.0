Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 62.175.99.172.dyn.user.ono.com ([62.175.99.172]:45248 "EHLO
        thunder.hadrons.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751888AbeAJB1i (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jan 2018 20:27:38 -0500
From: Guillem Jover <gjover@sipwise.com>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] Do not bind to reserved ports registered in /etc/services
Date: Wed, 10 Jan 2018 01:49:20 +0100
Message-Id: <20180110004920.11100-1-gjover@sipwise.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When using the bindresvport() function a privileged port will be looked
for and bound to a socket. The problem is that any service using a static
privileged port registered in the /etc/services file, can get its port
taken over by libtirpc users, making the other service fail to start.

Starting the other service before libtircp users is not an option as
this does not cover restart situations, for example during package
upgrades or HA switchovers and similar.

In addition honoring the /etc/services registry is already done for
example by rpc.statd, so it seems obvious to make libtirpc follow this
same pattern too.

Signed-off-by: Guillem Jover <gjover@sipwise.com>
---
 src/bindresvport.c | 28 +++++++++++++++++++++++++++-
 1 file changed, 27 insertions(+), 1 deletion(-)

diff --git a/src/bindresvport.c b/src/bindresvport.c
index 2d8f2bc..98e5f40 100644
--- a/src/bindresvport.c
+++ b/src/bindresvport.c
@@ -40,6 +40,7 @@
 #include <netinet/in.h>
 
 #include <errno.h>
+#include <netdb.h>
 #include <string.h>
 #include <unistd.h>
 
@@ -73,12 +74,15 @@ bindresvport_sa(sd, sa)
         int sd;
         struct sockaddr *sa;
 {
-        int res, af;
+        int res, af, so_proto;
+        socklen_t so_proto_len;
         struct sockaddr_storage myaddr;
 	struct sockaddr_in *sin;
 #ifdef INET6
 	struct sockaddr_in6 *sin6;
 #endif
+	struct servent *se;
+	const char *se_proto;
 	u_int16_t *portp;
 	static u_int16_t port;
 	static short startport = STARTPORT;
@@ -125,6 +129,25 @@ bindresvport_sa(sd, sa)
         }
         sa->sa_family = af;
 
+        so_proto_len = sizeof(so_proto);
+        if (getsockopt(sd, SOL_SOCKET, SO_PROTOCOL, &so_proto, &so_proto_len) == -1) {
+                mutex_unlock(&port_lock);
+                return -1;      /* errno is correctly set */
+        }
+        switch (so_proto) {
+        case IPPROTO_UDP:
+        case IPPROTO_UDPLITE:
+                se_proto = "udp";
+                break;
+        case IPPROTO_TCP:
+                se_proto = "tcp";
+                break;
+        default:
+                errno = ENOPROTOOPT;
+                mutex_unlock(&port_lock);
+                return -1;
+        }
+
         if (port == 0) {
                 port = (getpid() % NPORTS) + STARTPORT;
         }
@@ -135,6 +158,9 @@ bindresvport_sa(sd, sa)
                 *portp = htons(port++);
                  if (port > endport) 
                         port = startport;
+                se = getservbyport(*portp, se_proto);
+                if (se != NULL)
+                        continue;
                 res = bind(sd, sa, salen);
 		if (res >= 0 || errno != EADDRINUSE)
 	                break;
-- 
2.15.1

