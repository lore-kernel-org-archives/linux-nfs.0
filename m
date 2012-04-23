Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43242 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755172Ab2DWUyL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 16:54:11 -0400
Received: by mail-iy0-f174.google.com with SMTP id i9so2498807iad.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 13:54:11 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/20] NFS: Don't swap bytes in nfs4_construct_boot_verifier()
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Apr 2012 16:54:09 -0400
Message-ID: <20120423205409.11446.23766.stgit@degas.1015granger.net>
In-Reply-To: <20120423205312.11446.67081.stgit@degas.1015granger.net>
References: <20120423205312.11446.67081.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The SETCLIENTID boot verifier is opaque to NFSv4 servers, thus there
is no requirement for byte swapping before the client puts the
verifier on the wire.

This treatment is similar to other timestamp-based verifiers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0af657d..6ae0c14 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3880,8 +3880,8 @@ static void nfs4_construct_boot_verifier(struct nfs_client *clp,
 {
 	__be32 verf[2];
 
-	verf[0] = htonl((u32)clp->cl_boot_time.tv_sec);
-	verf[1] = htonl((u32)clp->cl_boot_time.tv_nsec);
+	verf[0] = (__be32)clp->cl_boot_time.tv_sec;
+	verf[1] = (__be32)clp->cl_boot_time.tv_nsec;
 	memcpy(bootverf->data, verf, sizeof(bootverf->data));
 }
 

