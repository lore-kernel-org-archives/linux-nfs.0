Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og111.obsmtp.com ([64.18.0.22]:58755 "HELO
	exprod5og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754760Ab0J0SYY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Oct 2010 14:24:24 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] SQUASHME: pnfs: filelayout: print_ds should use dprintk
Date: Wed, 27 Oct 2010 20:24:20 +0200
Message-Id: <1288203860-26920-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CC86D96.8020803@panasas.com>
References: <4CC86D96.8020803@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

rather than printk to prevent printouts in non-debug mode
currently happening in filelayout_commit

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4filelayoutdev.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 1f0ab62..de47112 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -53,10 +53,10 @@ void
 print_ds(struct nfs4_pnfs_ds *ds)
 {
 	if (ds == NULL) {
-		printk("%s NULL device\n", __func__);
+		dprintk("%s NULL device\n", __func__);
 		return;
 	}
-	printk("        ip_addr %x port %hu\n"
+	dprintk("        ip_addr %x port %hu\n"
 		"        ref count %d\n"
 		"        client %p\n"
 		"        cl_exchange_flags %x\n",
@@ -71,7 +71,7 @@ print_ds_list(struct nfs4_file_layout_dsaddr *dsaddr)
 	int i;
 
 	ifdebug(FACILITY) {
-		printk("%s dsaddr->ds_num %d\n", __func__,
+		dprintk("%s dsaddr->ds_num %d\n", __func__,
 		       dsaddr->ds_num);
 		for (i = 0; i < dsaddr->ds_num; i++)
 			print_ds(dsaddr->ds_list[i]);
@@ -211,8 +211,7 @@ static void
 destroy_ds(struct nfs4_pnfs_ds *ds)
 {
 	dprintk("--> %s\n", __func__);
-	ifdebug(FACILITY)
-		print_ds(ds);
+	print_ds(ds);
 
 	if (ds->ds_clp)
 		nfs_put_client(ds->ds_clp);
-- 
1.7.2.3

