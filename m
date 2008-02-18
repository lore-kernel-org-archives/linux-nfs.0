From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 17/17] NFS: Introduce "-4" and "-6" options to the mount.nfs
	command
Date: Mon, 18 Feb 2008 13:36:48 -0500
Message-ID: <20080218183648.19060.50458.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:57211 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085AbYBRSgt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2008 13:36:49 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1IIamrr020054
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 10:36:48 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1IIamoW019396
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 13:36:48 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add command line options to mount.nfs that allow it to prioritize DNS
resolution results for a server with interfaces registered for both
families.

Since this is a mount.nfs command line option and not something more
visible at higher levels (like as a mount option), consider this feature
useful mostly for testing.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c       |   15 ++++++++++++++-
 utils/mount/mount.nfs.man |    8 ++++++++
 utils/mount/stropts.c     |    3 ++-
 3 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 33d8d30..eecf1ad 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -54,6 +54,7 @@ int nomtab;
 int verbose;
 int sloppy;
 int string;
+int dnsfamily = AF_INET;
 
 #define FOREGROUND	(0)
 #define BACKGROUND	(1)
@@ -294,6 +295,10 @@ void mount_usage(void)
 	printf(_("\t-v\t\tVerbose\n"));
 	printf(_("\t-V\t\tPrint version\n"));
 	printf(_("\t-w\t\tMount file system read-write\n"));
+#if IPV6_SUPPORTED
+	printf(_("\t-4\t\tFavor IPv4 DNS resolution results\n"));
+	printf(_("\t-6\t\tFavor IPv6 DNS resolution results\n"));
+#endif
 	printf(_("\t-f\t\tFake mount, do not actually mount\n"));
 	printf(_("\t-n\t\tDo not update /etc/mtab\n"));
 	printf(_("\t-s\t\tTolerate sloppy mount options rather than fail\n"));
@@ -442,7 +447,7 @@ int main(int argc, char *argv[])
 	mount_point = argv[2];
 
 	argv[2] = argv[0]; /* so that getopt error messages are correct */
-	while ((c = getopt_long(argc - 2, argv + 2, "rvVwfno:hs",
+	while ((c = getopt_long(argc - 2, argv + 2, "rvVw46fno:hs",
 				longopts, NULL)) != -1) {
 		switch (c) {
 		case 'r':
@@ -457,6 +462,14 @@ int main(int argc, char *argv[])
 		case 'w':
 			flags &= ~MS_RDONLY;
 			break;
+#if IPV6_SUPPORTED
+		case '4':
+			dnsfamily = AF_INET;
+			break;
+		case '6':
+			dnsfamily = AF_INET6;
+			break;
+#endif
 		case 'f':
 			++fake;
 			break;
diff --git a/utils/mount/mount.nfs.man b/utils/mount/mount.nfs.man
index 1a4561b..9526d9e 100644
--- a/utils/mount/mount.nfs.man
+++ b/utils/mount/mount.nfs.man
@@ -39,6 +39,14 @@ Print version.
 .BI "\-w"
 Mount file system read-write.
 .TP
+.BI "\-4"
+If a server has both IPv4 and IPv6 interfaces,
+favor IPv4 results when resolving the server's hostname to an IP address.
+.TP
+.BI "\-6"
+If a server has both IPv4 and IPv6 interfaces,
+favor IPv6 results when resolving the server's hostname to an IP address.
+.TP
 .BI "\-f"
 Fake mount. Don't actually call the mount system call.
 .TP
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index caf13b1..eef9ebf 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -71,6 +71,7 @@
 extern int nfs_mount_data_version;
 extern char *progname;
 extern int verbose;
+extern int dnsfamily;
 
 static int parse_devname(const char *spec, char **hostname)
 {
@@ -732,7 +733,7 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
 
 	if (!parse_devname(spec, &hostname))
 		return retval;
-	if (nfs_name_to_address(hostname, AF_UNSPEC, saddr))
+	if (nfs_name_to_address(hostname, dnsfamily, saddr))
 		goto fail;
 
 	options = po_split(*extra_opts);

