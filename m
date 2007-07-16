From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/17] mount.nfs: Remove start_statd from mount.
Date: Sun, 15 Jul 2007 23:15:39 -0400
Message-ID: <20070716031539.11209.47630.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAH3m-0001oN-5p
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:42 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IAH3p-00062S-MK
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:45 -0700
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

Pre-requisite for subsequent fixes.

Also fix a minor nit:  Since the mount actually fails if start_statd
doesn't work, cause mount.nfs to exit with a status of EX_FAIL.

Still need to do something about "running_bg" in nfsmount.c:nfsmount().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c        |   61 +-------------------------------------------
 utils/mount/nfs_mount.h    |    2 +
 utils/mount/nfsmount.c     |   16 ++++++++++--
 utils/mount/nfsmount_net.c |   45 ++++++++++++++++++++++++++++++++
 utils/mount/nfsmount_net.h |    5 ++--
 5 files changed, 65 insertions(+), 64 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index c7cb896..865746a 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -345,50 +345,6 @@ static int chk_mountpoint(char *mount_point)
 	return 0;
 }
 
-static int probe_statd()
-{
-	struct sockaddr_in addr;
-	u_short port;
-
-	memset(&addr, 0, sizeof(addr));
-	addr.sin_family = AF_INET;
-	addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
-	port = getport(&addr, 100024, 1, IPPROTO_UDP);
-
-	if (port == 0)
-		return 0;
-	addr.sin_port = htons(port);
-
-	if (clnt_ping(&addr, 100024, 1, IPPROTO_UDP, NULL) <= 0)
-		return 0;
-
-	return 1;
-}
-
-static int start_statd()
-{
-	/* If /var/run/rpc.statd.pid exists and is non-empty,
-	 * assume statd already running.
-	 * If START_STATD not defined, or defined to a non-existent file,
-	 * don't bother,
-	 * else run that file (typically a shell script)
-	 */
-	struct stat stb;
-
-	if (probe_statd())
-		return 1;
-#ifdef START_STATD
-	if (stat(START_STATD, &stb) ==0 &&
-	    S_ISREG(stb.st_mode) &&
-	    (stb.st_mode & S_IXUSR)) {
-		system(START_STATD);
-		if (probe_statd())
-			return 1;
-	}
-#endif
-	return 0;
-}
-
 int main(int argc, char *argv[])
 {
 	int c, flags = 0, mnt_err = 1, fake = 0;
@@ -517,23 +473,10 @@ int main(int argc, char *argv[])
 
 	if (!strcmp(fs_type, "nfs4"))
 		mnt_err = nfs4mount(spec, mount_point, &flags, &extra_opts, &mount_opts, 0);
-	else {
-		int need_statd = 0;
+	else
 		mnt_err = nfsmount(spec, mount_point, &flags,
 				   &extra_opts, &mount_opts,
-				   0, &need_statd);
-		if (!mnt_err && !fake && need_statd) {
-			if (!start_statd()) {
-				fprintf(stderr,
-					"%s: rpc.statd is not running but is "
-					"required for remote locking\n"
-					"   Either use \"-o nolocks\" to keep "
-					"locks local, or start statd.\n",
-					progname);
-				exit(1);
-			}
-		}
-	}
+				   0, fake);
 
 	if (mnt_err)
 		exit(EX_FAIL);
diff --git a/utils/mount/nfs_mount.h b/utils/mount/nfs_mount.h
index b38aa0f..e566083 100644
--- a/utils/mount/nfs_mount.h
+++ b/utils/mount/nfs_mount.h
@@ -81,6 +81,6 @@ struct nfs_mount_data {
 #endif
 
 int nfsmount(const char *, const char *, int *, char **, char **,
-	     int, int *);
+	     int, int);
 
 #endif /* _NFS_MOUNT_H */
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 368793c..df23e30 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -89,6 +89,7 @@ typedef union {
 } mntres_t;
 
 extern int nfs_mount_data_version;
+extern char *progname;
 extern int verbose;
 extern int sloppy;
 
@@ -487,7 +488,7 @@ out_bad:
 int
 nfsmount(const char *spec, const char *node, int *flags,
 	 char **extra_opts, char **mount_opts,
-	 int running_bg, int *need_statd)
+	 int running_bg, int fake)
 {
 	static char *prev_bg_host;
 	char hostdir[1024];
@@ -849,7 +850,18 @@ noauth_flavors:
 	strcat(new_opts, cbuf);
 
 	*extra_opts = xstrdup(new_opts);
-	*need_statd = ! (data.flags & NFS_MOUNT_NONLM);
+
+	if (!fake && !(data.flags & NFS_MOUNT_NONLM)) {
+		if (!start_statd()) {
+			nfs_error(_("%s: rpc.statd is not running but is "
+				"required for remote locking.\n"
+				"   Either use '-o nolocks' to keep "
+				"locks local, or start statd."),
+					progname);
+			goto fail;
+		}
+	}
+
 	return 0;
 
 	/* abort */
diff --git a/utils/mount/nfsmount_net.c b/utils/mount/nfsmount_net.c
index 71762d6..36f1933 100644
--- a/utils/mount/nfsmount_net.c
+++ b/utils/mount/nfsmount_net.c
@@ -316,3 +316,48 @@ version_fixed:
 		goto out_bad;
 	return probe_mntport(mnt_server);
 }
+
+static int probe_statd(void)
+{
+	struct sockaddr_in addr;
+	unsigned short port;
+
+	memset(&addr, 0, sizeof(addr));
+	addr.sin_family = AF_INET;
+	addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+	port = getport(&addr, 100024, 1, IPPROTO_UDP);
+
+	if (port == 0)
+		return 0;
+	addr.sin_port = htons(port);
+
+	if (clnt_ping(&addr, 100024, 1, IPPROTO_UDP, NULL) <= 0)
+		return 0;
+
+	return 1;
+}
+
+/*
+ * Attempt to start rpc.statd
+ */
+int start_statd(void)
+{
+#ifdef START_STATD
+	struct stat stb;
+#endif
+
+	if (probe_statd())
+		return 1;
+
+#ifdef START_STATD
+	if (stat(START_STATD, &stb) == 0) {
+		if (S_ISREG(stb.st_mode) && (stb.st_mode & S_IXUSR)) {
+			system(START_STATD);
+			if (probe_statd())
+				return 1;
+		}
+	}
+#endif
+
+	return 0;
+}
diff --git a/utils/mount/nfsmount_net.h b/utils/mount/nfsmount_net.h
index 931f721..38376d7 100644
--- a/utils/mount/nfsmount_net.h
+++ b/utils/mount/nfsmount_net.h
@@ -24,8 +24,9 @@
 #include "conn.h"
 
 int nfs_gethostbyname(const char *, struct sockaddr_in *);
-unsigned short getport(struct sockaddr_in *, unsigned long,
-			unsigned long, unsigned int);
+
 int probe_mntport(clnt_addr_t *);
 int probe_nfsport(clnt_addr_t *);
 int probe_bothports(clnt_addr_t *, clnt_addr_t *);
+
+int start_statd(void);


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
