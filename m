Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:50983 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750727AbbEMEZZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 May 2015 00:25:25 -0400
Date: Wed, 13 May 2015 14:25:15 +1000
From: NeilBrown <neilb@suse.de>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 4/4] nfsd: Pin to vfsmnt instead of mntget
Message-ID: <20150513142515.6bd881c8@notabene.brown>
In-Reply-To: <5550A9DF.1070908@gmail.com>
References: <554A149B.5060102@gmail.com>
	<554A154B.6040103@gmail.com>
	<20150508144031.6f0d3cda@notabene.brown>
	<20150508134744.GA23753@fieldses.org>
	<5550A9DF.1070908@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/wYaxr3jgzWBoildcHHrztJS"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/wYaxr3jgzWBoildcHHrztJS
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 11 May 2015 21:08:47 +0800 Kinglong Mee <kinglongmee@gmail.com> wro=
te:

> On 5/8/2015 9:47 PM, J. Bruce Fields wrote:
> > On Fri, May 08, 2015 at 02:40:31PM +1000, NeilBrown wrote:
> >> Thanks for this patch.  It looks good!
> >>
> >> My only comment on the code is that I would really like to see a
> >> "path_get_pin()" and "path_put_unpin()" rather than open coding:
> >>
> >>> +	dget(item->ek_path.dentry);
> >>> +	pin_insert_group(&new->ek_pin, item->ek_path.mnt, NULL);
> >>
> >> and=20
> >>
> >>> +		dput(key->ek_path.dentry);
> >>> +		pin_remove(&key->ek_pin);
> >>
> >>
> >> But the question you raise is an important one:  Exactly which filesys=
tems
> >> should be allowed to be unmounted?
> >> This is a change in behaviour - is it one that people uniformly would =
want?
> >>
> >> The kernel doesn't currently know which file systems were explicitly l=
isted
> >> in /etc/exports, and which were found by following a 'crossmnt'.
> >> It could guess and allow the unmounting of anything below a 'crossmnt'=
, but I
> >> wouldn't be comfortable with that - it is error prone.
> >>
> >> mountd does know what is in /etc/exports, and could tell the kernel.
> >> For the expkey cache, we could always use path_get_pin.
> >> For the export cache (where flags are available) we could use path_get
> >> or path_get_pin depending on some new flag.
> >>
> >> I'm not really sure it is worth it.  I would rather the filesystems co=
uld
> >> always be unmounted.  But doing that could possibly break someone's wo=
rk
> >> flow.  Maybe.
> >>
> >> Or maybe I'm seeing problems where there aren't any.
> >>
> >> Anyone else have an opinion?
> >=20
> > The undisputed bug here was negative cache entries preventing unmount.
> > So most conservative might be just to purge negative entries.
>=20
> I'd like this,
> if the cache is valid, user should not be allowed to umount the filesyste=
m.
>=20
> >=20
> > Otherwise, the only guarantees I think we've really had is that we won't
> > allow unmount if you hold any actual state on the filesystem (NLM locks,
> > NFSv4 locks, opens, or delegations).
>=20
> Those resources hold the reference of vfsmnt.
>=20
> >=20
> > If a filesystem is exported but no clients hold state on it, then it's
> > currently mostly chance whether the unmount succeeds or not.  So we're
> > probably free to change the behavior in this case.  I'd be inclined to
> > allow the unmount, but haven't thought this through carefully.
>=20
> If client mount a nfsserver succeed without holds state,=20
> nfs server umounts the exported filesystem,=20
> client also think the filesystem is valid, but it is umounted.

This is no different from "exportfs -au" being run on the server, thus
unexporting the filesystem and making in unavailable to the client, even
though the client has it mounted.

I think we need to give the server admin control of their filesystems, and
assume they won't do something that they don't really want to do.



>=20
> >=20
> > It could also be useful to have the ability to force an unmount even in
> > the presence of locks.  That's not a safe default, but an
> > "allow_force_unmount" export option might be useful.

We already have a mechanism to forcibly drop any locks by writing some magic
to /proc/fs/nfsd/unlock_{ip,filesystem}.  I don't think we need any more.

NeilBrown

--Sig_/wYaxr3jgzWBoildcHHrztJS
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVVLSLDnsnt1WYoG5AQKhVhAAkeD7+D2c8COcul3ZAY3uIA0hR/EDLcLg
rbWbfqpjCcqI0BZ/Nvaat6oXYSVTmX+hS9LYEXVJX8xvd1AMvY6hoYp9RsnvTonH
oqJ6nnY1wvQs1KIYxItI3ao7+O6jFR7SFggi7p7WqEYBHAEhAVmZnxAocPP5qGnX
GbypIUIlrxrQk6KiYmy3pkwom4dOZ0Z6sPPHBGesMyAOROIBYDCE4w3lMtv0tyxf
y2XqOgpZmRpjtpIzBW3/3xxfpzG62leFBcF/1OXDlUbamUWekW8M0PygBmCaLFKw
Ck0rHkIuJ8zXsZyGoBD2iwSp/3du6GQbm+GLG1cc0tpv61Pr2+xOWVEuJ+k9FaNt
oVL14aiqHRPuzzgkJ/SpI8rL/VuHq77E+Xc+Taf0q/hFquekCRzeASJ/m+v/jMmZ
k814tmIUe9j+5HoEIoax2P8fuI8dmP6/6L+gYkCi+ce/HjZs9oSq7tpJZqn+4lYm
v/2sVb7sLJahtY9Ws91gFsehZKsG7NPMNXCpLBJXTNKBUeeimeQ6Nuh4cN36D3ds
T7txAcDGTkDD+NXrOfKsG0K9aVoHjZyzOIhNhBbcSAdNwZeWF40Ij3jDvtbYuqNu
WMtqZuj3j+M2I+jOd8qs6npC4lyqNp+6cWvdHARMIy783tt/t4vuRCXGNzE0wDX7
mFQoncD3ip8=
=0oBb
-----END PGP SIGNATURE-----

--Sig_/wYaxr3jgzWBoildcHHrztJS--
