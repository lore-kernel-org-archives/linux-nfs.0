From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/10] mount.nfs: support netids in v2/v3 version/transport
	negotiation
Date: Tue, 08 Dec 2009 12:59:36 -0500
Message-ID: <20091208175936.2544.78807.stgit@localhost.localdomain>
References: <20091208175128.2544.457.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:40877 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965709AbZLHSAP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Dec 2009 13:00:15 -0500
In-Reply-To: <20091208175128.2544.457.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When rewriting mount options during v2/v3 negotiation, restore the
correct netids, rather than protocol names, in the rewritten protocol
options.  If TI-RPC is not available, the traditional behavior is
preserved.

This patch assumes the kernel can recognize a netid, instead of a
protocol name, as the value of the proto= options.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   51 +++++++++++++++++++++----------------------------
 1 files changed, 22 insertions(+), 29 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index a0b9e7f..40f8bd9 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -38,6 +38,7 @@
 #include "xcommon.h"
 #include "mount.h"
 #include "nls.h"
+#include "nfsrpc.h"
 #include "mount_constants.h"
 #include "stropts.h"
 #include "error.h"
@@ -371,10 +372,13 @@ static int nfs_extract_server_addresses(struct mount_options *options,
 }
 
 static int nfs_construct_new_options(struct mount_options *options,
+				     struct sockaddr *nfs_saddr,
 				     struct pmap *nfs_pmap,
+				     struct sockaddr *mnt_saddr,
 				     struct pmap *mnt_pmap)
 {
 	char new_option[64];
+	char *netid;
 
 	po_remove_all(options, "nfsprog");
 	po_remove_all(options, "mountprog");
@@ -391,20 +395,14 @@ static int nfs_construct_new_options(struct mount_options *options,
 	po_remove_all(options, "proto");
 	po_remove_all(options, "udp");
 	po_remove_all(options, "tcp");
-	switch (nfs_pmap->pm_prot) {
-	case IPPROTO_TCP:
-		snprintf(new_option, sizeof(new_option) - 1,
-			 "proto=tcp");
-		if (po_append(options, new_option) == PO_FAILED)
-			return 0;
-		break;
-	case IPPROTO_UDP:
-		snprintf(new_option, sizeof(new_option) - 1,
-			 "proto=udp");
-		if (po_append(options, new_option) == PO_FAILED)
-			return 0;
-		break;
-	}
+	netid = nfs_get_netid(nfs_saddr->sa_family, nfs_pmap->pm_prot);
+	if (netid == NULL)
+		return 0;
+	snprintf(new_option, sizeof(new_option) - 1,
+			 "proto=%s", netid);
+	free(netid);
+	if (po_append(options, new_option) == PO_FAILED)
+		return 0;
 
 	po_remove_all(options, "port");
 	if (nfs_pmap->pm_port != NFS_PORT) {
@@ -421,20 +419,14 @@ static int nfs_construct_new_options(struct mount_options *options,
 		return 0;
 
 	po_remove_all(options, "mountproto");
-	switch (mnt_pmap->pm_prot) {
-	case IPPROTO_TCP:
-		snprintf(new_option, sizeof(new_option) - 1,
-			 "mountproto=tcp");
-		if (po_append(options, new_option) == PO_FAILED)
-			return 0;
-		break;
-	case IPPROTO_UDP:
-		snprintf(new_option, sizeof(new_option) - 1,
-			 "mountproto=udp");
-		if (po_append(options, new_option) == PO_FAILED)
-			return 0;
-		break;
-	}
+	netid = nfs_get_netid(mnt_saddr->sa_family, mnt_pmap->pm_prot);
+	if (netid == NULL)
+		return 0;
+	snprintf(new_option, sizeof(new_option) - 1,
+			 "mountproto=%s", netid);
+	free(netid);
+	if (po_append(options, new_option) == PO_FAILED)
+		return 0;
 
 	po_remove_all(options, "mountport");
 	snprintf(new_option, sizeof(new_option) - 1,
@@ -510,7 +502,8 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options)
 		return 0;
 	}
 
-	if (!nfs_construct_new_options(options, &nfs_pmap, &mnt_pmap)) {
+	if (!nfs_construct_new_options(options, nfs_saddr, &nfs_pmap,
+					mnt_saddr, &mnt_pmap)) {
 		errno = EINVAL;
 		return 0;
 	}

