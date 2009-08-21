From: Sylvain Rochet <gradator@gradator.net>
Subject: Re: 2.6.28.9: EXT3/NFS inodes corruption
Date: Fri, 21 Aug 2009 12:51:56 +0200
Message-ID: <20090821105156.GA9996@gradator.net>
References: <20090728112715.GA8442@gradator.net> <20090728135226.GA21682@duck.suse.cz> <20090728164142.GA13662@gradator.net> <20090803222901.GB23162@duck.suse.cz> <20090804111505.GA6433@gradator.net> <20090804225619.GB11097@duck.suse.cz> <20090806131555.GA23359@gradator.net> <20090812223453.GC10729@duck.suse.cz> <20090820171952.GA15133@gradator.net> <20090821000035.GB13221@hostway.ca>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="lrZ03NoBR/3+SXJZ"
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Sylvain Rochet <gradator@gradator.net>
To: Simon Kirby <sim@hostway.ca>
Return-path: <linux-ext4-owner@vger.kernel.org>
In-Reply-To: <20090821000035.GB13221@hostway.ca>
Sender: linux-ext4-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,


On Thu, Aug 20, 2009 at 05:00:35PM -0700, Simon Kirby wrote:
> On Thu, Aug 20, 2009 at 07:19:53PM +0200, Sylvain Rochet wrote:
>=20
> > So, everything is fine, but the problem happened only one time on this=
=20
> > server, so we cannot conclude anything after a few weeks. However,=20
> > I now have physical access back, so we will switch back to the former=
=20
> > server where the problem happened quite frequently, then we will see!
>=20
> Not to derail the thread, but you were definitely seeing the same issues
> with stock 2.6.30.4, right?

Nope, the last issue we had came from 2.6.28.9.

We upgraded to 2.6.30.3 on the advice of Jan, then we "upgraded" to=20
2.6.30.3 with the first Jan's patch to add some debug output=20
(0001-ext3-Debug-unlinking-of-inodes.patch). Finally we upgraded to=20
2.6.30.4 with the first and the second Jan's patch=20
(0001-fs-Make-sure-data-stored-into-inode-is-properly-see.patch) to add=20
a smp_mb() in the unlock_new_inode() function.


> We had all sorts of corruption happening for files served via NFS with=20
> 2.6.28 and 2.6.29, but everything was magically fixed on 2.6.30=20
> (though we needed a lot of fscking).  I never did track down what=20
> change fixed it, since it took a while to reproduce.

Same here, everything is fine since 2.6.30. We will switch back to the=20
quad-core server where the corruption happen(ed) in a few days. We are=20
now using a bi-opteron server because we suspected hardware issues on=20
the quad-core, the corruption happened only one time on the bi-opteron=20
(which is IMHO a sufficient evidence to discard hardware issue). I guess=20
the issue was(or is) kinda SMP related.

And yep, we also had long times playing with fsck ;-) Luckily that the=20
corruption only occurs on new files, and new files are mostly caches,=20
sessions, logs, and such, so fsck used its chainsaw on quite=20
not-really-important files.


> Hmm.  I just noticed what seems to be a new occurrence of "deleted inode
> referenced" on a box with 2.6.30.  We saw many when we first upgraded to
> 2.6.30 due to the corruption caused by 2.6.29, but those all occurred
> within a day or so and were fsck'd.  I would have thought the backup
> sweeps would have tripped over that inode way before now...
>=20
> Just wondering if you can confirm that the errors you saw with 2.6.30.4
> were not leftover from older kernels.

The few garbaged inodes from 2.6.28.9 (and previous) were pushed to=20
lost+found to prevent future use of them. We do a fsck when we moved to=20
2.6.30.4 that fixed everything. We never had corruption yet with the=20
2.6.30.4.


Sylvain

--lrZ03NoBR/3+SXJZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFKjnxMDFub3qtEsS8RAmogAKCJtWQHzQJP7+WgTpyDnbKvYhNRKgCgthfX
eBEoCVaq9SaHChnsd+Hvjag=
=ATL4
-----END PGP SIGNATURE-----

--lrZ03NoBR/3+SXJZ--
