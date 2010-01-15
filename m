From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/6] tcpwrappers: Use xlog() instead of perror(3) and syslog(2)
Date: Fri, 15 Jan 2010 16:31:15 -0500
Message-ID: <20100115213115.18214.70298.stgit@localhost.localdomain>
References: <20100115212102.18214.19398.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:65309 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758377Ab0AOVbY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jan 2010 16:31:24 -0500
In-Reply-To: <20100115212102.18214.19398.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Replace calls to syslog(2) and perror(3) in from_local.c
with calls to xlog().  The problems displayed by the perror(3) calls
especially should be reported.  Currently they are never seen in the
system log.

As part of a build test, I defined TEST, and found a couple of
problems with main(), which are also addressed in this patch.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/misc/from_local.c |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/support/misc/from_local.c b/support/misc/from_local.c
index 89ccc4a..3f46b99 100644
--- a/support/misc/from_local.c
+++ b/support/misc/from_local.c
@@ -37,8 +37,8 @@
 static char sccsid[] = "@(#) from_local.c 1.3 96/05/31 15:52:57";
 #endif
 
-#ifdef TEST
-#undef perror
+#ifdef HAVE_CONFIG_H
+#include <config.h>
 #endif
 
 #include <sys/types.h>
@@ -49,10 +49,12 @@ static char sccsid[] = "@(#) from_local.c 1.3 96/05/31 15:52:57";
 #include <netinet/in.h>
 #include <net/if.h>
 #include <sys/ioctl.h>
-#include <syslog.h>
 #include <stdlib.h>
 #include <string.h>
 
+#include "tcpwrapper.h"
+#include "xlog.h"
+
 #ifndef TRUE
 #define	TRUE	1
 #define FALSE	0
@@ -81,7 +83,7 @@ static int grow_addrs(void)
     new_num = (addrs == 0) ? 1 : num_addrs + num_addrs;
     new_addrs = (struct in_addr *) malloc(sizeof(*addrs) * new_num);
     if (new_addrs == 0) {
-	perror("portmap: out of memory");
+	xlog_warn("%s: out of memory", __func__);
 	return (0);
     } else {
 	if (addrs != 0) {
@@ -112,13 +114,13 @@ find_local(void)
      */
 
     if ((sock = socket(PF_INET, SOCK_DGRAM, 0)) < 0) {
-	perror("socket");
+	xlog_warn("%s: socket(2): %m", __func__);
 	return (0);
     }
     ifc.ifc_len = sizeof(buf);
     ifc.ifc_buf = buf;
     if (ioctl(sock, SIOCGIFCONF, (char *) &ifc) < 0) {
-	perror("SIOCGIFCONF");
+	xlog_warn("%s: ioctl(SIOCGIFCONF): %m", __func__);
 	(void) close(sock);
 	return (0);
     }
@@ -130,10 +132,10 @@ find_local(void)
 	if (ifr->ifr_addr.sa_family == AF_INET) {	/* IP net interface */
 	    ifreq = *ifr;
 	    if (ioctl(sock, SIOCGIFFLAGS, (char *) &ifreq) < 0) {
-		perror("SIOCGIFFLAGS");
+		xlog_warn("%s: ioctl(SIOCGIFFLAGS): %m", __func__);
 	    } else if (ifreq.ifr_flags & IFF_UP) {	/* active interface */
 		if (ioctl(sock, SIOCGIFADDR, (char *) &ifreq) < 0) {
-		    perror("SIOCGIFADDR");
+		    xlog_warn("%s: ioctl(SIOCGIFADDR): %m", __func__);
 		} else {
 		    if (num_local >= num_addrs)
 			if (grow_addrs() == 0)
@@ -160,7 +162,7 @@ from_local(struct sockaddr_in *addr)
     int     i;
 
     if (addrs == 0 && find_local() == 0)
-	syslog(LOG_ERR, "cannot find any active local network interfaces");
+	xlog(L_ERROR, "Cannot find any active local network interfaces");
 
     for (i = 0; i < num_local; i++) {
 	if (memcmp((char *) &(addr->sin_addr), (char *) &(addrs[i]),
@@ -172,9 +174,8 @@ from_local(struct sockaddr_in *addr)
 
 #ifdef TEST
 
-main()
+int main(void)
 {
-    char   *inet_ntoa();
     int     i;
 
     find_local();
@@ -182,4 +183,4 @@ main()
 	printf("%s\n", inet_ntoa(addrs[i]));
 }
 
-#endif
+#endif	/* TEST */

