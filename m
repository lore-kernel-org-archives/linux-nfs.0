Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:34027 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbbHECaA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 22:30:00 -0400
Received: by ioea135 with SMTP id a135so36118644ioe.1
        for <linux-nfs@vger.kernel.org>; Tue, 04 Aug 2015 19:29:59 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/6] NFSv4.1/pnfs: Fix serialisation of layout return and layoutget
Date: Tue,  4 Aug 2015 22:29:52 -0400
Message-Id: <1438741796-22681-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1438741796-22681-1-git-send-email-trond.myklebust@primarydata.com>
References: <1438741796-22681-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We should always test for outstanding layout returns, whether or not
pnfs_should_retry_layoutget() is true.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index aa95544123c5..5280def00bc4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1436,6 +1436,8 @@ static int pnfs_layoutget_retry_bit_wait(struct wait_bit_key *key)
 
 static bool pnfs_prepare_to_retry_layoutget(struct pnfs_layout_hdr *lo)
 {
+	if (!pnfs_should_retry_layoutget(lo))
+		return false;
 	/*
 	 * send layoutcommit as it can hold up layoutreturn due to lseg
 	 * reference
@@ -1531,8 +1533,7 @@ lookup_again:
 	 * Because we free lsegs before sending LAYOUTRETURN, we need to wait
 	 * for LAYOUTRETURN even if first is true.
 	 */
-	if (!lseg && pnfs_should_retry_layoutget(lo) &&
-	    test_bit(NFS_LAYOUT_RETURN, &lo->plh_flags)) {
+	if (test_bit(NFS_LAYOUT_RETURN, &lo->plh_flags)) {
 		spin_unlock(&ino->i_lock);
 		dprintk("%s wait for layoutreturn\n", __func__);
 		if (pnfs_prepare_to_retry_layoutget(lo)) {
-- 
2.4.3

