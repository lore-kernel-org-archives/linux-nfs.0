From: Sylvain Rochet <gradator-XWGZPxRNpGHk1uMJSBkQmQ@public.gmane.org>
Subject: Re: 2.6.28.9: EXT3/NFS inodes corruption
Date: Thu, 6 Aug 2009 15:15:56 +0200
Message-ID: <20090806131555.GA23359@gradator.net>
References: <20090420162017.GA28079@gradator.net> <20090716172749.GC3740@atrey.karlin.mff.cuni.cz> <20090725151751.GA6419@gradator.net> <20090727154253.GB8332@duck.suse.cz> <20090728112715.GA8442@gradator.net> <20090728135226.GA21682@duck.suse.cz> <20090728164142.GA13662@gradator.net> <20090803222901.GB23162@duck.suse.cz> <20090804111505.GA6433@gradator.net> <20090804225619.GB11097@duck.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="J/dobhs11T7y2rNN"
Cc: linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
To: Jan Kara <jack@suse.cz>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from atreides.gradator.net ([212.85.155.42]:60660 "EHLO
	atreides.gradator.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755819AbZHFNP5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Aug 2009 09:15:57 -0400
In-Reply-To: <20090804225619.GB11097-pwKtmJkCtMINMLpHRKhSow@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,


On Wed, Aug 05, 2009 at 12:56:19AM +0200, Jan Kara wrote:
>=20
> Thanks for testing. So you seem to be really stressting the path where
> creation of new files / directories fails (probably due to group quota).

Yes, there are 29 groups over quota on a total of 4499. Those are mainly=20
spammed websites and therefore quite stressed due to the amount of tries=20
to add new "data".


> I have one idea what could cause your filesystem corruption, although=20
> it's a wild guess... Please try attached oneliner.

Running since yesterday.


> Also your corruption reminded me that Al Viro has been fixing problems
> where we could cache one inode twice when a filesystem was mounted over N=
FS
> and that could also lead to a filesystem corruption. So I'm adding him to
> CC just in case he has some idea. BTW Al, what do you think about the
> problem I describe in the attached patch? I'm not sure if it can cause so=
me
> real problems but in theory it could...

Should we upgrade NFS clients as well ?  (now running 2.6.28.9)


Sylvain

--J/dobhs11T7y2rNN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFKeteLDFub3qtEsS8RAkblAKCDyCR00ocoDY1Qxjp1bk6YWlPfkACgvdg9
qcCk43m4BmrsCFyT9U7VTwE=
=Dhxc
-----END PGP SIGNATURE-----

--J/dobhs11T7y2rNN--
