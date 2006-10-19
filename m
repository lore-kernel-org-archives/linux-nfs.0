From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 08/11] NFS: __nfs_revalidate_inode() can use "inode" before
	checking it is non-NULL
Date: Thu, 19 Oct 2006 13:04:32 -0400
Message-ID: <20061019170432.8171.35298.stgit@lade.trondhjem.org>
References: <20061019170432.8171.75076.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1946243AbWJSRGJ@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <20061019170432.8171.75076.stgit@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Chuck Lever <chuck.lever@oracle.com>

The "!inode" check in __nfs_revalidate_inode() occurs well after the first
time it is dereferenced, so get rid of it.

Coverity: #cid 1372, 1373

Test plan:
Code review; recheck with Coverity.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 9979ad1..08cc4c5 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -583,7 +583,7 @@ __nfs_revalidate_inode(struct nfs_server
 
 	nfs_inc_stats(inode, NFSIOS_INODEREVALIDATE);
 	lock_kernel();
-	if (!inode || is_bad_inode(inode))
+	if (is_bad_inode(inode))
  		goto out_nowait;
 	if (NFS_STALE(inode))
  		goto out_nowait;
