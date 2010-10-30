Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from server.klug.on.ca ([205.189.48.131]:1992 "EHLO
	server.klug.on.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755170Ab0J3Rl7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Oct 2010 13:41:59 -0400
Received: from linux.interlinx.bc.ca (d67-193-197-208.home3.cgocable.net [67.193.197.208])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id 29DA72803
	for <linux-nfs@vger.kernel.org>; Sat, 30 Oct 2010 13:41:57 -0400 (EDT)
Received: from [10.75.22.1] (pc.ilinx [10.75.22.1])
	by linux.interlinx.bc.ca (Postfix) with ESMTP id B8DDE86B0
	for <linux-nfs@vger.kernel.org>; Sat, 30 Oct 2010 13:41:55 -0400 (EDT)
Subject: Re: Error: state manager failed on NFSv4 server linux with error
 127
From: "Brian J. Murrell" <brian@interlinx.bc.ca>
To: linux-nfs@vger.kernel.org
In-Reply-To: <1287340520.5266.70.camel@heimdal.trondhjem.org>
References: <1287334833.4871.6.camel@pc>
	 <1287340520.5266.70.camel@heimdal.trondhjem.org>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-ehdaAu6oRVPchof99M8o"
Date: Sat, 30 Oct 2010 13:41:54 -0400
Message-ID: <1288460514.32627.105.camel@pc>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--=-ehdaAu6oRVPchof99M8o
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2010-10-17 at 14:35 -0400, Trond Myklebust wrote:=20
>=20
> Error 127 is EKEYEXPIRED. It means that the RPCSEC_GSS context for at
> least one of your threads has expired.
>=20
> Sigh... It looks as if we have a really poor handling of that in the
> recovery threads.
>=20
> Does the following patch help?

Well, while I don't seem to have had any of the state manager failed
errors, I did have a number of processes blocked in NFS4 today with the
patched kernel running:

[316999.281908] SysRq : Show Blocked State
[316999.285576]   task                PC stack   pid father
[316999.285576] rhythmbox     D f32d1c9c     0 12726  12614 0x00000000
[316999.285576]  f32d1cac 00000086 00000002 f32d1c9c f32d1c70 c05d89e0 c08c=
1700 c08c1700
[316999.285576]  0dbaa7a3 0001204f c08c1700 c08c1700 0dba7e9d 0001204f 0000=
0000 c08c1700
[316999.285576]  c08c1700 ef127230 00000001 f32d1ce0 00000000 f32d1ce8 f32d=
1cb4 f83eac0c
[316999.285576] Call Trace:
[316999.285576]  [<f83eac0c>] rpc_wait_bit_killable+0x1c/0x40 [sunrpc]
[316999.285576]  [<c05c761d>] __wait_on_bit+0x4d/0x70
[316999.285576]  [<f83eabf0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
[316999.285576]  [<f83eabf0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
[316999.285576]  [<c05c76eb>] out_of_line_wait_on_bit+0xab/0xc0
[316999.285576]  [<c0165e60>] ? wake_bit_function+0x0/0x50
[316999.285576]  [<f83eb31b>] __rpc_execute+0xdb/0x250 [sunrpc]
[316999.285576]  [<f83eaa17>] ? rpc_init_task+0xd7/0x120 [sunrpc]
[316999.285576]  [<f83eb4fe>] rpc_execute+0x6e/0x80 [sunrpc]
[316999.285576]  [<f83e49af>] rpc_run_task+0x1f/0x30 [sunrpc]
[316999.285576]  [<f83e4abe>] rpc_call_sync+0x3e/0x60 [sunrpc]
[316999.285576]  [<f82345d2>] _nfs4_call_sync+0x22/0x30 [nfs]
[316999.285576]  [<f82333a3>] _nfs4_proc_access+0xe3/0x170 [nfs]
[316999.285576]  [<f8233469>] nfs4_proc_access+0x39/0x60 [nfs]
[316999.285576]  [<f8218edd>] nfs_do_access+0x7d/0xc0 [nfs]
[316999.285576]  [<f8218f98>] nfs_permission+0x78/0x1a0 [nfs]
[316999.285576]  [<c022309a>] ? do_lookup+0x7a/0x1c0
[316999.285576]  [<c02212ea>] exec_permission+0x2a/0x90
[316999.285576]  [<c0223867>] link_path_walk+0x67/0x890
[316999.285576]  [<c02241b1>] path_walk+0x51/0xc0
[316999.285576]  [<c0224339>] do_path_lookup+0x59/0x90
[316999.285576]  [<c0224e81>] user_path_at+0x41/0x80
[316999.285576]  [<c032e626>] ? apparmor_file_permission+0x16/0x20
[316999.285576]  [<c016ffbd>] ? ktime_get_ts+0xed/0x120
[316999.285576]  [<c016fb56>] ? getnstimeofday+0x56/0x120
[316999.285576]  [<c024ad63>] sys_inotify_add_watch+0x63/0x100
[316999.285576]  [<c0228829>] ? sys_poll+0x59/0xc0
[316999.285576]  [<c05c90a4>] syscall_call+0x7/0xb
[316999.285576] pidgin        D dfa25d04     0 12742  12614 0x00000000
[316999.285576]  dfa25d14 00000086 00000002 dfa25d04 f83ea917 c05d89e0 c08c=
1700 c08c1700
[316999.285576]  d7f600c4 0001204c c08c1700 c08c1700 d7f5ce5a 0001204c 0000=
0000 c08c1700
[316999.285576]  c08c1700 efb46580 00000001 c08fa500 c08fa500 dfa25d34 dfa2=
5d78 c05c72df
[316999.285576] Call Trace:
[316999.285576]  [<f83ea917>] ? rpc_put_task+0x77/0x80 [sunrpc]
[316999.285576]  [<c05c72df>] schedule_timeout+0x12f/0x270
[316999.285576]  [<c01589c0>] ? process_timeout+0x0/0x10
[316999.285576]  [<c05c745a>] schedule_timeout_killable+0x1a/0x20
[316999.285576]  [<f823132d>] nfs4_delay+0x2d/0x70 [nfs]
[316999.285576]  [<f823150a>] nfs4_handle_exception+0xfa/0x180 [nfs]
[316999.285576]  [<f823347e>] nfs4_proc_access+0x4e/0x60 [nfs]
[316999.285576]  [<f8218edd>] nfs_do_access+0x7d/0xc0 [nfs]
[316999.285576]  [<f8218f98>] nfs_permission+0x78/0x1a0 [nfs]
[316999.285576]  [<c022309a>] ? do_lookup+0x7a/0x1c0
[316999.285576]  [<c02212ea>] exec_permission+0x2a/0x90
[316999.285576]  [<c0223867>] link_path_walk+0x67/0x890
[316999.285576]  [<c02241b1>] path_walk+0x51/0xc0
[316999.285576]  [<c0224339>] do_path_lookup+0x59/0x90
[316999.285576]  [<c0224e81>] user_path_at+0x41/0x80
[316999.285576]  [<c021c9da>] vfs_fstatat+0x3a/0x70
[316999.285576]  [<c021cb30>] vfs_stat+0x20/0x30
[316999.285576]  [<c021cb59>] sys_stat64+0x19/0x30
[316999.285576]  [<c016fb56>] ? getnstimeofday+0x56/0x120
[316999.285576]  [<c035a249>] ? copy_to_user+0x39/0x130
[316999.285576]  [<c016fc76>] ? do_gettimeofday+0x16/0x40
[316999.285576]  [<c0150146>] ? sys_gettimeofday+0x36/0x70
[316999.285576]  [<c05c90a4>] syscall_call+0x7/0xb
[316999.285576] sensors-apple D d1b21d04     0 13205      1 0x00000000
[316999.285576]  d1b21d14 00000086 00000002 d1b21d04 f83ea917 c05d89e0 c08c=
1700 c08c1700
[316999.285576]  5a8cd7b3 0001204c c08c1700 c08c1700 5a8ca8c6 0001204c 0000=
0000 c08c1700
[316999.285576]  c08c1700 e02c2610 00000001 c08fa500 c08fa500 d1b21d34 d1b2=
1d78 c05c72df
[316999.285576] Call Trace:
[316999.285576]  [<f83ea917>] ? rpc_put_task+0x77/0x80 [sunrpc]
[316999.285576]  [<c05c72df>] schedule_timeout+0x12f/0x270
[316999.285576]  [<c01589c0>] ? process_timeout+0x0/0x10
[316999.285576]  [<c05c745a>] schedule_timeout_killable+0x1a/0x20
[316999.285576]  [<f823132d>] nfs4_delay+0x2d/0x70 [nfs]
[316999.285576]  [<f823150a>] nfs4_handle_exception+0xfa/0x180 [nfs]
[316999.285576]  [<f823347e>] nfs4_proc_access+0x4e/0x60 [nfs]
[316999.285576]  [<f8218edd>] nfs_do_access+0x7d/0xc0 [nfs]
[316999.285576]  [<f8218f98>] nfs_permission+0x78/0x1a0 [nfs]
[316999.285576]  [<c02306cf>] ? mntput_no_expire+0x1f/0xd0
[316999.285576]  [<c02212ea>] exec_permission+0x2a/0x90
[316999.285576]  [<c0223867>] link_path_walk+0x67/0x890
[316999.285576]  [<c02241b1>] path_walk+0x51/0xc0
[316999.285576]  [<c0224339>] do_path_lookup+0x59/0x90
[316999.285576]  [<c0224e81>] user_path_at+0x41/0x80
[316999.285576]  [<c0218534>] ? do_sync_read+0xa4/0xe0
[316999.285576]  [<c021c9da>] vfs_fstatat+0x3a/0x70
[316999.285576]  [<c02185d2>] ? rw_verify_area+0x62/0xd0
[316999.285576]  [<c021cb30>] vfs_stat+0x20/0x30
[316999.285576]  [<c021cb59>] sys_stat64+0x19/0x30
[316999.285576]  [<c016fb56>] ? getnstimeofday+0x56/0x120
[316999.285576]  [<c035a249>] ? copy_to_user+0x39/0x130
[316999.285576]  [<c016fc76>] ? do_gettimeofday+0x16/0x40
[316999.285576]  [<c0150146>] ? sys_gettimeofday+0x36/0x70
[316999.285576]  [<c05c90a4>] syscall_call+0x7/0xb
[316999.285576] update-notifi D eda75d04     0 13269  12614 0x00000000
[316999.285576]  eda75d14 00200086 00000002 eda75d04 f83ea917 c05d89e0 c08c=
1700 c08c1700
[316999.285576]  ca8d6759 0001204e c08c1700 c08c1700 ca8d321a 0001204e 0000=
0000 c08c1700
[316999.285576]  c08c1700 c0d8b2c0 00000001 f7090000 f7090000 eda75d34 eda7=
5d78 c05c72df
[316999.285576] Call Trace:
[316999.285576]  [<f83ea917>] ? rpc_put_task+0x77/0x80 [sunrpc]
[316999.285576]  [<c05c72df>] schedule_timeout+0x12f/0x270
[316999.285576]  [<c01589c0>] ? process_timeout+0x0/0x10
[316999.285576]  [<c05c745a>] schedule_timeout_killable+0x1a/0x20
[316999.285576]  [<f823132d>] nfs4_delay+0x2d/0x70 [nfs]
[316999.285576]  [<f823150a>] nfs4_handle_exception+0xfa/0x180 [nfs]
[316999.285576]  [<f823347e>] nfs4_proc_access+0x4e/0x60 [nfs]
[316999.285576]  [<f8218edd>] nfs_do_access+0x7d/0xc0 [nfs]
[316999.285576]  [<f8218f98>] nfs_permission+0x78/0x1a0 [nfs]
[316999.285576]  [<c022309a>] ? do_lookup+0x7a/0x1c0
[316999.285576]  [<c02212ea>] exec_permission+0x2a/0x90
[316999.285576]  [<c0223867>] link_path_walk+0x67/0x890
[316999.285576]  [<c02241b1>] path_walk+0x51/0xc0
[316999.285576]  [<c0224339>] do_path_lookup+0x59/0x90
[316999.285576]  [<c0224e81>] user_path_at+0x41/0x80
[316999.285576]  [<c0218534>] ? do_sync_read+0xa4/0xe0
[316999.285576]  [<c021c9da>] vfs_fstatat+0x3a/0x70
[316999.285576]  [<c02185d2>] ? rw_verify_area+0x62/0xd0
[316999.285576]  [<c021cb30>] vfs_stat+0x20/0x30
[316999.285576]  [<c021cb59>] sys_stat64+0x19/0x30
[316999.285576]  [<c016fb56>] ? getnstimeofday+0x56/0x120
[316999.285576]  [<c035a249>] ? copy_to_user+0x39/0x130
[316999.285576]  [<c016fc76>] ? do_gettimeofday+0x16/0x40
[316999.285576]  [<c0150146>] ? sys_gettimeofday+0x36/0x70
[316999.285576]  [<c05c90a4>] syscall_call+0x7/0xb
[316999.285576] gnome-screens D da83bd04     0 31067  12803 0x00000000
[316999.285576]  da83bd14 00000086 00000002 da83bd04 f83ea917 c05d89e0 c08c=
1700 c08c1700
[316999.285576]  a1a94a91 0001204d c08c1700 c08c1700 a1a91cd7 0001204d 0000=
0000 c08c1700
[316999.285576]  c08c1700 e02c3f70 00000001 c08fa500 c08fa500 da83bd34 da83=
bd78 c05c72df
[316999.285576] Call Trace:
[316999.285576]  [<f83ea917>] ? rpc_put_task+0x77/0x80 [sunrpc]
[316999.285576]  [<c05c72df>] schedule_timeout+0x12f/0x270
[316999.285576]  [<c01589c0>] ? process_timeout+0x0/0x10
[316999.285576]  [<c05c745a>] schedule_timeout_killable+0x1a/0x20
[316999.285576]  [<f823132d>] nfs4_delay+0x2d/0x70 [nfs]
[316999.285576]  [<f823150a>] nfs4_handle_exception+0xfa/0x180 [nfs]
[316999.285576]  [<f823347e>] nfs4_proc_access+0x4e/0x60 [nfs]
[316999.285576]  [<f8218edd>] nfs_do_access+0x7d/0xc0 [nfs]
[316999.285576]  [<f8218f98>] nfs_permission+0x78/0x1a0 [nfs]
[316999.285576]  [<c022309a>] ? do_lookup+0x7a/0x1c0
[316999.285576]  [<c02212ea>] exec_permission+0x2a/0x90
[316999.285576]  [<c0223867>] link_path_walk+0x67/0x890
[316999.285576]  [<c02241b1>] path_walk+0x51/0xc0
[316999.285576]  [<c0224339>] do_path_lookup+0x59/0x90
[316999.285576]  [<c0224e81>] user_path_at+0x41/0x80
[316999.285576]  [<c0218534>] ? do_sync_read+0xa4/0xe0
[316999.285576]  [<c01abe9c>] ? rcu_start_gp+0x12c/0x1a0
[316999.285576]  [<c021c9da>] vfs_fstatat+0x3a/0x70
[316999.285576]  [<c021cb30>] vfs_stat+0x20/0x30
[316999.285576]  [<c021cb59>] sys_stat64+0x19/0x30
[316999.285576]  [<c0219f9d>] ? fput+0x1d/0x30
[316999.285576]  [<c021691c>] ? filp_close+0x4c/0x80
[316999.285576]  [<c02169c5>] ? sys_close+0x75/0xc0
[316999.285576]  [<c05c90a4>] syscall_call+0x7/0xb

Maybe the above is an unrelated problem?

The way I resolved this was to kill autofs which took down the nfs4
mounts and then restart autofs which brought them back up, although,
TBH, I had to log back into my desktop session so the above processes
could have just died rather than have been resumed by NFS4 becoming
unblocked.

FWIW, the above stack traces look quite similar to issues I have seen
for the last year or so of running NFS4.  :-(

Cheers,
b.


--=-ehdaAu6oRVPchof99M8o
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAkzMWNgACgkQl3EQlGLyuXDf4wCgzD5QxF9qVvWLyV6lvNObGBdp
AP8AoNpzyzDrnLKw4ty+zXZYxJolETYD
=o6aV
-----END PGP SIGNATURE-----

--=-ehdaAu6oRVPchof99M8o--
