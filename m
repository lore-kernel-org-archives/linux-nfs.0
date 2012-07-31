Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44182 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754393Ab2GaO2d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 10:28:33 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Fengguang Wu <fengguang.wu@intel.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [nfs:devel 46/51] fs/nfs/write.c:1592:5: error: redefinition of
 'nfs_commit_inode'
Date: Tue, 31 Jul 2012 14:28:21 +0000
Message-ID: <1343744900.519.13.camel@lade.trondhjem.org>
References: <20120731024328.GA10480@localhost>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA934BE82@SACEXCMBX04-PRD.hq.netapp.com>
	 <5017D3FC.9010905@netapp.com> <1343739299.519.1.camel@lade.trondhjem.org>
	 <5017D824.209@netapp.com> <5017DDDB.6060500@netapp.com>
	 <1343741622.519.2.camel@lade.trondhjem.org> <5017E13F.4030909@netapp.com>
	 <1343743122.519.4.camel@lade.trondhjem.org>
	 <20120731141007.GA20369@localhost>
In-Reply-To: <20120731141007.GA20369@localhost>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTA3LTMxIGF0IDIyOjEwICswODAwLCBGZW5nZ3VhbmcgV3Ugd3JvdGU6DQo+
ID4gPiBFYXN5IGVub3VnaCwgdGhlIHBhdGNoIHRoYXQgZml4ZXMgaXQgaXMgdGhlIGxhc3Qgb25l
IGluIHRoZSBzZXJpZXMgdGhhdCBJIHNlbnQgaW4geWVzdGVyZGF5Lg0KPiA+IA0KPiA+IEkgZG9u
J3QgdW5kZXJzdGFuZC4gVGhhdCBpcyB0aGUgcGF0Y2ggc2VyaWVzIHRoYXQgRmVuZ2d1YW5nIHdh
cyB0ZXN0aW5nDQo+ID4gYWZhaWsuIEhpcyB0ZXN0cyB3ZXJlIG9uIA0KPiA+IA0KPiA+IHRyZWU6
ICAgZ2l0Oi8vZ2l0LmxpbnV4LW5mcy5vcmcvcHJvamVjdHMvdHJvbmRteS9saW51eC1uZnMuZ2l0
IGRldmVsDQo+ID4gaGVhZDogICA1YzEzYzllMWMxNWVlMmNhOWFiMmI5NTMyMjQwMDFhZjUzZDli
ZTA5DQo+ID4gDQo+ID4gd2hpY2ggaW5jbHVkZXMgeW91ciBwYXRjaCBzZXJpZXMgZnJvbSB5ZXN0
ZXJkYXksIG5vPw0KPiANCj4gVHJvbmQsIEkgdHlwaWNhbGx5IGRvIGNvbW1pdC1ieS1jb21taXQg
dGVzdHMgYW5kIHdpbGwgY29tcGxhaW4gaWYNCj4gKmFueSogcG9pbnQgb2YgdGhlIHRyZWUgaXMg
bm90IGJpc2VjdC1hYmxlLiBBIGZpeCBhdCB0aGUgSEVBRCB3b24ndA0KPiBzdG9wIHRoZSBlbWFp
bCBub3RpZmljYXRpb24gZm9yIGEgZGVmZWN0IGluIHRoZSBtaWRkbGUgcG9pbnQuLg0KPiANCj4g
T24gdGhlIG90aGVyIGhhbmQsIEkgZG8gbWFpbnRhaW4gYSBsaXN0IG9mIG5vbi1yZWJhc2VhYmxl
DQo+IHRyZWUvYnJhbmNoZXMsIG9uIHdoaWNoIHRoZSBIRUFEIGNvbW1pdCB3aWxsIGJlIHRlc3Rl
ZCBmaXJzdCwgYW5kIG9ubHkNCj4gaWYgYW55IHByb2JsZW1zIGFyZSBmb3VuZCwgZ28gYmFjayB0
byBmaW5kIG91dCB0aGUgZmlyc3QgYmFkIGNvbW1pdC4NCj4gDQo+IElmIHlvdSBwcmVmZXIgdGhl
IGxhdHRlciBiZWhhdmlvciwgSSBjYW4gYWRkIHlvdXIgdHJlZSBvciBhbnkgYnJhbmNoDQo+IG9m
IGl0IHRvIHRoZSBub24tcmViYXNlYWJsZSBsaXN0Lg0KDQpBaC4uLiBJIHNlZSBub3cuLi4gU28g
eW91IGFyZSBzYXlpbmcgdGhhdCB0aGUgZW5kIHJlc3VsdCBpcyBpbmRlZWQNCmNvcnJlY3QsIGJ1
dCB0aGUgYmlzZWN0aW9uIGZhaWxzLi4uDQoNClRoZSAnZGV2ZWwnIHRyZWUgaXMgdXN1YWxseSBh
IG1peHR1cmUgb2YgcmViYXNlYWJsZSBhbmQgbm9uLXJlYmFzZWFibGU6DQphbnl0aGluZyB0aGF0
IGlzIGFscmVhZHkgYmVlbiBjb21taXR0ZWQgdG8gdGhlIG5mcy1mb3ItbmV4dCBicmFuY2ggaXMN
Cm5vbi1yZWJhc2VhYmxlLCB3aGlsZSB0aGUgcmVzdCB1c3VhbGx5IGlzLi4uDQoNCkNoZWVycw0K
ICBUcm9uZA0K
