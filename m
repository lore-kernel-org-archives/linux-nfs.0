From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 26/26] statd: Support TI-RPC statd listener
Date: Tue, 13 Oct 2009 10:58:39 -0400
Message-ID: <20091013145839.2424.93005.stgit@matisse.1015granger.net>
References: <20091013142257.2424.76946.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:47308 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760114AbZJMO7h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2009 10:59:37 -0400
Received: from rgminet13.oracle.com (rcsinet13.oracle.com [148.87.113.125])
	by acsinet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DEwtAf004096
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:58:57 GMT
Received: from acsmt357.oracle.com (acsmt357.oracle.com [141.146.40.157])
	by rgminet13.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DExVoF023081
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:59:31 GMT
In-Reply-To: <20091013142257.2424.76946.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If TI-RPC is available, use it to create statd's svc listener.  If
not, use the old function, rpc_init(), to create statd's listener.

IPv6 can be supported if TI-RPC is available.  In this case,
/etc/netconfig is searched to determine which transports to advertise.

Add the new listener creation API in libnfs.a since other components
of nfs-utils (such as rpc.mountd) will eventually want to share it.

A little re-arrangement of when the statd listener is created is done
to make unregistration of the statd service more reliable.  As it is
now, the statd service is never unregistered when it exits.  After it
is gone, other programs usually hang when trying to access statd or
see if it's running, since the registration is still there but statd
itself does not respond.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/rpcmisc.h |    5 +
 support/nfs/Makefile.am   |    3 -
 support/nfs/svc_create.c  |  213 +++++++++++++++++++++++++++++++++++++++++++++
 utils/statd/statd.c       |   42 +++++++--
 4 files changed, 254 insertions(+), 9 deletions(-)
 create mode 100644 support/nfs/svc_create.c

diff --git a/support/include/rpcmisc.h b/support/include/rpcmisc.h
index f551a85..7a39f13 100644
--- a/support/include/rpcmisc.h
+++ b/support/include/rpcmisc.h
@@ -41,7 +41,10 @@ struct rpc_dtable {
 		(xdrproc_t)xdr_##res_type, sizeof(res_type), \
 	}
 
-
+unsigned int	nfs_svc_create(char *name, const rpcprog_t program,
+				const rpcvers_t version,
+				void (*dispatch)(struct svc_req *, SVCXPRT *),
+				const uint16_t port);
 void		rpc_init(char *name, int prog, int vers,
 				void (*dispatch)(struct svc_req *, SVCXPRT *),
 				int defport);
diff --git a/support/nfs/Makefile.am b/support/nfs/Makefile.am
index e9462fc..60400b2 100644
--- a/support/nfs/Makefile.am
+++ b/support/nfs/Makefile.am
@@ -4,7 +4,8 @@ noinst_LIBRARIES = libnfs.a
 libnfs_a_SOURCES = exports.c rmtab.c xio.c rpcmisc.c rpcdispatch.c \
 		   xlog.c xcommon.c wildmat.c nfsclient.c \
 		   nfsexport.c getfh.c nfsctl.c rpc_socket.c getport.c \
-		   svc_socket.c cacheio.c closeall.c nfs_mntent.c conffile.c
+		   svc_socket.c cacheio.c closeall.c nfs_mntent.c conffile.c \
+		   svc_create.c
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/support/nfs/svc_create.c b/support/nfs/svc_create.c
new file mode 100644
index 0000000..ca1d1bf
--- /dev/null
+++ b/support/nfs/svc_create.c
@@ -0,0 +1,213 @@
+/*
+ * Copyright 2009 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * nfs-utils is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with nfs-utils.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+/*
+ * NSM for Linux.
+ *
+ * Convert incoming NSM RPC requests into local function calls.
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <memory.h>
+#include <signal.h>
+#include <unistd.h>
+#include <netdb.h>
+
+#include <netinet/in.h>
+
+#include <sys/socket.h>
+#include <sys/resource.h>
+
+#include <rpc/rpc.h>
+#include <rpc/svc.h>
+
+#ifdef HAVE_TCP_WRAPPER
+#include "tcpwrapper.h"
+#endif
+
+#include "rpcmisc.h"
+#include "xlog.h"
+
+#ifdef HAVE_LIBTIRPC
+
+/*
+ * Set up an appropriate bind address, given @port and @nconf.
+ *
+ * Returns getaddrinfo(3) results if successful.  Caller must
+ * invoke freeaddrinfo(3) on these results.
+ *
+ * Otherwise NULL is returned if an error occurs.
+ */
+static struct addrinfo *
+svc_create_bindaddr(struct netconfig *nconf, const uint16_t port)
+{
+	struct addrinfo gai_hint = {
+		.ai_flags	= AI_PASSIVE | AI_NUMERICSERV,
+	};
+	struct addrinfo *gai_results;
+	char buf[8];
+	int error;
+
+	if (strcmp(nconf->nc_protofmly, NC_INET) == 0)
+		gai_hint.ai_family = AF_INET;
+#ifdef IPV6_SUPPORTED
+	else if (strcmp(nconf->nc_protofmly, NC_INET6) == 0)
+		gai_hint.ai_family = AF_INET6;
+#endif	/* IPV6_SUPPORTED */
+	else {
+		xlog(L_ERROR, "Unrecognized bind address family: %s",
+			nconf->nc_protofmly);
+		return NULL;
+	}
+
+	if (strcmp(nconf->nc_proto, NC_UDP) == 0)
+		gai_hint.ai_protocol = IPPROTO_UDP;
+	else if (strcmp(nconf->nc_proto, NC_TCP) == 0)
+		gai_hint.ai_protocol = IPPROTO_TCP;
+	else {
+		xlog(L_ERROR, "Unrecognized bind address protocol: %s",
+			nconf->nc_proto);
+		return NULL;
+	}
+
+	(void)snprintf(buf, sizeof(buf), "%u", port);
+	error = getaddrinfo(NULL, buf, &gai_hint, &gai_results);
+	switch (error) {
+	case 0:
+		return gai_results;
+	case EAI_SYSTEM:
+		xlog(L_ERROR, "Failed to construct bind address: %m");
+		break;
+	default:
+		xlog(L_ERROR, "Failed to construct bind address: %s",
+			gai_strerror(error));
+		break;
+	}
+
+	return NULL;
+}
+
+static int
+svc_create_nconf(const rpcprog_t program, const rpcvers_t version,
+		void (*dispatch)(struct svc_req *, SVCXPRT *),
+		const uint16_t port, struct netconfig *nconf)
+{
+	struct addrinfo *gai_results;
+	struct t_bind bindaddr;
+	SVCXPRT	*xprt;
+
+	gai_results = svc_create_bindaddr(nconf, port);
+	if (gai_results == NULL)
+		return 0;
+
+	bindaddr.addr.buf = gai_results->ai_addr;
+	bindaddr.qlen = SOMAXCONN;
+
+	xprt = svc_tli_create(RPC_ANYFD, nconf, &bindaddr, 0, 0);
+	freeaddrinfo(gai_results);
+	if (xprt == NULL) {
+		xlog(D_GENERAL, "Failed to create NSM xprt");
+		return 0;
+	}
+
+	if (!svc_reg(xprt, program, version, dispatch, nconf)) {
+		/* svc_reg(3) destroys @xprt in this case */
+		xlog(D_GENERAL, "Failed to register (statd, %u, %s).",
+				version, nconf->nc_proto);
+		return 0;
+	}
+
+	return 1;
+}
+
+/**
+ * svc_create - start up NSM listeners
+ * @name: C string containing name of new service
+ * @program: RPC program number to register
+ * @version: RPC version number to register
+ * @dispatch: address of function that handles incoming RPC requests
+ * @port: if not zero, transport listens on this port
+ *
+ * Sets up network transports for receiving NSM RPC requests, and starts
+ * the RPC dispatcher.  Returns the number of started network transports.
+ */
+unsigned int
+nfs_svc_create(__attribute__((unused)) char *name,
+		const rpcprog_t program, const rpcvers_t version,
+		void (*dispatch)(struct svc_req *, SVCXPRT *),
+		const uint16_t port)
+{
+	const struct sigaction create_sigaction = {
+		.sa_handler	= SIG_IGN,
+	};
+	unsigned int visible, up;
+	struct netconfig *nconf;
+	void *handlep;
+
+	/*
+	 * Ignore SIGPIPE to avoid exiting sideways when peers
+	 * close their TCP connection while we're trying to reply
+	 * to them.
+	 */
+	(void)sigaction(SIGPIPE, &create_sigaction, NULL);
+
+	handlep = setnetconfig();
+	if (handlep == NULL) {
+		xlog(L_ERROR, "Failed to access local netconfig database: %s",
+			nc_sperror());
+		return 0;
+	}
+
+	visible = 0;
+	up = 0;
+	while ((nconf = getnetconfig(handlep)) != NULL) {
+		if (!(nconf->nc_flag & NC_VISIBLE))
+			continue;
+		visible++;
+		up += svc_create_nconf(program, version, dispatch, port, nconf);
+	}
+
+	if (visible == 0)
+		xlog(L_ERROR, "Failed to find any visible netconfig entries");
+
+	if (endnetconfig(handlep) == -1)
+		xlog(L_ERROR, "Failed to close local netconfig database: %s",
+			nc_sperror());
+
+	return up;
+}
+
+#else	/* !HAVE_LIBTIRPC */
+
+unsigned int
+nfs_svc_create(char *name, const rpcprog_t program, const rpcvers_t version,
+		void (*dispatch)(struct svc_req *, SVCXPRT *),
+		const uint16_t port)
+{
+	rpc_init(name, program, version, dispatch, port);
+	return 1;
+}
+
+#endif	/* !HAVE_LIBTIRPC */
diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index 72c9b41..19823fb 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -90,13 +90,22 @@ sm_prog_1_wrapper (struct svc_req *rqstp, register SVCXPRT *transp)
 #define sm_prog_1 sm_prog_1_wrapper
 #endif
 
+static void
+statd_unregister(void) {
+#ifdef HAVE_LIBTIRPC
+	(void)rpcb_unset(SM_PROG, SM_VERS, NULL);
+#else
+	(void)pmap_unset(SM_PROG, SM_VERS);
+#endif
+}
+
 /*
  * Signal handler.
  */
 static void 
 killer (int sig)
 {
-	pmap_unset (SM_PROG, SM_VERS);
+	statd_unregister ();
 	xlog_err ("Caught signal %d, un-registering and exiting", sig);
 }
 
@@ -125,6 +134,9 @@ static void log_modes(void)
 		strcat(buf,"No-Daemon ");
 	if (run_mode & MODE_LOG_STDERR)
 		strcat(buf,"Log-STDERR ");
+#ifdef HAVE_LIBTIRPC
+	strcat(buf, "TI-RPC ");
+#endif
 
 	xlog_warn(buf);
 }
@@ -424,10 +436,29 @@ int main (int argc, char **argv)
 	xlog(D_GENERAL, "Local NSM state number: %d", MY_STATE);
 	nsm_update_kernel_state(MY_STATE);
 
-	pmap_unset (SM_PROG, SM_VERS);
+	/*
+	 * ORDER
+	 * Clear old listeners while still root, to override any
+	 * permission checking done by rpcbind.
+	 */
+	statd_unregister();
 
-	/* this registers both UDP and TCP services */
-	rpc_init("statd", SM_PROG, SM_VERS, sm_prog_1, port);
+	/*
+	 * ORDER
+	 */
+	if (!nsm_drop_privileges(pidfd))
+		exit(1);
+
+	/*
+	 * ORDER
+	 * Create RPC listeners after dropping privileges.  This permits
+	 * statd to unregister its own listeners when it exits.
+	 */
+	if (nfs_svc_create("statd", SM_PROG, SM_VERS, sm_prog_1, port) == 0) {
+		xlog(L_ERROR, "failed to create RPC listeners, exiting");
+		exit(1);
+	}
+	atexit(statd_unregister);
 
 	/* If we got this far, we have successfully started, so notify parent */
 	if (pipefds[1] > 0) {
@@ -440,9 +471,6 @@ int main (int argc, char **argv)
 		pipefds[1] = -1;
 	}
 
-	if (!nsm_drop_privileges(pidfd))
-		exit(1);
-
 	for (;;) {
 		/*
 		 * Handle incoming requests:  SM_NOTIFY socket requests, as

