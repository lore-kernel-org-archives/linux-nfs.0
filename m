Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47805 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759859Ab0J1WAP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 18:00:15 -0400
Subject: [GIT PULL] Please pull bugfixes for NFS client
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Oct 2010 18:00:00 -0400
Message-ID: <1288303200.20099.10.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/direct.c   |    2 +-
 fs/nfs/idmap.c    |    2 +-
 fs/nfs/nfs4proc.c |    4 ++--
 fs/nfs/pagelist.c |    8 +++++++-
 4 files changed, 11 insertions(+), 5 deletions(-)

commit 12364a4f05295cb1e4a161d36b486c248c11c485
Author: Geert Uytterhoeven <geert@linux-m68k.org>
Date:   Thu Oct 28 20:06:19 2010 +0200

    nfs4: The difference of 2 pointers is ptrdiff_t
    
    On m68k, which is 32-bit:
    
    fs/nfs/nfs4proc.c: In function ‘nfs41_sequence_done’:
    fs/nfs/nfs4proc.c:432: warning: format ‘%ld’ expects type ‘long int’, but argument 3 has type ‘int’
    fs/nfs/nfs4proc.c: In function ‘nfs4_setup_sequence’:
    fs/nfs/nfs4proc.c:576: warning: format ‘%ld’ expects type ‘long int’, but argument 5 has type ‘int’
    
    On 32-bit, ptrdiff_t is int; on 64-bit, ptrdiff_t is long.
    
    Introduced by commit dfb4f309830359352539919f23accc59a20a3758 ("NFSv4.1: keep
    seq_res.sr_slot as pointer rather than an index")
    
    Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8f0d97b41523fb85a2d230f6794121e5834f0cf9
Author: Dan Carpenter <error27@gmail.com>
Date:   Thu Oct 28 08:05:57 2010 +0200

    nfs: testing the wrong variable
    
    The intent was to test "*desc" for allocation failures, but it tests
    "desc" which is always a valid pointer here.
    
    Signed-off-by: Dan Carpenter <error27@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 015f0212d51d85bd281a831639a769b4a1a3307a
Author: Jeff Layton <jlayton@redhat.com>
Date:   Thu Oct 28 10:10:37 2010 -0400

    nfs: handle lock context allocation failures in nfs_create_request
    
    nfs_get_lock_context can return NULL on an allocation failure.
    Regression introduced by commit f11ac8db.
    
    Reported-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Cc: stable@kernel.org
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 568a810d7edd58bd505222dd1c7e48895532290b
Author: Steve Dickson <steved@redhat.com>
Date:   Thu Oct 28 08:17:54 2010 -0400

    Fixed Regression in NFS Direct I/O path
    
    A typo, introduced by commit f11ac8db, in the nfs_direct_write()
    routine causes writes with O_DIRECT set to fail with a ENOMEM error.
    
    Found-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Cc: stable@kernel.org
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 064a809..84d3c8b 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -873,7 +873,7 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	dreq->inode = inode;
 	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
 	dreq->l_ctx = nfs_get_lock_context(dreq->ctx);
-	if (dreq->l_ctx != NULL)
+	if (dreq->l_ctx == NULL)
 		goto out_release;
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index dec47ed..4e2d9b6 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -123,7 +123,7 @@ static ssize_t nfs_idmap_get_desc(const char *name, size_t namelen,
 	size_t desclen = typelen + namelen + 2;
 
 	*desc = kmalloc(desclen, GFP_KERNEL);
-	if (!desc)
+	if (!*desc)
 		return -ENOMEM;
 
 	cp = *desc;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 32c8758..0f24cdf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -429,7 +429,7 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 		 * returned NFS4ERR_DELAY as per Section 2.10.6.2
 		 * of RFC5661.
 		 */
-		dprintk("%s: slot=%ld seq=%d: Operation in progress\n",
+		dprintk("%s: slot=%td seq=%d: Operation in progress\n",
 			__func__,
 			res->sr_slot - res->sr_session->fc_slot_table.slots,
 			res->sr_slot->seq_nr);
@@ -573,7 +573,7 @@ int nfs4_setup_sequence(const struct nfs_server *server,
 		goto out;
 	}
 
-	dprintk("--> %s clp %p session %p sr_slot %ld\n",
+	dprintk("--> %s clp %p session %p sr_slot %td\n",
 		__func__, session->clp, session, res->sr_slot ?
 			res->sr_slot - session->fc_slot_table.slots : -1);
 
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 9194902..137b549 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -65,6 +65,13 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 	if (req == NULL)
 		return ERR_PTR(-ENOMEM);
 
+	/* get lock context early so we can deal with alloc failures */
+	req->wb_lock_context = nfs_get_lock_context(ctx);
+	if (req->wb_lock_context == NULL) {
+		nfs_page_free(req);
+		return ERR_PTR(-ENOMEM);
+	}
+
 	/* Initialize the request struct. Initially, we assume a
 	 * long write-back delay. This will be adjusted in
 	 * update_nfs_request below if the region is not locked. */
@@ -79,7 +86,6 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 	req->wb_pgbase	= offset;
 	req->wb_bytes   = count;
 	req->wb_context = get_nfs_open_context(ctx);
-	req->wb_lock_context = nfs_get_lock_context(ctx);
 	kref_init(&req->wb_kref);
 	return req;
 }

