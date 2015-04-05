Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:33987 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbbDEPNf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Apr 2015 11:13:35 -0400
Received: by pdbni2 with SMTP id ni2so19063371pdb.1
        for <linux-nfs@vger.kernel.org>; Sun, 05 Apr 2015 08:13:34 -0700 (PDT)
Message-ID: <55215117.2050504@gmail.com>
Date: Sun, 05 Apr 2015 23:13:27 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>, kinglongmee@gmail.com
Subject: [PATCH] nfsd: clear NFSEXP_PNFS flags if not supports pnfs in kernel
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd should not show "pnfs" flag in proc file if the filesystem
does not support pnfs.

# cat /proc/fs/nfsd/exports
# Version 1.1
# Path Client(Flags) # IPs
/testfs    *(rw,insecure,no_root_squash,sync,wdelay,no_subtree_check,pnfs,fsid=0,uuid=37b07525:dc5e4203:99cc71b0:3df9dfa5,sec=1)


Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4layouts.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 6904213..f4c9bf3 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -125,6 +125,8 @@ void nfsd4_setup_layout_type(struct svc_export *exp)
 	    sb->s_export_op->map_blocks &&
 	    sb->s_export_op->commit_blocks)
 		exp->ex_layout_type = LAYOUT_BLOCK_VOLUME;
+	else
+		exp->ex_flags &= ~NFSEXP_PNFS;
 }
 
 static void
-- 
2.3.4

