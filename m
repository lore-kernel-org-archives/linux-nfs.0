From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: kernel Oops in rpc.mountd
Date: Tue, 8 Feb 2005 16:58:07 +1100
Message-ID: <16904.21743.337045.348886@cse.unsw.edu.au>
References: <200502080447.j184lA2k012260@m27.ligo.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyOO4-0004lr-59
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 21:58:12 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CyOO3-00050M-Ci
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 21:58:11 -0800
To: Stuart Anderson <anderson@ligo.caltech.edu>
In-Reply-To: message from Stuart Anderson on Monday February 7
Sender: nfs-admin@lists.sourceforge.net
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

On Monday February 7, anderson@ligo.caltech.edu wrote:
> We are going to rebuild 2.6.10-1.760_FC3smp with 8k stack (just my
> paranoia about the 4k stacks), and remove absolutely everything we do
> not need, however, I will add in the CONFIG_DEBUG_SLAB. Are there any
> other kernel debug flags that might be helpful?

No.  However the following patch might be worth a try.
It adds some extra locking.  I'm pretty sure there is a race that this
closes that could possibly cause your problem.  I also think the
locking here is a bit heavy handed, but I am sure it is safe.

> 
> Perhaps the bug is due to having a large list of static NFS mounts (290)?

Having lots of mounts won't hurt.  But having lots of clients mount
this server might have make it more likely to trigger the bug as there
is more activity on the export cache.

NeilBrown


Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./include/linux/sunrpc/cache.h |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff ./include/linux/sunrpc/cache.h~current~ ./include/linux/sunrpc/cache.h
--- ./include/linux/sunrpc/cache.h~current~	2005-02-08 16:23:21.000000000 +1100
+++ ./include/linux/sunrpc/cache.h	2005-02-08 16:41:09.000000000 +1100
@@ -268,15 +268,19 @@ static inline struct cache_head  *cache_
 
 static inline int cache_put(struct cache_head *h, struct cache_detail *cd)
 {
-	atomic_dec(&h->refcnt);
+	int rv = 0;
+	read_lock(&cd->hash_lock);
+	if (atomic_dec_and_test(&h->refcnt))
+		rv = 1;
 	if (!atomic_read(&h->refcnt) &&
 	    h->expiry_time < cd->nextcheck)
 		cd->nextcheck = h->expiry_time;
-	if (!test_bit(CACHE_HASHED, &h->flags) &&
-	    !atomic_read(&h->refcnt))
-		return 1;
+	if (test_bit(CACHE_HASHED, &h->flags) ||
+	    atomic_read(&h->refcnt))
+		rv = 0;
+	read_unlock(&cd->hash_lock);
 
-	return 0;
+	return rv;
 }
 
 extern void cache_init(struct cache_head *h);


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
