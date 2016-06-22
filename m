Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:49140 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751059AbcFVTm6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2016 15:42:58 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Schumaker Anna <Anna.Schumaker@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 11/12] NFS: Remove inode->i_dio_count from the NFS
 O_DIRECT code
Date: Wed, 22 Jun 2016 19:42:51 +0000
Message-ID: <C4FA4E4F-DFF3-4AA7-9B1A-C34806DFA6A3@primarydata.com>
References: <1466544893-12058-1-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-2-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-3-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-4-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-5-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-6-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-7-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-8-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-9-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-10-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-11-git-send-email-trond.myklebust@primarydata.com>
 <74f8a81e-41c2-b28c-0227-780f3d26db75@Netapp.com>
 <BD2F73AF-8547-4198-A937-0C6EDBF079FA@primarydata.com>
 <795f5e87-2c43-0e6e-2f1c-322a5a928b39@Netapp.com>
 <22b9a7ea-771c-34b3-bb22-f109772d5da5@Netapp.com>
In-Reply-To: <22b9a7ea-771c-34b3-bb22-f109772d5da5@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQo+IE9uIEp1biAyMiwgMjAxNiwgYXQgMTQ6NTEsIEFubmEgU2NodW1ha2VyIDxBbm5hLlNjaHVt
YWtlckBuZXRhcHAuY29tPiB3cm90ZToNCj4gDQo+IE9uIDA2LzIyLzIwMTYgMDI6MDggUE0sIEFu
bmEgU2NodW1ha2VyIHdyb3RlOg0KPj4gT24gMDYvMjIvMjAxNiAwMjowNiBQTSwgVHJvbmQgTXlr
bGVidXN0IHdyb3RlOg0KPj4+IA0KPj4+PiBPbiBKdW4gMjIsIDIwMTYsIGF0IDEzOjU4LCBBbm5h
IFNjaHVtYWtlciA8QW5uYS5TY2h1bWFrZXJAbmV0YXBwLmNvbT4gd3JvdGU6DQo+Pj4+IA0KPj4+
PiBIaSBUcm9uZCwNCj4+Pj4gDQo+Pj4+IE9uIDA2LzIxLzIwMTYgMDU6MzQgUE0sIFRyb25kIE15
a2xlYnVzdCB3cm90ZToNCj4+Pj4+IE5vdyB0aGF0IHdlIGNhbiBzZXJpYWxpc2UgT19ESVJFQ1Qg
YW5kIHdyaXRlL3RydW5jYXRlIHVzaW5nIHRoZQ0KPj4+Pj4gaW5vZGUtPmlfcndzZW0sIHdlIG5v
IGxvbmdlciBuZWVkIGlub2RlLT5pX2Rpb19jb3VudC4NCj4+Pj4gDQo+Pj4+IEknbSBzZWVpbmcg
Y3Rob24gYmFzaWMgdGVzdHMgZmFpbCBvbiBhbGwgTkZTIHZlcnNpb25zIGFmdGVyIGFwcGx5aW5n
IHRoaXMgcGF0Y2g6DQo+Pj4+IA0KPj4+PiAuL3Rlc3Q1OiByZWFkIGFuZCB3cml0ZQ0KPj4+PiAg
ICAgICAuL3Rlc3Q1OiAoL25mcy9iYXNpYykgJ2JpZ2ZpbGUnIGhhcyBzaXplIDgxOTIsIHNob3Vs
ZCBiZSAxMDQ4NTc2DQo+Pj4+IGJhc2ljIHRlc3RzIGZhaWxlZA0KPj4+PiANCj4+PiANCj4+PiA/
Pz8/IENvbm5lY3RhdGhvbiBkb2VzbuKAmXQgdXNlIE9fRElSRUNULiBBcmUgeW91IHN1cmUgaXQg
aXMgdGhpcyBwYXRjaD8NCj4+PiANCj4+IA0KPj4gUHJldHR5IHN1cmUuICBDdGhvbiB3b3JrZWQg
Zm9yIG1lIGF0IHBhdGNoICMxMCwgYnV0IGl0IGZhaWxlZCBhZnRlciBhZGRpbmcgdGhpcyBvbmUu
DQo+IA0KPiBJIHJldHJpZWQgdGhlIHRlc3RzLCBhbmQgaXQncyBhY3R1YWxseSBwYXRjaCAjMTAg
d2hlcmUgSSBzdGFydCBoYXZpbmcgcHJvYmxlbXMuICBTb3JyeSBmb3IgdGhlIGNvbmZ1c2lvbiEN
Cj4gDQoNClRoYXQgbWFrZXMgbW9yZSBzZW5zZSwgYW5kIEkgdGhpbmsgSeKAmXZlIGZvdW5kIHRo
ZSBpc3N1ZXMuIFRoZXJlIHdlcmUgMjoNCg0KMSkgVGhlIHVwZGF0ZSBvZiBpb2NiLT5raV9wb3Mg
d2FzIGJyb2tlbi4NCjIpIGdlbmVyaWNfd3JpdGVfY2hlY2tzKCkgbmVlZHMgdG8gcnVuIGFmdGVy
IHRoZSBmaWxlIHNpemUgcmV2YWxpZGF0aW9uDQoNCkNoZWVycw0KICBUcm9uZA==

