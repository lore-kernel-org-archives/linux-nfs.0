From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: lockd grace period
Date: Mon, 31 Jan 2005 15:07:51 -0800
Message-ID: <1107212871.4071.45.camel@seki.nac.uci.edu>
References: <395A443A7CBF0246843BFD3471A8231DC0176D@bgeexc04.asiapacific.cpqcorp.net>
	 <41FE4796.9060909@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-vnUYjUKlM/hDa1E9MkXW"
Cc: strombrg@dcs.nac.uci.edu,
	"Aswathanarayana, Chetan (STSD)" <chetan.aswathanarayana@hp.com>,
	mehta kiran <kiranmehta1981@yahoo.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CvkeK-00033W-Sr
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 15:08:04 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CvkeI-0003wb-8b
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 15:08:04 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <41FE4796.9060909@RedHat.com>
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


--=-vnUYjUKlM/hDa1E9MkXW
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2005-01-31 at 09:58 -0500, Steve Dickson wrote:
> Aswathanarayana, Chetan (STSD) wrote:
>=20
> >Say, a reclaim request arrives after grace period and get's lock. There
> >will be time frame between end of grace period and arrival of
> >Reclaim request, in which case any thing can happen(ex: a new request
> >could be granted, it may make some changes to a file and unlock by the
> >time Reclaim arrives).
> > =20
> >
> Nobody  is saying this NLM protocol or method of recovery is perfect....=20
> ;-)  This
> is one of many reasons why the locking protocol is not integrated with th=
e
> NFSv4 protocol...
>=20
> steved.

I thought finally integrating locking into the protocol was supposed to
be a "feature" of NFSv4?



--=-vnUYjUKlM/hDa1E9MkXW
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBB/rpHo0feVm00f/8RAjqgAJ9QGg/Z5Z840FzKRdGgDo+1w7PGEQCfYTlV
i/IJ2j/ISwvD3Mt/5KnZ4BY=
=BW/p
-----END PGP SIGNATURE-----

--=-vnUYjUKlM/hDa1E9MkXW--



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
