From: Sylvain Rochet <gradator-XWGZPxRNpGHk1uMJSBkQmQ@public.gmane.org>
Subject: Re: Fw: 2.6.28.9: EXT3/NFS inodes corruption
Date: Fri, 24 Apr 2009 01:14:14 +0200
Message-ID: <20090423231414.GA32422@gradator.net>
References: <20090422142424.b4105f4c.akpm@linux-foundation.org> <20090422224455.GV15541@mit.edu> <20090422234823.GA24477@gradator.net> <20090423001139.GX15541@mit.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vtzGhvizbBRQ85DL"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org
To: Theodore Tso <tytso@mit.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from atreides.gradator.net ([212.85.155.42]:45142 "EHLO
	atreides.gradator.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbZDWXOR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 19:14:17 -0400
In-Reply-To: <20090423001139.GX15541@mit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,


On Wed, Apr 22, 2009 at 08:11:39PM -0400, Theodore Tso wrote:
>=20
> On the server side, that means you also an inode table block look
> corrupted.  I'm pretty sure that if you used debugfs to examine those
> blocks you would have seen that the inodes were completely garbaged.

Yep, I destroyed all evidences by using badblocks in read-write mode,=20
but in case of real need of them we just have to put the production back=20
on the primary array and wait a few days.


> Depending on the inode size, and assuming a 4k block size, there are
> typically 128 or 64 inodes in a 4k block,

4k block size
128 bytes/inode

so 32 inodes per 4k block in our case ?

Since the new default is 256 bytes/inode and values of less than 128 are=20
not allowed, how is it possible to store 64 or 128 inodes in a 4k block ?
(Maybe I miss something :p)


> so if you were to look at the inodes by inode number, you normally=20
> find that adjacent inodes are corrupted within a 4k block.  Of course,=20
> this just tells us what had gotten damaged; whether it was damanged by=20
> a kernel bug, a memory bug, a hard drive or controller failure (and=20
> there are multiple types of storage stack failures; complete garbage=20
> getting written into the right place, and the right data getting=20
> written into the wrong place).

Yes, this is not going to be easy to find out what is responsible, but=20
based on the probability of hardware that use to fail easily, let's=20
point out one of the harddrive :-)


> Well, sure, but any amount of corruption is extremely troubling....

Yep ;-)


> > By the way, if such corruptions doesn't happen on the backup storage=20
> > array we can conclude to a hardware problem around the primary one, but=
,=20
> > we are not going to be able to conclude before a few weeks.
>=20
> Good luck!!

Thanks, actually this isn't so bad, we enjoy having backup hardware
(The things we always consider as useless until we -really- need it --=20
"Who said like backups ? I heard it from the end of the room." ;-)

By the way, the badblocks check is going to take 12 days considering the=20
current rate. However I ran some data checks of the raid6 array in the=20
past, mainly when the filesystem was corrupted and every check=20
succeeded. Maybe the raid6 driver computed another parity strides by=20
reading corrupted data.


Sylvain

--vtzGhvizbBRQ85DL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFJ8PZGDFub3qtEsS8RAkaxAJwLMpETjfNlSDXI3rufcbOXpDOyKQCg1s83
Qbhe6ixaJPh7+cdL+h/6vjY=
=lqe6
-----END PGP SIGNATURE-----

--vtzGhvizbBRQ85DL--
