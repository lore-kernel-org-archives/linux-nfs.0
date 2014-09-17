Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.19]:50827 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754720AbaIQNac (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Sep 2014 09:30:32 -0400
From: Marc Dietrich <marvin24@gmx.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: kernel BUG at fs/dcache.c (3.17-rc4/5)
Date: Wed, 17 Sep 2014 15:30:24 +0200
Message-ID: <1658831.xKpFJcpMRg@fb07-iapwap2>
In-Reply-To: <CAHQdGtSN-_Te1UJxt7x52oUTG9BBaTpsDFpEzjWUs7HiKGS4Ng@mail.gmail.com>
References: <36181213.M9hWk1po2a@fb07-iapwap2> <CAHQdGtSN-_Te1UJxt7x52oUTG9BBaTpsDFpEzjWUs7HiKGS4Ng@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart9601145.NSePqdTMle"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--nextPart9601145.NSePqdTMle
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="UTF-8"

Hi Trond,

Am Mittwoch, 17. September 2014, 09:21:05 schrieb Trond Myklebust:
> On Wed, Sep 17, 2014 at 9:05 AM, Marc Dietrich <marvin24@gmx.de> wrote:
> > Hi,
> >
> > I get this roughly once in a week. Hard to reproduce.
> >
> > Sep 17 14:44:21 fb07-iapwap2 kernel: ------------[ cut here ]------------
> > Sep 17 14:44:21 fb07-iapwap2 kernel: kernel BUG at fs/dcache.c:1619!
> > Sep 17 14:44:22 fb07-iapwap2 kernel: invalid opcode: 0000 [#1] PREEMPT SMP
> > Sep 17 14:44:22 fb07-iapwap2 kernel: Modules linked in: vboxpci(O) vboxnetadp(O) vboxnetflt(O) vboxdrv(O) loop fuse af_packet bnep bluetooth
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  snd_seq_device sr_mod kvm_amd kvm pcspkr firewire_ohci firewire_core crc_itu_t serio_raw edac_core cdr
> > Sep 17 14:44:22 fb07-iapwap2 kernel: CPU: 2 PID: 25065 Comm: plasma-desktop Tainted: G           O   3.17.0-rc5-12.gfc9498b-desktop+ #9
> > Sep 17 14:44:22 fb07-iapwap2 kernel: Hardware name: System manufacturer System Product Name/M4A785TD-V EVO, BIOS 2105    07/23/2010
> > Sep 17 14:44:22 fb07-iapwap2 kernel: task: ffff880045030210 ti: ffff8800b2d58000 task.ti: ffff8800b2d58000
> > Sep 17 14:44:22 fb07-iapwap2 kernel: RIP: 0010:[<ffffffff811cfd48>]  [<ffffffff811cfd48>] d_instantiate+0x68/0x70
> > Sep 17 14:44:22 fb07-iapwap2 kernel: RSP: 0018:ffff8800b2d5ba48  EFLAGS: 00010286
> > Sep 17 14:44:22 fb07-iapwap2 kernel: RAX: 0000000000080007 RBX: ffff88002e4e10d8 RCX: 0000000000000000
> > Sep 17 14:44:22 fb07-iapwap2 kernel: RDX: 0000000000000008 RSI: 0000000000000000 RDI: ffff88002e4e10d8
> > Sep 17 14:44:22 fb07-iapwap2 kernel: RBP: ffff8800b2d5bae8 R08: 0000000000000000 R09: 0000000000000000
> > Sep 17 14:44:22 fb07-iapwap2 kernel: R10: 0000000000000546 R11: 0000000000000000 R12: ffff8800d9e65800
> > Sep 17 14:44:22 fb07-iapwap2 kernel: R13: ffff8800d9e65800 R14: ffff88009fe6c718 R15: ffff880100d73c00
> > Sep 17 14:44:22 fb07-iapwap2 kernel: FS:  00007f8a581ae780(0000) GS:ffff88011fc80000(0000) knlGS:00000000f5101b40
> > Sep 17 14:44:22 fb07-iapwap2 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > Sep 17 14:44:22 fb07-iapwap2 kernel: CR2: 00007f8a2e6ff6a0 CR3: 0000000045d96000 CR4: 00000000000007e0
> > Sep 17 14:44:22 fb07-iapwap2 kernel: Stack:
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  ffffffffc0acc1c0 ffff8800ce2e9060 0000000100000000 ffff880000008000
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  ffff8800fffffffe ffff8800b2d5ba90 ffffffffc0adfece ffff88006d58baa0
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  0000000000000000 ffff88006d58bb28 ffff8800ce2e9000 0000000000008000
> > Sep 17 14:44:22 fb07-iapwap2 kernel: Call Trace:
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  [<ffffffffc0acc1c0>] ? _nfs4_open_and_get_state+0x220/0x3f0 [nfsv4]
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  [<ffffffffc0adfece>] ? nfs4_get_open_state+0x6e/0x190 [nfsv4]
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  [<ffffffffc0adffb3>] ? nfs4_get_open_state+0x153/0x190 [nfsv4]
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  [<ffffffffc0acf323>] nfs4_do_open+0x1b3/0x5b0 [nfsv4]
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  [<ffffffffc0acf7f7>] nfs4_atomic_open+0xd7/0x100 [nfsv4]
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  [<ffffffffc0ae2b96>] nfs4_file_open+0xc6/0x1d0 [nfsv4]
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  [<ffffffffc0ae2ad0>] ? nfs4_file_fsync+0xa0/0xa0 [nfsv4]
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  [<ffffffff811b5052>] do_dentry_open+0x1d2/0x320
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  [<ffffffff811b536c>] finish_open+0x2c/0x50
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  [<ffffffff811c782c>] do_last+0xc0c/0x1250
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  [<ffffffff811c7f26>] path_openat+0xb6/0x680
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  [<ffffffff81152439>] ? do_writepages+0x19/0x30
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  [<ffffffffc0ae337e>] ? nfs4_have_delegation+0xe/0x10 [nfsv4]
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  [<ffffffff811c8ce5>] do_filp_open+0x35/0xa0
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  [<ffffffff811d58cf>] ? __alloc_fd+0x9f/0x130
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  [<ffffffff811b6ba7>] do_sys_open+0x127/0x220
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  [<ffffffff811b6cb9>] SyS_open+0x19/0x20
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  [<ffffffff8162316d>] system_call_fastpath+0x1a/0x1f
> > Sep 17 14:44:22 fb07-iapwap2 kernel: Code: 29 45 00 48 89 de 4c 89 e7 e8 45 98 0d 00 5b 41 5c 41 5d 5d c3 66 0f 1f 44 00 00 31 f6 e8 a1 fe f
> > Sep 17 14:44:22 fb07-iapwap2 kernel: RIP  [<ffffffff811cfd48>] d_instantiate+0x68/0x70
> > Sep 17 14:44:22 fb07-iapwap2 kernel:  RSP <ffff8800b2d5ba48>
> > Sep 17 14:44:22 fb07-iapwap2 kernel: ---[ end trace ff4ccb4b65178939 ]---
> >
> > Full log of blocked tasks attached.
> >
> > Marc
> 
> Does the following commit fix it?
> http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=commit;h=f39c01047994e66e7f3d89ddb4c6141f23349d8d

I will tell you in a week or two I guess.

Thanks so far!

Marc


--nextPart9601145.NSePqdTMle
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQEcBAABAgAGBQJUGYzwAAoJEKyeR39HFBtolXUH/1oyYityqSdPRefvxZevWf2H
Q8YShOhJB3AAoYI3k4kQHkDiYmxTxIjOm9EFDdwT0KACf6CSn/asHarTu70c5Tuq
KoO56OX6NTAzg7lkjVVQ1IQVUtbpQ5FEPVgAws+zj51oZXbT8aeMxv9rrSLP74eY
3wluzDunZ505HgoLMoZ8vFiDgdIfLsxRbeBDatjsdQqR36IZoz3VtRCTTazyL2ZW
5ADLPd891iIVb9149H/HVuqmNhF+QaJ/6ofW7HfR7CKrVjMM/W3prmdafGNmgxMy
51zP0pFrMpy6w/r1ek/NpE2zRRh5EIeau6zsfxxlSTWutFR7wg0b2jYwz93N4mM=
=wBLb
-----END PGP SIGNATURE-----

--nextPart9601145.NSePqdTMle--

