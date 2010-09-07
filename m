Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41576 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758258Ab0IGUW3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 16:22:29 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o87KMTBJ016447
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 7 Sep 2010 16:22:29 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o87KMSnl001714
	for <linux-nfs@vger.kernel.org>; Tue, 7 Sep 2010 16:22:29 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/3] Added support for the the -o rdma option
Date: Tue,  7 Sep 2010 16:21:59 -0400
Message-Id: <1283890921-3447-2-git-send-email-steved@redhat.com>
In-Reply-To: <1283890921-3447-1-git-send-email-steved@redhat.com>
References: <1283890921-3447-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Network transports can be specified with both
the proto= and -o options. The patch adds support
for the -o rdma option.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/stropts.c |   29 ++++++++++++++++++++---------
 1 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 0241400..eb6ecc5 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -98,6 +98,22 @@ struct nfsmount_info {
 				child;		/* forked bg child? */
 };
 
+/*
+ * Check the options to see if the transport is RDMA
+ */
+static int nfs_rdma_option(struct mount_options *options)
+{
+	char *option;
+
+	if (po_contains(options, "rdma"))
+		return 1;
+	option = po_get(options, "proto");
+	if (option && strcmp(option, "rdma") == 0)
+		return 1;
+
+	return 0;
+}
+
 #ifdef MOUNT_CONFIG
 static void nfs_default_version(struct nfsmount_info *mi);
 
@@ -302,11 +318,8 @@ static int nfs_set_version(struct nfsmount_info *mi)
 
 	if (strncmp(mi->type, "nfs4", 4) == 0)
 		mi->version = 4;
-	else {
-		char *option = po_get(mi->options, "proto");
-		if (option && strcmp(option, "rdma") == 0)
-			mi->version = 3;
-	}
+	else if (mi->version == 0 && nfs_rdma_option(mi->options))
+		mi->version = 3; /* The default for RDMA mounts */
 
 	/*
 	 * If we still don't know, check for version-specific
@@ -491,13 +504,11 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options)
 	struct sockaddr *mnt_saddr = &mnt_address.sa;
 	socklen_t mnt_salen = sizeof(mnt_address);
 	struct pmap mnt_pmap;
-	char *option;
 
 	/*
-	 * Skip option negotiation for proto=rdma mounts.
+	 * Skip option negotiation for RDMA mounts.
 	 */
-	option = po_get(options, "proto");
-	if (option && strcmp(option, "rdma") == 0)
+	if (nfs_rdma_option(options))
 		goto out;
 
 	/*
-- 
1.7.2.1

