Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:57451 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752565AbbBPBVP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 15 Feb 2015 20:21:15 -0500
Date: Mon, 16 Feb 2015 12:21:07 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH/RFC nfs-utils] exports.man: improve documentation of
 'nohide' and 'crossmnt'
Message-ID: <20150216122107.4bfd4225@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/Mwy5t=G/+Zr7N1=uoCyyTr5"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Mwy5t=G/+Zr7N1=uoCyyTr5
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



- note that 'nohide' is irrelevant for NFSv4
- note that children on a 'crossmnt' filesystem cannot be unexported
- note that 'nocrossmnt' is a valid option, but probably not useful.

Signed-off-by: NeilBrown <neilb@suse.de>

---

I wonder if we should add a new option, e.g. "noaccess" so that children
of a "crossmnt" filesystem can be hidden.  The  kernel wouldn't need to
know about this.  It would just tell mountd to refuse to export that
filesystem even if the parent was "crossmnt".
??

NeilBrown


diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index 3d974d92a729..88d9fbebe386 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -218,16 +218,46 @@ This option can be very useful in some situations, bu=
t it should be
 used with due care, and only after confirming that the client system
 copes with the situation effectively.
=20
-The option can be explicitly disabled with
+The option can be explicitly disabled for NFSv2 and NFSv3 with
 .IR hide .
+
+This option is not relevant when NFSv4 is use.  NFSv4 never hides
+subordinate filesystems.  Any filesystem that is exported will be
+visible where expected when using NFSv4.
 .TP
-.IR crossmnt
+.I crossmnt
 This option is similar to
 .I nohide
-but it makes it possible for clients to move from the filesystem marked
-with crossmnt to exported filesystems mounted on it.  Thus when a child
-filesystem "B" is mounted on a parent "A", setting crossmnt on "A" has
-the same effect as setting "nohide" on B.
+but it makes it possible for clients to access all filesystems mounted
+on a filesystem marked with
+.IR crossmnt .
+Thus when a child filesystem "B" is mounted on a parent "A", setting
+crossmnt on "A" has a similar effect to setting "nohide" on B.
+
+With
+.I nohide
+the child filesystem needs to be explicitly exported.  With
+.I crossmnt
+it need not.  If a child of a
+.I crossmnt
+file is not explicitly exported, then it will be implicitly exported
+with the same export options as the parent, except for
+.IR fsid=3D .
+This makes it impossible to
+.B not
+export a child of a
+.I crossmnt
+filesystem.  If some but not all subordinate filesystems of a parent
+are to be exported, then they must be explicitly exported and the
+parent should not have
+.I crossmnt
+set.
+
+The
+.I nocrossmnt
+option can explictly disable
+.I crossmnt
+if it was previously set.  This is rarely useful.
 .TP
 .IR no_subtree_check
 This option disables subtree checking, which has mild security

--Sig_/Mwy5t=G/+Zr7N1=uoCyyTr5
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVOFGAznsnt1WYoG5AQI/3g//e18kuZfD/OPv6TkG+TUnTko2JIH7MbTi
H159aeCoExvL6L7+BAHM+F5cQtrFh2Ab40x9fRgMN+b9rudcY6gZ/xMVxa6R8C5u
CK6+s3lOzlwRgcaYiyjbofiZt8Z1xAPV30Wkq2tqI0Brp9NNNQ8mkUx0uHX5hs7z
rCE1UFUuSmDjHyRd1XZ5h5fVeI+r2b7vtr2vcdyQIpShW4p/unI2fECD3mBevQT7
Ms3lJ9ESGxlDFhwfvOcKSOnTnARqZjxJ1u0XzoQdWFxZ9flMRBvAwf2JdAxkJVDt
pCQupZMw+5hf2ZHUAYOFcvn09PmdL/U5fqPX2Hzg7lpxRUvGuXV6Gi5rwa51hzi3
aBmAyT/GTgZQeOmqN0cCHWGSIgcIBZ10w+5egirfzTbMKjHrzXsvNcD5kH60+Qx+
HHp/vWu6JhcYOiEYenG0wQW9a+Sd/VChVqL1KbQ3q2mbXd2GncwmTiazHqRFEuYU
ydwWMRFi9NVX4yl0jPrpKg7hl4Gq4AfugRwxiPptUu5gSzzcc0RZBHxiJ2/dw/Fq
cdWe2B4WqJK4fBYJAut53q2wnxYRcss+uUEoay9W065QsImq2qEWnppTbpOKHIpD
b5SsxZETuQxxuYQlX2qtqEa3pQ8fEAgrkh8Z8aubFg4lW+lhfY1xa4i96Hw91lFE
v9IOUUNP7Us=
=E2oO
-----END PGP SIGNATURE-----

--Sig_/Mwy5t=G/+Zr7N1=uoCyyTr5--
