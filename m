Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22754 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758548AbbGHSOe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jul 2015 14:14:34 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: multipart/signed; boundary="Apple-Mail=_65B097AA-9A58-4FC2-A78B-B9E73183A7B5"; protocol="application/pgp-signature"; micalg=pgp-sha512
Subject: Announcing the release of fedfs-utils version 0.10.4
Date: Wed, 8 Jul 2015 14:14:11 -0400
Message-Id: <CE28D97A-7F26-4ED6-B0BE-53F3E988E6F9@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, autofs@vger.kernel.org,
        samba-technical@lists.samba.org
To: "fedfs-utils;release announcements"
	<fedfs-utils-announce@oss.oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_65B097AA-9A58-4FC2-A78B-B9E73183A7B5
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


Changes since 0.10.3:
	=95 Fix bugs in admin tools


Changes since 0.10.2:
	=95 More error handling fixes
	=95 Remove an incorrect package dependency


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


Source code available at:
=
http://git.linux-nfs.org/?p=3Dcel/fedfs-utils.git;a=3Dlog;h=3Drefs/heads/0=
.10-stable

The new head of the 0.10-stable branch is commit:

 da0e25b59275 Release 0.10.4

Patchwork available at:
http://patchwork.ozlabs.org/project/fedfs-utils/list/

Tarball releases available at:
http://git.linux-nfs.org/?p=3Dcel/fedfs-releases.git;a=3Dsummary

--
Chuck Lever


--Apple-Mail=_65B097AA-9A58-4FC2-A78B-B9E73183A7B5
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQIcBAEBCgAGBQJVnWh+AAoJEDNqszNvZn+X6ZcP/A6ugRqlJznVE7O1Sf6RfFlk
TV/ZnTE3RqfVn44a7f81Bo6Nhb+MWTf5lg88DYumgkxhaiek4QdLP/03ff3C7FZO
W+reSOh426xnHQPf8uIR55W6bFkS1WvPtl0h5Doh9f39mr0UXDTQVC/xB+viC2JU
Zphyt9AxpjrBvFN4mrFmy3NbozpDkZorm5FE/hoxyWn0OAZCHvlAG5NL4kph1cl5
ANCaTtTXeHlYr7vKhu0g+tYIZ9DuUC4lbHCBHPXphuUoaNKtOjlzE8/sHsk0vt4r
wAuFDNccTjgjrlMi3RQSewCvXE9KkzJVPmbN4d02iO4PYg7lyQDK03JGN8JPhV5x
bzpU7oW8CS1mdIv8ldZrkMD9OH4T23B06F+KWhaiilCzAYRAXAIkYH+uaPJFaTkB
IvM9EhOmUnHwp5KQkdV9q//pEDkDebTn3L2/DcDwjvNR+vQGDtOvgn4N654CzTP4
+VoRflVL3SvdYPLugWZv2OcKri0vEXLGIDdEjybgtWxI3VIJpRiwsGnSq20yp7HZ
Z2rkPLWzl4T2r1LkFUdjPZ3Kj+prEKk6B55Ab9+nVj/UDMatGJABR0sUuanYgC4a
mDnkhUo8TopfcoQvzJ9LLdVb5NnSzyq678FtFgjMLmlzfIJTx6S1fYkLfpfQJ46Q
feP8dEQw01/Xd3NeE/hL
=v25P
-----END PGP SIGNATURE-----

--Apple-Mail=_65B097AA-9A58-4FC2-A78B-B9E73183A7B5--
