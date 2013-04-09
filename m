Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:51632 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751866Ab3DJGFe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Apr 2013 02:05:34 -0400
Message-ID: <5163AF52.2080303@cn.fujitsu.com>
Date: Tue, 09 Apr 2013 14:04:02 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsd: don't  calculate mem's size in loop every time
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


 Signed-off-by: fanchaoting <fanchaoting@cn.fujitsu.com>
---
 fs/nfsd/nfs4state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2e27430..df3e3fd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -716,8 +716,8 @@ static struct nfsd4_session *__alloc_session(int slotsize, int numslots)
 	if (!new)
 		return NULL;
 	/* allocate each struct nfsd4_slot and data cache in one piece */
+	mem = sizeof(struct nfsd4_slot) + slotsize;
 	for (i = 0; i < numslots; i++) {
-		mem = sizeof(struct nfsd4_slot) + slotsize;
 		new->se_slots[i] = kzalloc(mem, GFP_KERNEL);
 		if (!new->se_slots[i])
 			goto out_free;
-- 
1.7.1
