Return-Path: <trondmy@primarydata.com>
From: Trond Myklebust <trondmy@primarydata.com>
To: "aweits@rit.edu" <aweits@rit.edu>
CC: bcodding redhat <bcodding@redhat.com>, "anna.schumaker@netapp.com"
	<anna.schumaker@netapp.com>, "linux-nfs@vger.kernel.org"
	<linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v6 05/10] NFSv4: Retry CLOSE and DELEGRETURN on
 NFS4ERR_OLD_STATEID.
Date: Mon, 6 Nov 2017 03:10:21 +0000
Message-ID: <1509937819.20977.0.camel@primarydata.com>
References: <20171103165354.15997-1-trond.myklebust@primarydata.com>
	 <20171103165354.15997-2-trond.myklebust@primarydata.com>
	 <20171103165354.15997-3-trond.myklebust@primarydata.com>
	 <20171103165354.15997-4-trond.myklebust@primarydata.com>
	 <20171103165354.15997-5-trond.myklebust@primarydata.com>
	 <20171103165354.15997-6-trond.myklebust@primarydata.com>
	 <m2k1z4qg45.fsf@discipline.rit.edu>
In-Reply-To: <m2k1z4qg45.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

T24gU3VuLCAyMDE3LTExLTA1IGF0IDIxOjQ2IC0wNTAwLCBBbmRyZXcgVyBFbGJsZSB3cm90ZToN
Cj4gSSd2ZSBiZWVuIHRlc3RpbmcgdGhlc2UgYSBiaXQsIEkgdGhpbmsgdGhpcyB3YXMgY2F1c2lu
ZyBhbiBpc3N1ZS4uLg0KPiANCj4gVHJvbmQgTXlrbGVidXN0IDx0cm9uZC5teWtsZWJ1c3RAcHJp
bWFyeWRhdGEuY29tPiB3cml0ZXM6DQo+IA0KPiA+IGRpZmYgLS1naXQgYS9mcy9uZnMvbmZzNHN0
YXRlLmMgYi9mcy9uZnMvbmZzNHN0YXRlLmMNCj4gPiBpbmRleCBkNjE1YjdjZGZhOGYuLjc1MmIx
OGU4ODI2NiAxMDA2NDQNCj4gPiAtLS0gYS9mcy9uZnMvbmZzNHN0YXRlLmMNCj4gPiArKysgYi9m
cy9uZnMvbmZzNHN0YXRlLmMNCj4gPiBAQCAtOTg2LDYgKzk4NiwyMiBAQCBzdGF0aWMgaW50IG5m
czRfY29weV9sb2NrX3N0YXRlaWQobmZzNF9zdGF0ZWlkDQo+ID4gKmRzdCwNCj4gPiAgCXJldHVy
biByZXQ7DQo+ID4gIH0NCj4gPiAgDQo+ID4gK2Jvb2wgbmZzNF9yZWZyZXNoX29wZW5fc3RhdGVp
ZChuZnM0X3N0YXRlaWQgKmRzdCwgc3RydWN0DQo+ID4gbmZzNF9zdGF0ZSAqc3RhdGUpDQo+ID4g
K3sNCj4gPiArCWJvb2wgcmV0Ow0KPiA+ICsJaW50IHNlcTsNCj4gPiArDQo+ID4gKwlkbyB7DQo+
ID4gKwkJcmV0ID0gZmFsc2U7DQo+ID4gKwkJc2VxID0gcmVhZF9zZXFiZWdpbigmc3RhdGUtPnNl
cWxvY2spOw0KPiA+ICsJCWlmIChuZnM0X3N0YXRlX21hdGNoX29wZW5fc3RhdGVpZF9vdGhlcihz
dGF0ZSwNCj4gPiBkc3QpKSB7DQo+ID4gKwkJCWRzdC0+c2VxaWQgPSBzdGF0ZS0+c3RhdGVpZC5z
ZXFpZDsNCj4gDQo+IFlvdSBtZWFuOg0KPiANCj4gICAgICAgICAgICAgICAgICAgICAgICAgZHN0
LT5zZXFpZCA9IHN0YXRlLT5vcGVuX3N0YXRlaWQuc2VxaWQ7DQo+IA0KDQpEb2ghIFllcywgdGhh
dCdzIGVudGlyZWx5IGNvcnJlY3QuLi4gVGhhbmtzIGZvciB0aGUgcmV2aWV3IGFuZCBmb3INCnNw
b3R0aW5nIHRoYXQhDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1h
aW50YWluZXIsIFByaW1hcnlEYXRhDQp0cm9uZC5teWtsZWJ1c3RAcHJpbWFyeWRhdGEuY29tDQo=
