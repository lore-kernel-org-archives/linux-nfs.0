Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.aixigo.de ([5.145.142.10]:8090 "EHLO mail.aixigo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755105AbbHKHJv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Aug 2015 03:09:51 -0400
Received: from srvvm01.ac.aixigo.de (mail.ac.aixigo.de [172.19.96.11]);
	by gate5a.ac.aixigo.de (OpenSMTPD) with ESMTPS id e8e57398;
	TLS version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO;
	for <linux-nfs@vger.kernel.org>;
	Tue, 11 Aug 2015 09:09:49 +0200 (CEST)
Date: Tue, 11 Aug 2015 09:09:49 +0200
From: Harald Dunkel <harald.dunkel@aixigo.de>
To: linux-nfs@vger.kernel.org
Subject: Re: Debian kernel: "Server nfs-home reports our clientid is in use"
Message-ID: <20150811090949.5f1a2594@dpcl082.ac.aixigo.de>
In-Reply-To: <55C3016A.9000509@aixigo.de>
References: <55C3016A.9000509@aixigo.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/uS7A/yflB4oBXFZNH2_Pv11"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/uS7A/yflB4oBXFZNH2_Pv11
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

PS:

/sys/module/nfs/parameters/nfs4_unique_id returns just an=20
empty string. I would have expected the hostname or a=20
similar string here, according to Documentation/filesystems/\
nfs/nfs.txt .=20

I am absolutely sure that there are no duplicate host names in=20
my net. The IP addresses are fixed, too. Nevertheless, to=20
avoid problems I have changed my setup procedure to set=20
nfs.nfs4_unique_id in grub, as suggested.

I am still hoping for valuable feedback


Regards
Harri

--Sig_/uS7A/yflB4oBXFZNH2_Pv11
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlXJn70ACgkQhMIDFeRJhsuMXgCgpjIRlfke/m4oSJtBjyktJgKH
ovkAoImtd/6nN4sm53Nm/wu1ydk4tG7f
=MaZq
-----END PGP SIGNATURE-----

--Sig_/uS7A/yflB4oBXFZNH2_Pv11--
