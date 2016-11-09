Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:26174 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932475AbcKIPI6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2016 10:08:58 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>,
        "tj@kernel.org" <tj@kernel.org>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>
CC: "bhaktipriya96@gmail.com" <bhaktipriya96@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] fs/nfsd/nfs4callback: Remove deprecated
 create_singlethread_workqueue
Date: Wed, 9 Nov 2016 15:08:52 +0000
Message-ID: <1478704129.15658.1.camel@primarydata.com>
References: <20160830205348.GA31915@Karyakshetra>
         <20161108213911.GA27681@fieldses.org>
         <20161108225221.GB6460@htj.duckdns.org>
         <20161109012725.GA29930@fieldses.org>
         <1478697488.7930.7.camel@poochiereds.net>
In-Reply-To: <1478697488.7930.7.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDE2LTExLTA5IGF0IDA4OjE4IC0wNTAwLCBKZWZmIExheXRvbiB3cm90ZToNCj4g
T24gVHVlLCAyMDE2LTExLTA4IGF0IDIwOjI3IC0wNTAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6
DQo+ID4gDQo+ID4gT24gVHVlLCBOb3YgMDgsIDIwMTYgYXQgMDU6NTI6MjFQTSAtMDUwMCwgVGVq
dW4gSGVvIHdyb3RlOg0KPiA+ID4gDQo+ID4gPiANCj4gPiA+IEhlbGxvLCBCcnVjZS4NCj4gPiA+
IA0KPiA+ID4gT24gVHVlLCBOb3YgMDgsIDIwMTYgYXQgMDQ6Mzk6MTFQTSAtMDUwMCwgSi4gQnJ1
Y2UgRmllbGRzIHdyb3RlOg0KPiA+ID4gPiANCj4gPiA+ID4gDQo+ID4gPiA+IEFwb2xvZ2llcywg
anVzdCBjbGVhbmluZyBvdXQgb2xkIG1haWwgYW5kIGZpbmRpbmcgc29tZSBJIHNob3VsZA0KPiA+
ID4gPiBoYXZlDQo+ID4gPiA+IHJlc3BvbmRlZCB0byBsb25nIGFnbzoNCj4gPiA+ID4gDQo+ID4g
PiA+IE9uIFdlZCwgQXVnIDMxLCAyMDE2IGF0IDAyOjIzOjQ4QU0gKzA1MzAsIEJoYWt0aXByaXlh
IFNocmlkaGFyDQo+ID4gPiA+IHdyb3RlOg0KPiA+ID4gPiA+IA0KPiA+ID4gPiA+IA0KPiA+ID4g
PiA+IFRoZSB3b3JrcXVldWUgImNhbGxiYWNrX3dxIiBxdWV1ZXMgYSBzaW5nbGUgd29yayBpdGVt
ICZjYi0NCj4gPiA+ID4gPiA+Y2Jfd29yayBwZXINCj4gPiA+ID4gPiBuZnNkNF9jYWxsYmFjayBp
bnN0YW5jZSBhbmQgdGh1cywgaXQgZG9lc24ndCByZXF1aXJlDQo+ID4gPiA+ID4gZXhlY3V0aW9u
IG9yZGVyaW5nLg0KPiA+ID4gPiANCj4gPiA+ID4gV2hhdCdzICJleGVjdXRpb24gb3JkZXJpbmci
Pw0KPiA+ID4gPiANCj4gDQo+IEFJVUksIGl0IG1lYW5zIHRoYXQgam9icyBhcmUgYWx3YXlzIHJ1
biBpbiB0aGUgb3JkZXIgcXVldWVkIGFuZCBhcmUNCj4gc2VyaWFsaXplZC4NCj4gDQo+ID4gDQo+
ID4gPiANCj4gPiA+ID4gDQo+ID4gPiA+IFdlIGRlZmluaXRlbHkgZG8gZGVwZW5kIG9uIHRoZSBm
YWN0IHRoYXQgYXQgbW9zdCBvbmUgb2YgdGhlc2UNCj4gPiA+ID4gaXMgcnVubmluZw0KPiA+ID4g
PiBhdCBhIHRpbWUuDQo+ID4gPiANCj4gDQo+IFdlIGRvPw0KPiANCj4gPiANCj4gPiA+IA0KPiA+
ID4gSWYgdGhlcmUgY2FuIGJlIG11bHRpcGxlIGNiJ3MgYW5kIHRodXMgY2ItPmNiX3dvcmsncyBw
ZXINCj4gPiA+IGNhbGxiYWNrX3dxLA0KPiA+ID4gaXQnZCBuZWVkIGV4cGxpY2l0IG9yZGVyaW5n
LsKgwqBJcyB0aGF0IHRoZSBjYXNlPw0KPiA+IA0KPiANCj4gVGhlc2UgYXJlIGJhc2ljYWxseSBj
bGllbnQgUlBDIHRhc2tzLCBhbmQgdGhlIGNiX3dvcmsganVzdCBoYW5kbGVzDQo+IHRoZQ0KPiBz
dWJtaXNzaW9uIGludG8gdGhlIGNsaWVudCBSUEMgc3RhdGUgbWFjaGluZS4gSnVzdCBiZWNhdXNl
IHdlJ3JlDQo+IHJ1bm5pbmcNCj4gc2V2ZXJhbCBjYWxsYmFja3MgYXQgdGhlIHNhbWUgdGltZSBk
b2Vzbid0IG1lYW4gdGhhdCB0aGV5IG5lZWQgdG8gYmUNCj4gc3RyaWN0bHkgb3JkZXJlZC4gVGhl
IGNsaWVudCBzdGF0ZSBtYWNoaW5lIGNhbiBjZXJ0YWlubHkgaGFuZGxlDQo+IHJ1bm5pbmcNCj4g
dGhlc2UgaW4gcGFyYWxsZWwuDQo+IA0KPiA+IA0KPiA+IFllcywgdGhlcmUgY2FuIGJlIG11bHRp
cGxlIGNiX3dvcmsncy4NCj4gPiANCj4gDQo+IFllcywgYnV0IGVhY2ggaXMgZWZmZWN0aXZlbHkg
YSBzZXBhcmF0ZSB3b3JrIHVuaXQuIEkgc2VlIG5vIHJlYXNvbg0KPiB3aHkNCj4gd2UnZCBuZWVk
IHRvIG9yZGVyIHRoZW0gYXQgYWxsLg0KPiANCg0KVGhlcmUgbmVlZHMgdG8gYmUgc2VyaWFsaXNh
dGlvbiBhdCB0aGUgc2Vzc2lvbiBsZXZlbCAoaS5lLiB0aGUNCmNhbGxiYWNrcyBoYXZlIHRvIHJl
c3BlY3QgdGhlIHNsb3QgbGltaXRzIHNldCBieSB0aGUgY2xpZW50KSBob3dldmVyDQp0aGVyZSBz
aG91bGRu4oCZdCBiZSBhIG5lZWQgZm9yIHNlcmlhbGlzYXRpb24gYXQgdGhlIFJQQyBsZXZlbC4N
Cg0KQ2hlZXJzDQrCoCBUcm9uZA==

