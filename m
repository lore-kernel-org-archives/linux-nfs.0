Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:35629 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751293AbdFELso (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Jun 2017 07:48:44 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "baijiaju1990@163.com" <baijiaju1990@163.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] fs: nfs: Fix a sleep-in-atomic bug in
 nfs_access_add_cache
Date: Mon, 5 Jun 2017 11:48:37 +0000
Message-ID: <1496663315.3433.1.camel@primarydata.com>
References: <1496649904-1855-1-git-send-email-baijiaju1990@163.com>
In-Reply-To: <1496649904-1855-1-git-send-email-baijiaju1990@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDE3LTA2LTA1IGF0IDE2OjA1ICswODAwLCBKaWEtSnUgQmFpIHdyb3RlOg0KPiBU
aGUgZHJpdmVyIG1heSBzbGVlcCB1bmRlciBhIHJjdSByZWFkIGxvY2ssIGFuZCBmdW5jdGlvbiBj
YWxsIHBhdGgNCj4gaXM6DQo+IG5mc19wZXJtaXNzaW9uIChhY3F1aXJlIHRoZSBsb2NrIGJ5IHJj
dV9yZWFkX2xvY2spDQo+IMKgIG5mc19kb19hY2Nlc3MNCj4gwqDCoMKgwqBuZnNfYWNjZXNzX2Fk
ZF9jYWNoZQ0KPiDCoMKgwqDCoMKgwqBrbWFsbG9jKEdGUF9LRVJORUwpIC0tPiBtYXkgc2xlZXAN
Cj4gDQo+IFRvIGZpeCBpdCwgIkdGUF9LRVJORUwiIGlzIHJlcGxhY2VkIHdpdGggIkdGUF9BVE9N
SUMiLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogSmlhLUp1IEJhaSA8YmFpamlhanUxOTkwQDE2My5j
b20+DQo+IC0tLQ0KPiDCoGZzL25mcy9kaXIuYyB8wqDCoMKgwqAyICstDQo+IMKgMSBmaWxlIGNo
YW5nZWQsIDEgaW5zZXJ0aW9uKCspLCAxIGRlbGV0aW9uKC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEv
ZnMvbmZzL2Rpci5jIGIvZnMvbmZzL2Rpci5jDQo+IGluZGV4IDMyY2NkNzcuLjdhMDc0ZGIgMTAw
NjQ0DQo+IC0tLSBhL2ZzL25mcy9kaXIuYw0KPiArKysgYi9mcy9uZnMvZGlyLmMNCj4gQEAgLTIz
MzMsNyArMjMzMyw3IEBAIHN0YXRpYyB2b2lkIG5mc19hY2Nlc3NfYWRkX3JidHJlZShzdHJ1Y3Qg
aW5vZGUNCj4gKmlub2RlLCBzdHJ1Y3QgbmZzX2FjY2Vzc19lbnRyeSAqDQo+IMKgDQo+IMKgdm9p
ZCBuZnNfYWNjZXNzX2FkZF9jYWNoZShzdHJ1Y3QgaW5vZGUgKmlub2RlLCBzdHJ1Y3QNCj4gbmZz
X2FjY2Vzc19lbnRyeSAqc2V0KQ0KPiDCoHsNCj4gLQlzdHJ1Y3QgbmZzX2FjY2Vzc19lbnRyeSAq
Y2FjaGUgPSBrbWFsbG9jKHNpemVvZigqY2FjaGUpLA0KPiBHRlBfS0VSTkVMKTsNCj4gKwlzdHJ1
Y3QgbmZzX2FjY2Vzc19lbnRyeSAqY2FjaGUgPSBrbWFsbG9jKHNpemVvZigqY2FjaGUpLA0KPiBH
RlBfQVRPTUlDKTsNCj4gwqAJaWYgKGNhY2hlID09IE5VTEwpDQo+IMKgCQlyZXR1cm47DQo+IMKg
CVJCX0NMRUFSX05PREUoJmNhY2hlLT5yYl9ub2RlKTsNCg0KVGhlIFJDVSBsb2NrZWQgY29kZXBh
dGggd2lsbCBub3QgZXZlciBoaXQgbmZzX2FjY2Vzc19hZGRfcmJ0cmVlKCkuIEl0DQpyZXR1cm5z
IHdpdGggYW4gZXJyb3IgY29kZSBvZiAtRUNISUxEIGFmdGVyIHRoZSB0ZXN0IG9mICJtYXlfYmxv
Y2siLg0KDQpDaGVlcnMNCiAgVHJvbmQNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMg
Y2xpZW50IG1haW50YWluZXIsIFByaW1hcnlEYXRhDQp0cm9uZC5teWtsZWJ1c3RAcHJpbWFyeWRh
dGEuY29tDQo=

