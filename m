Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:44359 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbaGFQJp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Jul 2014 12:09:45 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: multipart/signed; boundary="Apple-Mail=_C0B953FC-AA6C-4747-8114-9F8C2AE640F5"; protocol="application/pgp-signature"; micalg=pgp-sha512
Subject: Announcing the release of fedfs-utils version 0.10.3
Date: Sun, 6 Jul 2014 12:09:10 -0400
Message-Id: <B58F990E-01CC-4449-8665-19A1A29BCD04@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, autofs@vger.kernel.org,
        samba-technical@lists.samba.org
To: "fedfs-utils;release announcements"
	<fedfs-utils-announce@oss.oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_C0B953FC-AA6C-4747-8114-9F8C2AE640F5
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


Git repository available at:
=
http://git.linux-nfs.org/?p=3Dcel/fedfs-utils.git;a=3Dshortlog;h=3Drefs/he=
ads/master

The new head of the master branch is commit:

  cb9f4319 Release 0.10.3

Patchwork available at:
http://patchwork.ozlabs.org/project/fedfs-utils/list/

Tarball releases available at:
http://git.linux-nfs.org/?p=3Dcel/fedfs-releases.git;a=3Dsummary

--
Chuck Lever


--Apple-Mail=_C0B953FC-AA6C-4747-8114-9F8C2AE640F5
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCgAGBQJTuXStAAoJEDNqszNvZn+XSdIP/iVymDd++Lw+C2NJbRe0cm7C
Hmx6ZUZmeOfkj+pfIppJ05or56uvAeBnB6O49WTKHrKLroBaLZfWNM8RfLgiceKM
GevWMIyG8hofpuMA+UXMlHUctGchzo9wdwG3yd26VRTJjb/0OP5mBIG8w2V1nIcK
EpySrFsU4L5/vLfuZ9ZunXQPTwV+kb3a1a8R04hBOAF0E/87Idd1bHHA8u/0vzbH
Irj2vB8B5W3dhsf02LvdXObJuuCFT/wtQAuB6aHWvppNQNRvii8PtltuJd36lvKj
Xcoemmvg9/hIbQUw+DDCTv6xvJTKlf4N0ZiE0yD0Ubiiic9rlAr5/wEL5RwdW5Gm
IdHVT1tXdAh6cT7UTGTUyMZ+ABdemr3VwywjM7kNr+KFooOyi06Ss4dlLMRVcuWx
tfYo2/o4EQ0wmusxvR8vUWEsa96df2F/+iX9GP8t9eRnJX/JP9HX7p/EmrnPpw08
D5FXyXxKM7fbMNkWqAicqxDZQ6xdHCTDpyVfR+VL+A+2efr1Q34/T46lsCURmxHy
X104XBTEdHiY8OuhYgXqjOB/I1QsIZOA6R1BxtFdjscwWDyb8RjScjogD/eY+Qt+
3V53AU3cH7k8IHvmacs2TFojZY+MrOMVOxj+YhzZK1Q9jV8BHOLtqNylCcAAl+Sf
AD3wFCkqIZx/PviPIbH6
=Ci2+
-----END PGP SIGNATURE-----

--Apple-Mail=_C0B953FC-AA6C-4747-8114-9F8C2AE640F5--
