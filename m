Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34494 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750712AbdAWEKP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Jan 2017 23:10:15 -0500
Received: by mail-lf0-f66.google.com with SMTP id q89so13077925lfi.1
        for <linux-nfs@vger.kernel.org>; Sun, 22 Jan 2017 20:10:14 -0800 (PST)
Subject: Re: [systemd-devel] RequiresMountsFor and the noauto option.
To: NeilBrown <neilb@suse.com>, systemd-devel@freedesktop.org,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
References: <87inp6eipr.fsf@notabene.neil.brown.name>
From: Andrei Borzenkov <arvidjaar@gmail.com>
Message-ID: <9c81778a-a2a6-613f-b481-41a42e74f386@gmail.com>
Date: Mon, 23 Jan 2017 07:10:06 +0300
MIME-Version: 1.0
In-Reply-To: <87inp6eipr.fsf@notabene.neil.brown.name>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="qv4udrPQqSXOWJrkB4rau1rA8nKIodC9E"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--qv4udrPQqSXOWJrkB4rau1rA8nKIodC9E
Content-Type: multipart/mixed; boundary="7XIfEAw4fKDUrrBIv3idXrtHLWm9SEH2P"
From: Andrei Borzenkov <arvidjaar@gmail.com>
To: NeilBrown <neilb@suse.com>, systemd-devel@freedesktop.org,
 List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Message-ID: <9c81778a-a2a6-613f-b481-41a42e74f386@gmail.com>
Subject: Re: [systemd-devel] RequiresMountsFor and the noauto option.
References: <87inp6eipr.fsf@notabene.neil.brown.name>
In-Reply-To: <87inp6eipr.fsf@notabene.neil.brown.name>

--7XIfEAw4fKDUrrBIv3idXrtHLWm9SEH2P
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

This was discussed just recently as regression in Leap 42.2 on opensuse
mailing list ...

23.01.2017 03:13, NeilBrown =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>=20
> hi,
>  according to "man systemd.unit" :
>=20
>        RequiresMountsFor=3D
>            Takes a space-separated list of absolute paths.
>            Automatically adds dependencies of type Requires=3D and
>            After=3D for all mount units required to access the
>            specified path.
>=20
>            Mount points marked with noauto are not mounted
>            automatically and will be ignored for the purposes of
>            this option. If such a mount should be a requirement for
>            this unit, direct dependencies on the mount units may be
>            added (Requires=3D and After=3D or some other combination).
>=20
>=20
>  I understand this to mean that if a mount point has the "noauto" optio=
n in
>  /etc/fstab, and if a systemd service has RequiresMountsFor the path to=

>  that mount point, then the service will *not* require the mount point,=

>  and it will start even if that mountpoint cannot be mounted.
>=20
>  I recently made a change to nfs-utils to make use of this
>  functionality.  A generator creates RequiresMountsFor dependences for
>  nfs-server so that it won't start until all exported filesystems
>  (listed in /etc/exports) are mounted.  I assumed this would not trigge=
r
>  the mounting of filesystems marked as "noauto".  I really want After
>  functionality, but not Requires.
>=20
>  However, this is not how it works.
>=20
>  The "noauto" option stops a "Requires" dependency being created for
>  local-fs.target, but does not stop a "Requires" dependency being
>  created for a service which "RequiresMountsFor".  There is no checking=

>  for "noauto" in unit_add_mount_dependencies().
>=20
>  If this a bug in the documentation, or a bug in the code?  I'm hoping

Well ... I do not see any special handling for noauto in original commit
that added this option (7c8fa05c4d5d01748ff2a04edb882afb3119b7d7). Nor
do I see even theoretical possibility to handle it, because "noauto"
just means "mount unit is not dependency of local-fs.target".

What I suspect happened was

- original patch depends on mount unit being present in systemd cache
- due to aggressive garbage collection mount units without "auto" were
displaced from cache early. So those units were not visible at the time
dependency was checked
- later c7c89abb9edf9320246482bf4a8e0656199281ae made systemd to always
(try to) load all possible mount units for prefix

Long story short - this is documentation bug (added
5d2abc04fc95f5c5f6d0eaf2f9b06c70d504019f by mistake). This option always
was designed to *Require* other mount unit.

>  the later, otherwise I'll need to find a different solution for
>  nfs-utils, and that will probably require having my generator read
>  /etc/fstab and duplicate the work of fstab-generator.c
>=20
>  If the documentation is wrong, and the code is correct, would it be
>  possible to get "AfterMountsFor=3D" as that is the functionality that =
I
>  really want.
>=20

That's rather interesting question. As discussed in the thread I
mentioned, user has /foo/bar in /etc/exports. So the question now is -
what is semantic if /foo/bar is not mounted? nfsd server starts and
export /foo/bar *mount point*, right? But that feels just as wrong, does
not it?

I.e. if some unit refers to path /foo/bar and we *know* that /foo/bar is
on filesystem /foo - should we skip mounting filesystem? Then we risk
unit misbehavior, because it will miss some data in /foo/bar, right?


--7XIfEAw4fKDUrrBIv3idXrtHLWm9SEH2P--

--qv4udrPQqSXOWJrkB4rau1rA8nKIodC9E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEARECAAYFAliFgiMACgkQR6LMutpd94xk6ACfQeIaqLC4G6BQFwLPJu7IH1X/
vA4An0BcH4QJiZu66lxKA/Oq0OT4pibr
=t99x
-----END PGP SIGNATURE-----

--qv4udrPQqSXOWJrkB4rau1rA8nKIodC9E--
