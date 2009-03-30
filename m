From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/7] SQUASHME: nfs41: use kcalloc to allocate slot table
Date: Mon, 30 Mar 2009 17:00:33 +0300
Message-ID: <1238421633-25020-1-git-send-email-bhalevy@panasas.com>
References: <49D0D025.2080608@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org, andros@netapp.com
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:14220 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751469AbZC3OAr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 10:00:47 -0400
In-Reply-To: <49D0D025.2080608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also, change gfp flags to GFP_KERNEL.

FIXME: move nfs4_init_slot_table's definition
from "nfs41: sessions client infrastructure"
to "nfs41: create_session operation"
and squash this patch there.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7a96e17..e51622a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4470,7 +4470,7 @@ static int nfs4_init_slot_table(struct nfs4_slot_table *tbl,
 
 	dprintk("--> %s: max_reqs=%u\n", __func__, max_slots);
 
-	slot = kzalloc(max_slots * sizeof(struct nfs4_slot), GFP_ATOMIC);
+	slot = kcalloc(max_slots, sizeof(struct nfs4_slot), GFP_KERNEL);
 	if (!slot)
 		goto out;
 	for (i = 0; i < max_slots; ++i)
-- 
1.6.2.1

