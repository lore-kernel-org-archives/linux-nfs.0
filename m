Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-co1nam03on0137.outbound.protection.outlook.com ([104.47.40.137]:10560
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932198AbeFFP4A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Jun 2018 11:56:00 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 2/2] NFSv4.0: Remove transport protocol name from
 non-UCS client ID
Date: Wed, 6 Jun 2018 15:55:57 +0000
Message-ID: <6b892b9ad11d33f59de22427092dc41673313fa2.camel@hammerspace.com>
References: <20180604144154.11877.19298.stgit@manet.1015granger.net>
         <20180604145334.11877.12862.stgit@manet.1015granger.net>
         <d14af3599d007587137eb6814baa98b91ff3efc8.camel@hammerspace.com>
         <73D2F6EC-8CE6-4290-9713-6D5B8B0DC2E3@oracle.com>
In-Reply-To: <73D2F6EC-8CE6-4290-9713-6D5B8B0DC2E3@oracle.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDE4LTA2LTA2IGF0IDExOjQ4IC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBKdW4gNiwgMjAxOCwgYXQgMTE6NDQgQU0sIFRyb25kIE15a2xlYnVzdCA8dHJvbmRteUBo
YW1tZXJzcGFjZS5jDQo+ID4gb20+IHdyb3RlOg0KPiA+IA0KPiA+IE9uIE1vbiwgMjAxOC0wNi0w
NCBhdCAxMDo1MyAtMDQwMCwgQ2h1Y2sgTGV2ZXIgd3JvdGU6DQo+ID4gPiBDb21taXQgNjlkZDcx
NmM1ZmZkICgiTkZTdjQ6IEFkZCBzb2NrZXQgcHJvdG8gYXJndW1lbnQgdG8NCj4gPiA+IHNldGNs
aWVudGlkIikgKDIwMDcpIGFkZGVkIHRoZSB0cmFuc3BvcnQgcHJvdG9jb2wgbmFtZSB0byB0aGUN
Cj4gPiA+IGNsaWVudA0KPiA+ID4gSUQgc3RyaW5nLCBidXQgdGhlIHBhdGNoIGRlc2NyaXB0aW9u
IGRvZXNuJ3QgZXhwbGFpbiB3aHkgdGhpcyB3YXMNCj4gPiA+IG5lY2Vzc2FyeS4NCj4gPiA+IA0K
PiA+ID4gQXQgdGhhdCB0aW1lLCB0aGUgb25seSB0cmFuc3BvcnQgcHJvdG9jb2wgbmFtZSB0aGF0
IHdvdWxkIGhhdmUNCj4gPiA+IGJlZW4NCj4gPiA+IHVzZWQgaXMgInRjcCIgKGZvciBib3RoIElQ
djQgYW5kIElQdjYpLCByZXN1bHRpbmcgaW4gbm8NCj4gPiA+IGFkZGl0aW9uYWwNCj4gPiA+IGRp
c3RpbmN0aXZlbmVzcyBvZiB0aGUgY2xpZW50IElEIHN0cmluZy4NCj4gPiA+IA0KPiA+ID4gU2lu
Y2UgdGhlcmUgaXMgb25lIGNsaWVudCBpbnN0YW5jZSwgdGhlIHNlcnZlciBzaG91bGQgcmVjb2du
aXplDQo+ID4gPiBpdCdzDQo+ID4gPiBzdGF0ZSB3aGV0aGVyIHRoZSBjbGllbnQgaXMgY29ubmVj
dGluZyB2aWEgVENQIG9yIFJETUEuIFNhbWUNCj4gPiA+IGNsaWVudCwNCj4gPiA+IHNhbWUgbGVh
c2UuDQo+ID4gDQo+ID4gVGhlIHJlYXNvbiB3aHkgdGhpcyBpcyB0aGUgY2FzZSBub3cgaXMgYmVj
YXVzZSB0aGUgdHJ1bmtpbmcgY29kZQ0KPiA+IG92ZXJyaWRlcyB0aGUgZ3VhcmRyYWlscyBpbiBu
ZnNfZ2V0X2NsaWVudCgpLiBUaGUgbGF0dGVyIGRvZXMgbWF0Y2gNCj4gPiBvbg0KPiA+IHRoZSBw
cm90b2NvbC4NCj4gDQo+IE9LLiBXb3VsZCB0aGF0IGFsc28gdHJ1ZSBpbiB0aGUgVUNTIGNhc2U/
DQo+IA0KDQpZZXMsIEkgYmVsaWV2ZSB0aGF0IGNvZGUgaXMgaW5kZXBlbmRlbnQgb2YgdGhlIG1p
Z3JhdGlvbiBmbGFnLg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBt
YWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0K
DQo=
