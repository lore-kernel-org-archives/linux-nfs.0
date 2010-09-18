Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52093 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754753Ab0IRDSd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Sep 2010 23:18:33 -0400
Received: from localhost.localdomain (scher1-lxp.hq.netapp.com [10.58.61.44] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o8I3IEV3012071
	for <linux-nfs@vger.kernel.org>; Fri, 17 Sep 2010 20:18:15 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 01/12] NFSD: remove duplicate NFS4_STATEID_SIZE
Date: Fri, 17 Sep 2010 23:17:43 -0400
Message-Id: <1284779874-10499-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1284779874-10499-1-git-send-email-iisaman@netapp.com>
References: <1284779874-10499-1-git-send-email-iisaman@netapp.com>
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

