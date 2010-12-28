Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from server.klug.on.ca ([205.189.48.131]:2512 "EHLO
	server.klug.on.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753793Ab0L1OtH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Dec 2010 09:49:07 -0500
Received: from linux.interlinx.bc.ca (d67-193-161-171.home3.cgocable.net [67.193.161.171])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id 0CAD62805
	for <linux-nfs@vger.kernel.org>; Tue, 28 Dec 2010 09:30:46 -0500 (EST)
Received: from [10.75.22.1] (pc.ilinx [10.75.22.1])
	by linux.interlinx.bc.ca (Postfix) with ESMTP id 9610A93D6
	for <linux-nfs@vger.kernel.org>; Tue, 28 Dec 2010 09:30:45 -0500 (EST)
Subject: mount.nfs4 blocking trying to mount
From: "Brian J. Murrell" <brian@interlinx.bc.ca>
To: linux-nfs@vger.kernel.org
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-3Pe06vtLIb6/s4+llD7E"
Date: Tue, 28 Dec 2010 09:30:45 -0500
Message-ID: <1293546645.10579.83.camel@pc>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--=-3Pe06vtLIb6/s4+llD7E
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I have an NFS4 server (2.6.32) and client (2.6.35) and while NFS3 mounts
seem to succeed, NFS4 mounts are blocking as such:

[ 1252.172143]   task                PC stack   pid father
[ 1252.172143] mount.nfs4    D efec3c38     0 10863  10862 0x00000000
[ 1252.172143]  efec3c48 00000086 00000002 efec3c38 00000000 c05d99e0 c08c4=
700 c08c4700
[ 1252.172143]  388152ec 0000011a c08c4700 c08c4700 3880db63 0000011a 00000=
000 c08c4700
[ 1252.172143]  c08c4700 f13758d0 00000001 efec3c7c 00000000 efec3c84 efec3=
c50 f841ac0c
[ 1252.172143] Call Trace:
[ 1252.172143]  [<f841ac0c>] rpc_wait_bit_killable+0x1c/0x40 [sunrpc]
[ 1252.172143]  [<c05c823d>] __wait_on_bit+0x4d/0x70
[ 1252.172143]  [<f841abf0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
[ 1252.172143]  [<f841abf0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
[ 1252.172143]  [<c05c830b>] out_of_line_wait_on_bit+0xab/0xc0
[ 1252.172143]  [<c0165f10>] ? wake_bit_function+0x0/0x50
[ 1252.172143]  [<f841b31b>] __rpc_execute+0xdb/0x250 [sunrpc]
[ 1252.248014]  [<f841aa17>] ? rpc_init_task+0xd7/0x120 [sunrpc]
[ 1252.248014]  [<c016c004>] ? sched_clock_local+0xa4/0x180
[ 1252.248014]  [<f841b4fe>] rpc_execute+0x6e/0x80 [sunrpc]
[ 1252.248014]  [<f84149af>] rpc_run_task+0x1f/0x30 [sunrpc]
[ 1252.248014]  [<f8414abe>] rpc_call_sync+0x3e/0x60 [sunrpc]
[ 1252.248014]  [<f8deb6b2>] _nfs4_call_sync+0x22/0x30 [nfs]
[ 1252.248014]  [<f8de9795>] nfs4_proc_get_root+0xa5/0x100 [nfs]
[ 1252.248014]  [<f8dd36f8>] nfs4_get_rootfh+0x48/0x130 [nfs]
[ 1252.248014]  [<f8dd5a33>] ? nfs_alloc_fattr+0x23/0xb0 [nfs]
[ 1252.248014]  [<f8dcdf19>] ? nfs4_init_server+0xf9/0x200 [nfs]
[ 1252.248014]  [<f8dcd4b4>] nfs4_server_common_setup+0x54/0x170 [nfs]
[ 1252.248014]  [<f8dce062>] nfs4_create_server+0x42/0xc0 [nfs]
[ 1252.248014]  [<f8dd84eb>] nfs4_remote_get_sb+0x6b/0x250 [nfs]
[ 1252.248014]  [<c020fadf>] ? __alloc_percpu+0xf/0x20
[ 1252.248014]  [<c0231629>] ? alloc_vfsmnt+0xf9/0x130
[ 1252.248014]  [<c021b354>] vfs_kern_mount+0x74/0x1c0
[ 1252.248014]  [<f8dd98b9>] nfs_do_root_mount+0x69/0x90 [nfs]
[ 1252.248014]  [<f8dd99bf>] nfs4_try_mount+0x3f/0xb0 [nfs]
[ 1252.248014]  [<f8dd9ca1>] ? nfs_alloc_parsed_mount_data+0x41/0xa0 [nfs]
[ 1252.248014]  [<f8dd9d50>] nfs4_get_sb+0x50/0xd0 [nfs]
[ 1252.248014]  [<c0231629>] ? alloc_vfsmnt+0xf9/0x130
[ 1252.248014]  [<c021b354>] vfs_kern_mount+0x74/0x1c0
[ 1252.248014]  [<c022f9b3>] ? get_fs_type+0x33/0xb0
[ 1252.248014]  [<c021b4fe>] do_kern_mount+0x3e/0xe0
[ 1252.248014]  [<c0232b2c>] do_mount+0x1dc/0x220
[ 1252.248014]  [<c0232bdb>] sys_mount+0x6b/0xa0
[ 1252.248014]  [<c05c9cc4>] syscall_call+0x7/0xb

This is a result of:

$ sudo mount -t nfs4 -osec=3Dkrb5,exec,dev,suid,rw,bg,rsize=3D8192,wsize=3D=
8192 linux:/usr/local /mnt/tmp

gssds "-vvv" debug when this is done:

handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt10)
handle_gssd_upcall: 'mech=3Dkrb5 uid=3D0 enctypes=3D18,17,16,23,3,1,2 '
handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt10)
process_krb5_upcall: service is '<null>'
Full hostname for 'linux.interlinx.bc.ca' is 'linux.interlinx.bc.ca'
Full hostname for 'pc' is 'pc'
Key table entry not found while getting keytab entry for 'root/pc@ILINX'
Key table entry not found while getting keytab entry for 'nfs/pc@ILINX'
Key table entry not found while getting keytab entry for 'host/pc@ILINX'
Success getting keytab entry for nfs/*@ILINX
INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_ILINX' are good until 129=
3554429
INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_ILINX' are good until 129=
3554429
using FILE:/tmp/krb5cc_machine_ILINX as credentials cache for machine creds
using environment variable to select krb5 ccache FILE:/tmp/krb5cc_machine_I=
LINX
creating context using fsuid 0 (save_uid 0)
creating tcp client for server linux.interlinx.bc.ca
DEBUG: port already set to 2049
creating context with server nfs@linux.interlinx.bc.ca
DEBUG: serialize_krb5_ctx: lucid version!
prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
doing downcall

svcgssd's "-vvv" output:

entering poll
leaving poll
handling null request
sname =3D nfs/pc.interlinx.bc.ca@ILINX
DEBUG: serialize_krb5_ctx: lucid version!
prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length
8
doing downcall
mech: krb5, hndl len: 4, ctx len 85, timeout: 1293554429 (35793 from
now), uid: -1, gid: -1, num aux grps: 0:
sending null reply
writing message: \x \x60...9a 1293518696 0 0 \x01000000 \x607...7e9
finished handling null request
entering poll

Any idea why this mount.nfs4 is blocking?  This has been working until a
few days ago.  Not sure what's changed.

Cheers,
b.


--=-3Pe06vtLIb6/s4+llD7E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk0Z9JUACgkQl3EQlGLyuXDQGACfUuzScskz8LVrCnV2ykWvdiCI
Ik8An18gdUknPAqd6VzygVKe1DmmgwAF
=ninF
-----END PGP SIGNATURE-----

--=-3Pe06vtLIb6/s4+llD7E--
