Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:45988 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752906Ab2BHUvV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 15:51:21 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH 1/2] NFSv4.1: Convert slotid from u8 to u32
Date: Wed, 8 Feb 2012 20:50:55 +0000
Message-ID: <1328734255.3234.32.camel@lade.trondhjem.org>
References: <1328576237-7362-1-git-send-email-Trond.Myklebust@netapp.com>
	 <20120208162322.GA13315@fieldses.org>
	 <1328722042.3234.13.camel@lade.trondhjem.org>
	 <20120208174901.GA28564@umich.edu> <20120208183151.GA14316@fieldses.org>
	 <20120208203140.GA29238@umich.edu>
In-Reply-To: <20120208203140.GA29238@umich.edu>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTAyLTA4IGF0IDE1OjMxIC0wNTAwLCBKaW0gUmVlcyB3cm90ZToNCj4gSi4g
QnJ1Y2UgRmllbGRzIHdyb3RlOg0KPiANCj4gICBPbiBXZWQsIEZlYiAwOCwgMjAxMiBhdCAxMjo0
OTowMVBNIC0wNTAwLCBKaW0gUmVlcyB3cm90ZToNCj4gICA+IE15a2xlYnVzdCwgVHJvbmQgd3Jv
dGU6DQo+ICAgPiANCj4gICA+ICAgMTBHaWdFICsgaGlnaCBsYXRlbmNpZXMgaXMgZXhhY3RseSB3
aGVyZSB3ZSdyZSBzZWVpbmcgdGhlIHZhbHVlLiBBbmR5DQo+ICAgPiAgIGhhcyBiZWVuIHdvcmtp
bmcgd2l0aCB0aGUgaGlnaCBlbmVyZ3kgcGh5c2ljcyBjb21tdW5pdHkgZG9pbmcgTkZTDQo+ICAg
PiAgIHRyYWZmaWMgYmV0d2VlbiB0aGUgVVMgYW5kIENFUk4uLi4NCj4gICA+IA0KPiAgID4gQ0lU
SSB0byBDRVJOIGlzIGp1c3Qgb3ZlciAxMjBtcy4gIEkgZG9uJ3Qga25vdyB3aGF0IGl0IHdvdWxk
IGJlIGZyb20gQW5keSdzDQo+ICAgPiBob3VzZS4gIERvZXMgaGUgaGF2ZSAxMEcgYXQgaG9tZSB5
ZXQ/DQo+ICAgDQo+ICAgVGhhdCBzdGlsbCBzZWVtcyBzaG9ydCBvZiB3aGF0IHlvdSdkIG5lZWQg
dG8gZ2V0IGEgMjU1TUIgYmFuZHdpZHRoLWRlbGF5DQo+ICAgcHJvZHVjdC4NCj4gICANCj4gICBJ
J20ganVzdCBjdXJpb3VzIHdoYXQgdGhlIGV4cGVyaW1lbnQgaXMgaGVyZSBhbmQgd2hldGhlciB0
aGVyZSdzIGENCj4gICBwb3NzaWJpbGl0eSB0aGUgcmVhbCBwcm9ibGVtIGlzIGVsc2V3aGVyZS4N
Cj4gDQo+IEluIG15IG9waW5pb24sIGFueSBmaXggdGhhdCBpbnZvbHZlcyBhbGxvY2F0aW5nIG11
bHRpcGxlIHBhcmFsbGVsIGRhdGENCj4gc3RyZWFtcyAocnBjIHNsb3RzLCB0Y3AgY29ubmVjdGlv
bnMpIGlzIG1hc2tpbmcgdGhlIHJlYWwgcHJvYmxlbS4gIEJ1dCBpdCdzDQo+IGFuIGVmZmVjdGl2
ZSBmaXguDQoNCldobyBzYWlkIGFueXRoaW5nIGFib3V0IG11bHRpcGxlIHRjcCBjb25uZWN0aW9u
cz8gQWxsIHRoZSBzbG90cyBkbyBpcw0KYWxsb3cgdGhlIHNlcnZlciB0byBwcm9jZXNzIG1vcmUg
UlBDIGNhbGxzIGluIHBhcmFsbGVsIGJ5IGZlZWRpbmcgaXQNCm1vcmUgd29yay4gSG93IGlzIHRo
YXQgbWFza2luZyBhIHByb2JsZW0/DQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMg
Y2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0K
d3d3Lm5ldGFwcC5jb20NCg0K
