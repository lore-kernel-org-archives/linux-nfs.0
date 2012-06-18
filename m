Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52214 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752005Ab2FRN3F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Jun 2012 09:29:05 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Andre Tomt <andre@tomt.net>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Linux-NFS <linux-nfs@vger.kernel.org>,
        Fengguang Wu <fengguang.wu@intel.com>,
        "David Howells" <dhowells@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: BUG in __key_instantiate_and_link(): unable to handle kernel
 paging request at 0000632e6472616f
Date: Mon, 18 Jun 2012 13:28:49 +0000
Message-ID: <1340026127.2451.7.camel@lade.trondhjem.org>
References: <20120601034114.GA9248@localhost> <4FDBF056.7040404@tomt.net>
	  <4FDCD3C7.5080503@tomt.net> <1339876739.8267.96.camel@lade.trondhjem.org>
	 <4FDEEF38.8030101@tomt.net>
In-Reply-To: <4FDEEF38.8030101@tomt.net>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTA2LTE4IGF0IDExOjA0ICswMjAwLCBBbmRyZSBUb210IHdyb3RlOg0KPiBP
biAxNi4ganVuaSAyMDEyIDIxOjU5LCBNeWtsZWJ1c3QsIFRyb25kIHdyb3RlOg0KPiA+IEl0IGxv
b2tzIHRvIG1lIGFzIGlmIHRoZSBsZWdhY3kgdXBjYWxsIGNvZGUgaXMgYXNzdW1pbmcgdGhhdCB0
aGVyZSBjYW4NCj4gPiBiZSBubyBtb3JlIHRoYW4gMSB1cGNhbGwgYXQgYSB0aW1lOiB0aGVyZSBp
cyBvbmx5IGEgc2luZ2xlDQo+ID4gaWRtYXAtPmlkbWFwX2tleV9jb25zLCB3aGljaCBnZXRzIGFz
c2lnbmVkIGluIG5mc19pZG1hcF9sZWdhY3lfdXBjYWxsDQo+ID4gYW5kIHRoZW4gcmVhZCBpbiBp
ZG1hcF9waXBlX2Rvd25jYWxsLg0KPiA+DQo+ID4gQnJ5YW4sIGNhbiB5b3UgbG9vayBpbnRvIHRo
aXM/IEkgc3VzcGVjdCB0aGF0IHdlIG5lZWQgYSBtdXRleCBvcg0KPiA+IHNvbWV0aGluZyBsaWtl
IHRoYXQgKGZvciB0aGUgbGVnYWN5IHVwY2FsbCBjYXNlIG9ubHkpIHRvIGVuc3VyZSB0aGF0DQo+
ID4gbm9ib2R5IG92ZXJ3cml0ZXMgdGhlIGlkbWFwLT5pZG1hcF9rZXlfY29ucyB3aGlsZSBhbiB1
cGNhbGwgaXMgaW4NCj4gPiBwcm9ncmVzcy4NCj4gPg0KPiA+IEFuZHJlLCBpZiB5b3Ugd2FudCBp
ZG1hcHBlciBzY2FsYWJpbGl0eSwgdGhlbiB5b3Ugc2hvdWxkIHJhdGhlciB1c2UgdGhlDQo+ID4g
bmV3IGlkbWFwcGVyIHVwY2FsbC4gWW91IG5lZWQgYSByZWNlbnQgdmVyc2lvbiBvZiB0aGUgbmZz
LXV0aWxzIHBhY2thZ2UsDQo+ID4gdGhlIGtleXV0aWxzIHBhY2thZ2UsIGFuZCB0aGV5IHlvdSBz
aG91bGQgYWRkIGFuICdpZF9yZXNvbHZlcicgbGluZQ0KPiA+IHRvIC9ldGMvcmVxdWVzdC1rZXlz
LmNvbmYgYXMgcGVyIHRoZSBuZnNpZG1hcCBtYW5wYWdlLg0KPiANCj4gSW5kZWVkLCB1c2luZyBr
ZXl1dGlscyBkaWQgYXZvaWQgdGhlIGNyYXNoZXMgaGVyZSwgNDAgaG91cnMgYW5kIGNvdW50aW5n
Lg0KPiANCj4gQXJlIHRoZXJlIGFueSBkb3duc2lkZXMgb2YgaGF2aW5nIGtleXV0aWxzIHcvIGlk
X3Jlc29sdmVyIG9uIGJ5IGRlZmF1bHQgDQo+IGluIGEgZGlzdHJpYnV0aW9uPyBXb3VsZCBpdCBi
cmVhayBvbGRlciBrZXJuZWxzIG9yIG5mcy11dGlscyAoanVzdCBub3QgDQo+IGdldHRpbmcgdXNl
ZCBpcyBmaW5lLCBvYnZpb3VzbHkpPw0KDQpPbGRlciBrZXJuZWxzIGFyZW4ndCBhYmxlIHRvIHVz
ZSB0aGUga2V5dXRpbHMgbWVjaGFuaXNtLCBzbyB0aGV5IHdpbGwNCnN0aWxsIHJlcXVpcmUgeW91
IHRvIHJ1biB0aGUgaWRtYXBkIGRhZW1vbiwgYnV0IHRoZXJlIHNob3VsZCBiZSBubw0KcHJvYmxl
bXMgd2l0aCBqdXN0IGVuYWJsaW5nIGl0IGluIC9ldGMvcmVxdWVzdC1rZXkuY29uZi4NCkZlZG9y
YSAxNyBpcyBzdXBwb3NlZCB0byBpbnN0YWxsIHRoZSBpZF9yZXNvbHZlciBieSBkZWZhdWx0Lg0K
DQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5l
dEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQoNCg==
