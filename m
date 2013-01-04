Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-da0-f45.google.com ([209.85.210.45]:61480 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751269Ab3ADM3c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jan 2013 07:29:32 -0500
From: ycnian@gmail.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Yanchuan Nian <ycnian@gmail.com>
Subject: [PATCH] pnfs: Increase the refcount when LAYOUTGET fails the first time
Date: Fri,  4 Jan 2013 20:19:49 +0800
Message-Id: <1357301989-10278-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yanchuan Nian <ycnian@gmail.com>

The layout will be set unusable if LAYOUTGET fails. Is it reasonable to
increase the refcount iff LAYOUTGET fails the first time?

Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
---
 fs/nfs/pnfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e7165d9..d00260b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -254,7 +254,7 @@ static void
 pnfs_layout_set_fail_bit(struct pnfs_layout_hdr *lo, int fail_bit)
 {
 	lo->plh_retry_timestamp = jiffies;
-	if (test_and_set_bit(fail_bit, &lo->plh_flags))
+	if (!test_and_set_bit(fail_bit, &lo->plh_flags))
 		atomic_inc(&lo->plh_refcount);
 }
 
-- 
1.7.4.4

