Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:9129 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752620AbbDGVZF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Apr 2015 17:25:05 -0400
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
Subject: RE: [PATCH v2 02/17] IB/Verbs: Implement raw management helpers
Date: Tue, 7 Apr 2015 21:25:02 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373A8FBE403@ORSMSX109.amr.corp.intel.com>
References: <5523CCD5.6030401@profitbricks.com>
 <5523CDA7.8090902@profitbricks.com>
In-Reply-To: <5523CDA7.8090902@profitbricks.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiArc3RhdGljIGlubGluZSBpbnQgcmRtYV90cmFuc3BvcnRfaWIoc3RydWN0IGliX2RldmljZSAq
ZGV2aWNlLCB1OA0KPiBwb3J0X251bSkNCj4gK3sNCj4gKwlyZXR1cm4gZGV2aWNlLT5xdWVyeV90
cmFuc3BvcnQoZGV2aWNlLCBwb3J0X251bSkNCj4gKwkJCT09IFJETUFfVFJBTlNQT1JUX0lCOw0K
PiArfQ0KPiArDQo+ICtzdGF0aWMgaW5saW5lIGludCByZG1hX3RyYW5zcG9ydF9pYm9lKHN0cnVj
dCBpYl9kZXZpY2UgKmRldmljZSwgdTgNCj4gcG9ydF9udW0pDQo+ICt7DQo+ICsJcmV0dXJuIGRl
dmljZS0+cXVlcnlfdHJhbnNwb3J0KGRldmljZSwgcG9ydF9udW0pDQo+ICsJCQk9PSBSRE1BX1RS
QU5TUE9SVF9JQk9FOw0KPiArfQ0KDQpXZSBuZWVkIHRvIGRvIHNvbWV0aGluZyB3aXRoIHRoZSBm
dW5jdGlvbiBuYW1lcyB0byBtYWtlIHRoZWlyIHVzZSBtb3JlIG9idmlvdXMuICBCb3RoIElCIGFu
ZCBJQm9FIGhhdmUgdHJhbnNwb3J0IElCLiAgSSB0aGluayBKYXNvbiBzdWdnZXN0ZWQgcmRtYV90
ZWNoX2liIC8gcmRtYV90ZWNoX2lib2UuDQoNClJlZ2FyZGluZyB0cmFuc3BvcnQgdHlwZXMsIEkg
YmVsaWV2ZSB0aGF0IHVzbmljIHN1cHBvcnRzIDIgZGlmZmVyZW50IHRyYW5zcG9ydHMuICBBbHRo
b3VnaCB1c25pYyBpc24ndCB1c2VkIGJ5IGFueXRoaW5nIGVsc2UgaW4gdGhlIGNvcmUgbGF5ZXIs
IHdlIHNob3VsZCBwcm9iYWJseSBiZSBhYmxlIHRvIGhhbmRsZSBhIGRldmljZSB0aGF0IHN1cHBv
cnRzIG11bHRpcGxlIHByb3RvY29scy4gIEknbSBub3Qgc3VyZSB3aGF0IHRoZSAndHJhbnNwb3J0
JyBzaG91bGQgYmUgZm9yIGlXYXJwLCBzaW5jZSBpV2FycCBpcyBsYXllcmVkIG92ZXIgVENQLiAg
QnV0IHRoYXQgbWF5IGp1c3QgbWVhbiB0aGF0IHRoZSB0ZXJtIHRyYW5zcG9ydCBpc24ndCBncmVh
dC4NCg0KLSBTZWFuDQo=
