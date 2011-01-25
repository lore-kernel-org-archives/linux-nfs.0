Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24153 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751426Ab1AYPhm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Jan 2011 10:37:42 -0500
From: andros@netapp.com
To: trond.myklebuse@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 3/3] NFS improve pnfs_put_deviceid_cache debug print
Date: Tue, 25 Jan 2011 10:38:03 -0500
Message-Id: <1295969883-2100-3-git-send-email-andros@netapp.com>
In-Reply-To: <1295969883-2100-2-git-send-email-andros@netapp.com>
References: <1295969883-2100-1-git-send-email-andros@netapp.com>
 <1295969883-2100-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

What we really want to know is the ref count.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index bc40897..1b1bc1a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -951,7 +951,7 @@ pnfs_put_deviceid_cache(struct nfs_client *clp)
 {
 	struct pnfs_deviceid_cache *local = clp->cl_devid_cache;
 
-	dprintk("--> %s cl_devid_cache %p\n", __func__, clp->cl_devid_cache);
+	dprintk("--> %s ({%d})\n", __func__, atomic_read(&local->dc_ref));
 	if (atomic_dec_and_lock(&local->dc_ref, &clp->cl_lock)) {
 		int i;
 		/* Verify cache is empty */
-- 
1.6.6

