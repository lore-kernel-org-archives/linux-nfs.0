Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:51346 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbaCEOHi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Mar 2014 09:07:38 -0500
Received: by mail-ie0-f173.google.com with SMTP id rl12so1049477iec.32
        for <linux-nfs@vger.kernel.org>; Wed, 05 Mar 2014 06:07:37 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andy Adamson <andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 1/4] NFSv4: nfs4_stateid_is_current should return 'true' for an invalid stateid
Date: Wed,  5 Mar 2014 09:07:29 -0500
Message-Id: <1394028452-15956-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1394028452-15956-1-git-send-email-trond.myklebust@primarydata.com>
References: <1393959943-9919-1-git-send-email-trond.myklebust@primarydata.com>
 <1394028452-15956-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When nfs4_set_rw_stateid() can fails by returning EIO to indicate that
the stateid is completely invalid, then it makes no sense to have it
trigger a retry of the READ or WRITE operation. Instead, we should just
have it fall through and attempt a recovery.

Link: http://lkml.kernel.org/r/1393954269-3974-1-git-send-email-andros@netapp.com
Cc: stable@vger.kernel.org # 3.10+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 44e088dc357c..4778c55d0336 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4011,8 +4011,8 @@ static bool nfs4_stateid_is_current(nfs4_stateid *stateid,
 {
 	nfs4_stateid current_stateid;
 
-	if (nfs4_set_rw_stateid(&current_stateid, ctx, l_ctx, fmode))
-		return false;
+	if (nfs4_set_rw_stateid(&current_stateid, ctx, l_ctx, fmode) == -EIO)
+		return true;
 	return nfs4_stateid_match(stateid, &current_stateid);
 }
 
-- 
1.8.5.3

