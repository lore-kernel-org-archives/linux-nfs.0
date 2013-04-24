Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.17.22]:54246 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755094Ab3DXRID (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Apr 2013 13:08:03 -0400
Received: from mailout-de.gmx.net ([10.1.76.31]) by mrigmx.server.lan
 (mrigmx001) with ESMTP (Nemesis) id 0MCNfL-1UMYiH0QFN-009AT2 for
 <linux-nfs@vger.kernel.org>; Wed, 24 Apr 2013 19:08:00 +0200
Message-ID: <5178116F.1010608@gmx.de>
Date: Wed, 24 Apr 2013 19:07:59 +0200
From: =?UTF-8?B?TWFsdGUgU2NocsO2ZGVy?= <maltesch@gmx.de>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: NFS4 sec=krb5 broken in 3.9-rc8
References: <5176E715.2070201@gmx.de> <20130423215807.GL3676@fieldses.org> <51777494.8010306@gmx.de> <20130424140152.GA9794@fieldses.org>
In-Reply-To: <20130424140152.GA9794@fieldses.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2VSUONLFRQCURMQAGOFSV"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2VSUONLFRQCURMQAGOFSV
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 24.04.2013 16:01, J. Bruce Fields wrote:
> On Wed, Apr 24, 2013 at 07:58:44AM +0200, Malte Schr=C3=B6der wrote:
>> On 23.04.2013 23:58, J. Bruce Fields wrote:
>>> On Tue, Apr 23, 2013 at 09:55:01PM +0200, Malte Schr=C3=B6der wrote:
>>>> Hi,
>>>> when I update my server from kernel 3.8.5 to 3.9-rc8 I cannot mount =
its
>>>> NFS exports from clients using nfs4 and sec=3Dkrb5. Using sec=3Dsys =
works,
>>>> using 3.8.5 also works good with both modes.
>>>
>>> Could you get a network trace showing the failure
>>>
>>> Run
>>>
>>> 	tcpdump -s0 -wtmp.pcap
>>>
>>> then send us tmp.pcap.
>>>
>>> (You can also take a look at tmp.pcap yourself in wireshark--it may b=
e
>>> obvious where the failure occurs.)
>>>
>>> --b.
>>>
>>
>> The trace is attached. It contains two tries, the first using sec=3Dsy=
s,
>> the second sec=3Dkrb5. I used "mount -tnfs -overs=3D4,sec=3Dkrb5 gatew=
ay:/
>> /mnt". NFS-Utils have version 1.2.6.
>=20
> Looks like the context creation succeeds and then the first use of the
> new context (a PUTROOTFH+GETATTR) never gets a response.
>=20
> Nothing interesting in the server's logs?

No, nothing. I used rpcdebug to increase logging, this is what shows up
in dmesg:

> [78773.778081] svc: socket ffff880167423640 TCP (connected) state chang=
e 8 (svsk ffff8801619f7000)
> [78773.778093] svc: transport ffff8801619f7000 served by daemon ffff880=
212bce000
> [78773.778098] svc: socket ffff880167423640 TCP data ready (svsk ffff88=
01619f7000)
> [78773.778099] svc: transport ffff8801619f7000 busy, not enqueued
> [78773.778127] svc_recv: found XPT_CLOSE
> [78773.778132] svc: svc_delete_xprt(ffff8801619f7000)
> [78773.778134] svc: svc_tcp_sock_detach(ffff8801619f7000)
> [78773.778135] svc: svc_sock_detach(ffff8801619f7000)
> [78773.778173] svc: server ffff880212bce000 waiting for data (to =3D 90=
0000)
> [78773.778735] svc: socket ffff8802152f8000 TCP (listen) state change 1=
0
> [78773.778746] svc: transport ffff880215bfd000 served by daemon ffff880=
212bce000
> [78773.778767] svc: socket ffff8802152fe4c0 TCP (listen) state change 1=

> [78773.778780] svc: tcp_accept ffff880215bfd000 sock ffff8802118dd200
> [78773.778791] nfsd: connect from fdc7:1cc3:ec03:0001:f599:ac9c:6ffb:0f=
57, port=3D930
> [78773.778793] svc: svc_setup_socket ffff880215dc4480
> [78773.778796] setting up TCP socket for reading
> [78773.778798] svc: svc_setup_socket created ffff8800c0a94000 (inet fff=
f8802152fe4c0)
> [78773.778802] svc: transport ffff8800c0a94000 served by daemon ffff880=
2071f2000
> [78773.778815] svc: transport ffff880215bfd000 served by daemon ffff880=
21243c000
> [78773.778825] svc: server ffff880212bce000 waiting for data (to =3D 90=
0000)
> [78773.778846] svc: server ffff8802071f2000, pool 0, transport ffff8800=
c0a94000, inuse=3D2
> [78773.778850] svc: tcp_recv ffff8800c0a94000 data 1 conn 0 close 0
> [78773.778854] svc: socket ffff8800c0a94000 recvfrom(ffff8800c0a942b4, =
0) =3D 4
> [78773.778858] svc: tcp_accept ffff880215bfd000 sock ffff8802118dd200
> [78773.778859] svc: TCP record, 260 bytes
> [78773.778863] svc: socket ffff8800c0a94000 recvfrom(ffff8801b7758104, =
3836) =3D 260
> [78773.778865] svc: server ffff88021243c000 waiting for data (to =3D 90=
0000)
> [78773.778868] svc: TCP final record (260 bytes)
> [78773.778870] svc: got len=3D260
> [78773.778873] svc: svc_authenticate (6)
> [78773.778883] RPC:       svcauth_gss: argv->iov_len =3D 232
> [78773.778895] RPC:       gss_verify_mic_v2
> [78773.778915] RPC:       gss_get_mic_v2
> [78773.778925] RPC:       Want update, refage=3D120, age=3D94
> [78778.777978] svc: svc_process dropit
> [78778.777983] svc: xprt ffff8800c0a94000 dropped request
> [78778.777987] svc: server ffff8802071f2000 waiting for data (to =3D 90=
0000)
> [78784.954269] svc: socket ffff8802152f8000 TCP (listen) state change 1=
0
> [78784.954282] svc: transport ffff880215bfd000 served by daemon ffff880=
2071f2000
> [78784.954318] svc: tcp_accept ffff880215bfd000 sock ffff8802118dd200
> [78784.954327] \x014nfsd: connect from unprivileged port: fdc7:1cc3:ec0=
3:0001:f599:ac9c:6ffb:0f57, port=3D48090
> [78784.954330] nfsd: connect from fdc7:1cc3:ec03:0001:f599:ac9c:6ffb:0f=
57, port=3D48090
> [78784.954331] svc: svc_setup_socket ffff880154a63cc0
> [78784.954334] setting up TCP socket for reading
> [78784.954336] svc: svc_setup_socket created ffff8801619f1000 (inet fff=
f880167423e00)
> [78784.954341] svc: transport ffff8801619f1000 served by daemon ffff880=
21243c000
> [78784.954353] svc: transport ffff880215bfd000 served by daemon ffff880=
212bce000
> [78784.954359] svc: server ffff8802071f2000 waiting for data (to =3D 90=
0000)
> [78784.954373] svc: tcp_accept ffff880215bfd000 sock ffff8802118dd200
> [78784.954381] svc: server ffff88021243c000, pool 0, transport ffff8801=
619f1000, inuse=3D2
> [78784.954383] svc: server ffff880212bce000 waiting for data (to =3D 90=
0000)
> [78784.954390] svc: tcp_recv ffff8801619f1000 data 1 conn 0 close 0
> [78784.954394] svc: socket ffff8801619f1000 recvfrom(ffff8801619f12b0, =
4) =3D -11
> [78784.954397] RPC: TCP recv_record got -11
> [78784.954398] RPC: TCP recvfrom got EAGAIN
> [78784.954400] svc: got len=3D0
> [78784.954403] svc: server ffff88021243c000 waiting for data (to =3D 90=
0000)
> [78784.955459] svc: socket ffff880167423e00 TCP data ready (svsk ffff88=
01619f1000)
> [78784.955463] svc: transport ffff8801619f1000 served by daemon ffff880=
21243c000
> [78784.955498] svc: server ffff88021243c000, pool 0, transport ffff8801=
619f1000, inuse=3D2
> [78784.955501] svc: tcp_recv ffff8801619f1000 data 1 conn 0 close 0
> [78784.955504] svc: socket ffff8801619f1000 recvfrom(ffff8801619f12b4, =
0) =3D 4
> [78784.955506] svc: TCP record, 696 bytes
> [78784.955510] svc: socket ffff8801619f1000 recvfrom(ffff88010f8612b8, =
3400) =3D 696
> [78784.955514] svc: TCP final record (696 bytes)
> [78784.955516] svc: got len=3D696
> [78784.955519] svc: svc_authenticate (6)
> [78784.955522] RPC:       svcauth_gss: argv->iov_len =3D 668
> [78784.955530] RPC:       Want update, refage=3D120, age=3D0
> [78784.972344] RPC:       krb5_encrypt returns 0
> [78784.972348] RPC:       krb5_encrypt returns 0
> [78784.972357] RPC:       krb5_encrypt returns 0
> [78784.972358] RPC:       krb5_encrypt returns 0
> [78784.972366] RPC:       krb5_encrypt returns 0
> [78784.972367] RPC:       krb5_encrypt returns 0
> [78784.972373] RPC:       krb5_encrypt returns 0
> [78784.972375] RPC:       krb5_encrypt returns 0
> [78784.972381] RPC:       krb5_encrypt returns 0
> [78784.972383] RPC:       krb5_encrypt returns 0
> [78784.972388] RPC:       krb5_encrypt returns 0
> [78784.972390] RPC:       krb5_encrypt returns 0
> [78784.972394] RPC:       gss_import_sec_context_kerberos: returning 0
> [78784.972478] RPC:       gss_get_mic_v2
> [78784.972530] svc: socket ffff8801619f1000 sendto([ffff88010cfdf000 23=
6... ], 236) =3D 236 (addr fdc7:1cc3:ec03:0001:f599:ac9c:6ffb:0f57, port=3D=
48090)
> [78784.972534] svc: server ffff88021243c000 waiting for data (to =3D 90=
0000)
> [78784.974655] svc: socket ffff880167423e00 TCP data ready (svsk ffff88=
01619f1000)
> [78784.974659] svc: transport ffff8801619f1000 served by daemon ffff880=
21243c000
> [78784.974674] svc: socket ffff880167423e00 TCP (connected) state chang=
e 8 (svsk ffff8801619f1000)
> [78784.974676] svc: transport ffff8801619f1000 busy, not enqueued
> [78784.974677] svc: socket ffff880167423e00 TCP data ready (svsk ffff88=
01619f1000)
> [78784.974679] svc: transport ffff8801619f1000 busy, not enqueued
> [78784.974699] svc: socket ffff8802152fe4c0 TCP data ready (svsk ffff88=
00c0a94000)
> [78784.974701] svc: transport ffff8800c0a94000 served by daemon ffff880=
212bce000
> [78784.974712] svc_recv: found XPT_CLOSE
> [78784.974714] svc: svc_delete_xprt(ffff8801619f1000)
> [78784.974715] svc: svc_tcp_sock_detach(ffff8801619f1000)
> [78784.974717] svc: svc_sock_detach(ffff8801619f1000)
> [78784.974756] svc: svc_sock_free(ffff8801619f1000)
> [78784.974766] svc: server ffff880212bce000, pool 0, transport ffff8800=
c0a94000, inuse=3D3
> [78784.974768] svc: server ffff88021243c000 waiting for data (to =3D 90=
0000)
> [78784.974769] svc: tcp_recv ffff8800c0a94000 data 1 conn 0 close 0
> [78784.974771] svc: socket ffff8800c0a94000 recvfrom(ffff8800c0a942b4, =
0) =3D 4
> [78784.974771] svc: TCP record, 128 bytes
> [78784.974773] svc: socket ffff8800c0a94000 recvfrom(ffff88010f854080, =
3968) =3D 128
> [78784.974774] svc: TCP final record (128 bytes)
> [78784.974775] svc: got len=3D128
> [78784.974776] svc: svc_authenticate (6)
> [78784.974776] RPC:       svcauth_gss: argv->iov_len =3D 100
> [78784.974778] RPC:       gss_verify_mic_v2
> [78784.974784] RPC:       gss_get_mic_v2
> [78784.974807] RPC:       Want update, refage=3D120, age=3D105
> [78789.975231] svc: svc_process dropit
> [78789.975236] svc: xprt ffff8800c0a94000 dropped request
> [78789.975239] svc: server ffff880212bce000 waiting for data (to =3D 90=
0000)
> [78828.585290] NFSD: laundromat service - starting
> [78828.585296] NFSD: laundromat_main - sleeping for 90 seconds
> [78829.873886] revisit canceled
> [78829.873892] svc: svc_sock_free(ffff880133911000)
> [78829.873901] revisit canceled
> [78829.873903] svc: svc_sock_free(ffff8801619f7000)
> [78829.873908] revisit queued
> [78829.873910] svc: transport ffff8800c0a94000 served by daemon ffff880=
212bce000
> [78829.873914] revisit queued
> [78829.873916] svc: transport ffff8800c0a94000 busy, not enqueued
> [78829.873944] svc: server ffff880212bce000, pool 0, transport ffff8800=
c0a94000, inuse=3D2
> [78829.873948] svc: got len=3D128
> [78829.873950] svc: transport ffff8800c0a94000 served by daemon ffff880=
21243c000
> [78829.873957] svc: svc_authenticate (6)
> [78829.873959] RPC:       svcauth_gss: argv->iov_len =3D 100
> [78829.873965] RPC:       gss_get_mic_v2
> [78829.873984] svc: server ffff88021243c000, pool 0, transport ffff8800=
c0a94000, inuse=3D3
> [78829.873988] RPC:       Want update, refage=3D120, age=3D0
> [78829.873991] svc: got len=3D260
> [78829.873993] svc: transport ffff8800c0a94000 served by daemon ffff880=
2071f2000
> [78829.874000] svc: svc_authenticate (6)
> [78829.874002] RPC:       svcauth_gss: argv->iov_len =3D 232
> [78829.874007] RPC:       gss_get_mic_v2
> [78829.874023] RPC:       Want update, refage=3D120, age=3D0
> [78829.874027] svc: server ffff8802071f2000, pool 0, transport ffff8800=
c0a94000, inuse=3D4
> [78829.874029] svc: tcp_recv ffff8800c0a94000 data 0 conn 0 close 0
> [78829.874032] svc: socket ffff8800c0a94000 recvfrom(ffff8800c0a942b0, =
4) =3D -11
> [78829.874036] RPC: TCP recv_record got -11
> [78829.874037] RPC: TCP recvfrom got EAGAIN
> [78829.874038] svc: got len=3D0
> [78829.874041] svc: server ffff8802071f2000 waiting for data (to =3D 90=
0000)
> [78834.876234] svc: svc_process dropit
> [78834.876236] svc: svc_process dropit
> [78834.876241] svc: xprt ffff8800c0a94000 dropped request
> [78834.876244] svc: server ffff88021243c000 waiting for data (to =3D 90=
0000)
> [78834.876245] svc: xprt ffff8800c0a94000 dropped request
> [78834.876248] svc: server ffff880212bce000 waiting for data (to =3D 90=
0000)
> [78845.235651] svc: socket ffff8802152fe4c0 TCP (connected) state chang=
e 8 (svsk ffff8800c0a94000)
> [78845.235664] svc: transport ffff8800c0a94000 served by daemon ffff880=
21243c000
> [78845.235669] svc: socket ffff8802152fe4c0 TCP data ready (svsk ffff88=
00c0a94000)
> [78845.235670] svc: transport ffff8800c0a94000 busy, not enqueued
> [78845.235696] svc_recv: found XPT_CLOSE
> [78845.235700] svc: svc_delete_xprt(ffff8800c0a94000)
> [78845.235702] svc: svc_tcp_sock_detach(ffff8800c0a94000)
> [78845.235704] svc: svc_sock_detach(ffff8800c0a94000)
> [78845.235738] svc: server ffff88021243c000 waiting for data (to =3D 90=
0000)
> [78845.236250] svc: socket ffff8802152f8000 TCP (listen) state change 1=
0
> [78845.236261] svc: transport ffff880215bfd000 served by daemon ffff880=
21243c000
> [78845.236278] svc: socket ffff880167423640 TCP (listen) state change 1=

> [78845.236290] svc: tcp_accept ffff880215bfd000 sock ffff8802118dd200
> [78845.236300] nfsd: connect from fdc7:1cc3:ec03:0001:f599:ac9c:6ffb:0f=
57, port=3D930
> [78845.236301] svc: svc_setup_socket ffff880154a62880
> [78845.236306] setting up TCP socket for reading
> [78845.236313] svc: svc_setup_socket created ffff88011b04d000 (inet fff=
f880167423640)
> [78845.236320] svc: transport ffff88011b04d000 served by daemon ffff880=
212bce000
> [78845.236326] svc: transport ffff880215bfd000 served by daemon ffff880=
2071f2000
> [78845.236330] svc: server ffff88021243c000 waiting for data (to =3D 90=
0000)
> [78845.236356] svc: socket ffff880167423640 TCP data ready (svsk ffff88=
011b04d000)
> [78845.236359] svc: server ffff880212bce000, pool 0, transport ffff8801=
1b04d000, inuse=3D2
> [78845.236362] svc: tcp_accept ffff880215bfd000 sock ffff8802118dd200
> [78845.236363] svc: tcp_recv ffff88011b04d000 data 1 conn 0 close 0
> [78845.236369] svc: server ffff8802071f2000 waiting for data (to =3D 90=
0000)
> [78845.236380] svc: transport ffff88011b04d000 busy, not enqueued
> [78845.236389] svc: socket ffff88011b04d000 recvfrom(ffff88011b04d2b4, =
0) =3D 4
> [78845.236392] svc: TCP record, 128 bytes
> [78845.236395] svc: socket ffff88011b04d000 recvfrom(ffff88010f854080, =
3968) =3D 128
> [78845.236398] svc: TCP final record (128 bytes)
> [78845.236399] svc: got len=3D128
> [78845.236401] svc: transport ffff88011b04d000 served by daemon ffff880=
2071f2000
> [78845.236407] svc: svc_authenticate (6)
> [78845.236409] RPC:       svcauth_gss: argv->iov_len =3D 100
> [78845.236416] RPC:       gss_verify_mic_v2
> [78845.236434] svc: server ffff8802071f2000, pool 0, transport ffff8801=
1b04d000, inuse=3D3
> [78845.236440] svc: tcp_recv ffff88011b04d000 data 1 conn 0 close 0
> [78845.236443] RPC:       gss_get_mic_v2
> [78845.236445] svc: socket ffff88011b04d000 recvfrom(ffff88011b04d2b4, =
0) =3D 4
> [78845.236446] svc: TCP record, 260 bytes
> [78845.236448] svc: socket ffff88011b04d000 recvfrom(ffff8801b7758104, =
3836) =3D 260
> [78845.236450] svc: TCP final record (260 bytes)
> [78845.236452] svc: got len=3D260
> [78845.236454] svc: svc_authenticate (6)
> [78845.236455] RPC:       svcauth_gss: argv->iov_len =3D 232
> [78845.236459] RPC:       gss_verify_mic_v2
> [78845.236466] RPC:       Want update, refage=3D120, age=3D15
> [78845.236474] RPC:       gss_get_mic_v2
> [78845.236489] RPC:       Want update, refage=3D120, age=3D15
> [78850.235425] svc: svc_process dropit
> [78850.235430] svc: svc_process dropit
> [78850.235433] svc: xprt ffff88011b04d000 dropped request
> [78850.235436] svc: xprt ffff88011b04d000 dropped request
> [78850.235437] svc: server ffff880212bce000 waiting for data (to =3D 90=
0000)
> [78850.235441] svc: server ffff8802071f2000 waiting for data (to =3D 90=
0000)

/Malte


------enig2VSUONLFRQCURMQAGOFSV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlF4EW8ACgkQ4q3E2oMjYtUHfACg8DBySl+fCsvHSNY0bpftuJHT
Q4kAn2fbf2O1RWmGf8RMXcRe2DEJ57Eh
=/Ms1
-----END PGP SIGNATURE-----

------enig2VSUONLFRQCURMQAGOFSV--
