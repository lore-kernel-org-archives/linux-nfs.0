From: Anders Saaby <as@cohaesio.com>
Subject: Re: SMP, NFS, and 2.6
Date: Mon, 4 Apr 2005 14:33:38 +0200
Message-ID: <200504041433.39149.as@cohaesio.com>
References: <111aefd050329125848955802@mail.gmail.com> <111aefd05033008401742da5@mail.gmail.com> <20050331131734.GC1328@hmsendeavour.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Neil Horman <nhorman@redhat.com>, penney@msu.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DIQlm-00022v-5s
	for nfs@lists.sourceforge.net; Mon, 04 Apr 2005 05:33:30 -0700
Received: from penguin.cohaesio.net ([212.97.129.34] helo=mail.cohaesio.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DIQll-0006P6-2n
	for nfs@lists.sourceforge.net; Mon, 04 Apr 2005 05:33:30 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20050331131734.GC1328@hmsendeavour.rdu.redhat.com>
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

Hi,

I don't know if you originally referred to some of my earlier posts here and 
on LKML regarding instability on 2.6 (2.6.8.1) with SMP...

There where, from my experience two separate problems:

The dcache problems which was fixed in 2.6.10.

One or more issues producing Oops's on SMP machines. I am not sure if they 
where NFS bound (actually I dont think they where, but I only saw them on one 
of our high-load NFS servers). I found out that running the system in UP mode 
made the server stable.

Back when I had the problems, I tested on 2.6.8.1 and haven't dared to try SMP 
since, so my knowledge is a bit ageing. But if you decide you are up for it, 
I would be very interested in the results! ....SMP would be nice on those 
XEON boxes.

//Saaby

On Thursday 31 March 2005 15:17, Neil Horman wrote:
> On Wed, Mar 30, 2005 at 11:40:03AM -0500, Chris Penney wrote:
> > On Tue, 29 Mar 2005 16:13:24 -0500, Neil Horman <nhorman@redhat.com> 
wrote:
> > > On Tue, Mar 29, 2005 at 03:58:02PM -0500, Chris Penney wrote:
> > > > I've heard from some (via google searchs) that there are issues with
> > > > NFS + SMP when using the 2.6 kernel.  Assuming I'm using 2.6.11.5 w/
> > > > the NFS-ALL patches applied should I be concerned about running SMP
> > > > (dual cpu pentium 4 doing pretty much only NFSv3 TCP, but looking
> > > > toward NFSv4)?
> > > >
> > > > Assuming it's ok to use SMP on a heavy use NFS server, should I
> > > > enable or disable hyperthreading?  I'd assume that for NFS
> > > > hyperthreading would be good, but that's only a guess.
> > > >
> > > > Thanks,
> > > >
> > > >    Chris
> > >
> > > Are you referring to the dcache problems with XFS?  I think it was only
> > > a problem when the NFS server was exporting an XFS file system.  I also
> > > haven't checked in some time, but I believe those problems have since
> > > been fixed.
> > >
> > > Neil
> >
> > Yes, most of what I read was regarding XFS.  I was not sure if there
> > were any issues outside of that (I'm using JFS right now).
>
> None that I'm aware of, but my knoweldge is far from exhaustive :)
>
> > As far as HyperThreading my testing so far has shown that under heavy
> > loads enabling HyperThreading on a dual-cpu P4 box seems to be a good
> > thing.  I would grab 30s of packets with ethereal and look at the NFS
> > stats and the responce time on writes/commits (which we see a fair bit
> > of) were at least 33% faster if not more.  I'm not sure if that's an
> > accurate way to measure though -- I know enough to be dangerous, but
> > I'm not an expert.
>
> Neither am I :).  You testing seems reasonable to me (at least for what you
> are trying to measure currently).  IIRC the Linux scheduler is built to
> take advantage of the shared resources available on hyperthreaded
> processors and schedules accordingly.  In general I think its a good idea
> to turn on.  I believe there are some pessimal workloads that can cause
> worse performance with HT on, than with HT off, but I believe you really
> have to work hard to produce those.
>
> Regards
> Neil
>
> >    Chris
> >
> >
> > -------------------------------------------------------
> > SF email is sponsored by - The IT Product Guide
> > Read honest & candid reviews on hundreds of IT Products from real users.
> > Discover which products truly live up to the hype. Start reading now.
> > http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs

-- 
Med venlig hilsen - Best regards - Meilleures salutations

Anders Saaby
Systems Engineer
------------------------------------------------
Cohaesio A/S - Maglebjergvej 5D - DK-2800 Lyngby
Phone: +45 45 880 888 - Fax: +45 45 880 777
Mail: as@cohaesio.com - http://www.cohaesio.com
------------------------------------------------


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
