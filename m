Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:12268 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752746Ab3KSWec (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Nov 2013 17:34:32 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 3 1/1] NFSv4 wait on recovery for async session
 errors
Date: Tue, 19 Nov 2013 22:34:29 +0000
Message-ID: <1384900469.45997.2.camel@leira.trondhjem.org>
References: <1384551376-8734-1-git-send-email-andros@netapp.com>
	 <1384897797.45997.1.camel@leira.trondhjem.org>
In-Reply-To: <1384897797.45997.1.camel@leira.trondhjem.org>
Content-Type: multipart/mixed;
	boundary="_002_1384900469459972camelleiratrondhjemorg_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_1384900469459972camelleiratrondhjemorg_
Content-Type: text/plain; charset="utf-7"
Content-ID: <C8BAD14AA17571409C453F36F38B032C@hq.netapp.com>
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-11-19 at 16:49 -0500, Trond Myklebust wrote:
+AD4- There is a second patch that goes with this problem. Please see the
+AD4- following attachment.

V2: Don't return an error when we know that the stateid is no longer
valid.

--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

--_002_1384900469459972camelleiratrondhjemorg_
Content-Type: text/x-patch;
	name="0001-NFSv4-Update-list-of-irrecoverable-errors-on-DELEGRE.patch"
Content-Description: 0001-NFSv4-Update-list-of-irrecoverable-errors-on-DELEGRE.patch
Content-Disposition: attachment;
	filename="0001-NFSv4-Update-list-of-irrecoverable-errors-on-DELEGRE.patch";
	size=1505; creation-date="Tue, 19 Nov 2013 22:34:29 GMT";
	modification-date="Tue, 19 Nov 2013 22:34:29 GMT"
Content-ID: <7BD7E4672BA0C54AA42966148440363C@hq.netapp.com>
Content-Transfer-Encoding: base64

RnJvbSBiYTY0YjM2NDljZTMyMzAwNGNjMmJkNzVlNWM5Zjc4NWU2Mzg2Nzc5IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQ0KRnJvbTogVHJvbmQgTXlrbGVidXN0IDxUcm9uZC5NeWtsZWJ1c3RAbmV0
YXBwLmNvbT4NCkRhdGU6IFR1ZSwgMTkgTm92IDIwMTMgMTY6MzQ6MTQgLTA1MDANClN1YmplY3Q6
IFtQQVRDSCB2Ml0gTkZTdjQ6IFVwZGF0ZSBsaXN0IG9mIGlycmVjb3ZlcmFibGUgZXJyb3JzIG9u
IERFTEVHUkVUVVJODQoNCklmIHRoZSBERUxFR1JFVFVSTiBlcnJvcnMgb3V0IHdpdGggc29tZXRo
aW5nIGxpa2UgTkZTNEVSUl9CQURfU1RBVEVJRA0KdGhlbiB0aGVyZSBpcyBubyByZWNvdmVyeSBw
b3NzaWJsZS4gSnVzdCBxdWl0IHdpdGhvdXQgcmV0dXJuaW5nIGFuIGVycm9yLg0KDQpBbHNvLCBu
b3RlIHRoYXQgdGhlIGNsaWVudCBtdXN0IG5vdCBhc3N1bWUgdGhhdCB0aGUgTkZTdjQgbGVhc2Ug
aGFzIGJlZW4NCnJlbmV3ZWQgd2hlbiBpdCBzZWVzIGFuIGVycm9yIG9uIERFTEVHUkVUVVJOLg0K
DQpTaWduZWQtb2ZmLWJ5OiBUcm9uZCBNeWtsZWJ1c3QgPFRyb25kLk15a2xlYnVzdEBuZXRhcHAu
Y29tPg0KQ2M6IHN0YWJsZUB2Z2VyLmtlcm5lbC5vcmcNCi0tLQ0KIGZzL25mcy9uZnM0cHJvYy5j
IHwgMTAgKysrKysrKystLQ0KIDEgZmlsZSBjaGFuZ2VkLCA4IGluc2VydGlvbnMoKyksIDIgZGVs
ZXRpb25zKC0pDQoNCmRpZmYgLS1naXQgYS9mcy9uZnMvbmZzNHByb2MuYyBiL2ZzL25mcy9uZnM0
cHJvYy5jDQppbmRleCAxZjRlZGZiYjRhNzAuLmNhMzZkMGQ1MGI3ZCAxMDA2NDQNCi0tLSBhL2Zz
L25mcy9uZnM0cHJvYy5jDQorKysgYi9mcy9uZnMvbmZzNHByb2MuYw0KQEAgLTQ5ODgsMTEgKzQ5
ODgsMTcgQEAgc3RhdGljIHZvaWQgbmZzNF9kZWxlZ3JldHVybl9kb25lKHN0cnVjdCBycGNfdGFz
ayAqdGFzaywgdm9pZCAqY2FsbGRhdGEpDQogDQogCXRyYWNlX25mczRfZGVsZWdyZXR1cm5fZXhp
dCgmZGF0YS0+YXJncywgJmRhdGEtPnJlcywgdGFzay0+dGtfc3RhdHVzKTsNCiAJc3dpdGNoICh0
YXNrLT50a19zdGF0dXMpIHsNCi0JY2FzZSAtTkZTNEVSUl9TVEFMRV9TVEFURUlEOg0KLQljYXNl
IC1ORlM0RVJSX0VYUElSRUQ6DQogCWNhc2UgMDoNCiAJCXJlbmV3X2xlYXNlKGRhdGEtPnJlcy5z
ZXJ2ZXIsIGRhdGEtPnRpbWVzdGFtcCk7DQogCQlicmVhazsNCisJY2FzZSAtTkZTNEVSUl9BRE1J
Tl9SRVZPS0VEOg0KKwljYXNlIC1ORlM0RVJSX0RFTEVHX1JFVk9LRUQ6DQorCWNhc2UgLU5GUzRF
UlJfQkFEX1NUQVRFSUQ6DQorCWNhc2UgLU5GUzRFUlJfT0xEX1NUQVRFSUQ6DQorCWNhc2UgLU5G
UzRFUlJfU1RBTEVfU1RBVEVJRDoNCisJY2FzZSAtTkZTNEVSUl9FWFBJUkVEOg0KKwkJdGFzay0+
dGtfc3RhdHVzID0gMDsNCisJCWJyZWFrOw0KIAlkZWZhdWx0Og0KIAkJaWYgKG5mczRfYXN5bmNf
aGFuZGxlX2Vycm9yKHRhc2ssIGRhdGEtPnJlcy5zZXJ2ZXIsIE5VTEwpID09DQogCQkJCS1FQUdB
SU4pIHsNCi0tIA0KMS44LjMuMQ0KDQo=

--_002_1384900469459972camelleiratrondhjemorg_--
