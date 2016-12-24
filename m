Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42849 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752679AbcLXTlQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 24 Dec 2016 14:41:16 -0500
From: NeilBrown <neilb@suse.com>
To: daggs <daggs@gmx.com>
Date: Sun, 25 Dec 2016 06:41:05 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: unable to mount nfs4 mount
In-Reply-To: <trinity-f47ff353-231a-48ff-b6d4-a8f34c45ea26-1482563498427@3capp-mailcom-bs14>
References: <trinity-4254572c-7361-4bba-8056-b645fac97726-1482498754742@3capp-mailcom-bs14> <87r34yngxn.fsf@notabene.neil.brown.name> <trinity-f47ff353-231a-48ff-b6d4-a8f34c45ea26-1482563498427@3capp-mailcom-bs14>
Message-ID: <87lgv5nmi6.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, Dec 24 2016, daggs wrote:

> Greetings,
>>=20
>> > Greetings,
>> >
>> > I'm trying to mount an nfs mount it seems ti fails, I'd appreciate som=
e help on the matter.
>> > the client is a gentoo setup with kernel 4.9.0, nfs-utils-1.3.4.
>> > running showmount -e 10.0.0.10 (the server) returns this:
>> > Export list for 10.0.0.10:
>> > /mnt/nfs_exports/media 10.0.0.0/24
>> > /mnt/nfs_exports       10.0.0.0/24
>> >
>> > when I try to mount I get this:
>> > mount -v -t nfs 10.0.0.10://mnt/nfs_exports/media /tmp/media -o vers=
=3D4,rw,async,auto
>> > mount.nfs: timeout set for Fri Dec 23 14:30:56 2016
>> > mount.nfs: trying text-based options 'vers=3D4,addr=3D10.0.0.10,client=
addr=3D10.0.0.1'
>> > mount.nfs: mount(2): Connection timed out
>> > mount.nfs: Connection timed
>> >
>> > the server is a odroidc2 board, the kernel is based 3.14.79 (I know it=
 is old but there is still no full mainline kernel support for this board),=
 nfs-utils-1.3.3 built with latest buildroot.
>> > cat /etc/exportfs returns this:
>> > /mnt/nfs_exports        10.0.0.0/24(rw,fsid=3D0,no_subtree_check)
>>                                          ^^^^^^^
>>=20
>> Get rid of this, or get rid of "/mnt/nfs_exports" in your mount command.
>> i.e.
>>   mount -v -t nfs 10.0.0.10:/media /tmp/media -o vers=3D4,rw,async,auto
>>=20
>
> tried the mount line, same behavior.
> client:
> mount -v -t nfs 10.0.0.10:/media /tmp/media -o vers=3D4,rw,async,auto
> mount.nfs: timeout set for Sat Dec 24 09:07:17 2016
> mount.nfs: trying text-based options 'vers=3D4,addr=3D10.0.0.10,clientadd=
r=3D10.0.0.1'
> mount.nfs: mount(2): Connection timed out
> mount.nfs: Connection timed out

Sorry - I should have known that.  I just responded to the first obvious
error I saw, without confirming that it would have the results
reported.  The error I saw wouldn't cause "Connection timed out".

This message
> [    8.588359] svc: svc_process dropit

might suggest that rpc.mountd isn't running. Is it?
If it is, is it producing any error messages in the logs?

NeilBrown


>
> server:
> [    7.585428] svc: socket ffffffc05bfaa000 TCP (listen) state change 10
> [    7.585628] svc: transport ffffffc05c05c000 served by daemon ffffffc05=
bfd0000
> [    7.585924] svc: socket ffffffc05c3bce00 TCP (listen) state change 1
> [    7.586198] svc: tcp_accept ffffffc05c05c000 sock ffffffc05ca05180
> [    7.586441] nfsd: connect from 10.0.0.1, port=3D737
> [    7.586634] svc: svc_setup_socket ffffffc05c8ef400
> [    7.586832] setting up TCP socket for reading
> [    7.587011] svc: svc_setup_socket created ffffffc05bc70000 (inet fffff=
fc05c3bce00)
> [    7.587324] svc: transport ffffffc05bc70000 put into queue
> [    7.587551] svc: transport ffffffc05c05c000 put into queue
> [    7.587777] svc: server ffffffc05bfd0000 waiting for data (to =3D 3600=
00)
> [    7.588050] svc: transport ffffffc05bc70000 dequeued, inuse=3D1
> [    7.588287] svc: server ffffffc05bfd0000, pool 0, transport ffffffc05b=
c70000, inuse=3D2
> [    7.588612] svc: tcp_recv ffffffc05bc70000 data 1 conn 0 close 0
> [    7.588859] svc: socket ffffffc05bc70000 recvfrom(ffffffc05bc702bc, 0)=
 =3D 4
> [    7.589143] svc: TCP record, 40 bytes
> [    7.589330] svc: socket ffffffc05bc70000 recvfrom(ffffffc05c272028, 40=
56) =3D 40
> [    7.589592] svc: TCP final record (40 bytes)
> [    7.589781] svc: got len=3D40
> [    7.589970] svc: svc_authenticate (0)
> [    7.590156] svc: calling dispatcher
> [    7.590344] svc: socket ffffffc05bc70000 sendto([ffffffc05c3e8000 28..=
. ], 28) =3D 28 (addr 10.0.0.1, port=3D737)
> [    7.590715] svc: socket ffffffc05c3bce00 TCP data ready (svsk ffffffc0=
5bc70000)
> [    7.591015] svc: transport ffffffc05bc70000 put into queue
> [    7.591242] svc: transport ffffffc05bc70000 busy, not enqueued
> [    7.591482] svc: server ffffffc05bfd0000 waiting for data (to =3D 3600=
00)
> [    7.591756] svc: transport ffffffc05c05c000 dequeued, inuse=3D1
> [    7.591993] svc: tcp_accept ffffffc05c05c000 sock ffffffc05ca05180
> [    7.592249] svc: server ffffffc05bfd0000 waiting for data (to =3D 3600=
00)
> [    7.592521] svc: transport ffffffc05bc70000 dequeued, inuse=3D1
> [    7.592758] svc: server ffffffc05bfd0000, pool 0, transport ffffffc05b=
c70000, inuse=3D2
> [    7.593081] svc: tcp_recv ffffffc05bc70000 data 1 conn 0 close 0
> [    7.593329] svc: socket ffffffc05bc70000 recvfrom(ffffffc05bc702bc, 0)=
 =3D 4
> [    7.593613] svc: TCP record, 172 bytes
> [    7.593801] svc: socket ffffffc05bc70000 recvfrom(ffffffc05c2720ac, 39=
24) =3D 172
> [    7.594070] svc: TCP final record (172 bytes)
> [    7.594260] svc: got len=3D172
> [    7.594448] svc: svc_authenticate (1)
> [    7.594636] RPC:       Want update, refage=3D120, age=3D0
> [    8.588359] svc: svc_process dropit
> [    8.588550] svc: xprt ffffffc05bc70000 dropped request
> [    8.588739] svc: server ffffffc05bfd0000 waiting for data (to =3D 3600=
00)
> [   10.518359] svc: svc_process dropit
> [   10.518550] svc: xprt ffffffc05c396000 dropped request
> [   10.518738] svc: transport ffffffc05c396000 busy, not enqueued
> [   10.518956] svc: server ffffffc05b812000 waiting for data (to =3D 3600=
00)
> [   15.684420] svc: socket ffffffc05c3bce00 TCP (connected) state change =
8 (svsk ffffffc05bc70000)
> [   15.684740] svc: transport ffffffc05bc70000 served by daemon ffffffc05=
b812000
> [   15.685035] svc: socket ffffffc05c3bce00 TCP data ready (svsk ffffffc0=
5bc70000)
> [   15.685337] svc: transport ffffffc05bc70000 busy, not enqueued
> [   15.685592] svc_recv: found XPT_CLOSE
> [   15.685785] svc: svc_delete_xprt(ffffffc05bc70000)
> [   15.685979] svc: svc_tcp_sock_detach(ffffffc05bc70000)
> [   15.686174] svc: svc_sock_detach(ffffffc05bc70000)
> [   15.686370] svc: server ffffffc05b812000 waiting for data (to =3D 3600=
00)
>
> my /etc/exports if copied from the gentoo setup which has a working nfsv4=
 server.
>
> Dagg.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhez1IACgkQOeye3VZi
gbkfIA/+IOke6++u3INAh4Iya1l5nii0QuPvDlEzPAe3lQ7sCQ8fmSwa/BeSDcU8
KlDXlTC5HRPFAj8zhkrv0bWduoKmBUKNLBycGU59LngLqDNEQc5nA7yYDBuXYyAV
jh2y6gxzWvf9saUNOAFtzr2c5piuh5fkNWcOGlXuvJs8cxG71NdWEAq2bsrk54cu
kGfGQhbwbTYP9P1fquUoIiRKTWY43HUSeBl9FlondJyEy1XouhPd+ptR5Qqdl9kW
5cKK+bW/bnK+C8wRisNRYaGpnrgFcV1DKP/NsAXsmzS1oVYSRVfdibQcW6ztMGKv
hZJYzAmLIl2YWpubqWOUp+YN84Si5ct2VAdDVGWfPXKmvWDvFFnGNAGGbPK1B1yC
j2dIDLm6yIw+H+AM+LDh2M1tgoFu0iCElIhNxaTd/kBdXZofSUduI9dTg7dnRfA1
UKv1VCUnuwRwfLPw9cUZTucbKqCdH1EDq7z3xNwOjFv46WZ3BsiRoiTdvQniyV1a
CJrwcIuEuj6YbTo15l5TnvWjd60j4gluv/OIV0MRfB45RPZ0RAYohJyWon4+bodp
+d/FypnFxXQYYyTs83HWh5yYNZXaXRQTZChZlZyZ+9uR8iWtUh48KlW+IQiRYnJG
dY9/yatXjxHSohahfwVnwVZq6M78c8j4dxyaP/LsuUnLRp9u5fI=
=yhWX
-----END PGP SIGNATURE-----
--=-=-=--
