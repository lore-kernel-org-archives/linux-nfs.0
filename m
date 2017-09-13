Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40476 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751678AbdIMK1X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Sep 2017 06:27:23 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: NeilBrown <neilb@suse.com>, Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH nfs-utils v3 08/14] mount: AF_VSOCK address parsing
Date: Wed, 13 Sep 2017 11:26:44 +0100
Message-Id: <20170913102650.10377-9-stefanha@redhat.com>
In-Reply-To: <20170913102650.10377-1-stefanha@redhat.com>
References: <20170913102650.10377-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

getaddrinfo(3) does not have AF_VSOCK support.  Parse the CID in the
hostname option and build a struct sockaddr_vm.

There is one tricky thing here: struct addrinfo is normally allocated by
getaddrinfo(3) and freed by freeaddrinfo(3).  The memory allocation of
the struct addrinfo and struct sockaddr are an implementation detail of
libc.  Therefore we must avoid freeaddrinfo(3) calls when the addrinfo
details were filled out by us for AF_VSOCK instead of by getaddrinfo(3).

It is now possible to mount a file system from the host (hypervisor)
over AF_VSOCK like this:

  (guest)$ mount.nfs 2:/export /mnt -v -o proto=vsock

The hypervisor is CID 2.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 utils/mount/stropts.c | 57 ++++++++++++++++++++++++++++++++++++++++++++++-----
 utils/mount/nfs.man   | 20 ++++++++++++++----
 2 files changed, 68 insertions(+), 9 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 033f254..be72e1e 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -908,6 +908,40 @@ fall_back:
 	return nfs_try_mount_v3v2(mi, FALSE);
 }
 
+/* There are no guarantees on how getaddrinfo(3) allocates struct addrinfo so
+ * be sure to call free(3) on *address instead of freeaddrinfo(3).
+ */
+static int vsock_getaddrinfo(struct nfsmount_info *mi,
+			     struct addrinfo **address)
+{
+	struct {
+		struct addrinfo ai;
+		struct sockaddr_vm svm;
+	} *vai;
+	long cid;
+	char *endptr;
+
+	errno = 0;
+	cid = strtol(mi->hostname, &endptr, 10);
+	if (errno != 0 || *endptr != '\0' ||
+	    cid < 0 || cid > UINT_MAX)
+		return EAI_NONAME;
+
+	vai = calloc(1, sizeof(*vai));
+	if (!vai)
+		return EAI_MEMORY;
+
+	vai->ai.ai_family	= AF_VSOCK;
+	vai->ai.ai_socktype	= SOCK_STREAM;
+	vai->ai.ai_addrlen	= sizeof(vai->svm);
+	vai->ai.ai_addr		= (struct sockaddr *)&vai->svm;
+	vai->svm.svm_family	= AF_VSOCK;
+	vai->svm.svm_cid	= cid;
+
+	*address = &vai->ai;
+	return 0;
+}
+
 /*
  * This is a single pass through the fg/bg loop.
  *
@@ -919,12 +953,19 @@ static int nfs_try_mount(struct nfsmount_info *mi)
 	int result = 0;
 
 	if (mi->address == NULL) {
-		struct addrinfo hint = {};
-		int error;
-		struct addrinfo *address;
+		int error = 0;
+		struct addrinfo *address = NULL;
+
+		if (mi->family == AF_VSOCK)
+			error = vsock_getaddrinfo(mi, &address);
+
+		if (error == 0 && !address) {
+			struct addrinfo hint = {};
+
+			hint.ai_family = (int)mi->family;
+			error = getaddrinfo(mi->hostname, NULL, &hint, &address);
+		}
 
-		hint.ai_family = (int)mi->family;
-		error = getaddrinfo(mi->hostname, NULL, &hint, &address);
 		if (error != 0) {
 			if (error == EAI_AGAIN)
 				errno = EAGAIN;
@@ -1219,6 +1260,12 @@ int nfsmount_string(const char *spec, const char *node, char *type,
 	} else
 		nfs_error(_("%s: internal option parsing error"), progname);
 
+	/* See vsock_getaddrinfo() for why we cannot use freeaddrinfo(3) */
+	if (mi.address && mi.address->ai_family == AF_VSOCK) {
+		free(mi.address);
+		mi.address = NULL;
+	}
+
 	freeaddrinfo(mi.address);
 	free(mi.hostname);
 	return retval;
diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index cc6e992..4651826 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -58,8 +58,10 @@ are separated by blanks or tabs.
 .P
 The server's hostname can be an unqualified hostname,
 a fully qualified domain name,
-a dotted quad IPv4 address, or
-an IPv6 address enclosed in square brackets.
+a dotted quad IPv4 address,
+an IPv6 address enclosed in square brackets,
+or a vsock address prefixed with
+.BR vsock: .
 Link-local and site-local IPv6 addresses must be accompanied by an
 interface identifier.
 See
@@ -769,7 +771,7 @@ The
 .I netid
 determines the transport that is used to communicate with the NFS
 server.  Supported options are
-.BR tcp ", " tcp6 ", and " rdma .
+.BR tcp ", " tcp6 ", " rdma ", and " vsock .
 .B tcp6
 use IPv6 addresses and is only available if support for TI-RPC is
 built in. Both others use IPv4 addresses.
@@ -815,8 +817,11 @@ the behavior of this option in more detail.
 .BI clientaddr= n.n.n.n
 .TP 1.5i
 .BI clientaddr= n:n: ... :n
+.TP 1.5i
+.BI clientaddr= n
 Specifies a single IPv4 address (in dotted-quad form),
-or a non-link-local IPv6 address,
+a non-link-local IPv6 address,
+or a vsock address,
 that the NFS client advertises to allow servers
 to perform NFS version 4 callback requests against
 files on this mount point. If  the  server is unable to
@@ -934,6 +939,13 @@ using a raw IPv6 link-local address.
 .ta 8n +40n +5n +4n +9n
 	[fe80::215:c5ff:fb3e:e2b1%eth0]:/export	/mnt	nfs	defaults	0 0
 .fi
+.P
+This example shows how to mount using NFS version 4 over vsock.
+.P
+.nf
+.ta 8n +16n +6n +6n +30n
+	vsock:2:/export	/mnt	nfs4	defaults	0 0
+.fi
 .SH "TRANSPORT METHODS"
 NFS clients send requests to NFS servers via
 Remote Procedure Calls, or
-- 
2.13.5

