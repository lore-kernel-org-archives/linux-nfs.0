Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:34048 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751646AbbHECaC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 22:30:02 -0400
Received: by ioea135 with SMTP id a135so36119216ioe.1
        for <linux-nfs@vger.kernel.org>; Tue, 04 Aug 2015 19:30:01 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/6] NFSv4.1/pnfs: Remove redundant lo->plh_block_lgets in layoutreturn
Date: Tue,  4 Aug 2015 22:29:54 -0400
Message-Id: <1438741796-22681-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1438741796-22681-3-git-send-email-trond.myklebust@primarydata.com>
References: <1438741796-22681-1-git-send-email-trond.myklebust@primarydata.com>
 <1438741796-22681-2-git-send-email-trond.myklebust@primarydata.com>
 <1438741796-22681-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFS_LAYOUT_RETURN bit already suffices to ensure that layoutget
is blocked.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9147dcaeb546..0c6aa13525e4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -368,7 +368,6 @@ pnfs_prepare_layoutreturn(struct pnfs_layout_hdr *lo)
 	if (test_and_set_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
 		return false;
 	lo->plh_return_iomode = 0;
-	lo->plh_block_lgets++;
 	pnfs_get_layout_hdr(lo);
 	clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE, &lo->plh_flags);
 	return true;
@@ -954,7 +953,6 @@ pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
 	if (unlikely(lrp == NULL)) {
 		status = -ENOMEM;
 		spin_lock(&ino->i_lock);
-		lo->plh_block_lgets--;
 		pnfs_clear_layoutreturn_waitbit(lo);
 		rpc_wake_up(&NFS_SERVER(ino)->roc_rpcwaitq);
 		spin_unlock(&ino->i_lock);
-- 
2.4.3

