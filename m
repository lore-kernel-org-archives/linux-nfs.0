From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] kNFSdv4 - 1 of 10 - idmap bugfixes and cleanup
Date: Thu, 8 Apr 2004 15:18:39 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040408191838.GA17909@fieldses.org>
References: <20040408111135.5397.patches@notabene> <E1BBOBq-0001Qe-9u@notabene.cse.unsw.edu.au> <20040407233608.6414089a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NeilBrown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBf37-0002Cz-D3
	for nfs@lists.sourceforge.net; Thu, 08 Apr 2004 12:18:53 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BBf36-000326-TB
	for nfs@lists.sourceforge.net; Thu, 08 Apr 2004 12:18:53 -0700
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040407233608.6414089a.akpm@osdl.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Wed, Apr 07, 2004 at 11:36:08PM -0700, Andrew Morton wrote:
> 
> Random observations which may be wrong:
> 
> - If two CPUs run put_mdr() at the same time, one of them can do
>   wake_up() of a now-kfreed pointer.  This function requires higher-level
>   locking of some form.

Argh, there isn't any, so you're right of course, thanks.

So I just use a spinlock.  That also makes the atomic_t superfluous.
Here's an incremental patch.

--b.


 fs/nfsd/nfs4idmap.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff -puN fs/nfsd/nfs4idmap.c~nfsd_idmap_mdr_put_fix fs/nfsd/nfs4idmap.c
--- linux-2.6.5-rc2/fs/nfsd/nfs4idmap.c~nfsd_idmap_mdr_put_fix	2004-04-08 14:14:28.000000000 -0400
+++ linux-2.6.5-rc2-bfields/fs/nfsd/nfs4idmap.c	2004-04-08 14:14:28.000000000 -0400
@@ -406,18 +406,21 @@ struct idmap_defer_req {
        struct cache_req		req;
        struct cache_deferred_req deferred_req;
        wait_queue_head_t	waitq;
-       atomic_t			count;
+       int			count;
 };
 
+static spinlock_t mdr_lock = SPIN_LOCK_UNLOCKED;
+
 static void
 put_mdr(struct idmap_defer_req *mdr)
 {
-	wait_queue_head_t	*waitq = &mdr->waitq;
-
-	if (atomic_dec_and_test(&mdr->count))
+	spin_lock(&mdr_lock);
+	mdr->count--;
+	if (mdr->count == 0)
 		kfree(mdr);
 	else
-		wake_up(waitq);
+		wake_up(&mdr->waitq);
+	spin_unlock(&mdr_lock);
 }
 
 static void
@@ -501,7 +504,7 @@ init_mdr(struct idmap_defer_req *mdr, wa
 	memset(mdr, 0, sizeof(*mdr));
 	init_waitqueue_head(&mdr->waitq);
 	add_wait_queue(&mdr->waitq, waitq);
-	atomic_set(&mdr->count, 2);
+	mdr->count = 2;
 	mdr->req.defer = idmap_defer;
 }
 

_


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
