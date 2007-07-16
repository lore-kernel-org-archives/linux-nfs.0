From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/17] mount.nfs: clean-up add_mtab
Date: Sun, 15 Jul 2007 23:15:14 -0400
Message-ID: <20070716031514.11209.36069.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAH3N-0001nF-Bd
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:17 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IAH3P-00006n-Tk
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:21 -0700
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

Clean up add_mtab(), and make /sbin/mount.nfs[4] return a proper error if
it fails.

Also include an unbalanced unlock_mtab() noticed by Steve D.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |   52 +++++++++++++++++++++++++++------------------------
 1 files changed, 28 insertions(+), 24 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index c05f907..3df57fc 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -32,6 +32,7 @@
 
 #include "fstab.h"
 #include "xcommon.h"
+#include "nls.h"
 #include "mount_constants.h"
 #include "nfs_paths.h"
 
@@ -150,50 +151,53 @@ static char * fix_opts_string (int flags, const char *extra_opts) {
 	return new_opts;
 }
 
-
-int add_mtab(char *fsname, char *mount_point, char *fstype, int flags, char *opts, int freq, int passno)
+static int add_mtab(char *spec, char *mount_point, char *fstype,
+			int flags, char *opts, int freq, int pass)
 {
 	struct mntent ment;
 	FILE *mtab;
+	int result = EX_FILEIO;
 
-	ment.mnt_fsname = fsname;
+	ment.mnt_fsname = spec;
 	ment.mnt_dir = mount_point;
 	ment.mnt_type = fstype;
 	ment.mnt_opts = fix_opts_string(flags, opts);
-	ment.mnt_freq = 0;
-	ment.mnt_passno= 0;
+	ment.mnt_freq = freq;
+	ment.mnt_passno = pass;
 
-	if(flags & MS_REMOUNT) {
+	if (flags & MS_REMOUNT) {
 		update_mtab(ment.mnt_dir, &ment);
 		return 0;
 	}
 
 	lock_mtab();
 
-        if ((mtab = setmntent(MOUNTED, "a+")) == NULL) {
-		fprintf(stderr, "Can't open " MOUNTED);
-		return 1;
+	if ((mtab = setmntent(MOUNTED, "a+")) == NULL) {
+		nfs_error(_("Can't open mtab: %s"),
+				strerror(errno));
+		goto fail_unlock;
 	}
 
-        if (addmntent(mtab, &ment) == 1) {
-		endmntent(mtab);
-		unlock_mtab();
-		fprintf(stderr, "Can't write mount entry");
-		return 1;
+	if (addmntent(mtab, &ment) == 1) {
+		nfs_error(_("Can't write mount entry to mtab: %s"),
+				strerror(errno));
+		goto fail_close;
 	}
 
-        if (fchmod(fileno(mtab), 0644) == -1) {
-		endmntent(mtab);
-		unlock_mtab();
-		fprintf(stderr, "Can't set perms on " MOUNTED);
-		return 1;
+	if (fchmod(fileno(mtab), 0644) == -1) {
+		nfs_error(_("Can't set permissions on mtab: %s"),
+				strerror(errno));
+		goto fail_close;
 	}
 
-	endmntent(mtab);
+	result = 0;
 
+fail_close:
+	endmntent(mtab);
+fail_unlock:
 	unlock_mtab();
 
-	return 0;
+	return result;
 }
 
 int do_mount_syscall(char *spec, char *node, char *type, int flags, void *data)
@@ -525,9 +529,9 @@ int main(int argc, char *argv[])
 	}
 
 	if (!nomtab)
-		add_mtab(spec, mount_point, fs_type,
-			 flags, extra_opts, 0, 0);
+		mnt_err = add_mtab(spec, mount_point, fs_type, flags, extra_opts,
+				0, 0 /* these are always zero for NFS */ );
 
-	return 0;
+	exit(mnt_err);
 }
 


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
