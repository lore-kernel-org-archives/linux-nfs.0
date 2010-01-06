From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: vfs related crash in 2.6.33-rc2
Date: Wed, 06 Jan 2010 18:55:58 -0500
Message-ID: <1262822158.4251.179.camel@localhost>
References: <200912301733.19077.marvin24@gmx.de>
	 <87637oi6v8.fsf@devron.myhome.or.jp> <200912302144.36718.marvin24@gmx.de>
	 <87637omb4b.fsf@devron.myhome.or.jp>
	 <20100106154123.b12547f3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
	Marvin <marvin24@gmx.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:39552 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933187Ab0AFX4I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 18:56:08 -0500
In-Reply-To: <20100106154123.b12547f3.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-01-06 at 15:41 -0800, Andrew Morton wrote: 
> On Thu, 31 Dec 2009 05:59:32 +0900
> OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> wrote:
> 
> > Marvin <marvin24@gmx.de> writes:
> > 
> > >> Marvin <marvin24@gmx.de> writes:
> > >> > Hi,
> > >> >
> > >> > I'm getting a lot of these:
> > >> >
> > >> > kernel: general protection fault: 0000 [#1] SMP
> > >> > kernel: last sysfs file: /sys/devices/pci0000:00/0000:00:18.3/modalias
> > >> > kernel: CPU 0
> > >> > kernel: Pid: 12177, comm: packagekitd Not tainted 2.6.33-rc2 #1
> > >> > ...
> > >> >
> > >> > filesystem is ext4 (in case it matters).
> > >> 
> > >> BTW, are you using nfs client on this machine?
> > >>
> > >
> > > um - yes, now that I think about it... I killed a nfs umount process (because of an 
> > > offline server) shortly before the oopses started to fire.
> > 
> > OK. Probably, this oops would be same with one which happened on my
> > machine recently. That path in patch corrupts dcache hash, so it can be
> > the cause of strange behavior or oops on dcache hash.
> > 
> > If so, the attached patch would fix it.
> > 
> > Thanks.
> > -- 
> > OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
> > 
> > 
> > Recent change is missing to update "rehash". With that change, it will
> > become the cause of adding dentry to hash twice.
> > 
> > This explains the reason of Oops (dereference the freed dentry in
> > __d_lookup()) on my machine.
> > 
> > Signed-off-by: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
> > ---
> > 
> >  fs/nfs/dir.c |    1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff -puN fs/nfs/dir.c~nfs-d_rehash-fix fs/nfs/dir.c
> > --- linux-2.6/fs/nfs/dir.c~nfs-d_rehash-fix	2009-12-28 06:18:09.000000000 +0900
> > +++ linux-2.6-hirofumi/fs/nfs/dir.c	2009-12-28 06:18:16.000000000 +0900
> > @@ -1615,6 +1615,7 @@ static int nfs_rename(struct inode *old_
> >  				goto out;
> >  
> >  			new_dentry = dentry;
> > +			rehash = NULL;
> >  			new_inode = NULL;
> >  		}
> >  	}
> 
> Guys, what's the status of this fix?  Did Marvin have a chance to test
> it?  Are the NFS developers aware of it?
> 
> Thanks.
> 

Sorry for the delay. The above fix looks correct to me, but I too would
like a confirmation that it fixes the Oops before I push it to Linus.

In the meantime, I've committed it to my linux-next branch.

Cheers
  Trond

