Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:56167 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757808Ab0IGQ0m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 12:26:42 -0400
Received: by iwn5 with SMTP id 5so5440449iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 07 Sep 2010 09:26:41 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] mount.nfs: Prepare way for "vers=4,rdma" mounts
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 07 Sep 2010 12:26:39 -0400
Message-ID: <20100907162638.3392.14786.stgit@seurat.1015granger.net>
In-Reply-To: <20100907162156.3392.90376.stgit@seurat.1015granger.net>
References: <20100907162156.3392.90376.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

At some point, when the kernel starts to support "vers=4,rdma" mounts,
we will want the mount.nfs command to pass "vers=4,rdma" mounts
instead of rejecting them.

Assuming that the kernel will reject these today with EPROTONOSUPPORT,
that would cause the version fallback logic to go to "vers=3,rdma"
automatically.  So the extra check we have now is not needed anyway.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 9695c73..a8b22ce 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -302,13 +302,6 @@ static int nfs_set_version(struct nfsmount_info *mi)
 
 	if (strncmp(mi->type, "nfs4", 4) == 0)
 		mi->version = 4;
-	else {
-		unsigned long protocol;
-		if (!nfs_nfs_protocol(mi->options, &protocol))
-			return 0;
-		if (protocol == NFSPROTO_RDMA)
-			mi->version = 3;
-	}
 
 	/*
 	 * If we still don't know, check for version-specific

