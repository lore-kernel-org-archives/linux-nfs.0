From: Steve Dickson <SteveD@redhat.com>
Subject: [Patch 7/10] NFS Mount Configuration File (Vers 3)
Date: Thu, 06 Aug 2009 14:46:45 -0400
Message-ID: <4A7B2515.2040304@RedHat.com>
References: <4A7B2324.9090406@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4A7B2324.9090406@RedHat.com>
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

commit eab66bd02db90965d1cbf4e100a274a4e3e6e29e
Author: Steve Dickson <steved@redhat.com>
Date:   Sun Aug 2 12:37:19 2009 -0400

    Added hooks to the mount command that allow
    mount options to be set in a configuration file
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index a668cd9..30d087e 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -47,6 +47,11 @@
 #include "stropts.h"
 #include "version.h"
 
+#ifdef MOUNT_CONFIG
+#include "conffile.h"
+extern char *conf_get_mntopts(char *, char *, char *);
+#endif
+
 char *progname;
 int nfs_mount_data_version;
 int nomtab;
@@ -474,6 +479,13 @@ int main(int argc, char *argv[])
 	spec = argv[1];
 	mount_point = argv[2];
 
+#ifdef MOUNT_CONFIG
+	/*
+	 * Read the the default mount options
+	 */
+	conf_init();
+#endif
+
 	argv[2] = argv[0]; /* so that getopt error messages are correct */
 	while ((c = getopt_long(argc - 2, argv + 2, "rvVwfno:hs",
 				longopts, NULL)) != -1) {
@@ -559,6 +571,12 @@ int main(int argc, char *argv[])
 		mnt_err = EX_USAGE;
 		goto out;
 	}
+#ifdef MOUNT_CONFIG
+	/*
+	 * Concatenate mount options from the configuration file
+	 */
+	mount_opts = conf_get_mntopts(spec, mount_point, mount_opts);
+#endif
 
 	parse_opts(mount_opts, &flags, &extra_opts);
