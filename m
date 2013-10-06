Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f48.google.com ([74.125.83.48]:65248 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373Ab3JFHo2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Oct 2013 03:44:28 -0400
Received: by mail-ee0-f48.google.com with SMTP id l10so2583290eei.35
        for <linux-nfs@vger.kernel.org>; Sun, 06 Oct 2013 00:44:27 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] SQUASHME: fix lo_destroy_list nested definition
Date: Sun,  6 Oct 2013 10:44:23 +0300
Message-Id: <1381045463-30621-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <5251140B.4000203@primarydata.com>
References: <5251140B.4000203@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsd.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 95a27ec..a9e535f 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -1223,8 +1223,6 @@ int nfs4_pnfs_return_layout(struct svc_rqst *rqstp,
 		goto out_unlock;
 
 	if (lrp->args.lr_return_type == RETURN_FILE) {
-		LIST_HEAD(lo_destroy_list);
-
 		fp = find_file(ino);
 		if (!fp) {
 			dprintk("%s: RETURN_FILE: no nfs4_file for ino %p:%lu\n",
-- 
1.8.3.1

