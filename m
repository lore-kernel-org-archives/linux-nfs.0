From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [Patch] Fix memory leak in write_pool_threads
Date: Tue, 28 Jul 2009 11:42:05 -0400
Message-ID: <20090728154205.GF19497@fieldses.org>
References: <1248784328.3250.30.camel@queen> <b0943d9e0907280803p5ccf7e6pd7611af8ed302c6b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Sesterhenn <eric.sesterhenn-9J169x0r4uIEe5DYm7f/Lg@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: Catalin Marinas <catalin.marinas@arm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51624 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753518AbZG1PmR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jul 2009 11:42:17 -0400
In-Reply-To: <b0943d9e0907280803p5ccf7e6pd7611af8ed302c6b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 28, 2009 at 04:03:48PM +0100, Catalin Marinas wrote:
> 2009/7/28 Eric Sesterhenn <eric.sesterhenn-9J169x0r4uIEe5DYm7f/Lg@public.gmane.org>:
> > kmemcheck produces the following warning
>=20
> That's "kmemleak" (a bit confusing since there is "kmemcheck" as well
> in the kernel :-)).

Thanks, fixed up changelog and added a Reviewed-by: Catalin Marinas
<catalin.marinas@arm.com>.

--b.

> > unreferenced object 0xc9ec02a0 (size 8):
> > =C2=A0comm "cat", pid 19048, jiffies 730243
> > =C2=A0backtrace:
> > =C2=A0 =C2=A0[<c01bf970>] create_object+0x100/0x240
> > =C2=A0 =C2=A0[<c01bfadb>] kmemleak_alloc+0x2b/0x60
> > =C2=A0 =C2=A0[<c01bcd4b>] __kmalloc+0x14b/0x270
> > =C2=A0 =C2=A0[<c02fd027>] write_pool_threads+0x87/0x1d0
> > =C2=A0 =C2=A0[<c02fcc08>] nfsctl_transaction_write+0x58/0x70
> > =C2=A0 =C2=A0[<c02fcc6f>] nfsctl_transaction_read+0x4f/0x60
> > =C2=A0 =C2=A0[<c01c2574>] vfs_read+0x94/0x150
> > =C2=A0 =C2=A0[<c01c297d>] sys_read+0x3d/0x70
> > =C2=A0 =C2=A0[<c0102d6b>] sysenter_do_call+0x12/0x32
> > =C2=A0 =C2=A0[<ffffffff>] 0xffffffff
> >
> > write_pool_threads() only frees nthreads on error paths, in the suc=
cess case
> > we leak it.
> >
> > Signed-off-by: Eric Sesterhenn <eric.sesterhenn-PIliufFCYSYOIzVOb1FTxg@public.gmane.org>
> >
> > --- linux/fs/nfsd/nfsctl.c.orig 2009-07-28 14:19:19.000000000 +0200
> > +++ linux/fs/nfsd/nfsctl.c =C2=A0 =C2=A0 =C2=A02009-07-28 14:19:30.=
000000000 +0200
> > @@ -784,6 +784,7 @@ static ssize_t write_pool_threads(struct
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mesg +=3D le=
n;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> >
> > + =C2=A0 =C2=A0 =C2=A0 kfree(nthreads);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_unlock(&nfsd_mutex);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0return (mesg-buf);
>=20
> Thanks for this. On minor point - the kfree() could probably be moved
> after mutex_unlock().
>=20
> I added the patch to the kmemleak-fixes branch on
> git://linux-arm.org/linux-2.6.git (I'm not pushing this branch
> upstream, it's mainly for people trying kmemleak to avoid reporting o=
r
> investigating already fixed leaks).
>=20
> --=20
> Catalin
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
