Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail1.trendhosting.net ([195.8.117.5]:54970 "EHLO
        mail1.trendhosting.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753460AbcLQTMU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Dec 2016 14:12:20 -0500
Received: from localhost (localhost [127.0.0.1])
        by mail1.trendhosting.net (Postfix) with ESMTP id B3F4F150C7
        for <linux-nfs@vger.kernel.org>; Sat, 17 Dec 2016 19:12:16 +0000 (GMT)
Received: from mail1.trendhosting.net ([127.0.0.1])
        by localhost (thp003.trendhosting.net [127.0.0.1]) (amavisd-new, port 10024)
        with LMTP id Lk7h961Irqrt for <linux-nfs@vger.kernel.org>;
        Sat, 17 Dec 2016 19:12:14 +0000 (GMT)
From: Daniel Pocock <daniel@pocock.pro>
Subject: [PATCH] (revised) nfs-utils: start-statd script using incompatible
 file descriptor
To: linux-nfs@vger.kernel.org
Message-ID: <1d86b6dd-8d63-c66a-0eca-0333873dfdf0@pocock.pro>
Date: Sat, 17 Dec 2016 20:12:10 +0100
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="ScsVTsKBqGHLEvNePTvOra4JjnH5gQ946"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ScsVTsKBqGHLEvNePTvOra4JjnH5gQ946
Content-Type: multipart/mixed;
 boundary="------------4E5341996AF4FC13990D74DC"

This is a multi-part message in MIME format.
--------------4E5341996AF4FC13990D74DC
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



The current script uses fd 200, doesn't work for every possible shell as
reported[1] in Debian bug #848277

We are including a patch for it in the 1.3.4-2 package, it would be good
to incorporate this patch upstream too.

This patch has been revised to include a brief description and
signed-off-by.

Regards,

Daniel


1. https://bugs.debian.org/848277


--------------4E5341996AF4FC13990D74DC
Content-Type: text/x-patch;
 name="29-start-statd-fd-9.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="29-start-statd-fd-9.patch"

POSIX.1-2008 only specifies that file descriptor numbers
from 0 to 9, inclusive, are supported.  The number 200 works
in the bash shell, but not in dash.  This patch changes the file
descriptor number from 200 to 9.  Reported in Debian bug #848277

Signed-off-by: Daniel Pocock <daniel@pocock.pro>
---

diff --git a/utils/statd/start-statd b/utils/statd/start-statd
index 2fd6039..82715b4 100755
--- a/utils/statd/start-statd
+++ b/utils/statd/start-statd
@@ -7,8 +7,8 @@
 PATH=3D"/sbin:/usr/sbin:/bin:/usr/bin"
=20
 # Use flock to serialize the running of this script
-exec 200> /var/run/rpc.statd.lock
-flock -e 200
+exec 9> /var/run/rpc.statd.lock
+flock -e 9
=20
 if [ -s /var/run/rpc.statd.pid ] &&
        [ 1`cat /var/run/rpc.statd.pid` -gt 1 ] &&

--------------4E5341996AF4FC13990D74DC--

--ScsVTsKBqGHLEvNePTvOra4JjnH5gQ946
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYVY4OAAoJEGxlgOd711bEiLEP/1Baaqku+elSOAM4elDvkRib
Q/m1hlmQYKQ0qgdD42c/C3PuYo1X+0aG6K/lugPZkzjHthoN0xSHQbda4DEYmB1H
k66wnnxtcor9YzQl1+t18tFKUCVvV4WsFmFgZljOD2CFe7gzLYA27qrWsoe58wmT
OrWf2J1yTlWiXT1vMdg+/4jDBG/CcgFjKMetICDow0PXlBOdN83oH3ALoVtggvhu
JO4ba0/1UyEtnEk0f8yc0bRA9ATuqr43U7YD/DlW+7wdYZ0zrCgAH/JXeT6nykhB
qLkvfxFbgodpI3sc41ZqpRU+PMmU5VyKRYysUdycFkWJbsVX/qj7vRBHUeeWWBqB
tXQ+vuF839JBGlYf0Q62Yg/iXr3G9bqiH7neMdYcXknhwbh2NNs3A5Lw5ZbPa3fW
cBy3HhOD7823e5D8qCRK3jnWvLVYcuepnKOaD/btSla+KYVY2N8cP0Kckx/jhCuD
S5rKYtuUhJ2bL0wAPn6Oebd2wXePlkjF75LR/TcWqLSNkwOYWOAJ6RWSMH7bn/85
acrkANbBBETclww9JsHlCKe/8/HxD9iQEmpBZz1/3YygcCO6ecGDbGtVhsihIl0T
zqFFP7Hy04oYWRRUvHFvRxcuOM9ct5yqkbZkCTb6uRaJEf3M6Qlh/RXWwsg40E+d
JvDOiZGyH/YiunGYl1kJ
=9f0H
-----END PGP SIGNATURE-----

--ScsVTsKBqGHLEvNePTvOra4JjnH5gQ946--
