From: Dan Kegel <dkegel@ixiacom.com>
Subject: [NFS] NFS Mount Patch: Support servers that don't support portmapper
 over TCP
Date: Wed, 06 Aug 2003 13:53:32 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3F316ACC.7080008@ixiacom.com>
References: <3F316446.3020808@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: util-linux@math.uio.no, nfs@lists.sourceforge.net,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <3F316446.3020808@RedHat.com>
List-ID: <nfs.lists.sourceforge.net>

Steve Dickson wrote:
> This patch changes the default transport of NFS mounts
> from UDP to TCP, iff the transport not explicitly
> specified and the server support TCP mounts.
> 
> This patch is backwards compatible with servers that
> don't support TCP mounts since it quarries the server
> (which was already happening for the mount version)
> to see if the server support TCP mounts.

Say, as long as we're on the subject of supporting servers
that don't support TCP mounts, I've found the following
patch neccessary to support servers that don't support
TCP even for enumrating services.  (Hint: some operating systems
have an arbitrary limit on TCP sessions.)

Tested in busybox nfsmount, rediffed against util-linux-2.12pre,
compiles ok.  I don't know if the change in meaning of the
udp mount option is a good idea in general, but it sure helped
us here.
- Dan

--- util-linux-2.12pre/mount/nfsmount.c.old	Wed Aug  6 13:39:24 2003
+++ util-linux-2.12pre/mount/nfsmount.c	Wed Aug  6 13:46:51 2003
@@ -74,6 +74,9 @@

  static char *nfs_strerror(int stat);

+static struct pmaplist *
+pmap_getmaps_udp (struct sockaddr_in *address);
+
  #define MAKE_VERSION(p,q,r)	(65536*(p) + 256*(q) + (r))

  #define MAX_NFSPROT ((nfs_mount_version >= 4) ? 3 : 2)
@@ -148,7 +151,10 @@
  	p.pm_port = port;

  	server_addr->sin_port = PMAPPORT;
-	pmap = pmap_getmaps(server_addr);
+	if (proto == IPPROTO_TCP)
+		pmap = pmap_getmaps(server_addr);
+	else
+		pmap = pmap_getmaps_udp(server_addr);

  	while (pmap) {
  		if (pmap->pml_map.pm_prog != prog)
@@ -883,3 +889,91 @@
          return port;
  }
  #endif
+
+/* added 30 June 2003, dkegel@ixiacom.com, to support true udp-only mounts */
+
+/* @(#)pmap_getmaps.c	2.2 88/08/01 4.0 RPCSRC */
+/*
+ * Sun RPC is a product of Sun Microsystems, Inc. and is provided for
+ * unrestricted use provided that this legend is included on all tape
+ * media and as a part of the software program in whole or part.  Users
+ * may copy or modify Sun RPC without charge, but are not authorized
+ * to license or distribute it to anyone else except as part of a product or
+ * program developed by the user.
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
+ */
+#if !defined(lint) && defined(SCCSIDS)
+static char sccsid[] = "@(#)[copy of] pmap_getmaps.c 1.10 87/08/11 Copyr 1984 Sun Micro";
+#endif
+
+/*
+ * [copy of] pmap_getmap.c
+ * Client interface to pmap rpc service.
+ * contains pmap_getmaps, which is only tcp service involved
+ *
+ * Copyright (C) 1984, Sun Microsystems, Inc.
+ */
+
+#include <rpc/rpc.h>
+#include <rpc/pmap_prot.h>
+#include <rpc/pmap_clnt.h>
+#include <sys/socket.h>
+#include <netdb.h>
+#include <stdio.h>
+#include <errno.h>
+
+/*
+ * Get a copy of the current port maps.
+ * Calls the pmap service remotely to do get the maps.
+ */
+struct pmaplist *
+pmap_getmaps_udp(struct sockaddr_in *address)
+{
+	struct pmaplist *head = (struct pmaplist *) NULL;
+	int fd = -1;
+	struct timeval minutetimeout;
+	struct timeval retry;
+	CLIENT *client;
+
+	minutetimeout.tv_sec = 60;
+	minutetimeout.tv_usec = 0;
+	address->sin_port = htons(PMAPPORT);
+#if 0
+	client = clnttcp_create(address, PMAPPROG, PMAPVERS, &fd, 50, 500);
+#else
+	/* FIXME: this retry interval's a bit arbitrary...*/
+	retry.tv_sec = 5;
+	retry.tv_usec = 0;
+	client = clntudp_create(address, PMAPPROG, PMAPVERS, retry, &fd);
+#endif
+	if (client != (CLIENT *) NULL) {
+		if (CLNT_CALL(client, PMAPPROC_DUMP, (xdrproc_t) xdr_void, NULL,
+				(xdrproc_t) xdr_pmaplist, (caddr_t) & head, minutetimeout) != RPC_SUCCESS) {
+			clnt_perror(client, _("pmap_getmaps rpc problem"));
+		}
+		CLNT_DESTROY(client);
+	}
+	/* (void)close(fd); CLNT_DESTROY already closed it */
+	address->sin_port = 0;
+	return head;
+}
+
