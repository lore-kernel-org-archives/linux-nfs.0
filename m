From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/17] mount.nfs: Error handling clean-up
Date: Sun, 15 Jul 2007 23:16:05 -0400
Message-ID: <20070716031605.11209.61265.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAH4D-0001ul-Bi
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:16:09 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IAH4F-0006BP-Tg
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:16:13 -0700
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

o  Use nfs_error( _() ) instead of fprintf(stderr,
o  Use the mount return code macros instead of bare integers
o  Free mount_point after it has been canonicalized

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |   46 +++++++++++++++++++++++++++-------------------
 1 files changed, 27 insertions(+), 19 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 53dc731..6f98eae 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -366,22 +366,22 @@ int main(int argc, char *argv[])
 	if(!strncmp(progname, "umount", strlen("umount"))) {
 		if(argc < 2) {
 			umount_usage();
-			exit(1);
+			exit(EX_USAGE);
 		}
 		exit(nfsumount(argc, argv) ? 0 : 1);
 	}
 
-	if(argv[1] && argv[1][0] == '-') {
+	if (argv[1] && argv[1][0] == '-') {
 		if(argv[1][1] == 'V')
 			printf("%s ("PACKAGE_STRING")\n", progname);
 		else
 			mount_usage();
-		return 0;
+		exit(0);
 	}
 
 	if ((argc < 3)) {
 		mount_usage();
-		exit(1);
+		exit(EX_USAGE);
 	}
 
 	spec = argv[1];
@@ -427,7 +427,7 @@ int main(int argc, char *argv[])
 	if (optind != argc-2) {
 		/* Extra non-option words at the end... */
 		mount_usage();
-		exit(1);
+		exit(EX_USAGE);
 	}
 
 	if (strcmp(progname, "mount.nfs4") == 0)
@@ -444,9 +444,9 @@ int main(int argc, char *argv[])
 		if ((mc = getfsfile(mount_point)) == NULL ||
 		    !strcmp(mc->m.mnt_fsname, spec) ||
 		    !strcmp(mc->m.mnt_type, fs_type)) {
-			fprintf(stderr, "%s: permission denied: no match for %s "
-				"found in /etc/fstab\n", progname, mount_point);
-			exit(1);
+			nfs_error(_("%s: permission denied: no match for %s "
+				"found in /etc/fstab"), progname, mount_point);
+			exit(EX_USAGE);
 		}
 
 		/*
@@ -458,25 +458,31 @@ int main(int argc, char *argv[])
 		mount_opts = strdup(mc->m.mnt_opts);
 	}
 
-	mount_point = canonicalize(mount_point);
-	if (mount_point == NULL ||
-	    mount_point[0] != '/') {
-		fprintf(stderr, "%s: unknown mount point %s\n",
-			progname, mount_point ? : "");
-		exit(1);
+	if (!mount_point) {
+		nfs_error(_("%s: no mount point provided"), progname);
+		exit(EX_USAGE);
 	}
-	
+	if (mount_point[0] != '/') {
+		nfs_error(_("%s: unrecognized mount point %s"),
+			progname, mount_point);
+		mnt_err = EX_USAGE;
+		goto out;
+	}
+
 	parse_opts(mount_opts, &flags, &extra_opts);
 
 	if (uid != 0) {
 		if (!(flags & (MS_USERS|MS_USER))) {
-			fprintf(stderr, "%s: permission denied\n", progname);
-			exit(EX_USAGE);
+			nfs_error(_("%s: permission denied"), progname);
+			mnt_err = EX_USAGE;
+			goto out;
 		}
 	}
 
-	if (chk_mountpoint(mount_point))
-		exit(EX_FAIL);
+	if (chk_mountpoint(mount_point)) {
+		mnt_err = EX_USAGE
+		goto out;
+	}
 
 	if (!strcmp(fs_type, "nfs4"))
 		mnt_err = nfs4mount(spec, mount_point, flags, &extra_opts, fake);
@@ -493,6 +499,8 @@ int main(int argc, char *argv[])
 		mnt_err = add_mtab(spec, mount_point, fs_type, flags, extra_opts,
 				0, 0 /* these are always zero for NFS */ );
 
+out:
+	free(mount_point);
 	exit(mnt_err);
 }
 


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
