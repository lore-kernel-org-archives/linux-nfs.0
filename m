From: seth vidal <skvidal@phy.duke.edu>
Subject: Re: troubling interaction with quotas and nfs
Date: 09 Apr 2002 11:19:07 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1018365547.27365.26.camel@opus>
References: <1018325948.2639.67.camel@milo>
	<15538.29176.579826.727109@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature";
	boundary="=-j16KUjvwegjpHv/9HMvn"
Cc: nfs@lists.sourceforge.net
Received: from mail.phy.duke.edu ([152.3.182.2])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16uxOs-0004Bg-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Apr 2002 08:19:14 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15538.29176.579826.727109@notabene.cse.unsw.edu.au>
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


--=-j16KUjvwegjpHv/9HMvn
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2002-04-09 at 00:45, Neil Brown wrote:
> On  April 9, skvidal@phy.duke.edu wrote:
> > Hi all,
> >  I'm running red hat 7.2 with the 2.4.9-31 kernel.
> > Its an ext3 file system, exported for nfsv3 udp and nfsv2 clients.
> >=20
> > nothing fancy at all.
> >=20
> > I have quotas set for my users. If a user hits their hard quota and the
> > process continues to attempt to write to a file in their  quota'd space
> > - the process load on the server shoots through the roof.=20
> >=20
> > I can reliably recreate this by setting a hard quota, having the system
> > hit the hard quota and continue to attempt to write to that file - the
> > server becomes terribly unhappy.
> >=20
> > I never saw this problem on older 2.2.X servers and I'm not sure why I'=
m
> > seeing it now.
> >=20
> > Any places I should be looking first?
> >=20
>=20
> tcpdump?
> The server should return nfserr_dquot (69 =3D=3D 0x45) and the client
> should return this to the application.
> But it sounds like the client is repeating the request for some
> reason.
>=20
> You could also=20
>    echo 32 > /proc/sys/sunrpc/nfsd_debug
> and watch for
>     "nfsd: write complete err=3D%d"
> messages in the kernel log.  These will tell you whether nfsd thinks
> it got an error for the write.
>=20

It appears to return -122

However, the program will exit correctly if it catches that problem. But
the system does not respond well if there is a continued attempt to
write a lot of data when the quota is filled.

That doesn't seem to make sense.

-sv


--=-j16KUjvwegjpHv/9HMvn
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQA8swZr1Aj3x2mIbMcRAgdBAJwK2T+i9II+DaarzalX7IH9U2SgpwCfTXux
Tfubn8wndQk4yASAsFS5HtI=
=hgA+
-----END PGP SIGNATURE-----

--=-j16KUjvwegjpHv/9HMvn--


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
