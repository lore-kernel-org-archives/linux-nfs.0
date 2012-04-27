Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12023 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760281Ab2D0PCJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 11:02:09 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Josh Boyer <jwboyer@redhat.com>
CC: Jim Rees <rees@umich.edu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: Add modalias for "nfs4"
Date: Fri, 27 Apr 2012 15:02:07 +0000
Message-ID: <1335538927.3910.3.camel@lade.trondhjem.org>
References: <20120427131031.GA13189@zod.bos.redhat.com>
	 <20120427141918.GA15506@umich.edu>
	 <20120427144840.GB13189@zod.bos.redhat.com>
	 <1335538228.3910.1.camel@lade.trondhjem.org>
	 <20120427145352.GC13189@zod.bos.redhat.com>
In-Reply-To: <20120427145352.GC13189@zod.bos.redhat.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEyLTA0LTI3IGF0IDEwOjUzIC0wNDAwLCBKb3NoIEJveWVyIHdyb3RlOg0KPiBP
biBGcmksIEFwciAyNywgMjAxMiBhdCAwMjo1MDoyOFBNICswMDAwLCBNeWtsZWJ1c3QsIFRyb25k
IHdyb3RlOg0KPiA+IE9uIEZyaSwgMjAxMi0wNC0yNyBhdCAxMDo0OCAtMDQwMCwgSm9zaCBCb3ll
ciB3cm90ZToNCj4gPiA+IE9uIEZyaSwgQXByIDI3LCAyMDEyIGF0IDEwOjE5OjE4QU0gLTA0MDAs
IEppbSBSZWVzIHdyb3RlOg0KPiA+ID4gPiBKb3NoIEJveWVyIHdyb3RlOg0KPiA+ID4gPiANCj4g
PiA+ID4gICBXaGVuIE5GU3Y0IGlzIGNvbmZpZ3VyZWQsIHRoZSBzdXBwb3J0IGdvZXMgaW50byB0
aGUgbmZzLmtvIG1vZHVsZS4NCj4gPiA+ID4gICBIb3dldmVyLCBuZnMtdXRpbHMgc2VlbXMgdG8g
cGFzcyAibmZzNCIgYXMgdGhlIGZpbGVzdHN0ZW0gdHlwZSBmb3INCj4gPiA+ID4gICBORlN2NCBt
b3VudHMuDQo+ID4gPiA+IA0KPiA+ID4gPiBXZXJlbid0IHdlIGdvaW5nIHRvIGNoYW5nZSB0aGF0
IHRvIG5mcyBhbmQgdXNlIG5mc3ZlcnMgdG8gc2VsZWN0IG5mczQ/DQo+ID4gPiANCj4gPiA+IEkg
aGF2ZSwgYXBwcm94aW1hdGVseSwgbm8gaWRlYS4gIEF0IGxlYXN0IHRoZSB2ZXJzaW9uIG9mIG5m
cy11dGlscyBmb3VuZA0KPiA+ID4gaW4gRmVkb3JhIDE3IGFuZCByYXdoaWRlLCBpdCdzIHN0aWxs
IHVzaW5nICJuZnM0Ii4gICBJIGJlbGlldmUgdGhhdCBpcw0KPiA+ID4gbmZzLXV0aWxzLTEuMi42
LXJjNiBiYXNlZC4NCj4gPiANCj4gPiBuZnM0IGlzIHN0aWxsIF9zdXBwb3J0ZWRfIGluIEZlZG9y
YSAxNywgcmF3aGlkZSBhbmQgdXBzdHJlYW0gYXMgYSBsZWdhY3kNCj4gPiBmZWF0dXJlLCBidXQg
dGhlIHJlY29tbWVuZGVkIHByYWN0aWNlIHNob3VsZCBiZSB0byBtb3VudCAtdCBuZnMgLW92ZXJz
PTQNCj4gPiAob3IgLW92ZXJzPTQuMSkuDQo+IA0KPiBPSy4gIFNvIGVpdGhlciB0aGlzIHBhdGNo
IG5lZWRzIHRvIGdvIGluLCBvciBzb21ldGhpbmcgbmVlZHMgdG8gYWRkOg0KPiANCj4gYWxpYXMg
bmZzNCBuZnMNCj4gDQo+IHRvIGEgY29uZiBmaWxlIHNvIG1vZHByb2JlIHBpY2tzIGl0IHVwLiAg
SSBmaWd1cmVkIHRoZSBrZXJuZWwgY291bGQgYWRkDQo+IHRoZSBhbGlhcyBpdHNlbGYuICBJcyB0
aGVyZSBhIHJlYXNvbiBub3QgdG8/DQoNClllcy4gVGhpcyBpcyBhIGxlZ2FjeSBmZWF0dXJlIHRo
YXQgd2Ugd2FudCB0byBlbmNvdXJhZ2UgcGVvcGxlIHRvIG1vdmUNCnRoZWlyIHN5c3RlbXMgb2Zm
Li4uDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIN
Cg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0K
