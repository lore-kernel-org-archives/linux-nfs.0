From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0 of 5] knfsd: miscellaneous performance-related
	fixes
Date: Tue, 8 Aug 2006 18:01:25 +1000
Message-ID: <17624.17621.428870.694339@cse.unsw.edu.au>
References: <1155009879.29877.229.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAMWq-0003OL-Ql
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 01:01:32 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GAMWq-0000Z4-IU
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 01:01:33 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Tuesday August 8
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

On Tuesday August 8, gnb@melbourne.sgi.com wrote:
> G'day,
> 
> Five more patches which fix various issues found in knfsd,
> mostly directly performance-related.

Thanks.  I'll have a bit more of a look in a day or two, but just
quickly:

> 
> 1 of 5 knfsd: make readahead params cache SMP-friendly
> 	the racache is a global contention point and performance
>       bottleneck in some read-dominated workloads, alleviate that
> 

Looks good, though might become irrelevant if the 'new' readahead code
goes ahead (the racache can just be discarded).

> 2 of 5 knfsd: cache ipmap per TCP socket
> 	for TCP we can avoid doing a hash lookup on the ip_map
> 	cache for every RPC call

Looks sane, but I'm wondering why:
 
+static inline int cache_valid(struct cache_head *h)
+{
+	return (h->expiry_time != 0 && test_bit(CACHE_VALID, &h->flags));
+}
+

we need to test expiry_time here. Is not the test on CACHE_VALID
enough?


> 
> 3 of 5 knfsd: avoid nfsd CPU scheduler overload
> 	avoid enormous load averages and CPU scheduler overload
> 	with workloads which generate extremely high call rates

Not sure I quite understand all the implications of this yet.
There would have to be lots of active sockets because each socket can
only be waking one thread.  But that is entirely possible with TCP.
So a request comes in on a TCP socket and we decide not to queue it to
a process just yet, so it stays on the pool queue.
That means it doesn't get handled until some process in the queue
finishes it's request.  
These seems to suggest quite some room for unfairness on request
handling.
That may not be a problem, but I'm not sure...
Maybe when one thread wakes up it should kick the next one to wake
up???
Or am I missing something.

> 
> 4 of 5 knfsd: add RPC pool thread stats
> 	add some statistics to the svc_pool

Could we get a paragraph or 3 explaining how to interpret these stats?
And we have to do something about svc_put.  With this patch as it
stands, if you:
  write some sockets to 'portlist' (with no threads running)
  look at the pool stats
  try to start thread
the ports will have been forgotten because looking at the pool
stats destroyed the ports...

> 
> 5 of 5 knfsd: remove nfsd threadstats
> 	remove the 'th' stats line from /proc/net/rc/nfsd, it's
> 	a global contention point in high call rate workloads
> 

Yes..... I can appreciate all the problems that you identify.
But before removing this I would like to have something to replace it.
Some that gives some sort of vague idea about whether you have a
suitable number of threads or not.
Does your pool stats provide that at all?

What I would really like it auto-scaling of the number of threads to
match the load.  I wonder if that is a good idea?

NeilBrown



> Greg.
> -- 
> Greg Banks, R&D Software Engineer, SGI Australian Software Group.
> I don't speak for SGI.
> 

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
