From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS queue
Date: Mon, 2 Dec 2002 07:56:55 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D5511E@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18IswS-0001NJ-00
	for <nfs@lists.sourceforge.net>; Mon, 02 Dec 2002 07:57:04 -0800
To: "'Ramon Kagan'" <rkagan@YorkU.CA>
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

[ moving this to nfs-specific discussion list.  see below for comments. ]

> -----Original Message-----
> From: Ramon Kagan [mailto:rkagan@YorkU.CA] 
> Sent: Monday, December 02, 2002 8:20 AM
> To: Trond Myklebust
> Cc: linux-fsdevel@vger.kernel.org
> Subject: Re: NFS queue
> 
> 
> HI,
> 
> See below.
> 
> Thanks for your help.
> 
> Ramon Kagan
> York University, Computing and Network Services
> Unix Team -  Intermediate System Administrator
> (416)736-2100 #20263
> rkagan@yorku.ca
> 
> -------------------------------------
> I have not failed.  I have just
> found 10,000 ways that don't work.
> 	- Thomas Edison
> -------------------------------------
> 
> On Fri, 29 Nov 2002, Trond Myklebust wrote:
> 
> > >>>>> " " == Ramon Kagan <rkagan@YorkU.CA> writes:
> >
> >      > single system cannot handle the load.  So my first 
> inclination
> >      > was that the card couldn't handle that throughput but it's a
> >      > Gigbit card?  So I tested and easily pushed 250 Mb/s through
> >      > it.  So it's not the card.  Something on the system just went
> >      > nuts.  The only thing that made sense was NFS.
> >
> > If you are seeing 30Mbit/s on a Gigabit connection, then my 
> vote still 
> > goes to packet loss. I'm seeing ~25MByte/s on writes 
> against a filer 
> > when using 2.4.19 (and about 40MByte/s on reads).
> >
> I'm only using 30 Mb/s because that is what the service 
> currently needs, it's not a limitation.  I was able to create 
> a 250Mb/s load through the card to the filer.  Would I not 
> get the same behaviour if the card was the problem?

can you describe your application, network configuration,
and what performance level you expect?

> > When you did your ethereal test, did you run on both the 
> server side 
> > and the client side at the same time in order to compare 
> the number of 
> > packet send/receives that they see? Have you tried TCP?
> >
> I can't run ethereal on the server (filers don't have that 
> capability).

yes, they do.  type "pktt" on the filer's console for details.
this command generates raw tcpdump output into a file on the
filer's vol0.  you can then use ethereal to read the file.

> However I did get my Network team to sniff the 
> port and the counts matched.  So really I don't think it is 
> packet loss, but I could be wrong.  I will run another test 
> to make sure.  As for TCP, we are inherently unwilling to go 
> this way for failover reasons.  It has been my understanding 
> that most of our applications would just hang and "self 
> destruct" if we use NFS over TCP due to the statefulness.

TCP has nothing to do with NFS's "statefulness."  if failover
with TCP doesn't work, that's a bug and should be fixed.  can
you give any details about problems you've encountered with
failover?  what is your application?

> > You haven't mentioned which kernel you are running, or what your 
> > .config file looks like, so I can't answer your question concerning 
> > the load increase.
> >
> >      > BTW where are NFS patches (yours included) to be found?  Are
> >      > there a lot that help in performance?
> >
> Kernel is 2.4.18 and .config is attached.  Note that I've 
> added LVS group's hidden patch for direct routing (DR) load balancing.
>
> > See
> >    http://www.fys.uio.no/~trondmy/src/
> >
> 
> > Cheers,
> >   Trond
> >
> 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
