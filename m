Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:57479 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251Ab0HKNKs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Aug 2010 09:10:48 -0400
Received: from homiemail-a5.g.dreamhost.com (caiajhbdcagg.dreamhost.com [208.97.132.66])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 375A417AC7F
	for <linux-nfs@vger.kernel.org>; Wed, 11 Aug 2010 06:10:48 -0700 (PDT)
Subject: [PATCH] nfs: Remove redundant NULL check upon kfree()
From: Davidlohr Bueso <dave@gnu.org>
Reply-To: dave@gnu.org
To: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 11 Aug 2010 09:10:00 -0400
Message-ID: <1281532200.2067.7.camel@cowboy>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

nfs: Remove redundant NULL check upon kfree().

Signed-off-by: Davidlohr Bueso <dave@gnu.org>
---
 fs/nfs/nfs4proc.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7ffbb98..6b44bbf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2273,8 +2273,7 @@ static int nfs4_get_referral(struct inode *dir, const struct qstr *name, struct
 out:
 	if (page)
 		__free_page(page);
-	if (locations)
-		kfree(locations);
+	kfree(locations);
 	return status;
 }
 
-- 
1.7.0.4



