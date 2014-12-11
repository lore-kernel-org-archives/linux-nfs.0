Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40936 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932975AbaLKUfJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Dec 2014 15:35:09 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jeff.layton@primarydata.com>
Subject: [PATCH] nfs: verify open flags before allowing open
Date: Thu, 11 Dec 2014 15:30:29 -0500
Message-Id: <f2d48b67e911de7a8b89025b25d3ab97f397ba8f.1418329650.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix another path for:
9597c13b nfs: verify open flags before allowing an atomic open

which forbade the NFSv4 open for O_DIRECT|O_APPEND in nfs_atomic_open().
That code path is missed when a cached positive dentry exists;
nfs4_file_open() is used instead.  Duplicate the forbid in nfs4_file_open().

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/nfs4file.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index c51fb4d..c2e4767 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -37,6 +37,10 @@ nfs4_file_open(struct inode *inode, struct file *filp)
 
 	dprintk("NFS: open file(%pd2)\n", dentry);
 
+	err = nfs_check_flags(openflags);
+	if (err)
+		return err;
+
 	if ((openflags & O_ACCMODE) == 3)
 		openflags--;
 
-- 
1.7.1

