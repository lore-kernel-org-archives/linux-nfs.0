From: mike@waychison.com
Subject: [PATCH/RFC 2/2] make mount(8)/umount(8) use
	clntproxy_create
Date: Mon, 7 Mar 2005 15:54:38 -0500 (EST)
Message-ID: <37102.66.11.176.22.1110228878.squirrel@webmail1.hrnoc.net>
References: <37086.66.11.176.22.1110228763.squirrel@webmail1.hrnoc.net>
	<37093.66.11.176.22.1110228819.squirrel@webmail1.hrnoc.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;boundary="----=_20050307135438_50918"
Cc: mike@waychison.com
In-Reply-To: <37093.66.11.176.22.1110228819.squirrel@webmail1.hrnoc.net>
To: "linux-nfs" <nfs@lists.sourceforge.net>,
        "autofs mailing list" <autofs@linux.kernel.org>
List-Unsubscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/pipermail/autofs>
List-Post: <mailto:autofs@linux.kernel.org>
List-Help: <mailto:autofs-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=subscribe>
Sender: autofs-bounces@linux.kernel.org
Errors-To: autofs-bounces@linux.kernel.org
List-ID: <nfs.lists.sourceforge.net>

------=_20050307135438_50918
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit


------=_20050307135438_50918
Content-Type: text/x-patch; name="make_nfsmount_use_clnt_proxy.patch"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename="make_nfsmount_use_clnt_proxy.patch"

This patch makes nfs mounting and unmounting use the rpcproxyd interface.

Index: util-linux-2.12p/mount/nfsmount.c
===================================================================
--- util-linux-2.12p.orig/mount/nfsmount.c	2005-03-03 18:58:40.000000000 -0500
+++ util-linux-2.12p/mount/nfsmount.c	2005-03-07 15:21:17.625410280 -0500
@@ -26,6 +26,9 @@
  * 
  * Modified by Olaf Kirch and Trond Myklebust for new NFS code,
  * plus NFSv3 stuff.
+ *
+ * 2005-03-02 Mike Waychison <mike@waychison.com>
+ *  - Use the clnt_proxy interface when talking to mountd.
  */
 
 /*
@@ -65,6 +68,8 @@
 
 #include "nls.h"
 
+#include "clnt_proxy.h"
+
 #ifndef NFS_PORT
 #define NFS_PORT 2049
 #endif
@@ -135,7 +140,9 @@
       long unsigned port,
       int nfs_mount_version)
 {
-	struct pmaplist *pmap;
+	CLIENT *clnt;
+	struct pmaplist *pmap = NULL;
+	struct timeval tv = {10, 0};
 	static struct pmap p = {0, 0, 0, 0};
 
 	if (version > MAX_NFSPROT)
@@ -147,8 +154,26 @@
 	p.pm_prot = proto;
 	p.pm_port = port;
 
-	server_addr->sin_port = PMAPPORT;
-	pmap = pmap_getmaps(server_addr);
+	server_addr->sin_port = htons(PMAPPORT);
+
+	clnt = clntproxy_create(server_addr->sin_family,
+			 SOCK_STREAM,
+			 (struct sockaddr *)server_addr,
+			 sizeof(*server_addr),
+			 PMAPPROG,
+			 PMAPVERS);
+	if (!clnt)
+		clnt = clntproxy_create(server_addr->sin_family,
+					SOCK_DGRAM,
+					(struct sockaddr *)server_addr,
+					sizeof(*server_addr),
+					PMAPPROG,
+					PMAPVERS);
+	if (clnt)
+		clnt_call(clnt, PMAPPROC_DUMP,
+			  (xdrproc_t) xdr_void, (caddr_t) NULL,
+			  (xdrproc_t) xdr_pmaplist, (caddr_t) &pmap,
+			  tv);
 
 	while (pmap) {
 		if (pmap->pml_map.pm_prog != prog)
@@ -167,6 +192,10 @@
 	next:
 		pmap = pmap->pml_next;
 	}
+
+	if (clnt)
+		clnt_destroy(clnt);
+
 	if (!p.pm_vers)
 		p.pm_vers = MOUNTVERS;
 	if (!p.pm_prot)
@@ -207,7 +236,7 @@
 	struct sockaddr_in server_addr;
 	struct sockaddr_in mount_server_addr;
 	struct pmap *pm_mnt;
-	int msock, fsock;
+	int fsock;
 	struct timeval retry_timeout;
 	union {
 		struct fhstatus nfsv2;
@@ -231,7 +260,7 @@
 	nfs_mount_version = *nfs_mount_vers;
 
 	retval = EX_FAIL;
-	msock = fsock = -1;
+	fsock = -1;
 	mclient = NULL;
 	if (strlen(spec) >= sizeof(hostdir)) {
 		fprintf(stderr, _("mount: "
@@ -583,29 +612,15 @@
 
 			/* contact the mount daemon via TCP */
 			mount_server_addr.sin_port = htons(pm_mnt->pm_port);
-			msock = RPC_ANYSOCK;
 
-			switch (pm_mnt->pm_prot) {
-			case IPPROTO_UDP:
-				mclient = clntudp_create(&mount_server_addr,
-							 pm_mnt->pm_prog,
-							 pm_mnt->pm_vers,
-							 retry_timeout,
-							 &msock);
-				if (mclient)
-					break;
-				mount_server_addr.sin_port =
-					htons(pm_mnt->pm_port);
-				msock = RPC_ANYSOCK;
-			case IPPROTO_TCP:
-				mclient = clnttcp_create(&mount_server_addr,
-							 pm_mnt->pm_prog,
-							 pm_mnt->pm_vers,
-							 &msock, 0, 0);
-				break;
-			default:
-				mclient = 0;
-			}
+			mclient = clntproxy_create(
+					mount_server_addr.sin_family,
+					pm_mnt->pm_prot == IPPROTO_TCP ?
+						SOCK_STREAM : SOCK_DGRAM,
+					(struct sockaddr *)&mount_server_addr,
+					sizeof(mount_server_addr),
+					pm_mnt->pm_prog,
+					pm_mnt->pm_vers);
 
 			if (mclient) {
 				/* try to mount hostname:dirname */
@@ -648,7 +663,6 @@
 				auth_destroy(mclient->cl_auth);
 				clnt_destroy(mclient);
 				mclient = 0;
-				close(msock);
 			} else {
 				if (!running_bg && prevt == 0)
 					clnt_pcreateerror("mount");
@@ -728,9 +742,34 @@
 		goto fail;
 	}
 	if (port == 0) {
-		server_addr.sin_port = PMAPPORT;
-		port = pmap_getport(&server_addr, nfsprog, nfsvers,
-				    tcp ? IPPROTO_TCP : IPPROTO_UDP);
+		CLIENT *clnt;
+
+		server_addr.sin_port = htons(PMAPPORT);
+		clnt = clntproxy_create(server_addr.sin_family,
+				 SOCK_STREAM,
+				 (struct sockaddr *)&server_addr,
+				 sizeof(server_addr),
+				 PMAPPROG,
+			 PMAPVERS);
+		if (!clnt)
+			clnt = clntproxy_create(server_addr.sin_family,
+						SOCK_DGRAM,
+						(struct sockaddr *)&server_addr,
+						sizeof(server_addr),
+						PMAPPROG,
+						PMAPVERS);
+		if (clnt) {
+			struct pmap pmap = {0};
+			struct timeval tv = {10, 0};
+			pmap.pm_prog = nfsprog;
+			pmap.pm_vers = nfsvers;
+			pmap.pm_prot = tcp ? IPPROTO_TCP : IPPROTO_UDP;
+			clnt_call(clnt, PMAPPROC_GETPORT,
+				  (xdrproc_t) xdr_pmap, (caddr_t) &pmap,
+				  (xdrproc_t) xdr_u_long, (caddr_t) &port,
+				  tv);
+			clnt_destroy(clnt);
+		}
 #if 1
 		/* Here we check to see if user is mounting with the
 		 * tcp option.  If so, and if the portmap returns a
@@ -776,19 +815,11 @@
 
 	auth_destroy(mclient->cl_auth);
 	clnt_destroy(mclient);
-	close(msock);
 	return 0;
 
 	/* abort */
 
  fail:
-	if (msock != -1) {
-		if (mclient) {
-			auth_destroy(mclient->cl_auth);
-			clnt_destroy(mclient);
-		}
-		close(msock);
-	}
 	if (fsock != -1)
 		close(fsock);
 	return retval;
Index: util-linux-2.12p/mount/Makefile
===================================================================
--- util-linux-2.12p.orig/mount/Makefile	2005-03-03 18:58:40.000000000 -0500
+++ util-linux-2.12p/mount/Makefile	2005-03-07 15:21:17.654405872 -0500
@@ -30,7 +30,7 @@
 MAYBE = pivot_root swapoff
 
 LO_OBJS = lomount.o $(LIB)/xstrncpy.o
-NFS_OBJS = nfsmount.o nfsmount_xdr.o nfsmount_clnt.o
+NFS_OBJS = nfsmount.o nfsmount_xdr.o nfsmount_clnt.o $(LIB)/clnt_proxy.o
 GEN_FILES = nfsmount.h nfsmount_xdr.c nfsmount_clnt.c
 
 all: $(PROGS)
@@ -54,7 +54,7 @@
 
 umount: umount.o fstab.o sundries.o xmalloc.o realpath.o mntent.o \
 	getusername.o get_label_uuid.o mount_by_label.o mount_blkid.o \
-	version.o $(LIB)/env.o $(LO_OBJS)
+	version.o $(LIB)/env.o $(LIB)/clnt_proxy.o $(LO_OBJS)
 	$(LINK) $^ -o $@ $(BLKID_LIB)
 
 swapon:	swapon.o version.o xmalloc.o \
Index: util-linux-2.12p/mount/umount.c
===================================================================
--- util-linux-2.12p.orig/mount/umount.c	2005-03-03 18:58:40.000000000 -0500
+++ util-linux-2.12p/mount/umount.c	2005-03-07 15:21:17.656405568 -0500
@@ -31,6 +31,8 @@
 #include <arpa/inet.h>
 #endif
 
+#include <clnt_proxy.h>
+
 #if defined(MNT_FORCE) && !defined(__sparc__) && !defined(__arm__)
 /* Interesting ... it seems libc knows about MNT_FORCE and presumably
    about umount2 as well -- need not do anything */
@@ -159,8 +161,8 @@
       struct sockaddr_in saddr;
       struct timeval pertry, try;
       enum clnt_stat clnt_stat;
+      int socket_type;
       int port = 0;
-      int so = RPC_ANYSOCK;
       struct hostent *hostp;
       char *hostname;
       char *dirname;
@@ -209,18 +211,21 @@
       if (opts && (p = strstr(opts, "tcp"))) {
 	   /* possibly: make sure option is not "notcp"
 	      possibly: try udp if tcp fails */
-	   if ((clp = clnttcp_create(&saddr, MOUNTPROG, MOUNTVERS,
-				     &so, 0, 0)) == NULL) {
-		clnt_pcreateerror("Cannot MOUNTPROG RPC (tcp)");
-		return 1;
-	   }
+	   socket_type = SOCK_STREAM;
       } else {
-           if ((clp = clntudp_create(&saddr, MOUNTPROG, MOUNTVERS,
-				     pertry, &so)) == NULL) {
-		clnt_pcreateerror("Cannot MOUNTPROG RPC");
-		return 1;
-	   }
+	   socket_type = SOCK_DGRAM;
+      }
+      clp = clntproxy_create(saddr.sin_family,
+			     socket_type,
+			     (struct sockaddr *)&saddr,
+			     sizeof(saddr),
+			     MOUNTPROG,
+			     MOUNTVERS);
+      if (!clp) {
+	      clnt_pcreateerror("Cannot MOUNTPROG RPC");
+	      return 1;
       }
+
       clp->cl_auth = authunix_create_default();
       try.tv_sec = 20;
       try.tv_usec = 0;
------=_20050307135438_50918
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
autofs mailing list
autofs@linux.kernel.org
http://linux.kernel.org/mailman/listinfo/autofs

------=_20050307135438_50918--
