From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/17] Remove the running_bg parameter
Date: Sun, 15 Jul 2007 23:15:55 -0400
Message-ID: <20070716031554.11209.89772.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAH41-0001pB-Hr
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:57 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IAH44-0000FU-OY
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:16:01 -0700
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

Clean up: when nfsmount and nfs4mount are called, running_bg is always set
to zero.  Remove the parameter from the call.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c      |    4 ++--
 utils/mount/nfs4_mount.h |    2 +-
 utils/mount/nfs4mount.c  |    2 +-
 utils/mount/nfs_mount.h  |    2 +-
 utils/mount/nfsmount.c   |    4 ++--
 5 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 3f869ee..fcb1f5e 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -467,9 +467,9 @@ int main(int argc, char *argv[])
 		exit(EX_FAIL);
 
 	if (!strcmp(fs_type, "nfs4"))
-		mnt_err = nfs4mount(spec, mount_point, flags, &extra_opts, 0, fake);
+		mnt_err = nfs4mount(spec, mount_point, flags, &extra_opts, fake);
 	else
-		mnt_err = nfsmount(spec, mount_point, flags, &extra_opts, 0, fake);
+		mnt_err = nfsmount(spec, mount_point, flags, &extra_opts, fake);
 
 	if (mnt_err)
 		exit(EX_FAIL);
diff --git a/utils/mount/nfs4_mount.h b/utils/mount/nfs4_mount.h
index b03792e..00581fd 100644
--- a/utils/mount/nfs4_mount.h
+++ b/utils/mount/nfs4_mount.h
@@ -68,6 +68,6 @@ struct nfs4_mount_data {
 #define NFS4_MOUNT_UNSHARED	0x8000	/* 5 */
 #define NFS4_MOUNT_FLAGMASK	0xFFFF
 
-int nfs4mount(const char *, const char *, int, char **, int, int);
+int nfs4mount(const char *, const char *, int, char **, int);
 
 #endif
diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index 2c85db9..64f85e0 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -168,7 +168,7 @@ static int get_my_ipv4addr(char *ip_addr, int len)
 }
 
 int nfs4mount(const char *spec, const char *node, int flags,
-	      char **extra_opts, int running_bg, int fake)
+	      char **extra_opts, int fake)
 {
 	static struct nfs4_mount_data data;
 	static char hostdir[1024];
diff --git a/utils/mount/nfs_mount.h b/utils/mount/nfs_mount.h
index 8c46ce2..279ff36 100644
--- a/utils/mount/nfs_mount.h
+++ b/utils/mount/nfs_mount.h
@@ -80,6 +80,6 @@ struct nfs_mount_data {
 #define AUTH_GSS_SPKMP		390011
 #endif
 
-int nfsmount(const char *, const char *, int , char **, int, int);
+int nfsmount(const char *, const char *, int , char **, int);
 
 #endif /* _NFS_MOUNT_H */
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 74b5f93..4807c5b 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -487,14 +487,14 @@ out_bad:
 
 int
 nfsmount(const char *spec, const char *node, int flags,
-	 char **extra_opts, int running_bg, int fake)
+	 char **extra_opts, int fake)
 {
 	static char *prev_bg_host;
 	char hostdir[1024];
 	char *hostname, *dirname, *old_opts, *mounthost = NULL;
 	char new_opts[1024], cbuf[1024];
 	static struct nfs_mount_data data;
-	int val;
+	int val, running_bg = 0;
 	static int doonce = 0;
 
 	clnt_addr_t mnt_server = { &mounthost, };


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
