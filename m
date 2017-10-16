Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:27430 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753445AbdJPO5x (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Oct 2017 10:57:53 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "skinsbursky@virtuozzo.com" <skinsbursky@virtuozzo.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "Sergey.Lysanov@acronis.com" <Sergey.Lysanov@acronis.com>
Subject: Re: [RFC} NFS client issue with exclusive creation when server died
 in the middle
Date: Mon, 16 Oct 2017 14:57:47 +0000
Message-ID: <1508165865.3096.10.camel@primarydata.com>
References: <31f5b837-3e74-753b-2ebd-135c8aaef96f@virtuozzo.com>
In-Reply-To: <31f5b837-3e74-753b-2ebd-135c8aaef96f@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDE3LTEwLTE2IGF0IDEwOjQ5ICswMjAwLCBTdGFuaXNsYXYgS2luc2J1cnNraXkg
d3JvdGU6DQo+IEhpLA0KPiANCj4gV2UgZGlzY292ZXJlZCBhbiBpc3N1ZSB3aXRoIE5GU3Y0LjAg
bW91bnQuDQo+IFNlcnZlciBoYXMgY3Jhc2hlZCAob3Iga2lsbGVkIGJ5IE9PTTsgaXQgd2FzIEdh
bmVzaGEpIG9uIGV4Y2x1c2l2ZQ0KPiBvcGVuLWNyZWF0ZSBvcGVyYXRpb24gYWZ0ZXIgZmlsZSB3
YXMgYWN0dWFsbHkgY3JlYXRlZCwgYnV0IG5vDQo+IHJlc3BvbnNlIHdhcyBzZW5kIHRvIHRoZSBj
bGllbnQuDQo+IFNlcnZlciB3YXMgcmVzdGFydGVkICh3aXRoIGdyYWNlIHBlcmlvZCksIGFuZCBu
ZXh0IGNsaWVudHMgYXR0ZW1wdCB0bw0KPiBjcmVhdGUgYSBmaWxlIGFmdGVyIHNlcnZlciBpcyBy
ZWFkeSBmYWlscyB3aXRoIEVFWElTVC4NCj4gVGhpcyBpcywgcHJvYmFibHksIGJlY2F1c2UgZm9y
IGVhY2ggb3BlbiByZXF1ZXN0IGNsaWVudCBjcmVhdGVzDQo+IG9wZW5kYXRhIGFuZCBwdXRzIG5l
dyBqaWZmaWVzIHZhbHVlIGFzIHRoZSB2ZXJpZmllciAoaW4NCj4gbmZzNF9vcGVuZGF0YV9hbGxv
YykgaW4gdGhlIHJlcXVlc3QuDQo+IERvZXMgaXQgc291bmQgbGlrZSBhIGNsaWVudCBpc3N1ZT8N
Cj4gDQoNCkhpIFN0YW5pc2xhdiwNCg0KSWYgaXQgZGlkbid0IHJlY2VpdmUgYSByZXBseSwgdGhl
IGNsaWVudCBzaG91bGQgYmUgcmV1c2luZyB0aGUgc2FtZQ0Kb3BlbmRhdGEgZm9yIHRoZSByZXNl
bmQgb2YgdGhlIG9wZXJhdGlvbiBhZnRlciBzdGF0ZSByZWNvdmVyIGlzDQpjb21wbGV0ZS4gRG9l
c24ndCBpdD8NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRh
aW5lciwgUHJpbWFyeURhdGENCnRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20NCg==

