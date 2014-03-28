Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:27356 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756172AbaC1ADu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Mar 2014 20:03:50 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: multipart/signed; boundary="Apple-Mail=_2001E2B5-4572-46FC-8CC9-81734A411BD6"; protocol="application/pgp-signature"; micalg=pgp-sha512
Subject: Announcing the release of fedfs-utils version 0.10.1
Date: Thu, 27 Mar 2014 17:03:09 -0700
Message-Id: <5F7BC3EF-E0B8-4CB9-AE09-5C9913452E2B@oracle.com>
Cc: samba-technical@lists.samba.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        autofs@vger.kernel.org
To: "fedfs-utils;release announcements"
	<fedfs-utils-announce@oss.oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_2001E2B5-4572-46FC-8CC9-81734A411BD6
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


Going forward, stable patches now go into =93master,=94 rather than a =
separate branch.  Development for fedfs-utils 0.11 will be moved to a =
topic branch.

fedfs-utils 0.9 is packaged for EPEL 6 and will continue to see bug =
fixes.


Tarball releases available at:
 http://git.linux-nfs.org/?p=3Dcel/fedfs-releases.git;a=3Dsummary

Git repository available at:
 =
http://git.linux-nfs.org/?p=3Dcel/fedfs-utils.git;a=3Dshortlog;h=3Drefs/he=
ads/master

Patchwork available at:
 http://patchwork.ozlabs.org/project/fedfs-utils/list/

--
Chuck Lever


--Apple-Mail=_2001E2B5-4572-46FC-8CC9-81734A411BD6
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCgAGBQJTNLxHAAoJEKtSGoIDWtn6jEQP/RH/tkfaEu8PINCmFFcG8oSj
tVZdUs7kKmoHOb0Skg//3LWWCiC+PUAO1hvHGZfwJ8t81jZZ2hLxmIbl6UVhrpVc
40NhklNvyszOcKCbnZE2IQLyhk8ypcSU3pwTIn8uK160M1QCOJoy3pKLulAgPx/n
z1PcgzgaEoAz/kD908dFGoIJY5IH47SDSP1fcvxCZp6SEVdGOMGhDL75d3uc3BHJ
/WIicfHgc62wB8E7X/bEfGNqxwcCR4nWpFWO2dQEArWajkOufh+EiPxYWn3jSXBN
RycH7F/qqkC/+FwL3Tbk6CwjVnhV85M/hO4Al2csepNAD7lqF6KruSGR91glkOQY
Szo/SFf0XXACCCmP6jw4GUCSLDEi9xqeEZYUkYrqWCcUBbAwjKsc7/ZCXK+YbfUk
h3FHYIW3S/2SD6DVLmw7+nDgUDQbEq+AibKCnH0s/0GYn2A/RMI+5ijCnBV94JXC
q8xTT0gm/jL84kPwxhwUIw/TbDw0zPeDW8md2H3ruqBiIHO8FKEG+znRj/yzWRu+
liiiCORyloSqLmTQB1XP0hi9v4QlH19TD6Q2gZDc06ljv1ILYQzsUELTmZ8pKq3m
ntQy2YV0sowQPg3IzsOw+/QlvZWdsVNVBcDL93HLSLUtv2oK040VwJKeg/9BKfck
hCPZ1JfohAkPcD3i7QU9
=1ObQ
-----END PGP SIGNATURE-----

--Apple-Mail=_2001E2B5-4572-46FC-8CC9-81734A411BD6--
