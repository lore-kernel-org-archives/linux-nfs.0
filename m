Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:19820 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751215AbbDGStz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Apr 2015 14:49:55 -0400
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
        Haggai Eran <haggaie@mellanox.com>,
        Ilya Nelkenbaum <ilyan@mellanox.com>,
        Yann Droneaud <ydroneaud@opteya.com>,
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
Subject: RE: [PATCH v2 11/17] IB/Verbs: Reform link_layer_show() and
 ib_uverbs_query_port()
Date: Tue, 7 Apr 2015 18:49:52 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373A8FBE2FA@ORSMSX109.amr.corp.intel.com>
References: <5523CCD5.6030401@profitbricks.com>
 <5523CF30.7000608@profitbricks.com>
In-Reply-To: <5523CF30.7000608@profitbricks.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiBkaWZmIC0tZ2l0IGEvZHJpdmVycy9pbmZpbmliYW5kL2NvcmUvc3lzZnMuYw0KPiBiL2RyaXZl
cnMvaW5maW5pYmFuZC9jb3JlL3N5c2ZzLmMNCj4gaW5kZXggY2JkMDM4My4uYWE1M2U0MCAxMDA2
NDQNCj4gLS0tIGEvZHJpdmVycy9pbmZpbmliYW5kL2NvcmUvc3lzZnMuYw0KPiArKysgYi9kcml2
ZXJzL2luZmluaWJhbmQvY29yZS9zeXNmcy5jDQo+IEBAIC0yNDgsMTQgKzI0OCwxMCBAQCBzdGF0
aWMgc3NpemVfdCBwaHlzX3N0YXRlX3Nob3coc3RydWN0IGliX3BvcnQgKnAsDQo+IHN0cnVjdCBw
b3J0X2F0dHJpYnV0ZSAqdW51c2VkLA0KPiAgc3RhdGljIHNzaXplX3QgbGlua19sYXllcl9zaG93
KHN0cnVjdCBpYl9wb3J0ICpwLCBzdHJ1Y3QgcG9ydF9hdHRyaWJ1dGUNCj4gKnVudXNlZCwNCj4g
IAkJCSAgICAgICBjaGFyICpidWYpDQo+ICB7DQo+IC0Jc3dpdGNoIChyZG1hX3BvcnRfZ2V0X2xp
bmtfbGF5ZXIocC0+aWJkZXYsIHAtPnBvcnRfbnVtKSkgew0KPiAtCWNhc2UgSUJfTElOS19MQVlF
Ul9JTkZJTklCQU5EOg0KPiArCWlmIChyZG1hX3RyYW5zcG9ydF9pYihwLT5pYmRldiwgcC0+cG9y
dF9udW0pKQ0KPiAgCQlyZXR1cm4gc3ByaW50ZihidWYsICIlc1xuIiwgIkluZmluaUJhbmQiKTsN
Cj4gLQljYXNlIElCX0xJTktfTEFZRVJfRVRIRVJORVQ6DQo+ICsJZWxzZQ0KPiAgCQlyZXR1cm4g
c3ByaW50ZihidWYsICIlc1xuIiwgIkV0aGVybmV0Iik7DQo+IC0JZGVmYXVsdDoNCj4gLQkJcmV0
dXJuIHNwcmludGYoYnVmLCAiJXNcbiIsICJVbmtub3duIik7DQo+IC0JfQ0KPiAgfQ0KPiANCj4g
IHN0YXRpYyBQT1JUX0FUVFJfUk8oc3RhdGUpOw0KPiBkaWZmIC0tZ2l0IGEvZHJpdmVycy9pbmZp
bmliYW5kL2NvcmUvdXZlcmJzX2NtZC5jDQo+IGIvZHJpdmVycy9pbmZpbmliYW5kL2NvcmUvdXZl
cmJzX2NtZC5jDQo+IGluZGV4IGE5ZjA0ODkuLjNlYjZlYjUgMTAwNjQ0DQo+IC0tLSBhL2RyaXZl
cnMvaW5maW5pYmFuZC9jb3JlL3V2ZXJic19jbWQuYw0KPiArKysgYi9kcml2ZXJzL2luZmluaWJh
bmQvY29yZS91dmVyYnNfY21kLmMNCj4gQEAgLTUxNSw4ICs1MTUsMTAgQEAgc3NpemVfdCBpYl91
dmVyYnNfcXVlcnlfcG9ydChzdHJ1Y3QgaWJfdXZlcmJzX2ZpbGUNCj4gKmZpbGUsDQo+ICAJcmVz
cC5hY3RpdmVfd2lkdGggICAgPSBhdHRyLmFjdGl2ZV93aWR0aDsNCj4gIAlyZXNwLmFjdGl2ZV9z
cGVlZCAgICA9IGF0dHIuYWN0aXZlX3NwZWVkOw0KPiAgCXJlc3AucGh5c19zdGF0ZSAgICAgID0g
YXR0ci5waHlzX3N0YXRlOw0KPiAtCXJlc3AubGlua19sYXllciAgICAgID0gcmRtYV9wb3J0X2dl
dF9saW5rX2xheWVyKGZpbGUtPmRldmljZS0NCj4gPmliX2RldiwNCj4gLQkJCQkJCQljbWQucG9y
dF9udW0pOw0KPiArCXJlc3AubGlua19sYXllciAgICAgID0gcmRtYV90cmFuc3BvcnRfaWIoZmls
ZS0+ZGV2aWNlLT5pYl9kZXYsDQo+ICsJCQkJCQkJY21kLnBvcnRfbnVtKSA/DQo+ICsJCQkgICAg
ICAgSUJfTElOS19MQVlFUl9JTkZJTklCQU5EIDoNCj4gKwkJCSAgICAgICBJQl9MSU5LX0xBWUVS
X0VUSEVSTkVUOw0KPiANCj4gIAlpZiAoY29weV90b191c2VyKCh2b2lkIF9fdXNlciAqKSAodW5z
aWduZWQgbG9uZykgY21kLnJlc3BvbnNlLA0KPiAgCQkJICZyZXNwLCBzaXplb2YgcmVzcCkpDQoN
CkJvdGggb2YgdGhlIGFib3ZlIGNoZWNrIHRoZSB0cmFuc3BvcnQgaW4gb3JkZXIgdG8gZGV0ZXJt
aW5lIHRoZSBsaW5rIGxheWVyLg0KDQpUaGVzZSB2YWx1ZXMgYXJlIGV4cG9zZWQgdG8gdXNlciBz
cGFjZS4gIERvZXMgYW55b25lIGtub3cgd2hhdCBsaW5rIGxheWVyIGlXYXJwIHJldHVybnMgdG8g
dXNlciBzcGFjZT8gDQo=
