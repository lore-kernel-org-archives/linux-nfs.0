Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:21798 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754231AbbDHRCW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Apr 2015 13:02:22 -0400
From: "Hefty, Sean" <sean.hefty@intel.com>
To: Michael Wang <yun.wang@profitbricks.com>,
        Roland Dreier <roland@kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
CC: Hal Rosenstock <hal.rosenstock@gmail.com>,
        Tom Tucker <tom@opengridcomputing.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
        Christoph Raisch <raisch@de.ibm.com>,
        infinipath <infinipath@intel.com>, Eli Cohen <eli@mellanox.com>,
        "Latif, Faisal" <faisal.latif@intel.com>,
        Upinder Malhi <umalhi@cisco.com>,
        "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        "Weiny, Ira" <ira.weiny@intel.com>,
        PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
        "Nikolova, Tatyana E" <tatyana.e.nikolova@intel.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        "Haggai Eran" <haggaie@mellanox.com>,
        Ilya Nelkenbaum <ilyan@mellanox.com>,
        "Yann Droneaud" <ydroneaud@opteya.com>,
        Bart Van Assche <bvanassche@acm.org>,
        Shachar Raindel <raindel@mellanox.com>,
        Sagi Grimberg <sagig@mellanox.com>,
        Devesh Sharma <devesh.sharma@emulex.com>,
        Matan Barak <matanb@mellanox.com>, Moni Shoua <monis@mellanox.com>,
        Jiri Kosina <jkosina@suse.cz>,
        Selvin Xavier <selvin.xavier@emulex.com>,
        Mitesh Ahuja <mitesh.ahuja@emulex.com>,
        "Li RongQing" <roy.qing.li@gmail.com>,
        Rasmus Villemoes <linux@rasmusvillemoes.dk>,
        "Estrin, Alex" <alex.estrin@intel.com>,
        "Doug Ledford" <dledford@redhat.com>,
        Eric Dumazet <edumazet@google.com>,
        "Erez Shitrit" <erezsh@mellanox.com>, Tom Gundersen <teg@jklm.no>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: RE: [PATCH v2 13/17] IB/Verbs: Reform cma/ucma with management
 helpers
Date: Wed, 8 Apr 2015 17:02:11 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373A8FBF037@ORSMSX109.amr.corp.intel.com>
References: <5523CCD5.6030401@profitbricks.com>
 <5523CF74.8020004@profitbricks.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FBE42B@ORSMSX109.amr.corp.intel.com>
 <5524F6BD.30105@profitbricks.com>
In-Reply-To: <5524F6BD.30105@profitbricks.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiBPbiAwNC8wNy8yMDE1IDExOjM2IFBNLCBIZWZ0eSwgU2VhbiB3cm90ZToNCj4gPj4gZGlmZiAt
LWdpdCBhL2RyaXZlcnMvaW5maW5pYmFuZC9jb3JlL2NtYS5jDQo+IGIvZHJpdmVycy9pbmZpbmli
YW5kL2NvcmUvY21hLmMNCj4gPj4gaW5kZXggZDhhOGVhNy4uYzIzZjQ4MyAxMDA2NDQNCj4gPj4g
LS0tIGEvZHJpdmVycy9pbmZpbmliYW5kL2NvcmUvY21hLmMNCj4gPj4gKysrIGIvZHJpdmVycy9p
bmZpbmliYW5kL2NvcmUvY21hLmMNCj4gPj4gQEAgLTQzNSwxMCArNDM1LDEwIEBAIHN0YXRpYyBp
bnQgY21hX3Jlc29sdmVfaWJfZGV2KHN0cnVjdA0KPiByZG1hX2lkX3ByaXZhdGUNCj4gPj4gKmlk
X3ByaXYpDQo+ID4+ICAJcGtleSA9IG50b2hzKGFkZHItPnNpYl9wa2V5KTsNCj4gPj4NCj4gPj4g
IAlsaXN0X2Zvcl9lYWNoX2VudHJ5KGN1cl9kZXYsICZkZXZfbGlzdCwgbGlzdCkgew0KPiA+PiAt
CQlpZiAocmRtYV9ub2RlX2dldF90cmFuc3BvcnQoY3VyX2Rldi0+ZGV2aWNlLT5ub2RlX3R5cGUp
ICE9DQo+ID4+IFJETUFfVFJBTlNQT1JUX0lCKQ0KPiA+PiAtCQkJY29udGludWU7DQo+ID4+IC0N
Cj4gPj4gIAkJZm9yIChwID0gMTsgcCA8PSBjdXJfZGV2LT5kZXZpY2UtPnBoeXNfcG9ydF9jbnQ7
ICsrcCkgew0KPiA+PiArCQkJaWYgKCFyZG1hX2liX21nbXQoY3VyX2Rldi0+ZGV2aWNlLCBwKSkN
Cj4gPj4gKwkJCQljb250aW51ZTsNCj4gPg0KPiA+IFRoaXMgY2hlY2sgd2FudHMgdG8gYmUgc29t
ZXRoaW5nIGxpa2UgaXNfYWZfaWJfc3VwcG9ydGVkKCkuICBDaGVja2luZw0KPiBmb3IgSUIgdHJh
bnNwb3J0IG1heSBhY3R1YWxseSBiZSBiZXR0ZXIgdGhhbiBjaGVja2luZyBmb3IgSUIgbWFuYWdl
bWVudC4NCj4gSSBkb24ndCBrbm93IGlmIElCb0UvUm9DRSBkZXZpY2VzIHN1cHBvcnQgQUZfSUIu
DQo+IA0KPiBUaGUgd3JhcHBlciBtYWtlIHNlbnNlLCBidXQgZG8gd2UgaGF2ZSB0aGUgZ3VhcmFu
dGVlIHRoYXQgSUJvRSBwb3J0IHdvbid0DQo+IGJlIHVzZWQgZm9yIEFGX0lCIGFkZHJlc3M/IEkg
anVzdCBjYW4ndCBsb2NhdGUgdGhlIHBsYWNlIHdlIGZpbHRlcmVkIGl0DQo+IG91dC4uLg0KDQpJ
IGNhbid0IHRoaW5rIG9mIGEgcmVhc29uIHdoeSBJQm9FIHdvdWxkbid0IHdvcmsgd2l0aCBBRl9J
QiwgYnV0IEknbSBub3Qgc3VyZSBpZiBhbnlvbmUgaGFzIHRlc3RlZCBpdC4gIFRoZSBvcmlnaW5h
bCBjaGVjayB3b3VsZCBoYXZlIGxldCBJQm9FIHRocm91Z2guICBXaGVuIEkgc3VnZ2VzdGVkIGNo
ZWNraW5nIGZvciBJQiB0cmFuc3BvcnQsIEkgbWVhbnQgdGhlIGFjdHVhbCB0cmFuc3BvcnQgcHJv
dG9jb2wsIHdoaWNoIHdvdWxkIGhhdmUgaW5jbHVkZWQgYm90aCBJQiBhbmQgSUJvRS4NCg0KPiA+
PiBAQCAtNzAwLDggKzcwMCw3IEBAIHN0YXRpYyBpbnQgY21hX2liX2luaXRfcXBfYXR0cihzdHJ1
Y3QNCj4gcmRtYV9pZF9wcml2YXRlDQo+ID4+ICppZF9wcml2LA0KPiA+PiAgCWludCByZXQ7DQo+
ID4+ICAJdTE2IHBrZXk7DQo+ID4+DQo+ID4+IC0JaWYgKHJkbWFfcG9ydF9nZXRfbGlua19sYXll
cihpZF9wcml2LT5pZC5kZXZpY2UsIGlkX3ByaXYtDQo+ID4+PiBpZC5wb3J0X251bSkgPT0NCj4g
Pj4gLQkgICAgSUJfTElOS19MQVlFUl9JTkZJTklCQU5EKQ0KPiA+PiArCWlmIChyZG1hX3RyYW5z
cG9ydF9pYihpZF9wcml2LT5pZC5kZXZpY2UsIGlkX3ByaXYtPmlkLnBvcnRfbnVtKSkNCj4gPj4g
IAkJcGtleSA9IGliX2FkZHJfZ2V0X3BrZXkoZGV2X2FkZHIpOw0KPiA+PiAgCWVsc2UNCj4gPj4g
IAkJcGtleSA9IDB4ZmZmZjsNCj4gPg0KPiA+IENoZWNrIGhlcmUgc2hvdWxkIGJlIGFnYWluc3Qg
dGhlIGxpbmsgbGF5ZXIsIG5vdCB0cmFuc3BvcnQuDQo+IA0KPiBJIGd1ZXNzIHRoZSBuYW1lIGNv
bmZ1c2luZyB1cyBhZ2Fpbi4uLiB3aGF0IGlmIHVzZSByZG1hX3RlY2hfaWIoKSBoZXJlPw0KPiBp
dCdzIHRoZSBvbmx5IHRlY2ggdXNpbmcgSUIgbGluayBsYXllcnMsIG90aGVycyBhcmUgYWxsIEVU
SC4NCg0KWWVzLCB0aGF0IHdvdWxkIHdvcmsuDQoNCj4gPj4gIAlpZF9wcml2LT5pZC5yb3V0ZS5h
ZGRyLmRldl9hZGRyLmRldl90eXBlID0NCj4gPj4gLQkJKHJkbWFfcG9ydF9nZXRfbGlua19sYXll
cihjbWFfZGV2LT5kZXZpY2UsIHApID09DQo+ID4+IElCX0xJTktfTEFZRVJfSU5GSU5JQkFORCkg
Pw0KPiA+PiArCQkocmRtYV90cmFuc3BvcnRfaWIoY21hX2Rldi0+ZGV2aWNlLCBwKSkgPw0KPiA+
PiAgCQlBUlBIUkRfSU5GSU5JQkFORCA6IEFSUEhSRF9FVEhFUjsNCj4gPg0KPiA+IFRoaXMgd2Fu
dHMgdGhlIGxpbmsgbGF5ZXIsIG9yIG1heWJlIHVzZSBjYXBfaXBvaWIuDQo+IA0KPiBJcyB0aGlz
IHJlbGF0ZWQgd2l0aCBpcG9pYiBvbmx5Pw0KDQpBUlBIRFJfSU5GSU5JQkFORCBpcyByZWxhdGVk
IHRvIGlwb2liLiAgSW4geW91ciBuZXh0IHVwZGF0ZSwgbWF5YmUgZ28gd2l0aCB0ZWNoX2liLiAg
SSBkb24ndCBrbm93IHRoZSBzdGF0dXMgb2YgaXBvaWIgb3ZlciBpYm9lLg0KDQo=
