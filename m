Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34607 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376Ab1LEIOl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2011 03:14:41 -0500
Received: by mail-bw0-f46.google.com with SMTP id zv3so1472947bkb.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Dec 2011 00:14:41 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/10] efi: fix compiler warnings
Date: Mon,  5 Dec 2011 10:14:35 +0200
Message-Id: <1323072875-18579-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDC7C4E.1040901@tonian.com>
References: <4EDC7C4E.1040901@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 efi.c |   10 +---------
 1 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/efi.c b/efi.c
index 67b6211..a8c70d2 100644
--- a/efi.c
+++ b/efi.c
@@ -123,8 +123,6 @@
 static size_t
 read_lba(int fd, u64 lba, u8 * buffer, size_t count)
 {
-	size_t totalreadcount = 0;
-
 	lseek(fd, lba * 512LL, 0);
 	return read(fd, buffer, count);
 }
@@ -205,9 +203,6 @@ static int
 is_gpt_valid(int fd, u64 lba,
 	     gpt_header **gpt, gpt_entry **ptes)
 {
-	u32 crc, origcrc;
-	u64 lastlba;
-
 	if (!(*gpt = alloc_read_gpt_header(fd, lba)))
 		return 0;
 
@@ -236,9 +231,6 @@ is_gpt_valid(int fd, u64 lba,
 	/* We're done, all's well */
 	return 1;
 
- fail_ptes:
-	free(*ptes);
-	*ptes = NULL;
  fail:
 	free(*gpt);
 	*gpt = NULL;
@@ -284,7 +276,7 @@ efi_signature(int fd, struct partition_sig *sig)
         gpt_entry       *ptes   = NULL;
         int             rval    = 0;
 
-        sig->ps_sector_off = (u32)&((gpt_header *)0)->disk_guid.b[0];
+        sig->ps_sector_off = __builtin_offsetof(gpt_header, disk_guid.b);
         sig->ps_sector = GPT_PRIMARY_PARTITION_TABLE_LBA;
         sig->ps_len = sizeof (efi_guid_t);
 
-- 
1.7.6

