Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f176.google.com ([74.125.82.176]:55703 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754337Ab3EKCms (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:42:48 -0400
Received: by mail-we0-f176.google.com with SMTP id p60so4656008wes.35
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:42:47 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id dj7sm1198432wib.6.2013.05.10.19.42.46
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:42:47 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 04/38] pnfsd-lexp: remove get_state
Date: Sat, 11 May 2013 05:42:42 +0300
Message-Id: <1368240162-31872-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/pnfsd_lexp.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/fs/nfsd/pnfsd_lexp.c b/fs/nfsd/pnfsd_lexp.c
index bcdb80f..5d448c2 100644
--- a/fs/nfsd/pnfsd_lexp.c
+++ b/fs/nfsd/pnfsd_lexp.c
@@ -223,12 +223,6 @@ static int get_stripe_unit(int blocksize)
 	return 0;
 }
 
-static int pnfsd_lexp_get_state(struct inode *inode, struct knfsd_fh *fh,
-				struct pnfs_get_state *p)
-{
-	return 0;	/* just use the current stateid */
-}
-
 static struct pnfs_export_operations pnfsd_lexp_ops = {
 	.layout_type = pnfsd_lexp_layout_type,
 	.get_device_info = pnfsd_lexp_get_device_info,
@@ -236,7 +230,6 @@ static int pnfsd_lexp_get_state(struct inode *inode, struct knfsd_fh *fh,
 	.layout_get = pnfsd_lexp_layout_get,
 	.layout_commit = pnfsd_lexp_layout_commit,
 	.layout_return = pnfsd_lexp_layout_return,
-	.get_state = pnfsd_lexp_get_state,
 };
 
 void
-- 
1.7.11.7

