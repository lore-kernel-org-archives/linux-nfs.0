From: Marvin <marvin24@gmx.de>
Subject: Re: vfs related crash in 2.6.33-rc2
Date: Thu, 7 Jan 2010 10:27:58 +0100
Message-ID: <201001071027.58865.marvin24@gmx.de>
References: <200912301733.19077.marvin24@gmx.de> <20100106154123.b12547f3.akpm@linux-foundation.org> <1262822158.4251.179.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751859Ab0AGJ2W@vger.kernel.org>
In-Reply-To: <1262822158.4251.179.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi,

> On Wed, 2010-01-06 at 15:41 -0800, Andrew Morton wrote:
> > On Thu, 31 Dec 2009 05:59:32 +0900
> >
> > OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> wrote:
> > > Marvin <marvin24@gmx.de> writes:
> > > >> Marvin <marvin24@gmx.de> writes:
> > > >> > Hi,
> > > >> >
> > > >> > I'm getting a lot of these:
> > > >> >
> > > >> > kernel: general protection fault: 0000 [#1] SMP
> > > >> > kernel: last sysfs file:
> > > >> > /sys/devices/pci0000:00/0000:00:18.3/modalias kernel: CPU 0
> > > >> > kernel: Pid: 12177, comm: packagekitd Not tainted 2.6.33-rc2 #1
> > > >> > ...
> > > >> >
> > > >> > filesystem is ext4 (in case it matters).
> > > >>
> > > >> BTW, are you using nfs client on this machine?
> > > >
> > > > um - yes, now that I think about it... I killed a nfs umount process
> > > > (because of an offline server) shortly before the oopses started to
> > > > fire.
> > >
> > > OK. Probably, this oops would be same with one which happened on my
> > > machine recently. That path in patch corrupts dcache hash, so it can be
> > > the cause of strange behavior or oops on dcache hash.
> > >
> > > If so, the attached patch would fix it.
> > >
> > > Thanks.
> >
> > Guys, what's the status of this fix?  Did Marvin have a chance to test
> > it?  Are the NFS developers aware of it?
> >
> > Thanks.
> 
> Sorry for the delay. The above fix looks correct to me, but I too would
> like a confirmation that it fixes the Oops before I push it to Linus.
> 
> In the meantime, I've committed it to my linux-next branch.

It seems that I send the reply to Hirofumi only, sorry for that. The patch works fine 
- no oops anymore.

Thanks

Marvin
