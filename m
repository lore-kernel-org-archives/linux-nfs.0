From: Ramon Kagan <rkagan@YorkU.CA>
Subject: RE: NFS queue
Date: Mon, 2 Dec 2002 12:00:04 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0212021148350.10557-100000@centaur.ccs.yorku.ca>
References: <6440EA1A6AA1D5118C6900902745938E07D5511E@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailrelay.yorku.ca ([130.63.236.144] helo=sungoddess.ccs.yorku.ca)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ItvW-0004d1-00
	for <nfs@lists.sourceforge.net>; Mon, 02 Dec 2002 09:00:10 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D5511E@black.eng.netapp.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

HI,

See below

Ramon Kagan
York University, Computing and Network Services
Unix Team -  Intermediate System Administrator
(416)736-2100 #20263
rkagan@yorku.ca

-------------------------------------
I have not failed.  I have just
found 10,000 ways that don't work.
	- Thomas Edison
-------------------------------------

On Mon, 2 Dec 2002, Lever, Charles wrote:

> [ moving this to nfs-specific discussion list.  see below for comments. ]
>
> > -----Original Message-----
> > From: Ramon Kagan [mailto:rkagan@YorkU.CA]
> > Sent: Monday, December 02, 2002 8:20 AM
> > To: Trond Myklebust
> > Cc: linux-fsdevel@vger.kernel.org
> > Subject: Re: NFS queue
> >
> >
> > HI,
> >
> > See below.
> >
> > Thanks for your help.
> >
> > Ramon Kagan
> > York University, Computing and Network Services
> > Unix Team -  Intermediate System Administrator
> > (416)736-2100 #20263
> > rkagan@yorku.ca
> >
> > -------------------------------------
> > I have not failed.  I have just
> > found 10,000 ways that don't work.
> > 	- Thomas Edison
> > -------------------------------------
> >
> > On Fri, 29 Nov 2002, Trond Myklebust wrote:
> >
> > > >>>>> " " == Ramon Kagan <rkagan@YorkU.CA> writes:
> > >
> > >      > single system cannot handle the load.  So my first
> > inclination
> > >      > was that the card couldn't handle that throughput but it's a
> > >      > Gigbit card?  So I tested and easily pushed 250 Mb/s through
> > >      > it.  So it's not the card.  Something on the system just went
> > >      > nuts.  The only thing that made sense was NFS.
> > >
> > > If you are seeing 30Mbit/s on a Gigabit connection, then my
> > vote still
> > > goes to packet loss. I'm seeing ~25MByte/s on writes
> > against a filer
> > > when using 2.4.19 (and about 40MByte/s on reads).
> > >
> > I'm only using 30 Mb/s because that is what the service
> > currently needs, it's not a limitation.  I was able to create
> > a 250Mb/s load through the card to the filer.  Would I not
> > get the same behaviour if the card was the problem?
>
> can you describe your application, network configuration,
> and what performance level you expect?
>

All the servers are IMAP/POP servers.  Filers are clustered 840s, servers
are Dual P3 1.4 with 2 GB memory, all gigabit cards.  The router is a
Cisco Catalyst 6500.  If you look at previous messages in the original
thread you'll see that the problem 'may' be NFS, but I'm not sure.  I'm
looking for possible answers.  So, from previous messages:

"We have a web-based mail service that points to two of the machines using
LVS to load balance.  In testing I have found that if I have a 1:1 ratio
everything is fine.  Throughput on the ethernet cards is about 30 Mb/s,
workloads in the 1-1.5 range.  If I change the waitings to 5:2 the 5
weighted server still performs okay, load average about 1.25-1.7 and 45/50
Mb/s.  Now if I increase that to 3:1 weighting immediately the server goes
to 400-500 load average and throughput is still only about 50 Mb/s.  What
causes this dramatic increase?   This is a concern on system failure,
since I now know that the single system cannot handle the load.  So my
first inclination was that the card couldn't handle that throughput but
it's a Gigbit card?  So I tested and easily pushed 250 Mb/s through it.
So it's not the card.  Something on the system just went nuts.  The only
thing that made sense was NFS.  At the same time the Filer was feeding
data to hundreds of other NFS clients so the Filer was still working fine,
with excellent response times too."

> > > When you did your ethereal test, did you run on both the
> > server side
> > > and the client side at the same time in order to compare
> > the number of
> > > packet send/receives that they see? Have you tried TCP?
> > >
> > I can't run ethereal on the server (filers don't have that
> > capability).
>
> yes, they do.  type "pktt" on the filer's console for details.
> this command generates raw tcpdump output into a file on the
> filer's vol0.  you can then use ethereal to read the file.
>
Fair enough I may run the test again

> > However I did get my Network team to sniff the
> > port and the counts matched.  So really I don't think it is
> > packet loss, but I could be wrong.  I will run another test
> > to make sure.  As for TCP, we are inherently unwilling to go
> > this way for failover reasons.  It has been my understanding
> > that most of our applications would just hang and "self
> > destruct" if we use NFS over TCP due to the statefulness.
>
> TCP has nothing to do with NFS's "statefulness."  if failover
> with TCP doesn't work, that's a bug and should be fixed.  can
> you give any details about problems you've encountered with
> failover?  what is your application?
>
The one time we tested NFS over TCP and the NFS server was failed the
client would/could not recover.

> > > You haven't mentioned which kernel you are running, or what your
> > > .config file looks like, so I can't answer your question concerning
> > > the load increase.
> > >
> > >      > BTW where are NFS patches (yours included) to be found?  Are
> > >      > there a lot that help in performance?
> > >
> > Kernel is 2.4.18 and .config is attached.  Note that I've
> > added LVS group's hidden patch for direct routing (DR) load balancing.
> >
> > > See
> > >    http://www.fys.uio.no/~trondmy/src/
> > >
> >
> > > Cheers,
> > >   Trond
> > >
> >
>





-------------------------------------------------------
This SF.net email is sponsored by: Get the new Palm Tungsten T 
handheld. Power & Color in a compact size! 
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0002en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
