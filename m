From: Juan Gomez <juang@us.ibm.com>
Subject: Patch to enable rmtab's that are symbolic links
Date: Tue, 15 Oct 2002 09:07:12 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF2BD80441.154AB54D-ON87256C53.00586AAD@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e35.co.us.ibm.com ([32.97.110.133])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 181UFV-0004mq-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 09:08:49 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.194.23])
	by e35.co.us.ibm.com (8.12.2/8.12.2) with ESMTP id g9FG8bQu027560
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 12:08:37 -0400
Received: from d03nm694.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.193.82])
	by westrelay02.boulder.ibm.com (8.12.3/NCO/VER6.4) with ESMTP id g9FG7KMF038690
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 10:07:20 -0600
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


has anyone had anytime to look into this? could anyone include it in the
distribution?

Juan

----- Forwarded by Juan Gomez/Almaden/IBM on 10/15/02 09:09 AM -----
                                                                                                                                       
                      Juan Gomez                                                                                                       
                      <gomez@cs.sjsu.ed        To:       nfs@lists.sourceforge.net                                                     
                      u>                       cc:       Juan Gomez/Almaden/IBM@IBMUS                                                  
                                               Subject:  Patch to enable rmtab's that are symbolic links                               
                      10/12/02 01:06 AM                                                                                                
                                                                                                                                       
                                                                                                                                       




In clustered NAS environments we have found useful to support
symbolic links to the rmtab files. I would like to propose the following
patch for review and future inclusion on nfs-utils so that this feature
can be supported.

Regards, Juan

diff -ur nfs-utils/utils/mountd/rmtab.c
nfs-utils-new-mountd/utils/mountd/rmtab.c
--- nfs-utils/utils/mountd/rmtab.c         Wed May 31 17:57:13 2000
+++ nfs-utils-new-mountd/utils/mountd/rmtab.c          Sat Oct 12 07:54:01
2002
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
-            if (rename(_PATH_RMTABTMP, _PATH_RMTAB) < 0) {
+            if (slink_safe_rename(_PATH_RMTABTMP, _PATH_RMTAB) < 0) {
                         xlog(L_ERROR, "couldn't rename %s to %s",
                                                 _PATH_RMTABTMP,
_PATH_RMTAB);
             }
@@ -130,7 +166,7 @@
                         }
                         fputrmtabent(fp, rep, NULL);
             }
-            if (rename(_PATH_RMTABTMP, _PATH_RMTAB) < 0) {
+            if (slink_safe_rename(_PATH_RMTABTMP, _PATH_RMTAB) < 0) {
                         xlog(L_ERROR, "couldn't rename %s to %s",
                                                 _PATH_RMTABTMP,
_PATH_RMTAB);
             }






-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
