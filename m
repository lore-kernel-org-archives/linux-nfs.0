From: Ryan Sweet <rsweet@atos-group.nl>
Subject: Re: 2.4.18 knfsd load spikes
Date: Thu, 16 May 2002 09:52:40 +0200 (MEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.30.0205160949530.8047-100000@whitby.atos-group.nl>
References: <3CE2D6A7.64EC2FFF@atheros.com>
Reply-To: Ryan Sweet <rsweet@atos-group.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ryan Sweet <rsweet@atos-group.nl>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [62.58.73.254] (helo=ats-core-0.atos-group.nl)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178GFI-0008SN-00
	for <nfs@lists.sourceforge.net>; Thu, 16 May 2002 01:04:20 -0700
To: Jeff Smith <jeff@atheros.com>
In-Reply-To: <3CE2D6A7.64EC2FFF@atheros.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


hmm, I'm not convinced that we have _the_ same problem, but possibly they
are related.  In particular my cpu utilisation (dual PIII733) is minimal
when this happens.  What filesystems/NICS are you using? My server is
using an intel e1000.

I will test the program on a local disk to see if it also causes the
problem.

-ryan

On Wed, 15 May 2002, Jeff Smith wrote:

> Ahhhh... Welcome to my hell.  I'm experiencing something similar but
> have no resolution.  Here is the exchange I had with Roger Heflin who
> also had a similar problem.  I was hoping this would go away with 2.4,
> but your experience leaves me very worried...
>
>
> "Heflin, Roger A." wrote:
>
> Compile it,
> run it with ./slowspeed . 65536 .0002 10
>
> This will write 10 files in a round robbin fashion, it will rewind just
> before
> it hits 2GB and start over again.   65536 is the block size which should
> eliminate any disk head thrash issues.   The .0002 is a sleep time to
> use and may not really be sleeping much at all during this test.
>
> You will need about 20GB (10x2GB per file) to run this test, and the
> IO rates will be pretty good for a while and then will slowly start to
> drop over the next few hours until things become pretty bad.   It
> appears
> to work over NFS or on local disk, it does not appear to work if you
> decrease the number of files to write to at the same time.
>
> Our machines are 440GX/BX's for the disk nodes with ASUS P2D's,
> we have been using the older slower machines for the disk as they
> seem to have no real issues until this happens, and then the faster
> machines appear to do no better.   The disk nodes have 1GB ram.
>
> I went to eXtreme 3000 controllers and I like them more than the
> LVD scsi controllers (2000,1100), they appear to be less sensitive
> to cabling issues with the copper fiber channel.
>
>                                 Roger
>
> > -----Original Message-----
> > From: Jeff Smith [SMTP:jeff@atheros.com]
> > Sent:  3/ 08/ 2002 12:41 PM
> > To:   Heflin, Roger A.
> > Subject:      Re: [NFS] IO write rate problem with multiple writers to
> > different files
> >
> > Is is possible to send me the test as well so that I can verify that
> > I'm
> > experiencing the same problem?
> >
> > Thanks,
> > Jeff
> >
> > "Heflin, Roger A." wrote:
> > >
> > > I am talking to Alan Cox and he seems interested in the problem,
> > > I have figured out that running the same job on the local machine
> > with
> > > multiple writers also kills the IO rate and have a fairly small test
> > > job that nicely duplicates the problem.  I will be sending this to
> > Alan
> > > to see if it occurs on other kernels, and if so if it can be fixed
> > on on
> > > the
> > > other kernel and maybe on the 2.2 series.
> > >
> > > I am pretty leary of the 2.4 kernels as 2.2.19 is very very stable
> > and
> > > I don't know if 2.4 has this kind of stability.
> > >
> > >                                 Roger
> > >
> > > > -----Original Message-----
> > > > From: Jeff Smith [SMTP:jeff@atheros.com]
> > > > Sent:  3/ 08/ 2002 10:40 AM
> > > > To:   Heflin, Roger A.; Stephen Padnos
> > > > Subject:      Re: [NFS] IO write rate problem with multiple
> > writers to
> > > > different files
> > > >
> > > > Be comforted that you are not alone.  Every time we go through a
> > chip
> > > > tapeout, the number of large jobs rises, causing our NFS servers
> > to
> > > > suddenly fall off a cliff and exhibit the same symptoms (low IO
> > rate
> > > > plummets and the CPU utilization goes to 100%, all of it taken by
> > the
> > > > nfsd's).  We are running 2.2.18.
> > > >
> > > > We've been trying for six months to find a window where we can
> > upgrade
> > > > to 2.4.X and pray that this resolves the problem, but these are
> > > > production server and cannot afford any downtime.
> > > >
> > > > Let me know if you get any unposted responses.  I posted query a
> > few
> > > > months back, but no solutions were forthcoming.  I would like to
> > feel
> > > > confident that whatever we try next will actually resolve the
> > problem.
> > > >
> > > > Jeff
> > > >
> > > >
> > > >
> > > > "Heflin, Roger A." wrote:
> > > > >
> > > > > Any ideas on increasing write IO rates in this situation?
> > > > >
> > > > > I am running 2.2.19 with the NFS released about the 2.2.19 was
> > > > released,
> > > > > and
> > > > > the IO writes slow down massively when there are multiple write
> > > > streams,
> > > > > it seems
> > > > > to require several files to be being written to a the same time.
> > > > The
> > > > > same behavior
> > > > > is not noticed with only 1 or 2 files being open and being
> > written
> > > > to.
> > > > > For the
> > > > > behavior to happen it takes 60+ minutes of sustained IO, the
> > buffer
> > > > > cache fills
> > > > > in the expected 2-4 minutes, and then things look pretty good
> > for
> > > > quite
> > > > > a while
> > > > > and around 60 minutes the IO rates start to fall until they hit
> > > > about
> > > > > 1/4-1/8 of
> > > > > the IO rate after the buffercache was filled.   The machines are
> > > > being
> > > > > run with
> > > > > sync exports and sync mounts, but the problem was also observed
> > with
> > > > > sync
> > > > > mounts and async exports.
> > > > >
> > > > > The NFSd go to useing 60-80% of a dual cpu 600mhz PIII and the
> > IO
> > > > rate
> > > > > falls
> > > > > down to around 1.1-1.8 MB/second,  and machine response
> > generally
> > > > falls
> > > > > apart.
> > > > > I don't understand why the NFSd are using this sort of cpu to do
> > > > this
> > > > > low of IO
> > > > > rate.
> > > > >
> > > > > The application is writing the data in 128kb chunks, and the
> > duty
> > > > cycle
> > > > > on
> > > > > the disk lights is under 50%.
> > > > >
> > > > > How does NFS interact with the kernel buffercache and could the
> > > > > buffercache
> > > > > be causing the problem?
> > > > >                                 Roger
> > > > >
> > > > > _______________________________________________
> > > > > NFS maillist  -  NFS@lists.sourceforge.net
> > > > > https://lists.sourceforge.net/lists/listinfo/nfs
> > > >
> > > > --
> > > > Jeff Smith                                  Atheros
> > Communications,
> > > > Inc.
> > > > Hardware Manager                            529 Almanor Avenue
> > > > (408) 773-5257                              Sunnyvale, CA  94086
> >
> > --
> > Jeff Smith                                  Atheros Communications,
> > Inc.
> > Hardware Manager                            529 Almanor Avenue
> > (408) 773-5257                              Sunnyvale, CA  94086
>
> Ryan Sweet wrote:
> >
> > I didn't get any responses to the message below, but I _did_ bite the
> > bullet and update the IRIX systems, and now the 64bit filehandle problem
> > is solved.
> >
> > However, the performance problem is not.  With 2.4.18+xfs1.1, It is
> > definitely better (the load spikes to 7 or 8, sometimes 10, instead of 20
> > or 30...), but I still get the periods where suddenly the system will
> > respond _very_ slowly, cpu is mostly idle, memory is all used, but only
> > for cache, the system is not swapping at all, but the load climbs up and
> > up.  It then gradually falls back down.  The top processes are usually
> > bdflush and kupdated, with kupdated always in the dead wait (DW) state.
> > It is basically the same behaviour that we saw with 2.4.[2|5]+xfs1.0.2,
> > though not as painful.  The problem usually lasts for 3 or four minutes,
> > then subsides.
> >
> > The problem seemed to begin around the time we added a few new, really
> > fast compute workstations, each of which is periodically doing thousands
> > of small writes/reads.  I cannot yet make a direct correlation, however,
> > until I can get a decent tcpdump.
> >
> > does anyone have any pointers on where to begin looking?  Have other
> > people seen this behaviour?
> >
> > thanks,
> > -Ryan
>
> ...
>
> > Ryan Sweet <ryan.sweet@atosorigin.com>
> > Atos Origin Engineering Services
> > http://www.aoes.nl
> >
> > _______________________________________________________________
> >
> > Have big pipes? SourceForge.net is looking for download mirrors. We supply
> > the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
>
>

-- 
Ryan Sweet <ryan.sweet@atosorigin.com>
Atos Origin Engineering Services
http://www.aoes.nl



_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
