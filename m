From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/23] libnfs.a: move mnt_{open,
	close}clnt calls to utils/mount/network.c
Date: Sat, 28 Jul 2007 17:50:30 -0400
Message-ID: <20070728215030.21871.35838.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFGOr-0003iN-14
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 14:34:07 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IFGOu-0003vl-QH
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 14:34:09 -0700
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

It turns out that get_socket() accesses a global variable, "verbose," that
is only available in the mount command; yet it's in libnfs.a.  This creates
an undocumented API dependency that will bite someone someday.  This
mount-specific functionality doesn't really belong in libnfs.a anyway.

The simplest way to resolve this is to move all of the functions in
support/nfs/conn.c into utils/mount.  network.c seems like the logical
place to put these.  An added benefit is we eventually get to make
get_socket() static.

Let's start with the mnt_{open,close}clnt functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/conn.h |    5 -----
 support/nfs/conn.c     |   48 ------------------------------------------------
 utils/mount/network.c  |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/network.h  |    6 ++++++
 4 files changed, 53 insertions(+), 53 deletions(-)

diff --git a/support/include/conn.h b/support/include/conn.h
index 11f16ab..f21c10e 100644
--- a/support/include/conn.h
+++ b/support/include/conn.h
@@ -18,9 +18,6 @@
 #include <rpc/pmap_prot.h>
 #include <rpc/clnt.h>
 
-#define MNT_SENDBUFSIZE ((u_int)2048)
-#define MNT_RECVBUFSIZE ((u_int)1024)
-
 typedef struct {
 	char **hostname;
 	struct sockaddr_in saddr;
@@ -36,8 +33,6 @@ int clnt_ping(struct sockaddr_in *, const u_long, const u_long, const u_int,
 u_long nfsvers_to_mnt(const u_long);
 u_long mntvers_to_nfs(const u_long);
 int get_socket(struct sockaddr_in *, u_int, int, int);
-CLIENT * mnt_openclnt(clnt_addr_t *, int *);
-void mnt_closeclnt(CLIENT *, int);
 
 #endif /* _CONN_H */
 
diff --git a/support/nfs/conn.c b/support/nfs/conn.c
index 9b98682..cf080c2 100644
--- a/support/nfs/conn.c
+++ b/support/nfs/conn.c
@@ -190,51 +190,3 @@ clnt_ping(struct sockaddr_in *saddr, const u_long prog, const u_long vers,
 	else
 		return 0;
 }
-
-CLIENT *mnt_openclnt(clnt_addr_t *mnt_server, int *msock)
-{
-	struct sockaddr_in *mnt_saddr = &mnt_server->saddr;
-	struct pmap *mnt_pmap = &mnt_server->pmap;
-	CLIENT *clnt = NULL;
-
-	/* contact the mount daemon via TCP */
-	mnt_saddr->sin_port = htons((u_short)mnt_pmap->pm_port);
-	*msock = get_socket(mnt_saddr, mnt_pmap->pm_prot, TRUE, FALSE);
-	if (*msock == RPC_ANYSOCK) {
-		if (rpc_createerr.cf_error.re_errno == EADDRINUSE)
-			/* Probably in-use by a TIME_WAIT connection,
-			 * It is worth waiting a while and trying again.
-			 */
-			rpc_createerr.cf_stat = RPC_TIMEDOUT;
-		return NULL;
-	}
-
-	switch (mnt_pmap->pm_prot) {
-	case IPPROTO_UDP:
-		clnt = clntudp_bufcreate(mnt_saddr,
-					 mnt_pmap->pm_prog, mnt_pmap->pm_vers,
-					 RETRY_TIMEOUT, msock,
-					 MNT_SENDBUFSIZE, MNT_RECVBUFSIZE);
-		break;
-	case IPPROTO_TCP:
-		clnt = clnttcp_create(mnt_saddr,
-				      mnt_pmap->pm_prog, mnt_pmap->pm_vers,
-				      msock,
-				      MNT_SENDBUFSIZE, MNT_RECVBUFSIZE);
-		break;
-	}
-	if (clnt) {
-		/* try to mount hostname:dirname */
-		clnt->cl_auth = authunix_create_default();
-		return clnt;
-	}
-	return NULL;
-}
-
-void mnt_closeclnt(CLIENT *clnt, int msock)
-{
-	auth_destroy(clnt->cl_auth);
-	clnt_destroy(clnt);
-	close(msock);
-}
-
diff --git a/utils/mount/network.c b/utils/mount/network.c
index c997c4c..08b1f99 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -429,3 +429,50 @@ int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
 		return 1;
 	return 0;
 }
+
+CLIENT *mnt_openclnt(clnt_addr_t *mnt_server, int *msock)
+{
+	struct sockaddr_in *mnt_saddr = &mnt_server->saddr;
+	struct pmap *mnt_pmap = &mnt_server->pmap;
+	CLIENT *clnt = NULL;
+
+	mnt_saddr->sin_port = htons((u_short)mnt_pmap->pm_port);
+	*msock = get_socket(mnt_saddr, mnt_pmap->pm_prot, TRUE, FALSE);
+	if (*msock == RPC_ANYSOCK) {
+		if (rpc_createerr.cf_error.re_errno == EADDRINUSE)
+			/*
+			 * Probably in-use by a TIME_WAIT connection,
+			 * It is worth waiting a while and trying again.
+			 */
+			rpc_createerr.cf_stat = RPC_TIMEDOUT;
+		return NULL;
+	}
+
+	switch (mnt_pmap->pm_prot) {
+	case IPPROTO_UDP:
+		clnt = clntudp_bufcreate(mnt_saddr,
+					 mnt_pmap->pm_prog, mnt_pmap->pm_vers,
+					 RETRY_TIMEOUT, msock,
+					 MNT_SENDBUFSIZE, MNT_RECVBUFSIZE);
+		break;
+	case IPPROTO_TCP:
+		clnt = clnttcp_create(mnt_saddr,
+				      mnt_pmap->pm_prog, mnt_pmap->pm_vers,
+				      msock,
+				      MNT_SENDBUFSIZE, MNT_RECVBUFSIZE);
+		break;
+	}
+	if (clnt) {
+		/* try to mount hostname:dirname */
+		clnt->cl_auth = authunix_create_default();
+		return clnt;
+	}
+	return NULL;
+}
+
+void mnt_closeclnt(CLIENT *clnt, int msock)
+{
+	auth_destroy(clnt->cl_auth);
+	clnt_destroy(clnt);
+	close(msock);
+}
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 83375f0..81a59da 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -24,8 +24,14 @@
 #include "conn.h"
 #include "mount.h"
 
+#define MNT_SENDBUFSIZE (2048U)
+#define MNT_RECVBUFSIZE (1024U)
+
 int probe_bothports(clnt_addr_t *, clnt_addr_t *);
 int nfs_gethostbyname(const char *, struct sockaddr_in *);
 int nfs_call_umount(clnt_addr_t *, dirpath *);
 
 int start_statd(void);
+
+CLIENT *mnt_openclnt(clnt_addr_t *, int *);
+void mnt_closeclnt(CLIENT *, int);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
