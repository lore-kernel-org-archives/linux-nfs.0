From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH 4/8] knfsd: repcache: split hash index
Date: Mon, 16 Oct 2006 19:51:21 +1000
Message-ID: <20061016095121.GB8568@sgi.com>
References: <1160566044.8530.13.camel@hole.melbourne.sgi.com>
	<17714.59304.768727.298610@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZP83-0003ZB-H5
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 02:51:27 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GZP84-0004Eb-Ay
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 02:51:28 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17714.59304.768727.298610@cse.unsw.edu.au>
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

On Mon, Oct 16, 2006 at 12:00:08PM +1000, Neil Brown wrote:
> On Wednesday October 11, gnb@melbourne.sgi.com wrote:
> >   */
> >  #define CACHESIZE		1024
> > -#define HASHSIZE		64
> > +/* number of buckets used to manage LRU lists and cache locks (power of 2) */
> > +#ifdef CONFIG_SMP
> > +#define CACHE_NUM_BUCKETS	64
> > +#else
> > +#define CACHE_NUM_BUCKETS	1
> > +#endif
> > +/* largest possible number of entries in all LRU lists (power of 2) */
> > +#define CACHE_MAX_SIZE		(16*1024*CACHE_NUM_BUCKETS)
> > +/* largest possible number of entries in LRU per bucket */
> > +#define CACHE_BUCKET_MAX_SIZE	(CACHE_MAX_SIZE/CACHE_NUM_BUCKETS)
> > +/* log2 of largest desired hash chain length */
> > +#define MAX_CHAIN_ORDER		2
> > +/* size of the per-bucket hash table */
> > +#define HASHSIZE		((CACHE_MAX_SIZE>>MAX_CHAIN_ORDER)/CACHE_NUM_BUCKETS)
> 
> If I've done my sums right (there is always room for doubt), then HASHSIZE == 4096.

Correct.

> > +
> > +		b->hash = kmalloc (HASHSIZE * sizeof(struct hlist_head), GFP_KERNEL);
> 
> So this kmalloc asks for 16K or 32K depending on pointer size.  On
> most machines that would be an order 2 or 3 allocation which is more
> likely to fail that order 0.

This has run without allocation failures on 2 classes of machines:

* Altix (ia64), PAGE_SIZE=16K sizeof(void*)=8 => order=1
* Altix XE (x86_64), PAGE_SIZE=4K, sizeof(void*)=8 => order=3

Of course, under normal conditions these allocations happen when
the NFS server is started at boot and thus we have the best chance
of them succeeding.

But I take your point, the nfsd buffer saga teaches us that there's
value in strictly limiting the order of these allocations.


> I would really like to see HASHSIZE limited to PAGE_SIZE, and if
> needed, push CACHE_NUM_BUCKETS up ... that might make the
> 'cache_buckets' array bigger than a page, but we don't kmalloc that so
> it shouldn't be a problem.

Sounds reasonable.

> Hmmm.. but if we wanted to scale the hash table size based on memory,
> we would want to kmalloc cache_buckets which might limit it's size...

Let's look at the maths.  If we were to limit cache_buckets[] to a
single page, I calculate that would give us 186 entries on ia64, 46
on x86_64, and 68 on i386 (fewer if various spinlock-related config
options are enabled).  That's too low on x86_64 but fine on the other
platforms.  With a single order-1 allocation we could cover most bases.

Alternatively, we could allocate the buckets separately and make
cache_buckets[] an array of pointers to buckets.  Then we could do a
single (say) 128*sizeof(svc_cache_bucket*) allocation plus (say) 128 *
sizeof(svc_cache_bucket) allocations, all of which would be order 0.
Now we've effectively got a 3-level fat tree keyed on hash value.

The more I think about it, the more I like this idea.

> So for now I would like to see this limit HASHSIZE to
> PAGE_SIZE/sizeof(void*), and possibly make CACHE_NUM_BUCKETS bigger in
> some circumstances.  Allocating cache_buckets based on memory size can
> come later if it is needed.
> 
> Sound fair?

Yep.  I'll work up a new version of the patch with both the above ideas.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
