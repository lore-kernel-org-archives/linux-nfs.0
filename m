Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f43.google.com ([209.85.216.43]:50826 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754642AbaF3PvO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:51:14 -0400
Received: by mail-qa0-f43.google.com with SMTP id k15so6546541qaq.16
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:51:13 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 029/114] nfsd: clean up reset_union_bmap_deny
Date: Mon, 30 Jun 2014 11:48:58 -0400
Message-Id: <1404143423-24381-30-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix the "deny" argument type, and start the loop at 1. The 0 iteration
is always a noop.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 343b8de6309d..d0e465cb0781 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4242,10 +4242,11 @@ static inline void nfs4_stateid_downgrade(struct nfs4_ol_stateid *stp, u32 to_ac
 }
 
 static void
-reset_union_bmap_deny(unsigned long deny, struct nfs4_ol_stateid *stp)
+reset_union_bmap_deny(u32 deny, struct nfs4_ol_stateid *stp)
 {
 	int i;
-	for (i = 0; i < 4; i++) {
+
+	for (i = 1; i < 4; i++) {
 		if ((i & deny) != i)
 			clear_deny(i, stp);
 	}
-- 
1.9.3

