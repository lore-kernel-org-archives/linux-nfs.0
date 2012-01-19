Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:18451 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753248Ab2ASPeE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jan 2012 10:34:04 -0500
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Subject: RE: [PATCH 0/5] SUNRPC: make caches network namespace aware
Date: Thu, 19 Jan 2012 07:34:02 -0800
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430CE01EE4@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <4F18376C.9090504@parallels.com>
References: <20120119144517.9957.59143.stgit@localhost6.localdomain6> <1326986392.6114.1.camel@lade.trondhjem.org> <4F18376C.9090504@parallels.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Stanislav Kinsbursky" <skinsbursky@parallels.com>
Cc: "Dr James Bruce Fields" <bfields@redhat.com>, <linux-nfs@vger.kernel.org>,
        "Pavel Emelianov" <xemul@parallels.com>, <neilb@suse.de>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        "James Bottomley" <jbottomley@parallels.com>, <bfields@fieldses.org>,
        <davem@davemloft.net>, <devel@openvz.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBTdGFuaXNsYXYgS2luc2J1cnNr
eSBbbWFpbHRvOnNraW5zYnVyc2t5QHBhcmFsbGVscy5jb21dDQo+IFNlbnQ6IFRodXJzZGF5LCBK
YW51YXJ5IDE5LCAyMDEyIDEwOjMyIEFNDQo+IFRvOiBNeWtsZWJ1c3QsIFRyb25kDQo+IENjOiBE
ciBKYW1lcyBCcnVjZSBGaWVsZHM7IGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc7IFBhdmVsIEVt
ZWxpYW5vdjsNCj4gbmVpbGJAc3VzZS5kZTsgbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsgbGludXgt
a2VybmVsQHZnZXIua2VybmVsLm9yZzsNCj4gSmFtZXMgQm90dG9tbGV5OyBiZmllbGRzQGZpZWxk
c2VzLm9yZzsgZGF2ZW1AZGF2ZW1sb2Z0Lm5ldDsNCj4gZGV2ZWxAb3BlbnZ6Lm9yZw0KPiBTdWJq
ZWN0OiBSZTogW1BBVENIIDAvNV0gU1VOUlBDOiBtYWtlIGNhY2hlcyBuZXR3b3JrIG5hbWVzcGFj
ZSBhd2FyZQ0KPiANCj4gMTkuMDEuMjAxMiAxOToxOSwgVHJvbmQgTXlrbGVidXN0INC/0LjRiNC1
0YI6DQo+ID4gT24gVGh1LCAyMDEyLTAxLTE5IGF0IDE4OjQ4ICswNDAwLCBTdGFuaXNsYXYgS2lu
c2J1cnNreSB3cm90ZToNCj4gPj4gT25lIG1vcmUgc3RlcCB0b3dhcmRzIHRvICJORlMgaW4gY29u
dGFpbmVyIi4NCj4gPj4gV2l0aCB0aGlzIHBhdGNoIHNldCBjYWNoZXMgYXJlIGFsbG9jYXRlZCBw
ZXIgbmV0d29yayBuYW1lc3BhY2UuDQo+ID4+DQo+ID4+IFRoZSBmb2xsb3dpbmcgc2VyaWVzIGNv
bnNpc3RzIG9mOg0KPiA+Pg0KPiA+PiAtLS0NCj4gPj4NCj4gPj4gU3RhbmlzbGF2IEtpbnNidXJz
a3kgKDUpOg0KPiA+PiAgICAgICAgU1VOUlBDOiBjYWNoZSBjcmVhdGlvbiBhbmQgZGVzdHJ1Y3Rp
b24gcm91dGluZXMgaW50cm9kdWNlZA0KPiA+PiAgICAgICAgU1VOUlBDOiBjcmVhdGUgdW5peCBn
aWQgY2FjaGUgcGVyIG5ldHdvcmsgbmFtZXNwYWNlDQo+ID4+ICAgICAgICBTVU5SUEM6IGNyZWF0
ZSBHU1MgYXV0aCBjYWNoZSBwZXIgbmV0d29yayBuYW1lc3BhY2UNCj4gPj4gICAgICAgIFNVTlJQ
QzogaXAgbWFwIGNhY2hlIHBlciBuZXR3b3JrIG5hbWVzcGFjZSBjbGVhbnVwDQo+ID4+ICAgICAg
ICBTVU5SUEM6IGdlbmVyaWMgY2FjaGUgcmVnaXN0ZXIgcm91dGluZXMgcmVtb3ZlZA0KPiA+DQo+
ID4gVGhlIHBhdGNoZXMgbG9vayBnb29kLCBhbmQgSSd2ZSBhcHBsaWVkIHRoZW0gZm9yIG5vdyBp
biBteSAnZGV2ZWwnDQo+ID4gYnJhbmNoIHNvIHdlIGNhbiB0ZXN0IHRoZW0sIGJ1dCBJJ2QgbGlr
ZSB0byBnZXQgYW4gQWNrL05hY2sgZnJvbSBCcnVjZQ0KPiA+IGJlZm9yZSBjb21taXR0aW5nIHRv
IG1lcmdpbmcgdGhlbS4NCj4gPg0KPiANCj4gQ29vbCwgdGhhbmtzLg0KPiBCVFcsIHRoZXNlIHBh
dGNoZXMgZGVwZW5kcyBvbiBwYXRjaCAiTkZTZDogdXNlIG5ldHdvcmstbmFtZXNwYWNlLQ0KPiBh
d2FyZSBjYWNoZSByZWdpc3RlcmluZyByb3V0aW5lcyIsIHdoaWNoIEJydWNlIHRvb2sgYWxyZWFk
eSAoYW5kIGl0J3MgZXZlbiBpbg0KPiBsaW51eC1uZXh0IGFscmVhZHkpLCBidXQgbm90IGluIHlv
dXIgZGV2ZWwgdHJlZSBmb3Igc29tZSByZWFzb24uDQoNCkluIHRoYXQgY2FzZSwgd291bGQgaXQg
bWFrZSBtb3JlIHNlbnNlIHRvIGNhcnJ5IHRoZW0gaW4gQnJ1Y2UncyB0cmVlPw0KDQotLQ0KVHJv
bmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9u
ZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0KDQo=
