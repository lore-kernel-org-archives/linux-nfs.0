From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: FC2 NFS server + Solaris 9 4/04 strange permissions problem
Date: Fri, 08 Oct 2004 13:16:38 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1097266598.8133.117.camel@tesuji.nac.uci.edu>
References: <1096996544.4460.769.camel@tesuji.nac.uci.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-/TbElx8sWtJvP9zauIbE"
Cc: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CG1Ak-0001m3-3v
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 13:17:02 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CG1AU-0006DT-TO
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 13:17:02 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <1096996544.4460.769.camel@tesuji.nac.uci.edu>
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


--=-/TbElx8sWtJvP9zauIbE
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


There must be something about the combination of iso9660, loopback
mounting, and NFS, because when I did a tar pipeline to copy the
loopback mount into ext3, I was then able to NFS mount that onto the
same sun from the same NFS server, and all was well.

Thanks.

On Tue, 2004-10-05 at 10:15, Dan Stromberg wrote:
> On an FC2 system, I'm:
>=20
> 1) loopback mounting a .iso, with the following options from "mount":
> 	/tmp/sol-8-hw4-sparc-v1.iso on /mnt/loop type iso9660
> 	(ro,loop=3D/dev/loop0)
> 2) Turning off iptables
> 3) sharing out the loopback mount over NFS, with the following
> /etc/exports entry:
> 	/mnt/loop autoinst.nacs.uci.edu(ro,insecure,no_root_squash)
>=20
> Then on the Solaris 9 4/04 system, I:
>=20
> 1) Mount the loopback filesystem, with the following attributes from the
> "mount| grep /mnt" command:
> 	remote/read only/setuid/xattr/dev=3D430003c
> 2) Run a:
> 	find . -depth -print  | cpio -pdmu /some/local/dir
>=20
> ...and when I do this, most files are copied fine, however a small
> number of them give 'cpio: Error with fstatat() of
> "Product/SUNWxwfnt/reloc/openwin/bin", errno 13, Permission denied'
> errors.
>=20
> I suspect that it isn't the same files giving this errror every time.
>=20
> To make matters more perplexing, every time I do such a find | cpio, I
> get errors, but when I ls these directories, I do Not Get Consistent
> Behavior.  Sometimes I see:
> 	ls -ld ./Product/SUNW1251f/reloc/usr/bin
> 	./Product/SUNW1251f/reloc/usr/bin: Permission denied
> ...while other times I see:
> 	ls -ld ./Product/SUNW1251f/reloc/usr/bin
> drwxr-xr-x   2 root     other       2048 Jan  8  2004
> ./Product/SUNW1251f/reloc/usr/bin
>=20
>=20
> Has anyone else encountered this?
>=20
> Has anyone come across a solution?
>=20
> Should I just stop using the loopback mounts, and burn some CD-R's?  :)
>=20
>=20
> Thanks!
--=20
Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>


--=-/TbElx8sWtJvP9zauIbE
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBZvWmo0feVm00f/8RAiISAJ9a9El2jIhk7geZC964iunkg5QRhgCdFX1Y
Dr2JdkRXY5WPhMZWKmiNGtM=
=aU4A
-----END PGP SIGNATURE-----

--=-/TbElx8sWtJvP9zauIbE--



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
