From: "Chakri n" <chakriin5@gmail.com>
Subject: Re: A unresponsive file system can hang all I/O in the system
	on linux-2.6.23-rc6 (dirty_thresh problem?)
Date: Fri, 28 Sep 2007 02:01:23 -0700
Message-ID: <92cbf19b0709280201o3778f945mf1d8d61cbb3d0558@mail.gmail.com>
References: <92cbf19b0709272332s25684643odaade0e98cb3a1f4@mail.gmail.com>
	<20070927235034.ae7bd73d.akpm@linux-foundation.org>
	<1190962752.31636.15.camel@twins>
	<92cbf19b0709280127yba48b60wfe58e532944894ca@mail.gmail.com>
	<1190968800.31636.26.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	nfs@lists.sourceforge.net,
	linux-pm <linux-pm@lists.linux-foundation.org>,
	lkml <linux-kernel@vger.kernel.org>
To: "Peter Zijlstra" <a.p.zijlstra@chello.nl>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbBis-0007Pf-Os
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 02:01:23 -0700
Received: from an-out-0708.google.com ([209.85.132.251])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbBiv-0007k5-Gd
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 02:01:27 -0700
Received: by an-out-0708.google.com with SMTP id b38so547526ana
	for <nfs@lists.sourceforge.net>; Fri, 28 Sep 2007 02:01:25 -0700 (PDT)
In-Reply-To: <1190968800.31636.26.camel@twins>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Thanks for explaining the adaptive logic.

> However other devices will at that moment try to maintain a limit of 0,
> which ends up being similar to a sync mount.
>
> So they'll not get stuck, but they will be slow.
>
>

Sync should be ok, when the situation is bad like this and some one
hijacked all the buffers.

But, I see my simple dd to write 10blocks on local disk never
completes even after 10 minutes.

[root@h46 ~]# dd if=/dev/zero of=/tmp/x count=10

I think the process is completely stuck and is not progressing at all.

Is something going wrong in the calculations where it does not fall
back to sync mode.

Thanks
--Chakri

On 9/28/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> [ please don't top-post! ]
>
> On Fri, 2007-09-28 at 01:27 -0700, Chakri n wrote:
>
> > On 9/27/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > > On Thu, 2007-09-27 at 23:50 -0700, Andrew Morton wrote:
> > >
> > > > What we _don't_ want to happen is for other processes which are writing to
> > > > other, non-dead devices to get collaterally blocked.  We have patches which
> > > > might fix that queued for 2.6.24.  Peter?
> > >
> > > Nasty problem, don't do that :-)
> > >
> > > But yeah, with per BDI dirty limits we get stuck at whatever ratio that
> > > NFS server/mount (?) has - which could be 100%. Other processes will
> > > then work almost synchronously against their BDIs but it should work.
> > >
> > > [ They will lower the NFS-BDI's ratio, but some fancy clipping code will
> > >   limit the other BDIs their dirty limit to not exceed the total limit.
> > >   And with all these NFS pages stuck, that will still be nothing. ]
> > >
> > Thanks.
> >
> > The BDI dirty limits sounds like a good idea.
> >
> > Is there already a patch for this, which I could try?
>
> v2.6.23-rc8-mm2
>
> > I believe it works like this,
> >
> > Each BDI, will have a limit. If the dirty_thresh exceeds the limit,
> > all the I/O on the block device will be synchronous.
> >
> > so, if I have sda & a NFS mount, the dirty limit can be different for
> > each of them.
> >
> > I can set dirty limit for
> >  -  sda to be 90% and
> >  -  NFS mount to be 50%.
> >
> > So, if the dirty limit is greater than 50%, NFS does synchronously,
> > but sda can work asynchronously, till dirty limit reaches 90%.
>
> Not quite, the system determines the limit itself in an adaptive
> fashion.
>
>   bdi_limit = total_limit * p_bdi
>
> Where p is a faction [0,1], and is determined by the relative writeout
> speed of the current BDI vs all other BDIs.
>
> So if you were to have 3 BDIs (sda, sdb and 1 nfs mount), and sda is
> idle, and the nfs mount gets twice as much traffic as sdb, the ratios
> will look like:
>
>  p_sda: 0
>  p_sdb: 1/3
>  p_nfs: 2/3
>
> Once the traffic exceeds the write speed of the device we build up a
> backlog and stuff gets throttled, so these proportions converge to the
> relative write speed of the BDIs when saturated with data.
>
> So what can happen in your case is that the NFS mount is the only one
> with traffic is will get a fraction of 1. If it then disconnects like in
> your case, it will still have all of the dirty limit pinned for NFS.
>
> However other devices will at that moment try to maintain a limit of 0,
> which ends up being similar to a sync mount.
>
> So they'll not get stuck, but they will be slow.
>
>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
