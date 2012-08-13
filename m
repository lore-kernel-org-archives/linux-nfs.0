Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44781 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753743Ab2HMUVj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Aug 2012 16:21:39 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Peng Tao <bergwolf@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC 2/3] NFS41: send real write size in layoutget
Date: Mon, 13 Aug 2012 20:21:07 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA939F7C0@SACEXCMBX04-PRD.hq.netapp.com>
References: <1344391392-1948-1-git-send-email-bergwolf@gmail.com>
	 <1344391392-1948-3-git-send-email-bergwolf@gmail.com>
	 <5027F63F.8070107@panasas.com>
	 <CA+a=Yy5cG74RhVUYVQTYOCrwOWfuz2OfsCGpuMXW-8hoOgfKLw@mail.gmail.com>
	 <50295FF9.3020604@panasas.com>
In-Reply-To: <50295FF9.3020604@panasas.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTA4LTEzIGF0IDIzOjEzICswMzAwLCBCb2F6IEhhcnJvc2ggd3JvdGU6DQo+
IE9uIDA4LzEzLzIwMTIgMTI6NDQgUE0sIFBlbmcgVGFvIHdyb3RlOg0KPiANCj4gPiBPbiBNb24s
IEF1ZyAxMywgMjAxMiBhdCAyOjMwIEFNLCBCb2F6IEhhcnJvc2ggPGJoYXJyb3NoQHBhbmFzYXMu
Y29tPiB3cm90ZToNCj4gPj4gU28gdGhlIHNtYWxsIGNoYW5nZSBJIHdhbnQgaXM6DQo+ID4+DQo+
ID4+ICtlbnVtIHBuZnNfbGF5b3V0X2dldF9zdHJhdGVneSB7DQo+ID4+ICsgICAgICAgUExHU19V
U0VfSVNJWkUsDQo+ID4+ICsgICAgICAgUExHU19TRUFSQ0hfRklSU1RfSE9MRSwNCj4gPj4gKyAg
ICAgICBQTEdTX0FMTF9GSUxFLA0KPiA+PiArfTsNCj4gPj4NCj4gPiBKdXN0IGEgc2Vjb25kIHRo
b3VnaHQsIHNpbmNlIGVhY2ggbGF5b3V0IGRyaXZlciB3b3VsZCB1c2Ugb25lDQo+ID4gc3RyYXRl
Z3ksIGl0IGlzIG1vcmUgcmVhc29uYWJsZSB0byBzZXQgdGhlIHN0cmF0ZWd5IGluDQo+ID4gcG5m
c19jdXJyX2xkLT5mbGFncyBpbnN0ZWFkIG9mIGNoYW5naW5nIHBnX2luaXQgQVBJIHRvIHBhc3Mg
aXQgaW4uIEkNCj4gPiB3aWxsIGRvIGl0IHRoaXMgd2F5Lg0KPiA+IA0KPiANCj4gDQo+IEl0J3Mg
ZmluZSwgYXMgeW91IHNlZSBmaXQuIEkgdGhpbmsgaXQncyBtb3JlIGZsZXhpYmxlIHRoaXMgd2F5
IGJ1dA0KPiBib3RoIHdheXMgd2lsbCB3b3JrIGZvciBub3cuDQo+IA0KPiBQbGVhc2Ugbm90ZSB0
aGF0IGZvciBmaWxlcywgb25jZSBpdCB3aWxsIHN1cHBvcnQgc2VnbWVudHMsIGl0IHdvdWxkDQo+
IHdhbnQgdG8gdXNlIGlfc2l6ZSBsaWtlIG9iamVjdHMuDQoNCg0KTGF5b3V0LXNwZWNpZmljIGZs
YWdzIGluIHRoZSBnZW5lcmljIGNvZGUgYXJlIG5vdCBhY2NlcHRhYmxlLiBJZiB0aGUNCnN0cmF0
ZWd5IGlzIGxheW91dCBzcGVjaWZpYywgdGhlbiB0aGVyZSBzaG91bGQgYmUgbm8gbmVlZCB0byBw
YXNzIGl0DQphcm91bmQgdGhlIGdlbmVyaWMgbGF5ZXJzIGF0IGFsbC4gSnVzdCBkbyB0aGUgcmln
aHQgdGhpbmcgaW4gdGhlIGRyaXZlcg0KKGkuZS4gcGdfaW5pdCkgYW5kIHdlJ3JlIGRvbmUuDQoN
Ci0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0
QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0K
