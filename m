Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:33997 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932361AbaGQOic (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jul 2014 10:38:32 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: multipart/signed; boundary="Apple-Mail=_B0F6D09D-5543-4A10-A194-C55EC93F18DB"; protocol="application/pgp-signature"; micalg=pgp-sha512
Subject: Announcing the release of fedfs-utils 0.9.7
Date: Thu, 17 Jul 2014 10:38:15 -0400
Message-Id: <179D1073-7F34-4DF4-9F7D-65FB65ED9C7D@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, autofs@vger.kernel.org,
        samba-technical@lists.samba.org
To: "fedfs-utils;release announcements"
	<fedfs-utils-announce@oss.oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_B0F6D09D-5543-4A10-A194-C55EC93F18DB
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

This package contains an implementation of the Federated Filesystem =
(FedFS) Proposed Standard for Linux. For an introduction to FedFS, see =
RFC 5716.

This is an ALPHA quality release.  The code in this release is not =
guaranteed to work.  Programming, administrative, and user interfaces =
may change significantly before the next release.  This release is for =
technology preview only.


Git repository:
git://git.linux-nfs.org/projects/cel/fedfs-utils.git 0.9-stable

The new head of the 0.9-stable branch is commit:

 a18875ac Release 0.9.7


Changes since 0.9.6:
	=95 Fix segfaults in nfsref
	=95 Remove an extraneous build dependency

Changes since 0.9.5:   =20
	=95 Man page correction
	=95 Numerous fixes to error handling paths

Changes since 0.9.4:
	=95 Run rpcfedfsd.service after network.target is started
	=95 Use correct RPC result type in fedfs-get-limited-nsdb-params
	=95 SET_NSDB_PARAMS should not return NSDB_LDAP_VAL

Changes since 0.9.3:
	=95 Mount fails when domain has multiple SRV records
	=95 Fix a problem with build environment

Changes since 0.9.2:
	=95 Make the use of liburiparser optional

Changes since 0.9.1:
	=95 Packaging-related improvements

Changes since 0.9.0:
	=95 Address build issues with recent automake and libtools
	=95 Replace nl_langinfo(CODESET) check in command line tools

New with fedfs-utils 0.9.0:
	=95 NSDB schema complies with latest draft standard
	=95 DNS SRV support complies with RFC 6641
	=95 NSDB clients support the FEDFS_SEC_TLS security type
	=95 NSDB clients can follow LDAP referrals returned by NSDB =
nodes
	=95 New tools for configuration of NSDBs
	=95 New "display-junction" debugging command


Tarball releases:
git://git.linux-nfs.org/projects/cel/fedfs-releases.git

Project web site
http://wiki.linux-nfs.org/wiki/index.php/FedFsUtilsProject

Installation guide:
http://wiki.linux-nfs.org/wiki/index.php/FedFsInstallationGuide0.9

Patchwork:
http://patchwork.ozlabs.org/project/fedfs-utils/list/

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




--Apple-Mail=_B0F6D09D-5543-4A10-A194-C55EC93F18DB
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCgAGBQJTx9/fAAoJEDNqszNvZn+X++4P/jGEHkWuNcI6/ZmFVTS5jgaT
SMISZ1ME2pXcVijnuf3drcsmdR9L3PE53XuP38EGwOTJq493527d7sciZ48hX7JB
PnYYmz76fujOswJKGyKx1R7iDPfZEaVv86yb7+P9j7hIZQ68Yzwna93WoBTwawv2
47WOr+y60qfpGTv0tSrzoRoyqTFiqKSgUR3xqVyWG4LEmLuPtmdbheLA0gN3VJfj
aSstZ+axs3GI5om0Sm4vD+k+Y2Zcjy2iQO+ky88MC23bFlU6/Ctp+roCi6kCscCG
PPbL1khQ91UGn3fQsrSKvFXj2n05NkY5gFABs9WnqbI1j4lRiLF0LpgKgbjfbkul
QZQGMHvJHKz0nCw6jyvKPhGj51ZudV6hEOs2pwBMziRHZM+AWHsRhYnCcdgF4LuT
BQ/ba1YUva+4TyQ9r+e+zxbLameW1bpQTMXleS/KPRp1djg+9UCKVFewpslbgdwB
ikSzwYx3cv1+9z1fdVHG1jIlCMpZYR1RpSzbGqOTYYTjIJdqw8zKJrPhSL0zOYdS
nzW0ae7YAEPepbPNn9bcr1X+Zqi4xouAkuwRfqgE2fHU/1CozL7ujpG8en4mCMvp
FcHGMUqG2dc72ar7e1UWCecQHNWvHq1LPKiBzL1E6l6e5I736YPivJZl4QX1wEvD
Qhk8tao1/NG4QQ50p+aQ
=16QH
-----END PGP SIGNATURE-----

--Apple-Mail=_B0F6D09D-5543-4A10-A194-C55EC93F18DB--
