Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35253 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426Ab2LMGsG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Dec 2012 01:48:06 -0500
From: ycnian@gmail.com
To: Trond.Myklebust@netapp.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Yanchuan Nian <ycnian@gmail.com>
Subject: [PATCH] nfs: Remove unused list nfs4_clientid_list
Date: Thu, 13 Dec 2012 14:37:52 +0800
Message-Id: <1355380672-10982-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yanchuan Nian <ycnian@gmail.com>

This list was designed to store struct nfs4_client in the client side.
But nfs4_client was obsolete and has been removed from the source code. 
So remove the unused list.

Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
---
 fs/nfs/nfs4state.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index c351e6b..51c9b0b 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -66,7 +66,6 @@
 
 const nfs4_stateid zero_stateid;
 static DEFINE_MUTEX(nfs_clid_init_mutex);
-static LIST_HEAD(nfs4_clientid_list);
 
 int nfs4_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 {
-- 
1.7.4.4

