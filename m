Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:29582 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S965699AbdDZTFJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Apr 2017 15:05:09 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "fabf@skynet.be" <fabf@skynet.be>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH V2 linux-next] nfs: kmap can't fail
Date: Wed, 26 Apr 2017 19:05:02 +0000
Message-ID: <1493233499.2326.1.camel@primarydata.com>
References: <20170426184516.21784-1-fabf@skynet.be>
In-Reply-To: <20170426184516.21784-1-fabf@skynet.be>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDE3LTA0LTI2IGF0IDIwOjQ1ICswMjAwLCBGYWJpYW4gRnJlZGVyaWNrIHdyb3Rl
Og0KPiBSZW1vdmUgTlVMTCB0ZXN0IG9uIGttYXAoKQ0KPiANCj4gU2lnbmVkLW9mZi1ieTogRmFi
aWFuIEZyZWRlcmljayA8ZmFiZkBza3luZXQuYmU+DQo+IC0tLQ0KPiBWMjogUmVtb3ZlIHB0ciBh
bmQgcmV0dXJuIGttYXAocGFnZSkgZGlyZWN0bHkNCj4gKFN1Z2dlc3RlZCBieSBBbm5hIFNjaHVt
YWtlcikNCj4gDQo+IMKgZnMvbmZzL2Rpci5jIHwgNiArLS0tLS0NCj4gwqAxIGZpbGUgY2hhbmdl
ZCwgMSBpbnNlcnRpb24oKyksIDUgZGVsZXRpb25zKC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvZnMv
bmZzL2Rpci5jIGIvZnMvbmZzL2Rpci5jDQo+IGluZGV4IDNhMTg4Y2IuLjEyZWQ4MDZiIDEwMDY0
NA0KPiAtLS0gYS9mcy9uZnMvZGlyLmMNCj4gKysrIGIvZnMvbmZzL2Rpci5jDQo+IEBAIC0xNzUs
MTMgKzE3NSw5IEBAIHR5cGVkZWYgc3RydWN0IHsNCj4gwqBzdGF0aWMNCj4gwqBzdHJ1Y3QgbmZz
X2NhY2hlX2FycmF5ICpuZnNfcmVhZGRpcl9nZXRfYXJyYXkoc3RydWN0IHBhZ2UgKnBhZ2UpDQo+
IMKgew0KPiAtCXZvaWQgKnB0cjsNCj4gwqAJaWYgKHBhZ2UgPT0gTlVMTCkNCj4gwqAJCXJldHVy
biBFUlJfUFRSKC1FSU8pOw0KPiAtCXB0ciA9IGttYXAocGFnZSk7DQo+IC0JaWYgKHB0ciA9PSBO
VUxMKQ0KPiAtCQlyZXR1cm4gRVJSX1BUUigtRU5PTUVNKTsNCj4gLQlyZXR1cm4gcHRyOw0KPiAr
CXJldHVybiBrbWFwKHBhZ2UpOw0KPiDCoH0NCj4gwqANCj4gwqBzdGF0aWMNCg0KVGhlcmUgc2Vl
bXMgbGl0dGxlIHZhbHVlIGluIGhhdmluZyBhIHdyYXBwZXIgdG8ga21hcC4uLiBDYW4gd2UgcGVy
aGFwcw0KaW5zdGVhZCBqdXN0IGdldCByaWQgb2YgYm90aCBuZnNfcmVhZGRpcl9nZXRfYXJyYXkg
YW5kDQpuZnNfcmVhZGRpcl9yZWxlYXNlX2FycmF5Pw0KDQotLSANClRyb25kIE15a2xlYnVzdA0K
TGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBQcmltYXJ5RGF0YQ0KdHJvbmQubXlrbGVidXN0
QHByaW1hcnlkYXRhLmNvbQ0K

