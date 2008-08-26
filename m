From: =?iso-8859-1?Q?An=EDbal?= Monsalve Salazar <anibal@debian.org>
Subject: Re: Bug#492970: (was: nfs-utils-1.1.3 released)
Date: Tue, 26 Aug 2008 21:10:20 +1000
Message-ID: <20080826111020.GI12699@debianrules.debiancolombia.org>
References: <87myjul1fk.fsf@burly.wgtn.ondioline.org>
	<20080803151022.GA31484@fieldses.org>
	<60C652E1-512E-484A-874E-01997B688505@oracle.com>
	<87d4ko5wlx.fsf@burly.wgtn.ondioline.org>
	<9692E351-7140-4AD8-99F8-C9271F54CD5F@oracle.com>
	<863alj9s8p.fsf@gere.msconsult.dk>
	<5535F9D8-CD96-4807-80B3-7FD4B3983794@oracle.com>
	<20080807150514.GA3696@xanadu.blop.info>
	<6A0B8017-9FCB-4CF1-88F0-8E5752AC22EC@oracle.com>
	<2237EBE9-FE80-4B9A-B908-1533C47BBD0F@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0634196436=="
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>, bcwong@cisco.com,
	492970@bugs.debian.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <2237EBE9-FE80-4B9A-B908-1533C47BBD0F@oracle.com>
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


--===============0634196436==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="POjlveFHrWq2ZO+N"
Content-Disposition: inline


--POjlveFHrWq2ZO+N
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline

On Fri, Aug 08, 2008 at 09:06:46PM -0400, Chuck Lever wrote:
>Confirmed.  The kernel's mountd client doesn't even bother to
>unmarshal the auth flavor list in the server's reply.
>
>I'll work on a fix.

Please let me know when you have a patch to test it.

--POjlveFHrWq2ZO+N
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkiz5JoACgkQgY5NIXPNpFVqHgCgtcW7McsE/HOt6+GALltq7P/j
6vcAoMOGKOVlggAaMXoFefaGTr6gSf0R
=wXGZ
-----END PGP SIGNATURE-----

--POjlveFHrWq2ZO+N--

--===============0634196436==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--===============0634196436==--
