Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:34711 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750704Ab1KABhX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 21:37:23 -0400
Date: Mon, 31 Oct 2011 21:37:20 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] Silence compiler warning
Message-ID: <20111101013720.GA4237@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I think this is still needed, isn't it?  I haven't tried compiling
nfs-for-next but I don't see a fix for it in there.

From: Jim Rees <rees@umich.edu>
Date: Sun, 16 Oct 2011 20:06:52 -0400
Subject: [PATCH] Silence compiler warning

fs/nfs/callback_proc.c: In function ‘do_callback_layoutrecall’:
fs/nfs/callback_proc.c:115:26: warning: ‘lo’ may be used uninitialized in this function

No functional change. If no layout is found, we'll return before  using
"lo".

Signed-off-by: Jim Rees <rees@umich.edu>
---
 fs/nfs/callback_proc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 43926ad..f384eb1 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -112,8 +112,8 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 				  struct cb_layoutrecallargs *args)
 {
 	struct nfs_server *server;
-	struct pnfs_layout_hdr *lo;
-	struct inode *ino;
+	struct pnfs_layout_hdr *lo = NULL;
+	struct inode *ino = NULL;
 	bool found = false;
 	u32 rv = NFS4ERR_NOMATCHING_LAYOUT;
 	LIST_HEAD(free_me_list);
-- 
1.7.4.1
