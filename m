From: Steve Dickson <SteveD@redhat.com>
Subject: [Patch 5/9] Hooks needs incorporate file configuration code.
Date: Mon, 09 Mar 2009 17:03:04 -0400
Message-ID: <49B58408.4040001@RedHat.com>
References: <49B57FB2.9020000@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <49B57FB2.9020000@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

commit 4623964850df9c49a5ad5d77dffbb7181ed96a92
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Mar 9 14:01:38 2009 -0400

    Added hooks to the mount command that allow
    mount options to be set in a configuration file
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 06e2804..0c38ea3 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -46,6 +46,9 @@
 #include "error.h"
 #include "stropts.h"
 #include "version.h"
+#include "conffile.h"
+
+extern char *conf_get_mntopts(char *, char *, char *);
 
 char *progname;
 int nfs_mount_data_version;
@@ -474,6 +477,11 @@ int main(int argc, char *argv[])
 	spec = argv[1];
 	mount_point = argv[2];
 
+	/*
+	 * Read the the default mount options
+	 */
+	conf_init();
+
 	argv[2] = argv[0]; /* so that getopt error messages are correct */
 	while ((c = getopt_long(argc - 2, argv + 2, "rvVwfno:hs",
 				longopts, NULL)) != -1) {
@@ -559,7 +567,10 @@ int main(int argc, char *argv[])
 		mnt_err = EX_USAGE;
 		goto out;
 	}
-
+	/*
+	 * Concatenate mount options from the configuration file
+	 */
+	mount_opts = conf_get_mntopts(spec, mount_point, mount_opts);
 	parse_opts(mount_opts, &flags, &extra_opts);
 
 	if (uid != 0) {
