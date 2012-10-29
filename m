Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38556 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753504Ab2J2B6z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 28 Oct 2012 21:58:55 -0400
Date: Mon, 29 Oct 2012 12:59:14 +1100
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Legacy NFS client DNS resolver fails since 2.6.37
Message-ID: <20121029125914.506eb0fc@notabene.brown>
In-Reply-To: <6F448C67-E729-41E7-A09C-A49D15B50D5E@oracle.com>
References: <6F448C67-E729-41E7-A09C-A49D15B50D5E@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/CHTmRAPyL5yxXqwVcnJ_wwW"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/CHTmRAPyL5yxXqwVcnJ_wwW
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 28 Oct 2012 21:03:45 -0400 Chuck Lever <chuck.lever@oracle.com> wro=
te:

> Hi Neil-
>=20
> To use the legacy DNS resolver for resolving hostnames in NFSv4 referrals=
, I've installed the /sbin/nfs_cache_getent script on my NFS client "degas.=
"  I've confirmed it works with a 2.6.36 kernel.
>=20
> However, since 2.6.37 commit c5b29f885afe890f953f7f23424045cdad31d3e4 "su=
nrpc: use seconds since boot in expiry cache" the legacy DNS resolver appea=
rs not to work.  When attempting to follow a referral that uses a server ho=
stname, the client fails 100% of the time to mount the referred to server w=
ith an error such as:
>=20
>   [cel@degas example.net]$ ls home
>   ls: cannot open directory home: No such file or directory
>=20
> The contents of the dns_resolve cache appear to indicate that there are r=
esolution results in the cache, but the CACHE_VALID flag is not set for tha=
t entry:
>=20
>   [root@degas dns_resolve]# cat content=20
>   # ip address      hostname        ttl
>   #               , klimt.example.net 48
>=20
> klimt.example.net is the hostname that is contained in the referral.
>=20
> I have a second referral called "ip-address" in the same directory (domai=
nroot), with the same content except the IP address of klimt is used instea=
d of its hostname.  Following that second referral always works.
>=20
> I've tried every stable.0 release up to 3.6.0, and the behavior is roughl=
y the same for each, which suggests that there is no upstream fix for this =
issue thus far.
>=20
> Since I've never seen a problem like this reported, I'm wondering if anyo=
ne else can confirm this issue.
>=20
> I have a narrow interest in fixing the legacy DNS server in stable kernel=
s, but there may also be a latent problem with the RPC cache implementation=
 that could spell trouble for other consumers, even post-3.6.
>=20
> A rough outline of how you might reproduce this:
>=20
>   + Build and install a 2.6.37 or later kernel for your NFS client with C=
ONFIG_NFS_USE_LEGACY_DNS=3Dy.
>=20
>   + Set up an NFS server with "refer=3D" exports.  man exports(5)
>=20
>   + On your client, mount the server directory that contains the exports,=
 then try to "cd" through one of the referrals.
>=20
> If you don't feel up to replicating the above arrangement, can you sugges=
t cache debugging instrumentation that can be added to my client to help na=
il this?  Thanks for any advice!
>=20


Hi Chuck,
 looks like I messed up.
Every other cache uses absolute timestamps for expiry time.  The dns resolv=
er
differs from this and uses relative time stamps (ttl).  I obviously didn't
understand this properly when I wrote the patch that broke things.
In particular, using get_expiry() is inappropriate in this context.

Something like this should fix it.

NeilBrown


diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index 31c26c4..d9415a2 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -217,7 +217,7 @@ static int nfs_dns_parse(struct cache_detail *cd, char =
*buf, int buflen)
 {
 	char buf1[NFS_DNS_HOSTNAME_MAXLEN+1];
 	struct nfs_dns_ent key, *item;
-	unsigned long ttl;
+	unsigned int ttl;
 	ssize_t len;
 	int ret =3D -EINVAL;
=20
@@ -240,7 +240,8 @@ static int nfs_dns_parse(struct cache_detail *cd, char =
*buf, int buflen)
 	key.namelen =3D len;
 	memset(&key.h, 0, sizeof(key.h));
=20
-	ttl =3D get_expiry(&buf);
+	if (get_int(&buf, &ttl) < 0)
+		goto out;
 	if (ttl =3D=3D 0)
 		goto out;
 	key.h.expiry_time =3D ttl + seconds_since_boot();



--Sig_/CHTmRAPyL5yxXqwVcnJ_wwW
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUI3i8jnsnt1WYoG5AQLCEQ/7BW8y6R12hvoYgvvuDCqOvKdHUmc6Vm58
KHy4bb/VWkQRxnRYGXWyb2d3maGfYlm2lKTPBf/4iqZj3FEHMpithr/ZYf5tAHLw
Fuit5Sg/c1l88jOgll8yNJ0ClWqDod5RHITsBqwcaQItFmsNjjTrk0RNAAQspEw7
9RRHGgDkUGAR625YBu1dCs2zX2bKf5MZ8nmP4/WVsomisiJEdzxNgE2oyeQO4lnK
QCUUZ7eWYAomwfTZqWTnT2ibek70YnuRLN02P8ctVeLcwUq3X/7m4iz9GzGB7NEh
p57u3WFaUoURXVKnkniGXi1cfWluE8iUw0lys/vXCXDmXFObfWcY7yZmFYUUt9Rl
CghmE7FeuPCgCbL57IkV4elITyXKUdTgd1pIR3zBMhTTJTxATr5chjEST4rsZklw
ZRFvcLT4M3xXUdmsQnJeW7F/un2NjADH4Z40Zi0Ild0Nb65gupF8gyr9m3NgVDHi
Z5XnY0BB1yDQ2eLVEQL97xZiI+Athf0qDqj75jzqOIalp+HlFN+YWegTZ21uJDXt
gkgU1hdmyJhqUVI+PTGIuXjAK57Ovl5c07z377o6+ZkHFK4BRg0CNXPxtH+piBV6
fUzxdhbsCfBDZ9OypVfoFO1RTRa7j9ROsXXmaL7MqS6S3Q+Gc6CJcfH1kNqPR30/
exl8sL/vbgs=
=TW15
-----END PGP SIGNATURE-----

--Sig_/CHTmRAPyL5yxXqwVcnJ_wwW--
