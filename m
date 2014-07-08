Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:55639 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754474AbaGHSE4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:04:56 -0400
Received: by mail-qg0-f52.google.com with SMTP id f51so5281238qge.25
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:04:55 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 015/100] nfsd: clean up reset_union_bmap_deny
Date: Tue,  8 Jul 2014 14:03:03 -0400
Message-Id: <1404842668-22521-16-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix the "deny" argument type, and start the loop at 1. The 0 iteration
is always a noop.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8cfd38a4dcc0..67d1cb75a667 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4268,10 +4268,11 @@ static inline void nfs4_stateid_downgrade(struct nfs4_ol_stateid *stp, u32 to_ac
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

