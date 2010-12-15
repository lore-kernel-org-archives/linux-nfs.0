Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47269 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810Ab0LOSbt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Dec 2010 13:31:49 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/9] FIXME: roc should return layout on last close
Date: Wed, 15 Dec 2010 20:31:47 +0200
Message-Id: <1292437907-21823-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4D0908F9.4060208@panasas.com>
References: <4D0908F9.4060208@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

rather than on any close.
---
 fs/nfs/nfs4state.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 6a1eb41..dc62928 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -622,6 +622,7 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state,
 		u32 roc_iomode;
 		struct nfs_inode *nfsi = NFS_I(state->inode);
 
+		/* FIXME: should return the layout only on last close */
 		if (has_layout(nfsi) &&
 		    (roc_iomode = pnfs_layout_roc_iomode(nfsi)) != 0) {
 			struct pnfs_layout_range range = {
-- 
1.7.2.3

