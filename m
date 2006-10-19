From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 02/11] NFS: Fix oops in nfs_cancel_commit_list
Date: Thu, 19 Oct 2006 13:04:32 -0400
Message-ID: <20061019170432.8171.94121.stgit@lade.trondhjem.org>
References: <20061019170432.8171.75076.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1946249AbWJSRHt@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <20061019170432.8171.75076.stgit@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Fix two bugs:
 - nfs_inode_remove_request will call nfs_clear_request, so we cannot
   reference req->wb_page after it. Move the call to dec_zone_page_state so
   that it occurs while req->wb_page is still valid.
 - Calling nfs_clear_page_writeback is unnecessary since the radix tree
   tags will have been cleared by the call to nfs_inode_remove_request.
   Replace with a simple call to nfs_unlock_request.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f6675d2..d80fa8c 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -588,10 +588,10 @@ static void nfs_cancel_commit_list(struc
 
 	while(!list_empty(head)) {
 		req = nfs_list_entry(head->next);
+		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 		nfs_list_remove_request(req);
 		nfs_inode_remove_request(req);
-		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-		nfs_clear_page_writeback(req);
+		nfs_unlock_request(req);
 	}
 }
 
