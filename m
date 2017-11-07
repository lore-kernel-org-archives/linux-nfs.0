Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:57035 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752134AbdKGW0K (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Nov 2017 17:26:10 -0500
Received: by mail-it0-f66.google.com with SMTP id r127so4205149itb.5
        for <linux-nfs@vger.kernel.org>; Tue, 07 Nov 2017 14:26:10 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Cc: Joshua Watt <JPEWhacker@gmail.com>
Subject: [PATCH] NFS: Fix typo in nomigration mount option
Date: Tue,  7 Nov 2017 16:25:47 -0600
Message-Id: <20171107222547.10425-1-JPEWhacker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The option was incorrectly masking off all other options.

Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
---
 fs/nfs/super.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c9d24bae3025..216f67d628b3 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1332,7 +1332,7 @@ static int nfs_parse_mount_options(char *raw,
 			mnt->options |= NFS_OPTION_MIGRATION;
 			break;
 		case Opt_nomigration:
-			mnt->options &= NFS_OPTION_MIGRATION;
+			mnt->options &= ~NFS_OPTION_MIGRATION;
 			break;
 
 		/*
-- 
2.13.6

