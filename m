From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 23/23] mount.nfs: clean up a couple of printfs in
	fstab.c
Date: Sat, 28 Jul 2007 17:51:06 -0400
Message-ID: <20070728215105.21871.39156.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFGPU-0003oV-Qu
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 14:34:44 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IFGPY-0003ml-MT
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 14:34:48 -0700
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

Clean up for consistent use.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/fstab.c |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/utils/mount/fstab.c b/utils/mount/fstab.c
index aee8e53..449d4a5 100644
--- a/utils/mount/fstab.c
+++ b/utils/mount/fstab.c
@@ -25,6 +25,7 @@
 #define streq(s, t)	(strcmp ((s), (t)) == 0)
 #define PROC_MOUNTS		"/proc/mounts"
 
+extern char *progname;
 extern int verbose;
 
 /* Information about mtab. ------------------------------------*/
@@ -173,9 +174,8 @@ read_mounttable() {
                         return;
                 }
                 if (verbose)
-                        printf (_("mount: could not open %s - "
-                                  "using %s instead\n"),
-                                MOUNTED, PROC_MOUNTS);
+                        printf(_("%s: could not open %s; using %s instead\n"),
+				progname, MOUNTED, PROC_MOUNTS);
         }
         read_mntentchn(mfp, fnam, mc);
 }
@@ -399,8 +399,10 @@ lock_mtab (void) {
 			if (fcntl (lockfile_fd, F_SETLK, &flock) == -1) {
 				if (verbose) {
 				    int errsv = errno;
-				    printf(_("Can't lock lock file %s: %s\n"),
-					   MOUNTED_LOCK, strerror (errsv));
+				    nfs_error(_("%s: Can't lock lock file "
+						"%s: %s"), progname,
+					   	MOUNTED_LOCK,
+						strerror (errsv));
 				}
 				/* proceed anyway */
 			}
@@ -527,8 +529,8 @@ update_mtab (const char *dir, struct mntent *instead)
 	if (fchmod (fileno (mftmp->mntent_fp),
 		    S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH) < 0) {
 		int errsv = errno;
-		fprintf(stderr, _("error changing mode of %s: %s\n"),
-			MOUNTED_TEMP, strerror (errsv));
+		nfs_error(_("%s: error changing mode of %s: %s"),
+				progname, MOUNTED_TEMP, strerror (errsv));
 	}
 	nfs_endmntent (mftmp);
 
@@ -545,8 +547,9 @@ update_mtab (const char *dir, struct mntent *instead)
 	/* rename mtemp to mtab */
 	if (rename (MOUNTED_TEMP, MOUNTED) < 0) {
 		int errsv = errno;
-		fprintf(stderr, _("can't rename %s to %s: %s\n"),
-			MOUNTED_TEMP, MOUNTED, strerror(errsv));
+		nfs_error(_("%s: can't rename %s to %s: %s\n"),
+				progname, MOUNTED_TEMP, MOUNTED,
+				strerror(errsv));
 	}
 
  leave:


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
