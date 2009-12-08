From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/10] mount.nfs: Add new API for getting protocol family from
	netids
Date: Tue, 08 Dec 2009 13:00:06 -0500
Message-ID: <20091208180005.2544.45171.stgit@localhost.localdomain>
References: <20091208175128.2544.457.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:62465 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965722AbZLHSAe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Dec 2009 13:00:34 -0500
In-Reply-To: <20091208175128.2544.457.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce a couple of new functions that extract the protocol family
from the value of the proto= and mountproto= mount options.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   63 +++++++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/network.h |    2 ++
 2 files changed, 65 insertions(+), 0 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 7d9accd..d598fcf 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1354,6 +1354,40 @@ nfs_nfs_port(struct mount_options *options, unsigned long *port)
 }
 
 /*
+ * Returns TRUE and fills in @family if a valid NFS protocol option
+ * is found, or FALSE if the option was specified with an invalid value.
+ */
+int nfs_nfs_proto_family(struct mount_options *options,
+				sa_family_t *family)
+{
+	unsigned long protocol;
+	char *option;
+
+#ifdef HAVE_LIBTIRPC
+	*family = AF_UNSPEC;
+#else
+	*family = AF_INET;
+#endif
+
+	switch (po_rightmost(options, nfs_transport_opttbl)) {
+	case 0:	/* udp */
+		return 1;
+	case 1: /* tcp */
+		return 1;
+	case 2: /* proto */
+		option = po_get(options, "proto");
+		if (option != NULL)
+			return nfs_get_proto(option, family, &protocol);
+	}
+
+	/*
+	 * NFS transport protocol wasn't specified.  Return the
+	 * default address family.
+	 */
+	return 1;
+}
+
+/*
  * "mountprog" is supported only by the legacy mount command.  The
  * kernel mount client does not support this option.
  *
@@ -1466,6 +1500,35 @@ nfs_mount_port(struct mount_options *options, unsigned long *port)
 	return 1;
 }
 
+/*
+ * Returns TRUE and fills in @family if a valid MNT protocol option
+ * is found, or FALSE if the option was specified with an invalid value.
+ */
+int nfs_mount_proto_family(struct mount_options *options,
+				sa_family_t *family)
+{
+	unsigned long protocol;
+	char *option;
+
+#ifdef HAVE_LIBTIRPC
+	*family = AF_UNSPEC;
+#else
+	*family = AF_INET;
+#endif
+
+	option = po_get(options, "mountproto");
+	if (option != NULL)
+		return nfs_get_proto(option, family, &protocol);
+
+	/*
+	 * MNT transport protocol wasn't specified.  If the NFS
+	 * transport protocol was specified, derive the family
+	 * from that; otherwise, return the default family for
+	 * NFS.
+	 */
+	return nfs_nfs_proto_family(options, family);
+}
+
 /**
  * nfs_options2pmap - set up pmap structs based on mount options
  * @options: pointer to mount options
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 2cdf02e..da095e3 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -58,6 +58,8 @@ int clnt_ping(struct sockaddr_in *, const unsigned long,
 
 struct mount_options;
 
+int nfs_nfs_proto_family(struct mount_options *options, sa_family_t *family);
+int nfs_mount_proto_family(struct mount_options *options, sa_family_t *family);
 int nfs_nfs_version(struct mount_options *options, unsigned long *version);
 int  nfs_nfs_protocol(struct mount_options *options, unsigned long *protocol);
 

