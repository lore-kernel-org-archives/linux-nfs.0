From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 04/24] Remove warnings from svc_socket.c
Date: Tue, 20 Jul 2010 19:37:17 -0400
Message-ID: <1279669057-17509-5-git-send-email-steved@redhat.com>
References: <1279669057-17509-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:60367 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761873Ab0GUAmx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 20:42:53 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1ObMNW-0004K5-Mu
	for linux-nfs@vger.kernel.org; Tue, 20 Jul 2010 19:37:38 -0400
In-Reply-To: <1279669057-17509-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

svc_socket.c: In function 'svcudp_socket':
svc_socket.c:160: warning: unused parameter 'reuse'

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/include/nfslib.h |    2 +-
 support/nfs/rpcmisc.c    |    2 +-
 support/nfs/svc_socket.c |    6 +++---
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index e44cf8f..b8e7c40 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -158,6 +158,6 @@ void qword_printuint(FILE *f, unsigned int num);
 void closeall(int min);
 
 int			svctcp_socket (u_long __number, int __reuse);
-int			svcudp_socket (u_long __number, int __reuse);
+int			svcudp_socket (u_long __number);
 
 #endif /* NFSLIB_H */
diff --git a/support/nfs/rpcmisc.c b/support/nfs/rpcmisc.c
index a0854e7..b73187a 100644
--- a/support/nfs/rpcmisc.c
+++ b/support/nfs/rpcmisc.c
@@ -154,7 +154,7 @@ rpc_init(char *name, int prog, int vers,
 				sock = makesock(defport, IPPROTO_UDP);
 		}
 		if (sock == RPC_ANYSOCK)
-			sock = svcudp_socket (prog, 1);
+			sock = svcudp_socket (prog);
 		transp = svcudp_create(sock);
 		if (transp == NULL) {
 			xlog(L_FATAL, "cannot create udp service.");
diff --git a/support/nfs/svc_socket.c b/support/nfs/svc_socket.c
index f44217a..03a5325 100644
--- a/support/nfs/svc_socket.c
+++ b/support/nfs/svc_socket.c
@@ -157,9 +157,9 @@ svctcp_socket (u_long number, int reuse)
  * Create and bind a UDP socket based on program number
  */
 int
-svcudp_socket (u_long number, int reuse)
+svcudp_socket (u_long number)
 {
-  return svc_socket (number, SOCK_DGRAM, IPPROTO_UDP, 0);
+  return svc_socket (number, SOCK_DGRAM, IPPROTO_UDP, FALSE);
 }
 
 #ifdef TEST
@@ -174,7 +174,7 @@ check (u_long number, u_short port, int protocol, int reuse)
   if (protocol == IPPROTO_TCP)
     socket = svctcp_socket (number, reuse);
   else
-    socket = svcudp_socket (number, reuse);
+    socket = svcudp_socket (number);
 
   if (socket < 0)
     return 1;
-- 
1.7.0.1

