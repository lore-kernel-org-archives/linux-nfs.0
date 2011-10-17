Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:38504 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752999Ab1JQAG5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 Oct 2011 20:06:57 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@tonian.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] Silence compiler warning
Date: Sun, 16 Oct 2011 20:06:52 -0400
Message-Id: <1318810012-15140-1-git-send-email-rees@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fs/nfs/callback_proc.c: In function ‘do_callback_layoutrecall’:
fs/nfs/callback_proc.c:115:26: warning: ‘lo’ may be used uninitialized in this function

No functional change. If no layout is found, we'll return before  using
"lo".

Signed-off-by: Jim Rees <rees@umich.edu>
---
 fs/nfs/callback_proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 43926ad..93633f1 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -112,7 +112,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 				  struct cb_layoutrecallargs *args)
 {
 	struct nfs_server *server;
-	struct pnfs_layout_hdr *lo;
+	struct pnfs_layout_hdr *lo = NULL;
 	struct inode *ino;
 	bool found = false;
 	u32 rv = NFS4ERR_NOMATCHING_LAYOUT;
-- 
1.7.4.1

