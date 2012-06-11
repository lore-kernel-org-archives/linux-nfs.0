Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41563 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751321Ab2FKWbd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Jun 2012 18:31:33 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Andy Adamson <androsadamson@gmail.com>, NFSv4 <nfsv4@ietf.org>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>,
        Benny Halevy <bhalevy@tonian.com>
Subject: Re: RFC 5661 LAYOUTRETURN clarification.
Date: Mon, 11 Jun 2012 22:31:31 +0000
Message-ID: <1339453889.2019.3.camel@lade.trondhjem.org>
References: <CAHVgHyUpM0rQWqO5-id+FohPKm1Lk=kkekf7HqzpfKcfvxx23A@mail.gmail.com>
	  <4FD63BAF.8040107@panasas.com>
	 <1339441159.19775.25.camel@lade.trondhjem.org> <4FD66E9F.708@panasas.com>
In-Reply-To: <4FD66E9F.708@panasas.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTA2LTEyIGF0IDAxOjE4ICswMzAwLCBCb2F6IEhhcnJvc2ggd3JvdGU6DQo+
IE9uIDA2LzExLzIwMTIgMDk6NTkgUE0sIE15a2xlYnVzdCwgVHJvbmQgd3JvdGU6DQo+IA0KPiA+
IE9uIE1vbiwgMjAxMi0wNi0xMSBhdCAyMTo0MCArMDMwMCwgQm9heiBIYXJyb3NoIHdyb3RlOg0K
PiA+IA0KPiA+PiBBbmQgYWdhaW4sIHBsZWFzZSBleHBsYWluIHdoeSBkbyB5b3Ugd2FudCBpdC4g
V2hhdCBpcyB3cm9uZyB3aXRoIHRoZQ0KPiA+PiBjYXNlIHdlIGFsbCBhZ3JlZSB3aXRoPyBpZTog
IkNsaWVudCBjYW4gbm90IGNhbGwgTEFZT1VUUkVUVVJOIHVudGlsDQo+ID4+IGFsbCBpbi1mbGln
aHQgUlBDcyByZXR1cm4sIHdpdGggb3Igd2l0aG91dCBhbiBlcnJvciINCj4gPiANCj4gPiBXaG8g
ImFncmVlZCIgdG8gdGhpcz8gVGhpcyB3b3VsZCBtZWFuIHRoYXQgaWYgdGhlIERTIGdvZXMgZG93
biwgd2UgY2FuJ3QNCj4gPiBldmVyIHNlbmQgTEFZT1VUUkVUVVJOIHdoaWNoIGlzIHBhdGVudGx5
IHdyb25nLg0KPiA+IA0KPiANCj4gDQo+ICJEUyBnb2VzIGRvd24iIGlzIHVuZGVyIHRoZSBhYm92
ZSAiUlBDIHJldHVybiBhbiBlcnJvciIgdGhlIGVycm9yIGNvbmRpdGlvbg0KPiBvZiBhbiBSUEMg
aXMgd2VsbCBkZWZpbmVkLg0KDQo/Pz8/IE5vdyB5b3UgaGF2ZSBtZSBleHRyZW1lbHkgY29uZnVz
ZWQuIEhvdyBkb2VzIHRoZSBjbGllbnQgZGlzdGluZ3Vpc2gNCmJldHdlZW4gRVRJTUVET1VULWJl
Y2F1c2UtRFMtd2VudC1kb3duIGFuZA0KRVRJTUVET1VULWJ1dC1pbi1mbGlnaHQtUlBDcy13aWxs
LWV2ZW50dWFsbHktc3VjY2VlZC1zby1wbGVhc2UtaG9sZC10aGF0LUxBWU9VVFJFVFVSTj8NCg0K
PiA+RnJvbSB3aGF0IG9mIG15IHdvcmRzIGRpZCB5b3UgdW5kZXJzdGFuZCB0aGF0IEkgc2FpZA0K
PiAJIndlIGNhbid0IGV2ZXIgc2VuZCBhIExBWU9VVFJFVFVSTiINCj4gDQo+IElmIG15IEVuZ2xp
c2ggaXMgd3JvbmdseSB3b3JkZWQuIFdoaWNoIGlzIHBlcmZlY3RseSBwb3NzaWJsZS4gUGxlYXNl
IGNvcnJlY3QNCj4gbWUgc28gSSBjYW4gbGVhcm4uIERpZCB5b3UgaG9uZXN0bHkgdGhpbmsgdGhh
dCdzIHdoYXQgSSBtZWFudD8gDQo+IA0KPiBJIG1lYW50IHdlIGFsbCBhZ3JlZSwgdGhhdCB0aGlz
IGNhc2UgaXMgY292ZXJlZCBieSBSRkMuIFRoYXQgaXMgIC0gbm8gb25lIHdvdWxkDQo+IGFjY3Vz
ZSBhIGNsaWVudCB3aG8gZG9lcyB0aGF0LCBhcyB2aW9sYXRpbmcgdGhlIFJGQy4NCj4gDQo+IEFu
ZCBhZ2FpbiBteSBxdWVzdGlvbi4gVGhlIG1vdGl2YXRpb24/DQoNCk1ha2luZyBmYWxsYmFjay10
by1NRFMgd29yayB3aXRob3V0IGNvcnJ1cHRpbmcgeW91ciBkYXRhLiBQbGVhc2UgcmVhZCB1cA0K
b24gbXVsdGlwYXRoLTEwMSBhbmQgdGhlIG5lZWQgZm9yIGZlbmNpbmcuLi4NCg0KLS0gDQpUcm9u
ZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25k
Lk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
