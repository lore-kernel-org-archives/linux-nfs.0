From: Martin Waitz <tali@admingilde.org>
Subject: Re: [PATCH] NFS using CacheFS
Date: Mon, 11 Oct 2004 16:23:29 +0200
Sender: linux-cachefs-bounces@redhat.com
Message-ID: <20041011142329.GJ4072@admingilde.org>
References: <4161B664.70109@RedHat.com> <41661950.5070508@tequila.co.jp>
	<41667865.2000804@RedHat.com>
Reply-To: Linux filesystem caching discussion list <linux-cachefs@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0119317214=="
Cc: Linux filesystem caching discussion list <linux-cachefs@redhat.com>,
	nfs@lists.sourceforge.net,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Clemens Schwaighofer <cs@tequila.co.jp>
Return-path: <linux-cachefs-bounces@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <41667865.2000804@RedHat.com>
List-Unsubscribe: <http://www.redhat.com/mailman/listinfo/linux-cachefs>,
	<mailto:linux-cachefs-request@redhat.com?subject=unsubscribe>
List-Archive: </archives/linux-cachefs>
List-Post: <mailto:linux-cachefs@redhat.com>
List-Help: <mailto:linux-cachefs-request@redhat.com?subject=help>
List-Subscribe: <http://www.redhat.com/mailman/listinfo/linux-cachefs>,
	<mailto:linux-cachefs-request@redhat.com?subject=subscribe>
Errors-To: linux-cachefs-bounces@redhat.com
List-ID: <nfs.lists.sourceforge.net>


--===============0119317214==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2WS97oupGEGbYNpW"
Content-Disposition: inline


--2WS97oupGEGbYNpW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

hi :)

On Fri, Oct 08, 2004 at 07:22:13AM -0400, Steve Dickson wrote:
> The 'fscache' flag will be coming along with the nfs4 support, since
> nfs4 mounting code does not have an open (unused) mounting flag....

is such a flag even neccessary?
The way I see fscache is that its operations will be no-ops anyway if you
haven't mounted any backing cache.

--=20
Martin Waitz

--2WS97oupGEGbYNpW
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFBapdgj/Eaxd/oD7IRAmPmAJ9b2l9TuQSokw+O55kM+aqUutb0OQCdGkxe
nyV9WhgMUTRRWeEbOfwoQuo=
=wQV1
-----END PGP SIGNATURE-----

--2WS97oupGEGbYNpW--


--===============0119317214==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--
Linux-cachefs mailing list
Linux-cachefs@redhat.com
http://www.redhat.com/mailman/listinfo/linux-cachefs

--===============0119317214==--
