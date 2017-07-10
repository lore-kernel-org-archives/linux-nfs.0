Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38679 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754888AbdGJXTk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Jul 2017 19:19:40 -0400
From: NeilBrown <neilb@suse.com>
To: Karel Zak <kzak@redhat.com>
Date: Tue, 11 Jul 2017 09:19:30 +1000
Cc: Phil Kauffman <kauffman@cs.uchicago.edu>, linux-nfs@vger.kernel.org
Subject: Re: /etc/mtab read ~900 times by rpc.mountd
In-Reply-To: <20170710114730.i6dono3adt3xi3tf@ws.net.home>
References: <f9dcc371-cd94-6b39-dd6a-b412bdf03df4@cs.uchicago.edu> <8737a9x9ky.fsf@notabene.neil.brown.name> <595F1A3A.7070405@cs.uchicago.edu> <87efto69rs.fsf@notabene.neil.brown.name> <20170710114730.i6dono3adt3xi3tf@ws.net.home>
Message-ID: <871spn6fst.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 10 2017, Karel Zak wrote:

> On Mon, Jul 10, 2017 at 05:17:27PM +1000, NeilBrown wrote:
>> On Fri, Jul 07 2017, Phil Kauffman wrote:
>>=20
>> >> I can imagine /etc/mtab being read once for every line in /etc/export=
s,
>> >> but unless your /etc/exports is very big, I can't easily see why it
>> >> would be read 900 times.
>> >> Maybe lots of different mount points are being accessed by something =
and
>> >> each one triggers a few reads...
>> >>
>> >> Can you show your /etc/exports file?
>> >
>> > These get generated via puppet and dropped into /etc/exports.d/
>> ...
>> >
>> > Here we can see that there are 960 files in /etc/exports.d
>> > root@storage1:~# find /etc/exports.d/ -type f | wc
>> > 960 960 88701
>>=20
>> Ahhh.. 960 exports.  That could do it.
>>=20
>> $ grep -c crossmnt all_etc_exports.d_in_one_file.txt
>> 957
>>=20
>> I get 957 - much the same number.
>>=20
>> $ grep open redacted_strace.txt | uniq -c
>>       2 open("/var/lib/nfs/etab", O_RDONLY)     =3D 6
>>     942 open("/etc/mtab", O_RDONLY|O_CLOEXEC)   =3D 6
>>       1 open("/proc/net/rpc/nfsd.export/channel", O_WRONLY|O_CREAT|O_TRU=
NC, 0666) =3D 6
>>=20
>> /etc/mtab was ready 942 for a single access.  I would have expected 957,
>> but maybe the system is dynamic and something changed between the two
>> samples.
>>=20
>> This makes it fairly clear what is happening.  Now we just need to fix
>> it.
>> One option would be to cache some of the details extracted from
>> /etc/mtab, but that could get messy.
>
> Would be possible to read /proc/self/mounts only once and use poll()
> to detect changes?

Sure it is possible.  All we need is code....

>
> The issue is not only the open()+read() in the process, but also=20
> kernel has to compose the file from the mount tree. It's expensive.

That certainly contributes to the problem.  If we cache the content, we
can process it fast.  If we avoid wanting to look at the content, it
doesn't matter how fast processes it is (because we don't).

So yes, that might be part of the solution.  But not the whole solution.

Thanks,
NeilBrown


>
>     Karel
>
>
> --=20
>  Karel Zak  <kzak@redhat.com>
>  http://karelzak.blogspot.com

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAllkC4QACgkQOeye3VZi
gbntHw//Wwx1fISW7M9eZVPto1t0hgqi5E7sfAZobjodjAEsXIEr/6izfby4WvQc
dl07DMgSPqMGHpOqNba3LZ2tatKcna78D6mKETFTn3UN7BV/CkCM/p2tZMDrgbs5
Y77uzeEnEoaww148pp2IyTztqQNJCbaZGp/NxX4hUlRGg0IlIywUqQUVydG+Cxm9
EwtgWmZVvkS8OJNHKVdPgdQ/KDl2VzxHJFLhk+26oid1FjsAg39/XsjGYU2uBLJx
qcAfsbPqLVa5JSqDyPK95GgmspUBQ+RBXY75vJPXokZGJOUt/WNdUzhwJ+bISWp1
lbuL9rGm0ZZqTEb4hdD7sZxZEagNTXMHE0PT3xkCsX2odPBtMhG/PeGJNbYQANvS
+AMrQG/ZHY/uowTvuzygJTTfQQssTyjCxSCsrqxof2JgozOvWho4EjQd1hIp1Sd4
olEfNagQmCWfiocDsNa4UL+3ZZhD+Hr1otDJYFE3VyS5gX/YOSREK6NTF67qaMkv
AcqUrxtHO/ijFxtZFUoY+8FDgtLDzaFrvnHtib8Mz4U/q5tzPOxQ4vfXF7aft1Hl
lvZ8HGJ3gaO43FkNp9L4dQl7dj0ii4ntqoRlp33Hyzg8MWPXe+uA30IeaFfD4INN
FSdJJKSAsTMzdoZ9SeL3CIo5P+fvJRuopE9jJtRC1c+qOYSE46Q=
=ie/G
-----END PGP SIGNATURE-----
--=-=-=--
