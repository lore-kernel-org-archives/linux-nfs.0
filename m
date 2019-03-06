Return-Path: <SRS0=mk5Y=RJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D310FC43381
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 22:49:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A442E20675
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 22:49:57 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726094AbfCFWt4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Mar 2019 17:49:56 -0500
Received: from mx2.suse.de ([195.135.220.15]:44994 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725783AbfCFWt4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Mar 2019 17:49:56 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 03E4CB615;
        Wed,  6 Mar 2019 22:49:54 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Date:   Thu, 07 Mar 2019 09:49:46 +1100
Cc:     Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] nfsd: allow nfsv3 readdir request to be larger.
In-Reply-To: <20190305214212.GC27437@fieldses.org>
References: <87lg1vs5eh.fsf@notabene.neil.brown.name> <20190304164725.GE13690@fieldses.org> <877ederyjm.fsf@notabene.neil.brown.name> <20190305214212.GC27437@fieldses.org>
Message-ID: <87y35rr52t.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


nfsd currently reports the NFSv4 dtpref FSINFO parameter
to be PAGE_SIZE, so NFS clients will typically ask for one
page of directory entries at a time.  This is needlessly restrictive
as nfsd can handle larger replies easily.

Also, a READDIR request (but not a READDIRPLUS request) has the count
size clipped to PAGE_SIE, again unnecessary.

This patch lifts these limits so that larger readdir requests can be
used.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/nfsd/nfs3proc.c | 2 +-
 fs/nfsd/nfs3xdr.c  | 4 +++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index c9cf46e0c040..8f933e84cec1 100644
=2D-- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -588,7 +588,7 @@ nfsd3_proc_fsinfo(struct svc_rqst *rqstp)
 	resp->f_wtmax  =3D max_blocksize;
 	resp->f_wtpref =3D max_blocksize;
 	resp->f_wtmult =3D PAGE_SIZE;
=2D	resp->f_dtpref =3D PAGE_SIZE;
+	resp->f_dtpref =3D max_blocksize;
 	resp->f_maxfilesize =3D ~(u32) 0;
 	resp->f_properties =3D NFS3_FSF_DEFAULT;
=20
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 83919116d5cb..93fea246f676 100644
=2D-- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -573,6 +573,8 @@ int
 nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, __be32 *p)
 {
 	struct nfsd3_readdirargs *args =3D rqstp->rq_argp;
+	u32 max_blocksize =3D svc_max_payload(rqstp);
+
 	p =3D decode_fh(p, &args->fh);
 	if (!p)
 		return 0;
@@ -580,7 +582,7 @@ nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, __be=
32 *p)
 	args->verf   =3D p; p +=3D 2;
 	args->dircount =3D ~0;
 	args->count  =3D ntohl(*p++);
=2D	args->count  =3D min_t(u32, args->count, PAGE_SIZE);
+	args->count  =3D min_t(u32, args->count, max_blocksize);
 	args->buffer =3D page_address(*(rqstp->rq_next_page++));
=20
 	return xdr_argsize_check(rqstp, p);
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlyATosACgkQOeye3VZi
gbnWvBAAwnMdpmf4PvM1cimIjSJhHQFC5W5eZD6C+8dy6savgpoCaidOPxi1hHXm
RMNETiyQKfffsOoI1gvqLWNpT0NtMTI0KGu47D66Bub0inV33jdSUI4qu7F24DJt
JKjHQwtw7ON0xLWYzTqwAEQRD2bpxG1qphNUOQ/0NwQUzJkmH6jtoPIyjCylzXrj
KwIh4pHSxwH5i82QYGIM7QIGwYftBBLvQYCGwW6EbVgpJ2X4tocmWWnMo90+qfa/
l4Gd5faFgkpy5qFvS7arvyg7wS/c5naAMOJnt+8mAL6aNvPT434vWqwyYWP/2IyV
oIMv3Q2numhsb2ugfeMq41fC6LgbzQ9MGJv9+rAmQ6rcl4FdvDrajpHenZJmn3Mh
NekKz+jEabB4F/8pCzId12ObTWZxqIqLpGLkBvrckQBlKSHDUfZPqSiUfvoSivJi
uOe0GrZIVpnCCbAj0uJHe+Yj2Y9uz4/TJ5KhVQl8RJ21QziNE1Fq/ZcJsmiufjsr
1piAgKWi42v9YEibzGiPEH9Cmqh/GuD/64iajnbO4edm5rjM5Rd1TppPFr/CHswq
8Gt8L8G+/Y2XNFDvWz+TPry7el9Iu18P7DJ8arqKUT8oGH8wSUCq668SbV+/Lish
yfbkJ8RC+qPJxoeahM3VZSS665NZsqfH7xWJdze+d2ApQOWzXnI=
=/k3D
-----END PGP SIGNATURE-----
--=-=-=--
