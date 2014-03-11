Return-Path: linux-nfs-owner@vger.kernel.org
Received: from messinet.com ([50.196.241.75]:39234 "EHLO chicago.messinet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752478AbaCKSlz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Mar 2014 14:41:55 -0400
Received: from localhost (localhost [127.0.0.1])
	by chicago.messinet.com (Postfix) with ESMTP id CC37567B4929
	for <linux-nfs@vger.kernel.org>; Tue, 11 Mar 2014 13:41:54 -0500 (CDT)
Received: from chicago.messinet.com ([127.0.0.1])
	by localhost (chicago.messinet.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id XUa5b8Bp3n8G for <linux-nfs@vger.kernel.org>;
	Tue, 11 Mar 2014 13:41:53 -0500 (CDT)
Received: from linux-ws1.messinet.com (unknown [IPv6:2001:470:c1dc:7779:d6be:d9ff:fe8d:7c1e])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by chicago.messinet.com (Postfix) with ESMTPSA id 585F267B4088
	for <linux-nfs@vger.kernel.org>; Tue, 11 Mar 2014 13:41:53 -0500 (CDT)
From: Anthony Messina <amessina@messinet.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Issue with SELinux Labeled NFS
Date: Tue, 11 Mar 2014 13:41:49 -0500
Message-ID: <2308691.6kaIE5X6fN@linux-ws1.messinet.com>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2085065.C1mx0Pn6Ub"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--nextPart2085065.C1mx0Pn6Ub
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="us-ascii"

I've begun testing out the labeled NFSv4.2 features with good success w=
ith=20
only one exception so far.  I have several workstations that use NFSv4.=
2=20
mounted /home directories.  I've been able to remove the SELinux boolea=
n=20
requirement for 'use_nfs_home_dirs', however, on *one* of these worksta=
tions,=20
the /home directory is labeled 'unlabeled_t' after boot when it should =
be=20
labeled with 'home_root_t'.  This problem causes failures, as you can i=
magine.

I mount the filesystem on all of the workstations in the same manner:
# /etc/fstab
...
server.com:/home /home nfs rw,minorversion=3D2,sec=3Dkrb5p,x-systemd.au=
tomount 0 0

Yet the issue occurs on only *one* workstation.  If I manually issue

chcon -t home_root_t /home

then I am able to login and use the system without issue.

All of the servers and workstations are using

kernel-3.13.6-200.fc20.x86_64
nfs-utils-1.2.9-3.0.fc20.x86_64

I realize this is not the SELinux mailing list, but I was wondering if =
anyone=20
had any pointers on how to investigate this issue.  The workstations ar=
e all=20
nearly identical in configuration with the exception of a few user-base=
d=20
differences such as GnuCash on one, but not the other, etc.

Thanks for your guidance.  -A

=2D-=20
Anthony - http://messinet.com - http://messinet.com/~amessina/gallery
8F89 5E72 8DF0 BCF0 10BE 9967 92DC 35DC B001 4A4E

--nextPart2085065.C1mx0Pn6Ub
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iEYEABECAAYFAlMfWPAACgkQktw13LABSk5MvQCfZ5AFXITLljf1gwLzGOr+mq32
oLMAn07sGEWMU1C26V9EMrTBDR8c5fOb
=Ujik
-----END PGP SIGNATURE-----

--nextPart2085065.C1mx0Pn6Ub--

