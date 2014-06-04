Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f181.google.com ([209.85.192.181]:58467 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751413AbaFDWgT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2014 18:36:19 -0400
Received: by mail-pd0-f181.google.com with SMTP id z10so140508pdj.26
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jun 2014 15:36:18 -0700 (PDT)
From: Thomas Haynes <thomas.haynes@primarydata.com>
To: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Cc: Tom Haynes <Thomas.Haynes@primarydata.com>
Subject: [PATCH] Comment is now wrong and redundant to code
Date: Wed,  4 Jun 2014 15:36:05 -0700
Message-Id: <1401921365-22956-1-git-send-email-Thomas.Haynes@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Haynes <Thomas.Haynes@primarydata.com>

The save of the write offset was removed some time ago, so that
part of the comment is bogus.

The remainder is pretty self-evident.

So off with it!

This is based off of trond/testing

Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/filelayout/filelayout.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 7d479fd..b04ae035 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -608,10 +608,7 @@ filelayout_write_pagelist(struct nfs_pgio_data *data, int sync)
 	fh = nfs4_fl_select_ds_fh(lseg, j);
 	if (fh)
 		data->args.fh = fh;
-	/*
-	 * Get the file offset on the dserver. Set the write offset to
-	 * this offset and save the original offset.
-	 */
+
 	data->args.offset = filelayout_get_dserver_offset(lseg, offset);
 
 	/* Perform an asynchronous write */
-- 
1.9.3

