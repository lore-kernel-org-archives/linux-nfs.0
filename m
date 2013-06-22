Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:48674 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087Ab3FVO7b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Jun 2013 10:59:31 -0400
Received: by mail-ie0-f177.google.com with SMTP id aq17so21686179iec.36
        for <linux-nfs@vger.kernel.org>; Sat, 22 Jun 2013 07:59:31 -0700 (PDT)
Received: from [192.168.101.102] ([199.180.99.112])
        by mx.google.com with ESMTPSA id yt6sm3759232igb.2.2013.06.22.07.59.29
        for <linux-nfs@vger.kernel.org>
        (version=SSLv3 cipher=RC4-SHA bits=128/128);
        Sat, 22 Jun 2013 07:59:30 -0700 (PDT)
Message-ID: <1371913167.28295.8.camel@freed.purpleidea.com>
Subject: NFS clientaddr, kerberos
From: James <purpleidea@gmail.com>
To: linux-nfs@vger.kernel.org
Date: Sat, 22 Jun 2013 10:59:27 -0400
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-0ZH0M6nFpz5JPEDYMD5j"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-0ZH0M6nFpz5JPEDYMD5j
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Dear NFS experts, I have a few questions:

1) Concerning the NFSv4 clientaddr option, I'm curious about the
technical details of why the server needs a callback address, and what
to do if the client isn't directly routable? (eg: behind NAT) I am
thinking of the situation with *many* clients.

Also, what ports need to be open on the client? Does it need to respond
to "NEW" traffic, or only "ESTABLISHED" or ?

2) In /etc/exports, for an NFSv4 export, you often see docs suggesting:
sec=3Dsys,krb5,krb5i,krb5p OR the same but without the 'sys' part. If you
instead do 'sec=3Dkrb5p' will this *force* clients to use full encryption
and authentication, and deny those who try to mount without sec=3Dkrb5p ?
In particular, if a client tries to mount with sec=3Dkrb5i, what should
happen? For some reason I haven't seen anyone just use 'sec=3Dkrb5p' and I
wanted to know what was up.

Thank you in advance,
James


--=-0ZH0M6nFpz5JPEDYMD5j
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABAgAGBQJRxbvPAAoJEKDo88AkCQ1mYboP/RCJXlPxdWFGsudpinz35Vui
KJaPub9De8HmIdMNz/+Kt5baAmN6lDbfVCNQfWXKPea22FxIGSQqtxjkFZfQiAm8
+nGgI7ntyUFoHrOdi76yW+eiHCX9tCrEq7gBNFnErNQJh2ig/0GBgYRs+dEp4JUS
3RtfILIdRVnl1Av0fFwkTYFji4eXzKXZNQxU/8HwaA+guMS7owj9IS1gvb7IafeW
dsqmxfTEf6N2tNCbmpqqFFNniWOCT5Qgoi6wuIQK/KZMTJYrI4tptYzUxD+2P2jT
K2mMuw04xUMyyH966775zeoTaumxFF9YXvVHWhWLRSzITuaXhBl56tY9QOV28T8o
2bEW2FO4w2i531NlSGIVJEHC6rYns4eGrnzdPUm7o4ph4VDms3/mLsvL9Uzyooqa
+qbJRPBQCsL0+p8pm7OTdsMsePFmAHJop2Wx9HRo13L3bZtcpJDzmhLUlvhsuWlT
nz1NS4XtmC2lBQ7tg5YPw/NwIhdBdH53pgBGFszySzownEcN1cRB1cYyaeYKF7r8
ADfPgjgxqpWame7DC3n5gjKlwPu2vPK4CsGRgghls8SgJHlnRgz7ntlSYcq0M/Ho
Ybl39sCkEEGAnhHg2LMUZ3uH4BuaoCW+PCPV50z2v+QzNcR1xTxOIRIGNKdU70Sw
jyaltpJBNrLDvUs3ren4
=/CVR
-----END PGP SIGNATURE-----

--=-0ZH0M6nFpz5JPEDYMD5j--

