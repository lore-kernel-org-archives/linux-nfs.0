Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55032 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750703AbdAWFSU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 23 Jan 2017 00:18:20 -0500
From: NeilBrown <neilb@suse.com>
To: Andrei Borzenkov <arvidjaar@gmail.com>, systemd-devel@freedesktop.org,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Date: Mon, 23 Jan 2017 16:18:09 +1100
Subject: Re: [systemd-devel] RequiresMountsFor and the noauto option.
In-Reply-To: <9c81778a-a2a6-613f-b481-41a42e74f386@gmail.com>
References: <87inp6eipr.fsf@notabene.neil.brown.name> <9c81778a-a2a6-613f-b481-41a42e74f386@gmail.com>
Message-ID: <87a8aie4mm.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Mon, Jan 23 2017, Andrei Borzenkov wrote:

> This was discussed just recently as regression in Leap 42.2 on opensuse
> mailing list ...
>
> 23.01.2017 03:13, NeilBrown =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>=20
>> hi,
>>  according to "man systemd.unit" :
>>=20
>>        RequiresMountsFor=3D
>>            Takes a space-separated list of absolute paths.
>>            Automatically adds dependencies of type Requires=3D and
>>            After=3D for all mount units required to access the
>>            specified path.
>>=20
>>            Mount points marked with noauto are not mounted
>>            automatically and will be ignored for the purposes of
>>            this option. If such a mount should be a requirement for
>>            this unit, direct dependencies on the mount units may be
>>            added (Requires=3D and After=3D or some other combination).
>>=20
>>=20
>>  I understand this to mean that if a mount point has the "noauto" option=
 in
>>  /etc/fstab, and if a systemd service has RequiresMountsFor the path to
>>  that mount point, then the service will *not* require the mount point,
>>  and it will start even if that mountpoint cannot be mounted.
>>=20
>>  I recently made a change to nfs-utils to make use of this
>>  functionality.  A generator creates RequiresMountsFor dependences for
>>  nfs-server so that it won't start until all exported filesystems
>>  (listed in /etc/exports) are mounted.  I assumed this would not trigger
>>  the mounting of filesystems marked as "noauto".  I really want After
>>  functionality, but not Requires.
>>=20
>>  However, this is not how it works.
>>=20
>>  The "noauto" option stops a "Requires" dependency being created for
>>  local-fs.target, but does not stop a "Requires" dependency being
>>  created for a service which "RequiresMountsFor".  There is no checking
>>  for "noauto" in unit_add_mount_dependencies().
>>=20
>>  If this a bug in the documentation, or a bug in the code?  I'm hoping
>
> Well ... I do not see any special handling for noauto in original commit
> that added this option (7c8fa05c4d5d01748ff2a04edb882afb3119b7d7). Nor
> do I see even theoretical possibility to handle it, because "noauto"
> just means "mount unit is not dependency of local-fs.target".

I could Theoretically be handled by having any unit with declares
"RequiresMountsFor" getting either "Requires local-fs.target" or
"Requires remote-fs.target" instead of the current "Requires foo.mount",
depending on whether the "foo.mount" is a 'net'
filesystem.... presumably that can be measured.
The "After foo.mount" dependency would remain.

Maybe a bit clumsy, but I think it could "theoretically" be made to work"

>
> What I suspect happened was
>
> - original patch depends on mount unit being present in systemd cache
> - due to aggressive garbage collection mount units without "auto" were
> displaced from cache early. So those units were not visible at the time
> dependency was checked
> - later c7c89abb9edf9320246482bf4a8e0656199281ae made systemd to always
> (try to) load all possible mount units for prefix
>
> Long story short - this is documentation bug (added
> 5d2abc04fc95f5c5f6d0eaf2f9b06c70d504019f by mistake). This option always
> was designed to *Require* other mount unit.

I agree that the name "Requires" seemed to be inconsistent with the
behaviour described, but it seems more strange that the behaviour with
respect to "noauto" would be explicity described if it was not
intentional.

.... ah-ha.  The documentation was change by commit
Commit: 5d2abc04fc95 ("man: document relationship between RequiresMountsFor=
 and noauto")

in response to https://bugzilla.redhat.com/show_bug.cgi?id=3D1088057

So it was really documenting behaviour, not intention. ????
I should systemd promised some sort of stable API thing.....


>
>>  the later, otherwise I'll need to find a different solution for
>>  nfs-utils, and that will probably require having my generator read
>>  /etc/fstab and duplicate the work of fstab-generator.c
>>=20
>>  If the documentation is wrong, and the code is correct, would it be
>>  possible to get "AfterMountsFor=3D" as that is the functionality that I
>>  really want.
>>=20
>
> That's rather interesting question. As discussed in the thread I
> mentioned, user has /foo/bar in /etc/exports. So the question now is -
> what is semantic if /foo/bar is not mounted? nfsd server starts and
> export /foo/bar *mount point*, right? But that feels just as wrong, does
> not it?

It depends.
If the directory being exported is a subdirectory of the mountpoint,
then there will be no directory to export and the client will see ESTALE
or ENOENT (depending on exact sequence of events).  This is correct.

/etc/exports has a 'mountpoint' option which causes an entry to be
ignored if it is not, in fact, a mountpoint.  This works well for NFSv3
but is a bit awkward for NFSv4 (I don't recall exactly why).
Setting "mountpoint" on exports of filesystems which are "noauto" will
avoid most of the strange behaviour that you fear.

I could change the nfs-server generator to only RequiresMountsFor export
points that do not have the "mountpoint" option.  I considered that at
the time, but didn't because the systemd documentation told me I didn't
need to. :-(

Back to the drawing-board I guess .... but I'd really like to see the
documentation for systemd.unit reverted before I commit a change to
nfs-utils.

Thanks,
NeilBrown


>
> I.e. if some unit refers to path /foo/bar and we *know* that /foo/bar is
> on filesystem /foo - should we skip mounting filesystem? Then we risk
> unit misbehavior, because it will miss some data in /foo/bar, right?

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliFkhEACgkQOeye3VZi
gbnLsg/+IMtMhNGYbh4lJG1xnGji7BtIvRLH4RLdXj1ulNx5SotE+NEpwYdcOXgA
cwSPi5ffC6ccmKbhdbFs3IZWBjoe5Lv+kzConwqhD6oCvtpWFFlSdKm3npOXnNFN
xizv8AJIp5xYaxo+i/Er5+GP97aDdHP27rBYVd5vtZHAYg1bSa7oUwarXqLo2e6Z
pBbcQ/MXCIwWv8PukVuEei21aPc58hDiG/5f38WFXVFmgJUE7bjV3PjwoIiB7lb8
BZiyn+MyC0LYbN5wgecL/TaP50kiTWxDPHvsRXh6HmdtNjbmlWpT1WMC8rXhClhA
oJnbcKs19G+VxAIp9DMDd+DVjcR04OrbdBLYYFFoMejCcHSMr9wlfQlKUhh2rWus
46L/E/GnTHdx20sujf5xWqDr4r6vLeR3SsDHcnFaJuPblPHaPco5vc2qLXkuvylR
58EYNSYq4FcezQmXytqUe6OFRt69h9w0mpf1pUEFaGs9iDm1oF9ZryDS/c6AQ3Z0
iGOoUFxU0OmSSudtuh2aJKjzj97dHQGr5Po331KhrMMp8N70A+3xMitoP83XFPbs
zTEKZkRJmbpFOFwtD2ze/rgTGT9IXBFl810vmc3KB7uqMl9GavdKQGRH6vVUiClv
G1cefg9MBOUIW2yT2s6MddJAPkrU0rABGfuqLeCJUKGfd3O691g=
=Oi1z
-----END PGP SIGNATURE-----
--=-=-=--
