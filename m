Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:50225 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751156Ab2LKACm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2012 19:02:42 -0500
Date: Tue, 11 Dec 2012 11:02:28 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] gssd: base the size of the fd array on the
 RLIMIT_NOFILE limit.
Message-ID: <20121211110228.0159fc4f@notabene.brown>
In-Reply-To: <20121129113051.046bc658@notabene.brown>
References: <20121128010939.2475.13123.stgit@notabene.brown>
	<20121128011123.2475.13691.stgit@notabene.brown>
	<20121128131054.GB11651@fieldses.org>
	<20121129113051.046bc658@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/MD7KluzxDeoyOGifaJJE67c"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/MD7KluzxDeoyOGifaJJE67c
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 29 Nov 2012 11:30:51 +1100 NeilBrown <neilb@suse.de> wrote:

> On Wed, 28 Nov 2012 08:10:55 -0500 "J. Bruce Fields" <bfields@fieldses.or=
g>
> wrote:
>=20
> > On Wed, Nov 28, 2012 at 12:11:23PM +1100, Neil Brown wrote:
> > > We have previously raised the size of the 'pollarray' once (32 -> 256)
> > > and I have had another request to make it bigger.
> > > Rather than changing the hard-coded value, make it depend on
> > > RLIMIT_NOFILE.  This is an upper limit on the size of the array
> > > that can be passed to poll() anyway.
> >=20
> > Sounds like a good idea.
> >=20
> > Just out of curiosity: how does it fail?  I guess mounts just start
> > failing at some point--how do people find the workaround?
>=20
> Error seems to be
>=20
> rpcsec_gss: gss_init_sec_context: (major) Miscellaneous failure - (minor)=
 Cannot contact any KDC for requested realm
>=20
> in rpc.gssd logs.
>=20
> I guess people could read the source to find the work around .... not ide=
al
> though.  I guess we should get gssd to generate some more helpful message.
>=20
> The seem to be further problems that the customer is experiencing so I mi=
ght
> wait until they are completely resolved to ensure I have complete
> understanding before I propose a further patch.

The "further problem" was that krb5 libraries use select() in a way that do=
es
not support file descriptors higher than 1024.  This is fixed in the latest
krb5 so that is no longer an issue.

I've been thinking about your question, and about how best to deliver a fix
to customers, and I really think it should all "just work".
i.e. the array that gssd should be sized dynamically and RLIMIT_NOFILE shou=
ld
be increased as needed.

I haven't tested this, but what do people think?   I don't have a problem
changing the rlim_cur limit like this, but I wonder if it is OK to
dynamically set rlim_max.

Thoughts?

NeilBrown


diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index d01ba2f..3576a6f 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -389,18 +389,36 @@ static int
 get_poll_index(int *ind)
 {
 	unsigned int i;
+	struct pollfd *new_pollarray;
+	struct rlimit rlim;
=20
 	*ind =3D -1;
 	for (i=3D0; i<pollsize; i++) {
 		if (pollarray[i].events =3D=3D 0) {
 			*ind =3D i;
-			break;
+			return 0;
 		}
 	}
-	if (*ind =3D=3D -1) {
+
+	new_pollarray =3D realloc(pollarray, pollsize * 2 * sizeof(*pollarray));
+	if (!new_pollarray) {
 		printerr(0, "ERROR: No pollarray slots open\n");
 		return -1;
 	}
+	pollarray =3D new_pollarray;
+	memset(pollarray + pollsize, 0, sizeof(*pollarray) * pollsize);
+	*ind =3D pollsize;
+	pollsize *=3D 2;
+
+	/* We will need lots of file descriptors too */
+	if (getrlimit(RLIMIT_NOFILE, &rlim) =3D=3D 0) {
+		if (rlim.rlim_cur < pollsize+20) {
+			rlim.rlim_cur =3D pollsize + 20;
+			if (rlim.rlim_max < rlim.rlim_cur)
+				rlim.rlim_max =3D rlim.rlim_cur;
+			setrlimit(RLIMIT_NOFILE, &rlim);
+		}
+	}
 	return 0;
 }
=20
@@ -473,13 +491,9 @@ fail_keep_client:
 void
 init_client_list(void)
 {
-	struct rlimit rlim;
 	TAILQ_INIT(&clnt_list);
 	/* Eventually plan to grow/shrink poll array: */
 	pollsize =3D FD_ALLOC_BLOCK;
-	if (getrlimit(RLIMIT_NOFILE, &rlim) < 0 &&
-	    rlim.rlim_cur !=3D RLIM_INFINITY)
-		pollsize =3D rlim.rlim_cur;
 	pollarray =3D calloc(pollsize, sizeof(struct pollfd));
 }
=20

--Sig_/MD7KluzxDeoyOGifaJJE67c
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUMZ4FDnsnt1WYoG5AQIPTw/7B8CE0zwiGmNsoDr5Wo9kScsu3xSWIBWm
jDCdMlYNQvDhRjVDHeVqpdU3u+U3/kVg55LDO34MTyL7dfqFZKHCWfzqJNis5OmB
/KRJqUogFOxKgjeEXiWoAJxS2bL8tgEftQvym3MWKV2HUxJ0K588iNsak452RVH6
tOn35HNIjC5B+CdMBCRKpO3wp6qeAtTDEIIzUnZX74zPIhOSG1MSm6GVYcR0xMsY
V1PZvoUbopDPkJW4CBGwwc9rKgdT7uQeBzAxVCykFUoJ19iL8Jvo600z/1t0cPJG
aF+9XfFW0N53p5uoZZGloQmM9zFui2QiILMlE/Z8QZMSkW9mwpna+GXuVRuOLYzL
jLseiF3fqMWKdZDt0yqpBXIGBgoaYr5UBztSJOtbSI81ihrgtGyzHiElfunFCJKI
zub1CkY73PveJsw2ePbc1TRTbHxvXpeJLGmHrv9Lu1Trv9YuQKGdakvTNcrkoE10
74v7lpwR9pvX6CUCfLDFAUo8d68CWVarXEIsh7rHHsxVnIhCUHd3XO9nsfJMbA75
c7LVCvBBGQhlhYGYreF6on4pIwY3ttiOlQ3pxfrIW6Yy/ux1TqXZNXUAx0qFDGSt
xGWIO+AwcIJpIUWUxukfA4m72l6f64EgkzbGelPP4/vGbnKyAN9gAaudka7uU4/3
HO5tTqBCSKM=
=Kg8O
-----END PGP SIGNATURE-----

--Sig_/MD7KluzxDeoyOGifaJJE67c--
