Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:48392 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753696Ab3JOOvl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Oct 2013 10:51:41 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: multipart/signed; boundary="Apple-Mail=_A5964627-06DE-4A72-905B-E33EC5D9DFAB"; protocol="application/pgp-signature"; micalg=pgp-sha1
Subject: Announcing the release of fedfs-utils 0.9.4
Date: Tue, 15 Oct 2013 10:51:35 -0400
Message-Id: <B878534C-41AD-439B-B81A-C557418F9B17@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "autofs@vger.kernel.org" <autofs@vger.kernel.org>,
        "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>
To: "fedfs-utils;release announcements"
	<fedfs-utils-announce@oss.oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_A5964627-06DE-4A72-905B-E33EC5D9DFAB
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

This package contains an implementation of the Federated Filesystem =
(FedFS) Proposed Standard for Linux.  For an introduction to FedFS, see =
RFC 5716.

This is an ALPHA quality release.  The code in this release is not =
guaranteed to work.  Programming, administrative, and user interfaces =
may change significantly before the next release.  This release is for =
technology preview only.

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

Project web site
http://wiki.linux-nfs.org/wiki/index.php/FedFsUtilsProject

Installation guide:
http://wiki.linux-nfs.org/wiki/index.php/FedFsInstallationGuide0.9

Tarball releases:
http://git.linux-nfs.org/?p=3Dcel/fedfs-releases.git;a=3Dsummary

Git repository:
=
http://git.linux-nfs.org/?p=3Dcel/fedfs-utils.git;a=3Dshortlog;h=3Drefs/he=
ads/0.9-stable

Patchwork:
http://patchwork.ozlabs.org/project/fedfs-utils/list/

--=20
Chuck Lever
chuck[dot]lever[at]oracle[dot]com


--Apple-Mail=_A5964627-06DE-4A72-905B-E33EC5D9DFAB
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBAgAGBQJSXVZ3AAoJEKtSGoIDWtn6MrYP/3DKooIQSs9uk0CtR/nNEVtB
8kzipP3iiUHYaNEBJ+rtnGonDJvHwjo59BkKXowB54OqWRx6+WTyQC9j8q6o2FJB
jtAJehbZAqyTz1zvFpXLX5J8YMgJmWfOsM4EzBg7bl4yhAYl5lBUlIXg0VVT4fs3
Rf9MxJtUwXAoTZlBbxe4+CxMuX0dZFO/L58Vdra9bpUkCBj+OA90CkDQk1t2lW18
A/QcykMtwlyxMmElg4vzvCQ71jJ+UWXSpqg3XTf+uWaNZsAr37XaVnqflyFQMeBd
AvSRVpwM1IOiQwSgA719MgQ0zWYDTNPr8eHRyejGkcy3koLIzahite6h5hDJOfsl
Fh4X5pbVEEH1gzLTylB8e/fjoGD2SIkY1xoCdUQJ3YbZThXn9p04HOXRYGpPnA32
e91FrsolKSBFx2cKKGtOAghdj+cE/gQ5zAbWZ2Fkt7jVaptQZAW3X9UJj+8weTkM
xwgRlk/wVbHtnScqQD0/V1h7+/iKBOibF5bHu/GFxsFG63KxIFpZgKIS9gSbbTGk
3GOi/BDIoqg8xmQ5y0a/k2GplZoRXDlYYGLY5Q5iyXxBeiAQ1JzzzRcfwKhYTjyv
wSMor1WR/sIBfXOWGuaQQKH1+WkU2qyUal4TIvgpy04c+sjG73QLUC4D4CEXyWD3
UVmhWZnMK4bhHQNAv08B
=Xhph
-----END PGP SIGNATURE-----

--Apple-Mail=_A5964627-06DE-4A72-905B-E33EC5D9DFAB--
