From: Dan Kegel <dkegel@ixiacom.com>
Subject: Re: [PATCH] Make 'udp' mount option really mean it
Date: Mon, 30 Jun 2003 15:29:28 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F00B9C8.10104@ixiacom.com>
References: <3F00911E.5020001@ixiacom.com> <3F00B885.1010305@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 64-60-75-69.cust.telepacific.net ([64.60.75.69] helo=racerx.ixiacom.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19X7C5-0005qZ-00
	for <nfs@lists.sourceforge.net>; Mon, 30 Jun 2003 15:32:17 -0700
To: util-linux@math.uio.net,  aebr@win.tue.nl
In-Reply-To: <3F00B885.1010305@ixiacom.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Crap.  Ignore that patch.  Here's the real one.
- Dan

--- util-linux-2.11n/mount/nfsmount.c.old	Sat Sep 29 15:43:26 2001
+++ util-linux-2.11n/mount/nfsmount.c	Mon Jun 30 13:48:28 2003
@@ -68,6 +68,9 @@

  static char *nfs_strerror(int stat);

+static struct pmaplist *
+pmap_getmaps_udp (struct sockaddr_in *address);
+
  #define MAKE_VERSION(p,q,r)	(65536*(p) + 256*(q) + (r))

  #define MAX_NFSPROT ((nfs_mount_version >= 4) ? 3 : 2)
@@ -142,7 +145,10 @@
  	p.pm_port = port;

  	server_addr->sin_port = PMAPPORT;
-	pmap = pmap_getmaps(server_addr);
+	if (proto == IPPROTO_TCP)
+		pmap = pmap_getmaps(server_addr);
+	else
+		pmap = pmap_getmaps_udp(server_addr);

  	while (pmap) {
  		if (pmap->pml_map.pm_prog != prog)
@@ -877,3 +883,95 @@
          return port;
  }
  #endif
+
+/* added 30 June 2003, dkegel@ixiacom.com; modified to use udp */
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
+static char sccsid[] = "@(#)pmap_getmaps.c 1.10 87/08/11 Copyr 1984 Sun Micro";
+#endif
+
+/*
+ * pmap_getmap.c
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
+#include <libintl.h>
+
+/*
+ * Get a copy of the current port maps.
+ * Calls the pmap service remotely to do get the maps.
+ */
+struct pmaplist *
+pmap_getmaps_udp (struct sockaddr_in *address)
+{
+  struct pmaplist *head = (struct pmaplist *) NULL;
+  int socket = -1;
+  struct timeval minutetimeout;
+  struct timeval retry;
+  CLIENT *client;
+
+  minutetimeout.tv_sec = 60;
+  minutetimeout.tv_usec = 0;
+  address->sin_port = htons (PMAPPORT);
+#if 0
+  client = clnttcp_create (address, PMAPPROG,
+			   PMAPVERS, &socket, 50, 500);
+#else
+  retry.tv_sec = 5;
+  retry.tv_usec = 0;
+  client = clntudp_create (address, PMAPPROG,
+				PMAPVERS, retry, &socket);
+#endif
+  if (client != (CLIENT *) NULL)
+    {
+      if (CLNT_CALL (client, PMAPPROC_DUMP, (xdrproc_t)xdr_void, NULL,
+		     (xdrproc_t)xdr_pmaplist, (caddr_t)&head,
+		     minutetimeout) != RPC_SUCCESS)
+	{
+	  clnt_perror (client, _("pmap_getmaps rpc problem"));
+	}
+      CLNT_DESTROY (client);
+    }
+  /* (void)close(socket); CLNT_DESTROY already closed it */
+  address->sin_port = 0;
+  return head;
+}
+



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
