Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:55238 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752887Ab0EMIkO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 May 2010 04:40:14 -0400
Received: by wwi18 with SMTP id 18so667428wwi.19
        for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 01:40:12 -0700 (PDT)
Message-ID: <4BEBBAE9.8090605@panasas.com>
Date: Thu, 13 May 2010 11:40:09 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: SQUASHME: missing from FIXME: async layout return
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've tested the patch:
	FIXME: async layout return

And there is a missing small hunk

I have tested with this patch and it is a very good patch
that should also go into 2.6.33. It is necessary in the rare
case when one inode have more then one open_context.

(For some reason I see that happening much more in 2.6.34
 I don't understand why)

Boaz
---
git diff --stat -p -M
 fs/nfs/nfs4state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 15c8bc8..6dbe893 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -590,7 +590,7 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state, fmode_t fm
 		struct nfs_inode *nfsi = NFS_I(state->inode);
 
 		if (nfsi->layoutcommit_ctx)
-			pnfs_layoutcommit_inode(state->inode, 0);
+			pnfs_layoutcommit_inode(state->inode, wait);
 		if (has_layout(nfsi) && nfsi->layout.roc_iomode) {
 			struct nfs4_pnfs_layout_segment range;
 
