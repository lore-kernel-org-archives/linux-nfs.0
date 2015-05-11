Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40361 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753150AbbEKLNS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 May 2015 07:13:18 -0400
Date: Mon, 11 May 2015 21:13:02 +1000
From: NeilBrown <neilb@suse.de>
To: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
Cc: Josef Bacik <jbacik@fb.com>, Chris Mason <clm@fb.com>,
        Jan Kara <jack@suse.cz>, David Sterba <dsterba@suse.cz>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-nilfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Subject: [PATCH v2] NILFS2: support NFSv2 export
Message-ID: <20150511211302.1299aff5@notabene.brown>
In-Reply-To: <20150511.185458.913750783836948467.konishi.ryusuke@lab.ntt.co.jp>
References: <20150508001623.31129.25102.stgit@notabene.brown>
	<20150511.013143.706881749197692581.konishi.ryusuke@lab.ntt.co.jp>
	<20150511170251.4fb69e52@notabene.brown>
	<20150511.185458.913750783836948467.konishi.ryusuke@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/sxRqc3X6vzax+.w7_MJ83/b"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/sxRqc3X6vzax+.w7_MJ83/b
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


The "fh_len" passed to ->fh_to_* is not guaranteed to be that same as
that returned by encode_fh - it may be larger.

With NFSv2, the filehandle is fixed length, so it may appear longer
than expected and be zero-padded.

So we must test that fh_len is at least some value, not exactly equal
to it.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nilfs2/namei.c b/fs/nilfs2/namei.c
index 22180836ec22..37dd6b05b1b5 100644
--- a/fs/nilfs2/namei.c
+++ b/fs/nilfs2/namei.c
@@ -496,8 +496,7 @@ static struct dentry *nilfs_fh_to_dentry(struct super_b=
lock *sb, struct fid *fh,
 {
 	struct nilfs_fid *fid =3D (struct nilfs_fid *)fh;
=20
-	if ((fh_len !=3D NILFS_FID_SIZE_NON_CONNECTABLE &&
-	     fh_len !=3D NILFS_FID_SIZE_CONNECTABLE) ||
+	if (fh_len < NILFS_FID_SIZE_NON_CONNECTABLE ||
 	    (fh_type !=3D FILEID_NILFS_WITH_PARENT &&
 	     fh_type !=3D FILEID_NILFS_WITHOUT_PARENT))
 		return NULL;
@@ -510,7 +509,7 @@ static struct dentry *nilfs_fh_to_parent(struct super_b=
lock *sb, struct fid *fh,
 {
 	struct nilfs_fid *fid =3D (struct nilfs_fid *)fh;
=20
-	if (fh_len !=3D NILFS_FID_SIZE_CONNECTABLE ||
+	if (fh_len < NILFS_FID_SIZE_CONNECTABLE ||
 	    fh_type !=3D FILEID_NILFS_WITH_PARENT)
 		return NULL;
=20

--Sig_/sxRqc3X6vzax+.w7_MJ83/b
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVVCOvznsnt1WYoG5AQKLPw/9ExmIXmAmCqhDat1l6E72RzYZ6OeXJG/N
xnCYHPHzIA5/LJMTKQFAFGDSt68gOw5QBpo/ZDODC3SBgHmQGnE57TBtpR7ao/RB
usfTHc3Lt0rTNSXsEyTNTONzWSPKpCraD6Hc+//BBP5lYWhZPmoSQwE69JDfaWiL
TDmBMIE4KmsiBxM8X0NzXy6NBSyQSfgYhJTvlHlc+rqsgYz0hnJzPWaV4RoONJ+b
kll/GOo+jLG9bT+I297Uo4fWIilmedk3tBsamrGGaS/9RfFHnWO5xTI8QxSjQvqI
TbCQaLbMMFFNQg0GEQHn+C0kg5qQngoke1AU6L7PUqq4BZumpx7SnBbMkotqLtYc
uF+6NiUhCNUHkBETn/fwIkMaz/OuQmkPhsRhyCSuLtTDdsoHnoFovAZZAc1ZBAb1
jqgJg3mrzouBRg6Mv3Kf5VRdEPExanMLweGeeQK2oeO7mza1c0gwH6PEhaNuJhZZ
+lFfpQ69oNDhyHRJY13oRovlx/ShvYTPIwXnON1EpMq4e4fDLWZZ2jYOlvGRNvOE
49ENDzKY1o5GrTLFli8KWJWI6SHA6M/srB/ZXq1E6p8wVreC5ozKkHiu08oMFoYo
OLjdmMR72iYPhJRy9aCMEQmV8i6NTruL/pF3F5m84xgy1vzUseTlh78uoTRl85sh
A6YcaktGgaY=
=VFc9
-----END PGP SIGNATURE-----

--Sig_/sxRqc3X6vzax+.w7_MJ83/b--
