Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga03.intel.com ([143.182.124.21]:38513 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759866Ab2FHX07 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jun 2012 19:26:59 -0400
Date: Sat, 9 Jun 2012 02:28:11 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Boaz Harrosh <bharrosh@panasas.com>, Tao Ma <boyu.mt@taobao.com>,
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
Subject: Re: [RFC, PATCH, RESEND] fs: push rcu_barrier() from
 deactivate_locked_super() to filesystems
Message-ID: <20120608232811.GA18981@otc-wbsnb-06>
References: <1339191663-17693-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20120608150253.e42464a6.akpm@linux-foundation.org>
 <20120608221446.GA18250@otc-wbsnb-06>
 <20120608152550.258d6a30.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="BOKacYhQ+x31HxR3"
In-Reply-To: <20120608152550.258d6a30.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 08, 2012 at 03:25:50PM -0700, Andrew Morton wrote:
> On Sat, 9 Jun 2012 01:14:46 +0300
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
>=20
> > On Fri, Jun 08, 2012 at 03:02:53PM -0700, Andrew Morton wrote:
> > > On Sat,  9 Jun 2012 00:41:03 +0300
> > > "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > >=20
> > > > There's no reason to call rcu_barrier() on every deactivate_locked_=
super().
> > > > We only need to make sure that all delayed rcu free inodes are flus=
hed
> > > > before we destroy related cache.
> > > >=20
> > > > Removing rcu_barrier() from deactivate_locked_super() affects some
> > > > fas paths. E.g. on my machine exit_group() of a last process in IPC
> > > > namespace takes 0.07538s. rcu_barrier() takes 0.05188s of that time.
> > >=20
> > > What an unpleasant patch.  Is final-process-exiting-ipc-namespace a
> > > sufficiently high-frequency operation to justify the change?
>=20
> This, please.

ALT Linux guys use a namespaces (including IPC namespace) to create
sandbox[1] for build system and other use cases. The build system calls
the sandboxing wrapper frequently on setup building chroot and build
prepare. This kind of delays affect timings significantly.

[1] http://git.altlinux.org/people/ldv/packages/hasher-priv.git

> > > I don't really understand what's going on here.  Are you saying that
> > > there is some filesystem against which we run deactivate_locked_super=
()
> > > during exit_group(), and that this filesystem doesn't use rcu-freeing
> > > of inodes?  The description needs this level of detail, please.
>=20
> You still haven't explained where this deactivate_locked_super() call
> is coming from.  Oh well.

Call Trace:
 [<ffffffff81443a2a>] schedule+0x3a/0x50
 [<ffffffff81441e7d>] schedule_timeout+0x1cd/0x2c0
 [<ffffffff811f8f87>] ? mqueue_destroy_inode+0x17/0x20
 [<ffffffff81443044>] wait_for_common+0xc4/0x160
 [<ffffffff8107af50>] ? try_to_wake_up+0x2a0/0x2a0
 [<ffffffff810d63b0>] ? call_rcu_sched+0x10/0x20
 [<ffffffff810d63a0>] ? call_rcu_bh+0x20/0x20
 [<ffffffff81443188>] wait_for_completion+0x18/0x20
 [<ffffffff810d5a9b>] _rcu_barrier.clone.31+0x9b/0xb0
 [<ffffffff810d5ac0>] rcu_barrier_sched+0x10/0x20
 [<ffffffff810d5ad9>] rcu_barrier+0x9/0x10
 [<ffffffff811602c9>] deactivate_locked_super+0x49/0x90
 [<ffffffff81160d35>] deactivate_super+0x45/0x60
 [<ffffffff8117ad74>] mntput_no_expire+0x104/0x150
 [<ffffffff8117addc>] mntput+0x1c/0x30
 [<ffffffff8117cda7>] kern_unmount+0x27/0x30
 [<ffffffff811faeb0>] mq_put_mnt+0x10/0x20
 [<ffffffff811fb57f>] put_ipc_ns+0x3f/0xb0
 [<ffffffff81071f5c>] free_nsproxy+0x3c/0xa0
 [<ffffffff81072143>] switch_task_namespaces+0x33/0x40
 [<ffffffff8107215b>] exit_task_namespaces+0xb/0x10
 [<ffffffff8104f154>] do_exit+0x4b4/0x8a0
 [<ffffffff8104f7e3>] do_group_exit+0x53/0xc0
 [<ffffffff8104f862>] sys_exit_group+0x12/0x20
 [<ffffffff8144c939>] system_call_fastpath+0x16/0x1b

--=20
 Kirill A. Shutemov

--BOKacYhQ+x31HxR3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJP0oqLAAoJEAd+omnVudOMcP4QAKbbNKoSRJWh+GzG3pvNAERZ
iqlVtKYEJR+i+ABIR3HFB3QHWuUceas8yvu1UhyX2X4NbM80uJXPsw4DDfokoGSp
HMbSkAnax60LiLXy25HIkKKZGz+Ku/moPXrjLt6fKZ0jaH1Fg0WWRSTzvl3StEAs
ffFNVb1ij6eRMgedrmP0XKJ1LFeYh4CJLZg26EvYLgY5LwLNGaV6w4PyQsdcN0n7
GPr6PQRYaEasB+QYDCzvHOf/2MdRqel8XdJZBBoEWirPZ89+98/3tRghY2PSoLOc
il/URPjcM+ni4BRYAuV5w3iVzR0uDxPZBEnQ+VC5ZGq8qQxR03/+Mk5OXNGf5lhn
A7OToIUBnbVazr07xz8k+oJNqr4KRSZuUVNzBv5CmLp9O3NcUJmK0Su5YtjwbqVw
bAYUQv5mFA4cUC4tiqodc8Nntare/ClKxT8eMGCgSFfMceLVEQN8rNJtGXgBwYGF
bjhIbaaBVYPM6Txp1yHdC62ljOLX8YXVZSXCV6KoTm+chksizM0ggDxyDGGFLy5c
leG8JFpidGspSGJ6v9eFLoOm00EAYf/sQtiTOq/FQmBh4F6kQ2wx+M0z64uA5cOm
p6qQUXbHty1wQCQ0wdj99pmCAm6lvK2VFfm1WTsoBOc4WtHp5bLVAVbXGDAsSCu+
FPI6ekiivc98Ot0YKE2h
=mjfa
-----END PGP SIGNATURE-----

--BOKacYhQ+x31HxR3--
