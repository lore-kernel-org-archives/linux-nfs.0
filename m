Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:34107 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638AbbGAD6j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Jun 2015 23:58:39 -0400
Received: by pdbep18 with SMTP id ep18so17801687pdb.1
        for <linux-nfs@vger.kernel.org>; Tue, 30 Jun 2015 20:58:38 -0700 (PDT)
Message-ID: <55936567.8000201@gmail.com>
Date: Wed, 01 Jul 2015 11:58:31 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 5/8] nfs: Remove unneeded micro checking of CONFIG_PROC_FS
References: <5593648D.7020804@gmail.com>
In-Reply-To: <5593648D.7020804@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Have checking CONFIG_PROC_FS in include/linux/sunrpc/stats.h.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/inode.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index f734562..d1d2b11 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -2008,17 +2008,15 @@ static int __init init_nfs_fs(void)
 	if (err)
 		goto out1;
 
-#ifdef CONFIG_PROC_FS
 	rpc_proc_register(&init_net, &nfs_rpcstat);
-#endif
-	if ((err = register_nfs_fs()) != 0)
+
+	err = register_nfs_fs();
+	if (err)
 		goto out0;
 
 	return 0;
 out0:
-#ifdef CONFIG_PROC_FS
 	rpc_proc_unregister(&init_net, "nfs");
-#endif
 	nfs_destroy_directcache();
 out1:
 	nfs_destroy_writepagecache();
@@ -2049,9 +2047,7 @@ static void __exit exit_nfs_fs(void)
 	nfs_destroy_nfspagecache();
 	nfs_fscache_unregister();
 	unregister_pernet_subsys(&nfs_net_ops);
-#ifdef CONFIG_PROC_FS
 	rpc_proc_unregister(&init_net, "nfs");
-#endif
 	unregister_nfs_fs();
 	nfs_fs_proc_exit();
 	nfsiod_stop();
-- 
2.4.3

