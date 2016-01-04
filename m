Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:32800 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989AbcADSVs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jan 2016 13:21:48 -0500
Received: by mail-io0-f175.google.com with SMTP id q21so162459525iod.0
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jan 2016 10:21:48 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 05/18] NFSv4.1/pNFS: Don't return NFS4ERR_DELAY unnecessarily in CB_LAYOUTRECALL
Date: Mon,  4 Jan 2016 13:21:03 -0500
Message-Id: <1451931676-68481-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451931676-68481-4-git-send-email-trond.myklebust@primarydata.com>
References: <1451931676-68481-1-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-2-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-3-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the client is promising to return the layout ASAP, then there is no
need to return DELAY and have the server retry. Instead default to the
normal procedure described in RFC5661.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 1b24ad07d4f5..724a9b756ab0 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -214,7 +214,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 		pnfs_mark_matching_lsegs_return(lo,
 				&free_me_list,
 				&args->cbl_range);
-		rv = NFS4ERR_DELAY;
+		rv = NFS4_OK;
 		goto unlock;
 	}
 
-- 
2.5.0

