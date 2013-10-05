Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:28062 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751736Ab3JEO7q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Oct 2013 10:59:46 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: David Quigley <selinux@davequigley.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: Daniel J Walsh <dwalsh@redhat.com>, Stephen Smalley <sds@tycho.nsa.gov>,
        Eric Paris <eparis@redhat.com>, Steve Dickson <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: Hey we are seeing a big problem with Labeled NFS
Date: Sat, 5 Oct 2013 14:59:14 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9534847CF@sacexcmbx05-prd.hq.netapp.com>
References: <524EB4C2.6070804@redhat.com>
 <a72f70f2dce1409f383d634c06b17b40@countercultured.net>
 <20131004143549.GC1577@fieldses.org>
 <46df4f789cbeb203d1355adbd3a346c6@countercultured.net>
 <20131004150505.GD1577@fieldses.org>
 <7392559a27900ee1dfe69ebbe0fd468e@countercultured.net>
 <20131004152944.GE1577@fieldses.org>
 <cc6c106aa0b1ead440ff70a2ca002f69@countercultured.net>
In-Reply-To: <cc6c106aa0b1ead440ff70a2ca002f69@countercultured.net>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBsaW51eC1uZnMtb3duZXJAdmdl
ci5rZXJuZWwub3JnIFttYWlsdG86bGludXgtbmZzLQ0KPiBvd25lckB2Z2VyLmtlcm5lbC5vcmdd
IE9uIEJlaGFsZiBPZiBEYXZpZCBRdWlnbGV5DQo+IFNlbnQ6IEZyaWRheSwgT2N0b2JlciAwNCwg
MjAxMyAxMTo0MCBBTQ0KPiBUbzogSi4gQnJ1Y2UgRmllbGRzDQo+IENjOiBEYW5pZWwgSiBXYWxz
aDsgU3RlcGhlbiBTbWFsbGV5OyBFcmljIFBhcmlzOyBTdGV2ZSBEaWNrc29uOyBsaW51eC0NCj4g
bmZzQHZnZXIua2VybmVsLm9yZw0KPiBTdWJqZWN0OiBSZTogSGV5IHdlIGFyZSBzZWVpbmcgYSBi
aWcgcHJvYmxlbSB3aXRoIExhYmVsZWQgTkZTDQo+IA0KPiAoIEFkZGluZyBsaW51eC1uZnMgdG8g
dGhlIGxpc3Qgb2YgcGVvcGxlKQ0KPiANCj4gSGVyZSBpcyBhIHN1bW1hcnkgb2YgdGhlIGRpc2N1
c3Npb24gc28gZmFyLg0KPiANCj4gRGFuIFdhbHNoIGlzIHNlZWluZyBpc3N1ZXMgd2l0aCBMYWJl
bGVkIE5GUy4gVGhlIGlzc3VlIGhlIGlzIHNlZWluZyBpcyB0aGF0IGENCj4gbGFiZWwgY2hhbmdl
IG9uIHRoZSBzZXJ2ZXIgaXMgbm90IHJlZmxlY3RlZCBvbiB0aGUgY2xpZW50IHVudGlsIGEgcmVt
b3VudCBvZg0KPiB0aGUgY2xpZW50LiBUaGVyZSBzaG91bGQgYmUgYSBkZWxheSBpbiB0aGUgbGFi
ZWwgY2hhbmdlIGJlaW5nIHJlZmxlY3RlZCBpbiB0aGUNCj4gY2xpZW50IGFzIHdlIGRvbid0IHll
dCBoYXZlIHRoZSBsYWJlbCBjaGFuZ2Ugbm90aWZpY2F0aW9uIGluLiBIb3dldmVyIGl0IHNob3Vs
ZA0KPiBvbmx5IGJlIHVudGlsIHRoZSBjYWNoZSBmb3IgdGhlIGZpbGUgYXR0cmlidXRlIGlzIGlu
dmFsaWRhdGVkIGFuZCB0aGUgbmV4dA0KPiBnZXRmYXR0ciBjYWxsIHJldmFsaWRhdGVzIHRoZSBs
YWJlbC4gSXQgaXMgdW5jbGVhciB3aHkgYSByZW1vdW50IGlzIG5lZWRlZCBhdCB0aGlzDQo+IHRp
bWUuDQoNCg0KVGhpcyBpcyBieSBkZXNpZ24uDQoNCkRvIE5PVCBtYWtlIGxhYmVsIGNoYW5nZXMg
b24gdGhlIHNlcnZlci4gRG8gaXQgdGhyb3VnaCB0aGUgY2xpZW50IGFzIHBlciBkZXNpZ24gdW50
aWwgc29tZW9uZSBmaXhlcyB0aGUgc3BlYyB0byBoYXZlIHNhbmUgc3VwcG9ydCBmb3IgdGhlIHNl
cnZlci1zaWRlIGxhYmVsIGNoYW5nZSBjYXNlLg0KDQpDaGVlcnMNCiAgIFRyb25kDQo=
