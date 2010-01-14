From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 23/24] statd: Support TI-RPC statd listener
Date: Thu, 14 Jan 2010 12:32:12 -0500
Message-ID: <20100114173212.26079.54866.stgit@localhost.localdomain>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:45460 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757337Ab0ANRdK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:33:10 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
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

 support/include/rpcmisc.h |    7 +
 support/nfs/Makefile.am   |    3 -
 support/nfs/svc_create.c  |  252 +++++++++++++++++++++++++++++++++++++++++++++
 utils/statd/statd.c       |   38 ++++++-
 4 files changed, 291 insertions(+), 9 deletions(-)
 create mode 100644 support/nfs/svc_create.c

diff --git a/support/include/rpcmisc.h b/support/include/rpcmisc.h
index 93266b8..91910a6 100644
--- a/support/include/rpcmisc.h
+++ b/support/include/rpcmisc.h
@@ -41,7 +41,12 @@ struct rpc_dtable {
 		(xdrproc_t)xdr_##res_type, sizeof(res_type), \
 	}
 
-
+void		nfs_svc_unregister(const rpcprog_t program,
+				const rpcvers_t version);
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
index 0000000..fa7eab6
--- /dev/null
+++ b/support/nfs/svc_create.c
@@ -0,0 +1,252 @@
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
+__attribute_malloc__
+static struct addrinfo *
+svc_create_bindaddr(struct netconfig *nconf, const uint16_t port)
+{
+	struct addrinfo *ai = NULL;
+	struct addrinfo hint = {
+		.ai_flags	= AI_PASSIVE | AI_NUMERICSERV,
+	};
+	char buf[8];
+	int error;
+
+	if (strcmp(nconf->nc_protofmly, NC_INET) == 0)
+		hint.ai_family = AF_INET;
+#ifdef IPV6_SUPPORTED
+	else if (strcmp(nconf->nc_protofmly, NC_INET6) == 0)
+		hint.ai_family = AF_INET6;
+#endif	/* IPV6_SUPPORTED */
+	else {
+		xlog(L_ERROR, "Unrecognized bind address family: %s",
+			nconf->nc_protofmly);
+		return NULL;
+	}
+
+	if (strcmp(nconf->nc_proto, NC_UDP) == 0)
+		hint.ai_protocol = (int)IPPROTO_UDP;
+	else if (strcmp(nconf->nc_proto, NC_TCP) == 0)
+		hint.ai_protocol = (int)IPPROTO_TCP;
+	else {
+		xlog(L_ERROR, "Unrecognized bind address protocol: %s",
+			nconf->nc_proto);
+		return NULL;
+	}
+
+	(void)snprintf(buf, sizeof(buf), "%u", port);
+	error = getaddrinfo(NULL, buf, &hint, &ai);
+	switch (error != 0) {
+	case 0:
+		return ai;
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
+static unsigned int
+svc_create_nconf(const char *name, const rpcprog_t program,
+		const rpcvers_t version,
+		void (*dispatch)(struct svc_req *, SVCXPRT *),
+		const uint16_t port, struct netconfig *nconf)
+{
+	struct t_bind bindaddr;
+	struct addrinfo *ai;
+	SVCXPRT	*xprt;
+
+	ai = svc_create_bindaddr(nconf, port);
+	if (ai == NULL)
+		return 0;
+
+	bindaddr.addr.buf = ai->ai_addr;
+	bindaddr.qlen = SOMAXCONN;
+
+	xprt = svc_tli_create(RPC_ANYFD, nconf, &bindaddr, 0, 0);
+	freeaddrinfo(ai);
+	if (xprt == NULL) {
+		xlog(D_GENERAL, "Failed to create listener xprt "
+				"(%s, %u, %s)", name, version, nconf->nc_netid);
+		return 0;
+	}
+
+	if (!svc_reg(xprt, program, version, dispatch, nconf)) {
+		/* svc_reg(3) destroys @xprt in this case */
+		xlog(D_GENERAL, "Failed to register (%s, %u, %s)",
+				name, version, nconf->nc_netid);
+		return 0;
+	}
+
+	return 1;
+}
+
+/**
+ * nfs_svc_create - start up RPC svc listeners
+ * @name: C string containing name of new service
+ * @program: RPC program number to register
+ * @version: RPC version number to register
+ * @dispatch: address of function that handles incoming RPC requests
+ * @port: if not zero, transport listens on this port
+ *
+ * Sets up network transports for receiving RPC requests, and starts
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
+		up += svc_create_nconf(name, program, version, dispatch,
+						port, nconf);
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
+/**
+ * nfs_svc_unregister - remove service registrations from local rpcbind database
+ * @program: RPC program number to unregister
+ * @version: RPC version number to unregister
+ *
+ * Removes all registrations for [ @program, @version ] .
+ */
+void
+nfs_svc_unregister(const rpcprog_t program, const rpcvers_t version)
+{
+	if (rpcb_unset(program, version, NULL) == FALSE)
+		xlog(D_GENERAL, "Failed to unregister program %lu, version %lu",
+			(unsigned long)program, (unsigned long)version);
+}
+
+#else	/* !HAVE_LIBTIRPC */
+
+/**
+ * nfs_svc_create - start up RPC svc listeners
+ * @name: C string containing name of new service
+ * @program: RPC program number to register
+ * @version: RPC version number to register
+ * @dispatch: address of function that handles incoming RPC requests
+ * @port: if not zero, transport listens on this port
+ *
+ * Sets up network transports for receiving RPC requests, and starts
+ * the RPC dispatcher.  Returns the number of started network transports.
+ */
+unsigned int
+nfs_svc_create(char *name, const rpcprog_t program, const rpcvers_t version,
+		void (*dispatch)(struct svc_req *, SVCXPRT *),
+		const uint16_t port)
+{
+	rpc_init(name, (int)program, (int)version, dispatch, (int)port);
+	return 1;
+}
+
+/**
+ * nfs_svc_unregister - remove service registrations from local rpcbind database
+ * @program: RPC program number to unregister
+ * @version: RPC version number to unregister
+ *
+ * Removes all registrations for [ @program, @version ] .
+ */
+void
+nfs_svc_unregister(const rpcprog_t program, const rpcvers_t version)
+{
+	if (pmap_unset((unsigned long)program, (unsigned long)version) == FALSE)
+		xlog(D_GENERAL, "Failed to unregister program %lu, version %lu",
+			(unsigned long)program, (unsigned long)version);
+}
+
+#endif	/* !HAVE_LIBTIRPC */
diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index 72c9b41..7be6454 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -90,13 +90,18 @@ sm_prog_1_wrapper (struct svc_req *rqstp, register SVCXPRT *transp)
 #define sm_prog_1 sm_prog_1_wrapper
 #endif
 
+static void
+statd_unregister(void) {
+	nfs_svc_unregister(SM_PROG, SM_VERS);
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
 
@@ -125,6 +130,9 @@ static void log_modes(void)
 		strcat(buf,"No-Daemon ");
 	if (run_mode & MODE_LOG_STDERR)
 		strcat(buf,"Log-STDERR ");
+#ifdef HAVE_LIBTIRPC
+	strcat(buf, "TI-RPC ");
+#endif
 
 	xlog_warn(buf);
 }
@@ -424,10 +432,29 @@ int main (int argc, char **argv)
 	xlog(D_GENERAL, "Local NSM state number: %d", MY_STATE);
 	nsm_update_kernel_state(MY_STATE);
 
-	pmap_unset (SM_PROG, SM_VERS);
+	/*
+	 * ORDER
+	 * Clear old listeners while still root, to override any
+	 * permission checking done by rpcbind.
+	 */
+	statd_unregister();
+
+	/*
+	 * ORDER
+	 */
+	if (!nsm_drop_privileges(pidfd))
+		exit(1);
 
-	/* this registers both UDP and TCP services */
-	rpc_init("statd", SM_PROG, SM_VERS, sm_prog_1, port);
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
@@ -440,9 +467,6 @@ int main (int argc, char **argv)
 		pipefds[1] = -1;
 	}
 
-	if (!nsm_drop_privileges(pidfd))
-		exit(1);
-
 	for (;;) {
 		/*
 		 * Handle incoming requests:  SM_NOTIFY socket requests, as

