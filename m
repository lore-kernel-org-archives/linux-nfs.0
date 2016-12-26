Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45647 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754771AbcLZLTy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 26 Dec 2016 06:19:54 -0500
From: NeilBrown <neilb@suse.com>
To: daggs <daggs@gmx.com>
Date: Mon, 26 Dec 2016 22:19:44 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: unable to mount nfs4 mount
In-Reply-To: <trinity-161ef8fa-88f7-4128-85e2-cc4f1abb31a7-1482738488938@3capp-mailcom-bs14>
References: <trinity-4254572c-7361-4bba-8056-b645fac97726-1482498754742@3capp-mailcom-bs14> <87r34yngxn.fsf@notabene.neil.brown.name> <trinity-f47ff353-231a-48ff-b6d4-a8f34c45ea26-1482563498427@3capp-mailcom-bs14> <87lgv5nmi6.fsf@notabene.neil.brown.name> <trinity-8111cff0-0509-405f-8faa-190a3c9291c6-1482609137078@3capp-mailcom-bs11> <87inq8olcj.fsf@notabene.neil.brown.name> <trinity-c0b9c914-6d36-40d8-a13a-38cde8b7d23f-1482696592233@3capp-mailcom-bs03> <87fulboij2.fsf@notabene.neil.brown.name> <trinity-161ef8fa-88f7-4128-85e2-cc4f1abb31a7-1482738488938@3capp-mailcom-bs14>
Message-ID: <87d1gfndin.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 26 2016, daggs wrote:

> Greetings,
>
>> On Mon, Dec 26 2016, daggs wrote:
>>=20
>> >> Can you strace mountd while you attempt a mount?
>> >> e.g.
>> >>   strace -o /tmp/trace -s 1000 -p 241
>> >>=20
>> >> and send the /tmp/trace.
>> >> Also, after the attempt fails, run
>> >>  rpcdebug -m rpc -s cache
>> >>  grep . /proc/net/rpc/*/c*
>> >>  cat /proc/fs/nfsd/exports
>> >>=20
>> >> and report the output.
>> >>=20
>> > here:
>> >
>> > # cat /tmp/trace
>> > pselect6(1024, [3 4 5 7 8 9 10 11 12], NULL, NULL, NULL, NULL) =3D 1 (=
in [3])
>> > read(3, "nfsd 10.0.0.1\n", 32768)       =3D 14
>> > openat(AT_FDCWD, "/run/nfs/etab", O_RDONLY) =3D 14
>> > fstat(14, {st_mode=3DS_IFREG|0644, st_size=3D435, ...}) =3D 0
>> > close(14)                               =3D 0
>> > write(3, "nfsd 10.0.0.1 2079 10.0.0.0/24 \n", 32) =3D 32
>>=20
>> This is weird.
>> Here mountd is telling nfsd that when a request comes from IP address
>> 10.0.0.1, it should look for export entries associated with the client
>> name "10.0.0.0/24", which is good.
>> However the expiry time for that information is "2079", which is back in
>> January 1970.
>> When mountd writes that number, it computes it as
>>    time(0) + DEFAULT_TTL
>> where DEFAULT_TTL is (30 * 60)
>> Which suggests time(0) is "279".
>>=20
>> What is the current time on this system?
>>=20
>> If it really was very early on Jan 1st 1970, it should work, however...
>>=20
>>=20
>> > pselect6(1024, [3 4 5 7 8 9 10 11 12], NULL, NULL, NULL, NULL <detache=
d ...>
>> > # rpcdebug -m rpc -s cache
>> > rpc        cache
>> > # grep . /proc/net/rpc/*/c*
>> > /proc/net/rpc/auth.unix.gid/content:#uid cnt: gids...
>> > /proc/net/rpc/auth.unix.ip/channel:nfsd 10.0.0.1
>> > /proc/net/rpc/auth.unix.ip/channel:nfsd 10.0.0.1
>> > /proc/net/rpc/auth.unix.ip/content:#class IP domain
>> > /proc/net/rpc/auth.unix.ip/content:# expiry=3D2079 refcnt=3D1 flags=3D1
>> > /proc/net/rpc/auth.unix.ip/content:# nfsd 10.0.0.1 10.0.0.0/24
>>=20
>> ...the fact that this line is commented out indicates that the entry in
>> the cache is already expired.  So the time must be after 2079.
>>=20
>> Maybe the time is getting set from the network at an awkward time that
>> races with NFS service some how.
>> Can you find a way to run "exportfs -f" after the time has been set
>> correctly?
>>=20
>> NeilBrown
>>=20
>>=20
>
> wait, I think I've seen this somewhere, does this feature needs rtc? this=
 board doesn't have rtc component.
> for example, I cannot use openssh as ssh server because it needs rtc. I h=
ave to use dropbear.
> if so, this looks like it will affect nfsv3 mounts, am I right?

No, you shouldn't need an RTC.
You need the synchronize the clock with ntp or similar, else time stamps
on files will look wrong.
Though I think we fixed issues with wall-clock-time jumping in 2.6.37...

If you could try using "exportfs -f", and explain what does happen with
time - do you use ntp ?? - we might be able to make progress.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhg/NAACgkQOeye3VZi
gbmL+g/+LByv1eAyCOOOroTPrTdgPejDHdyeOcwgM/R1xs0P0EAdnReKZPMkhfR4
TbV4n+B6kV0c9Cuiomzp50r2omnFhz9nsuSRGy9hmA/TLNcnNQGbdj8JFcbMHnwQ
wtl6cNaa9NSKEbQKpkYnD/SQDRduzoXUKr13r214e5MS7inzWqh1RepcX+4wAYWX
CSt7DiNvx06XVkv/3DYVTbHhE/QXFjsQek38O4vp5PkGKVd1dKcNWD+xbpqFUMAV
N9BJ5csrfVEyt6xEkl2n5kNpDgTxq5FxYNS2p48ngsA1gyR2+0TPmYbiJvtUYp4U
Puvt6JMRUaSp0lQRBIWK7sPy641jelTS43s8mpK4Eqfgl1JUihsjLFRgDQ9cGJK3
S0k6ClgCLj6T2qLQYQASoXVs1Tlp9V6t/hZg47zU4mqqDftEX0VeON9afTaNPyc/
vtQNkVr+k+JRORNFGGWqHg3rpk89D/WxsJkFwH+Mz5YxQd/olV1WpGTtT9tYaWkk
6rqFj7aJc836NY1z10gjtsxQRfpK96NQcP0UZrp3D2A8LunIIgeSAlH+5lquNCz1
JcHBW5CSpnR6oPTFIRLW7zVcswra7oEdRBAxfH4XHRMu4Z8KPuULaPW8gisgulTl
4T+rVj2pgu9lsTjsofDHPwZDzKETCrAano64o/GVaKy/gR0xcJg=
=40pl
-----END PGP SIGNATURE-----
--=-=-=--
