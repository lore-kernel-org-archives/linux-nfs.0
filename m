Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:49336 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754700Ab0IJUDX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 16:03:23 -0400
Received: by mail-gy0-f174.google.com with SMTP id 8so1363332gyd.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 13:03:23 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/6] NFS: Remove \t from mount debugging message
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 10 Sep 2010 16:03:20 -0400
Message-ID: <20100910200320.13167.41148.stgit@seurat.1015granger.net>
In-Reply-To: <20100910200001.13167.61153.stgit@seurat.1015granger.net>
References: <20100910200001.13167.61153.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

During boot, a random character is displayed instead of a tab.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/mount_clnt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 59047f8..d610203 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -436,7 +436,7 @@ static int decode_auth_flavors(struct xdr_stream *xdr, struct mountres *res)
 
 	for (i = 0; i < entries; i++) {
 		flavors[i] = ntohl(*p++);
-		dprintk("NFS:\tflavor %u: %d\n", i, flavors[i]);
+		dprintk("NFS:   auth flavor[%u]: %d\n", i, flavors[i]);
 	}
 	*count = i;
 

