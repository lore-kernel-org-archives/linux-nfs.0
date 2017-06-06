Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55024 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751580AbdFFTsQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Jun 2017 15:48:16 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 4E6CBC049D5C
        for <linux-nfs@vger.kernel.org>; Tue,  6 Jun 2017 19:48:15 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-120-221.rdu2.redhat.com [10.10.120.221])
        by smtp.corp.redhat.com (Postfix) with ESMTP id F17E95885E
        for <linux-nfs@vger.kernel.org>; Tue,  6 Jun 2017 19:48:14 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] mount.nfs: Use default minor version when -t nfs4 is specified
Date: Tue,  6 Jun 2017 15:48:12 -0400
Message-Id: <20170606194812.4248-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the nfs4 filesystem specified, the default minor
version should be used not v4.0.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/stropts.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index c0266e5..57efb26 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -317,7 +317,8 @@ static int nfs_set_version(struct nfsmount_info *mi)
 
 	if (strncmp(mi->type, "nfs4", 4) == 0) {
 		mi->version.major = 4;
-		mi->version.v_mode = V_GENERAL;
+		mi->version.minor = 2;
+		mi->version.v_mode = V_SPECIFIC;
 	}
 	/*
 	 * Before 2.6.32, the kernel NFS client didn't
-- 
2.9.4

