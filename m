Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from szxga08-in.huawei.com ([45.249.212.255]:59490 "EHLO huawei.com"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752574AbeFFDBu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Jun 2018 23:01:50 -0400
From: "weiyongjun (A)" <weiyongjun1@huawei.com>
To: Trond Myklebust <trondmy@hammerspace.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "fred.isaman@gmail.com" <fred.isaman@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
Subject: RE: [PATCH -next] pnfs: Use GFP_ATOMIC under spin lock
Date: Wed, 6 Jun 2018 03:01:01 +0000
Message-ID: <6AADFAC011213A4C87B956458587ADB401E0E6D3@dggeml512-mbx.china.huawei.com>
References: <1528250538-50721-1-git-send-email-weiyongjun1@huawei.com>
 <5da8a18dbac01f8072e9ff2d26714c3673e14b92.camel@hammerspace.com>
In-Reply-To: <5da8a18dbac01f8072e9ff2d26714c3673e14b92.camel@hammerspace.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiBTdWJqZWN0OiBSZTogW1BBVENIIC1uZXh0XSBwbmZzOiBVc2UgR0ZQX0FUT01JQyB1bmRlciBz
cGluIGxvY2sNCj4gDQo+IE9uIFdlZCwgMjAxOC0wNi0wNiBhdCAwMjowMiArMDAwMCwgV2VpIFlv
bmdqdW4gd3JvdGU6DQo+ID4gQSBzcGluIGxvY2sgaXMgdGFrZW4gaGVyZSBzbyB3ZSBzaG91bGQg
dXNlIEdGUF9BVE9NSUMuDQo+ID4NCj4gPiBGaXhlczogMjQwOWE5NzZhMjk5ICgicG5mczogQWRk
IExBWU9VVEdFVCB0byBPUEVOIG9mIGEgbmV3IGZpbGUiKQ0KPiA+IFNpZ25lZC1vZmYtYnk6IFdl
aSBZb25nanVuIDx3ZWl5b25nanVuMUBodWF3ZWkuY29tPg0KPiA+IC0tLQ0KPiA+ICBmcy9uZnMv
cG5mcy5jIHwgMiArLQ0KPiA+ICAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24oKyksIDEgZGVs
ZXRpb24oLSkNCj4gPg0KPiA+IGRpZmYgLS1naXQgYS9mcy9uZnMvcG5mcy5jIGIvZnMvbmZzL3Bu
ZnMuYw0KPiA+IGluZGV4IGQ5Mzk0MmYuLjFmZjE5OTggMTAwNjQ0DQo+ID4gLS0tIGEvZnMvbmZz
L3BuZnMuYw0KPiA+ICsrKyBiL2ZzL25mcy9wbmZzLmMNCj4gPiBAQCAtMjAwOSw3ICsyMDA5LDcg
QEAgc3RydWN0IHBuZnNfbGF5b3V0X3NlZ21lbnQgKg0KPiA+ICAJc3RydWN0IHBuZnNfbGF5b3V0
X2hkciAqbG87DQo+ID4NCj4gPiAgCXNwaW5fbG9jaygmaW5vLT5pX2xvY2spOw0KPiA+IC0JbG8g
PSBwbmZzX2ZpbmRfYWxsb2NfbGF5b3V0KGlubywgY3R4LCBHRlBfS0VSTkVMKTsNCj4gPiArCWxv
ID0gcG5mc19maW5kX2FsbG9jX2xheW91dChpbm8sIGN0eCwgR0ZQX0FUT01JQyk7DQo+ID4gIAlp
ZiAoIWxvKQ0KPiA+ICAJCWdvdG8gb3V0X3VubG9jazsNCj4gPiAgCWlmICghdGVzdF9iaXQoTkZT
X0xBWU9VVF9JTlZBTElEX1NUSUQsICZsby0+cGxoX2ZsYWdzKSkNCj4gPg0KPiBIaSBXZWksDQo+
IA0KPiBUaGUgaW5vLT5pX2xvY2sgc3BpbmxvY2sgaXMgdGVtcG9yYXJpbHkgZHJvcHBlZCBpbnNp
ZGUNCj4gcG5mc19maW5kX2FsbG9jX2xheW91dCgpIGlmIHdlIGhhdmUgdG8gcGVyZm9ybSBhbiBh
bGxvY2F0aW9uLCBzbyB0aGUNCj4gZXhpc3RpbmcgY29kZSBzaG91bGQgYmUgY29ycmVjdC4NCg0K
SGkgVHJvbmQsDQoNClllcywgeW91IGFyZSByaWdodCwgdGhhbmtzIGZvciByZXZpZXcuDQoNClJl
Z2FyZHMNCg0K
