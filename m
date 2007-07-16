From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/17] mount.nfs: No need to return nfs_mount_data
	structs
Date: Sun, 15 Jul 2007 23:15:44 -0400
Message-ID: <20070716031544.11209.97187.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAH3r-0001od-AQ
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:47 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IAH3u-00063M-Hh
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:51 -0700
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

Refactor mount processing slightly to remove an output parameter and an
unnecessary type cast.

It doesn't look like background mounting was working, but this might help.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c      |   22 ++--------------------
 utils/mount/nfs4_mount.h |    3 +--
 utils/mount/nfs4mount.c  |   15 +++++++++++----
 utils/mount/nfs_mount.h  |    3 +--
 utils/mount/nfsmount.c   |   12 +++++++++---
 5 files changed, 24 insertions(+), 31 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 865746a..bc2e53a 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -249,11 +249,6 @@ fail_unlock:
 	return result;
 }
 
-int do_mount_syscall(char *spec, char *node, char *type, int flags, void *data)
-{
-	return mount(spec, node, type, flags, data);
-}
-
 void mount_usage()
 {
 	printf("usage: %s remotetarget dir [-rvVwfnh] [-o nfsoptions]\n",
@@ -472,26 +467,13 @@ int main(int argc, char *argv[])
 		exit(EX_FAIL);
 
 	if (!strcmp(fs_type, "nfs4"))
-		mnt_err = nfs4mount(spec, mount_point, &flags, &extra_opts, &mount_opts, 0);
+		mnt_err = nfs4mount(spec, mount_point, &flags, &extra_opts, 0, fake);
 	else
-		mnt_err = nfsmount(spec, mount_point, &flags,
-				   &extra_opts, &mount_opts,
-				   0, fake);
+		mnt_err = nfsmount(spec, mount_point, &flags, &extra_opts, 0, fake);
 
 	if (mnt_err)
 		exit(EX_FAIL);
 
-	if (!fake) {
-		mnt_err = do_mount_syscall(spec, mount_point, fs_type,
-					   flags & ~(MS_USER|MS_USERS) ,
-					   mount_opts);
-
-		if (mnt_err) {
-			mount_error(spec, mount_point, errno);
-			exit(EX_FAIL);
-		}
-	}
-
 	if (!nomtab)
 		mnt_err = add_mtab(spec, mount_point, fs_type, flags, extra_opts,
 				0, 0 /* these are always zero for NFS */ );
diff --git a/utils/mount/nfs4_mount.h b/utils/mount/nfs4_mount.h
index 58e311e..921739b 100644
--- a/utils/mount/nfs4_mount.h
+++ b/utils/mount/nfs4_mount.h
@@ -68,7 +68,6 @@ struct nfs4_mount_data {
 #define NFS4_MOUNT_UNSHARED	0x8000	/* 5 */
 #define NFS4_MOUNT_FLAGMASK	0xFFFF
 
-int nfs4mount(const char *, const char *, int *, char **,
-	char **, int);
+int nfs4mount(const char *, const char *, int *, char **, int, int);
 
 #endif
diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index ea2ac3a..c8fa0de 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -25,6 +25,7 @@
 #include <netdb.h>
 #include <time.h>
 #include <sys/stat.h>
+#include <sys/mount.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <rpc/auth.h>
@@ -41,6 +42,7 @@
 #include "conn.h"
 #include "xcommon.h"
 
+#include "mount_constants.h"
 #include "nfs4_mount.h"
 #include "nfs_mount.h"
 #include "nfsmount_err.h"
@@ -166,8 +168,7 @@ static int get_my_ipv4addr(char *ip_addr, int len)
 }
 
 int nfs4mount(const char *spec, const char *node, int *flags,
-	      char **extra_opts, char **mount_opts,
-	      int running_bg)
+	      char **extra_opts, int running_bg, int fake)
 {
 	static struct nfs4_mount_data data;
 	static char hostdir[1024];
@@ -441,8 +442,14 @@ int nfs4mount(const char *spec, const char *node, int *flags,
 		continue;
 	}
 
-	*mount_opts = (char *) &data;
-	/* clean up */
+	if (!fake) {
+		if (mount(spec, node, "nfs4",
+				*flags & ~(MS_USER|MS_USERS), &data)) {
+			mount_error(spec, node, errno);
+			goto fail;
+		}
+	}
+
 	return 0;
 
 fail:
diff --git a/utils/mount/nfs_mount.h b/utils/mount/nfs_mount.h
index e566083..169f12e 100644
--- a/utils/mount/nfs_mount.h
+++ b/utils/mount/nfs_mount.h
@@ -80,7 +80,6 @@ struct nfs_mount_data {
 #define AUTH_GSS_SPKMP		390011
 #endif
 
-int nfsmount(const char *, const char *, int *, char **, char **,
-	     int, int);
+int nfsmount(const char *, const char *, int *, char **, int, int);
 
 #endif /* _NFS_MOUNT_H */
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index df23e30..4ce8a4e 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -487,8 +487,7 @@ out_bad:
 
 int
 nfsmount(const char *spec, const char *node, int *flags,
-	 char **extra_opts, char **mount_opts,
-	 int running_bg, int fake)
+	 char **extra_opts, int running_bg, int fake)
 {
 	static char *prev_bg_host;
 	char hostdir[1024];
@@ -618,7 +617,6 @@ nfsmount(const char *spec, const char *node, int *flags,
 #endif
 
 	data.version = nfs_mount_data_version;
-	*mount_opts = (char *) &data;
 
 	if (*flags & MS_REMOUNT)
 		goto out_ok;
@@ -862,6 +860,14 @@ noauth_flavors:
 		}
 	}
 
+	if (!fake) {
+		if (mount(spec, node, "nfs",
+				*flags & ~(MS_USER|MS_USERS), &data)) {
+			mount_error(spec, node, errno);
+			goto fail;
+		}
+	}
+
 	return 0;
 
 	/* abort */


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
