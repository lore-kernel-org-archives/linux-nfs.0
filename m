From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: NFS write errors
Date: Thu, 14 Oct 2004 09:06:29 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1097769989.8133.3071.camel@tesuji.nac.uci.edu>
References: <1097686177.8133.2915.camel@tesuji.nac.uci.edu>
	 <416D8C32.8000801@RedHat.com>
	 <1097699964.8133.2940.camel@tesuji.nac.uci.edu>
	 <416E7497.1090307@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-2Bpff4LW53tqsZkJZbWf"
Cc: Dan Stromberg <strombrg@dcs.nac.uci.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CI87f-00020I-Hk
	for nfs@lists.sourceforge.net; Thu, 14 Oct 2004 09:06:35 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CI87e-0006bZ-6o
	for nfs@lists.sourceforge.net; Thu, 14 Oct 2004 09:06:35 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <416E7497.1090307@RedHat.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--=-2Bpff4LW53tqsZkJZbWf
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2004-10-14 at 05:44, Steve Dickson wrote:
> Dan Stromberg wrote:
>=20
> >Both of the write errors I've documented were during a huge rsync.
> > =20
> >
> hmm... are you are using soft mounts?
>=20
> SteveD.

I didn't specify hard/soft or intr/nointr, and mount | grep doesn't
indicate anything either way.  I assume it's defaulting to hard +
nointr.

I believe the fact that the mount remains mounted after the error,
supports the idea that it isn't mounted soft.

Thanks!

--=20
Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>


--=-2Bpff4LW53tqsZkJZbWf
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBbqQFo0feVm00f/8RAjz1AJ4pcY8FrPXgMe/z8RA/AfgvOFwFxgCgiDST
uWGb+Y2N1+UXG2MiM5DGkng=
=/ink
-----END PGP SIGNATURE-----

--=-2Bpff4LW53tqsZkJZbWf--



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
