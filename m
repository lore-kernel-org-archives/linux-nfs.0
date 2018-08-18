Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ed1-f67.google.com ([209.85.208.67]:45620 "EHLO
        mail-ed1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726443AbeHRQcb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Aug 2018 12:32:31 -0400
Received: by mail-ed1-f67.google.com with SMTP id s16-v6so5972470edq.12
        for <linux-nfs@vger.kernel.org>; Sat, 18 Aug 2018 06:24:48 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
        Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH v2 5/8] nfsd: use seq_open_data() in exports_net_open()
Date: Sat, 18 Aug 2018 15:24:31 +0200
Message-Id: <20180818132434.9515-5-linux@rasmusvillemoes.dk>
In-Reply-To: <20180818132434.9515-1-linux@rasmusvillemoes.dk>
References: <20180818132434.9515-1-linux@rasmusvillemoes.dk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using the seq_open_data() helper, exports_net_open() essentially becomes
a oneliner.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
Depends on 1/8 introducing seq_open_data.

fs/nfsd/nfsctl.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index d107b4426f7e..483a849b9ce1 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -135,17 +135,9 @@ static const struct file_operations transaction_ops = {
 
 static int exports_net_open(struct net *net, struct file *file)
 {
-	int err;
-	struct seq_file *seq;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
-	err = seq_open(file, &nfs_exports_op);
-	if (err)
-		return err;
-
-	seq = file->private_data;
-	seq->private = nn->svc_export_cache;
-	return 0;
+	return seq_open_data(file, &nfs_exports_op, nn->svc_export_cache);
 }
 
 static int exports_proc_open(struct inode *inode, struct file *file)
-- 
2.16.4
