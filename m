Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:60325 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757647Ab2JKABq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Oct 2012 20:01:46 -0400
Date: Thu, 11 Oct 2012 11:01:56 +1100
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Should "mount -o proto=udp" be usable against an IPv6 only
 server?
Message-ID: <20121011110156.5fdcfd53@notabene.brown>
In-Reply-To: <61E96B57-9545-4DC5-8AAF-BD704EA802D5@oracle.com>
References: <11D4587E-7739-4D31-836D-D63177D13302@oracle.com>
	<20121008143550.68b4aa45@notabene.brown>
	<64BBDA5E-E51C-4DD1-9ECB-41322286C57E@oracle.com>
	<20121009104847.13cceeae@notabene.brown>
	<61E96B57-9545-4DC5-8AAF-BD704EA802D5@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/E_bhjqs_B34ce9na.8a=vYq"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/E_bhjqs_B34ce9na.8a=vYq
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 9 Oct 2012 11:01:32 -0400 Chuck Lever <chuck.lever@oracle.com> wrot=
e:


> > Thanks for your patience.  Sorry I missed the mountproto=3Drdma changes=
 you
> > mentioned earlier - I've fixed that up now, as well as addressing your =
other
> > suggestion.
>=20
> Acked-by: Chuck Lever <chuck.lever@oracle.com>
>=20

Thanks!  I've sent it off to Steve.

NeilBrown

--Sig_/E_bhjqs_B34ce9na.8a=vYq
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUHYMdDnsnt1WYoG5AQKuYA//VEIV1M8rqHWjl4LZar17FBwgajx4vb53
CP5hi/Ov7LMp5y6bIDyOg+Gs3HORGoZn1FfS2/yA8nbz/tqHLLHTCjhwj/ADsk1b
hB+a1YbVFWa6GCZwNg8mgvsNhuzjoAAP8EeuwCH9SUAFwXmTwiuKUMizVIR5O5FE
UIE0rgTBWAfSSs5P4pnCavg+xv7AncrehkRIvpFh2nfknPN8Wt6cb3HuWppypKgP
ASOVad5uxbdgA5CbN7tZJSwEl3GOuj3dWXom5AMj179RcIvcjc44VxPWdbaDuU60
wD5k7Fyg19ls7TvEjQB/B0jStU+iVAPZMcbWUQavR0FoaXOzwPQBmvDNDop1Jjja
2H5aXziJCslbx8kz85XqYrgnt18yu9ZCehvT3uVjPevpvgycCTuXoNkjlKBfW26d
S2noJekjRpQXg056N+Mdx0qHhoNex3TEoNZfOfKhDae1INf+snI/H1qJC9VeD+yH
USckRzBhib7KrDywGe/7jNzsyWQlCVVkHVImhxiaSaVk9riEmYxO874MYkuQG0le
YtkcESIDPcRjiq4A24+QVWkm3JoM7F+DjV27/LT6/jQxsV9C8EBh/naZyxND/x+g
QH/qasKU3pPfhHxqLLGPlh8oH2yawZJdltPk331VSq8aIbneoMEOaYHh7aOJyDZI
JG8cP/DU5Mo=
=aAiA
-----END PGP SIGNATURE-----

--Sig_/E_bhjqs_B34ce9na.8a=vYq--
