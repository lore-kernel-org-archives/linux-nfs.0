From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] mount.nfs: Ignore vers=4
Date: Sun, 30 Aug 2009 12:37:13 -0400
Message-ID: <20090830163617.4608.48355.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:32256 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753863AbZH3Qh2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Aug 2009 12:37:28 -0400
Received: from acsinet13.oracle.com (acsinet13.oracle.com [141.146.126.235])
	by rgminet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n7UGbuJW032182
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Sun, 30 Aug 2009 16:37:57 GMT
Received: from acsmt354.oracle.com (acsmt354.oracle.com [141.146.40.154])
	by acsinet13.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n7UG3CfT006619
	for <linux-nfs@vger.kernel.org>; Sun, 30 Aug 2009 16:38:11 GMT
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since mount.nfs looks at the vers= option to determine pmap parameters when
negotiating, it throws EINVAL if "4" is specified, even if the kernel
supports vers=4 for "nfs" type file systems.

Teach mount.nfs to ignore vers=4 and just pass the options to the kernel.

Also fix up umount.nfs to skip the UMNT call for vers=4 mounts.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c   |   12 ++++++++----
 utils/mount/nfsumount.c |    4 ++++
 utils/mount/stropts.c   |    6 ++++++
 3 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index f6fa5fd..420e15a 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -90,6 +90,7 @@ static const char *nfs_transport_opttbl[] = {
 static const char *nfs_version_opttbl[] = {
 	"v2",
 	"v3",
+	"v4",
 	"vers",
 	"nfsvers",
 	NULL,
@@ -1215,10 +1216,13 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
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
@@ -1229,10 +1233,10 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
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
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index f81db14..c5505b1 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -179,6 +179,10 @@ static int nfs_umount_do_umnt(struct mount_options *options,
 		return EX_FAIL;
 	}
 
+	/* Skip UMNT call for vers=4 mounts */
+	if (nfs_pmap.pm_vers == 4)
+		return EX_SUCCESS;
+
 	*hostname = nfs_umount_hostname(options, *hostname);
 	if (!*hostname) {
 		nfs_error(_("%s: out of memory"), progname);
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index a12ace7..3e88c85 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -438,6 +438,7 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options)
 	/*
 	 * Extract just the options needed to contact server.
 	 * Bail now if any of these have bad values.
+	 * Skip probing the server if this is a vers=4 mount
 	 */
 	if (!nfs_extract_server_addresses(options, nfs_saddr, &nfs_salen,
 						mnt_saddr, &mnt_salen)) {
@@ -448,6 +449,11 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options)
 		errno = EINVAL;
 		return 0;
 	}
+	if (nfs_pmap.pm_vers == 4) {
+		if (!nfs_append_clientaddr_option(nfs_saddr, nfs_salen, options))
+			errno = EINVAL;
+		goto out;
+	}
 
 	/*
 	 * The kernel NFS client doesn't support changing the RPC

