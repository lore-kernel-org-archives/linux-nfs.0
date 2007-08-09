From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/5] mount.nfs: Enable mount.nfs to do text-based
	mount support
Date: Thu, 09 Aug 2007 17:37:11 -0400
Message-ID: <20070809213711.16767.30201.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJFgt-0007lp-I9
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 14:37:11 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IJFgx-0005u2-Hq
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 14:37:15 -0700
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

A new command line option, "-i", is added to mount.nfs to force the use of
the string interface for testing purposes.  "-s", "-t", and "-r" are
already taken or have legacy meaning so I picked "-i".

At some later point, when everyone is comfortable with the string mount
option parsing implementation, we will add a switch based on kernel
version, and remove the "-i" command line option.  For now, I am more
comfortable enabling it by hand instead.

Since this is a temporary arrangement, I'm leaving the option undocumented
in the mount.nfs man page.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |   32 ++++++++++++++++++++++++--------
 1 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 94435c8..fa23a2e 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -42,12 +42,14 @@
 #include "mount.h"
 #include "error.h"
 #include "network.h"
+#include "stropts.h"
 
 char *progname;
 int nfs_mount_data_version;
 int nomtab;
 int verbose;
 int sloppy;
+int string;
 
 #define FOREGROUND	(0)
 #define BACKGROUND	(1)
@@ -62,6 +64,7 @@ static struct option longopts[] = {
   { "version", 0, 0, 'V' },
   { "read-write", 0, 0, 'w' },
   { "rw", 0, 0, 'w' },
+  { "string", 0, 0, 'i' },
   { "options", 1, 0, 'o' },
   { NULL, 0, 0, 0 }
 };
@@ -270,7 +273,7 @@ fail_unlock:
 
 void mount_usage(void)
 {
-	printf(_("usage: %s remotetarget dir [-rvVwfnsh] [-o nfsoptions]\n"),
+	printf(_("usage: %s remotetarget dir [-rvVwfnsih] [-o nfsoptions]\n"),
 		progname);
 	printf(_("options:\n"));
 	printf(_("\t-r\t\tMount file system readonly\n"));
@@ -280,6 +283,7 @@ void mount_usage(void)
 	printf(_("\t-f\t\tFake mount, do not actually mount\n"));
 	printf(_("\t-n\t\tDo not update /etc/mtab\n"));
 	printf(_("\t-s\t\tTolerate sloppy mount options rather than fail\n"));
+	printf(_("\t-i\t\tPass mount options to the kernel via a string\n"));
 	printf(_("\t-h\t\tPrint this help\n"));
 	printf(_("\tnfsoptions\tRefer to mount.nfs(8) or nfs(5)\n\n"));
 }
@@ -370,12 +374,21 @@ static int try_mount(char *spec, char *mount_point, int flags,
 {
 	int ret;
 
-	if (strcmp(fs_type, "nfs4") == 0)
-		ret = nfs4mount(spec, mount_point, flags,
-				extra_opts, fake, bg);
-	else
-		ret = nfsmount(spec, mount_point, flags,
-				extra_opts, fake, bg);
+	if (string) {
+		if (strcmp(fs_type, "nfs4") == 0)
+			ret = nfs4mount_s(spec, mount_point, flags,
+						extra_opts, fake, bg);
+		else
+			ret = nfsmount_s(spec, mount_point, flags,
+						extra_opts, fake, bg);
+	} else {
+		if (strcmp(fs_type, "nfs4") == 0)
+			ret = nfs4mount(spec, mount_point, flags,
+					extra_opts, fake, bg);
+		else
+			ret = nfsmount(spec, mount_point, flags,
+					extra_opts, fake, bg);
+	}
 
 	if (ret)
 		return ret;
@@ -420,7 +433,7 @@ int main(int argc, char *argv[])
 	mount_point = argv[2];
 
 	argv[2] = argv[0]; /* so that getopt error messages are correct */
-	while ((c = getopt_long(argc - 2, argv + 2, "rvVwfno:hs",
+	while ((c = getopt_long(argc - 2, argv + 2, "rvVwfno:hsi",
 				longopts, NULL)) != -1) {
 		switch (c) {
 		case 'r':
@@ -450,6 +463,9 @@ int main(int argc, char *argv[])
 		case 's':
 			++sloppy;
 			break;
+		case 'i':
+			++string;
+			break;
 		case 'h':
 		default:
 			mount_usage();


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
