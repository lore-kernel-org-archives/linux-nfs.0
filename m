Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33018 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751678AbdIMK1W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Sep 2017 06:27:22 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: NeilBrown <neilb@suse.com>, Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH nfs-utils v3 07/14] getport: recognize "vsock" netid
Date: Wed, 13 Sep 2017 11:26:43 +0100
Message-Id: <20170913102650.10377-8-stefanha@redhat.com>
In-Reply-To: <20170913102650.10377-1-stefanha@redhat.com>
References: <20170913102650.10377-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neither libtirpc nor getprotobyname(3) know about AF_VSOCK.  Translate
"vsock" manually in getport.c.

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
2.13.5

