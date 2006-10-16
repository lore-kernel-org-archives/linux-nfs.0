From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 6/8] knfsd: repcache: use client IP address in	hash
Date: Tue, 17 Oct 2006 08:49:28 +1000
Message-ID: <17716.3192.162021.735299@cse.unsw.edu.au>
References: <1160566130.8530.17.camel@hole.melbourne.sgi.com>
	<1160620200.6596.36.camel@lade.trondhjem.org>
	<17714.60948.856931.650829@cse.unsw.edu.au>
	<1161006169.16226.85.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Greg Banks <gnb@melbourne.sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZbH8-0005y6-5M
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 15:49:38 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GZbH7-0004PC-EM
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 15:49:39 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on Monday October 16
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

On Monday October 16, trond.myklebust@fys.uio.no wrote:
> On Mon, 2006-10-16 at 12:27 +1000, Neil Brown wrote:
> > On Wednesday October 11, trond.myklebust@fys.uio.no wrote:
> > > On Wed, 2006-10-11 at 21:28 +1000, Greg Banks wrote:
> > > > knfsd: Use the client's IP address in the duplicate request cache
> > > > hash function, instead of just the XID.  This avoids contention
> > > > on hash buckets when the workload has many clients whose XIDs are
> > > > nearly in lockstep, a property seen on compute clusters using NFS
> > > > for shared storage.
> > > 
> > > Note that some platforms (in particular the *BSDs) use an MD5 checksum
> > > of the first couple of 100 bytes of the RPC header+message instead of
> > > relying on the XID. That is a good deal safer w.r.t. port reuse by other
> > > clients etc.
> > 
> > I'm amused at the juxtaposition here.
> > We have the possibility of using an MD5 hash over 100 bytes in a
> > comment on patch containing the comment
> > 
> > + * Experiment shows that using the Jenkins hash improves the spectral
> > + * properties of this hash, but the CPU cost of calculating it outweighs
> > + * the advantages.
> > 
> > If a Jenkins hash is too expensive, I suspect MD5 would be even more
> > so...
> 
> The point of using the checksum is to avoid having to save the incoming
> RPC message itself in the replay cache. i.e. the goal is data
> compression. That is indeed likely to require a tradeoff in the form of
> more CPU.

Yeah... that makes sense.
Rejecting a write request based on a hash collision that didn't cover
the whole write request makes me a bit queezy, but it is probably not
going to be a problem in practice.

> 
> In a mainly TCP world, the point of the replay cache is almost always to
> deal with the scenario where a network partition causes the connection
> to be lost so that the client has to wait for the partition to heal,
> then reconnect before finally replaying the request. Sod's law implies
> that this is most likely to happen while the other clients are hammering
> at the server at full blast.
> That means you have to design the cache to hold large amounts of data
> for long periods of time in order to be useful (hence compression).
> 
> BTW: It also means that a LRU algorithm for cache evictions is the wrong
> thing to do. In fact the least recently used entry is likely to be the
> most significant when you have a failure scenario like the above.
> 

I can see your point, but I cannot think of a better cache eviction
algorithm ... other than "discard when we get a TCP-ACK for the
reply".  I really like that idea.  Might be fiddly to implement
though.

For UDP I guess we are stuck with LRU and crossing fingers.

It probably makes sense to have quite separate caches for UDP and
TCP. with very different disciplines.

Thanks for the thoughts.

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
