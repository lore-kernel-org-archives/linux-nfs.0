From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/6] tcp_wrappers: Use getifaddrs(3) if it is available
Date: Fri, 15 Jan 2010 16:31:26 -0500
Message-ID: <20100115213126.18214.58700.stgit@localhost.localdomain>
References: <20100115212102.18214.19398.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:63715 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757655Ab0AOVg3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jan 2010 16:36:29 -0500
In-Reply-To: <20100115212102.18214.19398.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After glibc 2.3.3, getifaddrs(3) can return AF_INET6 addresses for
local network interfaces.  Using the library call is easier than
trying to update the open code in from_local(), and means we have
less to maintain in nfs-utils going forward.

And, since from_local() can now support IPv6, change its synopsis to
take a "struct sockaddr *" .

Note that the original code discovers local addresses once.  These
days, with wifi, DHCP, and NetworkManager, the local network
configuration can change dynamically over time.  So, call getifaddrs()
more often to ensure from_local() has up-to-date network configuration
information.

This implementation refreshes the list if from_local() has not been
called in the last second.  This is actually not terribly honerous.
check_default() invokes from_local() only when the remote host is not
in its access cache, or the access/deny files have changed.

So new hosts will cause a refresh, but previously seen hosts
(including localhost) should not.

On the other hand, it still may not be often enough.  After the first
call, if only previously seen hosts attempt to access our daemons,
from_local() would never be called, and the local list would never be
updated.  This might be possible during steady-state operation with
a small number of servers and clients.

It would also be nice if we could free the local interface address
list at shutdown time, but that would be a lot of trouble for little
gain.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 aclocal/ipv6.m4              |    4 +-
 configure.ac                 |    2 -
 support/include/tcpwrapper.h |    2 -
 support/misc/from_local.c    |   96 +++++++++++++++++++++++++++++++++++++++---
 support/misc/tcpwrapper.c    |    2 -
 5 files changed, 94 insertions(+), 12 deletions(-)

diff --git a/aclocal/ipv6.m4 b/aclocal/ipv6.m4
index 2490f3d..5ee8fb6 100644
--- a/aclocal/ipv6.m4
+++ b/aclocal/ipv6.m4
@@ -15,8 +15,8 @@ AC_DEFUN([AC_IPV6], [
     fi
 
     dnl IPv6-enabled networking functions required for IPv6
-    AC_CHECK_FUNCS([getnameinfo bindresvport_sa], ,
-                   [AC_MSG_ERROR([Missing functions needed for IPv6.])])
+    AC_CHECK_FUNCS([getifaddrs getnameinfo bindresvport_sa], ,
+                   [AC_MSG_ERROR([Missing library functions needed for IPv6.])])
 
     dnl Need to detect presence of IPv6 networking at run time via
     dnl getaddrinfo(3); old versions of glibc do not support ADDRCONFIG
diff --git a/configure.ac b/configure.ac
index c77c5ba..1dc4249 100644
--- a/configure.ac
+++ b/configure.ac
@@ -330,7 +330,7 @@ AC_FUNC_STAT
 AC_FUNC_VPRINTF
 AC_CHECK_FUNCS([alarm atexit dup2 fdatasync ftruncate getcwd \
                gethostbyaddr gethostbyname gethostname getmntent \
-               getnameinfo getrpcbyname \
+               getnameinfo getrpcbyname getifaddrs \
                gettimeofday hasmntopt inet_ntoa innetgr memset mkdir pathconf \
                realpath rmdir select socket strcasecmp strchr strdup \
                strerror strrchr strtol strtoul sigprocmask])
diff --git a/support/include/tcpwrapper.h b/support/include/tcpwrapper.h
index 98cf806..f1145bd 100644
--- a/support/include/tcpwrapper.h
+++ b/support/include/tcpwrapper.h
@@ -11,7 +11,7 @@ extern int allow_severity;
 extern int deny_severity;
 
 extern int good_client(char *daemon, struct sockaddr_in *addr);
-extern int from_local (struct sockaddr_in *addr);
+extern int from_local(const struct sockaddr *sap);
 extern int check_default(char *daemon, struct sockaddr_in *addr,
 			 u_long proc, u_long prog);
 
diff --git a/support/misc/from_local.c b/support/misc/from_local.c
index 3f46b99..e2de969 100644
--- a/support/misc/from_local.c
+++ b/support/misc/from_local.c
@@ -43,6 +43,7 @@ static char sccsid[] = "@(#) from_local.c 1.3 96/05/31 15:52:57";
 
 #include <sys/types.h>
 #include <sys/socket.h>
+#include <stdbool.h>
 #include <stdio.h>
 #include <unistd.h>
 #include <netdb.h>
@@ -52,6 +53,7 @@ static char sccsid[] = "@(#) from_local.c 1.3 96/05/31 15:52:57";
 #include <stdlib.h>
 #include <string.h>
 
+#include "sockaddr.h"
 #include "tcpwrapper.h"
 #include "xlog.h"
 
@@ -60,11 +62,75 @@ static char sccsid[] = "@(#) from_local.c 1.3 96/05/31 15:52:57";
 #define FALSE	0
 #endif
 
- /*
-  * With virtual hosting, each hardware network interface can have multiple
-  * network addresses. On such machines the number of machine addresses can
-  * be surprisingly large.
-  */
+#ifdef HAVE_GETIFADDRS
+
+#include <ifaddrs.h>
+#include <time.h>
+
+/**
+ * from_local - determine whether request comes from the local system
+ * @sap: pointer to socket address to check
+ *
+ * With virtual hosting, each hardware network interface can have
+ * multiple network addresses. On such machines the number of machine
+ * addresses can be surprisingly large.
+ *
+ * We also expect the local network configuration to change over time,
+ * so call getifaddrs(3) more than once, but not too often.
+ *
+ * Returns TRUE if the sockaddr contains an address of one of the local
+ * network interfaces.  Otherwise FALSE is returned.
+ */
+int
+from_local(const struct sockaddr *sap)
+{
+	static struct ifaddrs *ifaddr = NULL;
+	static time_t last_update = 0;
+	struct ifaddrs *ifa;
+	unsigned int count;
+	time_t now;
+
+	if (time(&now) == ((time_t)-1)) {
+		xlog(L_ERROR, "%s: time(2): %m", __func__);
+
+		/* If we don't know what time it is, use the
+		 * existing ifaddr list, if one exists  */
+		now = last_update;
+		if (ifaddr == NULL)
+			now++;
+	}
+	if (now != last_update) {
+		xlog(D_GENERAL, "%s: updating local if addr list", __func__);
+
+		if (ifaddr)
+			freeifaddrs(ifaddr);
+
+		if (getifaddrs(&ifaddr) == -1) {
+			xlog(L_ERROR, "%s: getifaddrs(3): %m", __func__);
+			return FALSE;
+		}
+
+		last_update = now;
+	}
+
+	count = 0;
+	for (ifa = ifaddr; ifa; ifa = ifa->ifa_next) {
+		if ((ifa->ifa_flags & IFF_UP) &&
+		    nfs_compare_sockaddr(sap, ifa->ifa_addr)) {
+			xlog(D_GENERAL, "%s: incoming address matches "
+					"local interface address", __func__);
+			return TRUE;
+		} else
+			count++;
+	}
+
+	xlog(D_GENERAL, "%s: checked %u local if addrs; "
+			"incoming address not found", __func__, count);
+	return FALSE;
+}
+
+#else	/* !HAVE_GETIFADDRS */
+
 static int num_local;
 static int num_addrs;
 static struct in_addr *addrs;
@@ -155,12 +221,26 @@ find_local(void)
     return (num_local);
 }
 
-/* from_local - determine whether request comes from the local system */
+/**
+ * from_local - determine whether request comes from the local system
+ * @sap: pointer to socket address to check
+ *
+ * With virtual hosting, each hardware network interface can have
+ * multiple network addresses. On such machines the number of machine
+ * addresses can be surprisingly large.
+ *
+ * Returns TRUE if the sockaddr contains an address of one of the local
+ * network interfaces.  Otherwise FALSE is returned.
+ */
 int
-from_local(struct sockaddr_in *addr)
+from_local(const struct sockaddr *sap)
 {
+    const struct sockaddr_in *addr = (const struct sockaddr_in *)sap;
     int     i;
 
+    if (sap->sa_family != AF_INET)
+	return (FALSE);
+
     if (addrs == 0 && find_local() == 0)
 	xlog(L_ERROR, "Cannot find any active local network interfaces");
 
@@ -184,3 +264,5 @@ int main(void)
 }
 
 #endif	/* TEST */
+
+#endif	/* !HAVE_GETIFADDRS */
diff --git a/support/misc/tcpwrapper.c b/support/misc/tcpwrapper.c
index 1da6020..af626ad 100644
--- a/support/misc/tcpwrapper.c
+++ b/support/misc/tcpwrapper.c
@@ -202,7 +202,7 @@ u_long  prog;
 	if (acc && changed == 0)
 		return (acc->access);
 
-	if (!(from_local(addr) || good_client(daemon, addr))) {
+	if (!(from_local((struct sockaddr *)addr) || good_client(daemon, addr))) {
 		log_bad_host(addr, proc, prog);
 		if (acc)
 			acc->access = FALSE;

