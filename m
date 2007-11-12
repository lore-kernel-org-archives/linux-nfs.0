From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] mount.nfs: Time to pull the covers off text-based NFS
	mounts
Date: Mon, 12 Nov 2007 12:46:18 -0500
Message-ID: <20071112174618.3134.45020.stgit@localhost.localdomain>
References: <20071112172835.3134.36815.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: steved@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IrdMj-0001S6-8X
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 09:46:29 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IrdMn-0003SO-0r
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 09:46:35 -0800
In-Reply-To: <20071112172835.3134.36815.stgit@localhost.localdomain>
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
index f3400e2..ea47cb4 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -65,7 +65,6 @@ static struct option longopts[] = {
   { "version", 0, 0, 'V' },
   { "read-write", 0, 0, 'w' },
   { "rw", 0, 0, 'w' },
-  { "string", 0, 0, 'i' },
   { "options", 1, 0, 'o' },
   { NULL, 0, 0, 0 }
 };
@@ -177,6 +176,9 @@ static void discover_nfs_mount_data_version(void)
 	}
 	if (nfs_mount_data_version > NFS_MOUNT_VERSION)
 		nfs_mount_data_version = NFS_MOUNT_VERSION;
+	else
+		if (kernel_version > MAKE_VERSION(2, 6, 22))
+			string++;
 }
 
 static void print_one(char *spec, char *node, char *type, char *opts)
@@ -286,7 +288,6 @@ void mount_usage(void)
 	printf(_("\t-f\t\tFake mount, do not actually mount\n"));
 	printf(_("\t-n\t\tDo not update /etc/mtab\n"));
 	printf(_("\t-s\t\tTolerate sloppy mount options rather than fail\n"));
-	printf(_("\t-i\t\tPass mount options to the kernel via a string\n"));
 	printf(_("\t-h\t\tPrint this help\n"));
 	printf(_("\tnfsoptions\tRefer to mount.nfs(8) or nfs(5)\n\n"));
 }
@@ -432,7 +433,7 @@ int main(int argc, char *argv[])
 	mount_point = argv[2];
 
 	argv[2] = argv[0]; /* so that getopt error messages are correct */
-	while ((c = getopt_long(argc - 2, argv + 2, "rvVwfno:hsi",
+	while ((c = getopt_long(argc - 2, argv + 2, "rvVwfno:hs",
 				longopts, NULL)) != -1) {
 		switch (c) {
 		case 'r':
@@ -462,20 +463,6 @@ int main(int argc, char *argv[])
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
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
