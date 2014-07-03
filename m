Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:56629 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759587AbaGCTQA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2014 15:16:00 -0400
Received: by mail-qg0-f45.google.com with SMTP id a108so631266qge.32
        for <linux-nfs@vger.kernel.org>; Thu, 03 Jul 2014 12:15:59 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: add a nfserrno mapping for -E2BIG to nfserr_fbig
Date: Thu,  3 Jul 2014 15:15:54 -0400
Message-Id: <1404414954-5227-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I saw this pop up with some pynfs testing:

    [  123.609992] nfsd: non-standard errno: -7

...and -7 is -E2BIG. I think what happened is that XFS returned -E2BIG
due to some xattr operations with the ACL10 pynfs TEST (I guess it has
limited xattr size?).

Add a better mapping for that error since it's possible that we'll need
it. How about we convert it to NFSERR_FBIG? As Bruce points out, they
both have "BIG" in the name so it must be good.

Also, turn the printk in this function into a WARN() so that we can get
a bit more information about situations that don't have proper mappings.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfsproc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index eff49552cdc8..b19c7e8bf64c 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -717,6 +717,7 @@ nfserrno (int errno)
 		{ nfserr_noent, -ENOENT },
 		{ nfserr_io, -EIO },
 		{ nfserr_nxio, -ENXIO },
+		{ nfserr_fbig, -E2BIG },
 		{ nfserr_acces, -EACCES },
 		{ nfserr_exist, -EEXIST },
 		{ nfserr_xdev, -EXDEV },
@@ -751,7 +752,7 @@ nfserrno (int errno)
 		if (nfs_errtbl[i].syserr == errno)
 			return nfs_errtbl[i].nfserr;
 	}
-	printk (KERN_INFO "nfsd: non-standard errno: %d\n", errno);
+	WARN(1, "nfsd: non-standard errno: %d\n", errno);
 	return nfserr_io;
 }
 
-- 
1.9.3

