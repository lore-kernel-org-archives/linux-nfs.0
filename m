Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38934 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754752AbdEDOhQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 May 2017 10:37:16 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id D48FA80C27
        for <linux-nfs@vger.kernel.org>; Thu,  4 May 2017 14:37:10 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-120-144.rdu2.redhat.com [10.10.120.144])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 8495480DF0
        for <linux-nfs@vger.kernel.org>; Thu,  4 May 2017 14:37:10 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] mount.nfs: Restore errno after v3 mounts on ECONNREFUSED errors
Date: Thu,  4 May 2017 10:37:04 -0400
Message-Id: <20170504143704.18263-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 65ac59cd introduced code that tries v3 mounts
when the the v4 mount fails with ECONNREFUSED. This
code allows failing back to v3 to work correctly.

When the v3 mount fails the original errno value has
been over rewritten. In this case the errno value
needs to be restored to ECONNREFUSED.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/stropts.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index a9ff95d..0fbb375 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -868,7 +868,10 @@ check_result:
 			result = nfs_try_mount_v4(mi);
 			if (result == 0 && errno != ECONNREFUSED)
 				goto check_result;
-		}
+		} else if (result == 0)
+			/* Restore original errno with v3 failures */
+			errno = ECONNREFUSED;
+
 		return result;
 	default:
 		return result;
-- 
2.9.3

