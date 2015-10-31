Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26317 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288AbbJaVha (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 31 Oct 2015 17:37:30 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: multipart/signed; boundary="Apple-Mail=_6B82C4B5-104E-406E-9FFD-3B5C523FC149"; protocol="application/pgp-signature"; micalg=pgp-sha512
Subject: Announcing the release of fedfs-utils version 0.10.5
Date: Sat, 31 Oct 2015 17:37:07 -0400
Message-Id: <B532CF95-7E25-42DC-91F3-E96BDCC87F22@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        samba-technical@lists.samba.org, autofs@vger.kernel.org
To: "fedfs-utils;release announcements"
	<fedfs-utils-announce@oss.oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_6B82C4B5-104E-406E-9FFD-3B5C523FC149
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8

This package contains an implementation of the Federated Filesystem
(FedFS) Proposed Standard for Linux. For an introduction to FedFS, see
RFC 5716.

This is an ALPHA quality release.  The code in this release is not
guaranteed to work.  Programming, administrative, and user interfaces
may change significantly before the next release.  This release is for
technology preview only.

Changes since 0.10.4:
	=E2=80=A2 More fixes in admin tools


Changes since 0.10.3:
	=E2=80=A2 Fix bugs in admin tools


Changes since 0.10.2:
	=E2=80=A2 More error handling fixes
	=E2=80=A2 Remove an incorrect package dependency


Changes since 0.10.1:
	=E2=80=A2 Fix bugs in nsdb-jumpstart
	=E2=80=A2 Numerous fixes to error handling paths
	=E2=80=A2 Introduce basic support for Coverity analysis


Changes since 0.10.0:
	=E2=80=A2 Address packaging issues


New with fedfs-utils 0.10.0:

Non-backwards compatible changes:
	=E2=80=A2 *ldaperr removed from libnsdb API
	=E2=80=A2 ADMIN client tools no longer use AUTH_NONE security
	=E2=80=A2 ADMIN client tools no longer exit with FedFS status =
code

New features:
	=E2=80=A2 Python package PyFedfs added
	=E2=80=A2 Tool for configuring FedFS domain root directories
	=E2=80=A2 Tool for setting up NSDBs using OpenLDAP
	=E2=80=A2 Simpler NCE discovery (compliant with new FedFS NCE =
I-D)
	=E2=80=A2 admin_t API for performing remote ADMIN requests
	=E2=80=A2 rpc.fedfsd uses an ACL to control who can perform =
ADMIN requests
	=E2=80=A2 rpc.fedfsd and ADMIN tools support RPCSEC and Kerberos =
v5

Minor fixes:
	=E2=80=A2 FEDFS_LOOKUP_JUNCTION no longer returns NSDB_LDAP_VAL
	=E2=80=A2 fedfs-map-nfs4 handles multiple SRV records
	=E2=80=A2 Packaging simplifications
	=E2=80=A2 Dozens of code clean-ups and bug fixes; consult =
Changelog for details


Source code available at:
http://git.linux-nfs.org/?p=3Dcel/fedfs-utils.git

The new head of the master branch is commit:

df0bf073399a Release 0.10.5

Patchwork available at:
http://patchwork.ozlabs.org/project/fedfs-utils/list/

Tarball releases available at:
http://git.linux-nfs.org/?p=3Dcel/fedfs-releases.git;a=3Dsummary

--
Chuck Lever


--Apple-Mail=_6B82C4B5-104E-406E-9FFD-3B5C523FC149
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCgAGBQJWNTSNAAoJEDNqszNvZn+X5hkP/0pRxgLWKoE5nwCsKj1L0d1Z
c7/of3be4CfGEKanAsxJT0VtdyNsCYPKl2vwFXe8s7eqLlQ8TKcO4mI4BZLe/u4t
fgIykKXILoUMLnfx+LCxxLp6GJ79VCcGvxBgJs/Xp0x+2NHA5OG5RGAfbmIQblSi
alYKR5gWJDWp931BTHfkaR+JXz5HJoxmXe51M3zbHZfASgY2clw1E0mn/5SNXWwE
YQ4SFuG9euNB9EmSDa9xALXMrQTq4WMEojUESaBEEMEV0cPW9386EeZAm46e+z43
hkWipf/I9PZmOz5upzb0ATDK9Rip1ZuMXxQJhjAXTrHTCbIiLlEXuKo7RjAeiMMW
eEvrNln8+5eLs3KuBJLhTa1otKnvhWZn/A40Om2cVZ0s35dYHzbYqHBA2x+qcMQP
tPA8NV3QRnpnDnhxbBv1zF9HQZ+9n2sB665gTJ7N6QufuhfROgDXezbE4jzu+P0u
d9/P3sBYQhIhUGJ0BROz/7M7jvBRnvMF5bCgq3w8wiRwRkyatpHwJIs3SB7Rne4F
TJmh6+uwdN8UNphUojY2JgOltjw+8hJ2/FkdxZyu+bX5KGwe5GROZefgCSSTEad/
bh4o2bo03jHG1gQnpmDKLODFjMPf2aPYyeAx/OO7cfeQfdkeKMzEDAv5kd6ANHzl
M/loZbdGvq4wkMVZcOfd
=XnmX
-----END PGP SIGNATURE-----

--Apple-Mail=_6B82C4B5-104E-406E-9FFD-3B5C523FC149--
