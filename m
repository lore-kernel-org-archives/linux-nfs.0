From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 4/8] knfsd: repcache: split hash index
Date: Mon, 16 Oct 2006 12:00:08 +1000
Message-ID: <17714.59304.768727.298610@cse.unsw.edu.au>
References: <1160566044.8530.13.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZHmD-0005OK-3W
	for nfs@lists.sourceforge.net; Sun, 15 Oct 2006 19:00:25 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GZHmC-00075r-D1
	for nfs@lists.sourceforge.net; Sun, 15 Oct 2006 19:00:26 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Wednesday October 11
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

On Wednesday October 11, gnb@melbourne.sgi.com wrote:
>   */
>  #define CACHESIZE		1024
> -#define HASHSIZE		64
> +/* number of buckets used to manage LRU lists and cache locks (power of 2) */
> +#ifdef CONFIG_SMP
> +#define CACHE_NUM_BUCKETS	64
> +#else
> +#define CACHE_NUM_BUCKETS	1
> +#endif
> +/* largest possible number of entries in all LRU lists (power of 2) */
> +#define CACHE_MAX_SIZE		(16*1024*CACHE_NUM_BUCKETS)
> +/* largest possible number of entries in LRU per bucket */
> +#define CACHE_BUCKET_MAX_SIZE	(CACHE_MAX_SIZE/CACHE_NUM_BUCKETS)
> +/* log2 of largest desired hash chain length */
> +#define MAX_CHAIN_ORDER		2
> +/* size of the per-bucket hash table */
> +#define HASHSIZE		((CACHE_MAX_SIZE>>MAX_CHAIN_ORDER)/CACHE_NUM_BUCKETS)

If I've done my sums right (there is always room for doubt), then HASHSIZE == 4096.

> +
> +		b->hash = kmalloc (HASHSIZE * sizeof(struct hlist_head), GFP_KERNEL);

So this kmalloc asks for 16K or 32K depending on pointer size.  On
most machines that would be an order 2 or 3 allocation which is more
likely to fail that order 0.
I would really like to see HASHSIZE limited to PAGE_SIZE, and if
needed, push CACHE_NUM_BUCKETS up ... that might make the
'cache_buckets' array bigger than a page, but we don't kmalloc that so
it shouldn't be a problem.

Hmmm.. but if we wanted to scale the hash table size based on memory,
we would want to kmalloc cache_buckets which might limit it's size...
Maybe we could try allocating it big - which might work on big
machines, and scale back the size on kmalloc failure??  That would
probably work.

So for now I would like to see this limit HASHSIZE to
PAGE_SIZE/sizeof(void*), and possibly make CACHE_NUM_BUCKETS bigger in
some circumstances.  Allocating cache_buckets based on memory size can
come later if it is needed.

Sound fair?

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
