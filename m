Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:48217 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751113AbdJXA35 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 23 Oct 2017 20:29:57 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Tue, 24 Oct 2017 11:29:46 +1100
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] sunrpc: use supplimental groups in auth hash.
Message-ID: <87h8upe6bp.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Some sites vary some supplimental groups a lot.
To avoid unduely long hash chains, include all of these
in the hash calculation.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

Hi,
 I have a customer who had thousands of auth entries with the same
 uid and gid, so the hashtable was unbalanced and some lookups were
 noticeably slow.  This fix helped.

 Relatedly, I wonder if we should set a default auth_max_cred_cachesize,
 and nfs_access_max_cachesize - smaller than ULONG_MAX.

 For auth_max_cred_cachesize, a default of e.g. 256*(1<<auth_hashbits)
 is appropriate I think.  If there are more auth entries than that,
 you'll start to notice lookups taking a long time.

 For nfs_access_max_cachesize we want a similar limit as each access
 entry pins an auth entry and so keeps a hash chain long.

 Or maybe we could change the auth lookup to use an rbtree (or
 hash-table of rbtrees?) so that time scales with log of size.

 One option is to restore the 'jiffies' field to the access cache, and
 discard entries older than (say) 10 minutes.

 Thoughts?

Thanks,
NeilBrown


 net/sunrpc/auth_generic.c | 15 ++++++++++++---
 net/sunrpc/auth_unix.c    | 12 +++++++++---
 2 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index f1df9837f1ac..035f7c5f184f 100644
=2D-- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -81,9 +81,18 @@ static struct rpc_cred *generic_bind_cred(struct rpc_tas=
k *task,
 static int
 generic_hash_cred(struct auth_cred *acred, unsigned int hashbits)
 {
=2D	return hash_64(from_kgid(&init_user_ns, acred->gid) |
=2D		((u64)from_kuid(&init_user_ns, acred->uid) <<
=2D			(sizeof(gid_t) * 8)), hashbits);
+	int ret =3D hash_32(from_kuid(&init_user_ns, acred->uid), 32);
+
+	if (acred->group_info) {
+		int g;
+
+		for (g =3D 0; g < acred->group_info->ngroups; g++)
+			ret =3D hash_32(ret ^
+				      from_kgid(&init_user_ns,
+						acred->group_info->gid[g]),
+				      32);
+	}
+	return hash_32(ret ^ from_kgid(&init_user_ns, acred->gid), hashbits);
 }
=20
 /*
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 82337e1ec9cd..20cd4ab3b339 100644
=2D-- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -47,9 +47,15 @@ unx_destroy(struct rpc_auth *auth)
 static int
 unx_hash_cred(struct auth_cred *acred, unsigned int hashbits)
 {
=2D	return hash_64(from_kgid(&init_user_ns, acred->gid) |
=2D		((u64)from_kuid(&init_user_ns, acred->uid) <<
=2D			(sizeof(gid_t) * 8)), hashbits);
+	int ret =3D hash_32(from_kuid(&init_user_ns, acred->uid), 32);
+	if (acred->group_info) {
+		int g;
+
+		for (g =3D 0; g < acred->group_info->ngroups && g < UNX_NGROUPS; g++)
+			ret =3D hash_32(ret ^ from_kgid(&init_user_ns,
+						      acred->group_info->gid[g]), 32);
+	}
+	return hash_32(ret ^ from_kgid(&init_user_ns, acred->gid), hashbits);
 }
=20
 /*
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlnuiX0ACgkQOeye3VZi
gbl3YQ//ddBH35u0hWk0ffIGPe6WMMbnhcunoyTk9Gdlbth9pJ0lPcId1vBItkm9
pBfY2q2BO+HHXLrIMSc8UtMUf4msm/80eQ4DFf3sWYdgTE/X3lQnaWFqFpesjPA9
fXtoxvJgOw1nBt0nM6Mk0wZBlXUBv30nAAkTicVboKeWkUQa0SXtWnWgEpYUZlAv
ENJ1DJzdcIOOEW2ZASe5Wsa883ubX6oStzEJjf8FfETBfemWhL8wnqw8qk5YzuzA
fok7TrsoREqlL1Sc09iw6yMl7ZeRDdh5fkI+Ypo3CH0mqw1TVKdJhcPL6yNuOHBX
fu2xqib4m4xkdFiNX4vvPP3XQc3PdXnxlYL290kIO3pSgmMb5bsX3nt2qhBsQEDo
xLOTFVfFOI5dVpREAbZlVfRWcTo0nJPSvgKU/B2f8nI1gycoegxeBZQUwZm9FkoF
ik+m0OIIER/o+dN6QNvj4EigOPrjCL2sl0sFC0RheuqybEXUrxLv3yHHbdo6L5N8
CE65PXXi2ibHTXnbFZ4RZA6WnX0K2vKFKeT7wRBgaAp6/wiwotnRYp6Efzs5V54P
kt3qCrimPrT/UPDyMXtnoAcPHVmT/M+2JZ/5+DM0vGubsao2FX4242exnZf6jm1j
uZSPylWvGCDnnKuJZ+pC4w+esB22YphM5dFqlMs8kfmLuPWslqs=
=mLon
-----END PGP SIGNATURE-----
--=-=-=--
