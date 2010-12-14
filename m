Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:42836 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756678Ab0LNO6x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 09:58:53 -0500
Received: by iyi12 with SMTP id 12so349341iyi.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 06:58:53 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 27/31] NFS: Remove unused UMNT response data structure
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 09:58:49 -0500
Message-ID: <20101214145849.2293.99438.stgit@matisse.1015granger.net>
In-Reply-To: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

The UMNT request has a NULL response.  There's no need to set up a
mountres structure for it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/mount_clnt.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index c82547e..97c3ec7 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -236,10 +236,8 @@ void nfs_umount(const struct nfs_mount_request *info)
 		.authflavor	= RPC_AUTH_UNIX,
 		.flags		= RPC_CLNT_CREATE_NOPING,
 	};
-	struct mountres	result;
 	struct rpc_message msg	= {
 		.rpc_argp	= info->dirpath,
-		.rpc_resp	= &result,
 	};
 	struct rpc_clnt *clnt;
 	int status;

