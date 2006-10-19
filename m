From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 07/11] NFS: fix minor bug in new NFS symlink code
Date: Thu, 19 Oct 2006 13:04:32 -0400
Message-ID: <20061019170432.8171.49033.stgit@lade.trondhjem.org>
References: <20061019170432.8171.75076.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1946241AbWJSRGg@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <20061019170432.8171.75076.stgit@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Chuck Lever <chuck.lever@oracle.com>

The original code confused a zero return code from pagevec_add() as
success.

Test plan:
None.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 58d4405..c86a1ea 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1519,8 +1519,8 @@ static int nfs_symlink(struct inode *dir
 	pagevec_init(&lru_pvec, 0);
 	if (!add_to_page_cache(page, dentry->d_inode->i_mapping, 0,
 							GFP_KERNEL)) {
-		if (!pagevec_add(&lru_pvec, page))
-			__pagevec_lru_add(&lru_pvec);
+		pagevec_add(&lru_pvec, page);
+		pagevec_lru_add(&lru_pvec);
 		SetPageUptodate(page);
 		unlock_page(page);
 	} else
