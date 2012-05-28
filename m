Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:39019 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214Ab2E1QJe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 12:09:34 -0400
Received: by wibhn6 with SMTP id hn6so1859146wib.1
        for <linux-nfs@vger.kernel.org>; Mon, 28 May 2012 09:09:32 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] SQUASHME: pnfsd: use LR_FLAG_INTERN for pnfsd_roc implicit layout return
Date: Mon, 28 May 2012 19:09:29 +0300
Message-Id: <1338221369-22515-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <4FC3A235.8090908@tonian.com>
References: <4FC3A235.8090908@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The client is not expired in the case, but rather we internally simulate
a layout return based on return_on_close.

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index a95e96e..cfaac56 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -1246,7 +1246,7 @@ void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp)
 
 		empty = list_empty(&fp->fi_layouts);
 		fs_layout_return(fp->fi_inode->i_sb, fp->fi_inode, &lr,
-				 LR_FLAG_EXPIRE,
+				 LR_FLAG_INTERN,
 				 empty ? PNFS_LAST_LAYOUT_NO_RECALLS : NULL);
 	}
 	spin_unlock(&layout_lock);
-- 
1.7.6.5

