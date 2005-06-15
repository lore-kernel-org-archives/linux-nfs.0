From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: Re: NFS tuning - high performance throughput.
Date: Wed, 15 Jun 2005 18:43:52 -0400
Message-ID: <20050615224352.GD31465@ti64.telemetry-investments.com>
References: <20050610031144.4B9CA12F8C@sc8-sf-spam2.sourceforge.net> <42AF3B6C.6070901@sohovfx.com> <20050614204138.GG1175@ti64.telemetry-investments.com> <42AF5F0A.3080601@sohovfx.com> <20050615174701.GC31465@ti64.telemetry-investments.com> <42B09081.50405@sohovfx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Digc4-00076H-Nx
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 15:44:00 -0700
Received: from 209-166-240-202.cust.walrus.com ([209.166.240.202] helo=ti41.telemetry-investments.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Digc3-0007iR-1d
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 15:44:00 -0700
To: "M. Todd Smith" <todd@sohovfx.com>
In-Reply-To: <42B09081.50405@sohovfx.com>
Sender: nfs-admin@lists.sourceforge.net
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

On Wed, Jun 15, 2005 at 04:33:05PM -0400, M. Todd Smith wrote:
> I'll try out the new core-utils when I can (*hoping next week I can get 
> this server out of production*).

As someone else noted, iozone is a good benchmark, and it also
has a command-line switch for O_DIRECT.

> I'm  sorry what would writing to a virtual FS tell me in regards to
> my SAN, perhaps you can explain in more  detail?

It wouldn't tell you anything about your RAID storage, but it would give
you a good idea of the upper limit on knfsd write performance for small
files, since you'd be storing to RAM.  Read tests are as readily done just
by ensuring that the file is in the page cache; write tests with the real
fs are a bit harder.  Another "good-enough" option for estimating knfsd
performance limits may be to set the NFS export option to the unsafe
"async" mode, use a small ext2 filesystem, and look at small file write
throughput.  [After all, /tmp on ext2 was for many years about as fast
as Solaris tmpfs. :-)] Having done that, you'll know whether the storage
configuration is the proximate cause of the lousy performance.

> Ip:
>    446801331 total packets received
>    0 forwarded
>    0 incoming packets discarded
>    314401713 incoming packets delivered
>    256822806 requests sent out
>    5800 fragments dropped after timeout
>    143422528 reassemblies required
>    11022911 packets reassembled ok
>    246950 packet reassembles failed
>    48736566 fragments received ok

That's a fair number of reassembly failures.  In light of your
next point, you may want to look at the stats on the client side ...

> Regarding the bonding .. Writes to the SAN happen on a single port of 
> the NIC so in writing there are very few reorderings needed.  Reading 
> from the SAN breaks the read up on the four ports and so the most 
> reordering would be done client side (even worse most of our clients are 
> still RH 7.2).

OK, I just went and re-read bonding.txt. Thanks. :-)

> If I mix TCP and UDP NFS connections will speed be 
> slower than if I used just straight TCP conns?  I'll do some testing 
> next week and report my findings.

Well, as I said, I'm disinclined to run over UDP with such a large
r/wsize of 32K; we did that once-upon-a-time with Linux and Solaris
hosts talking to a NetApp, and the results were unpleasant; we had to
use r/wsize=8K until we were able to switch to TCP.  Things might look
fine with a single client running a benchmark, and look very different
on a congested network.  Also, I'm not sure about fairness with respect
to a mix of TCP and UDP clients; if the network is loaded and UDP starts
to timeout, will the UDP clients recover if the TCP clients are active?

> This as my first recommendation when I began here .. Is TSO stable
> enough for production level usage now?  Suse still turns it off by default.

As a general proposition, I'd say no to blindly using it without a good bit
of testing.  David S. Miller has been posting his rewritten TSO framework
to netdev in the last few weeks; perhaps by 2.6.13 ...

	-Bill


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
