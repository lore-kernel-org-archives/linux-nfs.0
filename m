Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:64077 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968091Ab2ERWGS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2012 18:06:18 -0400
Received: by yenm10 with SMTP id m10so3324481yen.19
        for <linux-nfs@vger.kernel.org>; Fri, 18 May 2012 15:06:17 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/14] NFS: Don't swap bytes in nfs4_construct_boot_verifier()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 18 May 2012 18:06:16 -0400
Message-ID: <20120518220615.774.43776.stgit@degas.1015granger.net>
In-Reply-To: <20120518220145.774.53741.stgit@degas.1015granger.net>
References: <20120518220145.774.53741.stgit@degas.1015granger.net>
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
index db7b76a..73cfd9e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3937,8 +3937,8 @@ static void nfs4_construct_boot_verifier(struct nfs_client *clp,
 {
 	__be32 verf[2];
 
-	verf[0] = htonl((u32)clp->cl_boot_time.tv_sec);
-	verf[1] = htonl((u32)clp->cl_boot_time.tv_nsec);
+	verf[0] = (__be32)clp->cl_boot_time.tv_sec;
+	verf[1] = (__be32)clp->cl_boot_time.tv_nsec;
 	memcpy(bootverf->data, verf, sizeof(bootverf->data));
 }
 

