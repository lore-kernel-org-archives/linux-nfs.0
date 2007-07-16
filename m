From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/17] mount.nfs: Change *flags to flags
Date: Sun, 15 Jul 2007 23:15:49 -0400
Message-ID: <20070716031549.11209.79977.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAH3w-0001oj-GE
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:52 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IAH3z-0000EP-L2
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:56 -0700
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

It's not necessary to treat the *flags parameter to nfsmount and nfs4mount
as an output parameter.  Nothing is passed back.  Replace it with a normal
call-by-value.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c      |    4 ++--
 utils/mount/nfs4_mount.h |    2 +-
 utils/mount/nfs4mount.c  |    4 ++--
 utils/mount/nfs_mount.h  |    2 +-
 utils/mount/nfsmount.c   |    6 +++---
 5 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index bc2e53a..3f869ee 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -467,9 +467,9 @@ int main(int argc, char *argv[])
 		exit(EX_FAIL);
 
 	if (!strcmp(fs_type, "nfs4"))
-		mnt_err = nfs4mount(spec, mount_point, &flags, &extra_opts, 0, fake);
+		mnt_err = nfs4mount(spec, mount_point, flags, &extra_opts, 0, fake);
 	else
-		mnt_err = nfsmount(spec, mount_point, &flags, &extra_opts, 0, fake);
+		mnt_err = nfsmount(spec, mount_point, flags, &extra_opts, 0, fake);
 
 	if (mnt_err)
 		exit(EX_FAIL);
diff --git a/utils/mount/nfs4_mount.h b/utils/mount/nfs4_mount.h
index 921739b..b03792e 100644
--- a/utils/mount/nfs4_mount.h
+++ b/utils/mount/nfs4_mount.h
@@ -68,6 +68,6 @@ struct nfs4_mount_data {
 #define NFS4_MOUNT_UNSHARED	0x8000	/* 5 */
 #define NFS4_MOUNT_FLAGMASK	0xFFFF
 
-int nfs4mount(const char *, const char *, int *, char **, int, int);
+int nfs4mount(const char *, const char *, int, char **, int, int);
 
 #endif
diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index c8fa0de..2c85db9 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -167,7 +167,7 @@ static int get_my_ipv4addr(char *ip_addr, int len)
 	return 0;
 }
 
-int nfs4mount(const char *spec, const char *node, int *flags,
+int nfs4mount(const char *spec, const char *node, int flags,
 	      char **extra_opts, int running_bg, int fake)
 {
 	static struct nfs4_mount_data data;
@@ -444,7 +444,7 @@ int nfs4mount(const char *spec, const char *node, int *flags,
 
 	if (!fake) {
 		if (mount(spec, node, "nfs4",
-				*flags & ~(MS_USER|MS_USERS), &data)) {
+				flags & ~(MS_USER|MS_USERS), &data)) {
 			mount_error(spec, node, errno);
 			goto fail;
 		}
diff --git a/utils/mount/nfs_mount.h b/utils/mount/nfs_mount.h
index 169f12e..8c46ce2 100644
--- a/utils/mount/nfs_mount.h
+++ b/utils/mount/nfs_mount.h
@@ -80,6 +80,6 @@ struct nfs_mount_data {
 #define AUTH_GSS_SPKMP		390011
 #endif
 
-int nfsmount(const char *, const char *, int *, char **, int, int);
+int nfsmount(const char *, const char *, int , char **, int, int);
 
 #endif /* _NFS_MOUNT_H */
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 4ce8a4e..74b5f93 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -486,7 +486,7 @@ out_bad:
 }
 
 int
-nfsmount(const char *spec, const char *node, int *flags,
+nfsmount(const char *spec, const char *node, int flags,
 	 char **extra_opts, int running_bg, int fake)
 {
 	static char *prev_bg_host;
@@ -618,7 +618,7 @@ nfsmount(const char *spec, const char *node, int *flags,
 
 	data.version = nfs_mount_data_version;
 
-	if (*flags & MS_REMOUNT)
+	if (flags & MS_REMOUNT)
 		goto out_ok;
 
 	/*
@@ -862,7 +862,7 @@ noauth_flavors:
 
 	if (!fake) {
 		if (mount(spec, node, "nfs",
-				*flags & ~(MS_USER|MS_USERS), &data)) {
+				flags & ~(MS_USER|MS_USERS), &data)) {
 			mount_error(spec, node, errno);
 			goto fail;
 		}


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
