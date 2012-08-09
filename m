Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:17457 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750855Ab2HIQtT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Aug 2012 12:49:19 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Lukas Hejtmanek <xhejtman@ics.muni.cz>, Zdenek Salvet <salvet@ics.muni.cz>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 backchannel authentication
Date: Thu, 9 Aug 2012 16:49:17 +0000
Message-ID: <1344530955.25447.38.camel@lade.trondhjem.org>
References: <20120806135517.GS25979@ics.muni.cz>
	 <20120807154114.GA21460@fieldses.org>
	 <1344355148.5781.31.camel@lade.trondhjem.org>
	 <20120808075813.GW604@horn.ics.muni.cz>
	 <1344431887.3423.4.camel@lade.trondhjem.org>
	 <20120809080642.GE604@horn.ics.muni.cz>
	 <20120809144530.GB6592@fieldses.org>
	 <1344527573.25447.17.camel@lade.trondhjem.org>
	 <20120809162801.GM11089@ics.muni.cz>
	 <1344529851.25447.33.camel@lade.trondhjem.org>
	 <20120809163846.GA8230@fieldses.org>
In-Reply-To: <20120809163846.GA8230@fieldses.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEyLTA4LTA5IGF0IDEyOjM4IC0wNDAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6
DQo+IE9uIFRodSwgQXVnIDA5LCAyMDEyIGF0IDA0OjMwOjUzUE0gKzAwMDAsIE15a2xlYnVzdCwg
VHJvbmQgd3JvdGU6DQo+ID4gT24gVGh1LCAyMDEyLTA4LTA5IGF0IDE4OjI4ICswMjAwLCBMdWth
cyBIZWp0bWFuZWsgd3JvdGU6DQo+ID4gPiBPbiBUaHUsIEF1ZyAwOSwgMjAxMiBhdCAwMzo1Mzow
MVBNICswMDAwLCBNeWtsZWJ1c3QsIFRyb25kIHdyb3RlOg0KPiA+ID4gPiBIb3cgaXMgdGhpcyBh
bnkgZGlmZmVyZW50IHRvIHJlcXVpcmluZyB0aGF0IHRoZSB1c2VyIHN0YXJ0IHJwYy5zdGF0ZA0K
PiA+ID4gPiBiZWZvcmUgbGF1bmNoaW5nIGFuIE5GU3YzIG1vdW50PyBKdXN0IGRvY3VtZW50IHRo
ZSByZXF1aXJlbWVudCBpZiBpdA0KPiA+ID4gPiBpc24ndCBhbHJlYWR5IGNsZWFyIGVub3VnaCwg
YW5kIHdlIGNhbiBtb3ZlIG9uLg0KPiA+ID4gPiANCj4gPiA+ID4gVGhlIG90aGVyIHNvdXJjZSBv
ZiBjb25mdXNpb24gaGVyZSwgd2FzIHRoYXQgdGhlIHJwYy5zdmNnc3NkIHdhcw0KPiA+ID4gPiBk
ZWxpdmVyZWQgdGhyb3VnaCBhIG5mcy1rZXJuZWwtc2VydmVyIHBhY2thZ2UsIHdoaWNoIGluZGlj
YXRlcyB0aGF0IHdlDQo+ID4gPiA+IGZpcnN0IGFuZCBmb3JlbW9zdCBuZWVkIHRvIGVkdWNhdGUg
dGhlIGRpc3RybyBwYWNrYWdlcnMuDQo+ID4gPiANCj4gPiA+IGhtbSwgaWYgYm90aCBycGMuZ3Nz
ZCBhbmQgcnBjLnN2Y2dzc2QgYXJlIG5lZWRlZCBvbiBjbGllbnRzIGFuZCBzZXJ2ZXJzLCBpc24n
dA0KPiA+ID4gaXQgd29ydGggb2YgbWVyZ2luZyB0aGVtIGludG8gYSBzaW5nbGUgcHJvY2Vzcz8N
Cj4gPiANCj4gPiBZb3UgZG9uJ3QgbmVlZCBycGMuZ3NzZCB0byB1c2UgcnBjc2VjX2dzcyB3aXRo
IE5GU3YzLCBub3IgZG8geW91IG5lZWQgaXQNCj4gCQkgXl5eXl5eXl4NCj4gDQo+IFlvdSBtZWFu
dCBycGMuc3ZjZ3NzZCwgdW5sZXNzIHlvdSB3ZXJlIHRoaW5raW5nIGFib3V0IHRoZSBuZnNkIHNp
ZGUuDQoNClllcy4NCg0KPiA+IGlmIHlvdSdyZSBub3QgaW50ZW5kaW5nIG9uIHVzaW5nIGRlbGVn
YXRpb25zIHdpdGggTkZTdjQuDQo+IA0KPiBUaG91Z2ggdGhlIGRlZmF1bHQgc2hvdWxkIGJlIHRv
IHN1cHBvcnQgZGVsZWdhdGlvbnMuDQoNClJpZ2h0LCBidXQgdGhhdCBpc24ndCBhIGp1c3RpZmlj
YXRpb24gZm9yIG1ha2luZyBpdCBpbXBvc3NpYmxlIHRvIHJ1bg0Kd2l0aG91dCBycGMuc3ZjZ3Nz
ZCBpZiB5b3UgZG9uJ3QgbmVlZCBpdC4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5G
UyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29t
DQp3d3cubmV0YXBwLmNvbQ0KDQo=
