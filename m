Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60626 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755315Ab2KVSme (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Nov 2012 13:42:34 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 04/20] NFSv4.1: nfs4_alloc_slots doesn't need zeroing
Date: Wed, 21 Nov 2012 17:43:03 -0500
Message-Id: <1353537799-60488-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353537799-60488-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1353537799-60488-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-3-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All that memory is going to be initialised to non-zero by
nfs4_add_and_init_slots anyway.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1ac339b..0402ebb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5658,7 +5658,7 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
 
 static struct nfs4_slot *nfs4_alloc_slots(u32 max_slots, gfp_t gfp_flags)
 {
-	return kcalloc(max_slots, sizeof(struct nfs4_slot), gfp_flags);
+	return kmalloc_array(max_slots, sizeof(struct nfs4_slot), gfp_flags);
 }
 
 static void nfs4_add_and_init_slots(struct nfs4_slot_table *tbl,
-- 
1.7.11.7

