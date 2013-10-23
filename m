Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:44493 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753511Ab3JWBo6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 21:44:58 -0400
Date: Wed, 23 Oct 2013 12:44:44 +1100
From: NeilBrown <neilb@suse.de>
To: tasleson@redhat.com
Cc: linux-nfs@vger.kernel.org, Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] exportfs: Return non-zero exit value on error
Message-ID: <20131023124444.65ace6e3@notabene.brown>
In-Reply-To: <52669862.6030409@redhat.com>
References: <1380756584-13335-1-git-send-email-tasleson@redhat.com>
	<20131022092519.4f4683a8@notabene.brown>
	<52669862.6030409@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/75=hcdMA+8klYd/_0Prt0CF"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/75=hcdMA+8klYd/_0Prt0CF
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 22 Oct 2013 10:23:14 -0500 Tony Asleson <tasleson@redhat.com> wrote:

> On 10/21/2013 05:25 PM, NeilBrown wrote:
> > On Wed,  2 Oct 2013 18:29:44 -0500 Tony Asleson <tasleson@redhat.com> w=
rote:
> >=20
> >> To improve error handling when scripting exportfs it's useful
> >> to have non-zero exit codes when the requested operation did not
> >> succeed.
> >>
> >> This patch also returns a non-zero exit code if you request to
> >> unexport a non-existant share.
> >>
> >> Signed-off-by: Tony Asleson <tasleson@redhat.com>
> >=20
> > This seems the have been forgotten, so maybe by replying to it someone =
will
> > notice (hi Steve).
> >=20
> > Though I agree with the need for the patch, I don't much like it's shap=
e.
> >=20
> > Why change exportfs and unexportfs to return a status?  The status is o=
nly
> > used to set export_errno, and they sometimes set export_errno anyway, s=
o why
> > not leave them returning  void and just setting export_errno as needed?
>=20
> The reason I chose to return values was to make sure requested operation
> actually completed requested operation.  Unexporting a non-existent
> export is not considered an error and returns no indication you did
> absolutely nothing.

Hi,
 thanks makes sense - I had missed that (even though you explained it in the
 patch description :-( )

 With your patch, if asked to unexport something that wasn't exported it
 would not report any error, but would exit with an error status.  Is that
 correct?  I think I would rather have a message printed if there is an err=
or.

 So would something like this (on top of my patch) address you need, or was
 there something else I missed?

Thanks,
NeilBrown

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 52fc03d..c9e12db 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -351,6 +351,7 @@ unexportfs(char *arg, int verbose)
 	char		*path;
 	char		*hname =3D arg;
 	int		htype;
+	int		success =3D 0;
=20
 	if ((path =3D strchr(arg, ':')) !=3D NULL)
 		*path++ =3D '\0';
@@ -397,7 +398,10 @@ unexportfs(char *arg, int verbose)
 #endif
 		exp->m_xtabent =3D 0;
 		exp->m_mayexport =3D 0;
+		success =3D 1;
 	}
+	if (!success)
+		xlog(L_ERROR, "Could not find %s to unexport.\n", arg);
=20
 	freeaddrinfo(ai);
 }

--Sig_/75=hcdMA+8klYd/_0Prt0CF
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUmcqDDnsnt1WYoG5AQI/YQ/+NOnoPqprVDZlxlNmCxiZt9aREn5CYFDJ
WEEAGKah4j3k87pelmZoaHIUfY5HDwTC2kcQBT9MqtCVwXs49mUTnjopkg7o+Y8d
LsKQUJSJtqEdD0pAhJIsDYPrOdg3jbglaoKN2cYMEsuTHbpIZD0h6nz6pu0HsF1f
r5DgVKWCHkIajf7z2T4nHqGVmVa5/dRib4JxF8KsgvuGoetaboeiJWOh1OZSJ52F
bUKjOIK5r2ou34XhAvXICHyDexPBZcwWPRCAgMowbSn4lp3O18wwez1uyoCsgF+8
qlOWyg8LYu33yhPrehbJ3HSgtBFv21YKUKziXB9KK6YN4ZhrokuLYfYpHcz/2ZSa
tUT+4JulOz9KhuoiFCq/RuIXHVcJvHHZ05TX6H43SuxbNMCjqT6Wy/C4UHh8PIln
kMu3RwFLVyI2nXm58u18O2eFnD9PLMUiAlit/rqqL7NJkZVrAfkJrhef1nagh6je
0vFCd6vi0B6UvAzscZtZdCNuJCkn8YGfK5rB5uSEciupSRLr40EMfpp/aPnW4Evm
6J2LPFud5risNmNh0IY4jRMO10zfTGea6hmgD98WSX27Ro01dJ2x93T0fkTlGTE+
ivv2PgUETxd1jnQWMyBe6MdI7HgTTCXVXJT70MALlvrpJfscqGaqXvk8fk/7xrtL
DefyItCsFkE=
=whjM
-----END PGP SIGNATURE-----

--Sig_/75=hcdMA+8klYd/_0Prt0CF--
