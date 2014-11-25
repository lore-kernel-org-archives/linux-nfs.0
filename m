Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36403 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878AbaKYRFj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Nov 2014 12:05:39 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Systemd Mailing List <systemd-devel@lists.freedesktop.org>
Subject: [PATCH] rpcbind: add support for systemd socket activation
Date: Tue, 25 Nov 2014 12:05:33 -0500
Message-Id: <1416935133-7104-2-git-send-email-steved@redhat.com>
In-Reply-To: <1416935133-7104-1-git-send-email-steved@redhat.com>
References: <1416935133-7104-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Gundersen <teg@jklm.no>

Making rpcbind sockect activated will greatly simplify
its integration in systemd systems. In essence, other services
may now assume that rpcbind is always available, even during very
early boot. This means that we no longer need to worry about any
ordering dependencies.

Original-patch-by: Lennart Poettering <lennart@poettering.net>
Cc: systemd-devel@lists.freedesktop.org
Acked-by: Cristian Rodríguez<crrodriguez@opensuse.org>
Signed-off-by: Tom Gundersen <teg@jklm.no>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 Makefile.am   |  6 +++++
 configure.ac  | 12 +++++++++
 src/rpcbind.c | 81 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 93 insertions(+), 6 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index 8715082..c99566d 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -41,6 +41,12 @@ rpcbind_SOURCES = \
 	src/warmstart.c
 rpcbind_LDADD = $(TIRPC_LIBS)
 
+if SYSTEMD
+AM_CPPFLAGS += $(SYSTEMD_CFLAGS) -DSYSTEMD
+
+rpcbind_LDADD += $(SYSTEMD_LIBS)
+endif
+
 rpcinfo_SOURCES =       src/rpcinfo.c
 rpcinfo_LDADD   =       $(TIRPC_LIBS)
 
diff --git a/configure.ac b/configure.ac
index 5a88cc7..967eb05 100644
--- a/configure.ac
+++ b/configure.ac
@@ -36,6 +36,18 @@ AC_SUBST([nss_modules], [$with_nss_modules])
 
 PKG_CHECK_MODULES([TIRPC], [libtirpc])
 
+PKG_PROG_PKG_CONFIG
+AC_ARG_WITH([systemdsystemunitdir],
+  AS_HELP_STRING([--with-systemdsystemunitdir=DIR], [Directory for systemd service files]),
+  [], [with_systemdsystemunitdir=$($PKG_CONFIG --variable=systemdsystemunitdir systemd)])
+  if test "x$with_systemdsystemunitdir" != xno; then
+    AC_SUBST([systemdsystemunitdir], [$with_systemdsystemunitdir])
+     PKG_CHECK_MODULES([SYSTEMD], [libsystemd], [],
+	   [PKG_CHECK_MODULES([SYSTEMD], [libsystemd-daemon], [],
+	   AC_MSG_ERROR([libsystemd support requested but found]))])
+  fi
+AM_CONDITIONAL(SYSTEMD, [test -n "$with_systemdsystemunitdir" -a "x$with_systemdsystemunitdir" != xno ])
+
 AS_IF([test x$enable_libwrap = xyes], [
 	AC_CHECK_LIB([wrap], [hosts_access], ,
 		AC_MSG_ERROR([libwrap support requested but unable to find libwrap]))
diff --git a/src/rpcbind.c b/src/rpcbind.c
index e3462e3..f7c71ee 100644
--- a/src/rpcbind.c
+++ b/src/rpcbind.c
@@ -56,6 +56,9 @@
 #include <netinet/in.h>
 #endif
 #include <arpa/inet.h>
+#ifdef SYSTEMD
+#include <systemd/sd-daemon.h>
+#endif
 #include <fcntl.h>
 #include <netdb.h>
 #include <stdio.h>
@@ -296,6 +299,7 @@ init_transport(struct netconfig *nconf)
 	u_int32_t host_addr[4];  /* IPv4 or IPv6 */
 	struct sockaddr_un sun;
 	mode_t oldmask;
+	int n;
         res = NULL;
 
 	if ((nconf->nc_semantics != NC_TPI_CLTS) &&
@@ -314,6 +318,76 @@ init_transport(struct netconfig *nconf)
 			fprintf(stderr, "[%d] - %s\n", i, *s);
 	}
 #endif
+	if (!__rpc_nconf2sockinfo(nconf, &si)) {
+		syslog(LOG_ERR, "cannot get information for %s",
+		    nconf->nc_netid);
+		return (1);
+	}
+
+#ifdef SYSTEMD
+	n = sd_listen_fds(0);
+	if (n < 0) {
+		syslog(LOG_ERR, "failed to acquire systemd sockets: %s", strerror(-n));
+		return 1;
+	}
+
+	/* Try to find if one of the systemd sockets we were given match
+	 * our netconfig structure. */
+
+	for (fd = SD_LISTEN_FDS_START; fd < SD_LISTEN_FDS_START + n; fd++) {
+		struct __rpc_sockinfo si_other;
+		union {
+			struct sockaddr sa;
+			struct sockaddr_un un;
+			struct sockaddr_in in4;
+			struct sockaddr_in6 in6;
+			struct sockaddr_storage storage;
+		} sa;
+		socklen_t addrlen = sizeof(sa);
+
+		if (!__rpc_fd2sockinfo(fd, &si_other)) {
+			syslog(LOG_ERR, "cannot get information for fd %i", fd);
+			return 1;
+		}
+
+		if (si.si_af != si_other.si_af ||
+                    si.si_socktype != si_other.si_socktype ||
+                    si.si_proto != si_other.si_proto)
+			continue;
+
+		if (getsockname(fd, &sa.sa, &addrlen) < 0) {
+			syslog(LOG_ERR, "failed to query socket name: %s",
+                               strerror(errno));
+			goto error;
+		}
+
+		/* Copy the address */
+		taddr.addr.maxlen = taddr.addr.len = addrlen;
+		taddr.addr.buf = malloc(addrlen);
+		if (taddr.addr.buf == NULL) {
+			syslog(LOG_ERR,
+                               "cannot allocate memory for %s address",
+                               nconf->nc_netid);
+			goto error;
+		}
+		memcpy(taddr.addr.buf, &sa, addrlen);
+
+		my_xprt = (SVCXPRT *)svc_tli_create(fd, nconf, &taddr,
+                          RPC_MAXDATASIZE, RPC_MAXDATASIZE);
+		if (my_xprt == (SVCXPRT *)NULL) {
+			syslog(LOG_ERR, "%s: could not create service",
+                               nconf->nc_netid);
+			goto error;
+		}
+	}
+
+	/*
+	 * If none of the systemd sockets matched, we set up the socket in
+	 * the normal way:
+	 */
+#endif
+	if (my_xprt != NULL)
+		goto got_socket;
 
 	/*
 	 * XXX - using RPC library internal functions. For NC_TPI_CLTS
@@ -327,12 +401,6 @@ init_transport(struct netconfig *nconf)
 		}
 	}
 
-	if (!__rpc_nconf2sockinfo(nconf, &si)) {
-		syslog(LOG_ERR, "cannot get information for %s",
-		    nconf->nc_netid);
-		return (1);
-	}
-
 	if ((strcmp(nconf->nc_netid, "local") == 0) ||
 	    (strcmp(nconf->nc_netid, "unix") == 0)) {
 		memset(&sun, 0, sizeof sun);
@@ -569,6 +637,7 @@ init_transport(struct netconfig *nconf)
 			goto error;
 		}
 	}
+got_socket:
 
 #ifdef PORTMAP
 	/*
-- 
1.9.3

