From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: NAS server avalanche overload
Date: Thu, 04 Mar 2004 12:40:14 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <404688FE.69592A2A@melbourne.sgi.com>
References: <1078302718.825.67.camel@localhost>
		 <1078351343.821.28.camel@localhost>  <20040304000438.GA25910@sgi.com> <1078359638.813.71.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AyhwD-0002tC-7K
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 17:46:13 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=zok.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AyhXJ-0006HJ-4H
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 17:20:29 -0800
To: Erik Walthinsen <omega@pdxcolo.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Erik Walthinsen wrote:
> 
> On Wed, 2004-03-03 at 16:04, Greg Banks wrote:
> > And the export options are?  cat /etc/exports on the server.
> /array/01-moria *.nas.pdxcolo.net(rw,no_root_squash,async)

Aha.

> > The noatime option has no effect over NFS.  Your [rw]sizes are
> > really quite small, try 8K.  Also, try turning off noac.
> The rwsizes were set based on a set of experiments with different sizes,
> with 4k yielding by far the best bandwidth performance.  The limiting
> factor there is that the gig switch we have atm doesn't handle jumbo
> frames. 

That really shouldn't make a difference; both 4K and 8K IOs will end
up being split over multiple ethernet frames.

> If increasing the rwsizes will reduce actual IO/sec load, then
> it's worth trying even if it does reduce max bandwidth.  In reality, the
> theoretical max is almost never approached, so it's probably not a huge
> deal.

Generally speaking, larger IOs are more efficient for heavy streaming
reads and writes.  The best parameters will depend on your workload.

> > The problem I've seen is that the data is written out from the page
> > cache with the BKL held, which prevents any nfsd thread from waking up
> > and responding to incoming requests, and NFS traffic drops to zero.
> > In addition, if any of the nfsd's owned some other lock when this
> > happened, some local processes can be blocked too.  This is an
> > inevitable result of the "async" export option.
> That sounds like the kind of scenario I've been imagining.  Are there
> any (stable) patches to get rid of the BKL in this case, 

Not AFAIK.  Trond?  It would in any case be a fairly adventurous patch.

> or do I have to
> wait until we move to 2.6 for that? 

Sorry, I haven't tried this on 2.6 yet.

> Alternately, would reducing the
> number of nfsd's help?  

No, that will either have no effect or reduce the throughput when things
are going well.

> Since there are only 2 heavy and 2-3 light
> physical clients, is 16 overkill?

Probably not.

You need more than 1 nfsd per client, because (assuming you don't have
the sync *mount* option on the clients) the clients will be issuing
multiple (up to 16 for 2.4.x) rpc calls in parallel each.  The number
that is useful is limited (at least on my machines) by the nfsd's doing
time consuming memcpy()s with the BKL; absent this even more nfsds
would be useful.

> > You could try reducing the 1st parameter in /proc/sys/vm/bdflush[...]
> OK, I'll give that a shot and see if it makes a dent in tonight's
> spike(s).  . . . Oddly enough, I just checked the graphs and a spike is
> going on now, but looks like I caught the tail end only.  I made the
> bdflush changes, but cannot determine whether it's the end of the spike
> or a bdflush-related termination.

With the bdflush changes I mentioned you'll still get spikes, just hopefully
they'll be short enough that you won't notice.  What you want to do is get
them so short that the clients don't hit a major RPC timeout.

Also, making the changes won't help a spike in progress.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
