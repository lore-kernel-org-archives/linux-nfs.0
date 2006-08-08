From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0 of 5] knfsd: miscellaneous performance-related
	fixes
Date: Tue, 8 Aug 2006 21:25:44 +1000
Message-ID: <17624.29880.852610.256270@cse.unsw.edu.au>
References: <1155009879.29877.229.camel@hole.melbourne.sgi.com>
	<17624.17621.428870.694339@cse.unsw.edu.au>
	<1155032558.29877.324.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAPia-0003AG-5o
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 04:25:52 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GAPia-00046f-5n
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 04:25:52 -0700
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
> On Tue, 2006-08-08 at 18:01, Neil Brown wrote:
> > On Tuesday August 8, gnb@melbourne.sgi.com wrote:
> > > G'day,
> > > 
> > > Five more patches which fix various issues found in knfsd,
> > > mostly directly performance-related.
> > 
> > Thanks.  I'll have a bit more of a look in a day or two,
> 
> Suddenly we've all got a lot of reading to do  ;-)
> 

I've taken to reading kids fantasy novels recently.  Nice and light,
yet still entertaining (e.g. The Quentaris Chronicles).

> 
> I'm still working on another patch (it only recently became possible
> with the ktime_t code) which replaces threadstats fully.  That patch
> adds nanosecond resolution busy and idle counters to each thread,
> then aggregates them per-pool when you read the pool_stats file.
> After export to userspace and rate conversion, these numbers tell
> us directly what percentage of the nfsds are currently being used.
> 
> That patch worked on two platforms some weeks ago, but I'm not sure
> it's ready for primetime.  I can post it for comment if you like?

Please!
I always feel a bit guilty complaining about a patch that has been
thoroughly tested and polished.  Seeing things early removed the guilt :-)


> 
> > What I would really like it auto-scaling of the number of threads to
> > match the load.  I wonder if that is a good idea?
> 
> Yes it is.
> 
> The original purpose of the pool_stats file was to drive a userspace
> balancing daemon to do that, and I have written most of such a daemon.
> The trouble is that measuring demand for nfsds from what meagre stats
> it was possible to measure in a 2.6.9 kernel proved difficult.  The
> new pool idle counter provides a direct measure of the excess nfsd
> capacity, which it will be then easy to write a control loop for.

sounds grand!

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
