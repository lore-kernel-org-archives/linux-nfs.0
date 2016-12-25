Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50373 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752101AbcLYBUx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 24 Dec 2016 20:20:53 -0500
From: NeilBrown <neilb@suse.com>
To: daggs <daggs@gmx.com>
Date: Sun, 25 Dec 2016 12:20:44 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: unable to mount nfs4 mount
In-Reply-To: <trinity-8111cff0-0509-405f-8faa-190a3c9291c6-1482609137078@3capp-mailcom-bs11>
References: <trinity-4254572c-7361-4bba-8056-b645fac97726-1482498754742@3capp-mailcom-bs14> <87r34yngxn.fsf@notabene.neil.brown.name> <trinity-f47ff353-231a-48ff-b6d4-a8f34c45ea26-1482563498427@3capp-mailcom-bs14> <87lgv5nmi6.fsf@notabene.neil.brown.name> <trinity-8111cff0-0509-405f-8faa-190a3c9291c6-1482609137078@3capp-mailcom-bs11>
Message-ID: <87inq8olcj.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, Dec 25 2016, daggs wrote:

> Greeting Neil,
>
>> > Greetings,
>> >>=20
>> >> > Greetings,
>> >> >
>> >> > I'm trying to mount an nfs mount it seems ti fails, I'd appreciate =
some help on the matter.
>> >> > the client is a gentoo setup with kernel 4.9.0, nfs-utils-1.3.4.
>> >> > running showmount -e 10.0.0.10 (the server) returns this:
>> >> > Export list for 10.0.0.10:
>> >> > /mnt/nfs_exports/media 10.0.0.0/24
>> >> > /mnt/nfs_exports       10.0.0.0/24
>> >> >
>> >> > when I try to mount I get this:
>> >> > mount -v -t nfs 10.0.0.10://mnt/nfs_exports/media /tmp/media -o ver=
s=3D4,rw,async,auto
>> >> > mount.nfs: timeout set for Fri Dec 23 14:30:56 2016
>> >> > mount.nfs: trying text-based options 'vers=3D4,addr=3D10.0.0.10,cli=
entaddr=3D10.0.0.1'
>> >> > mount.nfs: mount(2): Connection timed out
>> >> > mount.nfs: Connection timed
>> >> >
>> >> > the server is a odroidc2 board, the kernel is based 3.14.79 (I know=
 it is old but there is still no full mainline kernel support for this boar=
d), nfs-utils-1.3.3 built with latest buildroot.
>> >> > cat /etc/exportfs returns this:
>> >> > /mnt/nfs_exports        10.0.0.0/24(rw,fsid=3D0,no_subtree_check)
>> >>                                          ^^^^^^^
>> >>=20
>> >> Get rid of this, or get rid of "/mnt/nfs_exports" in your mount comma=
nd.
>> >> i.e.
>> >>   mount -v -t nfs 10.0.0.10:/media /tmp/media -o vers=3D4,rw,async,au=
to
>> >>=20
>> >
>> > tried the mount line, same behavior.
>> > client:
>> > mount -v -t nfs 10.0.0.10:/media /tmp/media -o vers=3D4,rw,async,auto
>> > mount.nfs: timeout set for Sat Dec 24 09:07:17 2016
>> > mount.nfs: trying text-based options 'vers=3D4,addr=3D10.0.0.10,client=
addr=3D10.0.0.1'
>> > mount.nfs: mount(2): Connection timed out
>> > mount.nfs: Connection timed out
>>=20
>> Sorry - I should have known that.  I just responded to the first obvious
>> error I saw, without confirming that it would have the results
>> reported.  The error I saw wouldn't cause "Connection timed out".
>>=20
>> This message
>> > [    8.588359] svc: svc_process dropit
>>=20
>> might suggest that rpc.mountd isn't running. Is it?
>> If it is, is it producing any error messages in the logs?
>>=20
>
> from the original post:
> ps aux | egrep "nfs|rpc" on the server returns this:
> 37 root [rpciod]
> 41 root [nfsiod]
> 132 root /usr/bin/rpcbind
> 194 root [nfsd4]
> 195 root [nfsd4_callbacks]
> 199 root [nfsd]
> 200 root [nfsd]
> 233 root rpc.statd
> 237 root /usr/sbin/rpc.idmapd
> 241 root rpc.mountd -V 3 -V 4

Sorry, I missed that.
Still, it looks like mountd might be misbehaving.  That is a good place
to start anyway.
Can you strace mountd while you attempt a mount?
e.g.
  strace -o /tmp/trace -s 1000 -p 241

and send the /tmp/trace.
Also, after the attempt fails, run
 rpcdebug -m rpc -s cache
 grep . /proc/net/rpc/*/c*
 cat /proc/fs/nfsd/exports

and report the output.

NeilBrown

> all the prints from the logs that I've found (/var/log/messages) exist in=
 the previous mail I've sent.
> is there another log I'm missing? if so, where can I find it?
>
> Thanks.
>
> Dagg.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhfHuwACgkQOeye3VZi
gblk4Q/9HGwybRpKO05CG2lPqGkGSN2wPZu/iFlVBGxrUtarDWTJFJmf9RsKYI/5
TtVRsHbs1EuVwj2uXhqBdS6l7v+HK2w7kwhpPqW4bNwPBAQXZCqJIbyeKNsiBPOM
shKk1ohcd3rfVaC96TX6KmMGwCcHjHJ5BlRmEdg5asq9GRvYeqGg5EdrR8bX2JOD
u6arad/85X97esYr9dXujB4yn7yNt12d1rZftKf5mPPqdVNPR3Mi87wZlnVmTSG2
cmtRviN3wyHG0716fF+KMAYp5neSd0IGdcQxiLr9/JBTdhJY2cpup2W9nDBWYiCv
bA4w4lfMNAJrnmLHLWV7FovlWk0UUQCdONrj9gBhwGVqaq3653Vmp9PhJSAvZ+1f
bg4hDEcIAYn+u35r3JZLcRP/0RsA3Fo0VTzlY8E+z5G6V5uiWtQwL4kA7/YmXrQs
h5L3HVkWxTxrXKCMA82nsMVGSJl1WUwDRbFfQAZoY+YrksZNYUXGJFb+JvCuIsrt
xGpEFTVlQfZKX5c4KZi531FixZqeVnzUA6WgGjExr+m+a5uDwo2PA6f7gVTu7UIJ
a8QQvPO+Nru9KyltkQkLkYJWi5EIFs+Wvmbop1Ld7jrE28n+dqEOSblMvoqcbGnF
wKzwfU87X2Yh7vNijOtz6YMixFly96RFVGkpWg0S09AroNW+WRI=
=A4ME
-----END PGP SIGNATURE-----
--=-=-=--
