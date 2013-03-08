Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:14541 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759879Ab3CHSdz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Mar 2013 13:33:55 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Dave Chiluk <dave.chiluk@canonical.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 setattr null-terminates strings
Date: Fri, 8 Mar 2013 18:33:52 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9286B6F80@sacexcmbx05-prd.hq.netapp.com>
References: <513A1BD1.6060709@canonical.com>
In-Reply-To: <513A1BD1.6060709@canonical.com>
Content-Type: multipart/mixed;
	boundary="_002_4FA345DA4F4AE44899BD2B03EEEC2FA9286B6F80sacexcmbx05prdh_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA9286B6F80sacexcmbx05prdh_
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <6D0E7787835462428B2DDFF96004DC09@tahoe.netapp.com>
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-03-08 at 11:11 -0600, Dave Chiluk wrote:
> As of commit 57e62324e469e092ecc6c94a7a86fe4bd6ac5172, the SETATTR nfsv4
> command now null terminates fattr_owner and fattr_owner_group.
>=20
> Here is an example excerpt from a tcpdump
> Opcode: SETATTR (34)
>     stateid
>         [StateID Hash: 0xafa9]
>         seqid: 0x00000000
>         Data: 000000000000000000000000
>     obj_attributes
>         attrmask
>             recc_attr: FATTR4_OWNER_GROUP (37)
>                 fattr4_owner_group: groupname@domainname.com
>                     length: 25
>=20
> This means that even though there are actually 24 characters in
> groupname@domainname.com, we now send 24 characters + 1 null character.
> Hence the total length of 25.  Previously the client would send just the
> 24 characters and set length to 24.
>=20
> This isn't an issue for communication with other Linux machines, but it
> is an issue for interaction with AIX machines.  As is discussed here.
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1101292
>=20
> I attempted to read the RFC available here
> http://tools.ietf.org/html/rfc5661, but have not been able to find a
> statement instructing one way or the other.
>=20
> So the question becomes, is it correct for linux to be sending this null
> terminator when read against the RFC, or is it AIX's responsibility to
> handle null-terminated strings?

The client is definitely in error here according to RFC3530. Please
check if the attached patch fixes the issue for you.

Cheers
  Trond
--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA9286B6F80sacexcmbx05prdh_
Content-Type: text/x-patch;
	name="0001-NFSv4-Fix-the-string-length-returned-by-the-idmapper.patch"
Content-Description: 0001-NFSv4-Fix-the-string-length-returned-by-the-idmapper.patch
Content-Disposition: attachment;
	filename="0001-NFSv4-Fix-the-string-length-returned-by-the-idmapper.patch";
	size=2303; creation-date="Fri, 08 Mar 2013 18:33:52 GMT";
	modification-date="Fri, 08 Mar 2013 18:33:52 GMT"
Content-ID: <F048D9D5A6C3D54E8C307A7C9F299117@tahoe.netapp.com>
Content-Transfer-Encoding: base64

RnJvbSA5MGVhYmM1ZGZkZTU4ZGU1YzM3ZGUzODY2ZjQyN2RhMDJlODZjZTE3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQ0KRnJvbTogVHJvbmQgTXlrbGVidXN0IDxUcm9uZC5NeWtsZWJ1c3RAbmV0
YXBwLmNvbT4NCkRhdGU6IEZyaSwgOCBNYXIgMjAxMyAxMjo1NjozNyAtMDUwMA0KU3ViamVjdDog
W1BBVENIXSBORlN2NDogRml4IHRoZSBzdHJpbmcgbGVuZ3RoIHJldHVybmVkIGJ5IHRoZSBpZG1h
cHBlcg0KDQpGdW5jdGlvbnMgbGlrZSBuZnNfbWFwX3VpZF90b19uYW1lKCkgYW5kIG5mc19tYXBf
Z2lkX3RvX2dyb3VwKCkgYXJlDQpleHBlY3RlZCB0byByZXR1cm4gYSBzdHJpbmcgd2l0aG91dCBh
bnkgdGVybWluYXRpbmcgTlVMIGNoYXJhY3Rlci4NClJlZ3Jlc3Npb24gaW50cm9kdWNlZCBieSBj
b21taXQgNTdlNjIzMjRlNDY5ZTA5MmVjYzZjOTRhN2E4NmZlNGJkNmFjNTE3Mg0KKE5GUzogU3Rv
cmUgdGhlIGxlZ2FjeSBpZG1hcHBlciByZXN1bHQgaW4gdGhlIGtleXJpbmcpLg0KDQpSZXBvcnRl
ZC1ieTogRGF2ZSBDaGlsdWsgPGRhdmUuY2hpbHVrQGNhbm9uaWNhbC5jb20+DQpTaWduZWQtb2Zm
LWJ5OiBUcm9uZCBNeWtsZWJ1c3QgPFRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tPg0KQ2M6IEJy
eWFuIFNjaHVtYWtlciA8YmpzY2h1bWFAbmV0YXBwLmNvbT4NCkNjOiBzdGFibGVAdmdlci5rZXJu
ZWwub3JnIFs+PTMuNF0NCi0tLQ0KIGZzL25mcy9pZG1hcC5jIHwgMTMgKysrKysrKystLS0tLQ0K
IDEgZmlsZSBjaGFuZ2VkLCA4IGluc2VydGlvbnMoKyksIDUgZGVsZXRpb25zKC0pDQoNCmRpZmYg
LS1naXQgYS9mcy9uZnMvaWRtYXAuYyBiL2ZzL25mcy9pZG1hcC5jDQppbmRleCBkYzBmOThkLi5j
NTE2ZGE1IDEwMDY0NA0KLS0tIGEvZnMvbmZzL2lkbWFwLmMNCisrKyBiL2ZzL25mcy9pZG1hcC5j
DQpAQCAtNzI2LDkgKzcyNiw5IEBAIG91dDE6DQogCXJldHVybiByZXQ7DQogfQ0KIA0KLXN0YXRp
YyBpbnQgbmZzX2lkbWFwX2luc3RhbnRpYXRlKHN0cnVjdCBrZXkgKmtleSwgc3RydWN0IGtleSAq
YXV0aGtleSwgY2hhciAqZGF0YSkNCitzdGF0aWMgaW50IG5mc19pZG1hcF9pbnN0YW50aWF0ZShz
dHJ1Y3Qga2V5ICprZXksIHN0cnVjdCBrZXkgKmF1dGhrZXksIGNoYXIgKmRhdGEsIHNpemVfdCBk
YXRhbGVuKQ0KIHsNCi0JcmV0dXJuIGtleV9pbnN0YW50aWF0ZV9hbmRfbGluayhrZXksIGRhdGEs
IHN0cmxlbihkYXRhKSArIDEsDQorCXJldHVybiBrZXlfaW5zdGFudGlhdGVfYW5kX2xpbmsoa2V5
LCBkYXRhLCBkYXRhbGVuLA0KIAkJCQkJaWRfcmVzb2x2ZXJfY2FjaGUtPnRocmVhZF9rZXlyaW5n
LA0KIAkJCQkJYXV0aGtleSk7DQogfQ0KQEAgLTczOCw2ICs3MzgsNyBAQCBzdGF0aWMgaW50IG5m
c19pZG1hcF9yZWFkX2FuZF92ZXJpZnlfbWVzc2FnZShzdHJ1Y3QgaWRtYXBfbXNnICppbSwNCiAJ
CXN0cnVjdCBrZXkgKmtleSwgc3RydWN0IGtleSAqYXV0aGtleSkNCiB7DQogCWNoYXIgaWRfc3Ry
W05GU19VSU5UX01BWExFTl07DQorCXNpemVfdCBsZW47DQogCWludCByZXQgPSAtRU5PS0VZOw0K
IA0KIAkvKiByZXQgPSAtRU5PS0VZICovDQpAQCAtNzQ3LDEzICs3NDgsMTUgQEAgc3RhdGljIGlu
dCBuZnNfaWRtYXBfcmVhZF9hbmRfdmVyaWZ5X21lc3NhZ2Uoc3RydWN0IGlkbWFwX21zZyAqaW0s
DQogCWNhc2UgSURNQVBfQ09OVl9OQU1FVE9JRDoNCiAJCWlmIChzdHJjbXAodXBjYWxsLT5pbV9u
YW1lLCBpbS0+aW1fbmFtZSkgIT0gMCkNCiAJCQlicmVhazsNCi0JCXNwcmludGYoaWRfc3RyLCAi
JWQiLCBpbS0+aW1faWQpOw0KLQkJcmV0ID0gbmZzX2lkbWFwX2luc3RhbnRpYXRlKGtleSwgYXV0
aGtleSwgaWRfc3RyKTsNCisJCS8qIE5vdGU6IGhlcmUgd2Ugc3RvcmUgdGhlIE5VTCB0ZXJtaW5h
dG9yIHRvbyAqLw0KKwkJbGVuID0gc3ByaW50ZihpZF9zdHIsICIlZCIsIGltLT5pbV9pZCkgKyAx
Ow0KKwkJcmV0ID0gbmZzX2lkbWFwX2luc3RhbnRpYXRlKGtleSwgYXV0aGtleSwgaWRfc3RyLCBs
ZW4pOw0KIAkJYnJlYWs7DQogCWNhc2UgSURNQVBfQ09OVl9JRFRPTkFNRToNCiAJCWlmICh1cGNh
bGwtPmltX2lkICE9IGltLT5pbV9pZCkNCiAJCQlicmVhazsNCi0JCXJldCA9IG5mc19pZG1hcF9p
bnN0YW50aWF0ZShrZXksIGF1dGhrZXksIGltLT5pbV9uYW1lKTsNCisJCWxlbiA9IHN0cmxlbihp
bS0+aW1fbmFtZSk7DQorCQlyZXQgPSBuZnNfaWRtYXBfaW5zdGFudGlhdGUoa2V5LCBhdXRoa2V5
LCBpbS0+aW1fbmFtZSwgbGVuKTsNCiAJCWJyZWFrOw0KIAlkZWZhdWx0Og0KIAkJcmV0ID0gLUVJ
TlZBTDsNCi0tIA0KMS44LjEuNA0KDQo=

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA9286B6F80sacexcmbx05prdh_--
