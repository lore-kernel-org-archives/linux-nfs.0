Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39243 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761266AbdADDSS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 3 Jan 2017 22:18:18 -0500
From: NeilBrown <neilb@suse.com>
To: daggs <daggs@gmx.com>
Date: Wed, 04 Jan 2017 14:18:07 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: unable to mount nfs4 mount
In-Reply-To: <trinity-02157c25-8763-4394-ad29-2b05c954f503-1482778484415@3capp-mailcom-bs02>
References: <trinity-4254572c-7361-4bba-8056-b645fac97726-1482498754742@3capp-mailcom-bs14> <87r34yngxn.fsf@notabene.neil.brown.name> <trinity-f47ff353-231a-48ff-b6d4-a8f34c45ea26-1482563498427@3capp-mailcom-bs14> <87lgv5nmi6.fsf@notabene.neil.brown.name> <trinity-8111cff0-0509-405f-8faa-190a3c9291c6-1482609137078@3capp-mailcom-bs11> <87inq8olcj.fsf@notabene.neil.brown.name> <trinity-c0b9c914-6d36-40d8-a13a-38cde8b7d23f-1482696592233@3capp-mailcom-bs03> <87fulboij2.fsf@notabene.neil.brown.name> <trinity-161ef8fa-88f7-4128-85e2-cc4f1abb31a7-1482738488938@3capp-mailcom-bs14> <87d1gfndin.fsf@notabene.neil.brown.name> <trinity-02157c25-8763-4394-ad29-2b05c954f503-1482778484415@3capp-mailcom-bs02>
Message-ID: <87h95fms28.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Dec 27 2016, daggs wrote:

> Greetings Neil,
>
>> On Mon, Dec 26 2016, daggs wrote:
>>=20
>> > Greetings,
>> >
>> >> On Mon, Dec 26 2016, daggs wrote:
>> >>=20
>> >> >> Can you strace mountd while you attempt a mount?
>> >> >> e.g.
>> >> >>   strace -o /tmp/trace -s 1000 -p 241
>> >> >>=20
>> >> >> and send the /tmp/trace.
>> >> >> Also, after the attempt fails, run
>> >> >>  rpcdebug -m rpc -s cache
>> >> >>  grep . /proc/net/rpc/*/c*
>> >> >>  cat /proc/fs/nfsd/exports
>> >> >>=20
>> >> >> and report the output.
>> >> >>=20
>> >> > here:
>> >> >
>> >> > # cat /tmp/trace
>> >> > pselect6(1024, [3 4 5 7 8 9 10 11 12], NULL, NULL, NULL, NULL) =3D =
1 (in [3])
>> >> > read(3, "nfsd 10.0.0.1\n", 32768)       =3D 14
>> >> > openat(AT_FDCWD, "/run/nfs/etab", O_RDONLY) =3D 14
>> >> > fstat(14, {st_mode=3DS_IFREG|0644, st_size=3D435, ...}) =3D 0
>> >> > close(14)                               =3D 0
>> >> > write(3, "nfsd 10.0.0.1 2079 10.0.0.0/24 \n", 32) =3D 32
>> >>=20
>> >> This is weird.
>> >> Here mountd is telling nfsd that when a request comes from IP address
>> >> 10.0.0.1, it should look for export entries associated with the client
>> >> name "10.0.0.0/24", which is good.
>> >> However the expiry time for that information is "2079", which is back=
 in
>> >> January 1970.
>> >> When mountd writes that number, it computes it as
>> >>    time(0) + DEFAULT_TTL
>> >> where DEFAULT_TTL is (30 * 60)
>> >> Which suggests time(0) is "279".
>> >>=20
>> >> What is the current time on this system?
>> >>=20
>> >> If it really was very early on Jan 1st 1970, it should work, however.=
..
>> >>=20
>> >>=20
>> >> > pselect6(1024, [3 4 5 7 8 9 10 11 12], NULL, NULL, NULL, NULL <deta=
ched ...>
>> >> > # rpcdebug -m rpc -s cache
>> >> > rpc        cache
>> >> > # grep . /proc/net/rpc/*/c*
>> >> > /proc/net/rpc/auth.unix.gid/content:#uid cnt: gids...
>> >> > /proc/net/rpc/auth.unix.ip/channel:nfsd 10.0.0.1
>> >> > /proc/net/rpc/auth.unix.ip/channel:nfsd 10.0.0.1
>> >> > /proc/net/rpc/auth.unix.ip/content:#class IP domain
>> >> > /proc/net/rpc/auth.unix.ip/content:# expiry=3D2079 refcnt=3D1 flags=
=3D1
>> >> > /proc/net/rpc/auth.unix.ip/content:# nfsd 10.0.0.1 10.0.0.0/24
>> >>=20
>> >> ...the fact that this line is commented out indicates that the entry =
in
>> >> the cache is already expired.  So the time must be after 2079.
>> >>=20
>> >> Maybe the time is getting set from the network at an awkward time that
>> >> races with NFS service some how.
>> >> Can you find a way to run "exportfs -f" after the time has been set
>> >> correctly?
>> >>=20
>> >> NeilBrown
>> >>=20
>> >>=20
>> >
>> > wait, I think I've seen this somewhere, does this feature needs rtc? t=
his board doesn't have rtc component.
>> > for example, I cannot use openssh as ssh server because it needs rtc. =
I have to use dropbear.
>> > if so, this looks like it will affect nfsv3 mounts, am I right?
>>=20
>> No, you shouldn't need an RTC.
>> You need the synchronize the clock with ntp or similar, else time stamps
>> on files will look wrong.
>> Though I think we fixed issues with wall-clock-time jumping in 2.6.37...
>>=20
>> If you could try using "exportfs -f", and explain what does happen with
>> time - do you use ntp ?? - we might be able to make progress.
>
> I'll build ntp into the image and try. does this affects nfsv3 too?

Having correct time is quite important for any version of NFS.  With out
it, time stamps on files get confused.  "make" doesn't cope at all,
"tar" often complains, other tools might experience other problems.

I still cannot quite see why having an incorrect clock would cause the
particular symptoms you are experiencing, but it is worth fixing anyway.

>
> what should I do with the "exportfs -f"? jsut run it and retry?

Yes.

NeilBrown

>
> Thanks,
>
> Dagg.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhsaW8ACgkQOeye3VZi
gbktbg/9GhyTOIHjAvPb/pHtzAeh/m6++a/jUvb/npprppTc1i99XWxZ2utXXYil
Az9oKBAIDpK73QMlHw+QcQUormldOnl844z3qh3QKKeGZYrm3Ood9TE0dJ7Z/xnM
tUFY9cbqV4ozrtvdxqewxoIINSvYlFakVh2y9FBunQLfHy0y9TPgQ4FpQ9tC6Pq/
+RFWfM9It+/bWcgJY8jxDIxR9JEubxoelZkyyHyOpdKQg6cNVC+XmRrW1r0R/ihm
MEH0d7K4HpQkFF093vn1lyxcpDlQMB25Lxh5O8BFTQKRGmZUQcyXH5ZCIhlVJBUo
VxhTivW+ngaQpAZlsrmw7e5TJoZsHPVQdYyr7L4TroE/Bpne040eBLGCqaAuruGK
4JcSlSTwYkFFWwSixwWDM2F2SBk6xh+bSFiLtHm/dued246oPbmhsOAH2/TofdkS
VFB/HBcmI4hKdVKPkYcxQPry7jPFVUP7RpuZm20b0tdUsRFf8AGC+66s1ECww+0A
17dJd/U4YzmT/9w/y2p/LNxmt4zxmU3ZSSNIMnsJbMQh4CvEK9IkXCzn5koM8Ncd
U66Wh1VoCdEPpq3ETu4ftoZHHqkIkYCjpoTb3P1oelUzVOhW7Ip7Hp+6mKoVkx7W
aZ2ZHAjGe8KkroeqQxUYhq/t2mCiEgYeeNXdGWO4f7Xklt+5Abk=
=OA0L
-----END PGP SIGNATURE-----
--=-=-=--
