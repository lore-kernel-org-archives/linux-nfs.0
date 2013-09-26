Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:53573 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752967Ab3IZSnS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:43:18 -0400
Received: by mail-qa0-f46.google.com with SMTP id j7so4585403qaq.5
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:43:17 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 49/49] pnfsd: dlm set return_on_close to true
Date: Thu, 26 Sep 2013 14:43:15 -0400
Message-Id: <1380220995-14943-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The client may hold a layout post CLOSE essentially forever,
requiring the server to remember that.

However, since we keep track of the layout state by hanging it on the
respective file and client structures, when the file goes away we lose
track of the layout therefore we need to set return_on_close to true.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsdlm.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index de1af22..093d836 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -406,6 +406,8 @@ static enum nfsstat4 nfsd4_pnfs_dlm_layoutget(struct inode *inode,
 	res->lg_seg.length = NFS4_MAX_UINT64;
 	/* Always give out READ ONLY layouts */
 	res->lg_seg.iomode = IOMODE_READ;
+	/* Set return_on_close to true until we track layout state post CLOSE */
+	res->lg_return_on_close = 1;
 
 	layout = kzalloc(sizeof(*layout), GFP_KERNEL);
 	if (layout == NULL) {
-- 
1.8.3.1

