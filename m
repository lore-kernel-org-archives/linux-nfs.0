Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35324 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947486AbdDTVWi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Apr 2017 17:22:38 -0400
Received: by mail-io0-f195.google.com with SMTP id d203so21020074iof.2
        for <linux-nfs@vger.kernel.org>; Thu, 20 Apr 2017 14:22:37 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] pNFS: unexport nfs4_pnfs_v3_ds_connect_unload
Date: Thu, 20 Apr 2017 17:22:32 -0400
Message-Id: <20170420212232.88086-4-trond.myklebust@primarydata.com>
In-Reply-To: <20170420212232.88086-3-trond.myklebust@primarydata.com>
References: <20170420212232.88086-1-trond.myklebust@primarydata.com>
 <20170420212232.88086-2-trond.myklebust@primarydata.com>
 <20170420212232.88086-3-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is not used outside the NFSv4 module.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs_nfs.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 1edf5b84aba5..dc4111d08a27 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -613,7 +613,6 @@ void nfs4_pnfs_v3_ds_connect_unload(void)
 		get_v3_ds_connect = NULL;
 	}
 }
-EXPORT_SYMBOL_GPL(nfs4_pnfs_v3_ds_connect_unload);
 
 static int _nfs4_pnfs_v3_ds_connect(struct nfs_server *mds_srv,
 				 struct nfs4_pnfs_ds *ds,
-- 
2.9.3

