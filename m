Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56088 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934288Ab0HMNxu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 09:53:50 -0400
Date: Fri, 13 Aug 2010 15:53:49 +0200
Message-ID: <s5h4oeywrde.wl%tiwai@suse.de>
From: Takashi Iwai <tiwai@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Neil Brown <neilb@suse.de>, Al Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] nfsd: fix NULL dereference in nfsd_statfs()
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The commit ebabe9a9001af0af56c0c2780ca1576246e7a74b
    pass a struct path to vfs_statfs
introduced the struct path initialization, and this seems to trigger
an Oops on my machine.

fh_dentry field may be NULL and set later in fh_verify(), thus the
initialization of path must be after fh_verify().

Signed-off-by: Takashi Iwai <tiwai@suse.de>
---
 fs/nfsd/vfs.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 96360a8..661a6cf 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -2033,15 +2033,17 @@ out:
 __be32
 nfsd_statfs(struct svc_rqst *rqstp, struct svc_fh *fhp, struct kstatfs *stat, int access)
 {
-	struct path path = {
-		.mnt	= fhp->fh_export->ex_path.mnt,
-		.dentry	= fhp->fh_dentry,
-	};
 	__be32 err;
 
 	err = fh_verify(rqstp, fhp, 0, NFSD_MAY_NOP | access);
-	if (!err && vfs_statfs(&path, stat))
-		err = nfserr_io;
+	if (!err) {
+		struct path path = {
+			.mnt	= fhp->fh_export->ex_path.mnt,
+			.dentry	= fhp->fh_dentry,
+		};
+		if (vfs_statfs(&path, stat))
+			err = nfserr_io;
+	}
 	return err;
 }
 
-- 
1.7.2.1

