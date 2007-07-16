From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/17] mount.nfs: Move network functions into a common
	source	module
Date: Sun, 15 Jul 2007 23:15:34 -0400
Message-ID: <20070716031534.11209.52317.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAH3c-0001nw-Cu
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:32 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IAH3f-0000BQ-Hh
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:36 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

At a later point, I'd like to switch between the legacy nfs_mount_data
support and string-ified mount options by using a ./configure option to not
build utils/mount/nfsmount.c.

Thus it is necessary to remove some functions that are shared between
mount.nfs and umount.nfs so that these functions will remain whether
nfsmount.c is compiled or not.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/Makefile.am    |    2 
 utils/mount/mount.c        |    7 -
 utils/mount/nfsmount.c     |  264 -------------------------------------
 utils/mount/nfsmount_net.c |  318 ++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/nfsmount_net.h |   31 ++++
 utils/mount/nfsumount.c    |    4 -
 6 files changed, 353 insertions(+), 273 deletions(-)

diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
index b7d6b82..47bfa5b 100644
--- a/utils/mount/Makefile.am
+++ b/utils/mount/Makefile.am
@@ -9,7 +9,7 @@ man5_MANS	= nfs.man
 
 sbin_PROGRAMS	= mount.nfs
 EXTRA_DIST = nfsmount.x $(man8_MANS) $(man5_MANS)
-mount_nfs_SOURCES = mount.c nfsmount_err.c \
+mount_nfs_SOURCES = mount.c nfsmount_err.c nfsmount_net.c \
 		    nfsmount.c nfs4mount.c \
 		    nfsumount.c \
 		    mount_constants.h nfsmount_err.h \
diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 14f70de..c7cb896 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -42,6 +42,7 @@
 #include "nfsumount.h"
 #include "mount.h"
 #include "nfsmount_err.h"
+#include "nfsmount_net.h"
 
 char *progname;
 int nfs_mount_data_version;
@@ -344,12 +345,6 @@ static int chk_mountpoint(char *mount_point)
 	return 0;
 }
 
-extern u_short getport(
-	struct sockaddr_in *saddr,
-	u_long prog,
-	u_long vers,
-	u_int prot);
-
 static int probe_statd()
 {
 	struct sockaddr_in addr;
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 8c261d9..368793c 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -64,6 +64,7 @@
 #include "mount_constants.h"
 #include "nls.h"
 #include "nfsmount_err.h"
+#include "nfsmount_net.h"
 
 #ifndef NFS_PORT
 #define NFS_PORT 2049
@@ -93,269 +94,6 @@ extern int sloppy;
 
 extern int linux_version_code();
 
-static const unsigned int probe_udp_only[] = {
-	IPPROTO_UDP,
-	0,
-};
-
-static const unsigned int probe_udp_first[] = {
-	IPPROTO_UDP,
-	IPPROTO_TCP,
-	0,
-};
-
-static const unsigned int probe_tcp_first[] = {
-	IPPROTO_TCP,
-	IPPROTO_UDP,
-	0,
-};
-
-static const unsigned long probe_nfs2_only[] = {
-	2,
-	0,
-};
-
-static const unsigned long probe_nfs3_first[] = {
-	3,
-	2,
-	0,
-};
-
-static const unsigned long probe_mnt1_first[] = {
-	1,
-	2,
-	0,
-};
-
-static const unsigned long probe_mnt3_first[] = {
-	3,
-	1,
-	2,
-	0,
-};
-
-int nfs_gethostbyname(const char *, struct sockaddr_in *);
-int nfs_gethostbyname(const char *hostname, struct sockaddr_in *saddr)
-{
-	struct hostent *hp;
-
-	saddr->sin_family = AF_INET;
-	if (!inet_aton(hostname, &saddr->sin_addr)) {
-		if ((hp = gethostbyname(hostname)) == NULL) {
-			fprintf(stderr, _("mount: can't get address for %s\n"),
-				hostname);
-			return 0;
-		} else {
-			if (hp->h_length > sizeof(*saddr)) {
-				fprintf(stderr,
-					_("mount: got bad hp->h_length\n"));
-				hp->h_length = sizeof(*saddr);
-			}
-			memcpy(&saddr->sin_addr, hp->h_addr, hp->h_length);
-		}
-	}
-	return 1;
-}
-
-/*
- * getport() is very similar to pmap_getport() with
- * the exception this version uses a non-reserve ports 
- * instead of reserve ports since reserve ports
- * are not needed for pmap requests.
- */
-u_short
-getport(
-	struct sockaddr_in *saddr, 
-	u_long prog, 
-	u_long vers, 
-	u_int prot)
-{
-	u_short port = 0;
-	int    socket;
-	CLIENT *clnt = NULL;
-	struct pmap parms;
-	enum clnt_stat stat;
-
-	saddr->sin_port = htons (PMAPPORT);
-	socket = get_socket(saddr, prot, FALSE, FALSE);
-
-	switch (prot) {
-	case IPPROTO_UDP:
-		clnt = clntudp_bufcreate(saddr,
-					 PMAPPROG, PMAPVERS, TIMEOUT, &socket,
-					 UDPMSGSIZE, UDPMSGSIZE);
-		break;
-	case IPPROTO_TCP:
-		clnt = clnttcp_create(saddr,
-			PMAPPROG, PMAPVERS, &socket, 50, 500);
-		break;
-	}
-	if (clnt != NULL) {
-		parms.pm_prog = prog;
-		parms.pm_vers = vers;
-		parms.pm_prot = prot;
-		parms.pm_port = 0;    /* not needed or used */
-
-		stat = clnt_call(clnt, PMAPPROC_GETPORT, (xdrproc_t)xdr_pmap,
-			(caddr_t)&parms, (xdrproc_t)xdr_u_short, (caddr_t)&port, TIMEOUT);
-		if (stat) {
-			clnt_geterr(clnt, &rpc_createerr.cf_error);
-			rpc_createerr.cf_stat = stat;
-		}
-		clnt_destroy(clnt);
-		if (stat != RPC_SUCCESS)
-			port = 0;
-		else if (port == 0)
-			rpc_createerr.cf_stat = RPC_PROGNOTREGISTERED;
-	}
-	if (socket != 1)
-		close(socket);
-
-	return port;
-}
-
-/*
- * Use the portmapper to discover whether or not the service we want is
- * available. The lists 'versions' and 'protos' define ordered sequences
- * of service versions and udp/tcp protocols to probe for.
- */
-static int
-probe_port(clnt_addr_t *server, 
-	   const u_long *versions,
-	   const u_int *protos)
-{
-	struct sockaddr_in *saddr = &server->saddr;
-	struct pmap *pmap = &server->pmap;
-	const u_long prog = pmap->pm_prog, *p_vers;
-	const u_int prot = (u_int)pmap->pm_prot,
-		*p_prot;
-	const u_short port = (u_short) pmap->pm_port;
-	u_long vers = pmap->pm_vers;
-	u_short p_port;
-	p_prot = prot ? &prot : protos;
-	p_vers = vers ? &vers : versions;
-	rpc_createerr.cf_stat = 0;
-	for (;;) {
-		saddr->sin_port = htons(PMAPPORT);
-		p_port = getport(saddr, prog, *p_vers, *p_prot);
-		if (p_port) {
-			if (!port || port == p_port) {
-				saddr->sin_port = htons(p_port);
-				if (verbose) {
-					fprintf(stderr, 
-						"mount: trying %s prog %ld vers %ld prot %s port %d\n", 
-						inet_ntoa(saddr->sin_addr), prog, *p_vers,
-						*p_prot == IPPROTO_UDP ? "udp" : "tcp", p_port);
-				}
-				if (clnt_ping(saddr, prog, *p_vers, *p_prot, NULL))
-					goto out_ok;
-				if (rpc_createerr.cf_stat == RPC_TIMEDOUT)
-					goto out_bad;
-			}
-		}
-		if (rpc_createerr.cf_stat != RPC_PROGNOTREGISTERED) 
-			goto out_bad;
-
-		if (!prot) {
-			if (*++p_prot)
-				continue;
-			p_prot = protos;
-		}
-		if (vers == pmap->pm_vers) {
-			p_vers = versions;
-			vers = 0;
-		}
-		if (vers || !*++p_vers)
-			break;
-	}
-out_bad:
-	return 0;
-
- out_ok:
-	if (!vers)
-		pmap->pm_vers = *p_vers;
-	if (!prot)
-		pmap->pm_prot = *p_prot;
-	if (!port)
-		pmap->pm_port = p_port;
-	rpc_createerr.cf_stat = 0;
-	return 1;
-}
-
-static int probe_nfsport(clnt_addr_t *nfs_server)
-{
-	struct pmap *pmap = &nfs_server->pmap;
-
-	if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
-		return 1;
-
-	if (nfs_mount_data_version >= 4)
-		return probe_port(nfs_server, probe_nfs3_first, probe_tcp_first);
-	else
-		return probe_port(nfs_server, probe_nfs2_only, probe_udp_only);
-}
-
-int probe_mntport(clnt_addr_t *mnt_server)
-{
-	struct pmap *pmap = &mnt_server->pmap;
-
-	if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
-		return 1;
-
-	if (nfs_mount_data_version >= 4)
-		return probe_port(mnt_server, probe_mnt3_first, probe_udp_first);
-	else
-		return probe_port(mnt_server, probe_mnt1_first, probe_udp_only);
-}
-
-static int
-probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
-{
-	struct pmap *nfs_pmap = &nfs_server->pmap;
-	struct pmap *mnt_pmap = &mnt_server->pmap;
-	struct pmap save_nfs, save_mnt;
-	int res;
-	unsigned long *probe_vers;
-
-	if (mnt_pmap->pm_vers && !nfs_pmap->pm_vers)
-		nfs_pmap->pm_vers = mntvers_to_nfs(mnt_pmap->pm_vers);
-	else if (nfs_pmap->pm_vers && !mnt_pmap->pm_vers)
-		mnt_pmap->pm_vers = nfsvers_to_mnt(nfs_pmap->pm_vers);
-	if (nfs_pmap->pm_vers)
-		goto version_fixed;
-
-	memcpy(&save_nfs, nfs_pmap, sizeof(save_nfs));
-	memcpy(&save_mnt, mnt_pmap, sizeof(save_mnt));
-	probe_vers = (nfs_mount_data_version >= 4) ?
-			probe_mnt3_first : probe_mnt1_first;
-
-	for (; *probe_vers; probe_vers++) {
-		nfs_pmap->pm_vers = mntvers_to_nfs(*probe_vers);
-		if ((res = probe_nfsport(nfs_server) != 0)) {
-			mnt_pmap->pm_vers = nfsvers_to_mnt(nfs_pmap->pm_vers);
-			if ((res = probe_mntport(mnt_server)) != 0)
-				return 1;
-			memcpy(mnt_pmap, &save_mnt, sizeof(*mnt_pmap));
-		}
-		switch (rpc_createerr.cf_stat) {
-		case RPC_PROGVERSMISMATCH:
-		case RPC_PROGNOTREGISTERED:
-			break;
-		default:
-			goto out_bad;
-		}
-		memcpy(nfs_pmap, &save_nfs, sizeof(*nfs_pmap));
-	}
-
-out_bad:
-	return 0;
-
-version_fixed:
-	if (!probe_nfsport(nfs_server))
-		goto out_bad;
-	return probe_mntport(mnt_server);
-}
-
 static inline enum clnt_stat
 nfs3_mount(CLIENT *clnt, mnt3arg_t *mnt3arg, mnt3res_t *mnt3res)
 {
diff --git a/utils/mount/nfsmount_net.c b/utils/mount/nfsmount_net.c
new file mode 100644
index 0000000..71762d6
--- /dev/null
+++ b/utils/mount/nfsmount_net.c
@@ -0,0 +1,318 @@
+/*
+ * nfsmount_net.c -- Provide common network functions for NFS mount/umount
+ *
+ * Copyright (C) 2007 Oracle.  All rights reserved.
+ * Copyright (C) 2007 Chuck Lever <chuck.lever@oracle.com>
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
+ */
+
+#include <ctype.h>
+#include <unistd.h>
+#include <stdio.h>
+#include <string.h>
+#include <stdlib.h>
+#include <errno.h>
+#include <netdb.h>
+#include <time.h>
+#include <rpc/rpc.h>
+#include <rpc/pmap_prot.h>
+#include <rpc/pmap_clnt.h>
+#include <sys/socket.h>
+
+#include "conn.h"
+#include "xcommon.h"
+#include "mount.h"
+#include "nls.h"
+#include "nfsumount.h"
+#include "nfs_mount.h"
+#include "mount_constants.h"
+#include "nfsmount_net.h"
+
+#ifdef HAVE_RPCSVC_NFS_PROT_H
+#include <rpcsvc/nfs_prot.h>
+#else
+#include <linux/nfs.h>
+#define nfsstat nfs_stat
+#endif
+
+#ifndef NFS_PORT
+#define NFS_PORT 2049
+#endif
+
+extern int nfs_mount_data_version;
+extern char *progname;
+extern int verbose;
+
+static const unsigned int probe_udp_only[] = {
+	IPPROTO_UDP,
+	0,
+};
+
+static const unsigned int probe_udp_first[] = {
+	IPPROTO_UDP,
+	IPPROTO_TCP,
+	0,
+};
+
+static const unsigned int probe_tcp_first[] = {
+	IPPROTO_TCP,
+	IPPROTO_UDP,
+	0,
+};
+
+static const unsigned long probe_nfs2_only[] = {
+	2,
+	0,
+};
+
+static const unsigned long probe_nfs3_first[] = {
+	3,
+	2,
+	0,
+};
+
+static const unsigned long probe_mnt1_first[] = {
+	1,
+	2,
+	0,
+};
+
+static const unsigned long probe_mnt3_first[] = {
+	3,
+	1,
+	2,
+	0,
+};
+
+int nfs_gethostbyname(const char *hostname, struct sockaddr_in *saddr)
+{
+	struct hostent *hp;
+
+	saddr->sin_family = AF_INET;
+	if (!inet_aton(hostname, &saddr->sin_addr)) {
+		if ((hp = gethostbyname(hostname)) == NULL) {
+			nfs_error(_("mount: can't get address for %s\n"),
+				hostname);
+			return 0;
+		} else {
+			if (hp->h_length > sizeof(*saddr)) {
+				nfs_error(_("mount: got bad hp->h_length\n"));
+				hp->h_length = sizeof(*saddr);
+			}
+			memcpy(&saddr->sin_addr, hp->h_addr, hp->h_length);
+		}
+	}
+	return 1;
+}
+
+/*
+ * getport() is very similar to pmap_getport() with
+ * the exception this version uses a non-reserve ports
+ * instead of reserve ports since reserve ports
+ * are not needed for pmap requests.
+ */
+unsigned short getport(struct sockaddr_in *saddr, unsigned long prog,
+			unsigned long vers, unsigned int prot)
+{
+	unsigned short port = 0;
+	int socket;
+	CLIENT *clnt = NULL;
+	struct pmap parms;
+	enum clnt_stat stat;
+
+	saddr->sin_port = htons (PMAPPORT);
+	socket = get_socket(saddr, prot, FALSE, FALSE);
+
+	switch (prot) {
+	case IPPROTO_UDP:
+		clnt = clntudp_bufcreate(saddr,
+					 PMAPPROG, PMAPVERS, TIMEOUT, &socket,
+					 UDPMSGSIZE, UDPMSGSIZE);
+		break;
+	case IPPROTO_TCP:
+		clnt = clnttcp_create(saddr,
+			PMAPPROG, PMAPVERS, &socket, 50, 500);
+		break;
+	}
+	if (clnt != NULL) {
+		parms.pm_prog = prog;
+		parms.pm_vers = vers;
+		parms.pm_prot = prot;
+		parms.pm_port = 0;    /* not needed or used */
+
+		stat = clnt_call(clnt, PMAPPROC_GETPORT, (xdrproc_t)xdr_pmap,
+			(caddr_t)&parms, (xdrproc_t)xdr_u_short, (caddr_t)&port, TIMEOUT);
+		if (stat) {
+			clnt_geterr(clnt, &rpc_createerr.cf_error);
+			rpc_createerr.cf_stat = stat;
+		}
+		clnt_destroy(clnt);
+		if (stat != RPC_SUCCESS)
+			port = 0;
+		else if (port == 0)
+			rpc_createerr.cf_stat = RPC_PROGNOTREGISTERED;
+	}
+	if (socket != 1)
+		close(socket);
+
+	return port;
+}
+
+/*
+ * Use the portmapper to discover whether or not the service we want is
+ * available. The lists 'versions' and 'protos' define ordered sequences
+ * of service versions and udp/tcp protocols to probe for.
+ */
+static int probe_port(clnt_addr_t *server, const unsigned long *versions,
+			const unsigned int *protos)
+{
+	struct sockaddr_in *saddr = &server->saddr;
+	struct pmap *pmap = &server->pmap;
+	const unsigned long prog = pmap->pm_prog, *p_vers;
+	const unsigned int prot = (u_int)pmap->pm_prot, *p_prot;
+	const u_short port = (u_short) pmap->pm_port;
+	unsigned long vers = pmap->pm_vers;
+	unsigned short p_port;
+
+	p_prot = prot ? &prot : protos;
+	p_vers = vers ? &vers : versions;
+	rpc_createerr.cf_stat = 0;
+	for (;;) {
+		saddr->sin_port = htons(PMAPPORT);
+		p_port = getport(saddr, prog, *p_vers, *p_prot);
+		if (p_port) {
+			if (!port || port == p_port) {
+				saddr->sin_port = htons(p_port);
+				if (verbose) {
+					printf(_("%s: trying %s prog %ld vers "
+						"%ld prot %s port %d\n"),
+						progname,
+						inet_ntoa(saddr->sin_addr),
+						prog, *p_vers,
+						*p_prot == IPPROTO_UDP ?
+							"udp" : "tcp",
+						p_port);
+                                }
+				if (clnt_ping(saddr, prog, *p_vers, *p_prot, NULL))
+					goto out_ok;
+				if (rpc_createerr.cf_stat == RPC_TIMEDOUT)
+					goto out_bad;
+			}
+		}
+		if (rpc_createerr.cf_stat != RPC_PROGNOTREGISTERED)
+			goto out_bad;
+
+		if (!prot) {
+			if (*++p_prot)
+				continue;
+			p_prot = protos;
+		}
+		if (vers == pmap->pm_vers) {
+			p_vers = versions;
+			vers = 0;
+		}
+		if (vers || !*++p_vers)
+			break;
+	}
+
+out_bad:
+	return 0;
+
+out_ok:
+	if (!vers)
+		pmap->pm_vers = *p_vers;
+	if (!prot)
+		pmap->pm_prot = *p_prot;
+	if (!port)
+		pmap->pm_port = p_port;
+	rpc_createerr.cf_stat = 0;
+	return 1;
+}
+
+int probe_nfsport(clnt_addr_t *nfs_server)
+{
+	struct pmap *pmap = &nfs_server->pmap;
+
+	if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
+		return 1;
+
+	if (nfs_mount_data_version >= 4)
+		return probe_port(nfs_server, probe_nfs3_first, probe_tcp_first);
+	else
+		return probe_port(nfs_server, probe_nfs2_only, probe_udp_only);
+}
+
+int probe_mntport(clnt_addr_t *mnt_server)
+{
+	struct pmap *pmap = &mnt_server->pmap;
+
+	if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
+		return 1;
+
+	if (nfs_mount_data_version >= 4)
+		return probe_port(mnt_server, probe_mnt3_first, probe_udp_first);
+	else
+		return probe_port(mnt_server, probe_mnt1_first, probe_udp_only);
+}
+
+int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
+{
+	struct pmap *nfs_pmap = &nfs_server->pmap;
+	struct pmap *mnt_pmap = &mnt_server->pmap;
+	struct pmap save_nfs, save_mnt;
+	int res;
+	const unsigned long *probe_vers;
+
+	if (mnt_pmap->pm_vers && !nfs_pmap->pm_vers)
+		nfs_pmap->pm_vers = mntvers_to_nfs(mnt_pmap->pm_vers);
+	else if (nfs_pmap->pm_vers && !mnt_pmap->pm_vers)
+		mnt_pmap->pm_vers = nfsvers_to_mnt(nfs_pmap->pm_vers);
+	if (nfs_pmap->pm_vers)
+		goto version_fixed;
+
+	memcpy(&save_nfs, nfs_pmap, sizeof(save_nfs));
+	memcpy(&save_mnt, mnt_pmap, sizeof(save_mnt));
+	probe_vers = (nfs_mount_data_version >= 4) ?
+			probe_mnt3_first : probe_mnt1_first;
+
+	for (; *probe_vers; probe_vers++) {
+		nfs_pmap->pm_vers = mntvers_to_nfs(*probe_vers);
+		if ((res = probe_nfsport(nfs_server) != 0)) {
+			mnt_pmap->pm_vers = nfsvers_to_mnt(nfs_pmap->pm_vers);
+			if ((res = probe_mntport(mnt_server)) != 0)
+				return 1;
+			memcpy(mnt_pmap, &save_mnt, sizeof(*mnt_pmap));
+		}
+		switch (rpc_createerr.cf_stat) {
+		case RPC_PROGVERSMISMATCH:
+		case RPC_PROGNOTREGISTERED:
+			break;
+		default:
+			goto out_bad;
+		}
+		memcpy(nfs_pmap, &save_nfs, sizeof(*nfs_pmap));
+	}
+
+out_bad:
+	return 0;
+
+version_fixed:
+	if (!probe_nfsport(nfs_server))
+		goto out_bad;
+	return probe_mntport(mnt_server);
+}
diff --git a/utils/mount/nfsmount_net.h b/utils/mount/nfsmount_net.h
new file mode 100644
index 0000000..931f721
--- /dev/null
+++ b/utils/mount/nfsmount_net.h
@@ -0,0 +1,31 @@
+/*
+ * nfsmount_net.h -- Provide common network functions for NFS mount/umount
+ *
+ * Copyright (C) 2007 Oracle.  All rights reserved.
+ * Copyright (C) 2007 Chuck Lever <chuck.lever@oracle.com>
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
+ */
+
+#include "conn.h"
+
+int nfs_gethostbyname(const char *, struct sockaddr_in *);
+unsigned short getport(struct sockaddr_in *, unsigned long,
+			unsigned long, unsigned int);
+int probe_mntport(clnt_addr_t *);
+int probe_nfsport(clnt_addr_t *);
+int probe_bothports(clnt_addr_t *, clnt_addr_t *);
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 4069a38..05d13dd 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -35,6 +35,7 @@
 #include "mount.h"
 #include "nfsumount.h"
 #include "nfsmount_err.h"
+#include "nfsmount_net.h"
 
 #if !defined(MNT_FORCE)
 /* dare not try to include <linux/mount.h> -- lots of errors */
@@ -52,9 +53,6 @@ int force;
 int lazy;
 int remount;
 
-extern int probe_mntport(clnt_addr_t *);
-extern int nfs_gethostbyname(const char *, struct sockaddr_in *);
-
 static inline enum clnt_stat
 nfs_umount(dirpath *argp, CLIENT *clnt)
 {


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
