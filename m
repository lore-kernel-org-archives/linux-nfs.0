Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33797 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934551AbcKJVlP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2016 16:41:15 -0500
Received: by mail-it0-f65.google.com with SMTP id q124so6237978itd.1
        for <linux-nfs@vger.kernel.org>; Thu, 10 Nov 2016 13:41:15 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] NFSv4: Don't ask for the change attribute when reclaiming state
Date: Thu, 10 Nov 2016 16:41:07 -0500
Message-Id: <1478814070-17140-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1478814070-17140-2-git-send-email-trond.myklebust@primarydata.com>
References: <1478814070-17140-1-git-send-email-trond.myklebust@primarydata.com>
 <1478814070-17140-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't need to ask for the change attribute when returning a delegation
or recovering from a server reboot, and it could actually cause us to
obtain an incorrect value if we're using a pNFS flavour that requires
LAYOUTCOMMIT.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4eead738da8e..1e7e0754a96d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -226,7 +226,6 @@ static const u32 nfs4_pnfs_open_bitmap[3] = {
 
 static const u32 nfs4_open_noattr_bitmap[3] = {
 	FATTR4_WORD0_TYPE
-	| FATTR4_WORD0_CHANGE
 	| FATTR4_WORD0_FILEID,
 };
 
-- 
2.7.4

