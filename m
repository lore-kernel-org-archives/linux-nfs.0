Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f52.google.com ([74.125.82.52]:50094 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755838Ab3EKCo6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:44:58 -0400
Received: by mail-wg0-f52.google.com with SMTP id k13so4504891wgh.31
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:44:57 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id cw8sm1191619wib.7.2013.05.10.19.44.55
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:44:55 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 38/38] pnfsd: remove clientid member from struct nfsd4_layout_seg
Date: Sat, 11 May 2013 05:44:51 +0300
Message-Id: <1368240291-1204-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use layout stateid for identification instead.

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4proc.c              | 2 --
 include/linux/nfsd/nfsd4_pnfs.h | 1 -
 2 files changed, 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index cd52393..5bbd1a3 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1243,8 +1243,6 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 		__func__, lcp->args.lc_newoffset, lcp->args.lc_last_wr + 1,
 		ino->i_size);
 
-	/* Set clientid from sessionid */
-	copy_clientid((clientid_t *)&lcp->args.lc_seg.clientid, cstate->session);
 	lcp->res.lc_size_chg = 0;
 	if (sb->s_pnfs_op->layout_commit) {
 		status = sb->s_pnfs_op->layout_commit(ino, &lcp->args, &lcp->res);
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index 2e09065..fd7bad9 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -59,7 +59,6 @@ struct nfsd4_pnfs_dev_iter_res {
 };
 
 struct nfsd4_layout_seg {
-	u64	clientid;
 	u32	layout_type;
 	u32	iomode;
 	u64	offset;
-- 
1.7.11.7

