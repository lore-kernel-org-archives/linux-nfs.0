From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/23] umount.nfs: move nfs_call_umount to network.c
Date: Sat, 28 Jul 2007 17:49:43 -0400
Message-ID: <20070728214943.21871.63781.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEuAU-0007QV-J4
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:49:46 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IEuAY-00037e-C5
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:49:50 -0700
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

nfs_call_umount() is shared by nfsmount.c and nfsumount.c, and manages a
network function (building the RPC umount call to the server's MNT daemon).
So move it to network.c with other network-related functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c   |   35 +++++++++++++++++++++++++++++++++--
 utils/mount/network.h   |    7 +++----
 utils/mount/nfsumount.c |   37 -------------------------------------
 utils/mount/nfsumount.h |    1 -
 4 files changed, 36 insertions(+), 44 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index ab8cfb7..b04491c 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -245,7 +245,7 @@ out_ok:
 	return 1;
 }
 
-int probe_nfsport(clnt_addr_t *nfs_server)
+static int probe_nfsport(clnt_addr_t *nfs_server)
 {
 	struct pmap *pmap = &nfs_server->pmap;
 
@@ -258,7 +258,7 @@ int probe_nfsport(clnt_addr_t *nfs_server)
 		return probe_port(nfs_server, probe_nfs2_only, probe_udp_only);
 }
 
-int probe_mntport(clnt_addr_t *mnt_server)
+static int probe_mntport(clnt_addr_t *mnt_server)
 {
 	struct pmap *pmap = &mnt_server->pmap;
 
@@ -362,3 +362,34 @@ int start_statd(void)
 
 	return 0;
 }
+
+int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
+{
+	CLIENT *clnt;
+	enum clnt_stat res = 0;
+	int msock;
+
+	switch (mnt_server->pmap.pm_vers) {
+	case 3:
+	case 2:
+	case 1:
+		if (!probe_mntport(mnt_server))
+			goto out_bad;
+		clnt = mnt_openclnt(mnt_server, &msock);
+		if (!clnt)
+			goto out_bad;
+		res = clnt_call(clnt, MOUNTPROC_UMNT,
+				(xdrproc_t) xdr_dirpath, (caddr_t)argp,
+				(xdrproc_t) xdr_void, NULL,
+				TIMEOUT);
+		mnt_closeclnt(clnt, msock);
+		if (res == RPC_SUCCESS)
+			return 1;
+		break;
+	default:
+		res = 1;
+		break;
+	}
+ out_bad:
+	return res;
+}
diff --git a/utils/mount/network.h b/utils/mount/network.h
index bb5b4da..83375f0 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -22,11 +22,10 @@
  */
 
 #include "conn.h"
+#include "mount.h"
 
-int nfs_gethostbyname(const char *, struct sockaddr_in *);
-
-int probe_mntport(clnt_addr_t *);
-int probe_nfsport(clnt_addr_t *);
 int probe_bothports(clnt_addr_t *, clnt_addr_t *);
+int nfs_gethostbyname(const char *, struct sockaddr_in *);
+int nfs_call_umount(clnt_addr_t *, dirpath *);
 
 int start_statd(void);
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 477f262..2d68e7e 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -53,43 +53,6 @@ int force;
 int lazy;
 int remount;
 
-static inline enum clnt_stat
-nfs_umount(dirpath *argp, CLIENT *clnt)
-{
-	return clnt_call(clnt, MOUNTPROC_UMNT,
-			 (xdrproc_t) xdr_dirpath, (caddr_t)argp,
-			 (xdrproc_t) xdr_void, NULL,
-			 TIMEOUT);
-}
-
-int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
-{
-	CLIENT *clnt;
-	enum clnt_stat res = 0;
-	int msock;
-
-	switch (mnt_server->pmap.pm_vers) {
-	case 3:
-	case 2:
-	case 1:
-		if (!probe_mntport(mnt_server))
-			goto out_bad;
-		clnt = mnt_openclnt(mnt_server, &msock);
-		if (!clnt)
-			goto out_bad;
-		res = nfs_umount(argp, clnt);
-		mnt_closeclnt(clnt, msock);
-		if (res == RPC_SUCCESS)
-			return 1;
-		break;
-	default:
-		res = 1;
-		break;
-	}
- out_bad:
-	return res;
-}
-
 int del_mtab(const char *spec, const char *node)
 {
 	int umnt_err, res;
diff --git a/utils/mount/nfsumount.h b/utils/mount/nfsumount.h
index 191118d..0d67d27 100644
--- a/utils/mount/nfsumount.h
+++ b/utils/mount/nfsumount.h
@@ -5,6 +5,5 @@
 #include "mount.h"
 
 int nfsumount(int, char **);
-int nfs_call_umount(clnt_addr_t *, dirpath *);
 
 #endif


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
