Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33781 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932755AbcKNUzn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2016 15:55:43 -0500
Received: by mail-it0-f65.google.com with SMTP id c20so14364334itb.0
        for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2016 12:55:43 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/5] NFSv4: Don't ask for the change attribute when reclaiming state
Date: Mon, 14 Nov 2016 15:55:32 -0500
Message-Id: <1479156935-34479-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1479156935-34479-2-git-send-email-trond.myklebust@primarydata.com>
References: <1479156935-34479-1-git-send-email-trond.myklebust@primarydata.com>
 <1479156935-34479-2-git-send-email-trond.myklebust@primarydata.com>
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
index 03109b69c036..1897591689f6 100644
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

