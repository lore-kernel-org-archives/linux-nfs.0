Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:49297 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1033336AbdDTUSh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Apr 2017 16:18:37 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: hch <hch@lst.de>, "ooo@electrozaur.com" <ooo@electrozaur.com>,
        "Trond Myklebust" <trondmy@primarydata.com>,
        "martin.petersen@oracle.com" <martin.petersen@oracle.com>,
        "axboe@kernel.dk" <axboe@kernel.dk>
CC: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "osd-dev@open-osd.org" <osd-dev@open-osd.org>,
        "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] nfs: remove the objlayout driver
Date: Thu, 20 Apr 2017 20:18:28 +0000
Message-ID: <1492719505.82584.3.camel@primarydata.com>
References: <20170412160109.10598-1-hch@lst.de>
         <20170412160109.10598-4-hch@lst.de>
In-Reply-To: <20170412160109.10598-4-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDE3LTA0LTEyIGF0IDE4OjAxICswMjAwLCBDaHJpc3RvcGggSGVsbHdpZyB3cm90
ZToNCj4gVGhlIG9iamxheW91dCBjb2RlIGhhcyBiZWVuIGluIHRoZSB0cmVlLCBidXQgaXQncyBi
ZWVuIHVubWFpbnRhaW5lZA0KPiBhbmQNCj4gbm8gc2VydmVyIHByb2R1Y3QgZm9yIGl0IGFjdHVh
bGx5IGV2ZXIgc2hpcHBlZC4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IENocmlzdG9waCBIZWxsd2ln
IDxoY2hAbHN0LmRlPg0KPiAtLS0NCj4gwqBEb2N1bWVudGF0aW9uL2FkbWluLWd1aWRlL2tlcm5l
bC1wYXJhbWV0ZXJzLnR4dCB8wqDCoMKgNiAtDQo+IMKgRG9jdW1lbnRhdGlvbi9maWxlc3lzdGVt
cy9uZnMvcG5mcy50eHTCoMKgwqDCoMKgwqDCoMKgwqDCoHzCoMKgMzcgLS0NCj4gwqBmcy9uZnMv
S2NvbmZpZ8KgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgfMKgwqDCoDUgLQ0KPiDCoGZzL25mcy9NYWtlZmlsZcKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oHzCoMKgwqAxIC0NCj4gwqBmcy9uZnMvb2JqbGF5b3V0L0tidWlsZMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgfMKgwqDCoDUgLQ0KPiDCoGZzL25mcy9v
YmpsYXlvdXQvb2JqaW9fb3NkLmPCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgfCA2NzUgLS0tLS0tLS0tLS0tLS0NCj4gLS0tLS0tLS0NCj4gwqBmcy9uZnMvb2JqbGF5b3V0
L29iamxheW91dC5jwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoHwgNzA2
IC0tLS0tLS0tLS0tLS0tDQo+IC0tLS0tLS0tLS0NCj4gwqBmcy9uZnMvb2JqbGF5b3V0L29iamxh
eW91dC5owqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoHwgMTgzIC0tLS0t
LQ0KPiDCoGZzL25mcy9vYmpsYXlvdXQvcG5mc19vc2RfeGRyX2NsaS5jwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqB8IDQxNSAtLS0tLS0tLS0tLS0tLQ0KPiDCoDkgZmlsZXMgY2hhbmdlZCwgMjAz
MyBkZWxldGlvbnMoLSkNCj4gwqBkZWxldGUgbW9kZSAxMDA2NDQgZnMvbmZzL29iamxheW91dC9L
YnVpbGQNCj4gwqBkZWxldGUgbW9kZSAxMDA2NDQgZnMvbmZzL29iamxheW91dC9vYmppb19vc2Qu
Yw0KPiDCoGRlbGV0ZSBtb2RlIDEwMDY0NCBmcy9uZnMvb2JqbGF5b3V0L29iamxheW91dC5jDQo+
IMKgZGVsZXRlIG1vZGUgMTAwNjQ0IGZzL25mcy9vYmpsYXlvdXQvb2JqbGF5b3V0LmgNCj4gwqBk
ZWxldGUgbW9kZSAxMDA2NDQgZnMvbmZzL29iamxheW91dC9wbmZzX29zZF94ZHJfY2xpLmMNCj4g
DQoNCk9LLiBJJ20gYXBwbHlpbmcgdGhpcyBwYXRjaCBmb3IgdGhlIDQuMTIgbWVyZ2Ugd2luZG93
LiBJZiwgYXMgQm9heg0Kc3VnZ2VzdHMsIHRoZXJlIGlzIHN0aWxsIGFuIGludGVyZXN0IGluIGV4
b2ZzLCB0aGVuIEkgc3VnZ2VzdCB3ZSBwdXQNCnRoYXQgdG8gdGhlIHRlc3QgYnkgbW92aW5nIGl0
IGludG8gdGhlIFNUQUdJTkcgYXJlYSwgdG8gc2VlIGlmIHNvbWVvbmUNCndpbGwgc3RlcCB1cCB0
byBtYWludGFpbiBpdC4NCg0KQ2hlZXJzDQogIFRyb25kDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0
DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIFByaW1hcnlEYXRhDQp0cm9uZC5teWtsZWJ1
c3RAcHJpbWFyeWRhdGEuY29tDQo=

