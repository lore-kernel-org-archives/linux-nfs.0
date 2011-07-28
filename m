Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:13002 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752728Ab1G1Cag (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 22:30:36 -0400
From: <tao.peng@emc.com>
To: <Trond.Myklebust@netapp.com>, <rees@umich.edu>
CC: <linux-nfs@vger.kernel.org>, <honey@citi.umich.edu>
Date: Wed, 27 Jul 2011 22:30:12 -0400
Subject: RE: [PATCH v3 22/25] pnfsblock: note written INVAL areas for
 layoutcommit
Message-ID: <F19688880B763E40B28B2B462677FBF805BF061894@MX09A.corp.emc.com>
References: <1311792048-12551-1-git-send-email-rees@umich.edu>
	 <1311792048-12551-23-git-send-email-rees@umich.edu>
 <1311797597.25645.26.camel@lade.trondhjem.org>
In-Reply-To: <1311797597.25645.26.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBsaW51eC1uZnMtb3duZXJAdmdl
ci5rZXJuZWwub3JnIFttYWlsdG86bGludXgtbmZzLW93bmVyQHZnZXIua2VybmVsLm9yZ10NCj4g
T24gQmVoYWxmIE9mIFRyb25kIE15a2xlYnVzdA0KPiBTZW50OiBUaHVyc2RheSwgSnVseSAyOCwg
MjAxMSA0OjEzIEFNDQo+IFRvOiBKaW0gUmVlcw0KPiBDYzogbGludXgtbmZzQHZnZXIua2VybmVs
Lm9yZzsgcGV0ZXIgaG9uZXltYW4NCj4gU3ViamVjdDogUmU6IFtQQVRDSCB2MyAyMi8yNV0gcG5m
c2Jsb2NrOiBub3RlIHdyaXR0ZW4gSU5WQUwgYXJlYXMgZm9yIGxheW91dGNvbW1pdA0KPiANCj4g
T24gV2VkLCAyMDExLTA3LTI3IGF0IDE0OjQwIC0wNDAwLCBKaW0gUmVlcyB3cm90ZToNCj4gPiBG
cm9tOiBGcmVkIElzYW1hbiA8aWlzYW1hbkBjaXRpLnVtaWNoLmVkdT4NCj4gPg0KPiA+IFtTUVVB
U0hNRTogcG5mczogYmxvY2tsYXlvdXQ6IHBvcnQgYmxvY2sgbGF5b3V0IGNvZGVdDQo+ICAgXl5e
Xl5eXl5eXl5eXl5eXl5eXl5eXl5eXl5eXl4gPw0KVGhpcyBpcyBmcm9tIFtQQVRDSCA4Ny84OV0g
U1FVQVNITUU6IHBuZnM6IGJsb2NrbGF5b3V0OiBwb3J0IGJsb2NrIGxheW91dCBjb2RlLCB3aGlj
aCB3YXMgYSBsYXJnZSBwYXRjaCB0aGF0IG1hZGUgbmVjZXNzYXJ5IGNoYW5nZSB0byBmaXggdXAg
YnJva2VuIGJsb2NrIGxheW91dCBjb2RlIHNpbmNlIGxhc3QgbWVyZ2Ugd2luZG93Lg0KWWVzLCBJ
IGFncmVlIHRoZSB0aXRsZSBpcyBtaXNsZWFkaW5nLiBXaWxsIHJlbW92ZSBpdCBmcm9tIHRoZSBj
b21taXQgbG9nLg0KDQpUaGFua3MsDQpUYW8NCg0KPiANCj4gDQo+IA0KPiANCj4gPiAraW50IG1h
cmtfZm9yX2NvbW1pdChzdHJ1Y3QgcG5mc19ibG9ja19leHRlbnQgKmJlLA0KPiA+ICsJCSAgICBz
ZWN0b3JfdCBvZmZzZXQsIHNlY3Rvcl90IGxlbmd0aCk7DQo+IA0KPiBUaGlzIGlzIGFuIGV4dGVy
bmFsbHkgdmlzaWJsZSBmdW5jdGlvbiwgc28gaXQgbmVlZHMgYSBwcmVmaXguDQpXaWxsIGRvIGl0
LiBUaGFua3MuDQoNCg0KPiANCj4gLS0NCj4gVHJvbmQgTXlrbGVidXN0DQo+IExpbnV4IE5GUyBj
bGllbnQgbWFpbnRhaW5lcg0KPiANCj4gTmV0QXBwDQo+IFRyb25kLk15a2xlYnVzdEBuZXRhcHAu
Y29tDQo+IHd3dy5uZXRhcHAuY29tDQo+IA0KPiAtLQ0KPiBUbyB1bnN1YnNjcmliZSBmcm9tIHRo
aXMgbGlzdDogc2VuZCB0aGUgbGluZSAidW5zdWJzY3JpYmUgbGludXgtbmZzIiBpbg0KPiB0aGUg
Ym9keSBvZiBhIG1lc3NhZ2UgdG8gbWFqb3Jkb21vQHZnZXIua2VybmVsLm9yZw0KPiBNb3JlIG1h
am9yZG9tbyBpbmZvIGF0ICBodHRwOi8vdmdlci5rZXJuZWwub3JnL21ham9yZG9tby1pbmZvLmh0
bWwNCg0KTu+/ve+/ve+/ve+/ve+/vXLvv73vv71577+977+977+9Yu+/vVjvv73vv73Hp3bvv71e
77+9Kd66ey5u77+9K++/ve+/ve+/ve+/vXvvv73vv73vv70i77+977+9Xm7vv71y77+977+977+9
eu+/vRrvv73vv71o77+977+977+977+9Ju+/ve+/vR7vv71H77+977+977+9aO+/vQMo77+96ZqO
77+93aJqIu+/ve+/vRrvv70bbe+/ve+/ve+/ve+/ve+/vXrvv73elu+/ve+/ve+/vWbvv73vv73v
v71o77+977+977+9fu+/vW3vv70=
