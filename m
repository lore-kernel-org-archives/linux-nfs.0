Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38276 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750818AbdESWZM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 May 2017 18:25:12 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id ECC8E4ACAA
        for <linux-nfs@vger.kernel.org>; Fri, 19 May 2017 22:25:11 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-124-229.rdu2.redhat.com [10.10.124.229])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 9C0CD60BE5
        for <linux-nfs@vger.kernel.org>; Fri, 19 May 2017 22:25:11 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] mount.nfs: v4 mounts should fail when -o flag is used.
Date: Fri, 19 May 2017 18:25:09 -0400
Message-Id: <20170519222510.31205-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the pseudo root is set with fsid=0, explicit
v4 mounts (via the -o flag) should fail when
the incorrect export is tried instead of rolling
back to v3.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/network.c | 3 ++-
 utils/mount/network.h | 8 ++++----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 281e935..e39263e 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1299,7 +1299,8 @@ nfs_nfs_version(struct mount_options *options, struct nfs_version *version)
 		if (!(version->minor = strtol(version_val, &cptr, 10)) && cptr == version_val)
 			goto ret_error;
 		version->v_mode = V_SPECIFIC;
-	} else if (version->major > 3 && *cptr == '\0')
+	} else if (version->major > 3 && *cptr == '\0' &&
+			version->v_mode == V_DEFAULT) /* v_mode has not been set */
 		version->v_mode = V_GENERAL;
 
 	if (*cptr != '\0')
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 9cc5dec..45e2b24 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -58,10 +58,10 @@ int clnt_ping(struct sockaddr_in *, const unsigned long,
 struct mount_options;
 
 enum {
-	V_DEFAULT = 0,
-	V_GENERAL,
-	V_SPECIFIC,
-	V_PARSE_ERR,
+	V_DEFAULT = 0, /* not set */
+	V_GENERAL,     /* single digit => 4 */
+	V_SPECIFIC,    /* single digit < 4 or decimal included */
+	V_PARSE_ERR,   /* miss all others */
 };
 
 struct nfs_version {
-- 
2.9.4

