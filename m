Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47528 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753648Ab0IISKg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Sep 2010 14:10:36 -0400
Received: from localhost.localdomain (surajit-lxp.hq.netapp.com [10.58.50.95] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o89IAW1M002948
	for <linux-nfs@vger.kernel.org>; Thu, 9 Sep 2010 11:10:33 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 01/13] NFSD: remove duplicate NFS4_STATEID_SIZE
Date: Thu,  2 Sep 2010 14:00:07 -0400
Message-Id: <1283450419-5648-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Already accepted by Bruce
---
 fs/nfsd/nfs4callback.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 988cbb3..014482c 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -41,7 +41,6 @@
 
 #define NFSPROC4_CB_NULL 0
 #define NFSPROC4_CB_COMPOUND 1
-#define NFS4_STATEID_SIZE 16
 
 /* Index of predefined Linux callback client operations */
 
-- 
1.7.2.1

