From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: NFS readonly failover and linux?
Date: Fri, 18 Feb 2005 11:08:25 -0800
Message-ID: <1108753705.5897.114.camel@seki.nac.uci.edu>
References: <1106871309.6181.254.camel@seki.nac.uci.edu>
	 <Pine.LNX.4.61.0501291127450.1607@donald.themaw.net>
	 <1107205302.4071.17.camel@seki.nac.uci.edu>
	 <Pine.LNX.4.58.0502010945400.25875@wombat.indigo.net.au>
	 <16895.57760.531261.8465@segfault.boston.redhat.com>
	 <1108677567.5897.55.camel@seki.nac.uci.edu>
	 <Pine.LNX.4.58.0502181207490.20922@wombat.indigo.net.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-YaBtl/z3N3I//KU+75ST"
Cc: strombrg@dcs.nac.uci.edu, jmoyer@redhat.com,
	autofs mailing list <autofs@linux.kernel.org>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D2DUN-0006Pa-K0
	for nfs@lists.sourceforge.net; Fri, 18 Feb 2005 11:08:31 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D2DUN-0006ma-61
	for nfs@lists.sourceforge.net; Fri, 18 Feb 2005 11:08:31 -0800
To: Ian Kent <raven@themaw.net>
In-Reply-To: <Pine.LNX.4.58.0502181207490.20922@wombat.indigo.net.au>
Sender: nfs-admin@lists.sourceforge.net
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


--=-YaBtl/z3N3I//KU+75ST
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2005-02-18 at 12:09 +0800, Ian Kent wrote:

> > > And please include the contents of your maps!
> > >=20
> > > -Jeff
> >=20
>=20
> Short answer is no.
>=20
> > Here are the maps we use on Solaris 9.  Should they work the same way o=
n
> > RHEL 3?
> >=20
> > autoinst-strombrg> cat /etc/auto_dcslib
> > /dcs -ro
>   ^^^^
> Single level direct mount entries don't yet work.

What if we set up indirect mounts for /foo/dcs and /foo/dcslib, and then
had symlinks from /dcs and /dcslib?

> > dcslib1.nacs.uci.edu,dcslib2.nacs.uci.edu,dcslib3.nacs.uci.edu:/dcspdb/=
sun4-5
> > /dcslib -ro
> > dcslib1.nacs.uci.edu,dcslib2.nacs.uci.edu,dcslib3.nacs.uci.edu:/dcspda
> >=20
> > autoinst-strombrg> cat /etc/auto_master
> > # Master map for automounter
> > #
> > +auto.master
> > /net            -hosts          -nosuid,nobrowse
> > #/home          auto_home       -nobrowse
> > /xfn            -xfn
> > /-             auto_direct
>                  ^^^^^^^^^^^ Don't you mean auto_dcslib?

Apologies.  I got these maps from a system on which they were only
vestigial.  Here are the maps from a system that's actually doing
this :) :

data-strombrg> cat /etc/auto_dcslib
/dcs -ro
dcslib1.nacs.uci.edu,dcslib2.nacs.uci.edu,dcslib3.nacs.uci.edu:/dcspdb/sun4=
-5
/dcslib -ro
dcslib1.nacs.uci.edu,dcslib2.nacs.uci.edu,dcslib3.nacs.uci.edu:/dcspda

data-strombrg> cat /etc/auto_master
# Master map for automounter
#
+auto.master
/net            -hosts          -nosuid,nobrowse
#/home          auto_home       -nobrowse
#/xfn           -xfn
/- auto_dcslib
/- auto_dcs


> >=20
> >=20
>=20

--=-YaBtl/z3N3I//KU+75ST
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCFj0po0feVm00f/8RAh0uAJ43lv5i/8eRNy1pBeXEqwTQ62E22ACcC6s8
NLTr0QABUitoJv8JiNDCEM4=
=FoPa
-----END PGP SIGNATURE-----

--=-YaBtl/z3N3I//KU+75ST--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
