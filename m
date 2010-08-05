Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41859 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759234Ab0HEOSB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Aug 2010 10:18:01 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] NFSv4: Remember to clear NFS_DELEGATED_STATE in nfs_delegation_claim_opens
Date: Thu,  5 Aug 2010 10:17:48 -0400
Message-Id: <1281017872-6043-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1281017872-6043-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1281017872-6043-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Reported-by: Bian Naimeng <biannm@cn.fujitsu.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/delegation.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index b9c3c43..62f296e 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -106,6 +106,7 @@ again:
 			continue;
 		if (memcmp(state->stateid.data, stateid->data, sizeof(state->stateid.data)) != 0)
 			continue;
+		clear_bit(NFS_DELEGATED_STATE, &state->flags);
 		get_nfs_open_context(ctx);
 		spin_unlock(&inode->i_lock);
 		err = nfs4_open_delegation_recall(ctx, state, stateid);
-- 
1.7.2

