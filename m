From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 24/24] mount.nfs: Time to pull the covers off
	text-based NFS	mounts
Date: Wed, 12 Sep 2007 12:16:34 -0400
Message-ID: <20070912161634.23491.28356.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVUtC-0004bw-ST
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:16:31 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVUtH-00031L-Ga
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:16:35 -0700
Received: from manray.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8CGFin0031429
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 09:15:45 -0700
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id l8CGGY8L023651
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 12:16:34 -0400
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

Get rid of the "-i" option for mount.nfs[4] and always use the text-
based mount(2) system call for kernel version 2.6.23 and later.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |   21 ++++-----------------
 1 files changed, 4 insertions(+), 17 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 8c2e91d..4f2bc94 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -64,7 +64,6 @@ static struct option longopts[] = {
   { "version", 0, 0, 'V' },
   { "read-write", 0, 0, 'w' },
   { "rw", 0, 0, 'w' },
-  { "string", 0, 0, 'i' },
   { "options", 1, 0, 'o' },
   { NULL, 0, 0, 0 }
 };
@@ -176,6 +175,9 @@ static void discover_nfs_mount_data_version(void)
 	}
 	if (nfs_mount_data_version > NFS_MOUNT_VERSION)
 		nfs_mount_data_version = NFS_MOUNT_VERSION;
+	else
+		if (kernel_version > MAKE_VERSION(2, 6, 22))
+			string++;
 }
 
 static void print_one(char *spec, char *node, char *type, char *opts)
@@ -285,7 +287,6 @@ void mount_usage(void)
 	printf(_("\t-f\t\tFake mount, do not actually mount\n"));
 	printf(_("\t-n\t\tDo not update /etc/mtab\n"));
 	printf(_("\t-s\t\tTolerate sloppy mount options rather than fail\n"));
-	printf(_("\t-i\t\tPass mount options to the kernel via a string\n"));
 	printf(_("\t-h\t\tPrint this help\n"));
 	printf(_("\tnfsoptions\tRefer to mount.nfs(8) or nfs(5)\n\n"));
 }
@@ -435,7 +436,7 @@ int main(int argc, char *argv[])
 	mount_point = argv[2];
 
 	argv[2] = argv[0]; /* so that getopt error messages are correct */
-	while ((c = getopt_long(argc - 2, argv + 2, "rvVwfno:hsi",
+	while ((c = getopt_long(argc - 2, argv + 2, "rvVwfno:hs",
 				longopts, NULL)) != -1) {
 		switch (c) {
 		case 'r':
@@ -465,20 +466,6 @@ int main(int argc, char *argv[])
 		case 's':
 			++sloppy;
 			break;
-		case 'i':
-			if (linux_version_code() < MAKE_VERSION(2, 6, 23)) {
-				nfs_error(_("%s: Passing mount options via a"
-					" string is unsupported by this"
-					" kernel\n"), progname);
-				goto out_usage;
-			}
-			if (uid != 0) {
-				nfs_error(_("%s: -i option is restricted to 'root'\n"),
-					progname);
-				goto out_usage;
-			}
-			++string;
-			break;
 		case 'h':
 		default:
 			mount_usage();


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
