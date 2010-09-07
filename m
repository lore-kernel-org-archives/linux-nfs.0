Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45800 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757890Ab0IGUWa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 16:22:30 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o87KMTEu022679
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 7 Sep 2010 16:22:29 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o87KMSnm001714
	for <linux-nfs@vger.kernel.org>; Tue, 7 Sep 2010 16:22:29 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/3] Ensure the corrrect address family is used on RDMA mounts
Date: Tue,  7 Sep 2010 16:22:00 -0400
Message-Id: <1283890921-3447-3-git-send-email-steved@redhat.com>
In-Reply-To: <1283890921-3447-1-git-send-email-steved@redhat.com>
References: <1283890921-3447-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Due to the lack of RDMA netid support and no IANA protocol
number defined just make sure the correct address
family is used on RDMA mounts.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/nfs/getport.c |   21 +++++++++++++++++++++
 utils/mount/stropts.c |    4 +++-
 2 files changed, 24 insertions(+), 1 deletions(-)

diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index c930539..8f788d2 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -216,6 +216,17 @@ nfs_get_proto(const char *netid, sa_family_t *family, unsigned long *protocol)
 	struct netconfig *nconf;
 	struct protoent *proto;
 
+	/*
+	 * Special Case for RDMA mounts. Since
+	 * there is no RDMA netid support, just
+	 * ensure the correct address family 
+	 * is used.
+	 */
+	if (strcasecmp(netid, "rdma") == 0) {
+		*family = AF_INET;
+		return 1;
+	}
+
 	nconf = getnetconfigent(netid);
 	if (nconf == NULL)
 		return 0;
@@ -242,6 +253,16 @@ nfs_get_proto(const char *netid, sa_family_t *family, unsigned long *protocol)
 {
 	struct protoent *proto;
 
+	/*
+	 * Special Case for RDMA mounts. Since
+	 * there is not a protocol number define 
+	 * for  RDMA, just ensure the correct 
+	 * address family is used.
+	 */
+	if (strcasecmp(netid, "rdma") == 0) {
+		*family = AF_INET;
+		return 1;
+	}
 	proto = getprotobyname(netid);
 	if (proto == NULL)
 		return 0;
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index eb6ecc5..3f53ade 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -359,7 +359,9 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 	if (!nfs_parse_devname(mi->spec, &mi->hostname, NULL))
 		return 0;
 
-	if (!nfs_nfs_proto_family(mi->options, &family))
+	if (nfs_rdma_option(mi->options))
+		family = AF_INET;
+	else if (!nfs_nfs_proto_family(mi->options, &family))
 		return 0;
 
 	hint.ai_family = (int)family;
-- 
1.7.2.1

