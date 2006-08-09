From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 0 of 5] knfsd: miscellaneous
	performance-related	fixes
Date: Wed, 09 Aug 2006 12:37:36 +1000
Message-ID: <1155091055.16378.14.camel@hole.melbourne.sgi.com>
References: <1155009879.29877.229.camel@hole.melbourne.sgi.com>
	<17624.17621.428870.694339@cse.unsw.edu.au>
	<1155032558.29877.324.camel@hole.melbourne.sgi.com>
	<20060808154923.GA28855@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAdx4-0006AD-MQ
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 19:37:46 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GAdx4-0002pS-2R
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 19:37:47 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20060808154923.GA28855@fieldses.org>
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

On Wed, 2006-08-09 at 01:49, J. Bruce Fields wrote:
> On Tue, Aug 08, 2006 at 08:22:44PM +1000, Greg Banks wrote:
> > I'm still working on another patch (it only recently became possible
> > with the ktime_t code) which replaces threadstats fully.  That patch
> > adds nanosecond resolution busy and idle counters to each thread,
> > then aggregates them per-pool when you read the pool_stats file.
> > After export to userspace and rate conversion, these numbers tell
> > us directly what percentage of the nfsds are currently being used.
> 
> Would it be possible to use that to continue to support the existing
> interface (the "th" line)?

No, the formats are really quite different.

> It'd be nice if we could avoid ripping out a working user interface that
> someone might be using....

I agree, but I don't believe a) it's working or b) anyone could
be getting any use out of it.

An earlier version of the patch left the data structures in place
and just reported them as zeros in the /proc file.  Would that
be preferrable?

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
