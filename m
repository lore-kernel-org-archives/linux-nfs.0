From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: RFC: merging sm-notify and rpc.statd
Date: Tue, 19 May 2009 19:25:37 -0400
Message-ID: <200905191925.38902.vapier@gentoo.org>
References: <E9DE1ACD-4C9D-43F8-9B00-28CE536BFDBD@oracle.com> <18963.13619.563465.804193@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart113000138.cZnfA3kmyh";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:34998 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753707AbZESXZi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 May 2009 19:25:38 -0400
In-Reply-To: <18963.13619.563465.804193-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--nextPart113000138.cZnfA3kmyh
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 19 May 2009 18:39:47 Neil Brown wrote:
> sm-notify :
>    - is a 'client' for the "SM" protocol.
>    - must be run at boot time, and after that is not needed.
>
> statd :
>    - is a 'server' for the "SM" protocol.
>    - only needs to be running when either nfsd is running or an
>      nfs mount which supports locks is active

that last part -- any nfs mount with locks -- means that pretty much every =
nfs=20
client out there needs it running.

sm-notify is pretty minuscule, so the overhead of having that run on a serv=
er=20
is negligible, especially when combined with the already required statd.
=2Dmike

--nextPart113000138.cZnfA3kmyh
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iQIcBAABAgAGBQJKEz/yAAoJEEFjO5/oN/WBdvgP/1/kxIm15Xut9Ck9sZIbHRq0
qX1OPRnkQNKq7s59YTkKagr1eQelHwroMv02wKJUpCs0HVaIpiyCEqVL3I49Femm
0PQ8udjqpIoEa5Y5bZNCvpYGtPK6dFbrQKU9pFyiuSw9OAYRHM6FmSRaIOO93sw4
104MN5PLShI2tINl9DynfqqJv+X2XiwMsmvBk4mhXQaiRuM7yphIzoeEMN3Fo88p
lKPb4fpjUc5KW4KPVAJ8WQkj9PicVnBplDBezRFRC/xxzSYrW0kOnPPNh8qm2Qz8
n1/R/YuzInNY54ENAnP3wzK1MX2H8pR+2jxOBTpIY/jFtsouZkpgp/wc3jX7ouAw
1U6qeG/C18an23h+XEqdjfElS5Hj/NUO9xBX9ZeNG7rBPmuwuXPt25IrzAenxdZR
qMA06KsbsrxXCnMMBoTcXhZk1nt75k63pnCnsEflerLl6HalUuaUKYvZaJ6hBCrz
1bmn1tlNa28NPBW0sN0+HJgKExysh64U2Q6zye5PkrmY3ASn+MlMW//l+zcWXWY/
1R5C0X2OyNF0jOYGSs5wzAU2q0C8WbnYhl5c2odbO6RvQAizSCZIfPg0b/z3Kp/+
ei2wehxwIlzivjlRfh/D1usJQhzgiCkUFYsFe5QIjxTemdXpsRLec9anY2UO0v5F
uF9A3eZLvQQ54SUuw6mF
=HzZB
-----END PGP SIGNATURE-----

--nextPart113000138.cZnfA3kmyh--
