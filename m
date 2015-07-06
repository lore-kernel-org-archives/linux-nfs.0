Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52903 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751412AbbGFOmb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jul 2015 10:42:31 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 0B87A85538
	for <linux-nfs@vger.kernel.org>; Mon,  6 Jul 2015 14:42:31 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-62-169.rdu2.redhat.com [10.10.62.169])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t66EgUBZ020235
	for <linux-nfs@vger.kernel.org>; Mon, 6 Jul 2015 10:42:30 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] mount.nfs: Teach mount.nfs about the mountversion option
Date: Mon,  6 Jul 2015 10:42:28 -0400
Message-Id: <1436193748-4301-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the mountversion option is used, there should
not be any mount negotiations with the server.

Also, when the option is used, its know that the mount
is a v4 mount and a V_SPECFIC type.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/network.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index b5ed850..ebc39d3 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -92,6 +92,7 @@ static const char *nfs_version_opttbl[] = {
 	"v4",
 	"vers",
 	"nfsvers",
+	"minorversion",
 	NULL,
 };
 
@@ -1272,7 +1273,11 @@ nfs_nfs_version(struct mount_options *options, struct nfs_version *version)
 	if (!(version->major = strtol(version_val, &cptr, 10)))
 		goto ret_error;
 
-	if (version->major < 4)
+	if (strcmp(nfs_version_opttbl[i], "minorversion") == 0) {
+		version->v_mode = V_SPECIFIC;
+		version->minor = version->major;
+		version->major = 4;
+	} else if (version->major < 4)
 		version->v_mode = V_SPECIFIC;
 
 	if (*cptr == '.') {
-- 
2.4.3

