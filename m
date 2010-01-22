From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] text-based mount: Support protocol family negotiation
Date: Fri, 22 Jan 2010 16:06:47 -0500
Message-ID: <20100122210647.10598.74090.stgit@localhost.localdomain>
References: <20100122210221.10598.84522.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: jlayton@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:23352 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754446Ab0AVVH1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jan 2010 16:07:27 -0500
In-Reply-To: <20100122210221.10598.84522.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton pointed out that the current negotiation logic in
stropts.c simply doesn't handle the case where a server may have an
IPv6 address and an IPv4 address, but only NFS/IPv4 is supported.
This is typical of all currently deployed Linux servers.

Add support for trying all addresses returned from DNS when
"proto=" is not specified on the command line.
---

 utils/mount/stropts.c |   71 +++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 60 insertions(+), 11 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index fc1b0da..9b8c38f 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -576,12 +576,9 @@ static int nfs_sys_mount(struct nfsmount_info *mi, struct mount_options *opts)
 	return !result;
 }
 
-/*
- * For "-t nfs vers=2" or "-t nfs vers=3" mounts.
- */
-static int nfs_try_mount_v3v2(struct nfsmount_info *mi)
+static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
+		struct sockaddr *sap, socklen_t salen)
 {
-	struct addrinfo *ai = mi->address;
 	struct mount_options *options = po_dup(mi->options);
 	int result = 0;
 
@@ -590,7 +587,7 @@ static int nfs_try_mount_v3v2(struct nfsmount_info *mi)
 		return result;
 	}
 
-	if (!nfs_append_addr_option(ai->ai_addr, ai->ai_addrlen, options)) {
+	if (!nfs_append_addr_option(sap, salen, options)) {
 		errno = EINVAL;
 		goto out_fail;
 	}
@@ -630,11 +627,36 @@ out_fail:
 }
 
 /*
- * For "-t nfs -o vers=4" or "-t nfs4" mounts.
+ * Attempt a "-t nfs vers=2" or "-t nfs vers=3" mount.
+ *
+ * Returns TRUE if successful, otherwise FALSE.
+ * "errno" is set to reflect the individual error.
  */
-static int nfs_try_mount_v4(struct nfsmount_info *mi)
+static int nfs_try_mount_v3v2(struct nfsmount_info *mi)
+{
+	struct addrinfo *ai;
+	int ret;
+
+	for (ai = mi->address; ai != NULL; ai = ai->ai_next) {
+		ret = nfs_do_mount_v3v2(mi, ai->ai_addr, ai->ai_addrlen);
+		if (ret != 0)
+			return ret;
+
+		switch (errno) {
+		case ECONNREFUSED:
+		case EOPNOTSUPP:
+		case EHOSTUNREACH:
+			continue;
+		default:
+			break;
+		}
+	}
+	return ret;
+}
+
+static int nfs_do_mount_v4(struct nfsmount_info *mi,
+		struct sockaddr *sap, socklen_t salen)
 {
-	struct addrinfo *ai = mi->address;
 	struct mount_options *options = po_dup(mi->options);
 	int result = 0;
 
@@ -662,12 +684,12 @@ static int nfs_try_mount_v4(struct nfsmount_info *mi)
 		}
 	}
 
-	if (!nfs_append_addr_option(ai->ai_addr, ai->ai_addrlen, options)) {
+	if (!nfs_append_addr_option(sap, salen, options)) {
 		errno = EINVAL;
 		goto out_fail;
 	}
 
-	if (!nfs_append_clientaddr_option(ai->ai_addr, ai->ai_addrlen, options)) {
+	if (!nfs_append_clientaddr_option(sap, salen, options)) {
 		errno = EINVAL;
 		goto out_fail;
 	}
@@ -692,6 +714,33 @@ out_fail:
 }
 
 /*
+ * Attempt a "-t nfs -o vers=4" or "-t nfs4" mount.
+ *
+ * Returns TRUE if successful, otherwise FALSE.
+ * "errno" is set to reflect the individual error.
+ */
+static int nfs_try_mount_v4(struct nfsmount_info *mi)
+{
+	struct addrinfo *ai;
+	int ret;
+
+	for (ai = mi->address; ai != NULL; ai = ai->ai_next) {
+		ret = nfs_do_mount_v4(mi, ai->ai_addr, ai->ai_addrlen);
+		if (ret != 0)
+			return ret;
+
+		switch (errno) {
+		case ECONNREFUSED:
+		case EHOSTUNREACH:
+			continue;
+		default:
+			break;
+		}
+	}
+	return ret;
+}
+
+/*
  * This is a single pass through the fg/bg loop.
  *
  * Returns TRUE if successful, otherwise FALSE.

