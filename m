Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37546 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755645Ab0J1GGH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 02:06:07 -0400
Date: Thu, 28 Oct 2010 08:05:57 +0200
From: Dan Carpenter <error27@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [patch] nfs: testing the wrong variable
Message-ID: <20101028060557.GY6062@bicker>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The intent was to test "*desc" for allocation failures, but it tests
"desc" which is always a valid pointer here.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index dec47ed..4e2d9b6 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -123,7 +123,7 @@ static ssize_t nfs_idmap_get_desc(const char *name, size_t namelen,
 	size_t desclen = typelen + namelen + 2;
 
 	*desc = kmalloc(desclen, GFP_KERNEL);
-	if (!desc)
+	if (!*desc)
 		return -ENOMEM;
 
 	cp = *desc;
