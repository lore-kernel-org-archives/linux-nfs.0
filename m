Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39118 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752214AbcJGKFB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Oct 2016 06:05:01 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2309E1E20
        for <linux-nfs@vger.kernel.org>; Fri,  7 Oct 2016 10:04:31 +0000 (UTC)
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH 4/4] getport: recognize "vsock" netid
Date: Fri,  7 Oct 2016 11:01:43 +0100
Message-Id: <1475834503-3984-5-git-send-email-stefanha@redhat.com>
In-Reply-To: <1475834503-3984-1-git-send-email-stefanha@redhat.com>
References: <1475834503-3984-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neither libtirpc nor getprotobyname(3) know about AF_VSOCK.  For similar
reasons as for "rdma"/"rmda6", translate "vsock" manually in getport.c.

It is now possible to mount a file system from the host (hypervisor)
over AF_VSOCK like this:

  (guest)$ mount.nfs 2:/export /mnt -v -o clientaddr=3,proto=vsock

The VM's cid address is 3 and the hypervisor is 2.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 support/nfs/getport.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index 081594c..0b857af 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -217,8 +217,7 @@ nfs_get_proto(const char *netid, sa_family_t *family, unsigned long *protocol)
 	struct protoent *proto;
 
 	/*
-	 * IANA does not define a protocol number for rdma netids,
-	 * since "rdma" is not an IP protocol.
+	 * IANA does not define protocol numbers for non-IP netids.
 	 */
 	if (strcmp(netid, "rdma") == 0) {
 		*family = AF_INET;
@@ -230,6 +229,11 @@ nfs_get_proto(const char *netid, sa_family_t *family, unsigned long *protocol)
 		*protocol = NFSPROTO_RDMA;
 		return 1;
 	}
+	if (strcmp(netid, "vsock") == 0) {
+		*family = AF_VSOCK;
+		*protocol = 0;
+		return 1;
+	}
 
 	nconf = getnetconfigent(netid);
 	if (nconf == NULL)
@@ -258,14 +262,18 @@ nfs_get_proto(const char *netid, sa_family_t *family, unsigned long *protocol)
 	struct protoent *proto;
 
 	/*
-	 * IANA does not define a protocol number for rdma netids,
-	 * since "rdma" is not an IP protocol.
+	 * IANA does not define protocol numbers for non-IP netids.
 	 */
 	if (strcmp(netid, "rdma") == 0) {
 		*family = AF_INET;
 		*protocol = NFSPROTO_RDMA;
 		return 1;
 	}
+	if (strcmp(netid, "vsock") == 0) {
+		*family = AF_VSOCK;
+		*protocol = 0;
+		return 1;
+	}
 
 	proto = getprotobyname(netid);
 	if (proto == NULL)
-- 
2.7.4

