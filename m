From: Neil Horman <nhorman@redhat.com>
Subject: Re: SMP, NFS, and 2.6
Date: Thu, 31 Mar 2005 08:17:34 -0500
Message-ID: <20050331131734.GC1328@hmsendeavour.rdu.redhat.com>
References: <111aefd050329125848955802@mail.gmail.com> <20050329211324.GK22447@hmsendeavour.rdu.redhat.com> <111aefd05033008401742da5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DGzYI-0006jv-1L
	for nfs@lists.sourceforge.net; Thu, 31 Mar 2005 05:17:38 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DGzYG-0006Tl-3x
	for nfs@lists.sourceforge.net; Thu, 31 Mar 2005 05:17:37 -0800
To: penney@msu.edu
In-Reply-To: <111aefd05033008401742da5@mail.gmail.com>
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

On Wed, Mar 30, 2005 at 11:40:03AM -0500, Chris Penney wrote:
> On Tue, 29 Mar 2005 16:13:24 -0500, Neil Horman <nhorman@redhat.com> wrote:
> > On Tue, Mar 29, 2005 at 03:58:02PM -0500, Chris Penney wrote:
> > > I've heard from some (via google searchs) that there are issues with
> > > NFS + SMP when using the 2.6 kernel.  Assuming I'm using 2.6.11.5 w/
> > > the NFS-ALL patches applied should I be concerned about running SMP
> > > (dual cpu pentium 4 doing pretty much only NFSv3 TCP, but looking
> > > toward NFSv4)?
> > >
> > > Assuming it's ok to use SMP on a heavy use NFS server, should I enable
> > > or disable hyperthreading?  I'd assume that for NFS hyperthreading
> > > would be good, but that's only a guess.
> > >
> > > Thanks,
> > >
> > >    Chris
> > >
> > Are you referring to the dcache problems with XFS?  I think it was only a
> > problem when the NFS server was exporting an XFS file system.  I also haven't
> > checked in some time, but I believe those problems have since been fixed.
> > 
> > Neil
> 
> Yes, most of what I read was regarding XFS.  I was not sure if there
> were any issues outside of that (I'm using JFS right now).
> 
None that I'm aware of, but my knoweldge is far from exhaustive :)

> As far as HyperThreading my testing so far has shown that under heavy
> loads enabling HyperThreading on a dual-cpu P4 box seems to be a good
> thing.  I would grab 30s of packets with ethereal and look at the NFS
> stats and the responce time on writes/commits (which we see a fair bit
> of) were at least 33% faster if not more.  I'm not sure if that's an
> accurate way to measure though -- I know enough to be dangerous, but
> I'm not an expert.
> 
Neither am I :).  You testing seems reasonable to me (at least for what you are
trying to measure currently).  IIRC the Linux scheduler is built to take
advantage of the shared resources available on hyperthreaded processors and
schedules accordingly.  In general I think its a good idea to turn on.  I
believe there are some pessimal workloads that can cause worse performance with
HT on, than with HT off, but I believe you really have to work hard to produce
those.

Regards
Neil

>    Chris
> 
> 
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.
> http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/


-------------------------------------------------------
This SF.net email is sponsored by Demarc:
A global provider of Threat Management Solutions.
Download our HomeAdmin security software for free today!
http://www.demarc.com/Info/Sentarus/hamr30
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
