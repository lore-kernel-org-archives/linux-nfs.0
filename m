From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/5] NFS: Don't clear PG_writeback until after we've
	processed unstable writes
Date: Fri, 20 Apr 2007 16:12:40 -0400
Message-ID: <20070420201239.7897.74094.stgit@heimdal.trondhjem.org>
References: <20070420200358.7897.75870.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-kernel@vger.kernel.org, Florin Iucha <florin@iucha.net>,
	Adrian Bunk <bunk@stusta.de>, nfs@lists.sourceforge.net,
	Andrew Morton <akpm@linux-foundation.org>,
	OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HezTD-0002o1-2M
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 13:12:39 -0700
Received: from dh166.citi.umich.edu ([141.211.133.166]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HezTE-0006lu-DS
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 13:12:41 -0700
In-Reply-To: <20070420200358.7897.75870.stgit@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Ensure that we don't release the PG_writeback lock until after the page has
either been redirtied, or queued on the nfs_inode 'commit' list.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 3ed4feb..8e94246 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -920,8 +920,8 @@ out_bad:
 		list_del(&data->pages);
 		nfs_writedata_release(data);
 	}
-	nfs_end_page_writeback(req->wb_page);
 	nfs_redirty_request(req);
+	nfs_end_page_writeback(req->wb_page);
 	nfs_clear_page_writeback(req);
 	return -ENOMEM;
 }
@@ -966,8 +966,8 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, int how)
 	while (!list_empty(head)) {
 		struct nfs_page *req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
-		nfs_end_page_writeback(req->wb_page);
 		nfs_redirty_request(req);
+		nfs_end_page_writeback(req->wb_page);
 		nfs_clear_page_writeback(req);
 	}
 	return -ENOMEM;
@@ -1002,8 +1002,8 @@ out_err:
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
-		nfs_end_page_writeback(req->wb_page);
 		nfs_redirty_request(req);
+		nfs_end_page_writeback(req->wb_page);
 		nfs_clear_page_writeback(req);
 	}
 	return error;

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
