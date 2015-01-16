Return-Path: linux-nfs-owner@vger.kernel.org
Received: from chicago.messinet.com ([50.196.241.75]:50388 "EHLO
	chicago.messinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752334AbbAPXRJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Jan 2015 18:17:09 -0500
Received: from localhost (localhost [127.0.0.1])
	by chicago.messinet.com (Postfix) with ESMTP id 4705A67B424F
	for <linux-nfs@vger.kernel.org>; Fri, 16 Jan 2015 17:11:12 -0600 (CST)
Received: from chicago.messinet.com ([127.0.0.1])
	by localhost (chicago.messinet.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id lCGFhPYgBNOd for <linux-nfs@vger.kernel.org>;
	Fri, 16 Jan 2015 17:11:11 -0600 (CST)
Received: from linux-ws1.messinet.com (linux-ws1.messinet.com [IPv6:2001:55c:dc00:0:d6be:d9ff:fe8d:7c1e])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by chicago.messinet.com (Postfix) with ESMTPSA id 633E767B3CCD
	for <linux-nfs@vger.kernel.org>; Fri, 16 Jan 2015 17:11:11 -0600 (CST)
From: Anthony Messina <amessina@messinet.com>
To: linux-nfs@vger.kernel.org
Subject: Re: Secure NFSv4 mounts and daemons
Date: Fri, 16 Jan 2015 17:11:06 -0600
Message-ID: <7292044.Frj4BhIHUy@linux-ws1.messinet.com>
In-Reply-To: <54B6F7C1.5040208@zoho.com>
References: <54B6F7C1.5040208@zoho.com>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1672886.4pOkCUsTVe"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--nextPart1672886.4pOkCUsTVe
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="us-ascii"

On Thursday, January 15, 2015 12:12:01 AM Ralph Zack wrote:
> I have a number of NFSv4 shares which should only be accessible after=

> successful authentication, for which reason they are exported with
> sec=3Dkrb5p. However, this method requires the user to obtain a kerbe=
ros
> ticket to access files on the share, which is fine for regular users =
but
> causes issues for daemons which are not kerberos-aware.
>=20
> What is the common way to handle this problem? It can hardly be the o=
nly
> solution to patch each service to obtain a ticket at startup. Please
> correct me if I'm wrong, but I could not find any mechanism besides
> kerberos that provides encryption and authentication for NFS shares. =
I'd
> be fine with authentication on a host level, I mainly want to ensure
> that only trusted machines can accesses these shares and that all
> traffic is encrypted. Without the overhead of establishing a VPN
> connection between client and server, in case anyone was going to
> suggest that

I use GSS-Proxy for this:
https://fedorahosted.org/gss-proxy/

=2DA

=2D-=20
Anthony - https://messinet.com/ - https://messinet.com/~amessina/galler=
y
8F89 5E72 8DF0 BCF0 10BE 9967 92DC 35DC B001 4A4E

--nextPart1672886.4pOkCUsTVe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEABECAAYFAlS5mo4ACgkQktw13LABSk6p2ACgsGdClba9fmLbsfVUTpjZ/nBV
2lsAn2bpCRy0jdO0U2vzvsSNkdEXlPpL
=vEGC
-----END PGP SIGNATURE-----

--nextPart1672886.4pOkCUsTVe--

