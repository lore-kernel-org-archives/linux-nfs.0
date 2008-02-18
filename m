From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/17] nfs-utils: Introduce fallback bindresvport6()
	implementation
Date: Mon, 18 Feb 2008 13:35:41 -0500
Message-ID: <20080218183541.19060.39582.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:55140 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932AbYBRSfo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2008 13:35:44 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1IIZfSq016948
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 10:35:42 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1IIZf7f019318
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 13:35:41 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The bindresvport() function, available in glibc, is used to select an
ephemeral reserved port before connecting a socket.  However, it is
IPv4-specific.  To support IPv6 sockets, we require a way to select an
ephemeral reserved port for PF_INET6 sockets.  Usually this facility is
provided by bindresvport6().

Even though netinet/in.h on Linux has a prototype for bindresvport6(),
it doesn't currently appear in any standard library on Linux, and there's
no man page for it.

Thus we introduce our own implementation of bindresvport6() in the
nfs-utils support library which is compiled in when autoconf doesn't find
a version of bindresvport6() to use from the standard libraries.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 configure.ac                |    5 +
 support/misc/Makefile.am    |    5 +
 support/misc/bindresvport.c |  144 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 154 insertions(+), 0 deletions(-)

diff --git a/configure.ac b/configure.ac
index 5a06971..233cd57 100644
--- a/configure.ac
+++ b/configure.ac
@@ -294,6 +294,11 @@ AC_CHECK_FUNCS([alarm atexit dup2 fdatasync ftruncate getcwd \
                realpath rmdir select socket strcasecmp strchr strdup \
                strerror strrchr strtol strtoul sigprocmask])
 
+have_bindresvport6=none
+if test "$enable_ipv6" = yes; then
+    AC_CHECK_FUNC(bindresvport6, [have_bindresvport6=lib])
+fi
+AM_CONDITIONAL(CONFIG_BRP6, [test "$have_bindresvport6" = "none"])
 
 dnl *************************************************************
 dnl Check for data sizes
diff --git a/support/misc/Makefile.am b/support/misc/Makefile.am
index 1048580..d17655e 100644
--- a/support/misc/Makefile.am
+++ b/support/misc/Makefile.am
@@ -3,4 +3,9 @@
 noinst_LIBRARIES = libmisc.a
 libmisc_a_SOURCES = tcpwrapper.c from_local.c mountpoint.c
 
+if CONFIG_BRP6
+libmisc_a_SOURCES += bindresvport.c
+endif
+
+
 MAINTAINERCLEANFILES = Makefile.in
diff --git a/support/misc/bindresvport.c b/support/misc/bindresvport.c
new file mode 100644
index 0000000..e36e807
--- /dev/null
+++ b/support/misc/bindresvport.c
@@ -0,0 +1,144 @@
+/*
+ * bindresvport.c -- bind a PF_INET6 socket to a privileged port number
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ *
+ * This version of bindresvport6() is
+ *
+ * Copyright (C) 2008 Oracle.  All rights reserved.
+ *
+ * and based on an IPv4 version of bindresvport in
+ * glibc-2.7/sunrpc/bindresvport.c, which includes the following
+ * legal statement:
+ *
+ * Sun RPC is a product of Sun Microsystems, Inc. and is provided for
+ * unrestricted use provided that this legend is included on all tape
+ * media and as a part of the software program in whole or part.  Users
+ * may copy or modify Sun RPC without charge, but are not authorized
+ * to license or distribute it to anyone else except as part of a product
+ * or program developed by the user.
+ *
+ * SUN RPC IS PROVIDED AS IS WITH NO WARRANTIES OF ANY KIND INCLUDING THE
+ * WARRANTIES OF DESIGN, MERCHANTIBILITY AND FITNESS FOR A PARTICULAR
+ * PURPOSE, OR ARISING FROM A COURSE OF DEALING, USAGE OR TRADE PRACTICE.
+ *
+ * Sun RPC is provided with no support and without any obligation on the
+ * part of Sun Microsystems, Inc. to assist in its use, correction,
+ * modification or enhancement.
+ *
+ * SUN MICROSYSTEMS, INC. SHALL HAVE NO LIABILITY WITH RESPECT TO THE
+ * INFRINGEMENT OF COPYRIGHTS, TRADE SECRETS OR ANY PATENTS BY SUN RPC
+ * OR ANY PART THEREOF.
+ *
+ * In no event will Sun Microsystems, Inc. be liable for any lost revenue
+ * or profits or other special, indirect and consequential damages, even if
+ * Sun has been advised of the possibility of such damages.
+ *
+ * Sun Microsystems, Inc.
+ * 2550 Garcia Avenue
+ * Mountain View, California  94043
+ *
+ * Copyright (c) 1987 by Sun Microsystems, Inc.
+ */
+
+#ifndef HAVE_BINDRESVPORT6
+
+/*
+ * Linux's netinet/in.h does include a prototype for bindresvport6
+ * even though glibc does not provide an actual implementation.
+ * If autoconf does not detect a bindresvport6 entry point in the
+ * build system's C libraries, we provide an implementation that
+ * matches the standard bindresvport6 prototype.
+ */
+
+#include <errno.h>
+#include <unistd.h>
+#include <string.h>
+
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+
+#define STARTPORT	(600)
+#define LOWPORT		(512)
+#define ENDPORT		(IPPORT_RESERVED - 1)
+#define NPORTS		(ENDPORT - STARTPORT + 1)
+
+static unsigned short startport = STARTPORT;
+static unsigned short port = 0;
+
+/**
+ * bindresvport6 - bind a PF_INET6 socket to a privileged IP port
+ * @sd: socket file descriptor
+ * @sin: AF_INET6 address
+ *
+ * If the process has appropriate privilege, the bindresvport6() function
+ * binds a socket to a privileged IP port (a port number in the range 0
+ * through 1023).
+ *
+ * Only root can bind to a privileged port.  An explicit check isn't
+ * needed here, as the bind(2) system call below enforces this capability.
+ *
+ * On success, zero is returned. On error, -1 is returned, and the global
+ * variable errno is set to reflect the cause of the error:
+ *
+ * EPERM:		The process did not have appropriate privilege.
+ * EPFNOSUPPORT:	Address family of sin did not match protocol
+ *			family of sd.
+ */
+int bindresvport6(int sd, struct sockaddr_in6 *sin)
+{
+	struct sockaddr_in6 myaddr = {
+		.sin6_family	= AF_INET6,
+	};
+	unsigned int i, nports = ENDPORT - startport + 1;
+	unsigned short endport = ENDPORT;
+	int res = -1;
+
+	if (sin == NULL)
+		sin = &myaddr;
+	else
+		if (sin->sin6_family != AF_INET6) {
+			errno = EPFNOSUPPORT;
+			return -1;
+		}
+
+	if (port == 0)
+		port = (getpid() % NPORTS) + STARTPORT;
+
+again:
+	for (i = 0; i < nports; ++i) {
+		sin->sin6_port = htons(port++);
+		if (port > endport)
+			port = startport;
+		res = bind(sd, (struct sockaddr *)sin, sizeof(*sin));
+		if (res >= 0 || errno != EADDRINUSE)
+			break;
+	}
+
+	if (i == nports && startport != LOWPORT) {
+		startport = LOWPORT;
+		endport = STARTPORT - 1;
+		nports = STARTPORT - LOWPORT;
+		port = LOWPORT + port % (STARTPORT - LOWPORT);
+		/* should pause for a bit here */
+		goto again;
+	}
+
+	return res;
+}
+#endif	/* HAVE_BINDRESVPORT6 */

