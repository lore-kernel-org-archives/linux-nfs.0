From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/17] mount.nfs: Always preset nfs_mount_version
Date: Sun, 15 Jul 2007 23:15:24 -0400
Message-ID: <20070716031524.11209.2844.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAH3V-0001na-7U
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:25 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IAH3Y-0005zR-7Q
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:29 -0700
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

nfs_mount_version is a global integer that is set based on a guess
about which nfs_mount_data version is appropriate for the kernel we're
running on.

Make it always available and have the correct value before calling mount
and unmount so they don't have to worry about setting it themselves.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c     |   49 +++++++++++++++++++++++++++
 utils/mount/nfsmount.c  |   84 ++++++++---------------------------------------
 utils/mount/nfsumount.c |    3 --
 3 files changed, 64 insertions(+), 72 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 28c4718..14f70de 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -26,6 +26,7 @@
 #include <errno.h>
 #include <fcntl.h>
 #include <sys/mount.h>
+#include <sys/utsname.h>
 #include <getopt.h>
 #include <mntent.h>
 #include <pwd.h>
@@ -43,6 +44,7 @@
 #include "nfsmount_err.h"
 
 char *progname;
+int nfs_mount_data_version;
 int nomtab;
 int verbose;
 int sloppy;
@@ -123,6 +125,51 @@ static const struct opt_map opt_map[] = {
   { NULL,	0, 0, 0		}
 };
 
+#define MAKE_VERSION(p,q,r)	(65536 * (p) + 256 * (q) + (r))
+
+int linux_version_code(void)
+{
+	struct utsname my_utsname;
+	int p, q, r;
+
+	if (uname(&my_utsname) == 0) {
+		p = atoi(strtok(my_utsname.release, "."));
+		q = atoi(strtok(NULL, "."));
+		r = atoi(strtok(NULL, "."));
+		return MAKE_VERSION(p,q,r);
+	}
+	return 0;
+}
+
+/*
+ * Choose the version of the nfs_mount_data structure that is appropriate
+ * for the kernel that is doing the mount.
+ *
+ * NFS_MOUNT_VERSION:		maximum version supported by these sources
+ * nfs_mount_data_version:	maximum version supported by the running kernel
+ */
+static void discover_nfs_mount_data_version(void)
+{
+	int kernel_version = linux_version_code();
+
+	if (kernel_version) {
+		if (kernel_version < MAKE_VERSION(2, 1, 32))
+			nfs_mount_data_version = 1;
+		else if (kernel_version < MAKE_VERSION(2, 2, 18))
+			nfs_mount_data_version = 3;
+		else if (kernel_version < MAKE_VERSION(2, 3, 0))
+			nfs_mount_data_version = 4;
+		else if (kernel_version < MAKE_VERSION(2, 3, 99))
+			nfs_mount_data_version = 3;
+		else if (kernel_version < MAKE_VERSION(2, 6, 3))
+			nfs_mount_data_version = 4;
+		else
+			nfs_mount_data_version = 6;
+	}
+	if (nfs_mount_data_version > NFS_MOUNT_VERSION)
+		nfs_mount_data_version = NFS_MOUNT_VERSION;
+}
+
 /* Try to build a canonical options string.  */
 static char * fix_opts_string (int flags, const char *extra_opts) {
 	const struct opt_map *om;
@@ -356,6 +403,8 @@ int main(int argc, char *argv[])
 
 	progname = basename(argv[0]);
 
+	discover_nfs_mount_data_version();
+
 	if(!strncmp(progname, "umount", strlen("umount"))) {
 		if(argc < 2) {
 			umount_usage();
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 7c52c1c..24dc6e6 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -48,7 +48,6 @@
 #include <rpc/pmap_clnt.h>
 #include <sys/socket.h>
 #include <sys/time.h>
-#include <sys/utsname.h>
 #include <sys/stat.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
@@ -73,10 +72,9 @@
 #define NFS_FHSIZE 32
 #endif
 
-#define MAKE_VERSION(p,q,r)	(65536*(p) + 256*(q) + (r))
-#define MAX_NFSPROT ((nfs_mount_version >= 4) ? 3 : 2)
-#define MAX_MNTPROT ((nfs_mount_version >= 4) ? 3 : 2)
-#define HAVE_RELIABLE_TCP (nfs_mount_version >= 4)
+#define MAX_NFSPROT ((nfs_mount_data_version >= 4) ? 3 : 2)
+#define MAX_MNTPROT ((nfs_mount_data_version >= 4) ? 3 : 2)
+#define HAVE_RELIABLE_TCP (nfs_mount_data_version >= 4)
 
 #ifndef HAVE_INET_ATON
 #define inet_aton(a,b) (0)
@@ -93,9 +91,12 @@ typedef union {
 	mnt3res_t nfsv3;
 } mntres_t;
 
+extern int nfs_mount_data_version;
 extern int verbose;
 extern int sloppy;
 
+extern int linux_version_code();
+
 /* Define the order in which to probe for UDP/TCP services */
 enum plist {
 	use_tcp = 0,
@@ -144,59 +145,6 @@ mnt_probelist(const int vers)
 	}
 }
 
-static int
-linux_version_code(void) {
-	struct utsname my_utsname;
-	int p, q, r;
-
-	if (uname(&my_utsname) == 0) {
-		p = atoi(strtok(my_utsname.release, "."));
-		q = atoi(strtok(NULL, "."));
-		r = atoi(strtok(NULL, "."));
-		return MAKE_VERSION(p,q,r);
-	}
-	return 0;
-}
-
-/*
- * Unfortunately, the kernel prints annoying console messages
- * in case of an unexpected nfs mount version (instead of
- * just returning some error).  Therefore we'll have to try
- * and figure out what version the kernel expects.
- *
- * Variables:
- *	NFS_MOUNT_VERSION: these nfsmount sources at compile time
- *	nfs_mount_version: version this source and running kernel can handle
- */
-int nfs_mount_version = NFS_MOUNT_VERSION;
-
-int
-find_kernel_nfs_mount_version(void) {
-	static int kernel_version = -1;
-	int mnt_version = NFS_MOUNT_VERSION;
-
-	if (kernel_version == -1)
-		kernel_version = linux_version_code();
-
-	if (kernel_version) {
-	     if (kernel_version < MAKE_VERSION(2,1,32))
-		  mnt_version = 1;
-	     else if (kernel_version < MAKE_VERSION(2,2,18))
-		  mnt_version = 3;
-	     else if (kernel_version < MAKE_VERSION(2,3,0))
-		  mnt_version = 4; /* since 2.2.18pre9 */
-	     else if (kernel_version < MAKE_VERSION(2,3,99))
-		  mnt_version = 3;
-	     else if (kernel_version < MAKE_VERSION(2,6,3))
-		  mnt_version = 4;
-	     else
-		  mnt_version = 6;
-	}
-	if (mnt_version > NFS_MOUNT_VERSION)
-	     mnt_version = NFS_MOUNT_VERSION;
-	return mnt_version;
-}
-
 int nfs_gethostbyname(const char *, struct sockaddr_in *);
 int nfs_gethostbyname(const char *hostname, struct sockaddr_in *saddr)
 {
@@ -554,7 +502,7 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 				opt = "nfsvers";
 #if NFS_MOUNT_VERSION >= 2
 			} else if (!strcmp(opt, "namlen")) {
-				if (nfs_mount_version >= 2)
+				if (nfs_mount_data_version >= 2)
 					data->namlen = val;
 				else if (sloppy)
 					continue;
@@ -578,7 +526,7 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 #if NFS_MOUNT_VERSION >= 2
 					data->flags &= ~NFS_MOUNT_TCP;
 				} else if (!strcmp(opteq+1, "tcp") &&
-					   nfs_mount_version > 2) {
+					   nfs_mount_data_version > 2) {
 					nfs_pmap->pm_prot = IPPROTO_TCP;
 					mnt_pmap->pm_prot = IPPROTO_TCP;
 					data->flags |= NFS_MOUNT_TCP;
@@ -591,7 +539,7 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 			} else if (!strcmp(opt, "sec")) {
 				char *secflavor = opteq+1;
 				/* see RFC 2623 */
-				if (nfs_mount_version < 5) {
+				if (nfs_mount_data_version < 5) {
 					printf(_("Warning: ignoring sec=%s option\n"), secflavor);
 					continue;
 				} else if (!strcmp(secflavor, "none"))
@@ -690,7 +638,7 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 			} else if (!strcmp(opt, "tcp")) {
 				data->flags &= ~NFS_MOUNT_TCP;
 				if (val) {
-					if (nfs_mount_version < 2)
+					if (nfs_mount_data_version < 2)
 						goto bad_option;
 					nfs_pmap->pm_prot = IPPROTO_TCP;
 					mnt_pmap->pm_prot = IPPROTO_TCP;
@@ -702,7 +650,7 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 			} else if (!strcmp(opt, "udp")) {
 				data->flags &= ~NFS_MOUNT_TCP;
 				if (!val) {
-					if (nfs_mount_version < 2)
+					if (nfs_mount_data_version < 2)
 						goto bad_option;
 					nfs_pmap->pm_prot = IPPROTO_TCP;
 					mnt_pmap->pm_prot = IPPROTO_TCP;
@@ -716,7 +664,7 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 			} else if (!strcmp(opt, "lock")) {
 				data->flags &= ~NFS_MOUNT_NONLM;
 				if (!val) {
-					if (nfs_mount_version < 3)
+					if (nfs_mount_data_version < 3)
 						goto bad_option;
 					data->flags |= NFS_MOUNT_NONLM;
 				}
@@ -725,7 +673,7 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 			} else if (!strcmp(opt, "broken_suid")) {
 				data->flags &= ~NFS_MOUNT_BROKEN_SUID;
 				if (val) {
-					if (nfs_mount_version < 4)
+					if (nfs_mount_data_version < 4)
 						goto bad_option;
 					data->flags |= NFS_MOUNT_BROKEN_SUID;
 				}
@@ -827,8 +775,6 @@ nfsmount(const char *spec, const char *node, int *flags,
 	time_t prevt;
 	time_t timeout;
 
-	nfs_mount_version = find_kernel_nfs_mount_version();
-
 	if (strlen(spec) >= sizeof(hostdir)) {
 		fprintf(stderr, _("mount: "
 				  "excessively long host:dir argument\n"));
@@ -929,7 +875,7 @@ nfsmount(const char *spec, const char *node, int *flags,
 	printf("\n");
 #endif
 
-	data.version = nfs_mount_version;
+	data.version = nfs_mount_data_version;
 	*mount_opts = (char *) &data;
 
 	if (*flags & MS_REMOUNT)
@@ -1105,7 +1051,7 @@ noauth_flavors:
 #endif
 	}
 
-	if (nfs_mount_version == 1) {
+	if (nfs_mount_data_version == 1) {
 		/* create nfs socket for kernel */
 		if (nfs_pmap->pm_prot == IPPROTO_TCP)
 			fsock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index c275da8..4069a38 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -46,14 +46,12 @@
 #endif
 
 extern char *progname;
-extern int nfs_mount_version;
 extern int nomtab;
 extern int verbose;
 int force;
 int lazy;
 int remount;
 
-extern int find_kernel_nfs_mount_version(void);
 extern int probe_mntport(clnt_addr_t *);
 extern int nfs_gethostbyname(const char *, struct sockaddr_in *);
 
@@ -176,7 +174,6 @@ int _nfsumount(const char *spec, char *opts)
 	struct pmap *pmap = &mnt_server.pmap;
 	char *p;
 
-	nfs_mount_version = find_kernel_nfs_mount_version();
 	if (spec == NULL || (p = strchr(spec,':')) == NULL)
 		goto out_bad;
 	hostname = xstrndup(spec, p-spec);


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
