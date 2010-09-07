Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:55971 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757808Ab0IGQ0d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 12:26:33 -0400
Received: by pxi10 with SMTP id 10so1392489pxi.19
        for <linux-nfs@vger.kernel.org>; Tue, 07 Sep 2010 09:26:33 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] mount.nfs: Support an "rdma" mount option
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 07 Sep 2010 12:26:27 -0400
Message-ID: <20100907162627.3392.73250.stgit@seurat.1015granger.net>
In-Reply-To: <20100907162156.3392.90376.stgit@seurat.1015granger.net>
References: <20100907162156.3392.90376.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The kernel NFS client's mount option parser recognizes a stand-alone
"rdma" mount option, similar to the legacy "udp" and "tcp" options.

The mount.nfs command text-based mount option parser used to pass
"rdma" straight to the kernel, but since we've started handling MNT in
the kernel instead of in user space, "rdma" on the command line has
not worked.

Until now, no-one has noticed, especially since an "rdma" mount option
isn't documented in nfs(5).

Support "rdma" in mount.nfs command, and document it in nfs(5).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |    9 +++++++--
 utils/mount/nfs.man   |   11 ++++++++++-
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index d6b5205..d612427 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -83,6 +83,7 @@ static const char *nfs_nfs_pgmtbl[] = {
 static const char *nfs_transport_opttbl[] = {
 	"udp",
 	"tcp",
+	"rdma",
 	"proto",
 	NULL,
 };
@@ -1307,7 +1308,10 @@ nfs_nfs_protocol(struct mount_options *options, unsigned long *protocol)
 	case 1: /* tcp */
 		*protocol = IPPROTO_TCP;
 		return 1;
-	case 2: /* proto */
+	case 2: /* rdma */
+		*protocol = NFSPROTO_RDMA;
+		return 1;
+	case 3: /* proto */
 		option = po_get(options, "proto");
 		if (option != NULL) {
 			if (!nfs_get_proto(option, &family, protocol)) {
@@ -1396,10 +1400,11 @@ int nfs_nfs_proto_family(struct mount_options *options,
 	switch (po_rightmost(options, nfs_transport_opttbl)) {
 	case 0:	/* udp */
 	case 1: /* tcp */
+	case 2: /* rdma */
 		/* for compatibility; these are always AF_INET */
 		*family = AF_INET;
 		return 1;
-	case 2: /* proto */
+	case 3: /* proto */
 		option = po_get(options, "proto");
 		if (option != NULL &&
 		    !nfs_get_proto(option, &tmp_family, &protocol)) {
diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 3806635..10ac961 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -495,7 +495,10 @@ command,
 .I netid
 is a valid netid listed in
 .IR /etc/netconfig .
-Otherwise,
+The value "rdma" may also be specified.
+If the
+.B mount.nfs
+command does not have TI-RPC support, then
 .I netid
 is one of "tcp," "udp," or "rdma," and only IPv4 may be used.
 .IP
@@ -537,6 +540,12 @@ option is an alternative to specifying
 .BR proto=tcp.
 It is included for compatibility with other operating systems.
 .TP 1.5i
+.B rdma
+The
+.B rdma
+option is an alternative to specifying
+.BR proto=rdma.
+.TP 1.5i
 .BI port= n
 The numeric value of the server's NFS service port.
 If the server's NFS service is not available on the specified port,

