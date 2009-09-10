From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 04/12] nfsd4: fix whitespace in NFSPROC4_CLNT_CB_NULL definition
Date: Thu, 10 Sep 2009 12:25:46 +0300
Message-ID: <1252574746-30142-1-git-send-email-bhalevy@panasas.com>
References: <4AA8C597.8080809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:54720 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755281AbZIJJZR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Sep 2009 05:25:17 -0400
In-Reply-To: <4AA8C597.8080809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 81d1c52..63bb384 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -56,7 +56,7 @@
 /* Index of predefined Linux callback client operations */
 
 enum {
-        NFSPROC4_CLNT_CB_NULL = 0,
+	NFSPROC4_CLNT_CB_NULL = 0,
 	NFSPROC4_CLNT_CB_RECALL,
 };
 
-- 
1.6.4

