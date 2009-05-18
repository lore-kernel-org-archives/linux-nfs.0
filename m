From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [PATCH] nfs: Fix NFS v4 client handling of MAY_EXEC in
	nfs_permission.
Date: Mon, 18 May 2009 12:25:03 -0700
Message-ID: <1242674704.4273.5.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eugene Teo <eugene@redhat.com>, security@kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Bruce Fields <bfields@fieldses.org>
To: NFS List <linux-nfs@vger.kernel.org>,
	NFS V4 Mailing List <nfsv4@linux-nfs.org>,
	Linux Kernel Mailing List
	<linux-linux-kernel@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:33014 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752092AbZERTZF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 May 2009 15:25:05 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The problem is that permission checking is skipped if atomic open is
possible, but when exec opens a file, it just opens it O_READONLY which
means EXEC permission will not be checked at that time.

This problem is observed by the following sequence (executed as root):

mount -t nfs4 server:/ /mnt4
echo "ls" >/mnt4/foo
chmod 744 /mnt4/foo
su guest -c "mnt4/foo"

Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
---
 fs/nfs/dir.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 370b190..89f98e9 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1943,7 +1943,8 @@ int nfs_permission(struct inode *inode, int mask)
 		case S_IFREG:
 			/* NFSv4 has atomic_open... */
 			if (nfs_server_capable(inode, NFS_CAP_ATOMIC_OPEN)
-					&& (mask & MAY_OPEN))
+					&& (mask & MAY_OPEN)
+					&& !(mask & MAY_EXEC))
 				goto out;
 			break;
 		case S_IFDIR:

