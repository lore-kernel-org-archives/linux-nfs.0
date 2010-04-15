Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:51792 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457Ab0DOPQD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Apr 2010 11:16:03 -0400
Received: by vws5 with SMTP id 5so274676vws.19
        for <linux-nfs@vger.kernel.org>; Thu, 15 Apr 2010 08:16:01 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: rsize and wsize settings ignored on v4 mounts
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 15 Apr 2010 11:15:58 -0400
Message-ID: <20100415151556.3809.47671.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NFSv4 mounts ignore the rsize and wsize mount options, and always use
the default transfer size for both.  This seems to be because all
NFSv4 mounts are now cloned, and the cloning logic doesn't copy the
rsize and wsize settings from the parent nfs_server.

I tested Fedora's 2.6.32.11-99 and it seems to have this problem as
well, so I'm guessing that .33, .32, and perhaps older kernels have
this issue as well.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Stable <stable@kernel.org>
---

 fs/nfs/client.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 2a3d352..cd24d6e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -966,6 +966,8 @@ out_error:
 static void nfs_server_copy_userdata(struct nfs_server *target, struct nfs_server *source)
 {
 	target->flags = source->flags;
+	target->rsize = source->rsize;
+	target->wsize = source->wsize;
 	target->acregmin = source->acregmin;
 	target->acregmax = source->acregmax;
 	target->acdirmin = source->acdirmin;

