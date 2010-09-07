Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:44614 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757791Ab0IGQ0M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 12:26:12 -0400
Received: by gwj17 with SMTP id 17so1954393gwj.19
        for <linux-nfs@vger.kernel.org>; Tue, 07 Sep 2010 09:26:11 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/4] getport: Recognize "rdma" and "rdma6" netid
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 07 Sep 2010 12:26:07 -0400
Message-ID: <20100907162607.3392.72787.stgit@seurat.1015granger.net>
In-Reply-To: <20100907162156.3392.90376.stgit@seurat.1015granger.net>
References: <20100907162156.3392.90376.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The mount.nfs command must recognize the values of "rdma" and "rdma6"
with the "proto=" mount option.  Typically the mount.nfs command
relies on libtirpc or getprotobyname(3) to recognize netids and
translate them to protocol numbers.

RFCs 5665 and 5666 define the "rdma" and "rdma6" netids.  IANA defines
a specific port number for NFS over RDMA (20049), but has not provided
a protocol name and number for RDMA transports, and is not expected
to.  The best we can do is translate these by hand, as needed, to get
RDMA mount requests to the kernel without erroring out.

Only the forward translation is needed until such time that "rdma" and
"rdma6" start to appear in rpcbind registries.  For now, the version
and transport negotiation logic is skipped, avoiding rpcbind queries
for RDMA mounts.

Note: As of kernel 2.6.36, the kernel's NFS over RDMA transport
capability does not support IPv6.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/nfsrpc.h |    6 ++++++
 support/nfs/getport.c    |   25 +++++++++++++++++++++++++
 2 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/support/include/nfsrpc.h b/support/include/nfsrpc.h
index 6ebefca..d50fe94 100644
--- a/support/include/nfsrpc.h
+++ b/support/include/nfsrpc.h
@@ -27,6 +27,12 @@
 #include <rpc/clnt.h>
 
 /*
+ * IANA does not define an IP protocol number for RDMA transports.
+ * Choose an arbitrary value we can use locally.
+ */
+#define NFSPROTO_RDMA		(3939)
+
+/*
  * Conventional RPC program numbers
  */
 #ifndef RPCBPROG
diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index c930539..d74400b 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -216,6 +216,21 @@ nfs_get_proto(const char *netid, sa_family_t *family, unsigned long *protocol)
 	struct netconfig *nconf;
 	struct protoent *proto;
 
+	/*
+	 * IANA does not define a protocol number for rdma netids,
+	 * since "rdma" is not an IP protocol.
+	 */
+	if (strcmp(netid, "rdma") == 0) {
+		*family = AF_INET;
+		*protocol = NFSPROTO_RDMA;
+		return 1;
+	}
+	if (strcmp(netid, "rdma6") == 0) {
+		*family = AF_INET6;
+		*protocol = NFSPROTO_RDMA;
+		return 1;
+	}
+
 	nconf = getnetconfigent(netid);
 	if (nconf == NULL)
 		return 0;
@@ -242,6 +257,16 @@ nfs_get_proto(const char *netid, sa_family_t *family, unsigned long *protocol)
 {
 	struct protoent *proto;
 
+	/*
+	 * IANA does not define a protocol number for rdma netids,
+	 * since "rdma" is not an IP protocol.
+	 */
+	if (strcmp(netid, "rdma") == 0) {
+		*family = AF_INET;
+		*protocol = NFSPROTO_RDMA;
+		return 1;
+	}
+
 	proto = getprotobyname(netid);
 	if (proto == NULL)
 		return 0;

