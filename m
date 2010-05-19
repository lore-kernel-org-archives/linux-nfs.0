From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] pnfsblock: Lookup list entry of layouts and tags in
	reverse order
Date: Wed, 19 May 2010 12:36:32 -0400
Message-ID: <20100519163632.GL4581@fieldses.org>
References: <20100510033610.GA5443@MDS-78.localdomain> <4BEA4ED3.3010702@panasas.com> <20100512202811.GA9296@fieldses.org> <20100517135341.GA30737@fieldses.org> <4BF151A7.1070003@panasas.com> <20100517145311.GJ30737@fieldses.org> <20100517165302.GL30737@fieldses.org> <AANLkTilUpAHrtHH8pauvYrAuD3rWgj7aDmrTOzrmU-h5@mail.gmail.com> <20100518162005.GI17823@fieldses.org> <AANLkTik9L15tqpSboBpb9cSTy3hVPLEK487w94pEbLrS@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Zhang Jingwang <yyalone@gmail.com>,
	Boaz Harrosh <bharrosh@panasas.com>,
	Benny Halevy <bhalevy@panasas.com>,
	Zhang Jingwang <zhangjingwang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>,
	linux-nfs@vger.kernel.org, iisaman@netapp.com
To: Tao Guo <glorioustao@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59961 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753576Ab0ESQgf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 May 2010 12:36:35 -0400
In-Reply-To: <AANLkTik9L15tqpSboBpb9cSTy3hVPLEK487w94pEbLrS-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 19, 2010 at 12:56:42PM +0800, Tao Guo wrote:
> I think the warning just indicate a possible bug:
> nfs_inode_set_delegation():
>                                         clp->cl_lock
>                                             --> inode->i_lock
> get_lock_alloc_layout():
>                                    nfsi->lo_lock
>                                       --> clp->cl_lock
> nfs_try_to_update_request()->pnfs_do_flush()->_pnfs_do_flush()->
> pnfs_find_get_lseg()->get_lock_current_layout():
>=20
> inode->i_lock
>=20
> -->nfsi->lo_lock
> In nfs_inode_set_delegation(), maybe we should unlock clp->cl_lock be=
fore
> taking inode->i_lock spinlock?
>=20
> PS: I just use the latest pnfsblock code(pnfs-all-2.6.34-2010-05-17) =
doing some
> basic r/w tests and it works fine.

Could you try running the connectathon general test?

> Can you find out which code path
> lead to IO errror?

I'll try to narrow down the test case.

--b.

>=20
> On Wed, May 19, 2010 at 12:20 AM, J. Bruce Fields <bfields@fieldses.o=
rg> wrote:
> > On Tue, May 18, 2010 at 01:22:52AM +0800, Zhang Jingwang wrote:
> >> I've sent two patches to solve this problem, you can try them.
> >>
> >> [PATCH] pnfs: set pnfs_curr_ld before calling initialize_mountpoin=
t
> >> [PATCH] pnfs: set pnfs_blksize before calling set_pnfs_layoutdrive=
r
> >
> > Thanks. =C2=A0With Benny's latest block all (97602fc6, which includ=
es the two
> > patches above), I'm back to the previous behavior:
> >
> >>
> >> 2010/5/18 J. Bruce Fields <bfields@fieldses.org>:
> >> > On Mon, May 17, 2010 at 10:53:11AM -0400, J. Bruce Fields wrote:
> >> >> On Mon, May 17, 2010 at 05:24:39PM +0300, Boaz Harrosh wrote:
> >> >> > On 05/17/2010 04:53 PM, J. Bruce Fields wrote:
> >> >> > > On Wed, May 12, 2010 at 04:28:12PM -0400, bfields wrote:
> >> >> > >> The one thing I've noticed is that the connectathon genera=
l test has
> >> >> > >> started failing right at the start with an IO error. =C2=A0=
The last good
> >> >> > >> version I tested was b5c09c21, which was based on 33-rc6. =
=C2=A0The earliest
> >> >> > >> bad version I tested was 419312ada, based on 34-rc2. =C2=A0=
A quick look at
> >> >> > >> network traces from the two traces didn't turn up anything=
 obvious. =C2=A0I
> >> >> > >> haven't had the chance yet to look closer.
> >
> > So I still see the IO error at the start of the connectathon genera=
l
> > tests.
> >
> > Also, I get the following warning--I don't know if it's new or not.
> >
> > --b.
> >
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> > [ INFO: possible circular locking dependency detected ]
> > 2.6.34-pnfs-00322-g97602fc #141
> > -------------------------------------------------------
> > cp/2789 is trying to acquire lock:
> > =C2=A0(&(&nfsi->lo_lock)->rlock){+.+...}, at: [<ffffffff8124dbee>] =
T.947+0x4e/0x210
> >
> > but task is already holding lock:
> > =C2=A0(&sb->s_type->i_lock_key#11){+.+...}, at: [<ffffffff81223689>=
] nfs_updatepage+0x139/0x5a0
> >
> > which lock already depends on the new lock.
> >
> >
> > the existing dependency chain (in reverse order) is:
> >
> > -> #2 (&sb->s_type->i_lock_key#11){+.+...}:
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff81065913>] __lock_acquire+0x1293/0x1=
d30
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff81066442>] lock_acquire+0x92/0x170
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff81925d5b>] _raw_spin_lock+0x3b/0x50
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff81244173>] nfs_inode_set_delegation+=
0x203/0x2c0
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff81231b7a>] nfs4_opendata_to_nfs4_sta=
te+0x31a/0x3d0
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff81231fb2>] nfs4_do_open+0x242/0x460
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff81232a05>] nfs4_proc_create+0x85/0x2=
20
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff8120ec64>] nfs_create+0x74/0x120
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff810e5d63>] vfs_create+0xb3/0x100
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff810e656b>] do_last+0x59b/0x6c0
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff810e88e2>] do_filp_open+0x212/0x690
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff810d8059>] do_sys_open+0x69/0x140
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff810d8170>] sys_open+0x20/0x30
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff81002518>] system_call_fastpath+0x16=
/0x1b
> >
> > -> #1 (&(&clp->cl_lock)->rlock){+.+...}:
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff81065913>] __lock_acquire+0x1293/0x1=
d30
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff81066442>] lock_acquire+0x92/0x170
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff81925d5b>] _raw_spin_lock+0x3b/0x50
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff8124b378>] pnfs_update_layout+0x2f8/=
0xaf0
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff8124c7e4>] pnfs_file_write+0x64/0xc0
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff810daab7>] vfs_write+0xb7/0x180
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff810dac71>] sys_write+0x51/0x90
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff81002518>] system_call_fastpath+0x16=
/0x1b
> >
> > -> #0 (&(&nfsi->lo_lock)->rlock){+.+...}:
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff81065dd2>] __lock_acquire+0x1752/0x1=
d30
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff81066442>] lock_acquire+0x92/0x170
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff81925d5b>] _raw_spin_lock+0x3b/0x50
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff8124dbee>] T.947+0x4e/0x210
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff8124ddfb>] _pnfs_do_flush+0x4b/0xf0
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff8122364d>] nfs_updatepage+0xfd/0x5a0
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff812126b5>] nfs_write_end+0x265/0x3e0
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff810a3397>] generic_file_buffered_wri=
te+0x187/0x2a0
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff810a5890>] __generic_file_aio_write+=
0x240/0x460
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff810a5b17>] generic_file_aio_write+0x=
67/0xd0
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff81213661>] nfs_file_write+0xb1/0x1f0
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff810d9fca>] do_sync_write+0xda/0x120
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff8124c802>] pnfs_file_write+0x82/0xc0
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff810daab7>] vfs_write+0xb7/0x180
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff810dac71>] sys_write+0x51/0x90
> > =C2=A0 =C2=A0 =C2=A0 [<ffffffff81002518>] system_call_fastpath+0x16=
/0x1b
> >
> > other info that might help us debug this:
> >
> > 2 locks held by cp/2789:
> > =C2=A0#0: =C2=A0(&sb->s_type->i_mutex_key#13){+.+.+.}, at: [<ffffff=
ff810a5b04>] generic_file_aio_write+0x54/0xd0
> > =C2=A0#1: =C2=A0(&sb->s_type->i_lock_key#11){+.+...}, at: [<fffffff=
f81223689>] nfs_updatepage+0x139/0x5a0
> >
> > stack backtrace:
> > Pid: 2789, comm: cp Not tainted 2.6.34-pnfs-00322-g97602fc #141
> > Call Trace:
> > =C2=A0[<ffffffff81064033>] print_circular_bug+0xf3/0x100
> > =C2=A0[<ffffffff81065dd2>] __lock_acquire+0x1752/0x1d30
> > =C2=A0[<ffffffff81066442>] lock_acquire+0x92/0x170
> > =C2=A0[<ffffffff8124dbee>] ? T.947+0x4e/0x210
> > =C2=A0[<ffffffff81929d59>] ? sub_preempt_count+0x9/0xa0
> > =C2=A0[<ffffffff81925d5b>] _raw_spin_lock+0x3b/0x50
> > =C2=A0[<ffffffff8124dbee>] ? T.947+0x4e/0x210
> > =C2=A0[<ffffffff8124dbee>] T.947+0x4e/0x210
> > =C2=A0[<ffffffff8124ddfb>] _pnfs_do_flush+0x4b/0xf0
> > =C2=A0[<ffffffff8122364d>] nfs_updatepage+0xfd/0x5a0
> > =C2=A0[<ffffffff812126b5>] nfs_write_end+0x265/0x3e0
> > =C2=A0[<ffffffff810a3397>] generic_file_buffered_write+0x187/0x2a0
> > =C2=A0[<ffffffff810a5890>] __generic_file_aio_write+0x240/0x460
> > =C2=A0[<ffffffff81929d59>] ? sub_preempt_count+0x9/0xa0
> > =C2=A0[<ffffffff810a5b17>] generic_file_aio_write+0x67/0xd0
> > =C2=A0[<ffffffff81213661>] nfs_file_write+0xb1/0x1f0
> > =C2=A0[<ffffffff810d9fca>] do_sync_write+0xda/0x120
> > =C2=A0[<ffffffff810528a0>] ? autoremove_wake_function+0x0/0x40
> > =C2=A0[<ffffffff8124c802>] pnfs_file_write+0x82/0xc0
> > =C2=A0[<ffffffff810daab7>] vfs_write+0xb7/0x180
> > =C2=A0[<ffffffff810dac71>] sys_write+0x51/0x90
> > =C2=A0[<ffffffff81002518>] system_call_fastpath+0x16/0x1b
> > eth0: no IPv6 routers present
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs=
" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.=
html
> >
>=20
>=20
>=20
> --=20
> tao.
