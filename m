Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:49502 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751463Ab3JUXDm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 19:03:42 -0400
Date: Tue, 22 Oct 2013 10:03:29 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH nfs-utils] mountd: fix bug affecting exports of dirs with
 64bit inode number.
Message-ID: <20131022100329.20f37a19@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/ylNmVcgzofzLW6XI0hNjKE2"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ylNmVcgzofzLW6XI0hNjKE2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



parse_fsid() is currently truncating all inode numbers to
32bits, and assumes that 'int' is 32 bits (which it probably is,
but we shouldn't assume).

So make the 'inode' field in 'struct parsed_fsid' a 64 bit field.
and only memcpy into variables or fields that have been declared
to a specific bit size.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 517aa62..e04b86e 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -388,10 +388,10 @@ struct parsed_fsid {
 	int fsidtype;
 	/* We could use a union for this, but it would be more
 	 * complicated; why bother? */
-	unsigned int inode;
+	uint64_t inode;
 	unsigned int minor;
 	unsigned int major;
-	unsigned int fsidnum;
+	uint32_t fsidnum;
 	size_t uuidlen;
 	char *fhuuid;
 };
@@ -399,8 +399,8 @@ struct parsed_fsid {
 static int parse_fsid(int fsidtype, int fsidlen, char *fsid,
 		struct parsed_fsid *parsed)
 {
-	unsigned int dev;
-	unsigned long long inode64;
+	uint32_t dev;
+	uint32_t inode32;
=20
 	memset(parsed, 0, sizeof(*parsed));
 	parsed->fsidtype =3D fsidtype;
@@ -409,7 +409,8 @@ static int parse_fsid(int fsidtype, int fsidlen, char *=
fsid,
 		if (fsidlen !=3D 8)
 			return -1;
 		memcpy(&dev, fsid, 4);
-		memcpy(&parsed->inode, fsid+4, 4);
+		memcpy(&inode32, fsid+4, 4);
+		parsed->inode =3D inode32;
 		parsed->major =3D ntohl(dev)>>16;
 		parsed->minor =3D ntohl(dev) & 0xFFFF;
 		break;
@@ -420,7 +421,7 @@ static int parse_fsid(int fsidtype, int fsidlen, char *=
fsid,
 		memcpy(&parsed->fsidnum, fsid, 4);
 		break;
=20
-	case FSID_MAJOR_MINOR: /* 12 bytes: 4 major, 4 minor, 4 inode=20
+	case FSID_MAJOR_MINOR: /* 12 bytes: 4 major, 4 minor, 4 inode
 		 * This format is never actually used but was
 		 * an historical accident
 		 */
@@ -430,7 +431,8 @@ static int parse_fsid(int fsidtype, int fsidlen, char *=
fsid,
 		parsed->major =3D ntohl(dev);
 		memcpy(&dev, fsid+4, 4);
 		parsed->minor =3D ntohl(dev);
-		memcpy(&parsed->inode, fsid+8, 4);
+		memcpy(&inode32, fsid+8, 4);
+		parsed->inode =3D inode32;
 		break;
=20
 	case FSID_ENCODE_DEV: /* 8 bytes: 4 byte packed device number, 4 inode */
@@ -440,7 +442,8 @@ static int parse_fsid(int fsidtype, int fsidlen, char *=
fsid,
 		if (fsidlen !=3D 8)
 			return -1;
 		memcpy(&dev, fsid, 4);
-		memcpy(&parsed->inode, fsid+4, 4);
+		memcpy(&inode32, fsid+4, 4);
+		parsed->inode =3D inode32;
 		parsed->major =3D (dev & 0xfff00) >> 8;
 		parsed->minor =3D (dev & 0xff) | ((dev >> 12) & 0xfff00);
 		break;
@@ -448,7 +451,8 @@ static int parse_fsid(int fsidtype, int fsidlen, char *=
fsid,
 	case FSID_UUID4_INUM: /* 4 byte inode number and 4 byte uuid */
 		if (fsidlen !=3D 8)
 			return -1;
-		memcpy(&parsed->inode, fsid, 4);
+		memcpy(&inode32, fsid, 4);
+		parsed->inode =3D inode32;
 		parsed->uuidlen =3D 4;
 		parsed->fhuuid =3D fsid+4;
 		break;
@@ -467,8 +471,7 @@ static int parse_fsid(int fsidtype, int fsidlen, char *=
fsid,
 	case FSID_UUID16_INUM: /* 8 byte inode number and 16 byte uuid */
 		if (fsidlen !=3D 24)
 			return -1;
-		memcpy(&inode64, fsid, 8);
-		parsed->inode =3D inode64;
+		memcpy(&parsed->inode, fsid, 8);
 		parsed->uuidlen =3D 16;
 		parsed->fhuuid =3D fsid+8;
 		break;

--Sig_/ylNmVcgzofzLW6XI0hNjKE2
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUmWywjnsnt1WYoG5AQKgkxAAwPE41JE8J0tkeEipgHvvIEkK+BfecNCr
0UDrHQDnmpTIovsCOfD6+xOA5CNz5rFWsTr6fGHNJ3AMlQfcSBH/CEpIrdLOvV+y
wqcmoMpdksYFi3tmwTX+2fJ7D9JVHxupq6KQ5bEyITpb/4vmuhUZ3FcJ2N8OeGjr
AlIzOiNkWeEtXu0V9Wa+6N4THQoYENiOCDJpUUfr2tasC980DQqV8A9SObaQF8Iv
U6/F/aGlPjjA1FTsycbqgXuOfQAucv2Xwudcw1Ds4mXO0Kbj6th8blus7Xza49VL
de/i42vpc17gaIiTfbjQ6vrw03AvO4r9+xXsATnuTuiBGBxV35F94FUYv6OIUa+y
t074PKzqbG6xDL5xsZBPzD1DjE7Jgx3RpmkIiKoS5t28Rd9IFOqCulJ9oQ2H2bCf
FTHBeW1k6VcLb3ykjWUSIvAJ0KRH5GDwumChrWCytYRmWmvmI3t754VHmJ5LBXVI
s0foRkL8mlHSRqFcSqeZefG1EYx6u4Hnm0WPriJyC7jXI8fC7jW26ejwofCRo/b2
DiJAcQ8osEo4Bn3OdXQhca/h88v4XeEfZLjZmrOVL9zXRdVhDPulk3KkuqZvKNtX
Op19YJ8t0XRjZy6Alks71yep/fSlj9RpiKDNFQzJu7LEe0ZrWQYk637UadJyiLmO
x3ImtTPZ8TQ=
=wcH9
-----END PGP SIGNATURE-----

--Sig_/ylNmVcgzofzLW6XI0hNjKE2--
