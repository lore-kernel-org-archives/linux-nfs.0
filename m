From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] knfsd: allocate readahead cache in individual chunks
Date: Thu, 14 Aug 2008 14:06:35 -0400
Message-ID: <20080814180635.GC23859@fieldses.org>
References: <1218679407-11364-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45103 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751784AbYHNSGh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Aug 2008 14:06:37 -0400
In-Reply-To: <1218679407-11364-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 13, 2008 at 10:03:27PM -0400, Jeff Layton wrote:
> I had a report from someone building a large NFS server that they were
> unable to start more than 585 nfsd threads. It was reported against an
> older kernel using the slab allocator, and I tracked it down to the
> large allocation in nfsd_racache_init failing.
> 
> It appears that the slub allocator handles large allocations better,
> but large contiguous allocations can often be problematic. There
> doesn't seem to be any reason that the racache has to be allocated as a
> single large chunk. This patch breaks this up so that the racache is
> built up from separate allocations.

So by default nfsd_racache_init gets called with size 2*nrservs, so 1170
in this case.  Looks like struct raprms is about 50 bytes.  So that's
about a 60k allocation?

And RAPARM_HASH_SIZE is 16.  So you could use an array for each hash
bucket and each array would be under a page even in this rather extreme
case, if you wanted to avoid lots of little allocations.  I don't know
whether that really matters, though.

> +static unsigned int		raparm_hash_buckets;

It looks like this is here just to tell you how many bucket heads are
non-null when freeing?  But I think the

	if (cache_size < 2*RAPARM_HASH_SIZE)
		cache_size = 2*RAPARM_HASH_SIZE;

in nfsd_racache_init ensures no bucket is null, and anyway you check for
null when freeing, so it doesn't seem like it would matter much.

>  	nperbucket = DIV_ROUND_UP(cache_size, RAPARM_HASH_SIZE);
> -	for (i = 0; i < cache_size - 1; i++) {
> +	for (i = 0; i < cache_size; i++) {
> +		raparm = kzalloc(sizeof(*raparm), GFP_KERNEL);
> +		if (!raparm)
> +			goto out_nomem;
> +
>  		if (i % nperbucket == 0)
> -			raparm_hash[j++].pb_head = raparml + i;
> -		if (i % nperbucket < nperbucket-1)
> -			raparml[i].p_next = raparml + i + 1;
> +			raparm_hash[j++].pb_head = raparm;
> +		else
> +			last_raparm->p_next = raparm;
> +		last_raparm = raparm;

The modular arithmetic here always struck me as a bit convoluted.  Why
not just nested for loops, and not be as fussy about the round-off
error?  E.g.

	for (i = 0; i < RAPARM_HASH_SIZE; i++) {
		spin_lock_init(&raparm_hash[i].pb_lock);
		raparm = &raparm_hash[i].pb_head;

		for (j = 0; j < nperbucket; j++) {
			*raparm = kzalloc(sizeof(*raparm), GFP_KERNEL);
			if (!*raparm)
				goto out_nomem;
			raparm = &(*raparm)->p_next;
		}
		*raparm = NULL;
	}

Lightly-tested patch (to apply on top of yours) follows.

--b.

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 1acbf13..72783d9 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -87,7 +87,6 @@ struct raparm_hbucket {
 #define RAPARM_HASH_SIZE	(1<<RAPARM_HASH_BITS)
 #define RAPARM_HASH_MASK	(RAPARM_HASH_SIZE-1)
 static struct raparm_hbucket	raparm_hash[RAPARM_HASH_SIZE];
-static unsigned int		raparm_hash_buckets;
 
 /* 
  * Called from nfsd_lookup and encode_dirent. Check if we have crossed 
@@ -1977,7 +1976,7 @@ nfsd_racache_shutdown(void)
 
 	dprintk("nfsd: freeing readahead buffers.\n");
 
-	for (i = 0; i < raparm_hash_buckets; i++) {
+	for (i = 0; i < RAPARM_HASH_SIZE; i++) {
 		raparm = raparm_hash[i].pb_head;
 		while(raparm) {
 			last_raparm = raparm;
@@ -1996,35 +1995,32 @@ nfsd_racache_init(int cache_size)
 	int	i;
 	int	j = 0;
 	int	nperbucket;
-	struct raparms *raparm, *last_raparm = NULL;
+	struct raparms **raparm = NULL;
 
 
 	if (raparm_hash[0].pb_head)
 		return 0;
-	if (cache_size < 2*RAPARM_HASH_SIZE)
-		cache_size = 2*RAPARM_HASH_SIZE;
+	nperbucket = DIV_ROUND_UP(cache_size, RAPARM_HASH_SIZE);
+	if (nperbucket < 2)
+		nperbucket = 2;
+	cache_size = nperbucket * RAPARM_HASH_SIZE;
 
 	dprintk("nfsd: allocating %d readahead buffers.\n", cache_size);
-	for (i = 0 ; i < RAPARM_HASH_SIZE ; i++) {
-		raparm_hash[i].pb_head = NULL;
-		spin_lock_init(&raparm_hash[i].pb_lock);
-	}
 
-	nperbucket = DIV_ROUND_UP(cache_size, RAPARM_HASH_SIZE);
-	for (i = 0; i < cache_size; i++) {
-		raparm = kzalloc(sizeof(*raparm), GFP_KERNEL);
-		if (!raparm)
-			goto out_nomem;
+	for (i = 0; i < RAPARM_HASH_SIZE; i++) {
+		spin_lock_init(&raparm_hash[i].pb_lock);
 
-		if (i % nperbucket == 0)
-			raparm_hash[j++].pb_head = raparm;
-		else
-			last_raparm->p_next = raparm;
-		last_raparm = raparm;
+		raparm = &raparm_hash[i].pb_head;
+		for (j = 0; j < nperbucket; j++) {
+			*raparm = kzalloc(sizeof(*raparm), GFP_KERNEL);
+			if (!*raparm)
+				goto out_nomem;
+			raparm = &(*raparm)->p_next;
+		}
+		*raparm = NULL;
 	}
 
 	nfsdstats.ra_size = cache_size;
-	raparm_hash_buckets = j;
 	return 0;
 
 out_nomem:
