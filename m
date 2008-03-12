From: Adam Schrotenboer <adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>
Subject: Re: nfs_update_inode: inode X mode changed, Y to Z
Date: Wed, 12 Mar 2008 11:06:02 -0700
Message-ID: <47D81B8A.7040702@m2000.com>
References: <47C5EC81.6080004@m2000.com> <47C71EC6.3050702@m2000.com> <3AD71C5E-B45A-4BDB-8C94-73D62256BEBF@astro.wisc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig3AA27CAB1B4215B4C2494F5B"
Cc: opensuse@opensuse.org, Thomas Daniel <tdaniel-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	jesper.juhl@gmail.com, Fred Revenu <frevenu-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>,
	Neil Brown <neilb@suse.de>
To: Stephan Jansen <jansen-IwvncFSHKSLQAyQhgwMYSA@public.gmane.org>
Return-path: <opensuse+bounces-53980-glsog-opensuse=m.gmane.org@opensuse.org>
List-Post: <mailto:opensuse@opensuse.org>
List-Help: <mailto:opensuse+help@opensuse.org>
List-Subscribe: <mailto:opensuse+subscribe@opensuse.org>
List-Unsubscribe: <mailto:opensuse+unsubscribe@opensuse.org>
List-Owner: <mailto:opensuse+owner@opensuse.org>
In-Reply-To: <3AD71C5E-B45A-4BDB-8C94-73D62256BEBF-IwvncFSHKSLQAyQhgwMYSA@public.gmane.org>
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig3AA27CAB1B4215B4C2494F5B
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Stephan Jansen wrote:
>
> Hi,
>
> We've just run into a similar thing.  We have an OpenSuSE 10.3 NFS serv=
er
> exporting a filesystem to about 40 machines, most of which are also
> running OpenSuSE 10.3.  The client machines are running a distributed
> data processing pipeline.  The clients create, move and delete=20
> directories
> and files on the server.  We've seen a few instances where the=20
> programs on
> the clients die with a "no such file or directory" error but no errors =
in
> syslog.  Finally last night many of the clients gave these errors in=20
> syslog
> at about the same time as the client programs died with "no such file o=
r
> directory" errors:
>
> Mar 11 20:57:53 glimpse5 kernel: nfs_update_inode: inode 402653248=20
> mode changed, 0100644 to 0040755
> Mar 11 20:57:54 glimpse6 kernel: nfs_update_inode: inode 402653248=20
> mode changed, 0100644 to 0040755
> Mar 11 20:57:49 tsingtao kernel: nfs_update_inode: inode 402653248=20
> mode changed, 0100644 to 0040755
> Mar 11 20:57:16 glimpse12 kernel: nfs_update_inode: inode 402653248=20
> mode changed, 0100644 to 0040755
> Mar 11 20:59:04 cecilia kernel: nfs_update_inode: inode 402653248 mode =

> changed, 0100644 to 0040755
> Mar 11 20:59:11 glimpse28 kernel: nfs_update_inode: inode 402653248=20
> mode changed, 0100644 to 0040755
> Mar 11 20:58:20 glimpse27 kernel: nfs_update_inode: inode 402653248=20
> mode changed, 0100644 to 0040755
> Mar 11 20:59:12 glimpse18 kernel: nfs_update_inode: inode 402653248=20
> mode changed, 0100644 to 0040755
> Mar 11 20:58:22 glimpse19 kernel: nfs_update_inode: inode 402653248=20
> mode changed, 0100644 to 0040755
> Mar 11 20:59:25 glimpse20 kernel: nfs_update_inode: inode 402653248=20
> mode changed, 0100644 to 0040755
> Mar 11 20:58:35 glimpse21 kernel: nfs_update_inode: inode 402653248=20
> mode changed, 0100644 to 0040755
> Mar 11 20:59:27 glimpse22 kernel: nfs_update_inode: inode 402653248=20
> mode changed, 0100644 to 0040755
> Mar 11 20:59:27 glimpse23 kernel: nfs_update_inode: inode 402653248=20
> mode changed, 0100644 to 0040755
> Mar 11 20:59:39 glimpse24 kernel: nfs_update_inode: inode 402653248=20
> mode changed, 0100644 to 0040755
>
> I notice that the offending inodes are all the same.  This all worked=20
> without
> problems when the NFS server was SuSE 10.0.  The exported filesystem=20
> is XFS.
>
> Anyone have any ideas what's going on?
I personally don't, but I have a running thread with some of the NFS=20
maintainers, that I have added this mail to now.


--------------enig3AA27CAB1B4215B4C2494F5B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFH2BuKyWYDdvnGArwRAv49AJ9Oni5roL8rkCFtIbXYt2STSqHkXQCbB79I
wugF6kM0BAkvaIr/PEvuRHI=
=ssmx
-----END PGP SIGNATURE-----

--------------enig3AA27CAB1B4215B4C2494F5B--
