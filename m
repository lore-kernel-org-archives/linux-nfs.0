From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/10] mount.nfs: support netids in nfs_options2pmap()
Date: Tue, 08 Dec 2009 12:59:27 -0500
Message-ID: <20091208175927.2544.16520.stgit@localhost.localdomain>
References: <20091208175128.2544.457.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:62940 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965750AbZLHSAw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Dec 2009 13:00:52 -0500
In-Reply-To: <20091208175128.2544.457.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When parsing mount options in nfs_options2pmap(), treat the value of
proto= (and mountproto=) as a netid by looking it up in local
netconfig and protocol databases to convert it to a protocol number.
If TI-RPC is not available, the traditional behavior is preserved.

The meaning of the "udp" and "tcp" mount options is not affected by
this change.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   28 ++++++----------------------
 1 files changed, 6 insertions(+), 22 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 7b1152a..ecb5acc 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1289,6 +1289,7 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
 int
 nfs_nfs_protocol(struct mount_options *options, unsigned long *protocol)
 {
+	sa_family_t family;
 	char *option;
 
 	switch (po_rightmost(options, nfs_transport_opttbl)) {
@@ -1300,17 +1301,8 @@ nfs_nfs_protocol(struct mount_options *options, unsigned long *protocol)
 		return 1;
 	case 2: /* proto */
 		option = po_get(options, "proto");
-		if (option) {
-			if (strcmp(option, "tcp") == 0) {
-				*protocol = IPPROTO_TCP;
-				return 1;
-			}
-			if (strcmp(option, "udp") == 0) {
-				*protocol = IPPROTO_UDP;
-				return 1;
-			}
-			return 0;
-		}
+		if (option != NULL)
+			return nfs_get_proto(option, &family, protocol);
 	}
 
 	/*
@@ -1419,20 +1411,12 @@ nfs_mount_version(struct mount_options *options, unsigned long *version)
 static int
 nfs_mount_protocol(struct mount_options *options, unsigned long *protocol)
 {
+	sa_family_t family;
 	char *option;
 
 	option = po_get(options, "mountproto");
-	if (option) {
-		if (strcmp(option, "tcp") == 0) {
-			*protocol = IPPROTO_TCP;
-			return 1;
-		}
-		if (strcmp(option, "udp") == 0) {
-			*protocol = IPPROTO_UDP;
-			return 1;
-		}
-		return 0;
-	}
+	if (option != NULL)
+		return nfs_get_proto(option, &family, protocol);
 
 	/*
 	 * MNT transport protocol wasn't specified.  If the NFS

