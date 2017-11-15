Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:26018 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932169AbdKONkL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Nov 2017 08:40:11 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>,
        "jpewhacker@gmail.com" <jpewhacker@gmail.com>,
        "jlayton@redhat.com" <jlayton@redhat.com>,
        "neilb@suse.com" <neilb@suse.com>
CC: "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "dhowells@redhat.com" <dhowells@redhat.com>
Subject: Re: [RFC v3 0/7] NFS Force Unmounting
Date: Wed, 15 Nov 2017 13:40:05 +0000
Message-ID: <1510753204.9878.52.camel@primarydata.com>
References: <20171114230631.14682-1-JPEWhacker@gmail.com>
In-Reply-To: <20171114230631.14682-1-JPEWhacker@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDE3LTExLTE0IGF0IDE3OjA2IC0wNjAwLCBKb3NodWEgV2F0dCB3cm90ZToNCj4g
QWZ0ZXIgc29tZSBhZGRpdGlvbmFsIHRlc3Rpbmcgb24gdmVyc2lvbiAyLCBJIHJlYWxpemVkIHRo
YXQgMSkgbXkNCj4gdGVzdA0KPiBzZXR1cCB3YXMgYmFkIChEb2ghKSBhbmQgMikgdXNpbmcgcmVt
b3VudCBpc24ndCByZWFsbHkgYW4gaWRlYWwNCj4gbWV0aG9kDQo+IGZvciBzZXR0aW5nIHRoZSAi
c2VydmVyZmFpbGVkIiBtb3VudCBmbGFnLiBUaGUgcmVhc29uIGJlaW5nIHRoYXQgYW55DQo+IHVz
ZXJzcGFjZSByZW1vdW50IGlzIGdvaW5nIHRvIHRvdWNoIHRoZSBmaWxlIHN5c3RlbSBhbmQgcHJv
YmFibHkNCj4gaW52b2tlDQo+IHNvbWUgUlBDcyBmb3IgaW5vZGUgdmFsaWRhdGlvbiBhcyBzdWNo
LiBJZiB0aGUgc2VydmVyIGlzIHRydWx5IGRlYWQsDQo+IHRoZXNlIFJQQ3Mgd2lsbCBoYXZlIHRv
IHRpbWUgb3V0IGJlZm9yZSB0aGUgZmxhZyBjb3VsZCBhY3R1YWxseSBiZQ0KPiBzZXQuDQo+IFRo
aXMgbm90IG9ubHkgdGFrZXMgYSBsb25nIHRpbWUsIGJ1dCB3aWxsIHByb2JhYmx5IGFsc28gZmFp
bCwgY2F1c2luZw0KPiB0aGUgcmVtb3VudCB0byBmYWlsIGFuZCBub3Qgc2V0IHRoZSBmbGFnLCBk
ZWZlYXRpbmcgdGhlIHB1cnBvc2UuDQoNCldoeT8gVGhlcmUgc2hvdWxkIGJlIG5vIHJlYXNvbiB0
byBoYXZlIHRvIHJldmFsaWRhdGUgdGhlIHBhdGggaW4gb3JkZXINCnRvIGNoYW5nZSBtb3VudCBv
cHRpb25zIG9uIGEgbW91bnQgcG9pbnQuDQoNCj4gVGhpcyBwYXRjaCBzZXQgd29ya3MgYXJvdW5k
IHRoaXMgYnkgZXhwb3NpbmcgdGhlIGZhaWxlZCBzZXJ2ZXIgZmxhZw0KPiBpbg0KPiBkZWJ1Z2Zz
LiBJbiBhZGRpdGlvbiwgdGhlIGZsYWcgbm93IGFwcGxpZXMgYXQgdGhlIG5mc19jbGllbnQgbGV2
ZWwNCj4gKGluc3RlYWQgb2YgdGhlIG5mc19zZXJ2ZXIpLiBTZXR0aW5nIHRoZSBmbGFnIHdpbGwg
Y2FuY2VsIGFsbCBSUENzIGluDQo+IHRoZSBjbGllbnQsIGFzIHdlbGwgYXMgYWxsIG5mc19zZXJ2
ZXJzIGF0dGFjaGVkIHRvIGl0LiBUaGlzIGVuc3VyZXMNCj4gdGhhdA0KPiB5b3UgZ2V0IGFsbCB0
aGUgbW91bnRzLCBldmVuIHdoZW4gZGVhbGluZyB3aXRoIHN1Ym1vdW50cyB0aGF0IGNyb3NzDQo+
IHJlbW90ZSBkZXZpY2UgYm91bmRhcmllcy4gVGhpcyBpcyBhbHNvIHdoZXJlIHRoZSBub3NoYXJl
Y2FjaGUgb3B0aW9uDQo+IGFwcGx5aW5nIHRvIG5mc19jbGllbnRzIGJlY29tZXMgdXNlZnVsLi4u
IGl0IHdpbGwgcHJldmVudCBzaGFyaW5nDQo+IGJldHdlZW4gb3RoZXIgZXhwbGljaXQgbW91bnQg
Y2FsbHMsIGJ1dCBzdWJtb3VudHMgd2lsbCBhbGwgc3RpbGwNCj4gc2hhcmUgYQ0KPiBuZnNfY2xp
ZW50IChhbmQgZmFpbCB0b2dldGhlcikuDQo+IA0KPiBPYnZpb3VzbHksIGRlYnVnZnMgaXMgbm90
IGEgcGVybWFuZW50IHNvbHV0aW9uIGZvciB0aGlzLCBzbyBzb21lDQo+IGRpc2N1c3Npb24gbmVl
ZHMgdG8gYmUgaGFkIG9uIGhvdyB0aGlzIHdpbGwgYmUgYWRtaW5pc3RlcmVkICJpbiB0aGUNCj4g
cmVhbA0KPiB3b3JsZCIgKEkgdGhpbmsgInJlbW91bnQiIGlzIG9mZiB0aGUgdGFibGUpLg0KPiAN
Cg0KV2UncmUgbm90IGFkZGluZyBhbnkgQVBJcyB0byBkZWJ1Z2ZzLiBUaGF0J3MgYSBkZWFsIGJy
ZWFrZXIuLi4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRh
aW5lciwgUHJpbWFyeURhdGENCnRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20NCg==

