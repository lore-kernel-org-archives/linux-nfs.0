Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr680124.outbound.protection.outlook.com ([40.107.68.124]:9376
        "EHLO NAM04-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1730469AbeGVUF5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 22 Jul 2018 16:05:57 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "nixiaoming@huawei.com" <nixiaoming@huawei.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>
Subject: Re: [PATCH] fs/nfsd: Delete invalid assignment statements in
 nfsd4_decode_exchange_id
Date: Sun, 22 Jul 2018 19:08:09 +0000
Message-ID: <e0ee80246f7bb7587beac3f8d90f94cc6b7e6aff.camel@hammerspace.com>
References: <20180722085044.50701-1-nixiaoming@huawei.com>
         <2C39A9CD-4591-46C8-BB25-5FA2C85149CE@oracle.com>
         <a6be2d3bf2ff5ac43f82dcb7b29ba32faccbbdaf.camel@hammerspace.com>
         <8B9E4DFD-F651-4478-A82E-CDB759BB1A69@oracle.com>
In-Reply-To: <8B9E4DFD-F651-4478-A82E-CDB759BB1A69@oracle.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gU3VuLCAyMDE4LTA3LTIyIGF0IDE1OjAxIC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBKdWwgMjIsIDIwMTgsIGF0IDI6MzMgUE0sIFRyb25kIE15a2xlYnVzdCA8DQo+ID4gdHJv
bmRteUBoYW1tZXJzcGFjZS5jb20+IHdyb3RlOg0KPiA+IA0KPiA+IE9uIFN1biwgMjAxOC0wNy0y
MiBhdCAxNDoxMiAtMDQwMCwgQ2h1Y2sgTGV2ZXIgd3JvdGU6DQo+ID4gPiA+IE9uIEp1bCAyMiwg
MjAxOCwgYXQgNDo1MCBBTSwgbml4aWFvbWluZyA8bml4aWFvbWluZ0BodWF3ZWkuY29tPg0KPiA+
ID4gPiB3cm90ZToNCj4gPiA+ID4gDQo+ID4gPiA+IGR1bW15ID0gYmUzMl90b19jcHVwKHArKyk7
DQo+ID4gPiA+IGR1bW15ID0gYmUzMl90b19jcHVwKHArKyk7DQo+ID4gPiA+IEFzc2lnbmluZyB2
YWx1ZSB0byAiZHVtbXkiIGhlcmUsIGJ1dCB0aGF0IHN0b3JlZCB2YWx1ZQ0KPiA+ID4gPiBpcyBv
dmVyd3JpdHRlbiBiZWZvcmUgaXQgY2FuIGJlIHVzZWQuDQo+ID4gPiA+IA0KPiA+ID4gPiBkZWxl
dGUgaW52YWxpZCBhc3NpZ25tZW50IHN0YXRlbWVudHMgaW4NCj4gPiA+ID4gbmZzZDRfZGVjb2Rl
X2V4Y2hhbmdlX2lkDQo+ID4gPiA+IA0KPiA+ID4gPiBTaWduZWQtb2ZmLWJ5OiBuMDAyMDI3NTQg
PG5peGlhb21pbmdAaHVhd2VpLmNvbT4NCj4gPiA+ID4gLS0tDQo+ID4gPiA+IGZzL25mc2QvbmZz
NHhkci5jIHwgNCArKy0tDQo+ID4gPiA+IDEgZmlsZSBjaGFuZ2VkLCAyIGluc2VydGlvbnMoKyks
IDIgZGVsZXRpb25zKC0pDQo+ID4gPiA+IA0KPiA+ID4gPiBkaWZmIC0tZ2l0IGEvZnMvbmZzZC9u
ZnM0eGRyLmMgYi9mcy9uZnNkL25mczR4ZHIuYw0KPiA+ID4gPiBpbmRleCBhOTY4NDNjLi44ZTc4
NTQxIDEwMDY0NA0KPiA+ID4gPiAtLS0gYS9mcy9uZnNkL25mczR4ZHIuYw0KPiA+ID4gPiArKysg
Yi9mcy9uZnNkL25mczR4ZHIuYw0KPiA+ID4gPiBAQCAtMTM5Miw4ICsxMzkyLDggQEAgbmZzZDRf
ZGVjb2RlX2V4Y2hhbmdlX2lkKHN0cnVjdA0KPiA+ID4gPiBuZnNkNF9jb21wb3VuZGFyZ3MgKmFy
Z3AsDQo+ID4gPiA+IA0KPiA+ID4gPiAJCS8qIHNzcF93aW5kb3cgYW5kIHNzcF9udW1fZ3NzX2hh
bmRsZXMgKi8NCj4gPiA+ID4gCQlSRUFEX0JVRig4KTsNCj4gPiA+ID4gLQkJZHVtbXkgPSBiZTMy
X3RvX2NwdXAocCsrKTsNCj4gPiA+ID4gLQkJZHVtbXkgPSBiZTMyX3RvX2NwdXAocCsrKTsNCj4g
PiA+ID4gKwkJYmUzMl90b19jcHVwKHArKyk7DQo+ID4gPiA+ICsJCWJlMzJfdG9fY3B1cChwKysp
Ow0KPiA+ID4gDQo+ID4gPiBJZiB0aGVzZSB2YWx1ZXMgYXJlIG5vdCB1c2VkLCB3aGF0J3MgdGhl
IHBvaW50IG9mIGJ5dGUgc3dhcHBpbmcNCj4gPiA+IHRoZW0/DQo+ID4gPiBTdXJlbHkgInAgKz0g
MjsiIHNob3VsZCBiZSBlbm91Z2guDQo+ID4gPiANCj4gPiA+IA0KPiA+ID4gPiAJCWJyZWFrOw0K
PiA+ID4gPiAJZGVmYXVsdDoNCj4gPiA+ID4gCQlnb3RvIHhkcl9lcnJvcjsNCj4gPiANCj4gPiBH
aXZlbiB0aGF0IHRoZSB2YWx1ZSBvZiAncCcgaXNuJ3QgdXNlZCBlaXRoZXIsIHdoeSBub3QganVz
dCBkZWxldGUNCj4gPiB0aG9zZSB0d28gbGluZXMgYWx0b2dldGhlcj8NCj4gDQo+IFNvdW5kcyBP
SywgUkVBRF9CVUYgaXMgdHJhY2tpbmcgcHJvZ3Jlc3MgdGhyb3VnaCB0aGUgYnVmZmVyLA0KPiBh
bmQgaXQgYWxyZWFkeSB1cGRhdGVzICJwIiBhcyBhIHNpZGUtZWZmZWN0Lg0KPiANCj4gTWlnaHQg
dGhlcmUgYmUgc29tZSBuZWFyYnkgaW5zdGFuY2VzIG9mIG9wZW4tY29kZWQgInAiIHVwZGF0ZXMN
Cj4gdGhhdCBjb3VsZCBhbHNvIGJlIHJlbW92ZWQsIGZvciBzaW1pbGFyIHJlYXNvbnM/DQo+IA0K
DQpQcm9iYWJseSwgeWVzLiBJIGJlbGlldmUgdGhhdCB3ZSd2ZSBzYWlkIGJlZm9yZSAoYW5kIEJy
dWNlIGFncmVlZCBhdA0KdGhlIHRpbWUpIHRoYXQgd2Ugc2hvdWxkIGdldCByaWQgb2YgUkVBRF9C
VUYoKSBpbiBrbmZzZCBhcyBpdCB0ZW5kcyB0bw0Kb2JmdXNjYXRlIHRoZXNlIGFzc2lnbm1lbnRz
IHRvICdwJy4gRG9lcyBhbnlvbmUgaGF2ZSBhbnkgZnJlZSBjeWNsZXMgdG8NCndvcmsgb24gdGhh
dD8NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwg
SGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
