Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:48292 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459AbaGJSH5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 14:07:57 -0400
Received: by mail-qc0-f174.google.com with SMTP id x13so7815575qcv.19
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 11:07:55 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH 08/11] nfsd: clean up reset_union_bmap_deny
Date: Thu, 10 Jul 2014 14:07:32 -0400
Message-Id: <1405015655-12469-9-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
References: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix the "deny" argument type, and start the loop at 1. The 0 iteration
is always a noop.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0a54fc956463..5f7294712ad4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4266,10 +4266,11 @@ static inline void nfs4_stateid_downgrade(struct nfs4_ol_stateid *stp, u32 to_ac
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

