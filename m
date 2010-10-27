Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:58475 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183Ab0J0HVj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Oct 2010 03:21:39 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd changes for 2.6.37
Date: Wed, 27 Oct 2010 09:21:36 +0200
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
References: <20101026164549.GD19445@fieldses.org> <20101026214441.GC1842@fieldses.org> <20101026221156.GD1842@fieldses.org>
In-Reply-To: <20101026221156.GD1842@fieldses.org>
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201010270921.37032.arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wednesday 27 October 2010 00:11:56 J. Bruce Fields wrote:
> > BUG: sleeping function called from invalid context at mm/slab.c:3101
> > in_atomic(): 1, irqs_disabled(): 0, pid: 4345, name: lease_tests
> > 1 lock held by lease_tests/4345:
> >  #0:  (file_lock_lock){+.+.+.}, at: [<ffffffff81128be5>] lock_flocks+0x15/0x20
> > Pid: 4345, comm: lease_tests Not tainted 2.6.36-05858-gbd5e20b #1028
> > Call Trace:
> >  [<ffffffff8103141d>] __might_sleep+0x10d/0x140
> >  [<ffffffff810e3ad3>] kmem_cache_alloc+0x1f3/0x230
> >  [<ffffffff8112a4d2>] generic_setlease+0x112/0x2c0
> >  [<ffffffff8112a6b5>] __vfs_setlease+0x35/0x40
> >  [<ffffffff8112acfe>] fcntl_setlease+0xce/0x180
> >  [<ffffffff810f7c2e>] sys_fcntl+0x2fe/0x630
> >  [<ffffffff81961999>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> >  [<ffffffff81002658>] system_call_fastpath+0x16/0x1b
> > 
> > I'm testing a patch.
> 

Thanks for the report!

> @@ -1524,8 +1528,6 @@ int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
>         if (error)
>                 return error;
>  
> -       lock_flocks();
> -
>         error = __vfs_setlease(filp, arg, &flp);
>         if (error || arg == F_UNLCK)
>                 goto out_unlock;
> @@ -1541,7 +1543,6 @@ int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
>  
>         error = __f_setown(filp, task_pid(current), PIDTYPE_PID, 0);
>  out_unlock:
> -       unlock_flocks();
>         return error;
>  }

If you don't hold lock_flocks throughout fcntl_setlease, the flp variable
points to a flock that may get modified by another thread and you call
time_out_leases() without holding lock_flocks, which it requires.

The two alternatives I can see are to either use GFP_ATOMIC or to
take the lock inside of generic_setlease and drop it outside.
Neither of the two sounds particularly appealing.

	Arnd
