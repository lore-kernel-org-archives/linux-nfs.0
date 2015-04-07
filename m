Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:9242 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751651AbbDGSkU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Apr 2015 14:40:20 -0400
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
Subject: RE: [PATCH v2 10/17] IB/Verbs: Adopt management helpers for IB
 helpers
Date: Tue, 7 Apr 2015 18:40:14 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373A8FBE2A5@ORSMSX109.amr.corp.intel.com>
References: <5523CCD5.6030401@profitbricks.com>
 <5523CF0A.5090206@profitbricks.com>
In-Reply-To: <5523CF0A.5090206@profitbricks.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiBkaWZmIC0tZ2l0IGEvZHJpdmVycy9pbmZpbmliYW5kL2NvcmUvc2FfcXVlcnkuYw0KPiBiL2Ry
aXZlcnMvaW5maW5pYmFuZC9jb3JlL3NhX3F1ZXJ5LmMNCj4gaW5kZXggZjcwNDI1NC4uNGU2MTEw
NCAxMDA2NDQNCj4gLS0tIGEvZHJpdmVycy9pbmZpbmliYW5kL2NvcmUvc2FfcXVlcnkuYw0KPiAr
KysgYi9kcml2ZXJzL2luZmluaWJhbmQvY29yZS9zYV9xdWVyeS5jDQo+IEBAIC01NDAsNyArNTQw
LDcgQEAgaW50IGliX2luaXRfYWhfZnJvbV9wYXRoKHN0cnVjdCBpYl9kZXZpY2UgKmRldmljZSwg
dTgNCj4gcG9ydF9udW0sDQo+ICAJYWhfYXR0ci0+cG9ydF9udW0gPSBwb3J0X251bTsNCj4gIAlh
aF9hdHRyLT5zdGF0aWNfcmF0ZSA9IHJlYy0+cmF0ZTsNCj4gDQo+IC0JZm9yY2VfZ3JoID0gcmRt
YV9wb3J0X2dldF9saW5rX2xheWVyKGRldmljZSwgcG9ydF9udW0pID09DQo+IElCX0xJTktfTEFZ
RVJfRVRIRVJORVQ7DQo+ICsJZm9yY2VfZ3JoID0gIXJkbWFfdHJhbnNwb3J0X2liKGRldmljZSwg
cG9ydF9udW0pOw0KPiANCj4gIAlpZiAocmVjLT5ob3BfbGltaXQgPiAxIHx8IGZvcmNlX2dyaCkg
ew0KPiAgCQlhaF9hdHRyLT5haF9mbGFncyA9IElCX0FIX0dSSDsNCj4gZGlmZiAtLWdpdCBhL2Ry
aXZlcnMvaW5maW5pYmFuZC9jb3JlL3ZlcmJzLmMNCj4gYi9kcml2ZXJzL2luZmluaWJhbmQvY29y
ZS92ZXJicy5jDQo+IGluZGV4IDgzMzcwZGUuLmNhMDZmNzYgMTAwNjQ0DQo+IC0tLSBhL2RyaXZl
cnMvaW5maW5pYmFuZC9jb3JlL3ZlcmJzLmMNCj4gKysrIGIvZHJpdmVycy9pbmZpbmliYW5kL2Nv
cmUvdmVyYnMuYw0KPiBAQCAtMjAwLDExICsyMDAsOSBAQCBpbnQgaWJfaW5pdF9haF9mcm9tX3dj
KHN0cnVjdCBpYl9kZXZpY2UgKmRldmljZSwgdTgNCj4gcG9ydF9udW0sIHN0cnVjdCBpYl93YyAq
d2MsDQo+ICAJdTMyIGZsb3dfY2xhc3M7DQo+ICAJdTE2IGdpZF9pbmRleDsNCj4gIAlpbnQgcmV0
Ow0KPiAtCWludCBpc19ldGggPSAocmRtYV9wb3J0X2dldF9saW5rX2xheWVyKGRldmljZSwgcG9y
dF9udW0pID09DQo+IC0JCQlJQl9MSU5LX0xBWUVSX0VUSEVSTkVUKTsNCj4gDQo+ICAJbWVtc2V0
KGFoX2F0dHIsIDAsIHNpemVvZiAqYWhfYXR0cik7DQo+IC0JaWYgKGlzX2V0aCkgew0KPiArCWlm
ICghcmRtYV90cmFuc3BvcnRfaWIoZGV2aWNlLCBwb3J0X251bSkpIHsNCj4gIAkJaWYgKCEod2Mt
PndjX2ZsYWdzICYgSUJfV0NfR1JIKSkNCj4gIAkJCXJldHVybiAtRVBST1RPVFlQRTsNCj4gDQo+
IEBAIC04NzMsNyArODcxLDcgQEAgaW50IGliX3Jlc29sdmVfZXRoX2wyX2F0dHJzKHN0cnVjdCBp
Yl9xcCAqcXAsDQo+ICAJdW5pb24gaWJfZ2lkICBzZ2lkOw0KPiANCj4gIAlpZiAoKCpxcF9hdHRy
X21hc2sgJiBJQl9RUF9BVikgICYmDQo+IC0JICAgIChyZG1hX3BvcnRfZ2V0X2xpbmtfbGF5ZXIo
cXAtPmRldmljZSwgcXBfYXR0ci0+YWhfYXR0ci5wb3J0X251bSkNCj4gPT0gSUJfTElOS19MQVlF
Ul9FVEhFUk5FVCkpIHsNCj4gKwkgICAgKCFyZG1hX3RyYW5zcG9ydF9pYihxcC0+ZGV2aWNlLCBx
cF9hdHRyLT5haF9hdHRyLnBvcnRfbnVtKSkpIHsNCj4gIAkJcmV0ID0gaWJfcXVlcnlfZ2lkKHFw
LT5kZXZpY2UsIHFwX2F0dHItPmFoX2F0dHIucG9ydF9udW0sDQo+ICAJCQkJICAgcXBfYXR0ci0+
YWhfYXR0ci5ncmguc2dpZF9pbmRleCwgJnNnaWQpOw0KPiAgCQlpZiAocmV0KQ0KDQpUaGUgYWJv
dmUgY2hlY2tzIHdvdWxkIGJlIGJldHRlciBhczoNCg0KCWZvcmNlX2dyaCA9IHJkbWFfdHJhbnNw
b3J0X2lib2UoLi4uKQ0KDQpUaGV5IGFyZSBSb0NFL0lCb0Ugc3BlY2lmaWMgY2hlY2tzLg0K
