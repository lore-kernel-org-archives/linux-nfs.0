Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr690134.outbound.protection.outlook.com ([40.107.69.134]:12671
        "EHLO NAM04-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1729826AbeGVTaz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 22 Jul 2018 15:30:55 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "nixiaoming@huawei.com" <nixiaoming@huawei.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>
Subject: Re: [PATCH] fs/nfsd: Delete invalid assignment statements in
 nfsd4_decode_exchange_id
Date: Sun, 22 Jul 2018 18:33:15 +0000
Message-ID: <a6be2d3bf2ff5ac43f82dcb7b29ba32faccbbdaf.camel@hammerspace.com>
References: <20180722085044.50701-1-nixiaoming@huawei.com>
         <2C39A9CD-4591-46C8-BB25-5FA2C85149CE@oracle.com>
In-Reply-To: <2C39A9CD-4591-46C8-BB25-5FA2C85149CE@oracle.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gU3VuLCAyMDE4LTA3LTIyIGF0IDE0OjEyIC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBKdWwgMjIsIDIwMTgsIGF0IDQ6NTAgQU0sIG5peGlhb21pbmcgPG5peGlhb21pbmdAaHVh
d2VpLmNvbT4NCj4gPiB3cm90ZToNCj4gPiANCj4gPiBkdW1teSA9IGJlMzJfdG9fY3B1cChwKysp
Ow0KPiA+IGR1bW15ID0gYmUzMl90b19jcHVwKHArKyk7DQo+ID4gQXNzaWduaW5nIHZhbHVlIHRv
ICJkdW1teSIgaGVyZSwgYnV0IHRoYXQgc3RvcmVkIHZhbHVlDQo+ID4gaXMgb3ZlcndyaXR0ZW4g
YmVmb3JlIGl0IGNhbiBiZSB1c2VkLg0KPiA+IA0KPiA+IGRlbGV0ZSBpbnZhbGlkIGFzc2lnbm1l
bnQgc3RhdGVtZW50cyBpbiBuZnNkNF9kZWNvZGVfZXhjaGFuZ2VfaWQNCj4gPiANCj4gPiBTaWdu
ZWQtb2ZmLWJ5OiBuMDAyMDI3NTQgPG5peGlhb21pbmdAaHVhd2VpLmNvbT4NCj4gPiAtLS0NCj4g
PiBmcy9uZnNkL25mczR4ZHIuYyB8IDQgKystLQ0KPiA+IDEgZmlsZSBjaGFuZ2VkLCAyIGluc2Vy
dGlvbnMoKyksIDIgZGVsZXRpb25zKC0pDQo+ID4gDQo+ID4gZGlmZiAtLWdpdCBhL2ZzL25mc2Qv
bmZzNHhkci5jIGIvZnMvbmZzZC9uZnM0eGRyLmMNCj4gPiBpbmRleCBhOTY4NDNjLi44ZTc4NTQx
IDEwMDY0NA0KPiA+IC0tLSBhL2ZzL25mc2QvbmZzNHhkci5jDQo+ID4gKysrIGIvZnMvbmZzZC9u
ZnM0eGRyLmMNCj4gPiBAQCAtMTM5Miw4ICsxMzkyLDggQEAgbmZzZDRfZGVjb2RlX2V4Y2hhbmdl
X2lkKHN0cnVjdA0KPiA+IG5mc2Q0X2NvbXBvdW5kYXJncyAqYXJncCwNCj4gPiANCj4gPiAJCS8q
IHNzcF93aW5kb3cgYW5kIHNzcF9udW1fZ3NzX2hhbmRsZXMgKi8NCj4gPiAJCVJFQURfQlVGKDgp
Ow0KPiA+IC0JCWR1bW15ID0gYmUzMl90b19jcHVwKHArKyk7DQo+ID4gLQkJZHVtbXkgPSBiZTMy
X3RvX2NwdXAocCsrKTsNCj4gPiArCQliZTMyX3RvX2NwdXAocCsrKTsNCj4gPiArCQliZTMyX3Rv
X2NwdXAocCsrKTsNCj4gDQo+IElmIHRoZXNlIHZhbHVlcyBhcmUgbm90IHVzZWQsIHdoYXQncyB0
aGUgcG9pbnQgb2YgYnl0ZSBzd2FwcGluZyB0aGVtPw0KPiBTdXJlbHkgInAgKz0gMjsiIHNob3Vs
ZCBiZSBlbm91Z2guDQo+IA0KPiANCj4gPiAJCWJyZWFrOw0KPiA+IAlkZWZhdWx0Og0KPiA+IAkJ
Z290byB4ZHJfZXJyb3I7DQo+IA0KDQpHaXZlbiB0aGF0IHRoZSB2YWx1ZSBvZiAncCcgaXNuJ3Qg
dXNlZCBlaXRoZXIsIHdoeSBub3QganVzdCBkZWxldGUNCnRob3NlIHR3byBsaW5lcyBhbHRvZ2V0
aGVyPw0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVy
LCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
