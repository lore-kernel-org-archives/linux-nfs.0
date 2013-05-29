Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:4877 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933570Ab3E2UFX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 May 2013 16:05:23 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix a thinko in nfs4_try_open_cached
Date: Wed, 29 May 2013 16:05:13 -0400
Message-Id: <1369857913-42009-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to pass the full open mode flags to nfs_may_open() when doing
a delegated open.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@vger.kernel.org
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4e2fe71..d7ba561 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1078,7 +1078,7 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 	struct nfs4_state *state = opendata->state;
 	struct nfs_inode *nfsi = NFS_I(state->inode);
 	struct nfs_delegation *delegation;
-	int open_mode = opendata->o_arg.open_flags & (O_EXCL|O_TRUNC);
+	int open_mode = opendata->o_arg.open_flags;
 	fmode_t fmode = opendata->o_arg.fmode;
 	nfs4_stateid stateid;
 	int ret = -EAGAIN;
-- 
1.8.1.4

