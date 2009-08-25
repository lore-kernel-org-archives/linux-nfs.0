From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 1/2] Enable v4 mounts when either "nfsvers=4" or "vers=4"
	option are set (vers-02)
Date: Tue, 25 Aug 2009 13:54:11 -0400
Message-ID: <4A942543.50403@RedHat.com>
References: <4A9424DB.2040303@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4A9424DB.2040303@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

commit 69ec4e2c98cd4727eef72c1e16b326171c5ac774
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Aug 25 12:12:14 2009 -0400

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
index a12ace7..153723d 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -656,6 +656,48 @@ static int nfsmount_bg(struct nfsmount_info *mi)
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
+char *nfs_fs_type(struct nfsmount_info *mi)
+{
+	struct mount_options *options = mi->options;
+	char *fs_type = (char *)mi->type;
+	unsigned long version;
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
+		fs_type = (char *)mi->type; 
+	}
+
+	return fs_type;
+}
+
 /*
  * Process mount options and try a mount system call.
  *
@@ -669,6 +711,9 @@ static const char *nfs_background_opttbl[] = {
 
 static int nfsmount_start(struct nfsmount_info *mi)
 {
+
+	mi->type = nfs_fs_type(mi);
+
 	if (!nfs_validate_options(mi))
 		return EX_FAIL;
