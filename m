From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: [PATCH] 1/3 - RPC metrics support
Date: Wed, 31 Mar 2004 12:19:09 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1080753549.4194.60.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435DE34@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Patrick Mochel <mochel@digitalimplant.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B8jMv-0004WA-5g
	for nfs@lists.sourceforge.net; Wed, 31 Mar 2004 09:19:13 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B8jMu-0008Eq-SA
	for nfs@lists.sourceforge.net; Wed, 31 Mar 2004 09:19:13 -0800
To: Charles Lever <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435DE34@lavender-fe.eng.netapp.com>
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

On Wed, 2004-03-31 at 11:57, Lever, Charles wrote:
> > My experience with gettimeofday() was that it slows down and 
> > eventually hangs the machine when you use it inside bottom 
> > halves. That's why I had to revert to using 'jiffies' 
> > instead. While I agree that precision may be important, a 
> > measurement that so impacts on what it is measuring is not 
> > particularly useful either...
> 
> using jiffies makes these measurements useless for anything
> faster than a millisecond (or 10 milliseconds on current
> x86), which is most everything on 100Mb or faster, these
> days.  isn't there some other solution?

In 2.6. jiffies have 1 ms resolution, not 10 on x86. There may be some
alternative generic timing solution in Linux that does better than that,
and that can work within bottom halves without side-effects but I'm not
aware of such a solution.

You can of course use do_gettimeofday() for the non bh-safe parts if you
want to, but using it inside things like *data_ready() etc. was clearly
unacceptable.

The only generic solution I see is therefore to use statistics...

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
