Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:55958 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751851Ab2GIPo2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jul 2012 11:44:28 -0400
Received: by mail-yx0-f174.google.com with SMTP id l2so10189699yen.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jul 2012 08:44:28 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/14] NFS: nfs_getaclargs.acl_len is a size_t
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 09 Jul 2012 11:44:26 -0400
Message-ID: <20120709154426.1604.72252.stgit@degas.1015granger.net>
In-Reply-To: <20120709153355.1604.14102.stgit@degas.1015granger.net>
References: <20120709153355.1604.14102.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Squelch compiler warnings:

fs/nfs/nfs4proc.c: In function ‘__nfs4_get_acl_uncached’:
fs/nfs/nfs4proc.c:3811:14: warning: comparison between signed and
	unsigned integer expressions [-Wsign-compare]
fs/nfs/nfs4proc.c:3818:15: warning: comparison between signed and
	unsigned integer expressions [-Wsign-compare]

Introduced by commit bf118a34 "NFSv4: include bitmap in nfsv4 get
acl data", Dec 7, 2011.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f368e37..7adb705 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3792,7 +3792,8 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
-	int ret = -ENOMEM, npages, i, acl_len = 0;
+	int ret = -ENOMEM, npages, i;
+	size_t acl_len = 0;
 
 	npages = (buflen + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	/* As long as we're doing a round trip to the server anyway,

