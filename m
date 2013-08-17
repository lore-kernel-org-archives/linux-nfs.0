Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:59897 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754409Ab3HQUCC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Aug 2013 16:02:02 -0400
Message-ID: <1376769691.2544.4.camel@deadeye.wl.decadent.org.uk>
Subject: Re: [PATCH] jfs: fix readdir cookie incompatibility with NFSv4
From: Ben Hutchings <ben@decadent.org.uk>
To: Karl Schmidt <karl@xtronics.com>, Jonathan McDowell <noodles@earth.li>
Cc: Dave Kleikamp <dave.kleikamp@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        jfs-discussion@lists.sourceforge.net, 714974@bugs.debian.org,
        linux-nfs@vger.kernel.org, Christian Kujau <lists@nerdbynature.de>
Date: Sat, 17 Aug 2013 22:01:31 +0200
In-Reply-To: <alpine.DEB.2.10.1308151420140.7081@trent.utfs.org>
References: <1373245980.3428.46.camel@deadeye.wl.decadent.org.uk>
	 <520554A5.3060401@xtronics.com>
	 <alpine.DEB.2.10.1308092352550.7081@trent.utfs.org>
	 <alpine.DEB.2.10.1308120113360.7081@trent.utfs.org>
	 <alpine.DEB.2.10.1308120122500.7081@trent.utfs.org>
	 <20130812162924.GB2395@fieldses.org> <520C50F7.3010209@oracle.com>
	 <alpine.DEB.2.10.1308142122550.7081@trent.utfs.org>
	 <alpine.DEB.2.10.1308150001530.7081@trent.utfs.org>
	 <520D3EA7.1010109@oracle.com>
	 <alpine.DEB.2.10.1308151420140.7081@trent.utfs.org>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-N0GdbyaQyS+aU+67diJ7"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-N0GdbyaQyS+aU+67diJ7
Content-Type: multipart/mixed; boundary="=-0h7l+umR75/1W+yhr4V1"


--=-0h7l+umR75/1W+yhr4V1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-08-15 at 14:26 -0700, Christian Kujau wrote:
> On Thu, 15 Aug 2013 at 15:48, Dave Kleikamp wrote:
> > This patch replaces the one I posted yesterday. I like this better sinc=
e
> > it doesn't require fixing existing on-disk cookies or skipping a
> > position in the in-inode index table.
>=20
> Thanks. Applied to 3.11-rc5 and tested, no more "readdir loop" messages=
=20
> and with unique inode numbers, great!
>=20
>   Tested-by: Christian Kujau <lists@nerdbynature.de>

Karl and Jonathan, could you test the attached backport to 3.2?

(Instructions for rebuilding the Debian kernel package are at:
<http://kernel-handbook.alioth.debian.org/ch-common-tasks.html#s-common-off=
icial>)

Ben.

--=20
Ben Hutchings
Teamwork is essential - it allows you to blame someone else.

--=-0h7l+umR75/1W+yhr4V1
Content-Disposition: attachment;
	filename="jfs-fix-readdir-cookie-incompatibility-with-nfsv4-3.2.patch"
Content-Type: text/x-patch;
	name="jfs-fix-readdir-cookie-incompatibility-with-nfsv4-3.2.patch";
	charset="UTF-8"
Content-Transfer-Encoding: base64

RGF0ZTogVGh1LCAxNSBBdWcgMjAxMyAxNTo0ODozOSAtMDUwMA0KRnJvbTogRGF2ZSBLbGVpa2Ft
cCA8ZGF2ZS5rbGVpa2FtcEBvcmFjbGUuY29tPg0KU3ViamVjdDogamZzOiBmaXggcmVhZGRpciBj
b29raWUgaW5jb21wYXRpYmlsaXR5IHdpdGggTkZTdjQNCg0KVGhpcyBwYXRjaCByZXBsYWNlcyB0
aGUgb25lIEkgcG9zdGVkIHllc3RlcmRheS4gSSBsaWtlIHRoaXMgYmV0dGVyIHNpbmNlDQppdCBk
b2Vzbid0IHJlcXVpcmUgZml4aW5nIGV4aXN0aW5nIG9uLWRpc2sgY29va2llcyBvciBza2lwcGlu
ZyBhDQpwb3NpdGlvbiBpbiB0aGUgaW4taW5vZGUgaW5kZXggdGFibGUuDQoNCk5GU3Y0IHJlc2Vy
dmVzIHJlYWRkaXIgY29va2llIHZhbHVlcyAwLTIgZm9yIHNwZWNpYWwgZW50cmllcyAoLiBhbmQg
Li4pLA0KYnV0IGpmcyBhbGxvd3MgYSB2YWx1ZSBvZiAyIGZvciBhIG5vbi1zcGVjaWFsIGVudHJ5
LiBUaGlzIGluY29tcGF0aWJpbGl0eQ0KY2FuIHJlc3VsdCBpbiB0aGUgbmZzIGNsaWVudCByZXBv
cnRpbmcgYSByZWFkZGlyIGxvb3AuDQoNClRoaXMgcGF0Y2ggZG9lc24ndCBjaGFuZ2UgdGhlIHZh
bHVlIHN0b3JlZCBpbnRlcm5hbGx5LCBidXQgYWRkcyBvbmUgdG8NCnRoZSB2YWx1ZSBleHBvc2Vk
IHRvIHRoZSBpdGVyYXRlIG1ldGhvZC4NCg0KU2lnbmVkLW9mZi1ieTogRGF2ZSBLbGVpa2FtcCA8
ZGF2ZS5rbGVpa2FtcEBvcmFjbGUuY29tPg0KW2J3aDogQmFja3BvcnRlZCB0byAzLjI6DQogLSBB
ZGp1c3QgY29udGV4dA0KIC0gcy9jdHgtPnBvcy9maWxwLT5mX3Bvcy9dDQpTaWduZWQtb2ZmLWJ5
OiBCZW4gSHV0Y2hpbmdzIDxiZW5AZGVjYWRlbnQub3JnLnVrPg0KLS0tDQogZnMvamZzL2pmc19k
dHJlZS5jIHwgMzEgKysrKysrKysrKysrKysrKysrKysrKystLS0tLS0tLQ0KIDEgZmlsZSBjaGFu
Z2VkLCAyMyBpbnNlcnRpb25zKCspLCA4IGRlbGV0aW9ucygtKQ0KDQpkaWZmIC0tZ2l0IGEvZnMv
amZzL2pmc19kdHJlZS5jIGIvZnMvamZzL2pmc19kdHJlZS5jDQppbmRleCA4NzQzYmE5Li4wZWM3
NjdlIDEwMDY0NA0KLS0tIGEvZnMvamZzL2pmc19kdHJlZS5jDQorKysgYi9mcy9qZnMvamZzX2R0
cmVlLmMNCkBAIC0zMDQ3LDYgKzMwNDcsMTQgQEAgaW50IGpmc19yZWFkZGlyKHN0cnVjdCBmaWxl
ICpmaWxlLCBzdHJ1Y3QgZGlyX2NvbnRleHQgKmN0eCkNCiANCiAJCWRpcl9pbmRleCA9ICh1MzIp
IGZpbHAtPmZfcG9zOw0KIA0KKwkJLyoNCisJCSAqIE5GU3Y0IHJlc2VydmVzIGNvb2tpZXMgMSBh
bmQgMiBmb3IgLiBhbmQgLi4gc28gd2UgYWRkDQorCQkgKiB0aGUgdmFsdWUgd2UgcmV0dXJuIHRv
IHRoZSB2ZnMgaXMgb25lIGdyZWF0ZXIgdGhhbiB0aGUNCisJCSAqIG9uZSB3ZSB1c2UgaW50ZXJu
YWxseS4NCisJCSAqLw0KKwkJaWYgKGRpcl9pbmRleCkNCisJCQlkaXJfaW5kZXgtLTsNCisNCiAJ
CWlmIChkaXJfaW5kZXggPiAxKSB7DQogCQkJc3RydWN0IGRpcl90YWJsZV9zbG90IGRpcnRhYl9z
bG90Ow0KIA0KQEAgLTMwODYsNyArMzA5NCw3IEBAIGludCBqZnNfcmVhZGRpcihzdHJ1Y3QgZmls
ZSAqZmlsZSwgc3RydWN0IGRpcl9jb250ZXh0ICpjdHgpDQogCQkJaWYgKHAtPmhlYWRlci5mbGFn
ICYgQlRfSU5URVJOQUwpIHsNCiAJCQkJamZzX2VycigiamZzX3JlYWRkaXI6IGJhZCBpbmRleCB0
YWJsZSIpOw0KIAkJCQlEVF9QVVRQQUdFKG1wKTsNCi0JCQkJZmlscC0+Zl9wb3MgPSAtMTsNCisJ
CQkJZmlscC0+Zl9wb3MgPSBESVJFTkQ7DQogCQkJCXJldHVybiAwOw0KIAkJCX0NCiAJCX0gZWxz
ZSB7DQpAQCAtMzA5NCwxNSArMzEwMiwxNSBAQCBpbnQgamZzX3JlYWRkaXIoc3RydWN0IGZpbGUg
KmZpbGUsIHN0cnVjdCBkaXJfY29udGV4dCAqY3R4KQ0KIAkJCQkvKg0KIAkJCQkgKiBzZWxmICIu
Ig0KIAkJCQkgKi8NCi0JCQkJZmlscC0+Zl9wb3MgPSAwOw0KKwkJCQlmaWxwLT5mX3BvcyA9IDE7
DQogCQkJCWlmIChmaWxsZGlyKGRpcmVudCwgIi4iLCAxLCAwLCBpcC0+aV9pbm8sDQogCQkJCQkg
ICAgRFRfRElSKSkNCiAJCQkJCXJldHVybiAwOw0KIAkJCX0NCiAJCQkvKg0KIAkJCSAqIHBhcmVu
dCAiLi4iDQogCQkJICovDQotCQkJZmlscC0+Zl9wb3MgPSAxOw0KKwkJCWZpbHAtPmZfcG9zID0g
MjsNCiAJCQlpZiAoZmlsbGRpcihkaXJlbnQsICIuLiIsIDIsIDEsIFBBUkVOVChpcCksIERUX0RJ
UikpDQogCQkJCXJldHVybiAwOw0KIA0KQEAgLTMxMjMsMjQgKzMxMzEsMjUgQEAgaW50IGpmc19y
ZWFkZGlyKHN0cnVjdCBmaWxlICpmaWxlLCBzdHJ1Y3QgZGlyX2NvbnRleHQgKmN0eCkNCiAJCS8q
DQogCQkgKiBMZWdhY3kgZmlsZXN5c3RlbSAtIE9TLzIgJiBMaW51eCBKRlMgPCAwLjMuNg0KIAkJ
ICoNCi0JCSAqIHBuID0gaW5kZXggPSAwOglGaXJzdCBlbnRyeSAiLiINCi0JCSAqIHBuID0gMDsg
aW5kZXggPSAxOglTZWNvbmQgZW50cnkgIi4uIg0KKwkJICogcG4gPSAwOyBpbmRleCA9IDE6CUZp
cnN0IGVudHJ5ICIuIg0KKwkJICogcG4gPSAwOyBpbmRleCA9IDI6CVNlY29uZCBlbnRyeSAiLi4i
DQogCQkgKiBwbiA+IDA6CQlSZWFsIGVudHJpZXMsIHBuPTEgLT4gbGVmdG1vc3QgcGFnZQ0KIAkJ
ICogcG4gPSBpbmRleCA9IC0xOglObyBtb3JlIGVudHJpZXMNCiAJCSAqLw0KIAkJZHRwb3MgPSBm
aWxwLT5mX3BvczsNCi0JCWlmIChkdHBvcyA9PSAwKSB7DQorCQlpZiAoZHRwb3MgPCAyKSB7DQog
CQkJLyogYnVpbGQgIi4iIGVudHJ5ICovDQogDQorCQkJZmlscC0+Zl9wb3MgPSAxOw0KIAkJCWlm
IChmaWxsZGlyKGRpcmVudCwgIi4iLCAxLCBmaWxwLT5mX3BvcywgaXAtPmlfaW5vLA0KIAkJCQkg
ICAgRFRfRElSKSkNCiAJCQkJcmV0dXJuIDA7DQotCQkJZHRvZmZzZXQtPmluZGV4ID0gMTsNCisJ
CQlkdG9mZnNldC0+aW5kZXggPSAyOw0KIAkJCWZpbHAtPmZfcG9zID0gZHRwb3M7DQogCQl9DQog
DQogCQlpZiAoZHRvZmZzZXQtPnBuID09IDApIHsNCi0JCQlpZiAoZHRvZmZzZXQtPmluZGV4ID09
IDEpIHsNCisJCQlpZiAoZHRvZmZzZXQtPmluZGV4ID09IDIpIHsNCiAJCQkJLyogYnVpbGQgIi4u
IiBlbnRyeSAqLw0KIA0KIAkJCQlpZiAoZmlsbGRpcihkaXJlbnQsICIuLiIsIDIsIGZpbHAtPmZf
cG9zLA0KQEAgLTMyMzMsNiArMzI0MiwxMiBAQCBpbnQgamZzX3JlYWRkaXIoc3RydWN0IGZpbGUg
KmZpbGUsIHN0cnVjdCBkaXJfY29udGV4dCAqY3R4KQ0KIAkJCQkJfQ0KIAkJCQkJamZzX2RpcmVu
dC0+cG9zaXRpb24gPSB1bmlxdWVfcG9zKys7DQogCQkJCX0NCisJCQkJLyoNCisJCQkJICogV2Ug
YWRkIDEgdG8gdGhlIGluZGV4IGJlY2F1c2Ugd2UgbWF5DQorCQkJCSAqIHVzZSBhIHZhbHVlIG9m
IDIgaW50ZXJuYWxseSwgYW5kIE5GU3Y0DQorCQkJCSAqIGRvZXNuJ3QgbGlrZSB0aGF0Lg0KKwkJ
CQkgKi8NCisJCQkJamZzX2RpcmVudC0+cG9zaXRpb24rKzsNCiAJCQl9IGVsc2Ugew0KIAkJCQlq
ZnNfZGlyZW50LT5wb3NpdGlvbiA9IGR0cG9zOw0KIAkJCQlsZW4gPSBtaW4oZF9uYW1sZWZ0LCBE
VExIRFJEQVRBTEVOX0xFR0FDWSk7DQo=


--=-0h7l+umR75/1W+yhr4V1--

--=-N0GdbyaQyS+aU+67diJ7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIVAwUAUg/Wm+e/yOyVhhEJAQr2DxAA1UAahpwKW0TcPiUVsjCdsw6mSeSH8QnF
gBJTaHdYAMVkMbQcYzRL3mZh64k0R7GTqJbJpiV2AKAOpxfmQ8rp39klYKWvzvQd
wdlX1nLzQPfjEOmldWfF3rLUDbz9RniLfa1ntkuwnhMnB4EPvt9phyLCgetmwFD5
m6II/p6hk1Pk7OWpbPothDRRew/9mXQe2umQJ5/d1vyAMFVEnY27hvnsLbv9RMaY
akG9oCss7crV+mKudDdlg2UBuZbQhrZ31flZt6hwNoRjaNs9Y8eYlwN0dXdnKKvT
mjXy3VRkITw4Ry8z2AXedJyP1deTgaBUpmdgQnZMy94gdn+6d2fYs8cVtWJVSEAY
ELRjCcnTQppjo+42yaPgl6WGRcXjLPXitN/GJfJKakoMb2QunTNCmT0i/Xih2Plw
dOgtMzKDP8pj7kv3UPPaHED3S3jQiB/nj0dPVx7x36fLhUX05fNzG5D/T3tuQ2ns
Lp1HD5G+zJvCxxD+H5fK71B4K8n4SRP+1oXtT3MsIwDlc2wdzaB1jmoFP4/eFfW0
Gb1JHryYYv32K2VnZOCj1gxyJSRmPggArJ5XIAXyMnfpnOwHSwqqpR5J6g9S/TjR
eGNS/g/JFFYcyy/7cXZYzSAdqwyQMXWcW3gnqhtkQq7/kCV5FbQ+BBQt/2o0KtBd
9qH3Suy9pCU=
=R5yZ
-----END PGP SIGNATURE-----

--=-N0GdbyaQyS+aU+67diJ7--
