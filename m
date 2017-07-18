Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54922 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750730AbdGRFdc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Jul 2017 01:33:32 -0400
From: Eryu Guan <eguan@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Eryu Guan <eguan@redhat.com>, Christoph Hellwig <hch@lst.de>
Subject: [PATCH] nfs: count correct array for mnt3_counts array size
Date: Tue, 18 Jul 2017 13:32:32 +0800
Message-Id: <20170718053232.14858-1-eguan@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Array size of mnt3_counts should be the size of array
mnt3_procedures, not mnt_procedures, though they're same in size
right now. Found this by code inspection.

Fixes: 1c5876ddbdb4 ("sunrpc: move p_count out of struct rpc_procinfo")
Cc: Christoph Hellwig <hch@lst.de>
Signed-off-by: Eryu Guan <eguan@redhat.com>
---
 fs/nfs/mount_clnt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 3efe946672be..60bad882c123 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -512,7 +512,7 @@ static const struct rpc_version mnt_version1 = {
 	.counts		= mnt_counts,
 };
 
-static unsigned int mnt3_counts[ARRAY_SIZE(mnt_procedures)];
+static unsigned int mnt3_counts[ARRAY_SIZE(mnt3_procedures)];
 static const struct rpc_version mnt_version3 = {
 	.number		= 3,
 	.nrprocs	= ARRAY_SIZE(mnt3_procedures),
-- 
2.13.3

