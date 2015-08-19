Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35274 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001AbbHSFSV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Aug 2015 01:18:21 -0400
Received: by pacgr6 with SMTP id gr6so148880624pac.2
        for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2015 22:18:20 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] Revert "NFSv4: Remove incorrect check in can_open_delegated()"
Date: Wed, 19 Aug 2015 00:18:17 -0500
Message-Id: <1439961497-22176-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 4e379d36c050b0117b5d10048be63a44f5036115.

This commit opens up a race between the recovery code and the open code.

Reported-by: Olga Kornievskaia <aglo@umich.edu>
Cc: stable@vger.kernel # v4.0+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9e9f7816cf24..95c5e8d39bef 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1156,6 +1156,8 @@ static int can_open_delegated(struct nfs_delegation *delegation, fmode_t fmode)
 		return 0;
 	if ((delegation->type & fmode) != fmode)
 		return 0;
+	if (test_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags))
+		return 0;
 	if (test_bit(NFS_DELEGATION_RETURNING, &delegation->flags))
 		return 0;
 	nfs_mark_delegation_referenced(delegation);
-- 
2.4.3

