Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-co1nam03on0131.outbound.protection.outlook.com ([104.47.40.131]:37597
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727373AbeJUCd0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 20 Oct 2018 22:33:26 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "tigran.mkrtchyan@desy.de" <tigran.mkrtchyan@desy.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: readdir request re-requests entries
Date: Sat, 20 Oct 2018 18:22:07 +0000
Message-ID: <f9f24f44266292dc5fa41f633344b11cf84cc4f8.camel@hammerspace.com>
References: <174380207.12564567.1539987095714.JavaMail.zimbra@desy.de>
In-Reply-To: <174380207.12564567.1539987095714.JavaMail.zimbra@desy.de>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gU2F0LCAyMDE4LTEwLTIwIGF0IDAwOjExICswMjAwLCBNa3J0Y2h5YW4sIFRpZ3JhbiB3cm90
ZToNCj4gRGVhciBORlMgZmVsbG93cywNCj4gDQo+IHdlIGhhdmUgbm90aWNlIGEgYmVoYXZpb3Ig
b2YgbmZzIGNsaWVudCB3aGVuIGl0ZXJhdGluZyBvdmVyIGEgYmlnDQo+IGRpcmVjdG9yeS4gVGhl
IGNsaWVudCByZS1yZXF1ZXN0cyBlbnRyaWVzIHRoYXQgYWxyZWFkeSBoYXMgYmVlbi4gRm9yDQo+
IGV4YW1wbGUsIGEgY2xpZW50IGlzc3VlcyBSRUFERElSIG9uIGEgZGlyZWN0b3J5IHdpdGggMWsg
ZmlsZXMuDQo+IEluaXRpYWwgY29va2llDQo+IGlzIDAsIG1heGNvdW50IDMyNzY4Lg0KPiANCj4g
YyAtPiBzIGNvb2tpZSAwDQo+IHMgLT4gYyBsYXN0IGNvb2tpZSAxNTkNCj4gYyAtPiBzIGNvb2tp
ZSAxMDUNCj4gcyAtPiBjIGxhc3QgY29va2llIDI1OQ0KPiBjIC0+IHMgY29va2llIDIwNw0KPiAN
Cj4gLi4uDQo+IA0KPiBhbmQgc28gb24uIFRoZSBpbnRlcmVzdGluZyB0aGluZyBpcywgaWYgSSBt
b3VudCB3aXRoIHJzaXplIDgxOTINCj4gKG1heGNvdW50IDgxOTIpLCB0aGVuIGZpcnN0IGNvdXBs
ZQ0KPiBvciByZXF1ZXN0cyBhcmUgYXNraW5nIGZvciBjb3JyZWN0IGNvb2tpZXMgLSAwLCA0Mywg
ODEsIDEwNS4gQWdhaW4NCj4gMTA1IGFzIHdpdGggbWF4Y291bnQgMzI2NzguIFRvDQo+IG1lIGl0
IGxvb2tzIGxpa2UgdGhhdCB0aGVyZSBpcyBzb21lIGtpbmQgb2YgaW50ZXJuYWwgcGFnZSAoYWN0
dWFsbHkNCj4gTkZTX01BWF9SRUFERElSX1BBR0VTKSBhbGlnbm1lbnQNCj4gYW5kIGVudHJpZXMg
d2hpY2ggZG8gbm90IGZpdCBpbnRvIGluaXRpYWxseSBhbGxvY2F0ZWQgUEFHRV9TSVpFICoNCj4g
TkZTX01BWF9SRUFERElSX1BBR0VTIG1lbW9yeQ0KPiBqdXN0IGdldCBkcm9wcGVkLg0KPiANCj4g
QXMgMzAlIG9mIGVhY2ggcmVwbHkgaXMgdGhyb3duIGF3YXksIGxpc3Rpbmcgb2YgbGFyZ2UgZGly
ZWN0b3JpZXMgbWF5DQo+IHByb2R1Y2UgbXVjaCBtb3JlIHJlcXVlc3RzDQo+IHRoYW4gcmVxdWly
ZWQuDQo+IA0KPiBJcyBpdCBhbiBleHBlY3RlZCBiZWhhdmlvcj8NCg0KWWVzLg0KDQotLSANClRy
b25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0K
dHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
