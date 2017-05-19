Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43262 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751874AbdESWZM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 May 2017 18:25:12 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6D813C057FAD
        for <linux-nfs@vger.kernel.org>; Fri, 19 May 2017 22:25:12 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-124-229.rdu2.redhat.com [10.10.124.229])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 1C63818EC3
        for <linux-nfs@vger.kernel.org>; Fri, 19 May 2017 22:25:12 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] mount.nfs: v4 mounts should fail when nfs4 is specified with -t flag
Date: Fri, 19 May 2017 18:25:10 -0400
Message-Id: <20170519222510.31205-2-steved@redhat.com>
In-Reply-To: <20170519222510.31205-1-steved@redhat.com>
References: <20170519222510.31205-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the pseudo root is set with fsid=0, explicit v4
mounts (set with the -t fstype mount flag) should
fail when the incorrect export is tried instead
of rolling back to v3.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/stropts.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 0fbb375..a56e965 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -315,9 +315,10 @@ static int nfs_set_version(struct nfsmount_info *mi)
 	if (!nfs_nfs_version(mi->options, &mi->version))
 		return 0;
 
-	if (strncmp(mi->type, "nfs4", 4) == 0)
+	if (strncmp(mi->type, "nfs4", 4) == 0) {
 		mi->version.major = 4;
-
+		mi->version.v_mode = V_SPECIFIC;
+	}
 	/*
 	 * Before 2.6.32, the kernel NFS client didn't
 	 * support "-t nfs vers=4" mounts, so NFS version
-- 
2.9.4

