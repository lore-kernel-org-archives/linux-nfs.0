Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:49483 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754574Ab2BPUnW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Feb 2012 15:43:22 -0500
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q1GKhLPB025289
	for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 12:43:22 -0800 (PST)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] NFSv4: fix server_scope memory leak
Date: Thu, 16 Feb 2012 20:43:13 +0000
Message-ID: <1329424993.19793.12.camel@lade.trondhjem.org>
References: <1329409026-20466-1-git-send-email-dros@netapp.com>
	 <1329409026-20466-2-git-send-email-dros@netapp.com>
In-Reply-To: <1329409026-20466-2-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEyLTAyLTE2IGF0IDExOjE3IC0wNTAwLCBXZXN0b24gQW5kcm9zIEFkYW1zb24g
d3JvdGU6DQo+IHNlcnZlcl9zY29wZSB3b3VsZCBuZXZlciBiZSBmcmVlZCBpZiBuZnM0X2NoZWNr
X2NsX2V4Y2hhbmdlX2ZsYWdzKCkgcmV0dXJuZWQNCj4gbm9uLXplcm8NCj4gDQo+IFNpZ25lZC1v
ZmYtYnk6IFdlc3RvbiBBbmRyb3MgQWRhbXNvbiA8ZHJvc0BuZXRhcHAuY29tPg0KPiAtLS0NCj4g
IGZzL25mcy9uZnM0cHJvYy5jIHwgICAxNSArKysrKysrKystLS0tLS0NCj4gIDEgZmlsZXMgY2hh
bmdlZCwgOSBpbnNlcnRpb25zKCspLCA2IGRlbGV0aW9ucygtKQ0KPiANCj4gZGlmZiAtLWdpdCBh
L2ZzL25mcy9uZnM0cHJvYy5jIGIvZnMvbmZzL25mczRwcm9jLmMNCj4gaW5kZXggODdjNTg0ZC4u
MjBjM2JiMCAxMDA2NDQNCj4gLS0tIGEvZnMvbmZzL25mczRwcm9jLmMNCj4gKysrIGIvZnMvbmZz
L25mczRwcm9jLmMNCj4gQEAgLTQ5NDUsOCArNDk0NSwxMCBAQCBpbnQgbmZzNF9wcm9jX2V4Y2hh
bmdlX2lkKHN0cnVjdCBuZnNfY2xpZW50ICpjbHAsIHN0cnVjdCBycGNfY3JlZCAqY3JlZCkNCj4g
IAkJCQljbHAtPmNsX3JwY2NsaWVudC0+Y2xfYXV0aC0+YXVfZmxhdm9yKTsNCj4gIA0KPiAgCXJl
cy5zZXJ2ZXJfc2NvcGUgPSBremFsbG9jKHNpemVvZihzdHJ1Y3Qgc2VydmVyX3Njb3BlKSwgR0ZQ
X0tFUk5FTCk7DQo+IC0JaWYgKHVubGlrZWx5KCFyZXMuc2VydmVyX3Njb3BlKSkNCj4gLQkJcmV0
dXJuIC1FTk9NRU07DQo+ICsJaWYgKHVubGlrZWx5KCFyZXMuc2VydmVyX3Njb3BlKSkgew0KPiAr
CQlzdGF0dXMgPSAtRU5PTUVNOw0KPiArCQlnb3RvIG91dDsNCj4gKwl9DQo+ICANCj4gIAlzdGF0
dXMgPSBycGNfY2FsbF9zeW5jKGNscC0+Y2xfcnBjY2xpZW50LCAmbXNnLCBSUENfVEFTS19USU1F
T1VUKTsNCj4gIAlpZiAoIXN0YXR1cykNCj4gQEAgLTQ5NjMsMTIgKzQ5NjUsMTMgQEAgaW50IG5m
czRfcHJvY19leGNoYW5nZV9pZChzdHJ1Y3QgbmZzX2NsaWVudCAqY2xwLCBzdHJ1Y3QgcnBjX2Ny
ZWQgKmNyZWQpDQo+ICAJCQljbHAtPnNlcnZlcl9zY29wZSA9IE5VTEw7DQo+ICAJCX0NCj4gIA0K
PiAtCQlpZiAoIWNscC0+c2VydmVyX3Njb3BlKQ0KPiArCQlpZiAoIWNscC0+c2VydmVyX3Njb3Bl
KSB7DQo+ICAJCQljbHAtPnNlcnZlcl9zY29wZSA9IHJlcy5zZXJ2ZXJfc2NvcGU7DQo+IC0JCWVs
c2UNCj4gLQkJCWtmcmVlKHJlcy5zZXJ2ZXJfc2NvcGUpOw0KPiArCQkJZ290byBvdXQ7DQo+ICsJ
CX0NCj4gIAl9DQo+IC0NCj4gKwlrZnJlZShyZXMuc2VydmVyX3Njb3BlKTsNCj4gK291dDoNCj4g
IAlkcHJpbnRrKCI8LS0gJXMgc3RhdHVzPSAlZFxuIiwgX19mdW5jX18sIHN0YXR1cyk7DQo+ICAJ
cmV0dXJuIHN0YXR1czsNCj4gIH0NCg0KVGhpcyBsb29rcyBsaWtlIGl0IGlzIGEgYnVnIGluIGV4
aXN0aW5nIGtlcm5lbHMuIFNob3VsZCBJIHF1ZXVlIGl0IHVwDQpmb3Igc3RhYmxlQHZnZXIua2Vy
bmVsLm9yZz8NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRh
aW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNv
bQ0KDQo=
