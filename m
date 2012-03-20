Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:14576 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932452Ab2CTQjs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Mar 2012 12:39:48 -0400
Received: from vmwexceht03-prd.hq.netapp.com (vmwexceht03-prd.hq.netapp.com [10.106.76.241])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q2KGdmpl006261
	for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2012 09:39:48 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Isaman, Fred" <Fred.Isaman@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] NFS: ncommit count is being double decremented
Date: Tue, 20 Mar 2012 16:39:46 +0000
Message-ID: <1332261586.2963.51.camel@lade.trondhjem.org>
References: <1332260746-8351-1-git-send-email-iisaman@netapp.com>
	 <1332260746-8351-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1332260746-8351-2-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTAzLTIwIGF0IDEyOjI1IC0wNDAwLCBGcmVkIElzYW1hbiB3cm90ZToNCj4g
VGhlIGRlY3JlbWVudCBpcyBoYW5kbGVkIGJ5IGVhY2ggY2FsbCB0byBuZnNfcmVxdWVzdF9yZW1v
dmVfY29tbWl0X2xpc3QsDQo+IG5vIG5lZWQgdG8gZG8gaXQgYWdhaW4gaW4gbmZzX3NjYW5fY29t
bWl0Lg0KPiANCj4gU2lnbmVkLW9mZi1ieTogRnJlZCBJc2FtYW4gPGlpc2FtYW5AbmV0YXBwLmNv
bT4NCj4gLS0tDQo+ICBmcy9uZnMvd3JpdGUuYyB8ICAgIDUgKy0tLS0NCj4gIDEgZmlsZXMgY2hh
bmdlZCwgMSBpbnNlcnRpb25zKCspLCA0IGRlbGV0aW9ucygtKQ0KPiANCj4gZGlmZiAtLWdpdCBh
L2ZzL25mcy93cml0ZS5jIGIvZnMvbmZzL3dyaXRlLmMNCj4gaW5kZXggMGRlMTlmNC4uZTM5ZGRm
ZCAxMDA2NDQNCj4gLS0tIGEvZnMvbmZzL3dyaXRlLmMNCj4gKysrIGIvZnMvbmZzL3dyaXRlLmMN
Cj4gQEAgLTU5NSwxMiArNTk1LDkgQEAgbmZzX3NjYW5fY29tbWl0KHN0cnVjdCBpbm9kZSAqaW5v
ZGUsIHN0cnVjdCBsaXN0X2hlYWQgKmRzdCkNCj4gIAlzcGluX2xvY2soJmlub2RlLT5pX2xvY2sp
Ow0KPiAgCWlmIChuZnNpLT5uY29tbWl0ID4gMCkgew0KPiAgCQljb25zdCBpbnQgbWF4ID0gSU5U
X01BWDsNCj4gLQkJaW50IHBuZnNfcmV0Ow0KPiAgDQo+ICAJCXJldCA9IG5mc19zY2FuX2NvbW1p
dF9saXN0KCZuZnNpLT5jb21taXRfbGlzdCwgZHN0LCBtYXgpOw0KPiAtCQlwbmZzX3JldCA9IHBu
ZnNfc2Nhbl9jb21taXRfbGlzdHMoaW5vZGUsIG1heCAtIHJldCk7DQo+IC0JCXJldCArPSBwbmZz
X3JldDsNCg0KTm8hIElmIHdlJ3ZlIHNjYW5uZWQgcE5GUyBwYWdlcyB0byBjb21taXQsIHRoZW4g
d2UgbmVlZCB0byByZXBvcnQgdGhpcw0KdG8gbmZzX2NvbW1pdF9pbm9kZS4gT3RoZXJ3aXNlIGl0
IHdpbGwgc2tpcCBzZW5kaW5nIHRoZSBSUEMgY2FsbHMuDQoNCj4gLQkJbmZzaS0+bmNvbW1pdCAt
PSByZXQ7DQoJCV5eXl5eXl5eXl5eXl5eXl5eXl5eXl4NCkkgYWdyZWUgd2l0aCB0aGlzLi4uIEkg
Zm9yZ290IHRvIHJlbW92ZSBpdC4NCg0KPiArCQlwbmZzX3NjYW5fY29tbWl0X2xpc3RzKGlub2Rl
LCBtYXggLSByZXQpOw0KPiAgCX0NCj4gIAlzcGluX3VubG9jaygmaW5vZGUtPmlfbG9jayk7DQo+
ICAJcmV0dXJuIHJldDsNCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQg
bWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0
YXBwLmNvbQ0KDQo=
