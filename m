From: Sylvain Rochet <gradator-XWGZPxRNpGHk1uMJSBkQmQ@public.gmane.org>
Subject: Re: Fw: 2.6.28.9: EXT3/NFS inodes corruption
Date: Thu, 23 Apr 2009 01:48:23 +0200
Message-ID: <20090422234823.GA24477@gradator.net>
References: <20090422142424.b4105f4c.akpm@linux-foundation.org> <20090422224455.GV15541@mit.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="17pEHd4RhPHOinZp"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org
To: Theodore Tso <tytso@mit.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from atreides.gradator.net ([212.85.155.42]:53141 "EHLO
	atreides.gradator.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbZDWBGv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 21:06:51 -0400
In-Reply-To: <20090422224455.GV15541@mit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,


On Wed, Apr 22, 2009 at 06:44:55PM -0400, Theodore Tso wrote:
> On Wed, Apr 22, 2009 at 02:24:24PM -0700, Andrew Morton wrote:
> >=20
> > Is it nfsd, or is it htree?
>=20
> Well, I see evidence in the bug report of corrupted directory data
> structures, so I don't think it's an NFS problem.  I would want to
> rule out hardware flakiness, though.  This could easily be caused by a
> hardware problem.
>=20
> > The kernel log is not really nice with us, here on the NFS Server:
> >=20
> > Mar 22 06:47:14 bazooka kernel: EXT3-fs warning (device md10): dx_probe=
: Unrecognised inode hash code 52
> > Mar 22 06:47:14 bazooka kernel: EXT3-fs warning (device md10): dx_probe=
: Corrupt dir inode 40420228, running e2fsck is recommended.
>=20
> Evidence of a corrupted directory entry.  We would need to look at the
> directory to see whether the directory just ad a few bits flipped, or
> is pure garbage.  The ext3 htree code should do a better job printing
> out diagnostics, and flagging the filesystem as corrupt here.
>=20
> > Apr  2 22:19:02 bazooka kernel: EXT3-fs warning (device md10): ext3_unl=
ink: Deleting nonexistent file (40491685), 0
>=20
> More evidence of a corrupted directory.
>=20
> > =3D=3D Going deeper into the problem
> >=20
> > Something like that is quite common:
> >=20
> > root@bazooka:/data/...# ls -la
> > total xxx
> > drwxrwx--- 2 xx    xx        4096 2009-04-20 03:48 .
> > drwxr-xr-x 7 root  root      4096 2007-01-21 13:15 ..
> > -rw-r--r-- 1 root  root         0 2009-04-20 03:48 access.log
> > -rw-r--r-- 1 root  root  70784145 2009-04-20 00:11 access.log.0
> > -rw-r--r-- 1 root  root   6347007 2009-04-10 00:07 access.log.10.gz
> > -rw-r--r-- 1 root  root   6866097 2009-04-09 00:08 access.log.11.gz
> > -rw-r--r-- 1 root  root   6410119 2009-04-08 00:07 access.log.12.gz
> > -rw-r--r-- 1 root  root   6488274 2009-04-07 00:08 access.log.13.gz
> > ?--------- ?    ?     ?         ?                ? access.log.14.gz
> > ?--------- ?    ?     ?         ?                ? access.log.15.gz
> > ?--------- ?    ?     ?         ?                ? access.log.16.gz
>=20
> This is on the client side; what happens when you look at the same
> directory from the server side?

This is on the server side ;)


> > fsck.ext3 fixed the filesystem but didn't fix the problem.
>=20
> What do you mean by that?  That subsequently, you started seeing
> filesystem corruptions again?

Yes, a few days later, sorry for being unclear.


> Can you send me the output of fsck.ext3?  The sorts of filesystem=20
> corruption problems which are fixed by e2fsck are important in=20
> figuring out what is going on.

Unfortunately I can't, we fsck'ed it up quite in a hurry, but=20
/data/lost+found/ was filled up well with orphaned blocks which appeared=20
to be part of the disappeared files.

We first thought it was a problem caused by a not-so-recent power=20
outage, and that a simple fsck would fix that. But a further look up on=20
cron job mails told us we were wrong ;)


> What you if you run fsck.ext3 (aka e2fsck) twice.  Once after fixing
> fixing all of the problems, and then a second time afterwards.  Do the
> problems stay fixed?

We ran fsck two times in row, and the second check didn't find any=20
mistake. We thought, "so, it's fixed!"... erm. Actually it was one month=20
ago, corruption happens from time to time, several days to one week can=20
pass without worry.


> Suppose you try mounting the filesystem read-only; are things stable
> while it is mounted read-only.

Humm this is not easy to find out, we should wait at least one week to=20
conclude.


> > Let's check how inodes numbers are distributed:
> >=20
> > # cat /root/inodesnumbers | perl -e 'use Data::Dumper; my @pof; while(<=
>){my ( $inode ) =3D ( $_ =3D~ /^(\d+)/ ); my $hop =3D int($inode/1000000);=
 $pof[$hop]++; }; for (0 .. $#pof) { print $_." =3D ".($pof[$_]/10000)."%\n=
" }'
> > [... lot of quite unused inodes groups]
> > 53 =3D 3.0371%
> > 54 =3D 26.679%     <=3D mailboxes
> > 55 =3D 2.7026%
> > [... lot of quite unused inodes groups]
> > 58 =3D 1.3262%
> > 59 =3D 27.3211%    <=3D mailing lists archives
> > 60 =3D 5.5159%
> > [... lot of quite unused inodes groups]
> > 171 =3D 0.0631%
> > 172 =3D 0.1063%
> > 173 =3D 27.2895%   <=3D
> > 174 =3D 44.0623%   <=3D
> > 175 =3D 45.6783%   <=3D websites files
> > 176 =3D 45.8247%   <=3D
> > 177 =3D 36.9376%   <=3D
> > 178 =3D 6.3294%
> > 179 =3D 0.0442%
>=20
> Yes, that's normal.  BTW, you can get this sort of information much
> more easily simply by using the "dumpe2fs" program.

Yep, exactly.=09


> > We use to fix broken folders by moving them to a quarantine folder and=
=20
> > by restoring disappeared files from the backup.
> >=20
> > So, let's check corrupted inodes number from the quarantine folder:
> >=20
> > root@bazooka:/data/path/to/rep/of/quarantine/folders# find . -mindepth =
1 -maxdepth 1 -printf '%i\n' | sort -n
> > 174293418
> > 174506030
> > 174506056
> > 174506073
> > 174506081
> > 174506733
> > 174507694
> > 174507708
> > 174507888
> > 174507985
> > 174508077
> > 174508083
> > 176473056
> > 176473062
> > 176473064
> >=20
> > Humm... those are quite near to each other 17450... 17647... and are of=
=20
> > course in the most used inodes "groups"...
>=20
> When you say "corrupted inodes", how are they corrupted?  The errors
> you showed on the server side looked like directory corruptions.  Were
> these inodes directories or data files?

Well, this is the inode numbers of directories with entries pointing on=20
inexisting inodes, of course we cannot delete these directories anymore=20
through a regular recursive deletion (well, without debugfs ;).=20
Considering the amount of inodes, this is quite a very low corruption=20
rate.


> This really smells like a hardware problem to me; my recommendation
> would be to run memory tests and also hard drive tests.  I'm going to
> guess it's more likely the problem is with your hard drives as opposed
> to memory --- that would be consistent with your observation that
> trying to keep the inodes in memory seems to help.

Yes, this is what we thought too, especially because we use ext3/nfs for=20
a very long time without problem like that. I moved all the data to the=20
backup array so we can now do read-write tests on the primary one=20
without impacting much the production.


So, let's check the raid6 array, well, this is going to take a few days.

# badblocks -w -s /dev/md10


If everything goes well I will check disk by disk.


By the way, if such corruptions doesn't happen on the backup storage=20
array we can conclude to a hardware problem around the primary one, but,=20
we are not going to be able to conclude before a few weeks.


Thanks Theodore, your help is appreciated ;)


Sylvain

--17pEHd4RhPHOinZp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFJ76zHDFub3qtEsS8RAkq1AKCTZ5vO4C142m8X1eB65qIC9AkhoQCgtiDh
ifvjC9LrhiYQPIaAjLlfCkc=
=4wgV
-----END PGP SIGNATURE-----

--17pEHd4RhPHOinZp--
