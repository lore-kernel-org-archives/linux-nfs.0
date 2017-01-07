Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53673 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938185AbdAGDOg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 6 Jan 2017 22:14:36 -0500
From: NeilBrown <neilb@suse.com>
To: daggs <daggs@gmx.com>
Date: Sat, 07 Jan 2017 14:14:27 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: unable to mount nfs4 mount
In-Reply-To: <trinity-72ebcb17-21db-44da-abb3-5ee70ac0ec32-1483706005238@3capp-mailcom-bs05>
References: <trinity-4254572c-7361-4bba-8056-b645fac97726-1482498754742@3capp-mailcom-bs14> <87r34yngxn.fsf@notabene.neil.brown.name> <trinity-f47ff353-231a-48ff-b6d4-a8f34c45ea26-1482563498427@3capp-mailcom-bs14> <87lgv5nmi6.fsf@notabene.neil.brown.name> <trinity-8111cff0-0509-405f-8faa-190a3c9291c6-1482609137078@3capp-mailcom-bs11> <87inq8olcj.fsf@notabene.neil.brown.name> <trinity-c0b9c914-6d36-40d8-a13a-38cde8b7d23f-1482696592233@3capp-mailcom-bs03> <87fulboij2.fsf@notabene.neil.brown.name> <trinity-161ef8fa-88f7-4128-85e2-cc4f1abb31a7-1482738488938@3capp-mailcom-bs14> <87d1gfndin.fsf@notabene.neil.brown.name> <trinity-02157c25-8763-4394-ad29-2b05c954f503-1482778484415@3capp-mailcom-bs02> <87h95fms28.fsf@notabene.neil.brown.name> <trinity-72ebcb17-21db-44da-abb3-5ee70ac0ec32-1483706005238@3capp-mailcom-bs05>
Message-ID: <871swflfxo.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Jan 06 2017, daggs wrote:

> Greetings,
>
>> Subject: Re: unable to mount nfs4 mount
>>
>> On Tue, Dec 27 2016, daggs wrote:
>>=20
>> > Greetings Neil,
>> >
>> >> On Mon, Dec 26 2016, daggs wrote:
>> >>=20
>> >> > Greetings,
>> >> >
>> >> >> On Mon, Dec 26 2016, daggs wrote:
>> >> >>=20
>> >> >> >> Can you strace mountd while you attempt a mount?
>> >> >> >> e.g.
>> >> >> >>   strace -o /tmp/trace -s 1000 -p 241
>> >> >> >>=20
>> >> >> >> and send the /tmp/trace.
>> >> >> >> Also, after the attempt fails, run
>> >> >> >>  rpcdebug -m rpc -s cache
>> >> >> >>  grep . /proc/net/rpc/*/c*
>> >> >> >>  cat /proc/fs/nfsd/exports
>> >> >> >>=20
>> >> >> >> and report the output.
>> >> >> >>=20
>> >> >> > here:
>> >> >> >
>> >> >> > # cat /tmp/trace
>> >> >> > pselect6(1024, [3 4 5 7 8 9 10 11 12], NULL, NULL, NULL, NULL) =
=3D 1 (in [3])
>> >> >> > read(3, "nfsd 10.0.0.1\n", 32768)       =3D 14
>> >> >> > openat(AT_FDCWD, "/run/nfs/etab", O_RDONLY) =3D 14
>> >> >> > fstat(14, {st_mode=3DS_IFREG|0644, st_size=3D435, ...}) =3D 0
>> >> >> > close(14)                               =3D 0
>> >> >> > write(3, "nfsd 10.0.0.1 2079 10.0.0.0/24 \n", 32) =3D 32
>> >> >>=20
>> >> >> This is weird.
>> >> >> Here mountd is telling nfsd that when a request comes from IP addr=
ess
>> >> >> 10.0.0.1, it should look for export entries associated with the cl=
ient
>> >> >> name "10.0.0.0/24", which is good.
>> >> >> However the expiry time for that information is "2079", which is b=
ack in
>> >> >> January 1970.
>> >> >> When mountd writes that number, it computes it as
>> >> >>    time(0) + DEFAULT_TTL
>> >> >> where DEFAULT_TTL is (30 * 60)
>> >> >> Which suggests time(0) is "279".
>> >> >>=20
>> >> >> What is the current time on this system?
>> >> >>=20
>> >> >> If it really was very early on Jan 1st 1970, it should work, howev=
er...
>> >> >>=20
>> >> >>=20
>> >> >> > pselect6(1024, [3 4 5 7 8 9 10 11 12], NULL, NULL, NULL, NULL <d=
etached ...>
>> >> >> > # rpcdebug -m rpc -s cache
>> >> >> > rpc        cache
>> >> >> > # grep . /proc/net/rpc/*/c*
>> >> >> > /proc/net/rpc/auth.unix.gid/content:#uid cnt: gids...
>> >> >> > /proc/net/rpc/auth.unix.ip/channel:nfsd 10.0.0.1
>> >> >> > /proc/net/rpc/auth.unix.ip/channel:nfsd 10.0.0.1
>> >> >> > /proc/net/rpc/auth.unix.ip/content:#class IP domain
>> >> >> > /proc/net/rpc/auth.unix.ip/content:# expiry=3D2079 refcnt=3D1 fl=
ags=3D1
>> >> >> > /proc/net/rpc/auth.unix.ip/content:# nfsd 10.0.0.1 10.0.0.0/24
>> >> >>=20
>> >> >> ...the fact that this line is commented out indicates that the ent=
ry in
>> >> >> the cache is already expired.  So the time must be after 2079.
>> >> >>=20
>> >> >> Maybe the time is getting set from the network at an awkward time =
that
>> >> >> races with NFS service some how.
>> >> >> Can you find a way to run "exportfs -f" after the time has been set
>> >> >> correctly?
>> >> >>=20
>> >> >> NeilBrown
>> >> >>=20
>> >> >>=20
>> >> >
>> >> > wait, I think I've seen this somewhere, does this feature needs rtc=
? this board doesn't have rtc component.
>> >> > for example, I cannot use openssh as ssh server because it needs rt=
c. I have to use dropbear.
>> >> > if so, this looks like it will affect nfsv3 mounts, am I right?
>> >>=20
>> >> No, you shouldn't need an RTC.
>> >> You need the synchronize the clock with ntp or similar, else time sta=
mps
>> >> on files will look wrong.
>> >> Though I think we fixed issues with wall-clock-time jumping in 2.6.37=
...
>> >>=20
>> >> If you could try using "exportfs -f", and explain what does happen wi=
th
>> >> time - do you use ntp ?? - we might be able to make progress.
>> >
>> > I'll build ntp into the image and try. does this affects nfsv3 too?
>>=20
>> Having correct time is quite important for any version of NFS.  With out
>> it, time stamps on files get confused.  "make" doesn't cope at all,
>> "tar" often complains, other tools might experience other problems.
>>=20
>> I still cannot quite see why having an incorrect clock would cause the
>> particular symptoms you are experiencing, but it is worth fixing anyway.
> I worked around the issue by setting the date manually. the issue still p=
resists.
>
>>=20
>> >
>> > what should I do with the "exportfs -f"? jsut run it and retry?
>>=20
>> Yes.
> exportfs -f didn't made any difference.

OK. Please:
 - make sure the time is (nearly) correct - e.g. running date manually.
 - run "exportfs -f"
 - run "strace" on mountd
 - try to mount the filesystem
 - stop the strace
 - run
      rpcdebug -m rpc -s cache
      grep . /proc/net/rpc/*/*
      cat /proc/fs/nfsd/exports

  (note that it isn't quite the same 'grep' as before).

then post the output of the 'strace', the 'grep', and the 'cat'.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhwXRMACgkQOeye3VZi
gblwORAAs9ntdN2Q3J4OyLC6T+kc+5mgvnzKYodVBNq8PfWVsN7WRBV1ln86fFWU
QprZvgdqlUVbykY12u+N3CQ5z4B3BK1yef9RFVXY4wQ+PhHN3C/aZ2Bls8uC5uh9
2O3zyuBhAl3lTdBIcTaUau72V/dixZg47W3dcfSw2zFYej1A5Km6AcYez7oq3DYU
z0KyHw8M5+cTs2BK1Mfkk77pU9z7TEiZSaFc+fXqHKnEdANw/DoaxeBRf20jWYUs
BhIGHpKAXhzFFl6rOeohUdZ/UJ2LLlO2Xd7gz0mUIfxlV3YIumDGat92eB4Oo19t
L4D7oi77XozLwD03GueuIOzlv7D07kXbecCloZqU9ObZUMyFvnk7i3pIQEXF104c
NUsGtz+rFa42A04o6WNNt98jfoQzLCWcFmoqU5XgbfxVl6HdvAPTOMyF8CRDDb3o
AmJ9+jKLB0J6ayT3HQaWDo1r4yI68pXvOGmCLrZ0PnyIecX4y9dJMQ7cAvV12ZX8
4x0XNPMNDXSB3yjVWtJi03V1L7Ys+ZFX+bjSeVkbbfMmF/gSPy1gah9035RcExOL
YywcZ01OxawhwBmbjbrKzGbtVEpBGtx8hCJG2KJYkhcqKBimAGex5EyY4g9/3h0m
lIU11OQtf+WCaB6V3sxvMh9rnLbN3bv+5Pgtl+cBXenzwrZcteA=
=/MyW
-----END PGP SIGNATURE-----
--=-=-=--
