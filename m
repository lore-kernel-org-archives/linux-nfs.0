From: Garrick Staples <garrick@usc.edu>
Subject: Re: identify fs using a particular port
Date: Fri, 8 Oct 2004 14:56:21 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041008215621.GR7742@polop.usc.edu>
References: <20041008210212.GO7742@polop.usc.edu> <1097271075.8133.126.camel@tesuji.nac.uci.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="y0wg0gXWXfCO+7IC"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CG2jb-0007vc-VG
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 14:57:07 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CG2jb-0008DA-8p
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 14:57:07 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11/8.12.11) with ESMTP id i98LuLLX024097
	for <nfs@lists.sourceforge.net>; Fri, 8 Oct 2004 14:56:21 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11/8.12.11/Submit) id i98LuLiR024095
	for nfs@lists.sourceforge.net; Fri, 8 Oct 2004 14:56:21 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <1097271075.8133.126.camel@tesuji.nac.uci.edu>
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


--y0wg0gXWXfCO+7IC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 08, 2004 at 02:31:15PM -0700, Dan Stromberg alleged:
>=20
> If it's an rpc service, you can likely get what's using the port from
> rpcinfo -p.

NFS clients don't register themselves as an RPC server in portmapper.

=20
> If it's not an rpc service, you may be able to get it from
> /etc/services.
>=20
> Also check out netstat -p.

I already know it is a kernel nfs thread, but that doesn't tell me which
filesystem.

=20
> On Fri, 2004-10-08 at 14:02, Garrick Staples wrote:
> > Silly question that I can't find the answer to... is it possible to ide=
ntify
> > which mounted filesystem is using a particular port?
> >=20
> > $ netstat -an | grep :782
> > tcp        0      0 10.125.0.200:782        10.125.0.193:2049       EST=
ABLISHED=20
> >                                  ^^^ I need this port for another daemon
> >=20
> > I have a 14 filesystems mounted from that machine, all busy with user
> > processes.  So I'm trying to figure out which filesystem needs to be un=
mounted
> > to free port 782.
> --=20
> Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>
>=20



--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--y0wg0gXWXfCO+7IC
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFBZw0F0SBUxJbm9HMRApV8AJ0ZE5EqHQ5N3h8FBO4VnQgL/HD/uACfYtzF
WDB2YqRmFi4VbI67NH5oXXs=
=YyWB
-----END PGP SIGNATURE-----

--y0wg0gXWXfCO+7IC--


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
