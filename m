Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:20792 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754486AbaAFRMY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jan 2014 12:12:24 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: multipart/signed; boundary="Apple-Mail=_44E88D8B-7922-48C4-9AF6-DCE8132B035D"; protocol="application/pgp-signature"; micalg=pgp-sha512
Subject: [LSF/MM ATTEND] and possible topics
Date: Mon, 6 Jan 2014 12:12:11 -0500
Message-Id: <51F7F955-FD75-4131-BDA4-D6422110EA42@oracle.com>
Cc: James Morris <james.l.morris@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: lsf-pc@lists.linux-foundation.org
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_44E88D8B-7922-48C4-9AF6-DCE8132B035D
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Hi-

I would like to attend the 2014 Linux Storage, Filesystem and Memory =
Management Summit.

Since 2001 I've worked on various features of the Linux NFS =
implementation.  Oracle's use of NFS on Infiniband fabrics in its =
engineered solutions is a leading edge use of Linux NFS.  I'm interested =
in improving upstream support for NFS/RDMA and learning about next steps =
for the Linux direct-data-placement ecosystem.

I'm the key developer of FedFS on Linux and the current editor of the =
IETF FedFS proposed standards.  FedFS provides a standard way to create =
a network file namespace that crosses server and share boundaries =
(similar to autofs).  I'm interested in discussing potential common =
administrative interfaces, security issues, storage of namespace =
junction objects in Linux's physical filesystems, and FedFS support for =
CIFS/SMB.

I'm working with Martin Petersen and the IETF NFSv4 Working Group to =
integrate support for end-to-end data integrity into the NFS protocol =
[1], similar to T10's DIF but more oriented towards byte-streams.  I'm =
interested in hearing about progress with Linux implementations of =
end-to-end data integrity (DIF/DIX, filesystem metadata checksumming, =
etc).

--=20
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

[1] =
https://datatracker.ietf.org/doc/draft-cel-nfsv4-end2end-data-protection/


--Apple-Mail=_44E88D8B-7922-48C4-9AF6-DCE8132B035D
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCgAGBQJSyuPyAAoJEKtSGoIDWtn6wpwQAKsrhJRLfNAE3g8+7rpJ1UCc
MEWqfzx9vKzw5LN/wQquhvofrA22dKRcRNSsMNy8Usv3wjqFWcBmvyHBSk1nOkTD
9jB7CgnGaf8PFQZNhTrUDCv9VBvoxATU6SyKPHhiqrHkoaDT26i0s2msjP/g6iLg
6UpEMiJu38cpwvM/ZWKBIMU2STwBKMLLTHOnpql8n6gZnJfZBQFpVgHj9SY9w5gN
STYT3PHVy5S0cQJbqyZSOV92pEkuPp/UdtbW+71+07hk6HsaHTPLVKx2SHkaw+wp
Xr4qtk0gkSjys9LMFPcPUE44Q81/o+mGEcR/jznAPRjkDIOrThJhw5lfB6dMj5n4
bd4Mpgqz725XXeutpm8DEz+JHf5ebll7SLzULmFE+HwfNLLbMPMsX/vc9LtP6trg
K+eFGEy+golqPOIWAKcekG5o+XnNW5CXddXZICkkdADK+Z6ygr2szMS8iFc3cyBQ
xw7M4dfQ4GxxoVlDveFYFWqe5Cjs11ugYbBlPv+lDJ5une+q6+Sv2NLtBYjbmhEN
Hd2bUNAgMsD+E4L+nuBwDFwmI0gDmqzawMtDkpsZWMqXcQHWMED2hdsQNE9NHHeT
9HQWmAEEPAxYNTc+JX0NyJt7rtlIr2Ayemh8Po7FCdkClhhIlTmRVU4lOGE3zI07
JH2QP9xTq6Ah4Rl8G6W6
=hI6d
-----END PGP SIGNATURE-----

--Apple-Mail=_44E88D8B-7922-48C4-9AF6-DCE8132B035D--
