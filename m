Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-da0-f44.google.com ([209.85.210.44]:59012 "EHLO
	mail-da0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520Ab2LXKVk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Dec 2012 05:21:40 -0500
From: ycnian@gmail.com
To: bfields@fieldses.org
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Yanchuan Nian <ycnian@gmail.com>
Subject: [PATCH] nfsd: Pass correct slot number to nfsd4_put_drc_mem()
Date: Mon, 24 Dec 2012 18:11:27 +0800
Message-Id: <1356343887-11952-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yanchuan Nian <ycnian@gmail.com>

In alloc_session(), numslots is the correct slot number used by the session.
But the slot number passed to nfsd4_put_drc_mem() is the one from nfs client.

Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
---
 fs/nfsd/nfs4state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ac8ed96..29924a0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -905,7 +905,7 @@ static struct nfsd4_session *alloc_session(struct nfsd4_channel_attrs *fchan,
 
 	new = __alloc_session(slotsize, numslots);
 	if (!new) {
-		nfsd4_put_drc_mem(slotsize, fchan->maxreqs);
+		nfsd4_put_drc_mem(slotsize, numslots);
 		return NULL;
 	}
 	init_forechannel_attrs(&new->se_fchannel, fchan, numslots, slotsize, nn);
-- 
1.7.4.4

