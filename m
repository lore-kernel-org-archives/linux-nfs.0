From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 2/2] mount.nfs: silently fails when the network protocol is not found
Date: Thu,  3 Jun 2010 12:51:38 -0400
Message-ID: <1275583898-17908-3-git-send-email-steved@redhat.com>
References: <1275583898-17908-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15518 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751546Ab0FCQvm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jun 2010 12:51:42 -0400
Received: from int-mx03.intmail.prod.int.phx2.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o53Gpfr6020943
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 3 Jun 2010 12:51:41 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx03.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o53GpecF024336
	for <linux-nfs@vger.kernel.org>; Thu, 3 Jun 2010 12:51:41 -0400
Received: from localhost.localdomain (fathat.boston.devel.redhat.com [10.16.60.125])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id o53GpcaE027759
	for <linux-nfs@vger.kernel.org>; Thu, 3 Jun 2010 12:51:40 -0400
In-Reply-To: <1275583898-17908-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

mount.nfs should display some type of error diagnostics when
the network protocol can not be determined.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/network.c |   30 +++++++++++++++++++++---------
 utils/mount/stropts.c |   16 +++++++++++-----
 2 files changed, 32 insertions(+), 14 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index b08ce80..7c28869 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1312,6 +1312,8 @@ nfs_nfs_protocol(struct mount_options *options, unsigned long *protocol)
 		if (option != NULL) {
 			if (!nfs_get_proto(option, &family, protocol)) {
 				errno = EPROTONOSUPPORT;
+				nfs_error(_("%s: Failed to find '%s' protocol"), 
+					progname, option);
 				return 0;
 			}
 			return 1;
@@ -1401,8 +1403,13 @@ int nfs_nfs_proto_family(struct mount_options *options,
 	case 2: /* proto */
 		option = po_get(options, "proto");
 		if (option != NULL &&
-		    !nfs_get_proto(option, &tmp_family, &protocol))
-			goto out_err;
+		    !nfs_get_proto(option, &tmp_family, &protocol)) {
+
+			nfs_error(_("%s: Failed to find '%s' protocol"), 
+				progname, option);
+			errno = EPROTONOSUPPORT;
+			return 0;
+		}
 	}
 
 	if (!nfs_verify_family(tmp_family))
@@ -1495,6 +1502,8 @@ nfs_mount_protocol(struct mount_options *options, unsigned long *protocol)
 	option = po_get(options, "mountproto");
 	if (option != NULL) {
 		if (!nfs_get_proto(option, &family, protocol)) {
+			nfs_error(_("%s: Failed to find '%s' protocol"), 
+				progname, option);
 			errno = EPROTONOSUPPORT;
 			return 0;
 		}
@@ -1556,10 +1565,16 @@ int nfs_mount_proto_family(struct mount_options *options,
 
 	option = po_get(options, "mountproto");
 	if (option != NULL) {
-		if (!nfs_get_proto(option, &tmp_family, &protocol))
-			goto out_err;
-		if (!nfs_verify_family(tmp_family))
-			goto out_err;
+		if (!nfs_get_proto(option, &tmp_family, &protocol)) {
+			nfs_error(_("%s: Failed to find '%s' protocol"), 
+				progname, option);
+			errno = EPROTONOSUPPORT;
+			return 0;
+		}
+		if (!nfs_verify_family(tmp_family)) {
+			errno = EAFNOSUPPORT;
+			return 0;
+		}
 		*family = tmp_family;
 		return 1;
 	}
@@ -1571,9 +1586,6 @@ int nfs_mount_proto_family(struct mount_options *options,
 	 * NFS.
 	 */
 	return nfs_nfs_proto_family(options, family);
-out_err:
-	errno = EAFNOSUPPORT;
-	return 0;
 }
 
 /**
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
1.6.5.2

