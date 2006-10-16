From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 6/8] knfsd: repcache: use client IP address in	hash
Date: Mon, 16 Oct 2006 09:42:49 -0400
Message-ID: <1161006169.16226.85.camel@lade.trondhjem.org>
References: <1160566130.8530.17.camel@hole.melbourne.sgi.com>
	<1160620200.6596.36.camel@lade.trondhjem.org>
	<17714.60948.856931.650829@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Greg Banks <gnb@melbourne.sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZSkP-0000X8-Kq
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 06:43:17 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GZSkN-0002ht-9H
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 06:43:18 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17714.60948.856931.650829@cse.unsw.edu.au>
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

On Mon, 2006-10-16 at 12:27 +1000, Neil Brown wrote:
> On Wednesday October 11, trond.myklebust@fys.uio.no wrote:
> > On Wed, 2006-10-11 at 21:28 +1000, Greg Banks wrote:
> > > knfsd: Use the client's IP address in the duplicate request cache
> > > hash function, instead of just the XID.  This avoids contention
> > > on hash buckets when the workload has many clients whose XIDs are
> > > nearly in lockstep, a property seen on compute clusters using NFS
> > > for shared storage.
> > 
> > Note that some platforms (in particular the *BSDs) use an MD5 checksum
> > of the first couple of 100 bytes of the RPC header+message instead of
> > relying on the XID. That is a good deal safer w.r.t. port reuse by other
> > clients etc.
> 
> I'm amused at the juxtaposition here.
> We have the possibility of using an MD5 hash over 100 bytes in a
> comment on patch containing the comment
> 
> + * Experiment shows that using the Jenkins hash improves the spectral
> + * properties of this hash, but the CPU cost of calculating it outweighs
> + * the advantages.
> 
> If a Jenkins hash is too expensive, I suspect MD5 would be even more
> so...

The point of using the checksum is to avoid having to save the incoming
RPC message itself in the replay cache. i.e. the goal is data
compression. That is indeed likely to require a tradeoff in the form of
more CPU.

In a mainly TCP world, the point of the replay cache is almost always to
deal with the scenario where a network partition causes the connection
to be lost so that the client has to wait for the partition to heal,
then reconnect before finally replaying the request. Sod's law implies
that this is most likely to happen while the other clients are hammering
at the server at full blast.
That means you have to design the cache to hold large amounts of data
for long periods of time in order to be useful (hence compression).

BTW: It also means that a LRU algorithm for cache evictions is the wrong
thing to do. In fact the least recently used entry is likely to be the
most significant when you have a failure scenario like the above.

Cheers,
  Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
