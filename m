From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/17] mount.nfs: Remove support for "-t" option
Date: Sun, 15 Jul 2007 23:15:04 -0400
Message-ID: <20070716031503.11209.67390.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAH3B-0001ja-6T
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:06 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IAH3D-0005ua-O0
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:08 -0700
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

/bin/mount will never pass "-t" to a mount helper, since it passes the
fs-type in the name of the program it is executing.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |   64 ++++++++++++++++++++++-----------------------------
 1 files changed, 27 insertions(+), 37 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 5a7bd1c..337d7cc 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -57,7 +57,6 @@ static struct option longopts[] = {
   { "read-write", 0, 0, 'w' },
   { "rw", 0, 0, 'w' },
   { "options", 1, 0, 'o' },
-  { "nfsvers", 1, 0, 't' },
   { "bind", 0, 0, 128 },
   { "replace", 0, 0, 129 },
   { "after", 0, 0, 130 },
@@ -217,17 +216,18 @@ int do_mount_syscall(char *spec, char *node, char *type, int flags, void *data)
 
 void mount_usage()
 {
-	printf("usage: %s remotetarget dir [-rvVwfnh] [-t version] [-o nfsoptions]\n", progname);
-	printf("options:\n\t-r\t\tMount file system readonly\n");
+	printf("usage: %s remotetarget dir [-rvVwfnh] [-o nfsoptions]\n",
+		progname);
+	printf("options:\n");
+	printf("\t-r\t\tMount file system readonly\n");
 	printf("\t-v\t\tVerbose\n");
 	printf("\t-V\t\tPrint version\n");
 	printf("\t-w\t\tMount file system read-write\n");
-	printf("\t-f\t\tFake mount, don't actually mount\n");
+	printf("\t-f\t\tFake mount, do not actually mount\n");
 	printf("\t-n\t\tDo not update /etc/mtab\n");
 	printf("\t-s\t\tTolerate sloppy mount options rather than failing.\n");
 	printf("\t-h\t\tPrint this help\n");
-	printf("\tversion\t\tnfs4 - NFS version 4, nfs - older NFS version supported\n");
-	printf("\tnfsoptions\tRefer mount.nfs(8) or nfs(5)\n\n");
+	printf("\tnfsoptions\tRefer to mount.nfs(8) or nfs(5)\n\n");
 }
 
 static inline void
@@ -381,9 +381,9 @@ static int start_statd()
 
 int main(int argc, char *argv[])
 {
-	int c, flags = 0, nfs_mount_vers = 0, mnt_err = 1, fake = 0;
-	char *spec, *mount_point, *extra_opts = NULL;
-	char *mount_opts = NULL;
+	int c, flags = 0, mnt_err = 1, fake = 0;
+	char *spec, *mount_point, *fs_type = "nfs";
+	char *extra_opts = NULL, *mount_opts = NULL;
 	uid_t uid = getuid();
 
 	progname = basename(argv[0]);
@@ -413,23 +413,12 @@ int main(int argc, char *argv[])
 	mount_point = argv[2];
 
 	argv[2] = argv[0]; /* so that getopt error messages are correct */
-	while ((c = getopt_long (argc - 2, argv + 2, "rt:vVwfno:hs",
+	while ((c = getopt_long (argc - 2, argv + 2, "r:vVwfno:hs",
 				longopts, NULL)) != -1) {
 		switch (c) {
 		case 'r':
 			flags |= MS_RDONLY;
 			break;
-		case 't':
-			if (strcmp(optarg, "nfs4") == 0)
-				nfs_mount_vers = 4;
-			else if (strcmp(optarg, "nfs") == 0)
-				nfs_mount_vers = 0;
-			else {
-				fprintf(stderr, "%s: unknown filesystem type: %s\n",
-					progname, optarg);
-				exit(1);
-			}
-			break;
 		case 'v':
 			++verbose;
 			break;
@@ -488,26 +477,29 @@ int main(int argc, char *argv[])
 	}
 
 	if (strcmp(progname, "mount.nfs4") == 0)
-		nfs_mount_vers = 4;
+		fs_type = "nfs4";
 
+	/*
+	 * If a non-root user is attempting to mount, make sure the
+	 * user's requested options match the options specified in
+	 * /etc/fstab; otherwise, don't allow the mount.
+	 */
 	if (uid != 0) {
-		/* don't even think about it unless options exactly
-		 * match fstab
-		 */
 		struct mntentchn *mc;
 
 		if ((mc = getfsfile(mount_point)) == NULL ||
-		    strcmp(mc->m.mnt_fsname, spec) != 0 ||
-		    strcmp(mc->m.mnt_type, (nfs_mount_vers == 4 ? "nfs4":"nfs")) != 0
-		    ) {
-			fprintf(stderr, "%s: permission died - no match for fstab\n",
-				progname);
+		    !strcmp(mc->m.mnt_fsname, spec) ||
+		    !strcmp(mc->m.mnt_type, fs_type)) {
+			fprintf(stderr, "%s: permission denied: no match for %s "
+				"found in /etc/fstab\n", progname, mount_point);
 			exit(1);
 		}
-		/* 'mount' munges the options from fstab before passing them
+
+		/*
+		 * 'mount' munges the options from fstab before passing them
 		 * to us, so it is non-trivial to test that we have the correct
 		 * set of options and we don't want to trust what the user
-		 * gave us, so just take whatever is in fstab
+		 * gave us, so just take whatever is in /etc/fstab.
 		 */
 		mount_opts = strdup(mc->m.mnt_opts);
 		mounttype = 0;
@@ -533,7 +525,7 @@ int main(int argc, char *argv[])
 	if (chk_mountpoint(mount_point))
 		exit(EX_FAIL);
 
-	if (nfs_mount_vers == 4)
+	if (!strcmp(fs_type, "nfs4"))
 		mnt_err = nfs4mount(spec, mount_point, &flags, &extra_opts, &mount_opts, 0);
 	else {
 		int need_statd = 0;
@@ -557,8 +549,7 @@ int main(int argc, char *argv[])
 		exit(EX_FAIL);
 
 	if (!fake) {
-		mnt_err = do_mount_syscall(spec, mount_point,
-					   nfs_mount_vers == 4 ? "nfs4" : "nfs",
+		mnt_err = do_mount_syscall(spec, mount_point, fs_type,
 					   flags & ~(MS_USER|MS_USERS) ,
 					   mount_opts);
 
@@ -569,8 +560,7 @@ int main(int argc, char *argv[])
 	}
 
 	if (!nomtab)
-		add_mtab(spec, mount_point,
-			 nfs_mount_vers == 4 ? "nfs4" : "nfs",
+		add_mtab(spec, mount_point, fs_type,
 			 flags, extra_opts, 0, 0);
 
 	return 0;


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
