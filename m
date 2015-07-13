Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36595 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038AbbGMFv0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 01:51:26 -0400
Received: by pachj5 with SMTP id hj5so26055964pac.3
        for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2015 22:51:26 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 2/7] nfs42: remove unused declaration
Date: Mon, 13 Jul 2015 13:50:50 +0800
Message-Id: <1436766655-10696-3-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1436766655-10696-1-git-send-email-tao.peng@primarydata.com>
References: <1436766655-10696-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs42.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
index ff66ae7..814c125 100644
--- a/fs/nfs/nfs42.h
+++ b/fs/nfs/nfs42.h
@@ -17,7 +17,5 @@ int nfs42_proc_deallocate(struct file *, loff_t, loff_t);
 loff_t nfs42_proc_llseek(struct file *, loff_t, int);
 int nfs42_proc_layoutstats_generic(struct nfs_server *,
 				   struct nfs42_layoutstat_data *);
-/* nfs4.2xdr.h */
-extern struct rpc_procinfo nfs4_2_procedures[];
 
 #endif /* __LINUX_FS_NFS_NFS4_2_H */
-- 
1.8.3.1

