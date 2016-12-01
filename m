Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34111 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756832AbcLAWGg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:06:36 -0500
Received: by mail-io0-f194.google.com with SMTP id r94so3851303ioe.1
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:06:36 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] NFSv4: Don't ask for the change attribute when reclaiming state
Date: Thu,  1 Dec 2016 17:06:29 -0500
Message-Id: <20161201220632.12754-3-trond.myklebust@primarydata.com>
In-Reply-To: <20161201220632.12754-2-trond.myklebust@primarydata.com>
References: <20161201220632.12754-1-trond.myklebust@primarydata.com>
 <20161201220632.12754-2-trond.myklebust@primarydata.com>
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
index b582df89c083..c0628f78ed98 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -226,7 +226,6 @@ static const u32 nfs4_pnfs_open_bitmap[3] = {
 
 static const u32 nfs4_open_noattr_bitmap[3] = {
 	FATTR4_WORD0_TYPE
-	| FATTR4_WORD0_CHANGE
 	| FATTR4_WORD0_FILEID,
 };
 
-- 
2.9.3

