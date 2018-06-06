Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-co1nam03on0091.outbound.protection.outlook.com ([104.47.40.91]:54368
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752424AbeFFCVV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Jun 2018 22:21:21 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "weiyongjun1@huawei.com" <weiyongjun1@huawei.com>,
        "fred.isaman@gmail.com" <fred.isaman@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
Subject: Re: [PATCH -next] pnfs: Use GFP_ATOMIC under spin lock
Date: Wed, 6 Jun 2018 02:21:16 +0000
Message-ID: <5da8a18dbac01f8072e9ff2d26714c3673e14b92.camel@hammerspace.com>
References: <1528250538-50721-1-git-send-email-weiyongjun1@huawei.com>
In-Reply-To: <1528250538-50721-1-git-send-email-weiyongjun1@huawei.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDE4LTA2LTA2IGF0IDAyOjAyICswMDAwLCBXZWkgWW9uZ2p1biB3cm90ZToNCj4g
QSBzcGluIGxvY2sgaXMgdGFrZW4gaGVyZSBzbyB3ZSBzaG91bGQgdXNlIEdGUF9BVE9NSUMuDQo+
IA0KPiBGaXhlczogMjQwOWE5NzZhMjk5ICgicG5mczogQWRkIExBWU9VVEdFVCB0byBPUEVOIG9m
IGEgbmV3IGZpbGUiKQ0KPiBTaWduZWQtb2ZmLWJ5OiBXZWkgWW9uZ2p1biA8d2VpeW9uZ2p1bjFA
aHVhd2VpLmNvbT4NCj4gLS0tDQo+ICBmcy9uZnMvcG5mcy5jIHwgMiArLQ0KPiAgMSBmaWxlIGNo
YW5nZWQsIDEgaW5zZXJ0aW9uKCspLCAxIGRlbGV0aW9uKC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEv
ZnMvbmZzL3BuZnMuYyBiL2ZzL25mcy9wbmZzLmMNCj4gaW5kZXggZDkzOTQyZi4uMWZmMTk5OCAx
MDA2NDQNCj4gLS0tIGEvZnMvbmZzL3BuZnMuYw0KPiArKysgYi9mcy9uZnMvcG5mcy5jDQo+IEBA
IC0yMDA5LDcgKzIwMDksNyBAQCBzdHJ1Y3QgcG5mc19sYXlvdXRfc2VnbWVudCAqDQo+ICAJc3Ry
dWN0IHBuZnNfbGF5b3V0X2hkciAqbG87DQo+ICANCj4gIAlzcGluX2xvY2soJmluby0+aV9sb2Nr
KTsNCj4gLQlsbyA9IHBuZnNfZmluZF9hbGxvY19sYXlvdXQoaW5vLCBjdHgsIEdGUF9LRVJORUwp
Ow0KPiArCWxvID0gcG5mc19maW5kX2FsbG9jX2xheW91dChpbm8sIGN0eCwgR0ZQX0FUT01JQyk7
DQo+ICAJaWYgKCFsbykNCj4gIAkJZ290byBvdXRfdW5sb2NrOw0KPiAgCWlmICghdGVzdF9iaXQo
TkZTX0xBWU9VVF9JTlZBTElEX1NUSUQsICZsby0+cGxoX2ZsYWdzKSkNCj4gDQpIaSBXZWksDQoN
ClRoZSBpbm8tPmlfbG9jayBzcGlubG9jayBpcyB0ZW1wb3JhcmlseSBkcm9wcGVkIGluc2lkZQ0K
cG5mc19maW5kX2FsbG9jX2xheW91dCgpIGlmIHdlIGhhdmUgdG8gcGVyZm9ybSBhbiBhbGxvY2F0
aW9uLCBzbyB0aGUNCmV4aXN0aW5nIGNvZGUgc2hvdWxkIGJlIGNvcnJlY3QuDQoNCkNoZWVycw0K
ICBUcm9uZA0KDQotLSANClRyb25kIE15a2xlYnVzdA0KQ1RPLCBIYW1tZXJzcGFjZSBJbmMNCjQz
MDAgRWwgQ2FtaW5vIFJlYWwsIFN1aXRlIDEwNQ0KTG9zIEFsdG9zLCBDQSA5NDAyMg0Kd3d3Lmhh
bW1lci5zcGFjZSBpZD0iLXgtZXZvLXNlbGVjdGlvbi1lbmQtbWFya2VyIj4=
