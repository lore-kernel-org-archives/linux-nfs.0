From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH 6/8] knfsd: repcache: use client IP address in hash
Date: Mon, 16 Oct 2006 20:59:09 +1000
Message-ID: <20061016105909.GD8568@sgi.com>
References: <1160566130.8530.17.camel@hole.melbourne.sgi.com>
	<1160620200.6596.36.camel@lade.trondhjem.org>
	<17714.60948.856931.650829@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZQBp-0001iM-Ds
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 03:59:25 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GZQBm-0008F2-6I
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 03:59:26 -0700
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

On Mon, Oct 16, 2006 at 12:27:32PM +1000, Neil Brown wrote:
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

;-)

> I'm not suggesting either approach is right or wrong - just that it is
> thought provoking.
> 
> Greg: did you have measurements to suggest that a Jenkins hash was too
> expensive?   Did it just increase CPU load a bit, or did it affect
> throughput?

Fmeh.  Reading my notes again, I had the following observations.

With the original hash function, testing with a fixed call rate showed
the probe rate graph had an interesting periodic behaviour, sawtooth
IIRC, with a significant variation of number of probes per call.
This lead me to conclude that the spectral properties of the hash
function were poor (I didn't actually dump the hash table to confirm).

Then I tried changing the hash function to a Jenkins hash of the XID
and the client IP address.  This significantly reduced the CPU time
spent in nfsd_cache_lookup in the single-node case, and the graph
of probe rate became flat indicating better spectral properties,
which is all very wonderful.  However in the 2-node test all the CPU
usage came back, and the saturation call rate dropped from about 80
Kcalls/sec to about 77 Kcalls/sec.

So I think what was happening was that the improved spectral properties
of the hash function helped make the chains a more consistent length
but did nothing to reduce the cacheline bouncing due to CPUs from
multiple nodes writing to the same cacheline in the hash index.

In light of this I can't explain what I was smoking when I wrote the
comment about "CPU cost of calculating it".  Sorry.

Nevertheless, I think an MD5 would have the same behaviour as I
observed with the Jenkins hash.

In retrospect, there are a couple of other approaches I might
have tried if I'd had the time:

 *  Use multiple hashes, keyed on XID only and attached to the
    struct ip_map (might suffer from potential lifetime problems
    without another data structure to manage the hashes).

 *  Change the algorithm to avoid writing to two hash index
    cachelines on every lookup in the steady-state case (not
    even sure if this is possible).

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
