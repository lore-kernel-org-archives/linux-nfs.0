From: Ian Kent <raven@themaw.net>
Subject: Re: RE: Linux client on Solaris 7 NFS server
Date: Tue, 6 Jan 2004 12:42:17 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0401061229170.26529-100000@wombat.indigo.net.au>
References: <200401051731.i05HVaa15457@supercomputer.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Adj32-00058D-Dc
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 20:42:32 -0800
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Adj31-00039P-Ow
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 20:42:32 -0800
To: <dwight@supercomputer.org>
In-Reply-To: <200401051731.i05HVaa15457@supercomputer.org>
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

On Mon, 5 Jan 2004 dwight@supercomputer.org wrote:

> Ian Kent wrote:
> > Currently I'm running the RedHat 2.4.20-20.7 kernel.
> >
> > I used UDP transport for a long time but have recently changed to TCP for
> > nearly all my clients.
> > ...
> >
> > My usage is largely read.
> >
> > Performance has improved quite a bit as the kernel version has increased.
> > I can get around 80% (ie. 80% wire speed) the throughput of a 'similar'
> > Sun. Problem is that most of the Sparc clients can saturate 100Mb (onto a
> > gigabit backbone) so I don't really know what the difference is.
> >
> > Ian
>
> Thanks for the information, Ian.
>
> So if I understand you correctly, you are saying that your performance for Linux clients and Solaris clients with a Solaris server is the same? Or that any
> difference is not notiable?

I had some figures, but I've deleted them.

Basically I'm saying, with a 100Mb(it)/sec interface I get just over
8 MB(ytes)/sec whereas I can consistently get over 10MB(ytes)/sec on most
Sparcs (Solaris). So the Sparcs are pushing their interfaces about fast as
they can go but the Linux box is not. So there's still room for
improvement.

>
> Would you happen to know what throughput you are seeing with the Linux
> client? My own, as reported by Ethereal, is about 11 Mbs in this case.
>
> My transactions are a combination of read and write (mimicking the common
> behavior that we use in a production environment). I appreciate the information;
> I'll try a test of pure reads.
>
> And yes, I too have saturated a 100-Mb switch before, though not with NFS.
> The statistics on the switch in the production environment show that we're
> nowhere near saturating the switch. For my test environment, there's almost
> nothing else going on at the time (I.e. one client, one server). While I could
> just use a cross-over cable and eliminate the switch, I don't see any information
> indicating that this would improve things at this time.

Not talking about the switch the clients are connected to but the
interface on the client. I expect the switches can deal with a good deal
more that a single client going fat tack.

Ian






-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
