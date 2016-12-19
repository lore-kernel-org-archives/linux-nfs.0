Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50306 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750850AbcLSATm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 18 Dec 2016 19:19:42 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>
Date: Mon, 19 Dec 2016 11:19:31 +1100
Cc: Olga Kornievskaia <aglo@umich.edu>,
        Adamson William <andros@netapp.com>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>, Adamson@suse.com,
        Andy <William.Adamson@netapp.com>
Subject: [PATCH resend] NFSv4.1: nfs4_fl_prepare_ds must be careful about reporting success.
In-Reply-To: <CAN-5tyFfnSxcnFjpcCqT--qQhpHa-37NnVXuX70imE1WiyFFNg@mail.gmail.com>
References: <87lgxiwoxi.fsf@notabene.neil.brown.name> <8760nlfkkq.fsf@notabene.neil.brown.name> <C9C69F9A-F0AD-4F76-B334-11C4E83D4155@primarydata.com> <CAN-5tyH+4=9y9a3v0po5-cW+5ABSp5Z1pXN=+eTZSnd0KORk2Q@mail.gmail.com> <87wpg0dlnb.fsf@notabene.neil.brown.name> <CAN-5tyFfnSxcnFjpcCqT--qQhpHa-37NnVXuX70imE1WiyFFNg@mail.gmail.com>
Message-ID: <8760mgvkh8.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Various places assume that if nfs4_fl_prepare_ds() turns a non-NULL 'ds',
then ds->ds_clp will also be non-NULL.

This is not necessasrily true in the case when the process received a fatal=
 signal
while nfs4_pnfs_ds_connect is waiting in nfs4_wait_ds_connect().
In that case ->ds_clp may not be set, and the devid may not recently have b=
een marked
unavailable.

So add a test for ds_clp =3D=3D NULL and return NULL in that case.

Fixes: c23266d532b4 ("NFS4.1 Fix data server connection race")
Signed-off-by: NeilBrown <neilb@suse.com>
Acked-by: Olga Kornievskaia <aglo@umich.edu>
Acked-by: Adamson, Andy <William.Adamson@netapp.com>
=2D--

Hi Trond,
 I just noticed that this wasn't in your 4.10 pull request.  So I've
 added Acked-bys from Andy and Olga and am resending.

Thanks,
NeilBrown


 fs/nfs/filelayout/filelayoutdev.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayo=
utdev.c
index a5589b791439..f956ca20a8a3 100644
=2D-- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -282,7 +282,8 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u3=
2 ds_idx)
 			     s->nfs_client->cl_minorversion);
=20
 out_test_devid:
=2D	if (filelayout_test_devid_unavailable(devid))
+	if (ret->ds_clp =3D=3D NULL ||
+	    filelayout_test_devid_unavailable(devid))
 		ret =3D NULL;
 out:
 	return ret;
=2D-=20
2.11.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhXJ5QACgkQOeye3VZi
gbnOTw//cN6WI0k6YyUHCr3q7pWZ9Rz9UYG3InIoZS9+GaYTGa5yu02gLhHk9Ced
WeHkCJ5tTWElp3orgwwh0CM8VaxeLSPs7Z6SzLET9MF4YKHeEqzCRB+My4besmKJ
/851doXjf9NLKlw6wVfNdTijfOiTRtqnokRwpkL95B59XUJpowzGo+/3XLzO4PHU
xyQ0QI4SaDC7zNtMowAN5VBiq/rrUjRRkQ+jALZIyVlTHpHSrRHrBf/gWZdS9Yh2
wxrW9vf8v4e54VkcimnKBnuuI+WMTSmhgMPre1YTO/b874EOyBVyyWV9gCo9bSgJ
leWSD6jsJwo3ysIEeMA8diHTHdrVFCaRjpHQ3e/UpjLv0NBmzKae7Z1LgC2bOOy7
Y78xgWOawq5ZZEe4wi/L9DqA8j0A9XXNt+xdMa40fh+KGG9eqjBUfeswfA8q6LKk
WWBJ0LdLHe+j0kP3GWPE3qhyd7lM1R6q1uaK8yAmBjN5Ee/o7tBABf2We1icYAaF
0VtChcNGWJXTdrhdruzWPQy8l6xX3RFeWdm5KQ5am65G6ybfsn6D4OuA6rd5kqlq
M3rIIh2JtkEVTqBBmY0NTis0EslAUonVbNFjeFaNMTY3sKnDjiljWViuyl2665dv
pgSeBfhFb5RLZiLLeMIsoyEemjM4lJPjygInTDIK+71F/WL1i4c=
=/u03
-----END PGP SIGNATURE-----
--=-=-=--
