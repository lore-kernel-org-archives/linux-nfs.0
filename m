Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:12878 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933272Ab3GWRAq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Jul 2013 13:00:46 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Andre Heider <a.heider@gmail.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Rick Macklem <rmacklem@uoguelph.ca>
Subject: Re: [PATCH 2/2] NFSv4: encode_attrs should not backfill the bitmap
 and attribute length
Date: Tue, 23 Jul 2013 17:00:46 +0000
Message-ID: <1374598847.12943.0.camel@leira.trondhjem.org>
References: <1374098347-30196-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1374098347-30196-2-git-send-email-Trond.Myklebust@netapp.com>
	 <CAHsu+b-b=-pQ4f8AfHHDaPpAK3YvHomS3X-QuEJkzbAsuJBYfg@mail.gmail.com>
In-Reply-To: <CAHsu+b-b=-pQ4f8AfHHDaPpAK3YvHomS3X-QuEJkzbAsuJBYfg@mail.gmail.com>
Content-Type: multipart/mixed;
	boundary="_002_1374598847129430camelleiratrondhjemorg_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_1374598847129430camelleiratrondhjemorg_
Content-Type: text/plain; charset="utf-8"
Content-ID: <0684017A53A9F34DA8C9EDA4274D8F0A@hq.netapp.com>
Content-Transfer-Encoding: base64

T24gVHVlLCAyMDEzLTA3LTIzIGF0IDE3OjU5ICswMjAwLCBBbmRyZSBIZWlkZXIgd3JvdGU6DQo+
IFRyb25kLA0KPiANCj4gT24gV2VkLCBKdWwgMTcsIDIwMTMgYXQgMTE6NTkgUE0sIFRyb25kIE15
a2xlYnVzdA0KPiA8VHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20+IHdyb3RlOg0KPiA+IFRoZSBh
dHRyaWJ1dGUgbGVuZ3RoIGlzIGFscmVhZHkgY2FsY3VsYXRlZCBpbiBhZHZhbmNlLiBUaGVyZSBp
cyBubw0KPiA+IHJlYXNvbiB3aHkgd2UgY2Fubm90IGNhbGN1bGF0ZSB0aGUgYml0bWFwIGluIGFk
dmFuY2UgdG9vIHNvIHRoYXQNCj4gPiB3ZSBkb24ndCBoYXZlIHRvIHBsYXkgcG9pbnRlciBnYW1l
cy4NCj4gDQo+IEknbSBzb3JyeSB0byByZXBvcnQgdGhhdCB0aGlzIHBhdGNoIHNlZW1zIHRvIGJl
IG1vcmUgdGhhbiBqdXN0IGEgY2xlYW51cC4NCj4gDQo+IEkganVzdCB0ZXN0ZWQgMy4xMS1yYzIg
YWdhaW5zdCBteSBGcmVlQlNEIHNlcnZlciwgYW5kIHdpdGgganVzdCBwYXRjaA0KPiAxLzIgKGFz
IGluIC1yYzIpIEkgc3RpbGwgZ2V0IHRoZSBmYWlsdXJlIHVwb24gYHRvdWNoYC4gSXQgZmFpbHMg
d2l0aA0KPiBvciB3aXRob3V0IFJpY2sncyBzZXJ2ZXIgcGF0Y2guDQo+IA0KPiBBcHBseWluZyB0
aGlzIG9uZSBvbiB0b3Agb2YgLXJjMiBmaXhlcyBpdC4NCg0KSG93IGFib3V0IHRoZSBhdHRhY2hl
ZCBpbnN0ZWFkIG9mIHRoZSBjbGVhbnVwPw0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXgg
TkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5j
b20NCnd3dy5uZXRhcHAuY29tDQo=

--_002_1374598847129430camelleiratrondhjemorg_
Content-Type: text/x-patch;
	name="0001-NFSv4-Fix-brainfart-in-attribute-length-calculation.patch"
Content-Description: 0001-NFSv4-Fix-brainfart-in-attribute-length-calculation.patch
Content-Disposition: attachment;
	filename="0001-NFSv4-Fix-brainfart-in-attribute-length-calculation.patch";
	size=963; creation-date="Tue, 23 Jul 2013 17:00:45 GMT";
	modification-date="Tue, 23 Jul 2013 17:00:45 GMT"
Content-ID: <CD78C33E93C20442BC8FF577A0CB0300@hq.netapp.com>
Content-Transfer-Encoding: base64

RnJvbSBiZDAwYTIzYmJhOTFmNTRhYjQ1ZTg3ODhhODMwNjczM2Q4Y2EzMDYyIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQ0KRnJvbTogVHJvbmQgTXlrbGVidXN0IDxUcm9uZC5NeWtsZWJ1c3RAbmV0
YXBwLmNvbT4NCkRhdGU6IFR1ZSwgMjMgSnVsIDIwMTMgMTI6NTM6MzkgLTA0MDANClN1YmplY3Q6
IFtQQVRDSF0gTkZTdjQ6IEZpeCBicmFpbmZhcnQgaW4gYXR0cmlidXRlIGxlbmd0aCBjYWxjdWxh
dGlvbg0KDQpUaGUgY2FsY3VsYXRpb24gb2YgdGhlIGF0dHJpYnV0ZSBsZW5ndGggd2FzIDQgYnl0
ZXMgb2ZmLg0KDQpTaWduZWQtb2ZmLWJ5OiBUcm9uZCBNeWtsZWJ1c3QgPFRyb25kLk15a2xlYnVz
dEBuZXRhcHAuY29tPg0KLS0tDQogZnMvbmZzL25mczR4ZHIuYyB8IDIgKy0NCiAxIGZpbGUgY2hh
bmdlZCwgMSBpbnNlcnRpb24oKyksIDEgZGVsZXRpb24oLSkNCg0KZGlmZiAtLWdpdCBhL2ZzL25m
cy9uZnM0eGRyLmMgYi9mcy9uZnMvbmZzNHhkci5jDQppbmRleCBjNzRkNjE2Li4zODUwYjAxIDEw
MDY0NA0KLS0tIGEvZnMvbmZzL25mczR4ZHIuYw0KKysrIGIvZnMvbmZzL25mczR4ZHIuYw0KQEAg
LTExMTgsMTEgKzExMTgsMTEgQEAgc3RhdGljIHZvaWQgZW5jb2RlX2F0dHJzKHN0cnVjdCB4ZHJf
c3RyZWFtICp4ZHIsIGNvbnN0IHN0cnVjdCBpYXR0ciAqaWFwLA0KIAkJCQlsZW4sICgoY2hhciAq
KXAgLSAoY2hhciAqKXEpICsgNCk7DQogCQlCVUcoKTsNCiAJfQ0KLQlsZW4gPSAoY2hhciAqKXAg
LSAoY2hhciAqKXEgLSAoYm12YWxfbGVuIDw8IDIpOw0KIAkqcSsrID0gaHRvbmwoYm12YWwwKTsN
CiAJKnErKyA9IGh0b25sKGJtdmFsMSk7DQogCWlmIChibXZhbF9sZW4gPT0gMykNCiAJCSpxKysg
PSBodG9ubChibXZhbDIpOw0KKwlsZW4gPSAoY2hhciAqKXAgLSAoY2hhciAqKShxICsgMSk7DQog
CSpxID0gaHRvbmwobGVuKTsNCiANCiAvKiBvdXQ6ICovDQotLSANCjEuOC4zLjENCg0K

--_002_1374598847129430camelleiratrondhjemorg_--
