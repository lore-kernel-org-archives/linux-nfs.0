From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] Please pull one more NFS client fix...
Date: Wed, 30 May 2007 17:30:39 -0400
Message-ID: <1180560639.6770.58.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HtVl5-0007P7-R7
	for nfs@lists.sourceforge.net; Wed, 30 May 2007 14:31:07 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HtVl6-0006oj-MP
	for nfs@lists.sourceforge.net; Wed, 30 May 2007 14:31:10 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi Linus,

Please pull from the "fixes" branch of the repository at

   git pull git://git.linux-nfs.org/pub/linux/nfs-2.6.git fixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/direct.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

commit b4946ffb1860597b187d78d61ac6504177eb0ff8
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed May 30 12:58:00 2007 -0400

    NFS: Fix a refcount leakage in O_DIRECT
    
    The current code is leaking a reference to dreq->kref when the calls to
    nfs_direct_read_schedule() and nfs_direct_write_schedule() return an
    error.
    This patch moves the call to kref_put() from nfs_direct_wait() back into
    nfs_direct_read() and nfs_direct_write() (which are the functions that
    actually took the reference in the first place) fixing the leak.
    
    Thanks to Denis V. Lunev for spotting the bug and proposing the original
    fix.
    
    Acked-by: Denis V. Lunev <dlunev@gmail.com>
    Acked-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 0c542ec..00eee87 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -168,7 +168,7 @@ static inline struct nfs_direct_req *nfs_direct_req_alloc(void)
 	return dreq;
 }
 
-static void nfs_direct_req_release(struct kref *kref)
+static void nfs_direct_req_free(struct kref *kref)
 {
 	struct nfs_direct_req *dreq = container_of(kref, struct nfs_direct_req, kref);
 
@@ -177,6 +177,11 @@ static void nfs_direct_req_release(struct kref *kref)
 	kmem_cache_free(nfs_direct_cachep, dreq);
 }
 
+static void nfs_direct_req_release(struct nfs_direct_req *dreq)
+{
+	kref_put(&dreq->kref, nfs_direct_req_free);
+}
+
 /*
  * Collects and returns the final error value/byte-count.
  */
@@ -196,7 +201,6 @@ static ssize_t nfs_direct_wait(struct nfs_direct_req *dreq)
 		result = dreq->count;
 
 out:
-	kref_put(&dreq->kref, nfs_direct_req_release);
 	return (ssize_t) result;
 }
 
@@ -214,7 +218,7 @@ static void nfs_direct_complete(struct nfs_direct_req *dreq)
 	}
 	complete_all(&dreq->completion);
 
-	kref_put(&dreq->kref, nfs_direct_req_release);
+	nfs_direct_req_release(dreq);
 }
 
 /*
@@ -369,6 +373,7 @@ static ssize_t nfs_direct_read(struct kiocb *iocb, unsigned long user_addr, size
 	if (!result)
 		result = nfs_direct_wait(dreq);
 	rpc_clnt_sigunmask(clnt, &oldset);
+	nfs_direct_req_release(dreq);
 
 	return result;
 }
@@ -716,6 +721,7 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, unsigned long user_addr, siz
 	if (!result)
 		result = nfs_direct_wait(dreq);
 	rpc_clnt_sigunmask(clnt, &oldset);
+	nfs_direct_req_release(dreq);
 
 	return result;
 }

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
