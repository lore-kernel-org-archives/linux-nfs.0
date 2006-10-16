From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 4/8] knfsd: repcache: split hash index
Date: Mon, 16 Oct 2006 20:23:30 +1000
Message-ID: <17715.23970.155314.297331@cse.unsw.edu.au>
References: <1160566044.8530.13.camel@hole.melbourne.sgi.com>
	<17714.59304.768727.298610@cse.unsw.edu.au>
	<20061016095121.GB8568@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZPdJ-0006p7-3h
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 03:23:45 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GZPdJ-0007Sf-GY
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 03:23:46 -0700
To: Greg Banks <gnb@sgi.com>
In-Reply-To: message from Greg Banks on Monday October 16
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

On Monday October 16, gnb@sgi.com wrote:
> 
> Let's look at the maths.  If we were to limit cache_buckets[] to a
> single page, I calculate that would give us 186 entries on ia64, 46
> on x86_64, and 68 on i386 (fewer if various spinlock-related config
> options are enabled).  That's too low on x86_64 but fine on the other
> platforms.  With a single order-1 allocation we could cover most
> bases.

I had thought that ____cacheline_aligned_in_smp would have padded it
more making few entries per page, but that probably isn't important.

> 
> Alternatively, we could allocate the buckets separately and make
> cache_buckets[] an array of pointers to buckets.  Then we could do a
> single (say) 128*sizeof(svc_cache_bucket*) allocation plus (say) 128 *
> sizeof(svc_cache_bucket) allocations, all of which would be order 0.
> Now we've effectively got a 3-level fat tree keyed on hash value.
> 
> The more I think about it, the more I like this idea.
> 

Me too.

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
