Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35124 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759814AbcLAWTn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:43 -0500
Received: by mail-io0-f196.google.com with SMTP id h133so4681378ioe.2
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:43 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 20/26] pNFS: Prevent unnecessary layoutreturns after delegreturn
Date: Thu,  1 Dec 2016 17:19:16 -0500
Message-Id: <20161201221922.15657-21-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-20-trond.myklebust@primarydata.com>
References: <20161201221922.15657-1-trond.myklebust@primarydata.com>
 <20161201221922.15657-2-trond.myklebust@primarydata.com>
 <20161201221922.15657-3-trond.myklebust@primarydata.com>
 <20161201221922.15657-4-trond.myklebust@primarydata.com>
 <20161201221922.15657-5-trond.myklebust@primarydata.com>
 <20161201221922.15657-6-trond.myklebust@primarydata.com>
 <20161201221922.15657-7-trond.myklebust@primarydata.com>
 <20161201221922.15657-8-trond.myklebust@primarydata.com>
 <20161201221922.15657-9-trond.myklebust@primarydata.com>
 <20161201221922.15657-10-trond.myklebust@primarydata.com>
 <20161201221922.15657-11-trond.myklebust@primarydata.com>
 <20161201221922.15657-12-trond.myklebust@primarydata.com>
 <20161201221922.15657-13-trond.myklebust@primarydata.com>
 <20161201221922.15657-14-trond.myklebust@primarydata.com>
 <20161201221922.15657-15-trond.myklebust@primarydata.com>
 <20161201221922.15657-16-trond.myklebust@primarydata.com>
 <20161201221922.15657-17-trond.myklebust@primarydata.com>
 <20161201221922.15657-18-trond.myklebust@primarydata.com>
 <20161201221922.15657-19-trond.myklebust@primarydata.com>
 <20161201221922.15657-20-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we cannot grab the inode or superblock, then we cannot pin the
layout header, and so we cannot send a layoutreturn as part of an
async delegreturn call. In this case, we currently end up sending
an extra layoutreturn after the delegreturn. Since the layout was
implicitly returned by the delegreturn, that just gets a BAD_STATEID.

The fix is to simply complete the return-on-close immediately.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 221d97de0e2c..5593b088c561 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5744,14 +5744,16 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	nfs_fattr_init(data->res.fattr);
 	data->timestamp = jiffies;
 	data->rpc_status = 0;
+	data->lr.roc = pnfs_roc(inode, &data->lr.arg, &data->lr.res, cred);
 	data->inode = nfs_igrab_and_active(inode);
 	if (data->inode) {
-		data->lr.roc = pnfs_roc(inode, &data->lr.arg, &data->lr.res,
-				cred);
 		if (data->lr.roc) {
 			data->args.lr_args = &data->lr.arg;
 			data->res.lr_res = &data->lr.res;
 		}
+	} else if (data->lr.roc) {
+		pnfs_roc_release(&data->lr.arg, &data->lr.res, 0);
+		data->lr.roc = false;
 	}
 
 	task_setup_data.callback_data = data;
-- 
2.9.3

