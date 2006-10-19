From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 09/11] NFS: remove unused check in nfs4_open_revalidate
Date: Thu, 19 Oct 2006 13:04:32 -0400
Message-ID: <20061019170432.8171.64428.stgit@lade.trondhjem.org>
References: <20061019170432.8171.75076.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1946245AbWJSRGg@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <20061019170432.8171.75076.stgit@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Chuck Lever <chuck.lever@oracle.com>

Coverity spotted a superfluous error check in nfs4_open_revalidate().
Remove it.

Coverity: #cid 847

Test plan:
Code inspection; another pass through Coverity.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 47c7e6e..7421bcb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1314,11 +1314,9 @@ nfs4_open_revalidate(struct inode *dir, 
 			case -EROFS:
 				lookup_instantiate_filp(nd, (struct dentry *)state, NULL);
 				return 1;
-			case -ENOENT:
-				if (dentry->d_inode == NULL)
-					return 1;
+			default:
+				goto out_drop;
 		}
-		goto out_drop;
 	}
 	if (state->inode == dentry->d_inode) {
 		nfs4_intent_set_file(nd, dentry, state);
