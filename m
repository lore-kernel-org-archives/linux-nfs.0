Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:59470 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753120AbeDJO3z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 10 Apr 2018 10:29:55 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.rdu2.redhat.com [10.11.54.3])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id F236D40201A3
        for <linux-nfs@vger.kernel.org>; Tue, 10 Apr 2018 14:29:54 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id DD31D11701C5
        for <linux-nfs@vger.kernel.org>; Tue, 10 Apr 2018 14:29:54 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] mount.nfs: Fix auto protocol negotiation
Date: Tue, 10 Apr 2018 10:29:52 -0400
Message-Id: <20180410142952.10657-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 71b807e1 introduce a regression that
caused v3 not to be tried when v4 was not
supported by the server during auto negation.

A check of the type in nfs_nfs_version() was
reverted back to only check for the "nfs4"
string not the "nfs" string which fixed the
problem.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/network.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 9a2c878..e490399 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1279,8 +1279,8 @@ nfs_nfs_version(char *type, struct mount_options *options, struct nfs_version *v
 		}
 	}
 
-	if (!found && strncmp(type, "nfs", 3) == 0)
-		version_val = "4";
+	if (!found && strcmp(type, "nfs4") == 0)
+		version_val = type + 3;
 	else if (!found)
 		return 1;
 	else if (i <= 2 ) {
-- 
2.14.3

