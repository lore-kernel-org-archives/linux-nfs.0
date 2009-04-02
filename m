From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 04/21] SQUASHME: nfs41: reverse EXCHGID4_INVAL_FLAG_MASK_{A,R}
Date: Fri,  3 Apr 2009 01:37:48 +0300
Message-ID: <1238711868-22146-1-git-send-email-bhalevy@panasas.com>
References: <49D53D44.4030102@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:25270 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1764893AbZDBWhy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:37:54 -0400
In-Reply-To: <49D53D44.4030102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As per Bruce's review comment.

squash into "nfs41: common protocol definitions"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfs4.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 5756359..e3f0cbc 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -115,8 +115,8 @@
  * they're set in the argument or response, have separate
  * invalid flag masks for arg (_A) and resp (_R).
  */
-#define EXCHGID4_INVAL_FLAG_MASK_A		0xBFF8FFFC
-#define EXCHGID4_INVAL_FLAG_MASK_R		0x7FF8FFFC
+#define EXCHGID4_FLAG_MASK_A			0x40070003
+#define EXCHGID4_FLAG_MASK_R			0x80070003
 
 #define SEQ4_STATUS_CB_PATH_DOWN		0x00000001
 #define SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRING	0x00000002
-- 
1.6.2.1

