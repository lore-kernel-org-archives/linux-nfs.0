Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38263 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753854AbbEVDyv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 May 2015 23:54:51 -0400
Date: Fri, 22 May 2015 13:54:42 +1000
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>, Steve Dickson <SteveD@redhat.com>
Cc: libtirpc-devel@lists.sourceforge.net, Thorsten Kukuk <kukuk@suse.de>,
        linux-nfs@vger.kernel.org
Subject: New libtirpc vs fedfs-utils.
Message-ID: <20150522135442.048de45d@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/2XoW5Dlcd+dTYBmz_a_Bxsg"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/2XoW5Dlcd+dTYBmz_a_Bxsg
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



Hi Chuck / Steve,

It seems that fedfs-utils doesn't build with the new libtirpc.

Specifically fedfsd requires symbols

  svcauth_gss_set_svc_name
  svcauth_gss_get_principal

but libtirpc doesn't expose them any longer - it never included them in .h
files or provided documentation.

As far as I can tell fedfs-utils really does need these interfaces, there is
no alternate.
Would it be appropriate to make them "official" with header and doco suppor=
t?

A simple hack is:

--- libtirpc-0.3.0.orig/src/libtirpc.map
+++ libtirpc-0.3.0/src/libtirpc.map
@@ -284,4 +284,6 @@ TIRPC_PRIVATE {
     __libc_clntudp_bufcreate;
   # private, but used by rpcbind:
     __svc_clean_idle; svc_auth_none; libtirpc_set_debug;
+  # private, but used by fedfsd:
+   svcauth_gss_set_svc_name; svcauth_gss_get_principal;
 };


but I suspect something better is really needed.

Are there other server-side routines that need to be exported?

Thanks,
NeilBrown

--Sig_/2XoW5Dlcd+dTYBmz_a_Bxsg
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVV6ogjnsnt1WYoG5AQLjew//dKLeJy84vRYY5XZYPoAyEPQImrgnP0G/
z8iUNohQF2SE1n9GrHSWaOgYvUgXWvB3+WFVSqsTbmTD5yGGeb6vre9J7fkm/hu7
007LO6hnW835LxfGyqt4KRgtJQkuv54Gc8VB2LLydtBQiRoG4cMoxUe9VRsRe0U0
Z/KYAYlFFEMnAfjXR1eE6Retvh78ayWOIN6C9oTx6dZnlGfSz07YZsxAoydlIFPo
b8krGfbcgUPnrxc76vkY9iPRupIahWkPymLPvZ6M6utQKn7pmBSkuBYnZp1BjX8T
FVuSpYoucldvHbuBjJNEjrmN/qBGCzHQZxw4xmj9lX4Ew4p0RJ0c3huQiBqZ5czb
Cq6xi6/NyOSfY/yp1QOeR0uyu0e+yFbp/MryehpCvfP9oxbo/zxW5HCvYepqv659
s28GuIcOHj9Y10Ar7pMHgYofZIOWIQq+22BK6Flxb+Kl8L2C6OwGEOJEgi3T/qiS
XKV6TPGOTFbZy/3w864rlOzCq8MjQugQS9FuGdJfxfH3OvluuSJkree1yXBUC7gh
01KCgcpolJLcT78Stm5RuolzSNV4bB5U7qbhmfCsuGwtldV82eXGtY2gJz5j6Oqk
Lp8T2HSGtifMPBXhZ9JP9W/gVXXfCspkxich3mpxXCLSFx0RM8xc5gBS6uEsGHX0
kuxT+fPUx4o=
=33yh
-----END PGP SIGNATURE-----

--Sig_/2XoW5Dlcd+dTYBmz_a_Bxsg--
