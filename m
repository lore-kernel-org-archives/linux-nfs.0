Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41824 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751037AbeEaFXb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 31 May 2018 01:23:31 -0400
From: NeilBrown <neilb@suse.com>
To: Steven Rostedt <rostedt@goodmis.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 31 May 2018 15:23:22 +1000
Subject: [PATCH 1/4 v2] NFS: slight optimization for walking list for delegations
In-Reply-To: <20180430111741.561df374@gandalf.local.home>
References: <152506256513.7246.13171564155614823841.stgit@noble> <152506269054.7246.3941740801391514623.stgit@noble> <20180430111741.561df374@gandalf.local.home>
Message-ID: <871sdsv1o5.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


There are 3 places where we walk the list of delegations
for an nfs_client.
In each case there are two nested loops, one for nfs_servers
and one for nfs_delegations.

When we find an interesting delegation we try to get an active
reference to the server.  If that fails, it is pointless to
continue to look at the other delegation for the server as
we will never be able to get an active reference.
So instead of continuing in the inner loop, break out
and continue in the outer loop.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

This time with a Signed-off-by - sorry.
I took the opportunity to follow Steven's suggestion
of adding a comment to the new 'break' statements.

Thanks,
NeilBrown

 fs/nfs/delegation.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 1819d0d0ba4b..b9cd3864335b 100644
=2D-- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -495,7 +495,7 @@ int nfs_client_return_marked_delegations(struct nfs_cli=
ent *clp)
 			if (!nfs_delegation_need_return(delegation))
 				continue;
 			if (!nfs_sb_active(server->super))
=2D				continue;
+				break; /* continue in outer loop */
 			inode =3D nfs_delegation_grab_inode(delegation);
 			if (inode =3D=3D NULL) {
 				rcu_read_unlock();
@@ -887,7 +887,7 @@ void nfs_delegation_reap_unclaimed(struct nfs_client *c=
lp)
 						&delegation->flags) =3D=3D 0)
 				continue;
 			if (!nfs_sb_active(server->super))
=2D				continue;
+				break; /* continue in outer loop */
 			inode =3D nfs_delegation_grab_inode(delegation);
 			if (inode =3D=3D NULL) {
 				rcu_read_unlock();
@@ -995,7 +995,7 @@ void nfs_reap_expired_delegations(struct nfs_client *cl=
p)
 						&delegation->flags) =3D=3D 0)
 				continue;
 			if (!nfs_sb_active(server->super))
=2D				continue;
+				break; /* continue in outer loop */
 			inode =3D nfs_delegation_grab_inode(delegation);
 			if (inode =3D=3D NULL) {
 				rcu_read_unlock();
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlsPhsoACgkQOeye3VZi
gblvRQ//Tu/cVIQx08FqyB/9ThWlSIIh2qwKl2YArYslc8alme8E0Mre4fjI/MA5
/E0r/4r9bU0/hKJfgOy8KlOr4WZjxjV1XAxugYOjhcNzPo+DABkSvxDD+UUGRIVk
a7ZLaAqu2gdkAB/oDraV+UCOalOSapzzJhPlUmpTTk8E6AKUI+kwmUyRz1ND66yI
rmhPT+17k1m/Qxf7pQCT5vK04ePj1xNdVdtprM0mCM582jd/fq8FvvKYCWu2oOPI
9n0O12d/i93loSyC/KgRg4prC7W9w3MO1Ieauke05tzEAwXSCkM2VNkjNByAGPJT
CIKRlC6x3euM1gq/0u5JSks8smCTu2Hy4YElXXNQPwIC57zOMdfLXGopl7iQ2/Ps
XtEfb8053LY+FlksZ+RT/disuCbSKZPu00gLVFZifYXwM5YwEqbAtYtWdVYG2SNE
JeAQH94DqIgG2LwHybnVB2sKnfgqk87Y3i7jMm1/Iih4fGBlmEAqrQ0QOtb00g7c
Aq3b4g1uEaRS47WOs3guTrYugPX6OPZIPR48qv71zIErYjjiG5S3wRxfUaq/d2of
PjOSK5rF9yO7ARQ4jwdasriKrTN/fSAQxHY7XGOjrhLeyaas5UJLLCy5bkoDpmAh
SbJQ4VbcZejO8/SrWpW0HRdIm3+wH2r4/lZ2m4O518lhpoi/8DM=
=7MYm
-----END PGP SIGNATURE-----
--=-=-=--
