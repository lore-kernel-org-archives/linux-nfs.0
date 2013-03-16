Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f177.google.com ([209.85.210.177]:38591 "EHLO
	mail-ia0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439Ab3CPTzi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Mar 2013 15:55:38 -0400
Received: by mail-ia0-f177.google.com with SMTP id y25so4186274iay.22
        for <linux-nfs@vger.kernel.org>; Sat, 16 Mar 2013 12:55:38 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 10/15] NFS: Handle missing rpc.gssd when looking up root FH
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>,
        Bryan Schumaker <bjschuma@netapp.com>
Date: Sat, 16 Mar 2013 15:55:36 -0400
Message-ID: <20130316195536.27329.83797.stgit@seurat.1015granger.net>
In-Reply-To: <20130316195044.27329.11666.stgit@seurat.1015granger.net>
References: <20130316195044.27329.11666.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When rpc.gssd is not running, any NFS operation that needs to use a
GSS security flavor of course does not work.

If looking up a server's root file handle results in an
NFS4ERR_WRONGSEC, nfs4_find_root_sec() is called to try a bunch of
security flavors until one works or all reasonable flavors have
been tried.  When rpc.gssd isn't running, this loop seems to fail
immediately after rpcauth_create() craps out on the first GSS
flavor.

When the rpcauth_create() call in nfs4_lookup_root_sec() fails
because rpc.gssd is not available, nfs4_lookup_root_sec()
unconditionally returns -EIO.  This prevents nfs4_find_root_sec()
from retrying any other flavors; it drops out of its loop and fails
immediately.

Having nfs4_lookup_root_sec() return -EACCES instead allows
nfs4_find_root_sec() to try all flavors in its list.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>
---

 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b2671cb..c05e78b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2443,7 +2443,7 @@ static int nfs4_lookup_root_sec(struct nfs_server *server, struct nfs_fh *fhandl
 
 	auth = rpcauth_create(flavor, server->client);
 	if (IS_ERR(auth)) {
-		ret = -EIO;
+		ret = -EACCES;
 		goto out;
 	}
 	ret = nfs4_lookup_root(server, fhandle, info);

