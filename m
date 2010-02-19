Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.123]:52611 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753042Ab0BSXFa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Feb 2010 18:05:30 -0500
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH] nfs-utils: add and use nfs_authsys_create
Date: Fri, 19 Feb 2010 18:05:28 -0500
Message-Id: <1266620728-14574-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The current mount, umount and showmount code uses
authunix_create_default to get an auth handle. The one provided by glibc
returned a truncated list of groups when there were more than 16 groups.
libtirpc however currently does an abort() in this case, which causes
the program to crash and dump core.

nfs-utils just uses these auth handles for the MNT protocol, so the
group list doesn't make a lot of difference here. Add a new function
that creates an auth handle with a supplemental gids list that consists
only of the primary gid. Have nfs-utils use that function anywhere that
it currently uses authunix_create_default. Also, have the caller
properly check for a NULL return from that function.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 support/include/nfsrpc.h    |    3 +++
 support/nfs/rpc_socket.c    |   21 +++++++++++++++++++++
 utils/mount/network.c       |   15 ++++++++++++---
 utils/showmount/showmount.c |    8 +++++++-
 4 files changed, 43 insertions(+), 4 deletions(-)

diff --git a/support/include/nfsrpc.h b/support/include/nfsrpc.h
index 4db35ab..6ebefca 100644
--- a/support/include/nfsrpc.h
+++ b/support/include/nfsrpc.h
@@ -160,4 +160,7 @@ extern int		nfs_rpc_ping(const struct sockaddr *sap,
 				const unsigned short protocol,
 				const struct timeval *timeout);
 
+/* create AUTH_SYS handle with no supplemental groups */
+extern AUTH *			 nfs_authsys_create(void);
+
 #endif	/* !__NFS_UTILS_NFSRPC_H */
diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
index 0e20824..aa6a205 100644
--- a/support/nfs/rpc_socket.c
+++ b/support/nfs/rpc_socket.c
@@ -557,3 +557,24 @@ rpcprog_t nfs_getrpcbyname(const rpcprog_t program, const char *table[])
 
 	return program;
 }
+
+/*
+ * AUTH_SYS doesn't allow more than 16 gids in the supplemental group list.
+ * If there are more than that, trying to determine which ones to include
+ * in the list is problematic. This function creates an auth handle that
+ * only has the primary gid in the supplemental gids list. It's intended to
+ * be used for protocols where credentials really don't matter much (the MNT
+ * protocol, for instance).
+ */
+AUTH *
+nfs_authsys_create(void)
+{
+	char machname[MAXHOSTNAMELEN + 1];
+	uid_t	uid = geteuid();
+	gid_t	gid = getegid();
+
+	if (gethostname(machname, sizeof(machname)) == -1)
+		return NULL;
+
+	return authsys_create(machname, uid, gid, 1, &gid);
+}
diff --git a/utils/mount/network.c b/utils/mount/network.c
index 8dc183a..c541257 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -857,7 +857,14 @@ int nfs_advise_umount(const struct sockaddr *sap, const socklen_t salen,
 		return 0;
 	}
 
-	client->cl_auth = authunix_create_default();
+	client->cl_auth = nfs_authsys_create();
+	if (client->cl_auth == NULL) {
+		if (verbose)
+			nfs_error(_("%s: Failed to create RPC auth handle"),
+				progname);
+		CLNT_DESTROY(client);
+		return 0;
+	}
 
 	res = CLNT_CALL(client, MOUNTPROC_UMNT,
 			(xdrproc_t)xdr_dirpath, (caddr_t)argp,
@@ -957,8 +964,10 @@ CLIENT *mnt_openclnt(clnt_addr_t *mnt_server, int *msock)
 	}
 	if (clnt) {
 		/* try to mount hostname:dirname */
-		clnt->cl_auth = authunix_create_default();
-		return clnt;
+		clnt->cl_auth = nfs_authsys_create();
+		if (clnt->cl_auth)
+			return clnt;
+		CLNT_DESTROY(clnt);
 	}
 	return NULL;
 }
diff --git a/utils/showmount/showmount.c b/utils/showmount/showmount.c
index f567093..394f528 100644
--- a/utils/showmount/showmount.c
+++ b/utils/showmount/showmount.c
@@ -194,7 +194,13 @@ int main(int argc, char **argv)
 	}
 
 	mclient = nfs_get_mount_client(hostname, mount_vers_tbl[vers]);
-	mclient->cl_auth = authunix_create_default();
+	mclient->cl_auth = nfs_authsys_create();
+	if (mclient->cl_auth == NULL) {
+		fprintf(stderr, "%s: unable to create RPC auth handle.\n",
+				program_name);
+		clnt_destroy(mclient);
+		exit(1);
+	}
 	total_timeout.tv_sec = TOTAL_TIMEOUT;
 	total_timeout.tv_usec = 0;
 
-- 
1.6.6

