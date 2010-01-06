From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: vfs related crash in 2.6.33-rc2
Date: Wed, 6 Jan 2010 15:41:23 -0800
Message-ID: <20100106154123.b12547f3.akpm@linux-foundation.org>
References: <200912301733.19077.marvin24@gmx.de>
	<87637oi6v8.fsf@devron.myhome.or.jp>
	<200912302144.36718.marvin24@gmx.de>
	<87637omb4b.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Marvin <marvin24@gmx.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35742 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932266Ab0AFXll (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jan 2010 18:41:41 -0500
In-Reply-To: <87637omb4b.fsf-x/W9pkDDSe1TgC2z9Sl/nXf5DAMn2ifp@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 31 Dec 2009 05:59:32 +0900
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> wrote:

> Marvin <marvin24@gmx.de> writes:
> 
> >> Marvin <marvin24@gmx.de> writes:
> >> > Hi,
> >> >
> >> > I'm getting a lot of these:
> >> >
> >> > kernel: general protection fault: 0000 [#1] SMP
> >> > kernel: last sysfs file: /sys/devices/pci0000:00/0000:00:18.3/modalias
> >> > kernel: CPU 0
> >> > kernel: Pid: 12177, comm: packagekitd Not tainted 2.6.33-rc2 #1
> >> > ...
> >> >
> >> > filesystem is ext4 (in case it matters).
> >> 
> >> BTW, are you using nfs client on this machine?
> >>
> >
> > um - yes, now that I think about it... I killed a nfs umount process (because of an 
> > offline server) shortly before the oopses started to fire.
> 
> OK. Probably, this oops would be same with one which happened on my
> machine recently. That path in patch corrupts dcache hash, so it can be
> the cause of strange behavior or oops on dcache hash.
> 
> If so, the attached patch would fix it.
> 
> Thanks.
> -- 
> OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
> 
> 
> Recent change is missing to update "rehash". With that change, it will
> become the cause of adding dentry to hash twice.
> 
> This explains the reason of Oops (dereference the freed dentry in
> __d_lookup()) on my machine.
> 
> Signed-off-by: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
> ---
> 
>  fs/nfs/dir.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff -puN fs/nfs/dir.c~nfs-d_rehash-fix fs/nfs/dir.c
> --- linux-2.6/fs/nfs/dir.c~nfs-d_rehash-fix	2009-12-28 06:18:09.000000000 +0900
> +++ linux-2.6-hirofumi/fs/nfs/dir.c	2009-12-28 06:18:16.000000000 +0900
> @@ -1615,6 +1615,7 @@ static int nfs_rename(struct inode *old_
>  				goto out;
>  
>  			new_dentry = dentry;
> +			rehash = NULL;
>  			new_inode = NULL;
>  		}
>  	}

Guys, what's the status of this fix?  Did Marvin have a chance to test
it?  Are the NFS developers aware of it?

Thanks.

