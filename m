From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 12 of 12] change nfsd reply cache to use list.h lists
Date: Tue, 08 Feb 2005 14:06:54 +1100
Message-ID: <E1CyLiI-0006Vu-L2@notabene.cse.unsw.edu.au>
References: <20050208140033.24886.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyLis-0006vJ-MJ
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:30 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CyLir-0004G7-Nb
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:30 -0800
To: Andrew Morton <akpm@osdl.org>
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


also kmalloc the cache one entry at a time, instead
of in one big slab.

Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfscache.c         |  131 ++++++++++++++-----------------------------
 ./include/linux/nfsd/cache.h |    7 --
 2 files changed, 46 insertions(+), 92 deletions(-)

diff ./fs/nfsd/nfscache.c~current~ ./fs/nfsd/nfscache.c
--- ./fs/nfsd/nfscache.c~current~	2005-02-08 13:49:35.000000000 +1100
+++ ./fs/nfsd/nfscache.c	2005-02-08 13:49:42.000000000 +1100
@@ -15,6 +15,7 @@
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/spinlock.h>
+#include <linux/list.h>
 
 #include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
@@ -30,15 +31,8 @@
 #define HASHSIZE		64
 #define REQHASH(xid)		((((xid) >> 24) ^ (xid)) & (HASHSIZE-1))
 
-struct nfscache_head {
-	struct svc_cacherep *	next;
-	struct svc_cacherep *	prev;
-};
-
-static struct nfscache_head *	hash_list;
-static struct svc_cacherep *	lru_head;
-static struct svc_cacherep *	lru_tail;
-static struct svc_cacherep *	nfscache;
+static struct hlist_head *	hash_list;
+static struct list_head 	lru_head;
 static int			cache_disabled = 1;
 
 static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
@@ -54,46 +48,32 @@ void
 nfsd_cache_init(void)
 {
 	struct svc_cacherep	*rp;
-	struct nfscache_head	*rh;
-	size_t			i;
-	unsigned long		order;
+	int			i;
 
-
-	i = CACHESIZE * sizeof (struct svc_cacherep);
-	for (order = 0; (PAGE_SIZE << order) < i; order++)
-		;
-	nfscache = (struct svc_cacherep *)
-		__get_free_pages(GFP_KERNEL, order);
-	if (!nfscache) {
-		printk (KERN_ERR "nfsd: cannot allocate %Zd bytes for reply cache\n", i);
-		return;
+	INIT_LIST_HEAD(&lru_head);
+	i = CACHESIZE;
+	while(i) {
+		rp = kmalloc(sizeof(*rp), GFP_KERNEL);
+		if (!rp) break;
+		list_add(&rp->c_lru, &lru_head);
+		rp->c_state = RC_UNUSED;
+		rp->c_type = RC_NOCACHE;
+		INIT_HLIST_NODE(&rp->c_hash);
+		i--;
 	}
-	memset(nfscache, 0, i);
 
-	i = HASHSIZE * sizeof (struct nfscache_head);
-	hash_list = kmalloc (i, GFP_KERNEL);
+	if (i)
+		printk (KERN_ERR "nfsd: cannot allocate all %d cache entries, only got %d\n",
+			CACHESIZE, CACHESIZE-i);
+
+	hash_list = kmalloc (HASHSIZE * sizeof(struct hlist_head), GFP_KERNEL);
 	if (!hash_list) {
-		free_pages ((unsigned long)nfscache, order);
-		nfscache = NULL;
-		printk (KERN_ERR "nfsd: cannot allocate %Zd bytes for hash list\n", i);
+		nfsd_cache_shutdown();
+		printk (KERN_ERR "nfsd: cannot allocate %Zd bytes for hash list\n", 
+			HASHSIZE * sizeof(struct hlist_head));
 		return;
 	}
-
-	for (i = 0, rh = hash_list; i < HASHSIZE; i++, rh++)
-		rh->next = rh->prev = (struct svc_cacherep *) rh;
-
-	for (i = 0, rp = nfscache; i < CACHESIZE; i++, rp++) {
-		rp->c_state = RC_UNUSED;
-		rp->c_type = RC_NOCACHE;
-		rp->c_hash_next =
-		rp->c_hash_prev = rp;
-		rp->c_lru_next = rp + 1;
-		rp->c_lru_prev = rp - 1;
-	}
-	lru_head = nfscache;
-	lru_tail = nfscache + CACHESIZE - 1;
-	lru_head->c_lru_prev = NULL;
-	lru_tail->c_lru_next = NULL;
+	memset(hash_list, 0, HASHSIZE * sizeof(struct hlist_head));
 
 	cache_disabled = 0;
 }
@@ -102,48 +82,30 @@ void
 nfsd_cache_shutdown(void)
 {
 	struct svc_cacherep	*rp;
-	size_t			i;
-	unsigned long		order;
 
-	for (rp = lru_head; rp; rp = rp->c_lru_next) {
+	while (!list_empty(&lru_head)) {
+		rp = list_entry(lru_head.next, struct svc_cacherep, c_lru);
 		if (rp->c_state == RC_DONE && rp->c_type == RC_REPLBUFF)
 			kfree(rp->c_replvec.iov_base);
+		list_del(&rp->c_lru);
+		kfree(rp);
 	}
 
 	cache_disabled = 1;
 
-	i = CACHESIZE * sizeof (struct svc_cacherep);
-	for (order = 0; (PAGE_SIZE << order) < i; order++)
-		;
-	free_pages ((unsigned long)nfscache, order);
-	nfscache = NULL;
-	kfree (hash_list);
+	if (hash_list)
+		kfree (hash_list);
 	hash_list = NULL;
 }
 
 /*
- * Move cache entry to front of LRU list
+ * Move cache entry to end of LRU list
  */
 static void
-lru_put_front(struct svc_cacherep *rp)
+lru_put_end(struct svc_cacherep *rp)
 {
-	struct svc_cacherep	*prev = rp->c_lru_prev,
-				*next = rp->c_lru_next;
-
-	if (prev)
-		prev->c_lru_next = next;
-	else
-		lru_head = next;
-	if (next)
-		next->c_lru_prev = prev;
-	else
-		lru_tail = prev;
-
-	rp->c_lru_next = lru_head;
-	rp->c_lru_prev = NULL;
-	if (lru_head)
-		lru_head->c_lru_prev = rp;
-	lru_head = rp;
+	list_del(&rp->c_lru);
+	list_add_tail(&rp->c_lru, &lru_head);
 }
 
 /*
@@ -152,17 +114,8 @@ lru_put_front(struct svc_cacherep *rp)
 static void
 hash_refile(struct svc_cacherep *rp)
 {
-	struct svc_cacherep	*prev = rp->c_hash_prev,
-				*next = rp->c_hash_next;
-	struct nfscache_head	*head = hash_list + REQHASH(rp->c_xid);
-
-	prev->c_hash_next = next;
-	next->c_hash_prev = prev;
-
-	rp->c_hash_next = head->next;
-	rp->c_hash_prev = (struct svc_cacherep *) head;
-	head->next->c_hash_prev = rp;
-	head->next = rp;
+	hlist_del_init(&rp->c_hash);
+	hlist_add_head(&rp->c_hash, hash_list + REQHASH(rp->c_xid));
 }
 
 /*
@@ -173,7 +126,9 @@ hash_refile(struct svc_cacherep *rp)
 int
 nfsd_cache_lookup(struct svc_rqst *rqstp, int type)
 {
-	struct svc_cacherep	*rh, *rp;
+	struct hlist_node	*hn;
+	struct hlist_head 	*rh;
+	struct svc_cacherep	*rp;
 	u32			xid = rqstp->rq_xid,
 				proto =  rqstp->rq_prot,
 				vers = rqstp->rq_vers,
@@ -190,8 +145,8 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	spin_lock(&cache_lock);
 	rtn = RC_DOIT;
 
-	rp = rh = (struct svc_cacherep *) &hash_list[REQHASH(xid)];
-	while ((rp = rp->c_hash_next) != rh) {
+	rh = &hash_list[REQHASH(xid)];
+	hlist_for_each_entry(rp, hn, rh, c_hash) {
 		if (rp->c_state != RC_UNUSED &&
 		    xid == rp->c_xid && proc == rp->c_proc &&
 		    proto == rp->c_prot && vers == rp->c_vers &&
@@ -206,7 +161,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	/* This loop shouldn't take more than a few iterations normally */
 	{
 	int	safe = 0;
-	for (rp = lru_tail; rp; rp = rp->c_lru_prev) {
+	list_for_each_entry(rp, &lru_head, c_lru) {
 		if (rp->c_state != RC_INPROG)
 			break;
 		if (safe++ > CACHESIZE) {
@@ -254,7 +209,7 @@ found_entry:
 	/* We found a matching entry which is either in progress or done. */
 	age = jiffies - rp->c_timestamp;
 	rp->c_timestamp = jiffies;
-	lru_put_front(rp);
+	lru_put_end(rp);
 
 	rtn = RC_DROPIT;
 	/* Request being processed or excessive rexmits */
@@ -343,7 +298,7 @@ nfsd_cache_update(struct svc_rqst *rqstp
 		break;
 	}
 	spin_lock(&cache_lock);
-	lru_put_front(rp);
+	lru_put_end(rp);
 	rp->c_secure = rqstp->rq_secure;
 	rp->c_type = cachetype;
 	rp->c_state = RC_DONE;

diff ./include/linux/nfsd/cache.h~current~ ./include/linux/nfsd/cache.h
--- ./include/linux/nfsd/cache.h~current~	2005-02-08 13:49:35.000000000 +1100
+++ ./include/linux/nfsd/cache.h	2005-02-08 11:32:23.000000000 +1100
@@ -19,10 +19,9 @@
  * be hash_next and hash_prev.
  */
 struct svc_cacherep {
-	struct svc_cacherep *	c_hash_next;
-	struct svc_cacherep *	c_hash_prev;
-	struct svc_cacherep *	c_lru_next;
-	struct svc_cacherep *	c_lru_prev;
+	struct hlist_node	c_hash;
+	struct list_head	c_lru;
+
 	unsigned char		c_state,	/* unused, inprog, done */
 				c_type,		/* status, buffer */
 				c_secure : 1;	/* req came from port < 1024 */


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
