From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/2] SQUASHME: pnfs-submit: check has_layout in __nfs4_close
Date: Mon, 12 Jul 2010 21:39:59 +0300
Message-ID: <1278959999-32180-1-git-send-email-bhalevy@panasas.com>
References: <4C3B611C.1000208@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:63870 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751102Ab0GLSkL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 14:40:11 -0400
In-Reply-To: <4C3B611C.1000208@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pnfs_layout_roc_iomode may hit NULL deref if layout is NULL.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4state.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 8734688..724a963 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -594,8 +594,11 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state,
 		nfs4_put_open_state(state);
 		nfs4_put_state_owner(owner);
 	} else {
-		u32 roc_iomode = pnfs_layout_roc_iomode(NFS_I(state->inode));
-		if (roc_iomode) {
+		u32 roc_iomode;
+		struct nfs_inode *nfsi = NFS_I(state->inode);
+
+		if (has_layout(nfsi) &&
+		    (roc_iomode = pnfs_layout_roc_iomode(nfsi)) != 0) {
 			struct nfs4_pnfs_layout_segment range = {
 				.iomode = roc_iomode,
 				.offset = 0,
-- 
1.7.1.1

