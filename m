From: Timo Sirainen <tss@iki.fi>
Subject: inode caching
Date: Mon, 26 May 2008 23:58:19 +0300
Message-ID: <1211835499.3904.231.camel@hurina>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-4B2gwDg/0BEWKYrsYXIB"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dovecot.org ([82.118.211.50]:57260 "EHLO dovecot.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754913AbYEZVZL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 May 2008 17:25:11 -0400
Received: from [192.168.10.2] (xdsl-177-118.nblnetworks.fi [217.30.177.118])
	by dovecot.org (Postfix) with ESMTP id D22E9FA89E7
	for <linux-nfs@vger.kernel.org>; Mon, 26 May 2008 23:58:19 +0300 (EEST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-4B2gwDg/0BEWKYrsYXIB
Content-Type: multipart/mixed; boundary="=-5+d08e2I3C+IGsL+64es"


--=-5+d08e2I3C+IGsL+64es
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

NFS server: Linux 2.6.25
NFS client: Linux debian 2.6.25-2 (or 2.6.23.1)

If I do:

NFS client: fd1 =3D creat("foo"); write(fd1, "xx", 2); fsync(fd1);
NFS server: unlink("foo"); creat("foo");
NFS client: fd2 =3D open("foo"); fstat(fd1, &st1); fstat(fd2, &st2);
fstat(fd1, &st3);

The result is usually that the fstat(fd1) fails with ESTALE. But
sometimes the result is st1.st_ino =3D=3D st2.st_ino =3D=3D st3.st_ino and
st1.st_size =3D=3D 2 but st2.st_size =3D=3D 0. So I see two different files
using the same inode number. I'd really want to avoid seeing that
condition.

So what I'd want to know is:

a) Why does this happen only sometimes? I can't really figure out from
the code what invalidates the fd1 inode. Apparently the second open()
somehow, but since it uses the new "foo" file with a different struct
inode, where does the old struct inode get invalidated?

b) Can this be fixed? Or is it just luck that it works as well as it
does now?

=EF=BB=BFAttached a test program. Usage:

NFS client: Mount with actimeo=3D2
NFS client: ./t
(Run the next two commands within 2 seconds)
NFS server: rm -f foo;touch foo
NFS client: hit enter=20

Once in a while the result will be:
1a: ino=3D15646940 size=3D2
1b: ino=3D15646940 size=3D2
1c: ino=3D15646940 size=3D2
2: ino=3D15646940 size=3D0
1d: ino=3D15646940 size=3D2


--=-5+d08e2I3C+IGsL+64es
Content-Disposition: attachment; filename=t.c
Content-Type: text/x-csrc; name=t.c; charset=ISO-8859-15
Content-Transfer-Encoding: base64

I2luY2x1ZGUgPGVycm5vLmg+DQojaW5jbHVkZSA8c3RyaW5nLmg+DQojaW5jbHVkZSA8dW5pc3Rk
Lmg+DQojaW5jbHVkZSA8ZmNudGwuaD4NCiNpbmNsdWRlIDxzdGRpby5oPg0KI2luY2x1ZGUgPHN5
cy9zdGF0Lmg+DQoNCmludCBtYWluKHZvaWQpIHsNCglzdHJ1Y3Qgc3RhdCBzdDsNCglpbnQgZmQs
IGZkMjsNCgljaGFyIGJ1ZlsxMDBdOw0KDQoJZmQgPSBvcGVuKCJmb28iLCBPX1JEV1IgfCBPX0NS
RUFULCAwNjY2KTsNCgl3cml0ZShmZCwgInh4IiwgMik7IGZzeW5jKGZkKTsNCglpZiAoZnN0YXQo
ZmQsICZzdCkgPCAwKSBwZXJyb3IoImZzdGF0KCkiKTsNCglwcmludGYoIjFhOiBpbm89JWxkIHNp
emU9JWxkXG4iLCAobG9uZylzdC5zdF9pbm8sIHN0LnN0X3NpemUpOw0KDQoJZmdldHMoYnVmLCBz
aXplb2YoYnVmKSwgc3RkaW4pOw0KCWlmIChmc3RhdChmZCwgJnN0KSA8IDApIHBlcnJvcigiZnN0
YXQoKSIpOw0KCWVsc2UgcHJpbnRmKCIxYjogaW5vPSVsZCBzaXplPSVsZFxuIiwgKGxvbmcpc3Qu
c3RfaW5vLCBzdC5zdF9zaXplKTsNCg0KCWZkMiA9IG9wZW4oImZvbyIsIE9fUkRXUik7DQoJaWYg
KGZzdGF0KGZkLCAmc3QpIDwgMCkgcGVycm9yKCJmc3RhdCgpIik7DQoJZWxzZSBwcmludGYoIjFj
OiBpbm89JWxkIHNpemU9JWxkXG4iLCAobG9uZylzdC5zdF9pbm8sIHN0LnN0X3NpemUpOw0KCWlm
IChmc3RhdChmZDIsICZzdCkgPCAwKSBwZXJyb3IoImZzdGF0KCkiKTsNCgllbHNlIHByaW50Zigi
MjogaW5vPSVsZCBzaXplPSVsZFxuIiwgKGxvbmcpc3Quc3RfaW5vLCBzdC5zdF9zaXplKTsNCglp
ZiAoZnN0YXQoZmQsICZzdCkgPCAwKSBwZXJyb3IoImZzdGF0KCkiKTsNCgllbHNlIHByaW50Zigi
MWQ6IGlubz0lbGQgc2l6ZT0lbGRcbiIsIChsb25nKXN0LnN0X2lubywgc3Quc3Rfc2l6ZSk7DQoJ
cmV0dXJuIDA7DQp9DQo=


--=-5+d08e2I3C+IGsL+64es--

--=-4B2gwDg/0BEWKYrsYXIB
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBIOyRryUhSUUBViskRAu9gAJ9YWzsRaNEg/pBCdOyHxKo2BB7X5gCgoj2j
D5hCG0EKpy2XyhLhnHUSuGI=
=gg8O
-----END PGP SIGNATURE-----

--=-4B2gwDg/0BEWKYrsYXIB--

