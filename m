From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: How to know whether a given directory in in NFS
Date: Thu, 02 Dec 2004 11:59:41 -0800
Message-ID: <1102017581.14238.247.camel@tesuji.nac.uci.edu>
References: <20041202121530.16871.qmail@web60307.mail.yahoo.com>
	 <41AF0901.30907@moving-picture.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-HitSGIfxc508ToXB29CB"
Cc: strombrg@dcs.nac.uci.edu, Raghu Ram Murthy <me_rams@yahoo.com>,
        nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CZx7C-0002ug-M8
	for nfs@lists.sourceforge.net; Thu, 02 Dec 2004 11:59:46 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CZx7B-00054J-Pg
	for nfs@lists.sourceforge.net; Thu, 02 Dec 2004 11:59:46 -0800
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: <41AF0901.30907@moving-picture.com>
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


--=-HitSGIfxc508ToXB29CB
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable


IMO, python's a lot more practical than perl (at least until perl is
majorly overhauled for perl 6 :-S).

With python, the "os" module has a statvfs function, and the statvfs
module has symbolic constants to facilitate using the os.statvfs
function.

I used this API recently to summarize disk usage in a filesystem that
doesn't have quota support.  I had to compile python with "large file"
support though, even though IBM claims in some contexts that programs
are supposed to be large file-enabled on AIX by default.  But of course,
this assumes you'll be looking at somes that are over 2 gigabytes in
size...

On Thu, 2004-12-02 at 12:22 +0000, James Pearson wrote:
> You can use the statfs system call (on Linux) - see a similar thread at=20
> http://marc.theaimsgroup.com/?t=3D108784378500006&r=3D1&w=3D2
>=20
> There is probably a statfs Perl module.
>=20
> James Pearson
>=20
> Raghu Ram Murthy wrote:
> > How with mount.
> >=20
> > for example, /home directory is in NFS and /tmp is not
> > in NFS and I don't know whether /home is in NFS or
> > not?
> >=20
> > Then how can I find?
> > -Raghuram
> > --- Vincent Roqueta <vincent.roqueta@ext.bull.net>
> > wrote:
> >=20
> >=20
> >>Le jeudi 2 D=E9cembre 2004 11:45, Raghu Ram Murthy a
> >>=E9crit :
> >>
> >>>Hi,
> >>>
> >>>I want to know (from perl), whether a given
> >>
> >>directory
> >>
> >>>is in part of NFS. Are there any Unix commands to
> >>
> >>find
> >>
> >>>it out or any indirect methods?
> >>
> >>mount ?
> >>
> >>
> >>
> >=20
> > -------------------------------------------------------
> >=20
> >>SF email is sponsored by - The IT Product Guide
> >>Read honest & candid reviews on hundreds of IT
> >>Products from real users.
> >>Discover which products truly live up to the hype.
> >>Start reading now.
> >>http://productguide.itmanagersjournal.com/
> >>_______________________________________________
> >>NFS maillist  -  NFS@lists.sourceforge.net
> >>https://lists.sourceforge.net/lists/listinfo/nfs
> >>
> >=20
> >=20
> >=20
> > =3D=3D=3D=3D=3D
> > ----------------------------------------------
> > P.Raghu Ram Murthy, M-tech (Computer Science),
> > Member, Information Technology,
> > D E Shaw India Software Private Limited,
> > 6-3-879 & 879/B
> > Begumpet, Hyderabad 500 016
> > Andhra Pradesh
> > India
> >=20
> > Mobile: (+91) 98852 17928
> > ----------------------------------------------
> >=20
> > If it doesn't work, you're not hitting it with a big enough hammer
> >=20
> > __________________________________________________
> > Do You Yahoo!?
> > Tired of spam?  Yahoo! Mail has the best spam protection around=20
> > http://mail.yahoo.com=20
> >=20
> >=20
> > -------------------------------------------------------
> > SF email is sponsored by - The IT Product Guide
> > Read honest & candid reviews on hundreds of IT Products from real users=
.
> > Discover which products truly live up to the hype. Start reading now.=20
> > http://productguide.itmanagersjournal.com/
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >=20
>=20
>=20
>=20
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.=20
> http://productguide.itmanagersjournal.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20

--=-HitSGIfxc508ToXB29CB
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBr3Qto0feVm00f/8RAuckAJ0VCx9E4Z3Y4a3H5kEs/iORdeOURgCcDPIi
n0VLeRDiyBQ7bTq7nzV13ZE=
=bFC5
-----END PGP SIGNATURE-----

--=-HitSGIfxc508ToXB29CB--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
