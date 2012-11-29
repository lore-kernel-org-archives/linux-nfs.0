Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:56014 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752132Ab2K2GbF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2012 01:31:05 -0500
From: Abhijit Pawar <abhi.c.pawar@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Abhijit Pawar <abhi.c.pawar@gmail.com>
Subject: [PATCH 5/6] fs:nfs pass NULL as second parameter for set_anon_super
Date: Thu, 29 Nov 2012 12:00:46 +0530
Message-Id: <1354170646-12144-1-git-send-email-abhi.c.pawar@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

set_anon_super does not use the second parameter in its implementation.
So there is no need to pass on the second parameter.

Signed-off-by: Abhijit Pawar <abhi.c.pawar@gmail.com>
---
 fs/nfs/super.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index e12cea4..c8bdd86 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2310,7 +2310,7 @@ static int nfs_set_super(struct super_block *s, void *data)
 	s->s_flags = sb_mntdata->mntflags;
 	s->s_fs_info = server;
 	s->s_d_op = server->nfs_client->rpc_ops->dentry_ops;
-	ret = set_anon_super(s, server);
+	ret = set_anon_super(s, NULL);
 	if (ret == 0)
 		server->s_dev = s->s_dev;
 	return ret;
-- 
1.7.7.6

