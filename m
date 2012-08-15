Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:22422 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751913Ab2HON4E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Aug 2012 09:56:04 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Richard Ems <richard.ems@cape-horn-eng.com>
CC: Jeff Layton <jlayton@redhat.com>, Al Viro <viro@ZenIV.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfs_lookup_revalidate BUG ?
Date: Wed, 15 Aug 2012 13:55:00 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA93AB81E@SACEXCMBX04-PRD.hq.netapp.com>
References: <502A21A1.7020206@cape-horn-eng.com>
	   <4FA345DA4F4AE44899BD2B03EEEC2FA93A4848@SACEXCMBX04-PRD.hq.netapp.com>
	   <20120814183512.GI23464@ZenIV.linux.org.uk>
	   <4FA345DA4F4AE44899BD2B03EEEC2FA93A4DFC@SACEXCMBX04-PRD.hq.netapp.com>
	   <20120814151143.30fb9ca9@tlielax.poochiereds.net>
	   <502B8E9A.9010601@cape-horn-eng.com>
	  <4FA345DA4F4AE44899BD2B03EEEC2FA93AB5CB@SACEXCMBX04-PRD.hq.netapp.com>
	  <502BA2A0.6000208@cape-horn-eng.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA93AB714@SACEXCMBX04-PRD.hq.netapp.com>
	 <502BA6B8.3090209@cape-horn-eng.com>
In-Reply-To: <502BA6B8.3090209@cape-horn-eng.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTA4LTE1IGF0IDE1OjQwICswMjAwLCBSaWNoYXJkIEVtcyB3cm90ZToNCj4g
T24gMDgvMTUvMjAxMiAwMzozOCBQTSwgTXlrbGVidXN0LCBUcm9uZCB3cm90ZToNCj4gPiBPbiBX
ZWQsIDIwMTItMDgtMTUgYXQgMTU6MjIgKzAyMDAsIFJpY2hhcmQgRW1zIHdyb3RlOg0KPiA+PiBP
biAwOC8xNS8yMDEyIDAzOjIwIFBNLCBNeWtsZWJ1c3QsIFRyb25kIHdyb3RlOg0KPiA+Pj4+IChn
ZGIpIGxpc3QgKihuZnNfbG9va3VwX3JldmFsaWRhdGUrMHgyZCkNCj4gPj4+PiAweDU5Y2QgaXMg
aW4gbmZzX2xvb2t1cF9yZXZhbGlkYXRlICgvdXNyL3NyYy9kZWJ1Zy9rZXJuZWwtZGVmYXVsdC0z
LjUuMS9saW51eC0zLjUvZnMvbmZzL2Rpci5jOjExMjkpLg0KPiA+Pj4+IDExMjQgICAgICAgICAg
ICBzdHJ1Y3QgZGVudHJ5ICpwYXJlbnQ7DQo+ID4+Pj4gMTEyNSAgICAgICAgICAgIHN0cnVjdCBu
ZnNfZmggKmZoYW5kbGUgPSBOVUxMOw0KPiA+Pj4+IDExMjYgICAgICAgICAgICBzdHJ1Y3QgbmZz
X2ZhdHRyICpmYXR0ciA9IE5VTEw7DQo+ID4+Pj4gMTEyNyAgICAgICAgICAgIGludCBlcnJvcjsN
Cj4gPj4+PiAxMTI4DQo+ID4+Pj4gMTEyOSAgICAgICAgICAgIGlmIChuZC0+ZmxhZ3MgJiBMT09L
VVBfUkNVKQ0KPiA+Pj4NCj4gPj4+IEJ1bW1lci4uLiBXZSBjaGVjayBpZiAnbmQnIGlzIE5VTEwg
ZXZlcnl3aGVyZSBleGNlcHQgaGVyZS4uLg0KPiA+Pj4NCj4gPj4+IE9LLiBDaGFuZ2luZyB0aGUg
YWJvdmUgbGluZSB0bw0KPiA+Pj4NCj4gPj4+IAlpZiAobmQgJiYgKG5kLT5mbGFncyAmIExPT0tV
UF9SQ1UpKQ0KPiA+Pj4NCj4gPj4+IHdpbGwgZml4IHRoZSBwcm9ibGVtLg0KPiA+Pg0KPiA+PiBP
aywgZ3JlYXQgIQ0KPiA+PiBEbyB5b3UgdGhpbmsgdGhpcyBmaXggd2lsbCBnbyBpbnRvIDMuNS4y
ID8NCj4gPiANCj4gPiBJJ2xsIHRyeSB0byBnZXQgaXQgaW50byBzdGFibGUuIDMuNi1yY1ggaXMg
dW5hZmZlY3RlZCBieSB0aGUgYnVnIGR1ZSB0bw0KPiA+IHJlY2VudCBWRlMgY2hhbmdlcyB0aGF0
IGhhdmUgcmVtb3ZlZCB0aGUgInN0cnVjdCBuYW1laWRhdGEgKiIgYXJndW1lbnQNCj4gPiB0byBu
ZnNfbG9va3VwX3JldmFsaWRhdGUuDQo+ID4gDQo+IA0KPiBPaywgbWFueSB0aGFua3MuIEkgaGF2
ZSBmb3VuZCBhIGNvdXBsZSBvZiBvdGhlciBhY2Nlc3NlcyB0byBuZCB3aXRoIG5vDQo+IGNoZWNr
IGZvciBOVUxMIGF0ICpuZnNfYXRvbWljX2xvb2t1cCBhbmQgbmZzNF9sb29rdXBfcmV2YWxpZGF0
ZSwgYnV0DQo+IGRvbid0IGtub3cgaWYgdGhvc2UgYXJlIHJlbGV2YW50Lg0KDQpJdCBpcyByZWxl
dmFudCBmb3IgbmZzX29wZW5fcmV2YWxpZGF0ZSg8PTMuNCkgYW5kDQpuZnM0X2xvb2t1cF9yZXZh
bGlkYXRlKDMuNSksIGJ1dCBub3QgZm9yIG5mc19hdG9taWNfbG9va3VwLg0KDQpDaGVlcnMNCiAg
VHJvbmQNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIN
Cg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0K
