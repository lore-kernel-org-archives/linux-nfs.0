From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/8] NFS: Don't wait for congestion in
	nfs_update_request()
Date: Wed, 11 Apr 2007 22:37:25 -0400
Message-ID: <20070412023725.15270.30723.stgit@heimdal.trondhjem.org>
References: <20070412023714.15270.33322.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HbpBg-0005lC-L4
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 19:37:28 -0700
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HbpBi-0002dA-VH
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 19:37:31 -0700
In-Reply-To: <20070412023714.15270.33322.stgit@heimdal.trondhjem.org>
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

It is redundant, and will interfere with the call to
balance_dirty_pages_ratelimited_nr in generic_file_write().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |   30 ------------------------------
 1 files changed, 0 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e5d7cac..bcd72f6 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -555,34 +555,6 @@ static inline int nfs_scan_commit(struct inode *inode, struct list_head *dst, un
 }
 #endif
 
-static int nfs_wait_on_write_congestion(struct address_space *mapping)
-{
-	struct inode *inode = mapping->host;
-	struct backing_dev_info *bdi = mapping->backing_dev_info;
-	int ret = 0;
-
-	might_sleep();
-
-	if (!bdi_write_congested(bdi))
-		return 0;
-
-	nfs_inc_stats(inode, NFSIOS_CONGESTIONWAIT);
-
-	do {
-		struct rpc_clnt *clnt = NFS_CLIENT(inode);
-		sigset_t oldset;
-
-		rpc_clnt_sigmask(clnt, &oldset);
-		ret = congestion_wait_interruptible(WRITE, HZ/10);
-		rpc_clnt_sigunmask(clnt, &oldset);
-		if (ret == -ERESTARTSYS)
-			break;
-		ret = 0;
-	} while (bdi_write_congested(bdi));
-
-	return ret;
-}
-
 /*
  * Try to update any existing write request, or create one if there is none.
  * In order to match, the request's credentials must match those of
@@ -601,8 +573,6 @@ static struct nfs_page * nfs_update_request(struct nfs_open_context* ctx,
 
 	end = offset + bytes;
 
-	if (nfs_wait_on_write_congestion(mapping))
-		return ERR_PTR(-ERESTARTSYS);
 	for (;;) {
 		/* Loop over all inode entries and see if we find
 		 * A request for the page we wish to update

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
