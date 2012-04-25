Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:18024 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757516Ab2DYSy6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Apr 2012 14:54:58 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v2] SUNRPC: skip dead but not buried clients on PipeFS
 events
Date: Wed, 25 Apr 2012 18:54:55 +0000
Message-ID: <1335380095.15862.26.camel@lade.trondhjem.org>
References: <20120420141042.7205.62608.stgit@localhost6.localdomain6>
	 <20120425173005.GD751@fieldses.org>
In-Reply-To: <20120425173005.GD751@fieldses.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTA0LTI1IGF0IDEzOjMwIC0wNDAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6
DQo+IE9uIEZyaSwgQXByIDIwLCAyMDEyIGF0IDA2OjExOjAyUE0gKzA0MDAsIFN0YW5pc2xhdiBL
aW5zYnVyc2t5IHdyb3RlOg0KPiA+IHYyOiBhdG9taWNfaW5jX3JldHVybigpIHdhcyByZXBsYWNl
ZCBieSBhdG9taWNfaW5jX25vdF96ZXJvKCkuDQo+ID4gDQo+ID4gVGhlc2UgY2xpZW50cyBjYW4n
dCBiZSBzYWZlbHkgZGVyZWZlcmVuY2VkIGlmIHRoZWlyIGNvdW50ZXIgaW4gMC4NCj4gDQo+IEkn
bSBwcmV0dHkgY29uZnVzZWQgYnkgaG93IHRoZXNlIG5vdGlmaWVycyB3b3JrLi4uLg0KPiANCj4g
cnBjX3JlbGVhc2VfY2xpZW50IGRlY3JlbWVudHMgY2xfY291bnQgdG8gemVybyB0ZW1wb3Jhcmls
eSwgdG8gaGF2ZSBpdA0KPiBpbW1lZGlhdGVseSByZS1pbmNyZW1lbnRlZCBieSBycGNfZnJlZV9h
dXRoLg0KPiANCj4gU28gaWYgd2UncmUgY2FsbGVkIGNvbmN1cnJlbnRseSB3aXRoIHJwY19yZWxl
YXNlX2NsaWVudCB0aGVuIGl0J3Mgc29ydA0KPiBvZiByYW5kb20gd2hldGhlciBzb21lb25lIGdl
dHMgdGhpcyBjYWxsYmFjay4NCj4gDQo+IElzIHRoYXQgYSBwcm9ibGVtPw0KDQpOb3QgcmVhbGx5
LiBJZiB3ZSByZS1pbmNyZW1lbnQgdGhlIGNsaWVudC0+Y2xfY291bnQgaW4gcnBjX2ZyZWVfYXV0
aCgpDQp0aGVuIGl0IHdvdWxkIGJlIHNvIHRoYXQgd2UgY2FuIHNlbmQgb2ZmIGEgYnVuY2ggb2Yg
TlVMTCBycGMgY2FsbHMgdG8NCmRlc3Ryb3kgZXhpc3RpbmcgUlBDU0VDX0dTUyBjb250ZXh0cy4g
V2Ugc2hvdWxkbid0IG5lZWQgdG8gZG8gYW55IG1vcmUNCnVwY2FsbHMgaW4gcGlwZWZzLg0KDQpJ
ZiB3ZSBjYXJlLCB3ZSBjb3VsZCBzaW1wbHkgbW92ZSB0aGUgY2FsbCB0byBycGNfdW5yZWdpc3Rl
cl9jbGllbnQoKQ0KaW50byBycGNfZnJlZV9hdXRoKCkgc28gdGhhdCB0aGUgcGlwZWZzIG5vdGlm
aWVyIGRvZXNuJ3Qgc2VlIHVzLCBvciB3ZQ0KY291bGQgc2V0IGEgZmxhZyB0byBoYXZlIGl0IGln
bm9yZSB1cy4NCg0KPiBBbHNvLCBpcyB0aGlzIGFuIGV4aXN0aW5nIGJ1Zz8gIChJbiB3aGljaCBj
YXNlIFRyb25kIHNob3VsZCB0YWtlIGl0DQo+IG5vdy4pDQoNCg0KLS0gDQpUcm9uZCBNeWtsZWJ1
c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVz
dEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
