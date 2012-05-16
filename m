Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61378 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965021Ab2EPIfo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 May 2012 04:35:44 -0400
Received: by bkcji2 with SMTP id ji2so344053bkc.19
        for <linux-nfs@vger.kernel.org>; Wed, 16 May 2012 01:35:41 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH] NFS: fix unsigned comparison in nfs4_create_sec_client
Date: Wed, 16 May 2012 11:35:36 +0300
Message-Id: <1337157336-24174-1-git-send-email-bhalevy@tonian.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fs/nfs/nfs4namespace.c: In function ‘nfs4_create_sec_client’:
fs/nfs/nfs4namespace.c:171:2: error: comparison of unsigned expression < 0 is always false [-Werror=type-limits]

Introduced by commit 72de53ec4bca39c26709122a8f78bfefe7b6bca4
"NFS: Do secinfo as part of lookup"

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/nfs4namespace.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index a7f3ded..3f5519b 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -168,7 +168,7 @@ struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *clnt, struct inode *ino
 	rpc_authflavor_t flavor;
 
 	flavor = nfs4_negotiate_security(inode, name);
-	if (flavor < 0)
+	if ((int)flavor < 0)
 		return ERR_PTR(flavor);
 
 	clone = rpc_clone_client(clnt);
-- 
1.7.6.5

