From: linas@linas.org (Linas Vepstas)
Subject: Re: NFS on a freeswan gateway?
Date: Mon, 24 Jun 2002 19:42:15 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020625004215.GB16309@backlot.linas.org>
References: <20020624223641.GA16108@backlot.linas.org> <shsptygs21r.fsf@charged.uio.no> <3D17B3F7.1010301@actusa.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="yEPQxsgoJgBvi8ip"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linas Vepstas <linas@linas.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from www.linas.org ([207.224.61.137] helo=backlot.linas.org)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17MePT-0005DL-00
	for <nfs@lists.sourceforge.net>; Mon, 24 Jun 2002 17:42:19 -0700
To: Stuart Sheldon <stu@actusa.net>
In-Reply-To: <3D17B3F7.1010301@actusa.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


--yEPQxsgoJgBvi8ip
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 24, 2002 at 05:06:15PM -0700, Stuart Sheldon was heard to remar=
k:
> Linas,
>=20
> This looks to me to be a configuration issue. RPC always and has always=
=20
> presented it's default route interface IP when connecting.=20

As per other note, it seems that other things (e.g. telnet) 'present
the default route interface IP' when connecting.   News to me ...

> If you are=20
> attempting to mount to an NFS server on a network that is reachable from=
=20
> the inside interface, you would need to add the default interface IP to=
=20
> your /etc/exports file.=20

:-( well, of course, that interface is some dynamcially assigned address
that some ISP provided.  Hardly a thing I'd want to put in /etc/exports.

Now, I could wire up the internal DNS so that it learns about the=20
IP address that the ISP assigned.  That way, I could put the name of
the machine, instead of a dotted numeric address, in the /etc/exports file.
But this adds more complexity, and I'm somewhat concerned about the security
implications (dns spoofing & etc.). =20

I would be much happier if mount (and telnet & ping &etc). used a source
address that corresponded to the interface from which the packets came.
That way, I could set up my packet filters to roundly reject all traffic
from external interfaces (other than the secure ipsec traffic).

----
The basic idea is to allow roaming clients to get nfs access to internal
networks.  The roaming client has a built in firewall to block almost
everything, and a freeswan tunnel to get it onto the internal net.
Having the source address be the default route IP addr rather than=20
the internal addr just gums it all up.

I think this is a question for the networking gurus.

--linas


--=20
pub  1024D/01045933 2001-02-01 Linas Vepstas (Labas!) <linas@linas.org>
PGP Key fingerprint =3D 8305 2521 6000 0B5E 8984  3F54 64A9 9A82 0104 5933

--yEPQxsgoJgBvi8ip
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE9F7xnZKmaggEEWTMRAoObAJ9M+5eC14mrhhCu1DoSCH/zn0CXXACfUm7+
w5jkoIgl7Revjw64Zv3tb4w=
=9YG/
-----END PGP SIGNATURE-----

--yEPQxsgoJgBvi8ip--


-------------------------------------------------------
Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
