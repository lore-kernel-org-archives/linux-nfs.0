Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:48159 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933023Ab1CXS3q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Mar 2011 14:29:46 -0400
Date: Thu, 24 Mar 2011 14:29:41 -0400
From: Eric B Munson <emunson@mgebm.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: NFS Regression in commit 0b26a0bf6ff398
Message-ID: <20110324182941.GA9476@mgebm.net>
References: <20110216005640.GA2841@mgebm.net>
 <1297818155.10103.43.camel@heimdal.trondhjem.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="nFreZHaLTZJo0R7j"
In-Reply-To: <1297818155.10103.43.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 15 Feb 2011, Trond Myklebust wrote:

> On Tue, 2011-02-15 at 19:56 -0500, Eric B Munson wrote:=20
> > While testing some 2.6.38 work my rsync backup script started consuming
> > large amounts of memory (all available before dying with no more availa=
ble
> > memory).  I have bisected the problem back to 0b26a0bf6ff398.  I am
> > unfamiliar with the NFS code so I don't know where to start looking for=
 a
> > possible fix.  My backups files from my home directory to an NFS mounted
> > directory.  The NFS server is a Synology DS-411+ if it matters.  Let me=
 know
> > if there is any other information I can provide.
>=20
> Exactly which 2.6.38 kernel are you running, and which NFS version?
>=20
> I'm having trouble seeing how the patch in question can be responsible
> for what you are seeing, so please could you provide more details of
> your test setup.
>=20

I am running 2.6.38 and still having this problem.  The strace output from
earlier still applies and here is output from SysRq+L for the strace proces=
ses:

[20965.685696] SysRq : Show backtrace of all active CPUs
[20965.685699] sending NMI to all CPUs:
[20965.685702] NMI backtrace for cpu 0
[20965.685704] CPU 0=20
[20965.685705] Modules linked in: binfmt_misc nfs lockd fscache nfs_acl aut=
h_rpcgss sunrpc kvm_intel kvm parport_pc ppdev snd_hda_codec_hdmi snd_hda_c=
odec_realtek radeon deflate zlib_deflate ctr twofish_generic twofish_x86_64=
 twofish_common camellia serpent blowfish cast5 des_generic aesni_intel cry=
ptd aes_x86_64 aes_generic xcbc rmd160 sha512_generic sha256_generic snd_hd=
a_intel snd_hda_codec ttm sha1_generic crypto_null af_key snd_usb_audio snd=
_usbmidi_lib snd_hwdep snd_pcm snd_seq_midi snd_rawmidi drm_kms_helper snd_=
seq_midi_event snd_seq drm snd_timer snd_seq_device uvcvideo snd hwmon_vid =
i7core_edac psmouse xhci_hcd max6650 videodev edac_core joydev lp asus_atk0=
110 parport snd_page_alloc hid_microsoft i2c_algo_bit soundcore v4l2_compat=
_ioctl32 serio_raw usbhid hid firewire_ohci firewire_core crc_itu_t sky2 ah=
ci libahci
[20965.685747]=20
[20965.685748] Pid: 9210, comm: rsync Not tainted 2.6.38+ #38 System manufa=
cturer System Product Name/P6X58D PREMIUM
[20965.685752] RIP: 0010:[<ffffffffa0551870>]  [<ffffffffa0551870>] put_rpc=
cred+0x40/0x150 [sunrpc]
[20965.685763] RSP: 0018:ffff88032178fc88  EFLAGS: 00000202
[20965.685765] RAX: 0000000000000006 RBX: ffff88031ae27500 RCX: 8c6318c6318=
c6320
[20965.685766] RDX: 000000000000fcfb RSI: ffff8800bd600000 RDI: ffff88031ae=
27500
[20965.685767] RBP: ffff88032178fc98 R08: 0000000000000000 R09: 00000000000=
00001
[20965.685769] R10: 0000000000000001 R11: 0000000000000001 R12: 00000000000=
00001
[20965.685770] R13: ffff880296962778 R14: ffff88031ae27500 R15: 00000000000=
00000
[20965.685772] FS:  00007fe320eb8700(0000) GS:ffff8800bd600000(0000) knlGS:=
0000000000000000
[20965.685773] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[20965.685774] CR2: 000000000a9c1fe0 CR3: 00000003243f7000 CR4: 00000000000=
006f0
[20965.685776] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[20965.685777] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000=
00400
[20965.685779] Process rsync (pid: 9210, threadinfo ffff88032178e000, task =
ffff8803228bc620)
[20965.685780] Stack:
[20965.685781]  0000000000000000 0000000000000001 ffff88032178fcd8 ffffffff=
a079a0da
[20965.685785]  ffff88032178fd28 ffff880323d2a009 ffff880323d2a009 ffff8803=
2178fdc8
[20965.685788]  ffff880296962778 ffff8803228bc620 ffff88032178fd78 ffffffff=
81171112
[20965.685791] Call Trace:
[20965.685799]  [<ffffffffa079a0da>] nfs_permission+0xea/0x1d0 [nfs]
[20965.685803]  [<ffffffff81171112>] link_path_walk+0x222/0xaa0
[20965.685807]  [<ffffffff8116f9a8>] ? path_init_rcu+0x98/0x270
[20965.685809]  [<ffffffff81171c6b>] do_path_lookup+0x5b/0x140
[20965.685811]  [<ffffffff811729f7>] user_path_at+0x57/0xa0
[20965.685818]  [<ffffffff81125bcc>] ? might_fault+0x5c/0xb0
[20965.685820]  [<ffffffff81167d68>] ? cp_new_stat+0xf8/0x110
[20965.685822]  [<ffffffff81167f96>] vfs_fstatat+0x46/0x80
[20965.685824]  [<ffffffff8116803e>] vfs_lstat+0x1e/0x20
[20965.685826]  [<ffffffff81168064>] sys_newlstat+0x24/0x50
[20965.685830]  [<ffffffff815ac999>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[20965.685834]  [<ffffffff81002f82>] system_call_fastpath+0x16/0x1b
[20965.685836] Code: 00 48 8b 47 50 48 89 fb a8 04 75 1f f0 ff 4f 58 0f 94 =
c0 84 c0 0f 85 fd 00 00 00 48 8b 1c 24 4c 8b 64 24 08 c9 c3 eb 03 90 90 90 =
<48> 83 c7 58 48 c7 c6 a0 cd 56 a0 e8 f0 60 d8 e0 85 c0 74 dc 48=20
[20965.685874] Call Trace:
[20965.685883]  [<ffffffffa079a0da>] nfs_permission+0xea/0x1d0 [nfs]
[20965.685888]  [<ffffffff81171112>] link_path_walk+0x222/0xaa0
[20965.685894]  [<ffffffff8116f9a8>] ? path_init_rcu+0x98/0x270
[20965.685898]  [<ffffffff81171c6b>] do_path_lookup+0x5b/0x140
[20965.685902]  [<ffffffff811729f7>] user_path_at+0x57/0xa0
[20965.685907]  [<ffffffff81125bcc>] ? might_fault+0x5c/0xb0
[20965.685912]  [<ffffffff81167d68>] ? cp_new_stat+0xf8/0x110
[20965.685917]  [<ffffffff81167f96>] vfs_fstatat+0x46/0x80
[20965.685921]  [<ffffffff8116803e>] vfs_lstat+0x1e/0x20
[20965.685928]  [<ffffffff81168064>] sys_newlstat+0x24/0x50
[20965.685931]  [<ffffffff815ac999>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[20965.685933]  [<ffffffff81002f82>] system_call_fastpath+0x16/0x1b
[20965.685935] Pid: 9210, comm: rsync Not tainted 2.6.38+ #38
[20965.685936] Call Trace:
[20965.685937]  <NMI>  [<ffffffff8100ba27>] ? show_regs+0x27/0x30
[20965.685942]  [<ffffffff815af4d6>] ? arch_trigger_all_cpu_backtrace_handl=
er+0x76/0x90
[20965.685945]  [<ffffffff815b1786>] ? notifier_call_chain+0x56/0x80
[20965.685947]  [<ffffffff815b181c>] ? __atomic_notifier_call_chain+0x6c/0x=
a0
[20965.685949]  [<ffffffff815b17b0>] ? __atomic_notifier_call_chain+0x0/0xa0
[20965.685951]  [<ffffffff815b1866>] ? atomic_notifier_call_chain+0x16/0x20
[20965.685953]  [<ffffffff815b189e>] ? notify_die+0x2e/0x30
[20965.685956]  [<ffffffff815ae58a>] ? do_nmi+0xda/0x290
[20965.685958]  [<ffffffff815ae0f0>] ? nmi+0x20/0x39
[20965.685963]  [<ffffffffa0551870>] ? put_rpccred+0x40/0x150 [sunrpc]
[20965.685965]  <<EOE>>  [<ffffffffa079a0da>] ? nfs_permission+0xea/0x1d0 [=
nfs]
[20965.685971]  [<ffffffff81171112>] ? link_path_walk+0x222/0xaa0
[20965.685973]  [<ffffffff8116f9a8>] ? path_init_rcu+0x98/0x270
[20965.685975]  [<ffffffff81171c6b>] ? do_path_lookup+0x5b/0x140
[20965.685977]  [<ffffffff811729f7>] ? user_path_at+0x57/0xa0
[20965.685979]  [<ffffffff81125bcc>] ? might_fault+0x5c/0xb0
[20965.685981]  [<ffffffff81167d68>] ? cp_new_stat+0xf8/0x110
[20965.685983]  [<ffffffff81167f96>] ? vfs_fstatat+0x46/0x80
[20965.685985]  [<ffffffff8116803e>] ? vfs_lstat+0x1e/0x20
[20965.685987]  [<ffffffff81168064>] ? sys_newlstat+0x24/0x50
[20965.685990]  [<ffffffff815ac999>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[20965.685992]  [<ffffffff81002f82>] ? system_call_fastpath+0x16/0x1b


This is the pid that gets stuck on lstat.  Is there anything else that mugh=
t be
helpful?

--nFreZHaLTZJo0R7j
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNi42VAAoJEH65iIruGRnNBukH/jwoY5WrlQ4U91oF1/WhW/nD
ZqgfAtn5JljCU9HU+gOIvVvPhmgEEQHAspKRG+fmT53A3mDNXUM/4Lb2uBBGvLaz
8gEEda5Jb1iGAIjRBVP6KR2IjSEtWIAOt0iQ57zMLVUaBzQmgMLVlqGSfCTiPB+m
amtsc+LWP7m7xkFRPhRLkoiPHgPrvlVd8tqRH+fTIpfDGxUPUAAyypniNeq3xyMC
POzzVpp9g6Q7u6kDAejFW0mbcu9NGa0YKLbRLQrN98whlZYWtw89MXwPklU1oJhJ
Rb9h/O8cfQNKp7xPEpBzPiFqI6jacT2aFY2zxqlwI0V1Sz24sUlvSfAkW4qzq8k=
=ZTjK
-----END PGP SIGNATURE-----

--nFreZHaLTZJo0R7j--
