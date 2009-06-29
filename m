From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 17/31] mount.nfs: make nfs_options2pmap return errors
Date: Mon, 29 Jun 2009 13:37:28 -0400
Message-ID: <20090629173728.2076.21581.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:36604 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752569AbZF2Rh7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:37:59 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Up until now, nfs_options2pmap() has been passed mount options that
have already gone through the kernel's parser successfully.  So, it
never had to check for invalid mount option values.

However, we are about to pass it options that come right from the
user.  So nfs_options2pmap() will now need to report an error and
fail if it encounters a bogus value for any of the options it cares
about.

 =====

Note that nfs_options2pmap() will allow a bogus value for an option
if the same option is specified farther to the right with a useable
value.

For example, if a user specifies "proto=foo,...,tcp" then
nfs_options2pmap() uses "tcp" and ignores "proto=foo".

However, if the options are specified in the other order:
"tcp,...,proto=foo" then nfs_options2pmap() will fail.  This is a simple
and unambiguous extension of the "rightmost wins" rule.

Since mount.nfs strips out these options out and replaces them with
the rpcbind-negotiated options before invoking mount(2), the kernel
should never receive bogus values for these options from mount.nfs in
such cases.

This is probably slightly more flexible behavior than the legacy
mount implementation, but should be harmless.  All mount options
unrelated to pmap are ignored by nfs_options2pmap().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c   |  317 ++++++++++++++++++++++++++++++++---------------
 utils/mount/network.h   |    2 
 utils/mount/nfsumount.c |    5 +
 utils/mount/stropts.c   |    5 +
 4 files changed, 227 insertions(+), 102 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 1e05263..5b6f4c2 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1176,175 +1176,282 @@ out_failed:
 	if (verbose)
 		nfs_error(_("%s: failed to construct callback address"));
 	return 0;
-
 }
 
 /*
- * "nfsprog" is only supported by the legacy mount command.  The
+ * "nfsprog" is supported only by the legacy mount command.  The
  * kernel mount client does not support this option.
  *
- * Returns the value set by the nfsprog= option, the value of
- * the RPC NFS program specified in /etc/rpc, or a baked-in
- * default program number, if all fails.
+ * Returns TRUE if @program contains a valid value for this option,
+ * or FALSE if the option was specified with an invalid value.
  */
-static rpcprog_t nfs_nfs_program(struct mount_options *options)
+static int
+nfs_nfs_program(struct mount_options *options, unsigned long *program)
 {
 	long tmp;
 
-	if (po_get_numeric(options, "nfsprog", &tmp) == PO_FOUND)
-		if (tmp >= 0)
-			return tmp;
-	return nfs_getrpcbyname(NFSPROG, nfs_nfs_pgmtbl);
-}
+	switch (po_get_numeric(options, "nfsprog", &tmp)) {
+	case PO_NOT_FOUND:
+		break;
+	case PO_FOUND:
+		if (tmp > 0) {
+			*program = tmp;
+			return 1;
+		}
+	case PO_BAD_VALUE:
+		return 0;
+	}
 
+	/*
+	 * NFS RPC program wasn't specified.  The RPC program
+	 * cannot be determined via an rpcbind query.
+	 */
+	*program = nfs_getrpcbyname(NFSPROG, nfs_nfs_pgmtbl);
+	return 1;
+}
 
 /*
- * Returns the RPC version number specified by the given mount
- * options for the NFS service, or zero if all fails.
+ * Returns TRUE if @version contains a valid value for this option,
+ * or FALSE if the option was specified with an invalid value.
  */
-static rpcvers_t nfs_nfs_version(struct mount_options *options)
+static int
+nfs_nfs_version(struct mount_options *options, unsigned long *version)
 {
 	long tmp;
 
 	switch (po_rightmost(options, nfs_version_opttbl)) {
 	case 0:	/* v2 */
-		return 2;
+		*version = 2;
+		return 1;
 	case 1: /* v3 */
-		return 3;
+		*version = 3;
+		return 1;
 	case 2:	/* vers */
-		if (po_get_numeric(options, "vers", &tmp) == PO_FOUND)
-			if (tmp >= 2 && tmp <= 3)
-				return tmp;
-		break;
+		switch (po_get_numeric(options, "vers", &tmp)) {
+		case PO_FOUND:
+			if (tmp >= 2 && tmp <= 3) {
+				*version = tmp;
+				return 1;
+			}
+			return 0;
+		case PO_NOT_FOUND:
+			nfs_error(_("%s: option parsing error\n"),
+					progname);
+		case PO_BAD_VALUE:
+			return 0;
+		}
 	case 3: /* nfsvers */
-		if (po_get_numeric(options, "nfsvers", &tmp) == PO_FOUND)
-			if (tmp >= 2 && tmp <= 3)
-				return tmp;
-		break;
+		switch (po_get_numeric(options, "nfsvers", &tmp)) {
+		case PO_FOUND:
+			if (tmp >= 2 && tmp <= 3) {
+				*version = tmp;
+				return 1;
+			}
+			return 0;
+		case PO_NOT_FOUND:
+			nfs_error(_("%s: option parsing error\n"),
+					progname);
+		case PO_BAD_VALUE:
+			return 0;
+		}
 	}
 
-	return 0;
+	/*
+	 * NFS version wasn't specified.  The pmap version value
+	 * will be filled in later by an rpcbind query in this case.
+	 */
+	*version = 0;
+	return 1;
 }
 
 /*
- * Returns the NFS transport protocol specified by the given mount options
- *
- * Returns the IPPROTO_ value specified by the given mount options, or
- * zero if all fails.  The protocol value will be filled in by an
- * rpcbind query in this case.
+ * Returns TRUE if @protocol contains a valid value for this option,
+ * or FALSE if the option was specified with an invalid value.
  */
-static unsigned short nfs_nfs_protocol(struct mount_options *options)
+static int
+nfs_nfs_protocol(struct mount_options *options, unsigned long *protocol)
 {
 	char *option;
 
 	switch (po_rightmost(options, nfs_transport_opttbl)) {
 	case 0:	/* udp */
-		return IPPROTO_UDP;
+		*protocol = IPPROTO_UDP;
+		return 1;
 	case 1: /* tcp */
-		return IPPROTO_TCP;
+		*protocol = IPPROTO_TCP;
+		return 1;
 	case 2: /* proto */
 		option = po_get(options, "proto");
 		if (option) {
-			if (strcmp(option, "tcp") == 0)
-				return IPPROTO_TCP;
-			if (strcmp(option, "udp") == 0)
-				return IPPROTO_UDP;
+			if (strcmp(option, "tcp") == 0) {
+				*protocol = IPPROTO_TCP;
+				return 1;
+			}
+			if (strcmp(option, "udp") == 0) {
+				*protocol = IPPROTO_UDP;
+				return 1;
+			}
+			return 0;
 		}
 	}
 
-	return 0;
+	/*
+	 * NFS transport protocol wasn't specified.  The pmap
+	 * protocol value will be filled in later by an rpcbind
+	 * query in this case.
+	 */
+	*protocol = 0;
+	return 1;
 }
 
 /*
- * Returns the NFS server's port number specified by the given
- * mount options, or zero if all fails.  Zero results in a portmap
- * query to discover the server's mountd service port.
- *
- * port=0 will guarantee an rpcbind request precedes the first
- * NFS RPC so the client can determine the server's port number.
+ * Returns TRUE if @port contains a valid value for this option,
+ * or FALSE if the option was specified with an invalid value.
  */
-static unsigned short nfs_nfs_port(struct mount_options *options)
+static int
+nfs_nfs_port(struct mount_options *options, unsigned long *port)
 {
 	long tmp;
 
-	if (po_get_numeric(options, "port", &tmp) == PO_FOUND)
-		if (tmp >= 0 && tmp <= 65535)
-			return tmp;
-	return 0;
+	switch (po_get_numeric(options, "port", &tmp)) {
+	case PO_NOT_FOUND:
+		break;
+	case PO_FOUND:
+		if (tmp >= 1 && tmp <= 65535) {
+			*port = tmp;
+			return 1;
+		}
+	case PO_BAD_VALUE:
+		return 0;
+	}
+
+	/*
+	 * NFS service port wasn't specified.  The pmap port value
+	 * will be filled in later by an rpcbind query in this case.
+	 */
+	*port = 0;
+	return 1;
 }
 
 /*
- * "mountprog" is only supported by the legacy mount command.  The
+ * "mountprog" is supported only by the legacy mount command.  The
  * kernel mount client does not support this option.
  *
- * Returns the value set by the mountprog= option, the value of
- * the RPC mount program specified in /etc/rpc, or a baked-in
- * default program number, if all fails.
+ * Returns TRUE if @program contains a valid value for this option,
+ * or FALSE if the option was specified with an invalid value.
  */
-static rpcprog_t nfs_mount_program(struct mount_options *options)
+static int
+nfs_mount_program(struct mount_options *options, unsigned long *program)
 {
 	long tmp;
 
-	if (po_get_numeric(options, "mountprog", &tmp) == PO_FOUND)
-		if (tmp >= 0)
-			return tmp;
-	return nfs_getrpcbyname(MOUNTPROG, nfs_mnt_pgmtbl);
+	switch (po_get_numeric(options, "mountprog", &tmp)) {
+	case PO_NOT_FOUND:
+		break;
+	case PO_FOUND:
+		if (tmp > 0) {
+			*program = tmp;
+			return 1;
+		}
+	case PO_BAD_VALUE:
+		return 0;
+	}
+
+	/*
+	 * MNT RPC program wasn't specified.  The RPC program
+	 * cannot be determined via an rpcbind query.
+	 */
+	*program = nfs_getrpcbyname(MOUNTPROG, nfs_mnt_pgmtbl);
+	return 1;
 }
 
 /*
- * Returns the RPC version number specified by the given mount options,
- * or zero if all fails.  The version value will be filled in by an
- * rpcbind query in this case.
+ * Returns TRUE if @version contains a valid value for this option,
+ * or FALSE if the option was specified with an invalid value.
  */
-static rpcvers_t nfs_mount_version(struct mount_options *options)
+static int
+nfs_mount_version(struct mount_options *options, unsigned long *version)
 {
 	long tmp;
 
-	if (po_get_numeric(options, "mountvers", &tmp) == PO_FOUND)
-		if (tmp >= 1 && tmp <= 4)
-			return tmp;
+	switch (po_get_numeric(options, "mountvers", &tmp)) {
+	case PO_NOT_FOUND:
+		break;
+	case PO_FOUND:
+		if (tmp >= 1 && tmp <= 4) {
+			*version = tmp;
+			return 1;
+		}
+	case PO_BAD_VALUE:
+		return 0;
+	}
 
-	return 0;
+	/*
+	 * MNT version wasn't specified.  The pmap version value
+	 * will be filled in later by an rpcbind query in this case.
+	 */
+	*version = 0;
+	return 1;
 }
 
 /*
- * Returns the transport protocol to use for the mount service
- *
- * Returns the IPPROTO_ value specified by the mountproto option, or
- * copies the NFS protocol setting.  If the protocol value is zero,
- * the value will be filled in by an rpcbind query.
+ * Returns TRUE if @protocol contains a valid value for this option,
+ * or FALSE if the option was specified with an invalid value.
  */
-static unsigned short nfs_mount_protocol(struct mount_options *options)
+static int
+nfs_mount_protocol(struct mount_options *options, unsigned long *protocol)
 {
 	char *option;
 
 	option = po_get(options, "mountproto");
 	if (option) {
-		if (strcmp(option, "tcp") == 0)
-			return IPPROTO_TCP;
-		if (strcmp(option, "udp") == 0)
-			return IPPROTO_UDP;
+		if (strcmp(option, "tcp") == 0) {
+			*protocol = IPPROTO_TCP;
+			return 1;
+		}
+		if (strcmp(option, "udp") == 0) {
+			*protocol = IPPROTO_UDP;
+			return 1;
+		}
+		return 0;
 	}
 
-	return nfs_nfs_protocol(options);
+	/*
+	 * MNT transport protocol wasn't specified.  If the NFS
+	 * transport protocol was specified, use that; otherwise
+	 * set @protocol to zero.  The pmap protocol value will
+	 * be filled in later by an rpcbind query in this case.
+	 */
+	return nfs_nfs_protocol(options, protocol);
 }
 
 /*
- * Returns the mountd server's port number specified by the given
- * mount options, or zero if all fails.  Zero results in a portmap
- * query to discover the server's mountd service port.
- *
- * mountport=0 will guarantee an rpcbind request precedes the mount
- * RPC so the client can determine the server's port number.
+ * Returns TRUE if @port contains a valid value for this option,
+ * or FALSE if the option was specified with an invalid value.
  */
-static unsigned short nfs_mount_port(struct mount_options *options)
+static int
+nfs_mount_port(struct mount_options *options, unsigned long *port)
 {
 	long tmp;
 
-	if (po_get_numeric(options, "mountport", &tmp) == PO_FOUND)
-		if (tmp >= 0 && tmp <= 65535)
-			return tmp;
-	return 0;
+	switch (po_get_numeric(options, "mountport", &tmp)) {
+	case PO_NOT_FOUND:
+		break;
+	case PO_FOUND:
+		if (tmp >= 1 && tmp <= 65535) {
+			*port = tmp;
+			return 1;
+		}
+	case PO_BAD_VALUE:
+		return 0;
+	}
+
+	/*
+	 * MNT service port wasn't specified.  The pmap port value
+	 * will be filled in later by an rpcbind query in this case.
+	 */
+	*port = 0;
+	return 1;
 }
 
 /**
@@ -1353,17 +1460,29 @@ static unsigned short nfs_mount_port(struct mount_options *options)
  * @nfs_pmap: OUT: pointer to pmap arguments for NFS server
  * @mnt_pmap: OUT: pointer to pmap arguments for mountd server
  *
+ * Returns TRUE if the pmap options specified in @options have valid
+ * values; otherwise FALSE is returned.
  */
-void nfs_options2pmap(struct mount_options *options,
-		      struct pmap *nfs_pmap, struct pmap *mnt_pmap)
+int nfs_options2pmap(struct mount_options *options,
+		     struct pmap *nfs_pmap, struct pmap *mnt_pmap)
 {
-	nfs_pmap->pm_prog = nfs_nfs_program(options);
-	nfs_pmap->pm_vers = nfs_nfs_version(options);
-	nfs_pmap->pm_prot = nfs_nfs_protocol(options);
-	nfs_pmap->pm_port = nfs_nfs_port(options);
-
-	mnt_pmap->pm_prog = nfs_mount_program(options);
-	mnt_pmap->pm_vers = nfs_mount_version(options);
-	mnt_pmap->pm_prot = nfs_mount_protocol(options);
-	mnt_pmap->pm_port = nfs_mount_port(options);
+	if (!nfs_nfs_program(options, &nfs_pmap->pm_prog))
+		return 0;
+	if (!nfs_nfs_version(options, &nfs_pmap->pm_vers))
+		return 0;
+	if (!nfs_nfs_protocol(options, &nfs_pmap->pm_prot))
+		return 0;
+	if (!nfs_nfs_port(options, &nfs_pmap->pm_port))
+		return 0;
+
+	if (!nfs_mount_program(options, &mnt_pmap->pm_prog))
+		return 0;
+	if (!nfs_mount_version(options, &mnt_pmap->pm_vers))
+		return 0;
+	if (!nfs_mount_protocol(options, &mnt_pmap->pm_prot))
+		return 0;
+	if (!nfs_mount_port(options, &mnt_pmap->pm_port))
+		return 0;
+
+	return 1;
 }
diff --git a/utils/mount/network.h b/utils/mount/network.h
index b3f9bd2..ca5fa3b 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -57,7 +57,7 @@ int clnt_ping(struct sockaddr_in *, const unsigned long,
 
 struct mount_options;
 
-void nfs_options2pmap(struct mount_options *,
+int nfs_options2pmap(struct mount_options *,
 		      struct pmap *, struct pmap *);
 
 int start_statd(void);
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 9b48cc9..ba27900 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -174,7 +174,10 @@ static int nfs_umount_do_umnt(struct mount_options *options,
 	socklen_t salen = sizeof(address);
 	struct pmap nfs_pmap, mnt_pmap;
 
-	nfs_options2pmap(options, &nfs_pmap, &mnt_pmap);
+	if (!nfs_options2pmap(options, &nfs_pmap, &mnt_pmap)) {
+		nfs_error(_("%s: bad mount options"), progname);
+		return EX_FAIL;
+	}
 
 	*hostname = nfs_umount_hostname(options, *hostname);
 	if (!*hostname) {
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index ec95b78..30ac5ae 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -450,7 +450,10 @@ static struct mount_options *nfs_rewrite_mount_options(char *str)
 		goto err;
 	}
 
-	nfs_options2pmap(options, &nfs_pmap, &mnt_pmap);
+	if (!nfs_options2pmap(options, &nfs_pmap, &mnt_pmap)) {
+		errno = EINVAL;
+		goto err;
+	}
 
 	/* The kernel NFS client doesn't support changing the RPC program
 	 * number for these services, so reset these fields before probing

