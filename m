From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 05/47] nfsd41: change NFSERR_REPLAY_ME
Date: Sat, 28 Mar 2009 11:31:05 +0300
Message-ID: <1238229065-8402-1-git-send-email-bhalevy@panasas.com>
References: <49CDDFC2.4070402@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:15579 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754224AbZC1IbK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 04:31:10 -0400
In-Reply-To: <49CDDFC2.4070402@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

so not to overlap nfs41 error codes.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfs.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfs.h b/include/linux/nfs.h
index 54af92c..1510a64 100644
--- a/include/linux/nfs.h
+++ b/include/linux/nfs.h
@@ -109,7 +109,8 @@
 	NFSERR_FILE_OPEN = 10046,      /*       v4 */
 	NFSERR_ADMIN_REVOKED = 10047,  /*       v4 */
 	NFSERR_CB_PATH_DOWN = 10048,   /*       v4 */
-	NFSERR_REPLAY_ME = 10049	/*       v4 */
+
+	NFSERR_REPLAY_ME = 11001,	/* linux internal */
 };
 
 /* NFSv2 file types - beware, these are not the same in NFSv3 */
-- 
1.6.2.1

