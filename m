From: linas@linas.org (Linas Vepstas)
Subject: NFS on a freeswan gateway?
Date: Mon, 24 Jun 2002 17:36:41 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020624223641.GA16108@backlot.linas.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NzB8fVQJ5HfG6fxh"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from www.linas.org ([207.224.61.137] helo=backlot.linas.org)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17McRw-0005nK-00
	for <nfs@lists.sourceforge.net>; Mon, 24 Jun 2002 15:36:44 -0700
To: nfs@lists.sourceforge.net
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


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

I am resending a message sent to the freeswan mailing list. =20
As explained below,  the default IP source address used in
nfs mount requests is sometimes 'not appropriate' for certain
packet-filtering/freeswan setups. =20

I'd like to patch that part of the nfs/rpc client so that it uses=20
an IP source address that is routing-wise 'closer' to the nfs
server.  But I have damned little experience with the nfs kernel
code (or nfs internals), and thus would like an opinion, or commnts,
or, best yet, a pointer to a pre-existing patch.

--linas


----- Forwarded message from linas -----

To: carlos@solaria-mediterranea.com, users@lists.freeswan.org
Subject: NFS on a freeswan gateway?


Hi,


I'd like to run an nfs client on a freeswan gateway.  As the mailing=20
list archives attest, others on the mailing list have found that this
doesn't always work.  I think I know why, and am about to trying=20
patching to fix the problem, but ... before I get too deep,  I was
wondering if anyone already knows of a patch that fixes this?

Problem:

Can't mount nfs volumes on a freeswan gateway.  Message on the gateway:
   mount: xxx failed, reason given by server: Permission denied

Message at the server:
   Jun 24 14:56:00 rpc.mountd: refused mount request from nn.nn.nn.nn for /=
xxx (/): no export entry


Analysis:
The server refuses the client because the IP address nn.nn.nn.nn is 'wrong'.
The nfs server will only export to 'internal' addresses (e.g. 10.x.y.z)
whereas the mount client used an external nn.nn.nn.nn address.

I tried switching eth0 <--> eth1, etc. but is seems that the mount client
keeps trying to use a source address that corresponds to the default gateway
(which is *not* ipsec0).

Solution:
Search the web.  No luck. Try to patch the linux kernel.  I am going to=20
crawl through the linux kernel rpc code to see if I can make it use a=20
source address that is routing-wise 'closer' to the target address. =20
But I was wondiering if anyone already had some work-around for this ...

--linas

p.s. No, I do *not* want to make ipsec0 the default gateway for all
my traffic, so that 'workaround' is not an option.=20




--=20
pub  1024D/01045933 2001-02-01 Linas Vepstas (Labas!) <linas@linas.org>
PGP Key fingerprint =3D 8305 2521 6000 0B5E 8984  3F54 64A9 9A82 0104 5933



----- End forwarded message -----

--=20
pub  1024D/01045933 2001-02-01 Linas Vepstas (Labas!) <linas@linas.org>
PGP Key fingerprint =3D 8305 2521 6000 0B5E 8984  3F54 64A9 9A82 0104 5933

--NzB8fVQJ5HfG6fxh
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE9F575ZKmaggEEWTMRAsOvAJ9WnWBnrrUw/xScTp59cpyxjt6DRQCdGaXZ
OAttwHVMmOOIdl1MYHn4LvU=
=SX5N
-----END PGP SIGNATURE-----

--NzB8fVQJ5HfG6fxh--


-------------------------------------------------------
Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
