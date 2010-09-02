Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54491 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754150Ab0IBT7K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Sep 2010 15:59:10 -0400
Received: from int-mx03.intmail.prod.int.phx2.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o82Jx9pU017862
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 2 Sep 2010 15:59:10 -0400
Received: from fathat.boston.devel.redhat.com (fathat.boston.devel.redhat.com [10.16.60.125])
	by int-mx03.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o82Jx906022535
	for <linux-nfs@vger.kernel.org>; Thu, 2 Sep 2010 15:59:09 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] mount: RDMA processing in the mount command is broken
Date: Thu,  2 Sep 2010 16:00:51 -0400
Message-Id: <1283457651-12010-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The mounting code that process RMDA mounts is broken in a few places

First with '-o proto=rdma' was broken because nfs_get_proto()
did not how to convert a netid of 'rdma' in to a AF_INET
address family.

Secondly, '-o rdma' was broken because po_get() was being using
to detect the existence of 'rdma' in the options. With '-o rdma'
there is no value associated with that option so po_get()
was always return NULL.

This patch address both those problems.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/nfs/getport.c |    8 ++++++++
 utils/mount/stropts.c |   31 ++++++++++++++++++++++---------
 2 files changed, 30 insertions(+), 9 deletions(-)

diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index c930539..b4c2f8f 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -216,6 +216,10 @@ nfs_get_proto(const char *netid, sa_family_t *family, unsigned long *protocol)
 	struct netconfig *nconf;
 	struct protoent *proto;
 
+	if (strcasecmp(netid, "rdma") == 0) {
+		*family = AF_INET;
+		return 1;
+	}
 	nconf = getnetconfigent(netid);
 	if (nconf == NULL)
 		return 0;
@@ -242,6 +246,10 @@ nfs_get_proto(const char *netid, sa_family_t *family, unsigned long *protocol)
 {
 	struct protoent *proto;
 
+	if (strcasecmp(netid, "rdma") == 0) {
+		*family = AF_INET;
+		return 1;
+	}
 	proto = getprotobyname(netid);
 	if (proto == NULL)
 		return 0;
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 0241400..d688ee8 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -98,6 +98,22 @@ struct nfsmount_info {
 				child;		/* forked bg child? */
 };
 
+/*
+ * Check the options to see if the transport is RDMA
+ */
+static int rdma_enabled(struct mount_options *options)
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
+	else if (rdma_enabled(mi->options))
+		mi->version = 3;
 
 	/*
 	 * If we still don't know, check for version-specific
@@ -346,7 +359,9 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 	if (!nfs_parse_devname(mi->spec, &mi->hostname, NULL))
 		return 0;
 
-	if (!nfs_nfs_proto_family(mi->options, &family))
+	if (rdma_enabled(mi->options))
+		family = AF_INET;
+	else if (!nfs_nfs_proto_family(mi->options, &family))
 		return 0;
 
 	hint.ai_family = (int)family;
@@ -491,13 +506,11 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options)
 	struct sockaddr *mnt_saddr = &mnt_address.sa;
 	socklen_t mnt_salen = sizeof(mnt_address);
 	struct pmap mnt_pmap;
-	char *option;
 
 	/*
 	 * Skip option negotiation for proto=rdma mounts.
 	 */
-	option = po_get(options, "proto");
-	if (option && strcmp(option, "rdma") == 0)
+	if (rdma_enabled(options))
 		goto out;
 
 	/*
-- 
1.7.1

