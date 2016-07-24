Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34636 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751891AbcGXVhW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jul 2016 17:37:22 -0400
Received: by mail-io0-f193.google.com with SMTP id g86so10767292ioj.1
        for <linux-nfs@vger.kernel.org>; Sun, 24 Jul 2016 14:37:21 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] =?UTF-8?q?NFSv4:=20Fix=20warning=20"no=20previous=20proto?= =?UTF-8?q?type=20for=20=E2=80=98nfs4=5Flistxattr=E2=80=99"?=
Date: Sun, 24 Jul 2016 17:36:56 -0400
Message-Id: <1469396218-85598-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make it static

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d30f88c667b7..4b1491da16eb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8848,7 +8848,7 @@ const struct nfs4_minor_version_ops *nfs_v4_minor_ops[] = {
 #endif
 };
 
-ssize_t nfs4_listxattr(struct dentry *dentry, char *list, size_t size)
+static ssize_t nfs4_listxattr(struct dentry *dentry, char *list, size_t size)
 {
 	ssize_t error, error2;
 
-- 
2.7.4

