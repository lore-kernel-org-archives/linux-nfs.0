From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 1/5] sunrpc: Clean never used include files
Date: Wed, 21 Oct 2009 10:11:51 +0200
Message-ID: <1256112711-25728-1-git-send-email-bharrosh@panasas.com>
References: <4ADEC1EF.8040107@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Trond Myklebust <Trond.M
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:55778 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752023AbZJUILw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Oct 2009 04:11:52 -0400
In-Reply-To: <4ADEC1EF.8040107@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove include of two headers never used by this file.
I did not see any users dependency but if exist they
should be fixed since these headers are totally irrelevant
to here.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 include/linux/sunrpc/debug.h |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 10709cb..c2786f2 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -28,9 +28,6 @@
 
 #ifdef __KERNEL__
 
-#include <linux/timer.h>
-#include <linux/workqueue.h>
-
 /*
  * Enable RPC debugging/profiling.
  */
-- 
1.6.2.1

