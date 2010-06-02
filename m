From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 2/2] mount.nfs: silently fails when the network protocol is not found
Date: Wed,  2 Jun 2010 09:41:24 -0400
Message-ID: <1275486084-23899-3-git-send-email-steved@redhat.com>
References: <1275486084-23899-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:46011 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752933Ab0FBOyn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jun 2010 10:54:43 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1OJoCC-0002bc-Qn
	for linux-nfs@vger.kernel.org; Wed, 02 Jun 2010 09:41:24 -0400
In-Reply-To: <1275486084-23899-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

mount.nfs should display some type of error diagnostics when
the network protocol can not be determined.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/network.c |   17 +++++++++++++++--
 utils/mount/stropts.c |   16 +++++++++++-----
 2 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index de1014d..74f9cb2 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1307,6 +1307,8 @@ nfs_nfs_protocol(struct mount_options *options, unsigned long *protocol)
 		if (option != NULL) {
 			if (!nfs_get_proto(option, &family, protocol)) {
 				errno = EPROTONOSUPPORT;
+				nfs_error(_("%s: Failed to find '%s' protocol"), 
+					progname, option);
 				return 0;
 			}
 			return 1;
@@ -1393,8 +1395,13 @@ int nfs_nfs_proto_family(struct mount_options *options,
 	case 2: /* proto */
 		option = po_get(options, "proto");
 		if (option != NULL &&
-		    !nfs_get_proto(option, &tmp_family, &protocol))
+		    !nfs_get_proto(option, &tmp_family, &protocol)) {
+
+			nfs_error(_("%s: Failed to find '%s' protocol"), 
+				progname, option);
+			errno = EPROTONOSUPPORT;
 			goto out_err;
+		}
 	}
 
 	if (!nfs_verify_family(tmp_family))
@@ -1482,6 +1489,8 @@ nfs_mount_protocol(struct mount_options *options, unsigned long *protocol)
 	if (option != NULL) {
 		if (!nfs_get_proto(option, &family, protocol)) {
 			errno = EPROTONOSUPPORT;
+			nfs_error(_("%s: Failed to find '%s' protocol"), 
+				progname, option);
 			return 0;
 		}
 		return 1;
@@ -1539,8 +1548,12 @@ int nfs_mount_proto_family(struct mount_options *options,
 
 	option = po_get(options, "mountproto");
 	if (option != NULL) {
-		if (!nfs_get_proto(option, &tmp_family, &protocol))
+		if (!nfs_get_proto(option, &tmp_family, &protocol)) {
+			nfs_error(_("%s: Failed to find '%s' protocol"), 
+				progname, option);
+			errno = EPROTONOSUPPORT;
 			goto out_err;
+		}
 		if (!nfs_verify_family(tmp_family))
 			goto out_err;
 		*family = tmp_family;
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 98557d2..0241400 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -538,7 +538,10 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options)
 
 	if (!nfs_construct_new_options(options, nfs_saddr, &nfs_pmap,
 					mnt_saddr, &mnt_pmap)) {
-		errno = EINVAL;
+		if (rpc_createerr.cf_stat == RPC_UNKNOWNPROTO)
+			errno = EPROTONOSUPPORT;
+		else
+			errno = EINVAL;
 		return 0;
 	}
 
@@ -586,18 +589,21 @@ static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
 		errno = ENOMEM;
 		return result;
 	}
-
+	errno = 0;
 	if (!nfs_append_addr_option(sap, salen, options)) {
-		errno = EINVAL;
+		if (errno == 0)
+			errno = EINVAL;
 		goto out_fail;
 	}
 
 	if (!nfs_fix_mounthost_option(options, mi->hostname)) {
-		errno = EINVAL;
+		if (errno == 0)
+			errno = EINVAL;
 		goto out_fail;
 	}
 	if (!mi->fake && !nfs_verify_lock_option(options)) {
-		errno = EINVAL;
+		if (errno == 0)
+			errno = EINVAL;
 		goto out_fail;
 	}
 
-- 
1.6.6.1

