From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/31] mount.nfs: force rpcbind queries if options aren't
	specified
Date: Mon, 29 Jun 2009 13:37:19 -0400
Message-ID: <20090629173718.2076.33138.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:36396 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752761AbZF2Rht (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:37:49 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_options2pmap() fills in default values if the passed-in mount
options don't specify values.  This short-circuits the version, port,
and transport negotiation logic in nfs_probe_bothports().

Instead, nfs_options2pmap() should plant zeros in these pmap fields
to force nfs_probe_bothports() and nfs_advise_mount() to discover, via
rpcbind queries, what the server supports.

This fixes some scenarios where umount.nfs fails to connect to servers
that don't have all rpcbind ports open, in addition to fixing other
corner cases during mount.nfs version/protocol negotiation.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 73d64a2..1e05263 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1230,13 +1230,16 @@ static rpcvers_t nfs_nfs_version(struct mount_options *options)
  * Returns the NFS transport protocol specified by the given mount options
  *
  * Returns the IPPROTO_ value specified by the given mount options, or
- * IPPROTO_UDP if all fails.
+ * zero if all fails.  The protocol value will be filled in by an
+ * rpcbind query in this case.
  */
 static unsigned short nfs_nfs_protocol(struct mount_options *options)
 {
 	char *option;
 
 	switch (po_rightmost(options, nfs_transport_opttbl)) {
+	case 0:	/* udp */
+		return IPPROTO_UDP;
 	case 1: /* tcp */
 		return IPPROTO_TCP;
 	case 2: /* proto */
@@ -1249,7 +1252,7 @@ static unsigned short nfs_nfs_protocol(struct mount_options *options)
 		}
 	}
 
-	return IPPROTO_UDP;
+	return 0;
 }
 
 /*
@@ -1290,7 +1293,8 @@ static rpcprog_t nfs_mount_program(struct mount_options *options)
 
 /*
  * Returns the RPC version number specified by the given mount options,
- * or the version "3" if all fails.
+ * or zero if all fails.  The version value will be filled in by an
+ * rpcbind query in this case.
  */
 static rpcvers_t nfs_mount_version(struct mount_options *options)
 {
@@ -1300,15 +1304,15 @@ static rpcvers_t nfs_mount_version(struct mount_options *options)
 		if (tmp >= 1 && tmp <= 4)
 			return tmp;
 
-	return nfsvers_to_mnt(nfs_nfs_version(options));
+	return 0;
 }
 
 /*
  * Returns the transport protocol to use for the mount service
  *
  * Returns the IPPROTO_ value specified by the mountproto option, or
- * if that doesn't exist, the IPPROTO_ value specified for NFS
- * itself.
+ * copies the NFS protocol setting.  If the protocol value is zero,
+ * the value will be filled in by an rpcbind query.
  */
 static unsigned short nfs_mount_protocol(struct mount_options *options)
 {
@@ -1330,7 +1334,7 @@ static unsigned short nfs_mount_protocol(struct mount_options *options)
  * mount options, or zero if all fails.  Zero results in a portmap
  * query to discover the server's mountd service port.
  *
- * port=0 will guarantee an rpcbind request precedes the mount
+ * mountport=0 will guarantee an rpcbind request precedes the mount
  * RPC so the client can determine the server's port number.
  */
 static unsigned short nfs_mount_port(struct mount_options *options)

