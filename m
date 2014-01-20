Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx.bwstor.com.cn ([211.103.180.228]:35193 "EHLO mx.bwstor.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751467AbaATIQp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jan 2014 03:16:45 -0500
From: shaobingqing <shaobingqing@bwstor.com.cn>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        shaobingqing <shaobingqing@bwstor.com.cn>
Subject: [PATCH] NFSv4.1: new layout stateid can not be overwrite by one out of date
Date: Mon, 20 Jan 2014 16:15:31 +0800
Message-Id: <1390205731-21005-1-git-send-email-shaobingqing@bwstor.com.cn>
In-Reply-To: <n>
References: <n>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If initiate_file_draining returned NFS4ERR_DELAY, all the lsegs of
a file might be released before the retrying cb_layout request arriving
at the client. In this situation, layoutget request of the file will
use open stateid to obtain a new layout stateid. And if the retrying
cb_layout request arrived at the client after the layoutget reply,
new layout stateid would be overwrite by one out of date.

Signed-off-by: shaobingqing <shaobingqing@bwstor.com.cn>
---
 fs/nfs/callback_proc.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index ae2e87b..98fed13 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -174,7 +174,9 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 		rv = NFS4ERR_DELAY;
 	else
 		rv = NFS4ERR_NOMATCHING_LAYOUT;
-	pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
+	if (memcmp(args->cbl_stateid.other, lo->plh_stateid.other,
+	     NFS4_STATEID_OTHER_SIZE) == 0)
+		pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&free_me_list);
 	pnfs_put_layout_hdr(lo);
-- 
1.7.4.2

