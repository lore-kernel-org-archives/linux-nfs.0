Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:57358 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757082Ab2EVCpS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 May 2012 22:45:18 -0400
Received: by mail-yw0-f46.google.com with SMTP id m54so5053606yhm.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 May 2012 19:45:17 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/14] NFS: Don't swap bytes in nfs4_construct_boot_verifier()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 21 May 2012 22:45:16 -0400
Message-ID: <20120522024516.1787.23068.stgit@degas.1015granger.net>
In-Reply-To: <20120522022702.1787.45940.stgit@degas.1015granger.net>
References: <20120522022702.1787.45940.stgit@degas.1015granger.net>
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
index 0b9b55c..ab6b2e5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3908,8 +3908,8 @@ static void nfs4_construct_boot_verifier(struct nfs_client *clp,
 {
 	__be32 verf[2];
 
-	verf[0] = htonl((u32)clp->cl_boot_time.tv_sec);
-	verf[1] = htonl((u32)clp->cl_boot_time.tv_nsec);
+	verf[0] = (__be32)clp->cl_boot_time.tv_sec;
+	verf[1] = (__be32)clp->cl_boot_time.tv_nsec;
 	memcpy(bootverf->data, verf, sizeof(bootverf->data));
 }
 

