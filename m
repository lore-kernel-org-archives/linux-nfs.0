From: Erik Walthinsen <omega@pdxcolo.net>
Subject: Re: NAS server avalanche overload
Date: Wed, 03 Mar 2004 16:20:38 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1078359638.813.71.camel@localhost>
References: <1078302718.825.67.camel@localhost>
	 <1078351343.821.28.camel@localhost>  <20040304000438.GA25910@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aygh9-0005vz-Nh
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 16:26:35 -0800
Received: from mail.pdxcolo.net ([64.146.134.17] helo=palantir.pdxcolo.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AygIL-0007Yz-Fk
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 16:00:57 -0800
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040304000438.GA25910@sgi.com>
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

On Wed, 2004-03-03 at 16:04, Greg Banks wrote:
> And the export options are?  cat /etc/exports on the server.
/array/01-moria *.nas.pdxcolo.net(rw,no_root_squash,async)

> The noatime option has no effect over NFS.  Your [rw]sizes are
> really quite small, try 8K.  Also, try turning off noac.
The rwsizes were set based on a set of experiments with different sizes,
with 4k yielding by far the best bandwidth performance.  The limiting
factor there is that the gig switch we have atm doesn't handle jumbo
frames.  If increasing the rwsizes will reduce actual IO/sec load, then
it's worth trying even if it does reduce max bandwidth.  In reality, the
theoretical max is almost never approached, so it's probably not a huge
deal.

> So did you get the collapse with sync ?
The sync/async testing was done before migrating everything to the NAS,
and these spikes started showing up as load increased many months later
on.  Can only try sync after the next downtime coming up in about a
month.

> The problem I've seen is that the data is written out from the page
> cache with the BKL held, which prevents any nfsd thread from waking up
> and responding to incoming requests, and NFS traffic drops to zero.
> In addition, if any of the nfsd's owned some other lock when this
> happened, some local processes can be blocked too.  This is an
> inevitable result of the "async" export option.
That sounds like the kind of scenario I've been imagining.  Are there
any (stable) patches to get rid of the BKL in this case, or do I have to
wait until we move to 2.6 for that?  Alternately, would reducing the
number of nfsd's help?  Since there are only 2 heavy and 2-3 light
physical clients, is 16 overkill?

> You could try reducing the 1st parameter in /proc/sys/vm/bdflush
> to say 5 and decrease the 5th parameter by a similar factor.  This
> will activate kupdated more frequently and it will write data out
> earlier.  But, did I mention the "sync" export option?
OK, I'll give that a shot and see if it makes a dent in tonight's
spike(s).  . . . Oddly enough, I just checked the graphs and a spike is
going on now, but looks like I caught the tail end only.  I made the
bdflush changes, but cannot determine whether it's the end of the spike
or a bdflush-related termination.

- Omega
  aka Erik Walthinsen
  omega@pdxcolo.net



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
