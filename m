Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:48417 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757808Ab0IGQ0U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 12:26:20 -0400
Received: by gxk23 with SMTP id 23so2014997gxk.19
        for <linux-nfs@vger.kernel.org>; Tue, 07 Sep 2010 09:26:20 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] mount.nfs: Use nfs_nfs_protocol() for checking for
	proto=rdma
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 07 Sep 2010 12:26:17 -0400
Message-ID: <20100907162617.3392.21184.stgit@seurat.1015granger.net>
In-Reply-To: <20100907162156.3392.90376.stgit@seurat.1015granger.net>
References: <20100907162156.3392.90376.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up: Now that nfs_get_proto() can recognize "rdma" we can re-use
nfs_nfs_protocol() instead of ad hoc checks for "proto=rdma".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 0241400..9695c73 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -303,8 +303,10 @@ static int nfs_set_version(struct nfsmount_info *mi)
 	if (strncmp(mi->type, "nfs4", 4) == 0)
 		mi->version = 4;
 	else {
-		char *option = po_get(mi->options, "proto");
-		if (option && strcmp(option, "rdma") == 0)
+		unsigned long protocol;
+		if (!nfs_nfs_protocol(mi->options, &protocol))
+			return 0;
+		if (protocol == NFSPROTO_RDMA)
 			mi->version = 3;
 	}
 
@@ -490,14 +492,19 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options)
 	union nfs_sockaddr mnt_address;
 	struct sockaddr *mnt_saddr = &mnt_address.sa;
 	socklen_t mnt_salen = sizeof(mnt_address);
+	unsigned long protocol;
 	struct pmap mnt_pmap;
 	char *option;
 
 	/*
-	 * Skip option negotiation for proto=rdma mounts.
+	 * Version and transport negotiation is not required
+	 * and does not work for RDMA mounts.
 	 */
-	option = po_get(options, "proto");
-	if (option && strcmp(option, "rdma") == 0)
+	if (!nfs_nfs_protocol(options, &protocol)) {
+		errno = EINVAL;
+		return 0;
+	}
+	if (protocol == NFSPROTO_RDMA)
 		goto out;
 
 	/*

