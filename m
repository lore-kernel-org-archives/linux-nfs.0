Return-Path: <SRS0=iDPq=RH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDA53C43381
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 03:08:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 936F620823
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 03:08:32 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725974AbfCDDIb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 3 Mar 2019 22:08:31 -0500
Received: from mx2.suse.de ([195.135.220.15]:41782 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725938AbfCDDIb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 3 Mar 2019 22:08:31 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 622F1AEDF;
        Mon,  4 Mar 2019 03:08:30 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>
Date:   Mon, 04 Mar 2019 14:08:22 +1100
Subject: [PATCH] nfsd: fix memory corruption caused by readdir
cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Message-ID: <87lg1vs5eh.fsf@notabene.neil.brown.name>
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


If the result of an NFSv3 readdir{,plus} request results in the
"offset" on one entry having to be split across 2 pages, and is sized
so that the next directory entry doesn't fix in the requested size,
then memory corruption can happen.

When encode_entry() is called after encoding the last entry that fits,
it notices that ->offset and ->offset1 are set, and so stores the
offset value in the two pages as required.  It clears ->offset1 but
*does not* clear ->offset.

Normally this omission doesn't matter as encode_entry_baggage() will
be called, and will set ->offset to a suitable value (not on a page
boundary).
But in the case where cd->buflen < elen and nfserr_toosmall is
returned, ->offset is not reset.

This means that nfsd3proc_readdirplus will see ->offset with a value 4
bytes before the end of a page, and ->offset1 set to NULL.
It will try to write 8bytes to ->offset.
If we are lucky, the next page will be read-only, and the system will
  BUG: unable to handle kernel paging request at...

If we are unlucky, some innocent page will have the first 4 bytes
corrupted.

nfsd3proc_readdir() doesn't even check for ->offset1, it just blindly
writes 8 bytes to the offset wherever it is.

Fix this by clearing ->offset after it is used, and copying the
=2D>offset handling code from nfsd3_proc_readdirplus into
nfsd3_proc_readdir.

(Note that the commit hash in the Fixes tag is from the 'history'
 tree - this bug predates git).
Fixes: eb229d253e6c ("[PATCH] kNFSd: fix two xdr-encode bugs for readdirplu=
s reply")
Cc: stable@vger.kernel.org (v2.6.12+)
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

Can I still get extra credit for fixing a bug that is 14.5 years old, if
I'm the one who introduced it?

 fs/nfsd/nfs3proc.c | 16 ++++++++++++++--
 fs/nfsd/nfs3xdr.c  |  1 +
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 9eb8086ea841..c9cf46e0c040 100644
=2D-- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -463,8 +463,19 @@ nfsd3_proc_readdir(struct svc_rqst *rqstp)
 					&resp->common, nfs3svc_encode_entry);
 	memcpy(resp->verf, argp->verf, 8);
 	resp->count =3D resp->buffer - argp->buffer;
=2D	if (resp->offset)
=2D		xdr_encode_hyper(resp->offset, argp->cookie);
+	if (resp->offset) {
+		loff_t offset =3D argp->cookie;
+
+		if (unlikely(resp->offset1)) {
+			/* we ended up with offset on a page boundary */
+			*resp->offset =3D htonl(offset >> 32);
+			*resp->offset1 =3D htonl(offset & 0xffffffff);
+			resp->offset1 =3D NULL;
+		} else {
+			xdr_encode_hyper(resp->offset, offset);
+		}
+		resp->offset =3D NULL;
+	}
=20
 	RETURN_STATUS(nfserr);
 }
@@ -533,6 +544,7 @@ nfsd3_proc_readdirplus(struct svc_rqst *rqstp)
 		} else {
 			xdr_encode_hyper(resp->offset, offset);
 		}
+		resp->offset =3D NULL;
 	}
=20
 	RETURN_STATUS(nfserr);
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 9b973f4f7d01..83919116d5cb 100644
=2D-- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -921,6 +921,7 @@ encode_entry(struct readdir_cd *ccd, const char *name, =
int namlen,
 		} else {
 			xdr_encode_hyper(cd->offset, offset64);
 		}
+		cd->offset =3D NULL;
 	}
=20
 	/*
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlx8lqcACgkQOeye3VZi
gbmMZQ//X3PHTu3swQ0759WwQhkkdqXWlyt2uv8yzx3rcYeeP45AIzq2NS7tDsbJ
JwD2qWS+QciC0VhizPVQ+pgPRJvGMrGOwTZGGiDxKIDVauCKTPLMLzSh2do8zO0o
z9dyltflNwixZoeDp4l8mByQhx3Qh2yXkY6iHoNGmQVsnHltnC/t2akQDz2XlXJF
/eoamBN6vmrjnniXTR5TivgygOC0LCBKnawbJNbWUPA7UhG+sP8mWiHTqz8jquym
qOQRJnA7aOzxebA6RBTJScmcnT86S8bOFvY4lBbsxO6vVK9fsY0pQG2GALnT+S4R
8NMfGbO3dmcIn5ayCAEOYUp195O98PclJLeTqGyF9Pro25JCBI/9BUF2jQTSUhrh
W8fNnGtGiEgMU25sX779q44jE4W20q/RENkyMH0u6bJUoaCc4mUVg0OTNRcO94NU
1ysnu3f6Pl90kwaWtS8xR0dZFOsiCTyZH2dKZQSOgfocM+pUk8wk4cCvkN2dcu6c
H3oSPYP+lAIeFAuFWWljkHyIhheL6xAsP79548ixGiZDdebyMwt1b9zFDcF95aqV
EsYaEmZaVmjDupPq/c9Kwhn8NUogK8E62wK6O0+D7wpntXB0y/TX5+3/j1e75qDD
0v3IguvlL30o62trjuLV/3vdPEiaeNPgML2QH9WyrtDBUKkVPXI=
=D6y8
-----END PGP SIGNATURE-----
--=-=-=--
