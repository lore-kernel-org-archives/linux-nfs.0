From: David Chinner <dgc@sgi.com>
Subject: Re: [PATCH 4/8] knfsd: repcache: split hash index
Date: Mon, 16 Oct 2006 16:38:58 +1000
Message-ID: <20061016063858.GI11034@melbourne.sgi.com>
References: <1160566044.8530.13.camel@hole.melbourne.sgi.com>
	<17714.59304.768727.298610@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Greg Banks <gnb@melbourne.sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZM7z-0003DQ-Ge
	for nfs@lists.sourceforge.net; Sun, 15 Oct 2006 23:39:12 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GZM7y-0004Ai-6d
	for nfs@lists.sourceforge.net; Sun, 15 Oct 2006 23:39:12 -0700
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
> If I've done my sums right (there is always room for doubt), then HASHSIZE == 4096.
> 
> > +
> > +		b->hash = kmalloc (HASHSIZE * sizeof(struct hlist_head), GFP_KERNEL);
> 
> So this kmalloc asks for 16K or 32K depending on pointer size.  On
> most machines that would be an order 2 or 3 allocation which is more
> likely to fail that order 0.
>
> I would really like to see HASHSIZE limited to PAGE_SIZE, and if
> needed, push CACHE_NUM_BUCKETS up ... that might make the
> 'cache_buckets' array bigger than a page, but we don't kmalloc that so
> it shouldn't be a problem.
> 
> Hmmm.. but if we wanted to scale the hash table size based on memory,
> we would want to kmalloc cache_buckets which might limit it's size...
> Maybe we could try allocating it big - which might work on big
> machines, and scale back the size on kmalloc failure??  That would
> probably work.

Yes, that works.  e.g. XFS uses kmem_zalloc_greedy() allocating
large hashes at mount time....

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
