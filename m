From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 06/47] nfsd41: change NFSERR_REPLAY_ME
Date: Fri, 27 Mar 2009 06:06:30 +0300
Message-ID: <1238123190-7099-1-git-send-email-bhalevy@panasas.com>
References: <49CC40E5.2080506@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>,
	Andy Adamson <andros@netapp.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:22668 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752715AbZC0DGf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 23:06:35 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
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

