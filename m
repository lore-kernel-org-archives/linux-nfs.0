Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:52377 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752830Ab3IEWH1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Sep 2013 18:07:27 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Quentin Barnes <qbarnes@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfs-backed mmap file results in 1000s of WRITEs per second
Date: Thu, 5 Sep 2013 22:07:26 +0000
Message-ID: <1378418844.5450.30.camel@leira.trondhjem.org>
References: <20130905162110.GA17920@gmail.com>
	 <20130905170303.GB17330@us.ibm.com> <20130905191139.GA20830@gmail.com>
	 <1378411320.5450.27.camel@leira.trondhjem.org>
	 <20130905213649.GA21944@gmail.com>
In-Reply-To: <20130905213649.GA21944@gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEzLTA5LTA1IGF0IDE2OjM2IC0wNTAwLCBRdWVudGluIEJhcm5lcyB3cm90ZToN
Cj4gT24gVGh1LCBTZXAgMDUsIDIwMTMgYXQgMDg6MDI6MDFQTSArMDAwMCwgTXlrbGVidXN0LCBU
cm9uZCB3cm90ZToNCj4gPiBPbiBUaHUsIDIwMTMtMDktMDUgYXQgMTQ6MTEgLTA1MDAsIFF1ZW50
aW4gQmFybmVzIHdyb3RlOg0KPiA+ID4gT24gVGh1LCBTZXAgMDUsIDIwMTMgYXQgMTI6MDM6MDNQ
TSAtMDUwMCwgTWFsYWhhbCBOYWluZW5pIHdyb3RlOg0KPiA+ID4gPiBOZWlsIEJyb3duIHBvc3Rl
ZCBhIHBhdGNoIGNvdXBsZSBkYXlzIGFnbyBmb3IgdGhpcyENCj4gPiA+ID4gDQo+ID4gPiA+IGh0
dHA6Ly90aHJlYWQuZ21hbmUub3JnL2dtYW5lLmxpbnV4Lm5mcy81ODQ3Mw0KPiA+ID4gDQo+ID4g
PiBJIHRyaWVkIE5laWwncyBwYXRjaCBvbiBhIHYzLjExIGtlcm5lbC4gIFRoZSByZWJ1aWx0IGtl
cm5lbCBzdGlsbA0KPiA+ID4gZXhoaWJpdGVkIHRoZSBzYW1lIDEwMDBzIG9mIFdSSVRFcy9zZWMg
cHJvYmxlbS4NCj4gPiA+IA0KPiA+ID4gQW55IG90aGVyIGlkZWFzPw0KPiA+IA0KPiA+IFllcy4g
UGxlYXNlIHRyeSB0aGUgYXR0YWNoZWQgcGF0Y2guDQo+IA0KPiBHcmVhdCEgIFRoYXQgZGlkIHRo
ZSB0cmljayENCj4gDQo+IERvIHlvdSBmZWVsIHRoaXMgcGF0Y2ggY291bGQgYmUgd29ydGh5IG9m
IHB1c2hpbmcgaXQgdXBzdHJlYW0gaW4gaXRzDQo+IGN1cnJlbnQgc3RhdGUgb3Igd2FzIGl0IGp1
c3QgdG8gdmVyaWZ5IGEgdGhlb3J5Pw0KDQpJdCBzaG91bGQgYmUgc2FmZSB0byBtZXJnZSB0aGlz
LiBJdCBpcyBhIHZhbGlkIG9wdGltaXNhdGlvbiBpbiB0aGUgY2FzZQ0Kd2hlcmUgdGhlcmUgYXJl
IG5vIGxvY2tzIGFwcGxpZWQuDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xp
ZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3
Lm5ldGFwcC5jb20NCg==
