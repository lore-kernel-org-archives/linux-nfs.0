Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37951 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753952Ab3KTQst (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Nov 2013 11:48:49 -0500
From: Susant Sahani <ssahani@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] data race in bindresvport_sa
Date: Wed, 20 Nov 2013 22:19:30 +0530
Message-Id: <1384966173-6229-1-git-send-email-ssahani@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Susant Sahani <ssahani@redhat.com>
---
 src/bindresvport.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/src/bindresvport.c b/src/bindresvport.c
index 6ce3e81..d26d754 100644
--- a/src/bindresvport.c
+++ b/src/bindresvport.c
@@ -46,6 +46,7 @@
 #include <rpc/rpc.h>
 
 #include <string.h>
+#include <reentrant.h>
 
 /*
  * Bind a socket to a privileged IP port
@@ -79,17 +80,23 @@ bindresvport_sa(sd, sa)
 	u_int16_t *portp;
 	static u_int16_t port;
 	static short startport = STARTPORT;
+	static pthread_mutex_t port_lock = PTHREAD_MUTEX_INITIALIZER;
 	socklen_t salen;
-	int nports = ENDPORT - startport + 1;
+	int nports;
 	int endport = ENDPORT;
 	int i;
 
+	mutex_lock(&port_lock);
+	nports = ENDPORT - startport + 1;
+
         if (sa == NULL) {
                 salen = sizeof(myaddr);
                 sa = (struct sockaddr *)&myaddr;
 
-                if (getsockname(sd, (struct sockaddr *)&myaddr, &salen) == -1)
-                        return -1;      /* errno is correctly set */
+                if (getsockname(sd, (struct sockaddr *)&myaddr, &salen) == -1) {
+                    mutex_unlock(&port_lock);
+                    return -1;      /* errno is correctly set */
+                }
 
                 af = myaddr.ss_family;
         } else
@@ -112,6 +119,7 @@ bindresvport_sa(sd, sa)
 #endif
         default:
                 errno = EPFNOSUPPORT;
+                mutex_unlock(&port_lock);
                 return (-1);
         }
         sa->sa_family = af;
@@ -137,6 +145,8 @@ bindresvport_sa(sd, sa)
 	    port = LOWPORT + port % (STARTPORT - LOWPORT);
 	    goto again;
 	}
+	mutex_unlock(&port_lock);
+
         return (res);
 }
 #else
-- 
1.8.4.2

