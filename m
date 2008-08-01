From: =?iso-8859-1?Q?An=EDbal?= Monsalve Salazar <anibal@debian.org>
Subject: (was: nfs-utils-1.1.3 released)
Date: Fri, 1 Aug 2008 23:15:33 +1000
Message-ID: <20080801131533.GN14057@debianrules.debiancolombia.org>
References: <488D718F.200@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1188722374=="
Cc: Christian Surchi <csurchi@debian.org>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Rasmus =?iso-8859-1?B?Qvhn?= Hansen <rasmus@msconsult.dk>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>, 492970@bugs.debian.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <488D718F.200@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Mime-version: 1.0
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>


--===============1188722374==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="dZHW955j1vPFHE0Q"
Content-Disposition: inline


--dZHW955j1vPFHE0Q
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 28, 2008 at 03:13:19AM -0400, Steve Dickson wrote:
>I just cut the 1.1.3 nfs-utils release. Unfortunately I'm having
>issues accessing my kernel.org account so for the moment the=20
>tar ball is only available on SourceForge:
>
>     http://sourceforge.net/projects/nfs
>[...]=20

1.1.3 clients don't work with a 1.0.10 server anymore.

Please read the Debian bug report at http://bugs.debian.org/492970

On Fri, Aug 01, 2008 at 02:54:02PM +0200, Christian Surchi wrote:
>On Wed, Jul 30, 2008 at 12:56:12PM +0200, Rasmus B=F8g Hansen wrote:
>>Package: nfs-common
>>Version: 1:1.1.3-1
>>Severity: important
>>
>>
>>Upgrading nfs-common 1:1.1.3-1 broke my NFS client.
>>
>>The NFS server is running etch and nothing was changed. After upgrading
>>the client to 1:1.1.3-1 access to my files (/home is NFS-mounted) is
>>disallowed where it should be allowed (and certainly was in 1:1.1.2-6).
>
>I confirm this one on my sid client too. No changes in nfs server=20
>(etch). Downgrading nfs-common solved the problem for me too.
>
>Christian

--dZHW955j1vPFHE0Q
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkiTDHIACgkQgY5NIXPNpFVHJgCgjPAwJLEqej7MHOxwQSNlaioc
XacAoNHW1nAMsRang1e8HZTY5Ee4F7TC
=v8UL
-----END PGP SIGNATURE-----

--dZHW955j1vPFHE0Q--

--===============1188722374==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--===============1188722374==--
