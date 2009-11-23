From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 09/10] nfs41: remove server-only EXCHGID4_FLAG_CONFIRMED_R flag from exchange_id
Date: Mon, 23 Nov 2009 13:54:46 -0800
Message-ID: <1259013287-3349-9-git-send-email-batsakis@netapp.com>
References: <1259013287-3349-1-git-send-email-batsakis@netapp.com>
 <1259013287-3349-2-git-send-email-batsakis@netapp.com>
 <1259013287-3349-3-git-send-email-batsakis@netapp.com>
 <1259013287-3349-4-git-send-email-batsakis@netapp.com>
 <1259013287-3349-5-git-send-email-batsakis@netapp.com>
 <1259013287-3349-6-git-send-email-batsakis@netapp.com>
 <1259013287-3349-7-git-send-email-batsakis@netapp.com>
 <1259013287-3349-8-git-send-email-batsakis@netapp.com>
Cc: Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37396 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757287AbZKWV7Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2009 16:59:25 -0500
In-Reply-To: <1259013287-3349-8-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/nfs4proc.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2de209c..6a0f9ea 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4324,6 +4324,9 @@ static int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	dprintk("--> %s\n", __func__);
 	BUG_ON(clp == NULL);
 
+	if (args.flags & EXCHGID4_FLAG_CONFIRMED_R)
+		args.flags ^= EXCHGID4_FLAG_CONFIRMED_R;
+
 	p = (u32 *)verifier.data;
 	*p++ = htonl((u32)clp->cl_boot_time.tv_sec);
 	*p = htonl((u32)clp->cl_boot_time.tv_nsec);
-- 
1.6.2.5

