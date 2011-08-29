Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62696 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755133Ab1H2WIj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Aug 2011 18:08:39 -0400
Content-Type: text/plain;
	charset="utf-8"
Subject: RE: [PATCH 19/24] sunrpc: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 15:08:41 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AEB4F23@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <4E5C0AB3.90401@panasas.com>
References: <cover.1314650069.git.joe@perches.com> <8a6378b3fef105983db001fb720c84b669491439.1314650069.git.joe@perches.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AEB4EE9@SACMVEXC2-PRD.hq.netapp.com> <20110829.143751.1153162956919885670.davem@davemloft.net> <4E5C0AB3.90401@panasas.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Boaz Harrosh" <bharrosh@panasas.com>,
        "David Miller" <davem@davemloft.net>
Cc: <joe@perches.com>, <bfields@fieldses.org>, <neilb@suse.de>,
        <linux-nfs@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBCb2F6IEhhcnJvc2ggW21haWx0
bzpiaGFycm9zaEBwYW5hc2FzLmNvbV0NCj4gU2VudDogTW9uZGF5LCBBdWd1c3QgMjksIDIwMTEg
NTo1NSBQTQ0KPiBUbzogRGF2aWQgTWlsbGVyDQo+IENjOiBNeWtsZWJ1c3QsIFRyb25kOyBqb2VA
cGVyY2hlcy5jb207IGJmaWVsZHNAZmllbGRzZXMub3JnOw0KPiBuZWlsYkBzdXNlLmRlOyBsaW51
eC1uZnNAdmdlci5rZXJuZWwub3JnOyBuZXRkZXZAdmdlci5rZXJuZWwub3JnOw0KPiBsaW51eC1r
ZXJuZWxAdmdlci5rZXJuZWwub3JnDQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggMTkvMjRdIHN1bnJw
YzogUmVtb3ZlIHVubmVjZXNzYXJ5IE9PTSBsb2dnaW5nDQo+IG1lc3NhZ2VzDQo+IA0KPiBPbiAw
OC8yOS8yMDExIDAyOjM3IFBNLCBEYXZpZCBNaWxsZXIgd3JvdGU6DQo+ID4gRnJvbTogIk15a2xl
YnVzdCwgVHJvbmQiIDxUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbT4NCj4gPiBEYXRlOiBNb24s
IDI5IEF1ZyAyMDExIDE0OjM2OjE3IC0wNzAwDQo+ID4NCj4gPj4gQmlnIE5BQ0suLi4NCj4gPj4N
Cj4gPj4gQnkgd2hvc2Ugc3RhbmRhcmQgYXJlIHRob3NlICJub3QgdXNlZnVsIj8NCj4gPg0KPiA+
IEJ5IG1pbmUsIHRoYXQncyBmb3Igc3VyZS4gIEl0J3MgZHVwbGljYXRpbmcgc29tZXRoaW5nIHRo
YXQgdGhlDQo+IGFsbG9jYXRpb24NCj4gPiBsYXllcnMgYXJlIGFscmVhZHkgZ29pbmcgdG8gcHJp
bnQuDQo+IA0KPiBJIGhhdmUgYSBxdWVzdGlvbiBhYm91dCB0aGF0LiBBcmUgdGhlIGRwcmludHMg
Z29pbmcgdG8gc2hvdyB0aGUgc3RhY2sNCj4gYmFja3RyYWNlPw0KPiBPdGhlcndpc2UgaG93IGNh
biBJIHNlZSB3aGljaCBleGFjdCBhbGxvY2F0aW9uIGZhaWxlZCBhbmQgd2FzIG5vdA0KPiBwcm9w
ZXJseSBoYW5kbGVkPw0KPiANCj4gSWYgeWVzIGFib3ZlPyB0aGVuIEknbSBub3Qgc3VyZSBJIGxp
a2UgaXQgZWl0aGVyLCBiZWNhdXNlIGFtIEknbGwgYmUNCj4gZ2V0dGluZyBhIGZ1bGwNCj4gc3Rh
Y2sgYmFja3RyYWNlIGZvciBldmVyeSBmYWlsZWQgYWxsb2NhdGlvbj8NCj4gDQo+IEJ1dCBJIG1p
Z2h0IGxpa2UgaXQgaWYgSSB0cnkuIEhvdyBkbyBJIHR1cm4gb24gYWxsb2NhdGlvbiBmYWlsdXJl
cw0KPiBwcmludHM/DQo+IENhbiBJIGZpbHRlciBvdXQgdG8gcHJpbnQgb25seSBHRlBfS0VSTkVM
IGZhaWx1cmVzIGFuZCBvciBvdGhlciBHRlANCj4gY29tYmluYXRpb25zPw0KDQpSaWdodC4gSWYg
ZXZlcnkgR0ZQX0FUT01JQyBvciBHRlBfTk9XQUlUIGlzIGdvaW5nIHRvIHByaW50IG91dCBzdGFj
ayB0cmFjZXMsIHRoZW4gd2UncmUgaGVhZGluZyBmb3IgYWJzb2x1dGUgaW5zYW5pdHkuIElmIG5v
dCwgdGhlbiB0aGUgZXhpc3RpbmcgZHByaW50aygpcyBtYWtlIGEgbG90IG1vcmUgc2Vuc2UsICdj
b3MgdGhleSBhcmUgdHVybmVkIG9uIG9ubHkgd2hlbiB0aGUgYWRtaW5pc3RyYXRvciBub3RpY2Vz
IGEgcHJvYmxlbSwgYW5kIGlzIHRyeWluZyB0byBkZWJ1ZyBpdC4NCg0KVHJvbmQNCg0KTu+/ve+/
ve+/ve+/ve+/vXLvv73vv71577+977+977+9Yu+/vVjvv73vv73Hp3bvv71e77+9Kd66ey5u77+9
K++/ve+/ve+/ve+/vXvvv73vv73vv70i77+977+9Xm7vv71y77+977+977+9eu+/vRrvv73vv71o
77+977+977+977+9Ju+/ve+/vR7vv71H77+977+977+9aO+/vQMo77+96ZqO77+93aJqIu+/ve+/
vRrvv70bbe+/ve+/ve+/ve+/ve+/vXrvv73elu+/ve+/ve+/vWbvv73vv73vv71o77+977+977+9
fu+/vW3vv70=
