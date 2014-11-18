Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54585 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754771AbaKROGq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Nov 2014 09:06:46 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sAIE6jdN018977
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 18 Nov 2014 09:06:46 -0500
Received: from bcodding-csb.redhat.com (vpn-60-200.rdu2.redhat.com [10.10.60.200])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sAIE6jr7002682
	for <linux-nfs@vger.kernel.org>; Tue, 18 Nov 2014 09:06:45 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/6] mount.nfs: configurable minor version defaults
Date: Tue, 18 Nov 2014 09:06:44 -0500
Message-Id: <b5203298427d8057a9f8504b69abd9df67f4cea5.1416319371.git.bcodding@redhat.com>
In-Reply-To: <cover.1416319371.git.bcodding@redhat.com>
References: <cover.1416319371.git.bcodding@redhat.com>
In-Reply-To: <cover.1416319371.git.bcodding@redhat.com>
References: <cover.1416319371.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Update nfsmount.conf to allow minor version specification, and rearrange
the autonegotiation logic to agreed upon best behavior.  Depending upon the
combination of values specified within nfsmount.conf and given to mount.nfs,
the retry behavior of mount.nfs varies according to the general rule of
defaulting to the most specific setting, with some exceptions.  A general
guide to the expected behavior follows:

┌────────────────┐
│ nfsmount.conf  ├──────────────┬───────────────────┐
│ Defaultvers=   │  arg option  │     attempts:     │
├────────────────┼──────────────┼───────────────────┤
│     4.2        │  not set     │ v4.2 v4.1 v4.0 v3 │
│     4.2        │   v4         │ v4.2 v4.1 v4.0    │
│     4.1        │  not set     │      v4.1 v4.0 v3 │
│     4.1        │   v4         │      v4.1 v4.0    │
│     4          │  not set     │           v4.0 v3 │
│     4          │   v4         │           v4.0    │
│     3          │  not set     │                v3 │
│    any set     │   v4.2       │ v4.2              │
│    any set     │   v4.1       │      v4.1         │
│    any set     │   v4         │           v4.0    │
│    any set     │   v3         │                v3 │
│    not set     │  not set     │ v4.2 v4.1 v4.0 v3 │
└────────────────┴──────────────┴───────────────────┘

If built with --enable-mountconfig=no, then the behavior is the same as if
nfsmount.conf did not set Defaultvers.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 utils/mount/stropts.c |  138 +++++++++++++++++++++++++++++++++---------------
 1 files changed, 95 insertions(+), 43 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index faa77cf..76ecb32 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -94,24 +94,44 @@ struct nfsmount_info {
 				child;		/* forked bg child? */
 };
 
-#ifdef MOUNT_CONFIG
-static void nfs_default_version(struct nfsmount_info *mi);
 
 static void nfs_default_version(struct nfsmount_info *mi)
 {
+#ifdef MOUNT_CONFIG
 	extern struct nfs_version config_default_vers;
 	/*
 	 * Use the default value set in the config file when
 	 * the version has not been explicitly set.
 	 */
-	if (mi->version.major == 0 && config_default_vers.major) {
-		if (config_default_vers.major < 4)
-			mi->version = config_default_vers;
+	if (config_default_vers.v_mode == V_PARSE_ERR) {
+		mi->version.v_mode = V_PARSE_ERR;
+		return;
 	}
-}
-#else
-inline void nfs_default_version(__attribute__ ((unused)) struct nfsmount_info *mi) {}
+
+	if (mi->version.v_mode == V_GENERAL &&
+		config_default_vers.v_mode == V_DEFAULT) {
+		mi->version.v_mode = V_SPECIFIC;
+		return;
+	}
+
+	if (mi->version.v_mode == V_DEFAULT &&
+		config_default_vers.v_mode != V_DEFAULT) {
+		mi->version.major = config_default_vers.major;
+		mi->version.minor = config_default_vers.minor;
+		return;
+	}
+
+	if (mi->version.v_mode == V_GENERAL &&
+		config_default_vers.v_mode != V_DEFAULT) {
+		if (mi->version.major == config_default_vers.major)
+			mi->version.minor = config_default_vers.minor;
+		return;
+	}
+
 #endif /* MOUNT_CONFIG */
+	mi->version.major = 4;
+	mi->version.minor = 2;
+}
 
 /*
  * Obtain a retry timeout value based on the value of the "retry=" option.
@@ -308,28 +328,44 @@ static int nfs_set_version(struct nfsmount_info *mi)
 	 * 4 cannot be included when autonegotiating
 	 * while running on those kernels.
 	 */
-	if (mi->version.major == 0 &&
-	    linux_version_code() <= MAKE_VERSION(2, 6, 31))
+	if (mi->version.v_mode == V_DEFAULT &&
+	    linux_version_code() <= MAKE_VERSION(2, 6, 31)) {
 		mi->version.major = 3;
+		mi->version.v_mode = V_SPECIFIC;
+	}
 
 	/*
 	 * If we still don't know, check for version-specific
 	 * mount options.
 	 */
-	if (mi->version.major == 0) {
+	if (mi->version.v_mode == V_DEFAULT) {
 		if (po_contains(mi->options, "mounthost") ||
 		    po_contains(mi->options, "mountaddr") ||
 		    po_contains(mi->options, "mountvers") ||
-		    po_contains(mi->options, "mountproto"))
+		    po_contains(mi->options, "mountproto")) {
 			mi->version.major = 3;
+			mi->version.v_mode = V_SPECIFIC;
+		}
 	}
 
 	/*
 	 * If enabled, see if the default version was
 	 * set in the config file
 	 */
-	nfs_default_version(mi);
-	
+	if (mi->version.v_mode != V_SPECIFIC) {
+		nfs_default_version(mi);
+		/*
+		 * If the version was not specifically set, it will
+		 * be set by autonegotiation later, so remove it now:
+		 */
+		po_remove_all(mi->options, "v4");
+		po_remove_all(mi->options, "vers");
+		po_remove_all(mi->options, "nfsvers");
+	}
+
+	if (mi->version.v_mode == V_PARSE_ERR)
+		return 0;
+
 	return 1;
 }
 
@@ -684,6 +720,7 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
 {
 	struct mount_options *options = po_dup(mi->options);
 	int result = 0;
+	char version_opt[16];
 	char *extra_opts = NULL;
 
 	if (!options) {
@@ -691,20 +728,24 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
 		return result;
 	}
 
-	if (mi->version.major == 0) {
-		if (po_contains(options, "mounthost") ||
-			po_contains(options, "mountaddr") ||
-			po_contains(options, "mountvers") ||
-			po_contains(options, "mountproto")) {
-		/*
-		 * Since these mountd options are set assume version 3
-		 * is wanted so error out with EPROTONOSUPPORT so the
-		 * protocol negation starts with v3.
-		 */
-			errno = EPROTONOSUPPORT;
-			goto out_fail;
-		}
-		if (po_append(options, "vers=4") == PO_FAILED) {
+	if (po_contains(options, "mounthost") ||
+		po_contains(options, "mountaddr") ||
+		po_contains(options, "mountvers") ||
+		po_contains(options, "mountproto")) {
+	/*
+	 * Since these mountd options are set assume version 3
+	 * is wanted so error out with EPROTONOSUPPORT so the
+	 * protocol negation starts with v3.
+	 */
+		errno = EPROTONOSUPPORT;
+		goto out_fail;
+	}
+
+	if (mi->version.v_mode != V_SPECIFIC) {
+		snprintf(version_opt, sizeof(version_opt) - 1,
+			"vers=%lu.%lu", mi->version.major, mi->version.minor);
+
+		if (po_append(options, version_opt) == PO_FAILED) {
 			errno = EINVAL;
 			goto out_fail;
 		}
@@ -792,14 +833,25 @@ static int nfs_autonegotiate(struct nfsmount_info *mi)
 	int result;
 
 	result = nfs_try_mount_v4(mi);
+check_result:
 	if (result)
 		return result;
 
-check_errno:
 	switch (errno) {
 	case EPROTONOSUPPORT:
 		/* A clear indication that the server or our
-		 * client does not support NFS version 4. */
+		 * client does not support NFS version 4 and minor */
+		if (mi->version.v_mode == V_GENERAL &&
+			mi->version.minor == 0)
+				return result;
+		if (mi->version.v_mode != V_SPECIFIC) {
+			if (mi->version.minor > 0) {
+				mi->version.minor--;
+				result = nfs_try_mount_v4(mi);
+				goto check_result;
+			}
+		}
+
 		goto fall_back;
 	case ENOENT:
 		/* Legacy Linux servers don't export an NFS
@@ -818,7 +870,7 @@ check_errno:
 			/* v4 server seems to be registered now. */
 			result = nfs_try_mount_v4(mi);
 			if (result == 0 && errno != ECONNREFUSED)
-				goto check_errno;
+				goto check_result;
 		}
 		return result;
 	default:
@@ -840,18 +892,18 @@ static int nfs_try_mount(struct nfsmount_info *mi)
 	int result = 0;
 
 	switch (mi->version.major) {
-	case 0:
-		result = nfs_autonegotiate(mi);
-		break;
-	case 2:
-	case 3:
-		result = nfs_try_mount_v3v2(mi, FALSE);
-		break;
-	case 4:
-		result = nfs_try_mount_v4(mi);
-		break;
-	default:
-		errno = EIO;
+		case 2:
+		case 3:
+			result = nfs_try_mount_v3v2(mi, FALSE);
+			break;
+		case 4:
+			if (mi->version.v_mode != V_SPECIFIC)
+				result = nfs_autonegotiate(mi);
+			else
+				result = nfs_try_mount_v4(mi);
+			break;
+		default:
+			errno = EIO;
 	}
 
 	return result;
-- 
1.7.1

