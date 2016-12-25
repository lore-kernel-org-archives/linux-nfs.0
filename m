Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47548 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754443AbcLYUeD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 25 Dec 2016 15:34:03 -0500
From: NeilBrown <neilb@suse.com>
To: daggs <daggs@gmx.com>
Date: Mon, 26 Dec 2016 07:33:53 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: unable to mount nfs4 mount
In-Reply-To: <trinity-c0b9c914-6d36-40d8-a13a-38cde8b7d23f-1482696592233@3capp-mailcom-bs03>
References: <trinity-4254572c-7361-4bba-8056-b645fac97726-1482498754742@3capp-mailcom-bs14> <87r34yngxn.fsf@notabene.neil.brown.name> <trinity-f47ff353-231a-48ff-b6d4-a8f34c45ea26-1482563498427@3capp-mailcom-bs14> <87lgv5nmi6.fsf@notabene.neil.brown.name> <trinity-8111cff0-0509-405f-8faa-190a3c9291c6-1482609137078@3capp-mailcom-bs11> <87inq8olcj.fsf@notabene.neil.brown.name> <trinity-c0b9c914-6d36-40d8-a13a-38cde8b7d23f-1482696592233@3capp-mailcom-bs03>
Message-ID: <87fulboij2.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 26 2016, daggs wrote:

>> Can you strace mountd while you attempt a mount?
>> e.g.
>>   strace -o /tmp/trace -s 1000 -p 241
>>=20
>> and send the /tmp/trace.
>> Also, after the attempt fails, run
>>  rpcdebug -m rpc -s cache
>>  grep . /proc/net/rpc/*/c*
>>  cat /proc/fs/nfsd/exports
>>=20
>> and report the output.
>>=20
> here:
>
> # cat /tmp/trace
> pselect6(1024, [3 4 5 7 8 9 10 11 12], NULL, NULL, NULL, NULL) =3D 1 (in =
[3])
> read(3, "nfsd 10.0.0.1\n", 32768)       =3D 14
> openat(AT_FDCWD, "/run/nfs/etab", O_RDONLY) =3D 14
> fstat(14, {st_mode=3DS_IFREG|0644, st_size=3D435, ...}) =3D 0
> close(14)                               =3D 0
> write(3, "nfsd 10.0.0.1 2079 10.0.0.0/24 \n", 32) =3D 32

This is weird.
Here mountd is telling nfsd that when a request comes from IP address
10.0.0.1, it should look for export entries associated with the client
name "10.0.0.0/24", which is good.
However the expiry time for that information is "2079", which is back in
January 1970.
When mountd writes that number, it computes it as
   time(0) + DEFAULT_TTL
where DEFAULT_TTL is (30 * 60)
Which suggests time(0) is "279".

What is the current time on this system?

If it really was very early on Jan 1st 1970, it should work, however...


> pselect6(1024, [3 4 5 7 8 9 10 11 12], NULL, NULL, NULL, NULL <detached .=
..>
> # rpcdebug -m rpc -s cache
> rpc        cache
> # grep . /proc/net/rpc/*/c*
> /proc/net/rpc/auth.unix.gid/content:#uid cnt: gids...
> /proc/net/rpc/auth.unix.ip/channel:nfsd 10.0.0.1
> /proc/net/rpc/auth.unix.ip/channel:nfsd 10.0.0.1
> /proc/net/rpc/auth.unix.ip/content:#class IP domain
> /proc/net/rpc/auth.unix.ip/content:# expiry=3D2079 refcnt=3D1 flags=3D1
> /proc/net/rpc/auth.unix.ip/content:# nfsd 10.0.0.1 10.0.0.0/24

...the fact that this line is commented out indicates that the entry in
the cache is already expired.  So the time must be after 2079.

Maybe the time is getting set from the network at an awkward time that
races with NFS service some how.
Can you find a way to run "exportfs -f" after the time has been set
correctly?

NeilBrown


> /proc/net/rpc/nfs4.idtoname/content:#domain type id [name]
> /proc/net/rpc/nfs4.nametoid/content:#domain type name [id]
> /proc/net/rpc/nfsd.export/content:#path domain(flags)
> /proc/net/rpc/nfsd.fh/content:#domain fsidtype fsid [path]
> # cat /proc/fs/nfsd/exports
> # Version 1.1
> # Path Client(Flags) # IPs
>
> Dagg.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhgLTIACgkQOeye3VZi
gbmDyRAAp1sQsd2PwLdRB0RKbPq45BvJf7lo1uS5kMNwKcRZnvxrLGY3OYIifVfR
jRlQmyWU6B4Vthqlvgd9/qQHJQon+iV0+qF/eCzvgzIRsmPbjajg6wrUyBPbLxbx
TXksWGHvm5Fajuritqow9Hy6SxV9DsV6Szlbt4eh27O5WczLJmhWxXknq5hGvyBL
gxteQZyjE2m73WtzjvrI3vdidGgxKR3QdFhrAzRrSzFUrUuIUl9wecUyh5lIDfI1
PlOSPdMEGjNS9lIXKVd0uxiLGAXrmBpThEDdGos8rRIDeO6+wE+iCgTN/xj8J4x+
nUCvoSoofRRbc7dRL4v4JP3Z64qKC7D7sYSWiVCd6Rgh5kKXDT/W7BbZH+Ttf9ov
rvBGW5o4ROF/tA9pJxziV7+oZnn2ToRcOJ5FjXNGGNkDK9e4etGBNNlznmt/6dNN
6uzl+RD+1RuywpXeDlmgj2AdlBc2br1C1G38Re36o4qVM3DHkZA/PDrHJ5nlO6GZ
unniKUQsaNHpMdM9v0zjm8Qn4+ijNfY4by2YcMoEEqLZRk/gESwKHU4DIUgg8sFf
m6W7ksZswsRM6/Vc634EXLZRIp42qJ32KfjYS9uEXPb5qh1oL7EMFYYgtBAch/ie
zrCpEMR53bg7mQ49SEd8j+8kdkHjJKkbTG7W16UbizcTFBv3t2o=
=idZK
-----END PGP SIGNATURE-----
--=-=-=--
