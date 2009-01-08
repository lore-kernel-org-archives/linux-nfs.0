From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/5] text-based mount command: Function to stuff "struct pmap"
	from mount options
Date: Thu, 08 Jan 2009 12:32:48 -0500
Message-ID: <20090108173247.19893.17040.stgit@ingres.1015granger.net>
References: <20090108172526.19893.91621.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:60416 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbZAHRd1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2009 12:33:27 -0500
In-Reply-To: <20090108172526.19893.91621.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both the text-based mount.nfs command and the umount.nfs command need
to fill in a pmap structure based on string mount options.  Introduce
a shared function that can do this.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |  214 +++++++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/network.h |    5 +
 2 files changed, 219 insertions(+), 0 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index d262e94..91a005c 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -48,6 +48,7 @@
 #include "nfs_mount.h"
 #include "mount_constants.h"
 #include "nfsrpc.h"
+#include "parse_opt.h"
 #include "network.h"
 
 #define PMAP_TIMEOUT	(10)
@@ -67,6 +68,33 @@ static const char *nfs_ns_pgmtbl[] = {
 	NULL,
 };
 
+static const char *nfs_mnt_pgmtbl[] = {
+	"mount",
+	"mountd",
+	NULL,
+};
+
+static const char *nfs_nfs_pgmtbl[] = {
+	"nfs",
+	"nfsprog",
+	NULL,
+};
+
+static const char *nfs_transport_opttbl[] = {
+	"udp",
+	"tcp",
+	"proto",
+	NULL,
+};
+
+static const char *nfs_version_opttbl[] = {
+	"v2",
+	"v3",
+	"vers",
+	"nfsvers",
+	NULL,
+};
+
 static const unsigned long nfs_to_mnt[] = {
 	0,
 	0,
@@ -1111,3 +1139,189 @@ out_failed:
 	return 0;
 
 }
+
+/*
+ * "nfsprog" is only supported by the legacy mount command.  The
+ * kernel mount client does not support this option.
+ *
+ * Returns the value set by the nfsprog= option, the value of
+ * the RPC NFS program specified in /etc/rpc, or a baked-in
+ * default program number, if all fails.
+ */
+static rpcprog_t nfs_nfs_program(struct mount_options *options)
+{
+	long tmp;
+
+	if (po_get_numeric(options, "nfsprog", &tmp) == PO_FOUND)
+		if (tmp >= 0)
+			return tmp;
+	return nfs_getrpcbyname(NFSPROG, nfs_nfs_pgmtbl);
+}
+
+
+/*
+ * Returns the RPC version number specified by the given mount
+ * options for the NFS service, or zero if all fails.
+ */
+static rpcvers_t nfs_nfs_version(struct mount_options *options)
+{
+	long tmp;
+
+	switch (po_rightmost(options, nfs_version_opttbl)) {
+	case 1:	/* v2 */
+		return 2;
+	case 2: /* v3 */
+		return 3;
+	case 3:	/* vers */
+		if (po_get_numeric(options, "vers", &tmp) == PO_FOUND)
+			if (tmp >= 2 && tmp <= 3)
+				return tmp;
+		break;
+	case 4: /* nfsvers */
+		if (po_get_numeric(options, "nfsvers", &tmp) == PO_FOUND)
+			if (tmp >= 2 && tmp <= 3)
+				return tmp;
+		break;
+	}
+
+	return 0;
+}
+
+/*
+ * Returns the NFS transport protocol specified by the given mount options
+ *
+ * Returns the IPPROTO_ value specified by the given mount options, or
+ * IPPROTO_UDP if all fails.
+ */
+static unsigned short nfs_nfs_protocol(struct mount_options *options)
+{
+	char *option;
+
+	switch (po_rightmost(options, nfs_transport_opttbl)) {
+	case 1:	/* udp */
+		return IPPROTO_UDP;
+	case 2: /* tcp */
+		return IPPROTO_TCP;
+	case 3: /* proto */
+		option = po_get(options, "proto");
+		if (option) {
+			if (strcmp(option, "tcp") == 0)
+				return IPPROTO_TCP;
+			if (strcmp(option, "udp") == 0)
+				return IPPROTO_UDP;
+		}
+	}
+	return IPPROTO_UDP;
+}
+
+/*
+ * Returns the NFS server's port number specified by the given
+ * mount options, or zero if all fails.  Zero results in a portmap
+ * query to discover the server's mountd service port.
+ *
+ * port=0 will guarantee an rpcbind request precedes the first
+ * NFS RPC so the client can determine the server's port number.
+ */
+static unsigned short nfs_nfs_port(struct mount_options *options)
+{
+	long tmp;
+
+	if (po_get_numeric(options, "port", &tmp) == PO_FOUND)
+		if (tmp >= 0 && tmp <= 65535)
+			return tmp;
+	return 0;
+}
+
+/*
+ * "mountprog" is only supported by the legacy mount command.  The
+ * kernel mount client does not support this option.
+ *
+ * Returns the value set by the mountprog= option, the value of
+ * the RPC mount program specified in /etc/rpc, or a baked-in
+ * default program number, if all fails.
+ */
+static rpcprog_t nfs_mount_program(struct mount_options *options)
+{
+	long tmp;
+
+	if (po_get_numeric(options, "mountprog", &tmp) == PO_FOUND)
+		if (tmp >= 0)
+			return tmp;
+	return nfs_getrpcbyname(MOUNTPROG, nfs_mnt_pgmtbl);
+}
+
+/*
+ * Returns the RPC version number specified by the given mount options,
+ * or the version "3" if all fails.
+ */
+static rpcvers_t nfs_mount_version(struct mount_options *options)
+{
+	long tmp;
+
+	if (po_get_numeric(options, "mountvers", &tmp) == PO_FOUND)
+		if (tmp >= 1 && tmp <= 4)
+			return tmp;
+
+	return nfsvers_to_mnt(nfs_nfs_version(options));
+}
+
+/*
+ * Returns the transport protocol to use for the mount service
+ *
+ * Returns the IPPROTO_ value specified by the mountproto option, or
+ * if that doesn't exist, the IPPROTO_ value specified for NFS
+ * itself.
+ */
+static unsigned short nfs_mount_protocol(struct mount_options *options)
+{
+	char *option;
+
+	option = po_get(options, "mountproto");
+	if (option) {
+		if (strcmp(option, "tcp") == 0)
+			return IPPROTO_TCP;
+		if (strcmp(option, "udp") == 0)
+			return IPPROTO_UDP;
+	}
+
+	return nfs_nfs_version(options);
+}
+
+/*
+ * Returns the mountd server's port number specified by the given
+ * mount options, or zero if all fails.  Zero results in a portmap
+ * query to discover the server's mountd service port.
+ *
+ * port=0 will guarantee an rpcbind request precedes the mount
+ * RPC so the client can determine the server's port number.
+ */
+static unsigned short nfs_mount_port(struct mount_options *options)
+{
+	long tmp;
+
+	if (po_get_numeric(options, "mountport", &tmp) == PO_FOUND)
+		if (tmp >= 0 && tmp <= 65535)
+			return tmp;
+	return 0;
+}
+
+/**
+ * nfs_options2pmap - set up pmap structs based on mount options
+ * @options: pointer to mount options
+ * @nfs_pmap: OUT: pointer to pmap arguments for NFS server
+ * @mnt_pmap: OUT: pointer to pmap arguments for mountd server
+ *
+ */
+void nfs_options2pmap(struct mount_options *options,
+		      struct pmap *nfs_pmap, struct pmap *mnt_pmap)
+{
+	nfs_pmap->pm_prog = nfs_nfs_program(options);
+	nfs_pmap->pm_vers = nfs_nfs_version(options);
+	nfs_pmap->pm_prot = nfs_nfs_protocol(options);
+	nfs_pmap->pm_port = nfs_nfs_port(options);
+
+	mnt_pmap->pm_prog = nfs_mount_program(options);
+	mnt_pmap->pm_vers = nfs_mount_version(options);
+	mnt_pmap->pm_prot = nfs_mount_protocol(options);
+	mnt_pmap->pm_port = nfs_mount_port(options);
+}
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 075093d..25060ab 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -57,6 +57,11 @@ int clnt_ping(struct sockaddr_in *, const unsigned long,
 		const unsigned long, const unsigned int,
 		struct sockaddr_in *);
 
+struct mount_options;
+
+void nfs_options2pmap(struct mount_options *,
+		      struct pmap *, struct pmap *);
+
 int start_statd(void);
 
 unsigned long nfsvers_to_mnt(const unsigned long);

