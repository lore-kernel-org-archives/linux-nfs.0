Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:46256 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615AbaE0PNj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 May 2014 11:13:39 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: multipart/signed; boundary="Apple-Mail=_CE5C87DD-84BF-485A-A836-6D0B1E93BA33"; protocol="application/pgp-signature"; micalg=pgp-sha512
Subject: Announcing the release of fedfs-utils version 0.10.2
Date: Tue, 27 May 2014 11:13:01 -0400
Message-Id: <E673796A-8155-4FD1-A513-B6E9799D682B@oracle.com>
Cc: samba-technical@lists.samba.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        autofs@vger.kernel.org
To: "fedfs-utils;release announcements"
	<fedfs-utils-announce@oss.oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_CE5C87DD-84BF-485A-A836-6D0B1E93BA33
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

This package contains an implementation of the Federated Filesystem
(FedFS) Proposed Standard for Linux. For an introduction to FedFS, see
RFC 5716.

This is an ALPHA quality release.  The code in this release is not
guaranteed to work.  Programming, administrative, and user interfaces
may change significantly before the next release.  This release is for
technology preview only.


Changes since 0.10.1:
	=95 Fix bugs in nsdb-jumpstart
	=95 Numerous fixes to error handling paths
	=95 Introduce basic support for Coverity analysis


Changes since 0.10.0:
	=95 Address packaging issues


New with fedfs-utils 0.10.0:

Non-backwards compatible changes:
	=95 *ldaperr removed from libnsdb API
	=95 ADMIN client tools no longer use AUTH_NONE security
	=95 ADMIN client tools no longer exit with FedFS status code

New features:
	=95 Python package PyFedfs added
	=95 Tool for configuring FedFS domain root directories
	=95 Tool for setting up NSDBs using OpenLDAP
	=95 Simpler NCE discovery (compliant with new FedFS NCE I-D)
	=95 admin_t API for performing remote ADMIN requests
	=95 rpc.fedfsd uses an ACL to control who can perform ADMIN =
requests
	=95 rpc.fedfsd and ADMIN tools support RPCSEC and Kerberos v5

Minor fixes:
	=95 FEDFS_LOOKUP_JUNCTION no longer returns NSDB_LDAP_VAL
	=95 fedfs-map-nfs4 handles multiple SRV records
	=95 Packaging simplifications
	=95 Dozens of code clean-ups and bug fixes; consult Changelog =
for details


Git repository available at:
=
http://git.linux-nfs.org/?p=3Dcel/fedfs-utils.git;a=3Dshortlog;h=3Drefs/he=
ads/master

The new head of the master branch is commit:

94a8179d Release 0.10.2

Patchwork available at:
http://patchwork.ozlabs.org/project/fedfs-utils/list/

Tarball releases available at:
http://git.linux-nfs.org/?p=3Dcel/fedfs-releases.git;a=3Dsummary

--
Chuck Lever


--Apple-Mail=_CE5C87DD-84BF-485A-A836-6D0B1E93BA33
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCgAGBQJThKuJAAoJEDNqszNvZn+XPl4P/RVp8FGlOxCaUkfz35IXjZBv
4T+qiOXOmx7/SoZTMDoiublJ78RJtX5KUAUMGNEDeRz/O+b542MJ8A8LTrjbGKVn
f8UDtJmnA6vGY1S76ho5mVhFSYC7CphlbxE1OZbdN3xkirOQphnCyrapYcSZpH4+
Rlo99U3k4wxc0t5WxorlxXvFIwnWeMP6L5374kT93wj4/C3vb9SbWvrQfDPzqh40
ZrPfCabyD0OvOuG4SPS9B509CR7gWBSwKLbtGkEpPOShFsWSa+Ot7VjDJZcuteKO
Nm4PXaBOTrCWGdHSK/K5H0JylFe+gDq87vouGSE8+fjrah1AF5tE8651lAf3tu7v
XKckCAvkWLFOGkDCNIphPncEtJLj+lIGHpFt9LSn8U737hAi/YMDHkEt4BIarJTP
Gs2470WD8dGLG4fgIlSVTwQzjt7/RfTr+YBDoSu80tCdXPrkFBy+KJ3V/Q5UNuWb
DC1H2kpyInltS4i80wrfdopRpjjLR0vEbHRSmVgGKTpFnGU3lyPgAuVgLXpmK8Tm
ZOyzZH0Lcjlf1t1/zWcYvSlpsPPovWSsid3hk/CFx6paWCb9/m5MqTRw5qE3dhZZ
5rDLDAHL+AsoNhWHFh0TMhNSANQsi28fxM9QwsoNy9rM+rFRhRYQ9+9v6Wk4PaXE
iFaejYYq/mGFZ0z0iKjx
=TY/1
-----END PGP SIGNATURE-----

--Apple-Mail=_CE5C87DD-84BF-485A-A836-6D0B1E93BA33--
