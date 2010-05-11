From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/6] NFS: Remove \t from mount debugging message
Date: Tue, 11 May 2010 13:16:13 -0400
Message-ID: <20100511171612.2167.23512.stgit@matisse.1015granger.net>
References: <20100511170754.2167.72681.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f183.google.com ([209.85.221.183]:60854 "EHLO
	mail-qy0-f183.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756543Ab0EKRQQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 May 2010 13:16:16 -0400
Received: by qyk13 with SMTP id 13so8473395qyk.1
        for <linux-nfs@vger.kernel.org>; Tue, 11 May 2010 10:16:16 -0700 (PDT)
In-Reply-To: <20100511170754.2167.72681.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
 

