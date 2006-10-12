From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH 6/8] knfsd: repcache: use client IP address in hash
Date: Thu, 12 Oct 2006 18:21:26 +1000
Message-ID: <20061012082126.GM8568@sgi.com>
References: <1160566130.8530.17.camel@hole.melbourne.sgi.com>
	<1160620200.6596.36.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GXvp1-0000mi-DO
	for nfs@lists.sourceforge.net; Thu, 12 Oct 2006 01:21:43 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GXvp0-000690-5K
	for nfs@lists.sourceforge.net; Thu, 12 Oct 2006 01:21:44 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1160620200.6596.36.camel@lade.trondhjem.org>
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

On Wed, Oct 11, 2006 at 07:30:00PM -0700, Trond Myklebust wrote:
> On Wed, 2006-10-11 at 21:28 +1000, Greg Banks wrote:
> > knfsd: Use the client's IP address in the duplicate request cache
> > hash function, instead of just the XID.  This avoids contention
> > on hash buckets when the workload has many clients whose XIDs are
> > nearly in lockstep, a property seen on compute clusters using NFS
> > for shared storage.
> 
> Note that some platforms (in particular the *BSDs) use an MD5 checksum
> of the first couple of 100 bytes of the RPC header+message instead of
> relying on the XID. That is a good deal safer w.r.t. port reuse by other
> clients etc.
> 

I hear that there was a Cthon presentation on this subject.  It sounds
very interesting, does anyone have a URL?

I presume the approach involves masking out the IPID and TCP sequence
number?  Otherwise retries would never hash to the same value as the
original requests, thus defeating the repcache entirely.

Also, I'm not entirely convinced that a hash function which distributes
repcache entries more evenly across the hash table (which is what
I would expect an MD5 to do) is necessarily the best approach.
For one thing, that maximises the number of times that cachelines
need to be retrieved from remote nodes.  A better approach might be
to construct the hash function so that certain cachelines naturally
stay on certain CPUs.  I thought I'd done something like this, but
looking at the patch I sent it's dumber than that.


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
