From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] umount.nfs command: Support AF_INET6 server addresses
Date: Wed, 28 Jan 2009 18:07:49 -0500
Message-ID: <20090128230749.21484.53663.stgit@ingres.1015granger.net>
References: <20090128225938.21484.82096.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:51908 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751908AbZA1XJG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jan 2009 18:09:06 -0500
In-Reply-To: <20090128225938.21484.82096.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace existing mount option parser in nfsumount.c with the new pmap stuffer
function nfs_options2pmap().  Mount option parsing for umount.nfs now works
the same as it does for mount option rewriting in the text-based mount.nfs
command.

This adds a number of new features:

  1.  The new logic supports resolving AF_INET6 server addresses
  2.  Support is added for the recently introduced "mountaddr" option.
  3.  Parsing numeric option values is much more careful
  4.  Option parsing no longer uses xmalloc/xstrdup, so it won't fail
      silently if memory can't be allocated
  5.  Mount program number set in /etc/rpc is respected
  6.  Mount doesn't exit with EX_USAGE if the hostname lookup fails

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsumount.c |  103 +++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 99 insertions(+), 4 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index b2327e0..04990f0 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -34,6 +34,7 @@
 #include "mount.h"
 #include "error.h"
 #include "network.h"
+#include "parse_opt.h"
 #include "parse_dev.h"
 
 #if !defined(MNT_FORCE)
@@ -134,6 +135,100 @@ static int del_mtab(const char *spec, const char *node)
 }
 
 /*
+ * Discover mount server's hostname/address by examining mount options
+ *
+ * Returns a pointer to a string that the caller must free, on
+ * success; otherwise NULL is returned.
+ */
+static char *nfs_umount_hostname(struct mount_options *options,
+				 char *hostname)
+{
+	char *option;
+
+	option = po_get(options, "mountaddr");
+	if (option)
+		goto out;
+	option = po_get(options, "mounthost");
+	if (option)
+		goto out;
+	option = po_get(options, "addr");
+	if (option)
+		goto out;
+
+	return hostname;
+
+out:
+	free(hostname);
+	return strdup(option);
+}
+
+/*
+ * Returns EX_SUCCESS if mount options and device name have been
+ * parsed successfully; otherwise EX_FAIL.
+ */
+static int nfs_umount_do_umnt(struct mount_options *options,
+			      char **hostname, char **dirname)
+{
+	struct sockaddr_storage address;
+	struct sockaddr *sap = (struct sockaddr *)&address;
+	socklen_t salen = sizeof(address);
+	struct pmap nfs_pmap, mnt_pmap;
+
+	nfs_options2pmap(options, &nfs_pmap, &mnt_pmap);
+
+	*hostname = nfs_umount_hostname(options, *hostname);
+	if (!*hostname) {
+		nfs_error(_("%s: out of memory"), progname);
+		return EX_FAIL;
+	}
+
+	if (nfs_name_to_address(*hostname, AF_UNSPEC, sap, &salen)) {
+		if (nfs_advise_umount(sap, salen, &mnt_pmap, dirname) != 0)
+			return EX_SUCCESS;
+		else
+			nfs_error(_("%s: Server failed to unmount '%s:%s'"),
+					progname, *hostname, *dirname);
+	}
+	return EX_FAIL;
+}
+
+/*
+ * Pick up certain mount options used during the original mount
+ * from /etc/mtab.  The basics include the server's IP address and
+ * the server pathname of the share to unregister.
+ *
+ * These options might also describe the mount port, mount protocol
+ * version, and transport protocol used to punch through a firewall.
+ * We will need this information to get through the firewall again
+ * to do the umount.
+ *
+ * Note that option parsing failures won't necessarily cause the
+ * umount request to fail.  Those values will be left zero in the
+ * pmap tuple.  If the GETPORT call later fails to disambiguate them,
+ * then we fail.
+ */
+static int nfs_umount23(const char *devname, char *string)
+{
+	char *hostname, *dirname;
+	struct mount_options *options;
+	int result = EX_FAIL;
+
+	if (!nfs_parse_devname(devname, &hostname, &dirname))
+		return EX_USAGE;
+
+	options = po_split(string);
+	if (options) {
+		result = nfs_umount_do_umnt(options, &hostname, &dirname);
+		po_destroy(options);
+	} else
+		nfs_error(_("%s: option parsing error"), progname);
+
+	free(hostname);
+	free(dirname);
+	return result;
+}
+
+/*
  * Pick up certain mount options used during the original mount
  * from /etc/mtab.  The basics include the server's IP address and
  * the server pathname of the share to unregister.
@@ -350,16 +445,16 @@ int nfsumount(int argc, char *argv[])
 	ret = 0;
 	if (mc) {
 		if (!lazy && strcmp(mc->m.mnt_type, "nfs4") != 0)
-			/* We ignore the error from do_nfs_umount23.
+			/* We ignore the error from nfs_umount23.
 			 * If the actual umount succeeds (in del_mtab),
 			 * we don't want to signal an error, as that
 			 * could cause /sbin/mount to retry!
 			 */
-			do_nfs_umount23(mc->m.mnt_fsname, mc->m.mnt_opts);
-		ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir);
+			nfs_umount23(mc->m.mnt_fsname, mc->m.mnt_opts);
+		ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir) ?: ret;
 	} else if (*spec != '/') {
 		if (!lazy)
-			ret = do_nfs_umount23(spec, "tcp,v3");
+			ret = nfs_umount23(spec, "tcp,v3");
 	} else
 		ret = del_mtab(NULL, spec);
 

