From: Jordi Mallach <jordi@debian.org>
Subject: Re: Possible breakthrough Re: Debian Bug#203918 - statd request on eth interface, not localhost?
Date: Thu, 21 Aug 2003 20:54:54 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030821185454.GA4643@nubol.int.oskuro.net>
References: <20030821180214.GA12129@perlsupport.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="1yeeQ81UyVL57Vl7"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 115.red-213-96-69.pooles.rima-tde.net ([213.96.69.115] helo=natura.oskuro.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19puaM-0004zL-00
	for <nfs@lists.sourceforge.net>; Thu, 21 Aug 2003 11:55:02 -0700
To: Chip Salzenberg <chip@debian.org>
In-Reply-To: <20030821180214.GA12129@perlsupport.com>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 21, 2003 at 02:02:14PM -0400, Chip Salzenberg wrote:
> That *is* interesting.  It's possible that statd and even portmap will
> refuse to accept requests from localhost, since your /etc/hosts.deny
> says "ALL: PARANOID", and your loopback interface fails the paranoia
> test.
>=20
> Could you please do what it takes to make "host localhost" and "host
> 127.0.0.1" work on both client *and* server, and see if your problem
> goes away?  Either that or add "ALL: 127.0.0.1" to /etc/hosts.allow.

Ok. I added "localhost" to my internal network zone file. I thought this
was bad, but someone on IRC told me it's ok. They also told me it's
really not needed (normal apps should be using nsswitch.conf, but host
doesn't).

20801:jordi@natura:~$ host localhost
localhost.int.oskuro.net        A       127.0.0.1

FWIW, "ALL: 127.0.0.1" didn't help.

Ok. Apparently it doesn't help either... I have restarted the nfs stuff
and nothing happens. I'm seeing the exact same messages on the server's
logs and this on the client's when I try to use apt-get:

Aug 21 20:49:15 nubol rpc.statd[632]: Received erroneous SM_UNMON request f=
rom nubol for 192.168.1.1

(nubol =3D client =3D 192.168.1.3)

Of course, I haven't remounted or anything after doing these changes,
because I can't umount the share. Should I reboot the client to see?

> (Sorry for the resend, Jordi.)

No problem, after all the help I'm getting from you guys :)

Jordi
--=20
Jordi Mallach P=E9rez  --  Debian developer     http://www.debian.org/
jordi@sindominio.net     jordi@debian.org     http://www.sindominio.net/
GnuPG public key information available at http://oskuro.net/~jordi/

--1yeeQ81UyVL57Vl7
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/RRV+JYSUupF6Il4RAsl6AKDZRwNw1la0Z6NQVPMRov2JDsS8LgCdHwXr
+J5vcDOLb+Yn/YJgRJikrTg=
=tPd3
-----END PGP SIGNATURE-----

--1yeeQ81UyVL57Vl7--


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
