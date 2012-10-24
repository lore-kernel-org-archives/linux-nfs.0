Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-da0-f46.google.com ([209.85.210.46]:64199 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757833Ab2JXGxT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2012 02:53:19 -0400
From: ycnian@gmail.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Yanchuan Nian <ycnian@gmail.com>
Subject: [PATCH] nfs: fix wrong object type in lockowner_slab
Date: Wed, 24 Oct 2012 14:44:19 +0800
Message-Id: <1351061059-29318-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yanchuan Nian <ycnian@gmail.com>

The object type in the cache of lockowner_slab is wrong, and it is better to fix it.

Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
---
 fs/nfsd/nfs4state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cc894ed..1609eb2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2325,7 +2325,7 @@ nfsd4_init_slabs(void)
 	if (openowner_slab == NULL)
 		goto out_nomem;
 	lockowner_slab = kmem_cache_create("nfsd4_lockowners",
-			sizeof(struct nfs4_openowner), 0, 0, NULL);
+			sizeof(struct nfs4_lockowner), 0, 0, NULL);
 	if (lockowner_slab == NULL)
 		goto out_nomem;
 	file_slab = kmem_cache_create("nfsd4_files",
-- 
1.7.4.4

