From: "Batsakis, Alexandros" <Alexandros.Batsakis@netapp.com>
Subject: RE: [PATCH 1/1] nfs: fix race between renewd, umount, and the state manager in V4.1
Date: Fri, 22 Jan 2010 11:30:50 -0800
Message-ID: <B9364369CA66BF45806C2CD86EAB8BA604F35537@SACMVEXC3-PRD.hq.netapp.com>
References: <1264135871-13083-1-git-send-email-batsakis@netapp.com> <1264186039.30757.7.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Cc: <linux-nfs@vger.kernel.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58950 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752757Ab0AVTa7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jan 2010 14:30:59 -0500
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o0MJUuHk015496
	for <linux-nfs@vger.kernel.org>; Fri, 22 Jan 2010 11:30:56 -0800 (PST)
In-Reply-To: <1264186039.30757.7.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogTXlrbGVidXN0LCBUcm9u
ZA0KPiBTZW50OiBGcmlkYXksIEphbnVhcnkgMjIsIDIwMTAgMTA6NDcgQU0NCj4gVG86IEJhdHNh
a2lzLCBBbGV4YW5kcm9zDQo+IENjOiBsaW51eC1uZnNAdmdlci5rZXJuZWwub3JnOyBNeWtsZWJ1
c3QsIFRyb25kDQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggMS8xXSBuZnM6IGZpeCByYWNlIGJldHdl
ZW4gcmVuZXdkLCB1bW91bnQsIGFuZCB0aGUNCj4gc3RhdGUgbWFuYWdlciBpbiBWNC4xDQo+IA0K
PiBPbiBUaHUsIDIwMTAtMDEtMjEgYXQgMjA6NTEgLTA4MDAsIEFsZXhhbmRyb3MgQmF0c2FraXMg
d3JvdGU6DQo+IA0KPiA+IHN0cnVjdCBycGNfY3JlZCAqbmZzNF9nZXRfc2V0Y2xpZW50aWRfY3Jl
ZChzdHJ1Y3QgbmZzX2NsaWVudCAqY2xwKQ0KPiA+IEBAIC04NzgsNyArODg4LDExIEBAIHZvaWQg
bmZzNF9zY2hlZHVsZV9zdGF0ZV9tYW5hZ2VyKHN0cnVjdA0KPiBuZnNfY2xpZW50ICpjbHApDQo+
ID4gIAlpZiAodGVzdF9hbmRfc2V0X2JpdChORlM0Q0xOVF9NQU5BR0VSX1JVTk5JTkcsICZjbHAt
PmNsX3N0YXRlKSAhPQ0KPiAwKQ0KPiA+ICAJCXJldHVybjsNCj4gPiAgCV9fbW9kdWxlX2dldChU
SElTX01PRFVMRSk7DQo+ID4gLQlhdG9taWNfaW5jKCZjbHAtPmNsX2NvdW50KTsNCj4gPiArCWlm
ICghYXRvbWljX2luY19ub3RfemVybygmY2xwLT5jbF9jb3VudCkpIHsNCj4gPiArCQluZnM0X2Ns
ZWFyX3N0YXRlX21hbmFnZXJfYml0KGNscCk7DQo+ID4gKwkJbW9kdWxlX3B1dChUSElTX01PRFVM
RSk7DQo+ID4gKwkJcmV0dXJuOw0KPiA+ICsJfQ0KPiANCj4gVGhlIHVzZSBvZiBhdG9taWNfaW5j
X25vdF96ZXJvKCkgc2hvdWxkIG5vdCBiZSBuZWNlc3NhcnkgaGVyZS4gQW55Ym9keQ0KPiB3aG8g
aXMgY2FsbGluZyB0aGlzIGZ1bmN0aW9uIHdpdGhvdXQgaG9sZGluZyBhIHJlZmVyZW5jZSB0byBj
bHAgaXMNCj4gZG9pbmcNCj4gc29tZXRoaW5nIGZ1bmRhbWVudGFsbHkgd3JvbmcuDQoNCkFncmVl
ZCwgYnV0IGhvdyBjYW4gd2UgZW5mb3JjZSB0aGlzIChlc3BlY2lhbGx5IHdpdGggYXN5bmNocm9u
b3VzIFJQQykgPw0KRm9yIGV4YW1wbGUgd2hhdCB3aWxsIGhhcHBlbiBpZiBfZHVyaW5nXyB1bW91
bnQgKGFmdGVyIG5mc19wdXRfY2xpZW50KCkpLCBhbiBORlMgY2FsbCB0aGF0IHdhcyBzbGVlcGlu
ZyBlLmcuIHdhaXRpbmcgZm9yIHRoZSBzZXJ2ZXIgdG8gY29tZSB1cCwgcmVhY2hlcyB0aGUgc2Vy
dmVyIGFuZCB0aGUgcmVzcG9uc2UgY2F1c2VzIHRoZSBzdGF0ZSBtYW5hZ2VyIHRvIHN0YXJ0ID8N
CkFueSBpZGVhcyA/DQoNCi1hDQoNCj4gDQo+IFRyb25kDQo=
