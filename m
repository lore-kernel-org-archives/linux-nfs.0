From: Juan Gomez  <gomez@cs.sjsu.edu>
Subject: Patch to enable rmtab's that are symbolic links
Date: Sat, 12 Oct 2002 01:06:16 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.05.10210120103230.11528-100000@eniac>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: juang@us.ibm.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailhub.cs.sjsu.edu ([130.65.86.58])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 180HIl-0005jz-00
	for <nfs@lists.sourceforge.net>; Sat, 12 Oct 2002 01:07:11 -0700
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


In clustered NAS environments we have found useful to support
symbolic links to the rmtab files. I would like to propose the following
patch for review and future inclusion on nfs-utils so that this feature
can be supported.

Regards, Juan

diff -ur nfs-utils/utils/mountd/rmtab.c nfs-utils-new-mountd/utils/mountd/rmtab.c
--- nfs-utils/utils/mountd/rmtab.c	Wed May 31 17:57:13 2000
+++ nfs-utils-new-mountd/utils/mountd/rmtab.c	Sat Oct 12 07:54:01 2002
@@ -8,7 +8,9 @@
 
 #include "config.h"
 
+#include <sys/types.h>
 #include <sys/stat.h>
+#include <unistd.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <netdb.h>
@@ -18,6 +20,40 @@
 #include "xio.h"
 #include "mountd.h"
 
+#include <limits.h> /* PATH_MAX */
+
+/* If new path is a link do not destroy it but place the
+ * file where the link points.
+ */
+
+static int 
+slink_safe_rename(const char * oldpath, const char * newpath)
+{
+  int r;
+  struct stat s;
+  char slink_path[PATH_MAX];
+  char real_newpath = newpath;
+
+  if((lstat(newpath, &s) == 0) && (S_ISLNK(s.st_mode))) {
+
+    /* New path is a symbolic link, do not destroy but follow */
+
+    if((r = readlink(newpath, slink_path, PATH_MAX))==-1) {
+
+      return -1;
+
+    }
+
+    slink_path[ (r < PATH_MAX) ? (r + 1) : (PATH_MAX - 1)] = '\0';
+
+    real_newpath = slink_path;
+
+  }
+
+  return rename(oldpath, real_newpath);
+
+}/* static int slink_safe_rename() */
+
 void
 mountlist_add(nfs_export *exp, const char *path)
 {
@@ -82,7 +118,7 @@
 		if (!match || rep->r_count)
 			fputrmtabent(fp, rep, NULL);
 	}
-	if (rename(_PATH_RMTABTMP, _PATH_RMTAB) < 0) {
+	if (slink_safe_rename(_PATH_RMTABTMP, _PATH_RMTAB) < 0) {
 		xlog(L_ERROR, "couldn't rename %s to %s",
 				_PATH_RMTABTMP, _PATH_RMTAB);
 	}
@@ -130,7 +166,7 @@
 		}
 		fputrmtabent(fp, rep, NULL);
 	}
-	if (rename(_PATH_RMTABTMP, _PATH_RMTAB) < 0) {
+	if (slink_safe_rename(_PATH_RMTABTMP, _PATH_RMTAB) < 0) {
 		xlog(L_ERROR, "couldn't rename %s to %s",
 				_PATH_RMTABTMP, _PATH_RMTAB);
 	}



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
