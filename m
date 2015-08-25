Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33005 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753280AbbHYQNj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 12:13:39 -0400
Received: by pacti10 with SMTP id ti10so55499875pac.0
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 09:13:38 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 2/2] nfs42: remove unused declaration
Date: Wed, 26 Aug 2015 00:13:16 +0800
Message-Id: <1440519196-116456-3-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1440519196-116456-1-git-send-email-tao.peng@primarydata.com>
References: <1440519196-116456-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reviewed-by: Christoph Hellwig <hch@lst.de>
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

