From: Greg Banks <gnb@sgi.com>
Subject: Re: nfsd write throughput
Date: Tue, 3 Aug 2004 17:55:06 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040803075506.GL5581@sgi.com>
References: <20040802162448.GB21365@suse.de> <20040803021018.GG5581@sgi.com> <20040803060213.GA21134@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bru8e-0004tQ-AL
	for nfs@lists.sourceforge.net; Tue, 03 Aug 2004 00:55:12 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1Bru8d-0007w2-5y
	for nfs@lists.sourceforge.net; Tue, 03 Aug 2004 00:55:11 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040803060213.GA21134@suse.de>
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

On Tue, Aug 03, 2004 at 08:02:13AM +0200, Olaf Kirch wrote:
> On Tue, Aug 03, 2004 at 12:10:18PM +1000, Greg Banks wrote:
> 
> > First, the way the v3 server is supposed to work is that normal page
> > cache pressure pushes pages from unstable writes to disk before the
> > COMMIT call arrives from the client.  The best way to achieve this
> > for a dedicated NFS server box is tuning the pdflush parameters
> > to be more aggressive about writing back dirty pages, e.g. bumping
> > down the following in /proc/vm: dirty_background_ratio, dirty_ratio,
> > dirty_writeback_centisecs, and dirty_expire_centisecs.  I have to
> 
> Yes and no. Can we expect every user to fiddle with the pdflush
> tunables to get an NFS server that performs reasonably well?

No, of course not, hence the next idea.

> > I think another useful approach would be to writeback pages which
> > have been written by NFS unstable writes at a faster rate than pages
> > written by local applications, i.e. add a new /proc/vm/ sysctl like
> > nfs_dirty_writeback_centisecs and a per-page flag.
> 
> That may be a useful solution, too. My patch basically does what
> fadvise(WONTNEED) does.

Sure, the key question is when and for how many pages.  You don't
really have enough information in nfsd_write() to tell that safely.

> > For example, imagine the disk backend is a hardware RAID5 with a
> > stripe size of 128K or greater and the client is doing streaming
> > 32K WRITE calls.  With your patch, every second WRITE call will now
> > try to write half a RAID stripe unit,
> 
> No, it doesn't. If you look at the if() expression, you'll see it
> writes every 64 client-size pages.

> > > +		if ((cnt & 1023) == 0
> > > +		 && ((offset / cnt) & 63) == 0

It writes every time `offset' is a multiple of 64 times `cnt' and
`cnt' is a multiple of 1024.  At this point `cnt' is the length
of the data received in the WRITE call, which has only a vague
relationship to the client page size.

> In the worst case that's every 64K,
> but for Linux clients that's every 256K which is a reasonable size
> for IDE DMA, as well as most RAID configurations

We have configurations with hardware RAID stripe sizes up to 4MB.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
