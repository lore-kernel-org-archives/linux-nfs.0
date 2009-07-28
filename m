From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [Patch] Fix memory leak in write_pool_threads
Date: Tue, 28 Jul 2009 16:03:48 +0100
Message-ID: <b0943d9e0907280803p5ccf7e6pd7611af8ed302c6b@mail.gmail.com>
References: <1248784328.3250.30.camel@queen>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Eric Sesterhenn <eric.sesterhenn-9J169x0r4uIEe5DYm7f/Lg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f221.google.com ([209.85.218.221]:42827 "EHLO
	mail-bw0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753323AbZG1PDv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jul 2009 11:03:51 -0400
Received: by bwz21 with SMTP id 21so91323bwz.37
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2009 08:03:50 -0700 (PDT)
In-Reply-To: <1248784328.3250.30.camel@queen>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2009/7/28 Eric Sesterhenn <eric.sesterhenn-9J169x0r4uIEe5DYm7f/Lg@public.gmane.org>:
> kmemcheck produces the following warning

That's "kmemleak" (a bit confusing since there is "kmemcheck" as well
in the kernel :-)).

> unreferenced object 0xc9ec02a0 (size 8):
> =A0comm "cat", pid 19048, jiffies 730243
> =A0backtrace:
> =A0 =A0[<c01bf970>] create_object+0x100/0x240
> =A0 =A0[<c01bfadb>] kmemleak_alloc+0x2b/0x60
> =A0 =A0[<c01bcd4b>] __kmalloc+0x14b/0x270
> =A0 =A0[<c02fd027>] write_pool_threads+0x87/0x1d0
> =A0 =A0[<c02fcc08>] nfsctl_transaction_write+0x58/0x70
> =A0 =A0[<c02fcc6f>] nfsctl_transaction_read+0x4f/0x60
> =A0 =A0[<c01c2574>] vfs_read+0x94/0x150
> =A0 =A0[<c01c297d>] sys_read+0x3d/0x70
> =A0 =A0[<c0102d6b>] sysenter_do_call+0x12/0x32
> =A0 =A0[<ffffffff>] 0xffffffff
>
> write_pool_threads() only frees nthreads on error paths, in the succe=
ss case
> we leak it.
>
> Signed-off-by: Eric Sesterhenn <eric.sesterhenn-PIliufFCYSYOIzVOb1FTxg@public.gmane.org>
>
> --- linux/fs/nfsd/nfsctl.c.orig 2009-07-28 14:19:19.000000000 +0200
> +++ linux/fs/nfsd/nfsctl.c =A0 =A0 =A02009-07-28 14:19:30.000000000 +=
0200
> @@ -784,6 +784,7 @@ static ssize_t write_pool_threads(struct
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mesg +=3D len;
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 kfree(nthreads);
> =A0 =A0 =A0 =A0mutex_unlock(&nfsd_mutex);
> =A0 =A0 =A0 =A0return (mesg-buf);

Thanks for this. On minor point - the kfree() could probably be moved
after mutex_unlock().

I added the patch to the kmemleak-fixes branch on
git://linux-arm.org/linux-2.6.git (I'm not pushing this branch
upstream, it's mainly for people trying kmemleak to avoid reporting or
investigating already fixed leaks).

--=20
Catalin
