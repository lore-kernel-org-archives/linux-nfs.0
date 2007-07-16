From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/17] mount.nfs: /bin/mount already handles --bind &
	friends
Date: Sun, 15 Jul 2007 23:15:09 -0400
Message-ID: <20070716031509.11209.35069.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAH3C-0001ky-QP
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:07 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IAH3F-00005M-R9
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:10 -0700
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

Clean-up: remove logic to handle --bind and other such options from
mount.nfs[4].

These options are already handled in /bin/mount, and the logic for handling
them in the NFS helper is currently disabled.  Other helpers such as
mount.ocfs2 appear not to support --bind (ie. they rely on /bin/mount to
do it).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c           |   45 +++++------------------------------------
 utils/mount/mount_constants.h |    6 +++++
 2 files changed, 11 insertions(+), 40 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 337d7cc..c05f907 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -43,7 +43,6 @@
 char *progname;
 int nomtab;
 int verbose;
-int mounttype;
 int sloppy;
 
 static struct option longopts[] = {
@@ -57,13 +56,6 @@ static struct option longopts[] = {
   { "read-write", 0, 0, 'w' },
   { "rw", 0, 0, 'w' },
   { "options", 1, 0, 'o' },
-  { "bind", 0, 0, 128 },
-  { "replace", 0, 0, 129 },
-  { "after", 0, 0, 130 },
-  { "before", 0, 0, 131 },
-  { "over", 0, 0, 132 },
-  { "move", 0, 0, 133 },
-  { "rbind", 0, 0, 135 },
   { NULL, 0, 0, 0 }
 };
 
@@ -75,11 +67,6 @@ struct opt_map {
   int  mask;                    /* flag mask value */
 };
 
-/* Custom mount options for our own purposes.  */
-#define MS_DUMMY	0x00000000
-#define MS_USERS	0x40000000
-#define MS_USER		0x80000000
-
 static const struct opt_map opt_map[] = {
   { "defaults", 0, 0, 0         },      /* default options */
   { "ro",       1, 0, MS_RDONLY },      /* read-only */
@@ -443,31 +430,10 @@ int main(int argc, char *argv[])
 		case 's':
 			++sloppy;
 			break;
-		case 128: /* bind */
-			mounttype = MS_BIND;
-			break;
-		case 129: /* replace */
-			mounttype = MS_REPLACE;
-			break;
-		case 130: /* after */
-			mounttype = MS_AFTER;
-			break;
-		case 131: /* before */
-			mounttype = MS_BEFORE;
-			break;
-		case 132: /* over */
-			mounttype = MS_OVER;
-			break;
-		case 133: /* move */
-			mounttype = MS_MOVE;
-			break;
-		case 135: /* rbind */
-			mounttype = MS_BIND | MS_REC;
-			break;
 		case 'h':
 		default:
 			mount_usage();
-			exit(1);
+			exit(EX_USAGE);
 		}
 	}
 	if (optind != argc-2) {
@@ -502,7 +468,6 @@ int main(int argc, char *argv[])
 		 * gave us, so just take whatever is in /etc/fstab.
 		 */
 		mount_opts = strdup(mc->m.mnt_opts);
-		mounttype = 0;
 	}
 
 	mount_point = canonicalize(mount_point);
@@ -516,10 +481,10 @@ int main(int argc, char *argv[])
 	parse_opts(mount_opts, &flags, &extra_opts);
 
 	if (uid != 0) {
-	    if (! (flags & (MS_USERS | MS_USER))) {
-		    fprintf(stderr, "%s: permission denied\n", progname);
-		    exit(1);
-	    }
+		if (!(flags & (MS_USERS|MS_USER))) {
+			fprintf(stderr, "%s: permission denied\n", progname);
+			exit(EX_USAGE);
+		}
 	}
 
 	if (chk_mountpoint(mount_point))
diff --git a/utils/mount/mount_constants.h b/utils/mount/mount_constants.h
index 19a7bf5..3e40841 100644
--- a/utils/mount/mount_constants.h
+++ b/utils/mount/mount_constants.h
@@ -39,6 +39,12 @@ if we have a stack or plain mount - mount atop of it, forming a stack. */
 #ifndef MS_VERBOSE
 #define MS_VERBOSE	0x8000	/* 32768 */
 #endif
+
+/* Custom mount options for our own purposes.  */
+#define MS_DUMMY	0x00000000
+#define MS_USERS	0x40000000
+#define MS_USER		0x80000000
+
 /*
  * Magic mount flag number. Had to be or-ed to the flag values.
  */


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
