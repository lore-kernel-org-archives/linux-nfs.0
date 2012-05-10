Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:59152 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758051Ab2EJTb1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 15:31:27 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: bfields@fieldses.org
Cc: bjschuma@netapp.com, linux-nfs@vger.kernel.org,
        Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] nfsd: return 0 on reads of fault injection files
Date: Thu, 10 May 2012 15:31:10 -0400
Message-Id: <1336678270-791-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

debugfs read operations were returning the contents of an uninitialized u64.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
I found this while working on (forthcoming) fault injection tests for 
CB_PATH_DOWN.

 fs/nfsd/fault_inject.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index 46b7696..ab81144 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -62,6 +62,7 @@ static int nfsd_inject_set(void *op_ptr, u64 val)
 
 static int nfsd_inject_get(void *data, u64 *val)
 {
+	*val = 0;
 	return 0;
 }
 
-- 
1.7.4.4

