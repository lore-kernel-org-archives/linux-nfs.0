Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51843 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753333AbbG0LZ6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Jul 2015 07:25:58 -0400
Message-ID: <55B6153B.1070604@redhat.com>
Date: Mon, 27 Jul 2015 13:25:47 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
To: Mel Gorman <mgorman@techsingularity.net>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] nfs: avoid swap-over-NFS deadlock
References: <1437552643-18774-1-git-send-email-jmarchan@redhat.com> <CAHQdGtRXhUi+=akuASUWo-tYy0YCWJtUts6fqGnA62fo1Jf5tA@mail.gmail.com> <55AF9EA8.6020102@redhat.com> <20150727105216.GD2660@techsingularity.net>
In-Reply-To: <20150727105216.GD2660@techsingularity.net>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="9DiHjOX0bQxrdmvbt0W4lFSHuaHeViWul"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--9DiHjOX0bQxrdmvbt0W4lFSHuaHeViWul
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable

On 07/27/2015 12:52 PM, Mel Gorman wrote:
> On Wed, Jul 22, 2015 at 03:46:16PM +0200, Jerome Marchand wrote:
>> On 07/22/2015 02:23 PM, Trond Myklebust wrote:
>>> On Wed, Jul 22, 2015 at 4:10 AM, Jerome Marchand <jmarchan@redhat.com=
> wrote:
>>>>
>>>> Lockdep warns about a inconsistent {RECLAIM_FS-ON-W} ->
>>>> {IN-RECLAIM_FS-W} usage. The culpritt is the inode->i_mutex taken in=

>>>> nfs_file_direct_write(). This code was introduced by commit a9ab5e84=
0669
>>>> ("nfs: page cache invalidation for dio").
>>>> This naive test patch avoid to take the mutex on a swapfile and make=
s
>>>> lockdep happy again. However I don't know much about NFS code and I
>>>> assume it's probably not the proper solution. Any thought?
>>>>
>>>> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
>>>
>>> NFS is not the only O_DIRECT implementation to set the inode->i_mutex=
=2E
>>> Why can't this be fixed in the generic swap code instead of adding
>>> yet-another-exception-for-IS_SWAPFILE?
>>
>> I meant to cc Mel. Just added him.
>>
>=20
> Can the full lockdep warning be included as it'll be easier to see then=
 if
> the generic swap code can somehow special case this? Currently, generic=

> swapping does not not need to care about how the filesystem locked.
> For most filesystems, it's writing directly to the blocks on disk and
> bypassing the FS. In the NFS case it'd be surprising to find that there=

> also are dirty pages in page cache that belong to the swap file as it's=

> going to cause corruption. If there is any special casing it would to o=
nly
> attempt the invalidation in the !swap case and warn if mapping->nrpages=
=2E It
> still would look a bit weird but safer than just not acquiring the mute=
x
> and then potentially attempting an invalidation.
>=20

[ 6819.501009] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[ 6819.501009] [ INFO: inconsistent lock state ]
[ 6819.501009] 4.2.0-rc1-shmacct-babka-v2-next-20150709+ #255 Not tainted=

[ 6819.501009] ---------------------------------
[ 6819.501009] inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.=

[ 6819.501009] kswapd0/38 [HC0[0]:SC0[0]:HE1:SE1] takes:
[ 6819.501009]  (&sb->s_type->i_mutex_key#17){+.+.?.}, at: [<ffffffffa037=
72a5>] nfs_file_direct_write+0x85/0x3f0 [nfs]
[ 6819.501009] {RECLAIM_FS-ON-W} state was registered at:
[ 6819.501009]   [<ffffffff81107f51>] mark_held_locks+0x71/0x90
[ 6819.501009]   [<ffffffff8110b775>] lockdep_trace_alloc+0x75/0xe0
[ 6819.501009]   [<ffffffff81245529>] kmem_cache_alloc_node_trace+0x39/0x=
440
[ 6819.501009]   [<ffffffff81225b8f>] __get_vm_area_node+0x7f/0x160
[ 6819.501009]   [<ffffffff81226eb2>] __vmalloc_node_range+0x72/0x2c0
[ 6819.501009]   [<ffffffff81227424>] vzalloc+0x54/0x60
[ 6819.501009]   [<ffffffff8122c7c8>] SyS_swapon+0x628/0xfc0
[ 6819.501009]   [<ffffffff81867772>] entry_SYSCALL_64_fastpath+0x12/0x76=

[ 6819.501009] irq event stamp: 163459
[ 6819.501009] hardirqs last  enabled at (163459): [<ffffffff81866c66>] _=
raw_spin_unlock_irqrestore+0x36/0x60
[ 6819.501009] hardirqs last disabled at (163458): [<ffffffff8186747b>] _=
raw_spin_lock_irqsave+0x2b/0x90
[ 6819.501009] softirqs last  enabled at (162966): [<ffffffff810b13d3>] _=
_do_softirq+0x363/0x630
[ 6819.501009] softirqs last disabled at (162961): [<ffffffff810b1a03>] i=
rq_exit+0xf3/0x100
[ 6819.501009]=20
other info that might help us debug this:
[ 6819.501009]  Possible unsafe locking scenario:

[ 6819.501009]        CPU0
[ 6819.501009]        ----
[ 6819.501009]   lock(&sb->s_type->i_mutex_key#17);
[ 6819.501009]   <Interrupt>
[ 6819.501009]     lock(&sb->s_type->i_mutex_key#17);
[ 6819.501009]=20
 *** DEADLOCK ***

[ 6819.501009] no locks held by kswapd0/38.
[ 6819.501009]=20
stack backtrace:
[ 6819.501009] CPU: 1 PID: 38 Comm: kswapd0 Not tainted 4.2.0-rc1-shmacct=
-babka-v2-next-20150709+ #255
[ 6819.501009] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[ 6819.501009]  0000000000000000 00000000cca71737 ffff880033f374d8 ffffff=
ff8185ce5b
[ 6819.501009]  0000000000000000 ffff880033f30000 ffff880033f37538 ffffff=
ff8185732d
[ 6819.501009]  0000000000000000 ffff880000000001 ffff880000000001 ffffff=
ff8102f49f
[ 6819.501009] Call Trace:
[ 6819.501009]  [<ffffffff8185ce5b>] dump_stack+0x4c/0x65
[ 6819.501009]  [<ffffffff8185732d>] print_usage_bug+0x1f2/0x203
[ 6819.501009]  [<ffffffff8102f49f>] ? save_stack_trace+0x2f/0x50
[ 6819.501009]  [<ffffffff81107430>] ? check_usage_backwards+0x150/0x150
[ 6819.501009]  [<ffffffff81107e52>] mark_lock+0x212/0x2a0
[ 6819.501009]  [<ffffffff81108d73>] __lock_acquire+0x8d3/0x1f40
[ 6819.501009]  [<ffffffff8110953e>] ? __lock_acquire+0x109e/0x1f40
[ 6819.501009]  [<ffffffff8110ac92>] lock_acquire+0xc2/0x280
[ 6819.501009]  [<ffffffffa03772a5>] ? nfs_file_direct_write+0x85/0x3f0 [=
nfs]
[ 6819.501009]  [<ffffffff818641bf>] mutex_lock_nested+0x7f/0x3f0
[ 6819.501009]  [<ffffffffa03772a5>] ? nfs_file_direct_write+0x85/0x3f0 [=
nfs]
[ 6819.501009]  [<ffffffff81105328>] ? __lock_is_held+0x58/0x80
[ 6819.501009]  [<ffffffffa03772a5>] ? nfs_file_direct_write+0x85/0x3f0 [=
nfs]
[ 6819.501009]  [<ffffffff8122a500>] ? get_swap_bio+0x90/0x90
[ 6819.501009]  [<ffffffffa03772a5>] nfs_file_direct_write+0x85/0x3f0 [nf=
s]
[ 6819.501009]  [<ffffffff8122a500>] ? get_swap_bio+0x90/0x90
[ 6819.501009]  [<ffffffffa0377640>] nfs_direct_IO+0x30/0x50 [nfs]
[ 6819.501009]  [<ffffffff8122a9b5>] __swap_writepage+0x105/0x270
[ 6819.501009]  [<ffffffff8122ab59>] swap_writepage+0x39/0x70
[ 6819.501009]  [<ffffffff811fbef2>] shmem_writepage+0x1f2/0x330
[ 6819.501009]  [<ffffffff811f3319>] pageout.isra.48+0x189/0x4a0
[ 6819.501009]  [<ffffffff811f5497>] shrink_page_list+0x9b7/0xc80
[ 6819.501009]  [<ffffffff811f60a8>] shrink_inactive_list+0x3a8/0x800
[ 6819.501009]  [<ffffffff810e72f5>] ? local_clock+0x15/0x30
[ 6819.501009]  [<ffffffff811f6f10>] shrink_lruvec+0x610/0x800
[ 6819.501009]  [<ffffffff811f71e7>] shrink_zone+0xe7/0x2d0
[ 6819.501009]  [<ffffffff811f8ddd>] kswapd+0x55d/0xd30
[ 6819.501009]  [<ffffffff811f8880>] ? mem_cgroup_shrink_node_zone+0x490/=
0x490
[ 6819.501009]  [<ffffffff810d1a74>] kthread+0x104/0x120
[ 6819.501009]  [<ffffffff810d1970>] ? kthread_create_on_node+0x250/0x250=

[ 6819.501009]  [<ffffffff81867aef>] ret_from_fork+0x3f/0x70
[ 6819.501009]  [<ffffffff810d1970>] ? kthread_create_on_node+0x250/0x250=




--9DiHjOX0bQxrdmvbt0W4lFSHuaHeViWul
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVthVCAAoJEHTzHJCtsuoCTKUH+gLqmn0tY4gVViZE4FjYXBq/
cWt8bapX0ax+KCXrwPm3ni+vrFBvXiLIh2gGqjXxMwk3lcw+SFXdokYbH1+mm3zy
JQVRgUwy2woqHouUkOt7R21HUNNzybObtNjfHYo/EkLORm3MB2Y5lm0eXWvFZkZF
MfFYQzFVfs4WDX7NAspHi3asLPz0pORWCZd3jZewbdm++hpj+EeoIwkr4okFu4bv
UzctQQIxHERGScThdk2N7/jAQkDfHPAoIsp3tMBYV7H1R/kO7+bbiKdV+3RDmeXo
iFeKSsoLctq8ONChexPdsXg2gKwwEyYJsqLYlligbaoSuNNysssfzsuifIbDlXw=
=r4WN
-----END PGP SIGNATURE-----

--9DiHjOX0bQxrdmvbt0W4lFSHuaHeViWul--
