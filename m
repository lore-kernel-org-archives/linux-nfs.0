From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 3/7] SQUASHME: nfs41: alloc session with GFP_KERNEL
Date: Mon, 30 Mar 2009 17:00:36 +0300
Message-ID: <1238421636-25051-1-git-send-email-bhalevy@panasas.com>
References: <49D0D025.2080608@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org, andros@netapp.com
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:1662 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752188AbZC3OAs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 10:00:48 -0400
In-Reply-To: <49D0D025.2080608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No reason for using GFP_ATOMIC.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e51622a..5e7e95c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4525,7 +4525,7 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
 	struct nfs4_session *session;
 	struct nfs4_slot_table *tbl;
 
-	session = kzalloc(sizeof(struct nfs4_session), GFP_ATOMIC);
+	session = kzalloc(sizeof(struct nfs4_session), GFP_KERNEL);
 	if (!session)
 		return NULL;
 
-- 
1.6.2.1

