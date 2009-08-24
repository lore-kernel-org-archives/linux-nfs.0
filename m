From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] Enable v4 mounts when either "nfsvers=4" or "vers=4" option
 are set (vers-01)
Date: Mon, 24 Aug 2009 12:05:00 -0400
Message-ID: <4A92BA2C.3030407@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20132 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752785AbZHXQFD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Aug 2009 12:05:03 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Incorporating all the input from the RFC of this patch (thank you very much) 
here is the actual patch that allows v4 mount to occurr by setting mount 
version to '4' on the mount command line.

The patch is on the "mount_vers4-r1" branch on my experiential git tree:
     git://linux-nfs.org/~steved/nfs-utils-exp.git

Comments?

steved.

commit 8ae2bbb042559cd283067322072b6d669819e729
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Aug 24 12:06:51 2009 -0400

    Enable v4 mounts when either "nfsvers=4" or "vers=4" option are set.
    
    Since nfs4 is a different file system than nfs, the file system type
    has to be set when "v4" or "vers=4" or "nfsvers=4" are used. So
    when either of these options are specified, the file system type
    will be set to "nfs4" and those options will be stripped out of the
    option list since the kernel will not know how to parse them
    with v4 mounts
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/network.c b/utils/mount/network.c
index f6fa5fd..d3185b4 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -90,11 +90,11 @@ static const char *nfs_transport_opttbl[] = {
 static const char *nfs_version_opttbl[] = {
 	"v2",
 	"v3",
+	"v4",
 	"vers",
 	"nfsvers",
 	NULL,
 };
-
 static const unsigned long nfs_to_mnt[] = {
 	0,
 	0,
@@ -1203,7 +1203,7 @@ nfs_nfs_program(struct mount_options *options, unsigned long *program)
  * Returns TRUE if @version contains a valid value for this option,
  * or FALSE if the option was specified with an invalid value.
  */
-static int
+int
 nfs_nfs_version(struct mount_options *options, unsigned long *version)
 {
 	long tmp;
@@ -1215,10 +1215,13 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
 	case 1: /* v3 */
 		*version = 3;
 		return 1;
-	case 2:	/* vers */
+	case 2: /* v4 */
+		*version = 4;
+		return 1;
+	case 3:	/* vers */
 		switch (po_get_numeric(options, "vers", &tmp)) {
 		case PO_FOUND:
-			if (tmp >= 2 && tmp <= 3) {
+			if (tmp >= 2 && tmp <= 4) {
 				*version = tmp;
 				return 1;
 			}
@@ -1229,10 +1232,10 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
 		case PO_BAD_VALUE:
 			return 0;
 		}
-	case 3: /* nfsvers */
+	case 4: /* nfsvers */
 		switch (po_get_numeric(options, "nfsvers", &tmp)) {
 		case PO_FOUND:
-			if (tmp >= 2 && tmp <= 3) {
+			if (tmp >= 2 && tmp <= 4) {
 				*version = tmp;
 				return 1;
 			}
diff --git a/utils/mount/network.h b/utils/mount/network.h
index db5134c..5169b26 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -62,6 +62,7 @@ int nfs_options2pmap(struct mount_options *,
 int start_statd(void);
 
 unsigned long nfsvers_to_mnt(const unsigned long);
+int nfs_nfs_version(struct mount_options *, unsigned long *);
 
 int nfs_call_umount(clnt_addr_t *, dirpath *);
 int nfs_advise_umount(const struct sockaddr *, const socklen_t,
diff --git a/utils/mount/nfsmount.conf b/utils/mount/nfsmount.conf
index f9fcfcb..1848359 100644
--- a/utils/mount/nfsmount.conf
+++ b/utils/mount/nfsmount.conf
@@ -28,7 +28,7 @@
 # This statically named section defines global mount 
 # options that can be applied on all NFS mount.
 #
-# Protocol Version [2,3]
+# Protocol Version [2,3,4]
 # Nfsvers=3
 # Network Transport [Udp,Tcp,Rdma]
 # Proto=Tcp
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index a12ace7..0d82441 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -656,6 +656,47 @@ static int nfsmount_bg(struct nfsmount_info *mi)
 		return nfsmount_child(mi);
 }
 
+static const char *nfs_fstype_opttbl[] = {
+	"v4",
+	"vers",
+	"nfsvers",
+	NULL,
+};
+
+/*
+ * Returns either "nfs" or "nfs4" as the file system type
+ * depending on which (if any) of the nfs version options
+ * are specified. 
+ */
+char *nfs_fs_type(struct mount_options *options)
+{
+	unsigned long version;
+	static char *fs_type = "nfs";
+
+	if (nfs_nfs_version(options, &version) == 0)
+		return fs_type;
+
+	if (version != 4)
+		return fs_type;
+
+	fs_type = "nfs4";
+	switch(po_rightmost(options, nfs_fstype_opttbl)) {
+	case 0: /* v4 */
+		po_remove_all(options, "v4");
+		break;
+	case 1: /* vers=4 */
+		po_remove_all(options, "vers");
+		break;
+	case 2: /* nfsvers=4 */
+		po_remove_all(options, "nfsvers");
+		break;
+	default: /* Is this even possible ?? */
+		fs_type = "nfs";
+	}
+
+	return fs_type;
+}
+
 /*
  * Process mount options and try a mount system call.
  *
@@ -669,6 +710,9 @@ static const char *nfs_background_opttbl[] = {
 
 static int nfsmount_start(struct nfsmount_info *mi)
 {
+
+	mi->type = nfs_fs_type(mi->options);
+
 	if (!nfs_validate_options(mi))
 		return EX_FAIL;
 



 
