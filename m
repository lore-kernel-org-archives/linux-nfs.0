Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9047 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751659AbdF3NVp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 09:21:45 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@redhat.com>, Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH nfs-utils v2 06/12] mount: AF_VSOCK address parsing
Date: Fri, 30 Jun 2017 14:21:14 +0100
Message-Id: <20170630132120.31578-7-stefanha@redhat.com>
In-Reply-To: <20170630132120.31578-1-stefanha@redhat.com>
References: <20170630132120.31578-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

getaddrinfo(3) does not have AF_VSOCK support.  Parse the CID in the
hostname option and build a struct sockaddr_vm.

There is one tricky thing here: struct addrinfo is normally allocated by
getaddrinfo(3) and freed by freeaddrinfo(3).  The memory allocation of
the struct addrinfo and struct sockaddr are an implementation detail of
libc.  Therefore we must avoid freeaddrinfo(3) calls when the addrinfo
details were filled out by us for AF_VSOCK instead of by getaddrinfo(3).

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 utils/mount/stropts.c | 63 +++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 58 insertions(+), 5 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 99656dd..3161609 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -898,6 +898,42 @@ fall_back:
 	return nfs_try_mount_v3v2(mi, FALSE);
 }
 
+#ifdef AF_VSOCK
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
+#endif /* AF_VSOCK */
+
 /*
  * This is a single pass through the fg/bg loop.
  *
@@ -909,12 +945,21 @@ static int nfs_try_mount(struct nfsmount_info *mi)
 	int result = 0;
 
 	if (mi->address == NULL) {
-		struct addrinfo hint = {};
-		int error;
-		struct addrinfo *address;
+		int error = 0;
+		struct addrinfo *address = NULL;
+
+#ifdef AF_VSOCK
+		if (mi->family == AF_VSOCK)
+			error = vsock_getaddrinfo(mi, &address);
+#endif
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
@@ -1209,6 +1254,14 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
 	} else
 		nfs_error(_("%s: internal option parsing error"), progname);
 
+#ifdef AF_VSOCK
+	/* See vsock_getaddrinfo() for why we cannot use freeaddrinfo(3) */
+	if (mi.address && mi.address->ai_family == AF_VSOCK) {
+		free(mi.address);
+		mi.address = NULL;
+	}
+#endif
+
 	freeaddrinfo(mi.address);
 	free(mi.hostname);
 	return retval;
-- 
2.9.4

