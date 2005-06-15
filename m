From: "Roger Heflin" <rheflin@atipa.com>
Subject: RE: NFS tuning - high performance throughput.
Date: Wed, 15 Jun 2005 14:52:10 -0500
Message-ID: <EXCHG2003QtpfTYSl1q000005f2@EXCHG2003.microtech-ks.com>
References: <1118862823.22484.13.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "'M. Todd Smith'" <todd@sohovfx.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DiduS-0007Az-0G
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 12:50:48 -0700
Received: from host27-37.discord.birch.net ([65.16.27.37] helo=EXCHG2003.microtech-ks.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DiduP-00049N-E8
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 12:50:47 -0700
To: "'Dan Stromberg'" <strombrg@dcs.nac.uci.edu>
In-Reply-To: <1118862823.22484.13.camel@seki.nac.uci.edu>
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


The mount/remount (unless you time how long it takes to unmount),
will potentially still skew the write test, and the writes
will still be happening for quite a while after the dd completes.
 
                        Roger 

> -----Original Message-----
> From: Dan Stromberg [mailto:strombrg@dcs.nac.uci.edu] 
> Sent: Wednesday, June 15, 2005 2:14 PM
> To: Roger Heflin
> Cc: 'M. Todd Smith'; nfs@lists.sourceforge.net; 
> strombrg@dcs.nac.uci.edu
> Subject: RE: [NFS] NFS tuning - high performance throughput.
> 
> 
> A bigger dd test should work - if you use about 3x your 
> physical memory, you'll probably be fine doing it that way.
> 
> Another way that may work better in -some- cases, is to 
> umount the filesystem and re-mount it - except for warm 
> restartable filesystems.
> 
> On Wed, 2005-06-15 at 10:28 -0500, Roger Heflin wrote:
> > Make the dd test bigger, with 2x the memory size, 50% will be from 
> > cache and almost instanteous, with 4x the memory size, 25% will be 
> > from cache, bigger runs will get closer to actual reality, on the 
> > tests I do I run things 8x, but if you run 2x, 4x, 8x memory you 
> > should get a decent graph to give you an idea of what the 
> actual value 
> > is.
> > 
> >                Roger
> > 		   Atipa Technologies. 
> > 
> > > -----Original Message-----
> > > From: nfs-admin@lists.sourceforge.net 
> > > [mailto:nfs-admin@lists.sourceforge.net] On Behalf Of M. 
> Todd Smith
> > > Sent: Wednesday, June 15, 2005 9:47 AM
> > > To: nfs@lists.sourceforge.net
> > > Subject: Re: [NFS] NFS tuning - high performance throughput.
> > > 
> > > Roger Heflin wrote:
> > > 
> > > >Are you using the same dd test on the local machine test?  
> > > If so cache
> > > >will be a major factor.
> > > >
> > > >Also, raid5 stripe size, bigger is almost always better, 
> I would do 
> > > >some testing with different strip sizes and see how it 
> affects the 
> > > >speed, I have never seen less than 32k be faster than 32k.
> > > >
> > > >Are you using md for the raid5 setup or something else 
> that has not 
> > > >been mentioned?
> > > >
> > > >                     Roger
> > > >  
> > > >
> > > Roger,
> > > 
> > > I was told by a consultant we hired to help us with this that 5Gb 
> > > test files should be large enough to blow out the caches.
> > >  Looking back I realize that must have been when we only 
> had 2Gb RAM 
> > > in the machine ..
> > > is there a better test I can use to check local rw 
> performance, as 
> > > well is there a formula or recommended way to calculate how big a 
> > > file you should rw to properly check local rw?
> > > 
> > > I'll have to ask our soft eng who worked with the 
> consultant as to 
> > > why that particular stripe size was used.  I believe we are using 
> > > md, we attempted to use LVM but ran into some problems 
> and had some 
> > > file inconsistencies that were unacceptable so had to back out of 
> > > it.
> > > 
> > > Cheers
> > > Todd
> > > 
> > > --
> > > Systems Administrator
> > > ----------------------------------
> > > Soho VFX - Visual Effects Studio
> > > 99 Atlantic Avenue, Suite 303
> > > Toronto, Ontario, M6K 3J8
> > > (416) 516-7863
> > > http://www.sohovfx.com
> > > ----------------------------------
> > > 
> > > 
> > >  
> > > 
> > > 
> > > 
> > > -------------------------------------------------------
> > > SF.Net email is sponsored by: Discover Easy Linux Migration 
> > > Strategies from IBM. Find simple to follow Roadmaps, 
> straightforward 
> > > articles, informative Webcasts and more! Get everything 
> you need to 
> > > get up to speed, fast.
> > > http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
> > > _______________________________________________
> > > NFS maillist  -  NFS@lists.sourceforge.net 
> > > https://lists.sourceforge.net/lists/listinfo/nfs
> > > 
> > 
> > 
> > 
> > -------------------------------------------------------
> > SF.Net email is sponsored by: Discover Easy Linux Migration 
> Strategies 
> > from IBM. Find simple to follow Roadmaps, straightforward articles, 
> > informative Webcasts and more! Get everything you need to get up to 
> > speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net 
> > https://lists.sourceforge.net/lists/listinfo/nfs
> > 
> 



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
