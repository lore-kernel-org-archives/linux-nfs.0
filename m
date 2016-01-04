Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:35188 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127AbcADSV5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jan 2016 13:21:57 -0500
Received: by mail-ig0-f174.google.com with SMTP id to4so249282344igc.0
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jan 2016 10:21:57 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 15/18] NFSv4.1/pNFS: Fix a race in initiate_file_draining()
Date: Mon,  4 Jan 2016 13:21:13 -0500
Message-Id: <1451931676-68481-15-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451931676-68481-14-git-send-email-trond.myklebust@primarydata.com>
References: <1451931676-68481-1-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-2-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-3-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-4-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-5-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-6-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-7-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-8-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-9-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-10-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-11-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-12-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-13-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-14-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Peng Tao points out that the call to pnfs_mark_matching_lsegs_return()
could race with pnfs_put_lseg(), in which case the layout segment is
cleared, but no layoutreturn will be sent.
Fix is to replace the call to pnfs_mark_matching_lsegs_invalid().

Reported-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 2be8b252e3b1..f0939d097406 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -216,11 +216,8 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 		goto unlock;
 	}
 
-	if (pnfs_mark_matching_lsegs_invalid(lo, &free_me_list,
+	if (pnfs_mark_matching_lsegs_return(lo, &free_me_list,
 					&args->cbl_range)) {
-		pnfs_mark_matching_lsegs_return(lo,
-				&free_me_list,
-				&args->cbl_range);
 		rv = NFS4_OK;
 		goto unlock;
 	}
-- 
2.5.0

