Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:33117 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751427AbcLEVM2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2016 16:12:28 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: Anna Schumaker <schumaker.anna@gmail.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Fix incorrect size revalidation when holding a
 delegation
Date: Mon, 5 Dec 2016 21:12:22 +0000
Message-ID: <52E81909-DCF1-4BDE-B7BC-D16BA049BDE6@primarydata.com>
References: <20161204231008.31396-1-trond.myklebust@primarydata.com>
 <56cfbea2-4267-b39d-7bf2-e4c38c4abcff@gmail.com>
In-Reply-To: <56cfbea2-4267-b39d-7bf2-e4c38c4abcff@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQo+IE9uIERlYyA1LCAyMDE2LCBhdCAxNToyOCwgQW5uYSBTY2h1bWFrZXIgPHNjaHVtYWtlci5h
bm5hQGdtYWlsLmNvbT4gd3JvdGU6DQo+IA0KPiBIaSBUcm9uZCwNCj4gDQo+IE9uIDEyLzA0LzIw
MTYgMDY6MTAgUE0sIFRyb25kIE15a2xlYnVzdCB3cm90ZToNCj4+IFdlIHNob3VsZCBvbmx5IGNh
cmUgYWJvdXQgY2hlY2tpbmcgdGhlIGF0dHJpYnV0ZXMgaWYgdGhlIHBhZ2UgY2FjaGUNCj4+IGlz
IG1hcmtlZCBhcyBkdWJpb3VzICh1c2luZyBORlNfSU5PX1JFVkFMX1BBR0VDQUNIRSkgYW5kIHRo
ZQ0KPj4gTkZTX0lOT19SRVZBTF9GT1JDRUQgZmxhZyBpcyBzZXQuDQo+PiANCj4+IFNpZ25lZC1v
ZmYtYnk6IFRyb25kIE15a2xlYnVzdCA8dHJvbmQubXlrbGVidXN0QHByaW1hcnlkYXRhLmNvbT4N
Cj4+IC0tLQ0KPj4gZnMvbmZzL2ZpbGUuYyB8IDUgKysrKy0NCj4+IDEgZmlsZSBjaGFuZ2VkLCA0
IGluc2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkNCj4+IA0KPj4gZGlmZiAtLWdpdCBhL2ZzL25m
cy9maWxlLmMgYi9mcy9uZnMvZmlsZS5jDQo+PiBpbmRleCA5ZWE4NWFlMjNjMzIuLjY0YzExZjM5
OWIzZCAxMDA2NDQNCj4+IC0tLSBhL2ZzL25mcy9maWxlLmMNCj4+ICsrKyBiL2ZzL25mcy9maWxl
LmMNCj4+IEBAIC0xMDIsOCArMTAyLDExIEBAIHN0YXRpYyBpbnQgbmZzX3JldmFsaWRhdGVfZmls
ZV9zaXplKHN0cnVjdCBpbm9kZSAqaW5vZGUsIHN0cnVjdCBmaWxlICpmaWxwKQ0KPj4gew0KPj4g
CXN0cnVjdCBuZnNfc2VydmVyICpzZXJ2ZXIgPSBORlNfU0VSVkVSKGlub2RlKTsNCj4+IAlzdHJ1
Y3QgbmZzX2lub2RlICpuZnNpID0gTkZTX0koaW5vZGUpOw0KPj4gKwljb25zdCB1bnNpZ25lZCBs
b25nIGZvcmNlX3JldmFsID0gTkZTX0lOT19SRVZBTF9QQUdFQ0FDSEV8TkZTX0lOT19SRVZBTF9G
T1JDRUQ7DQo+IA0KPiBXb3VsZCBpdCBtYWtlIHNlbnNlIHRvIGRlY2xhcmUgdGhpcyBpbiBhIGhl
YWRlciBmaWxlIHNvbWV3aGVyZSwgcmF0aGVyIHRoYW4gcmVwZWF0aW5nIHRoaXMgaW4gZmlsZS5j
IGFuZCBpbm9kZS5jPyAoYW5kIGFueSBvdGhlciBwbGFjZXMgd2UgbWlnaHQgbmVlZCB0byAiZm9y
Y2VfcmV2YWwiIGluIHRoZSBmdXR1cmU/KQ0KDQpJIGhhdmUgc29tZSBpZGVhcyBmb3Igc29tZSBj
bGVhbnVwcyB0aGF0IHNob3VsZCBoZWxwIGNsZWFyIHVwIHRoZSBzaXR1YXRpb24gd2l0aCB0aGUg
YXR0cmlidXRlIGNhY2hlLiBJ4oCZbGwgc2VlIGlmIEkgZ2V0IHJvdW5kIHRvIHRoZW0gdGhpcyB3
ZWVrLg0KDQpDaGVlcnMNCiAgVHJvbmQ=

