Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga02.intel.com ([134.134.136.20]:16122 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934518Ab2FHV7g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jun 2012 17:59:36 -0400
Date: Sat, 9 Jun 2012 01:00:49 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Boaz Harrosh <bharrosh@panasas.com>, Tao Ma <boyu.mt@taobao.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Nick Piggin <npiggin@kernel.dk>, "Dmitry V. Levin" <ldv@altlinux.org>,
        v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-btrfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        codalist@TELEMANN.coda.cs.cmu.edu, ecryptfs@vger.kernel.org,
        osd-dev@open-osd.org, linux-ext4@vger.kernel.org,
        fuse-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        jfs-discussion@lists.sourceforge.net, logfs@logfs.org,
        linux-nfs@vger.kernel.org, linux-nilfs@vger.kernel.org,
        linux-ntfs-dev@lists.sourceforge.net, ocfs2-devel@oss.oracle.com,
        reiserfs-devel@vger.kernel.org
Subject: Re: [RFC, PATCH] fs: push rcu_barrier() from
 deactivate_locked_super() to filesystems
Message-ID: <20120608220049.GA18024@otc-wbsnb-06>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dDRMvlgZJXvWKvBx"
In-Reply-To: <1339191663-17693-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 08, 2012 at 02:43:58PM -0700, Linus Torvalds wrote:
> On Fri, Jun 8, 2012 at 2:28 PM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> >
> > There's no reason to call rcu_barrier() on every deactivate_locked_supe=
r().
> > We only need to make sure that all delayed rcu free inodes are flushed
> > before we destroy related cache.
> >
> > Removing rcu_barrier() from deactivate_locked_super() affects some
> > fas paths. E.g. on my machine exit_group() of a last process in IPC
> > namespace takes 0.07538s. rcu_barrier() takes 0.05188s of that time.
>=20
> I think we should just delete it.
>=20
> kmem_cache_destroy() (at least for SLUB) already has:
>=20
>                 if (s->flags & SLAB_DESTROY_BY_RCU)
>                         rcu_barrier();
>=20
> in it. But I think it's too late - it gets called *after* we do
> kmem_cache_close(), and I get the feeling that we should do it before.
>=20
> Shouldn't that be sufficient? And if other slab allocators don't have
> this, we should add it to them too.
>=20
> Hmm?

When I tried SLAB_DESTROY_BY_RCU I've got problem:

[   36.687999] Pid: 3455, comm: rmmod Not tainted 3.5.0-rc1-00130-g48d212a-=
dirty #40
[   36.688001] Call Trace:
[   36.688012]  [<ffffffff8113367a>] slab_err+0xaa/0xd0
[   36.688020]  [<ffffffff8113515a>] ? __kmalloc+0x10a/0x110
[   36.688026]  [<ffffffff8113647d>] kmem_cache_destroy+0x1dd/0x420
[   36.688056]  [<ffffffffa00f0f25>] btrfs_destroy_cachep+0x15/0x60 [btrfs]
[   36.688076]  [<ffffffffa013cac3>] exit_btrfs_fs+0x9/0x3a [btrfs]
[   36.688083]  [<ffffffff810c324e>] sys_delete_module+0x16e/0x2f0
[   36.688090]  [<ffffffff8128cf29>] ? lockdep_sys_exit_thunk+0x35/0x67
[   36.688097]  [<ffffffff8161eba6>] system_call_fastpath+0x1a/0x1f
[   36.688111] Pid: 3455, comm: rmmod Not tainted 3.5.0-rc1-00130-g48d212a-=
dirty #40
[   36.688114] Call Trace:
[   36.688119]  [<ffffffff811365ee>] kmem_cache_destroy+0x34e/0x420
[   36.688143]  [<ffffffffa00f0f25>] btrfs_destroy_cachep+0x15/0x60 [btrfs]
[   36.688162]  [<ffffffffa013cac3>] exit_btrfs_fs+0x9/0x3a [btrfs]
[   36.688168]  [<ffffffff810c324e>] sys_delete_module+0x16e/0x2f0
[   36.688174]  [<ffffffff8128cf29>] ? lockdep_sys_exit_thunk+0x35/0x67
[   36.688179]  [<ffffffff8161eba6>] system_call_fastpath+0x1a/0x1f

IIUC, moving rcu_barrier() up should help, but I can't say that I fully
understand SLAB_DESTROY_BY_RCU semantics.

--=20
 Kirill A. Shutemov

--dDRMvlgZJXvWKvBx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJP0nYQAAoJEAd+omnVudOMbF0QAKpg3Zcvr4yESZua/Bv1bnzX
jkOHQHWJ3NunwtuR7SOhvXfvXXDS7jVfVjlpR6gjF1LmsRqrE/aTCFsz73npYIFc
s9ne9/pjA7kewL3jOQqv1ujZ4s4JGXo/4fWL6vOlvYio4+x8UlaKH5z2vI1brc/K
ASQ/WqoO5ndxoUOE3RrssnSlkvII6PAQlno44mCberhpplOm1F7r3+BWNB3e6h9b
ItpmSAYpBqSOhjBl1Ek/TQElCvDIJddQJ3E++UaDQlm6JyABzRUHOCuzXiVYMVES
8MdIDpn35/gywY3KYxwxweX7F8H/GtmY/swn/Bujb9phKud9Xh/hw7td+aWJcrDU
6AvAS+BMAWLrZi5cSvWn3JnGZNzC6/FJE47nUUn/7mjYNyE5YnVMyNjZA1a3PPu+
VW0LZdKGjq30hGjhth1HzPGNFUHP6H/ks7H8LU2ycXeuc+CDN0OdOFjCJTWlWnBj
FxspDEQhlYzBt4WUwF8pq47i4HBZYJjGSaR9CHFVB/Uw1DiX/asLEyBNq3r/F0Kq
PW97ykg0bYVl++5ImfPJiLvd1uPUMltyS0KUGb5U7h9UyC/AndHLGVgGt4g3cSju
QVpqUCxCEcU4R2HiDJ44YiO0x9pJeZ1Z70B5zi/Fhx5sCKB0j1CoD/WYlTOrFxqA
es9Jc2r5bucrvbquOhCb
=1MlR
-----END PGP SIGNATURE-----

--dDRMvlgZJXvWKvBx--
