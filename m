Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60094 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750912Ab2JRSy2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Oct 2012 14:54:28 -0400
Received: from vmwexceht01-prd.hq.netapp.com (vmwexceht01-prd.hq.netapp.com [10.106.76.239])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q9IIsRYb023176
	for <linux-nfs@vger.kernel.org>; Thu, 18 Oct 2012 11:54:27 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 08/25] SUNRPC: remove BUG_ON() from rpc_sleep_on*()
Date: Thu, 18 Oct 2012 18:54:26 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA909281304@SACEXCMBX04-PRD.hq.netapp.com>
References: <1350405043-39316-1-git-send-email-dros@netapp.com>
	 <1350405043-39316-8-git-send-email-dros@netapp.com>
In-Reply-To: <1350405043-39316-8-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTEwLTE2IGF0IDEyOjMwIC0wNDAwLCBXZXN0b24gQW5kcm9zIEFkYW1zb24g
d3JvdGU6DQo+IFJlcGxhY2UgQlVHX09OKCkgd2l0aCBXQVJOX09OX09OQ0UoKSBhbmQgY2xlYW4g
dXAgYnkgY2FsbGluZyBycGNfZXhpdCgpLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogV2VzdG9uIEFu
ZHJvcyBBZGFtc29uIDxkcm9zQG5ldGFwcC5jb20+DQo+IC0tLQ0KPiAgbmV0L3N1bnJwYy9zY2hl
ZC5jIHwgICAxMiArKysrKysrKysrLS0NCj4gIDEgZmlsZSBjaGFuZ2VkLCAxMCBpbnNlcnRpb25z
KCspLCAyIGRlbGV0aW9ucygtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL25ldC9zdW5ycGMvc2NoZWQu
YyBiL25ldC9zdW5ycGMvc2NoZWQuYw0KPiBpbmRleCA2MzU3ZmNiLi5lYzk1MTNkIDEwMDY0NA0K
PiAtLS0gYS9uZXQvc3VucnBjL3NjaGVkLmMNCj4gKysrIGIvbmV0L3N1bnJwYy9zY2hlZC5jDQo+
IEBAIC0zNDMsNyArMzQzLDExIEBAIHZvaWQgcnBjX3NsZWVwX29uKHN0cnVjdCBycGNfd2FpdF9x
dWV1ZSAqcSwgc3RydWN0IHJwY190YXNrICp0YXNrLA0KPiAgCQkJCXJwY19hY3Rpb24gYWN0aW9u
KQ0KPiAgew0KPiAgCS8qIFdlIHNob3VsZG4ndCBldmVyIHB1dCBhbiBpbmFjdGl2ZSB0YXNrIHRv
IHNsZWVwICovDQo+IC0JQlVHX09OKCFSUENfSVNfQUNUSVZBVEVEKHRhc2spKTsNCj4gKwlXQVJO
X09OX09OQ0UoIVJQQ19JU19BQ1RJVkFURUQodGFzaykpOw0KPiArCWlmICghUlBDX0lTX0FDVElW
QVRFRCh0YXNrKSkgew0KPiArCQlycGNfZXhpdCh0YXNrLCAtRUlOVkFMKTsNCg0KV2Ugc2hvdWxk
IG5vdCBjYWxsIHJwY19leGl0KCksIHNpbmNlIHRoZSBSUEMgY2FsbCBoYXNuJ3QgZXZlbiBiZWVu
DQpzdGFydGVkIGF0IHRoaXMgdGltZS4gV2Ugc2hvdWxkIHJhdGhlciBzZXQgdGFzay0+dGtfc3Rh
dHVzIHRvIC1FSU8sIGFuZA0KdGhlbiBjYWxsIHJwY19wdXRfdGFza19hc3luYygpLg0KDQo+ICsJ
CXJldHVybjsNCj4gKwl9DQo+ICANCj4gIAkvKg0KPiAgCSAqIFByb3RlY3QgdGhlIHF1ZXVlIG9w
ZXJhdGlvbnMuDQo+IEBAIC0zNTgsNyArMzYyLDExIEBAIHZvaWQgcnBjX3NsZWVwX29uX3ByaW9y
aXR5KHN0cnVjdCBycGNfd2FpdF9xdWV1ZSAqcSwgc3RydWN0IHJwY190YXNrICp0YXNrLA0KPiAg
CQlycGNfYWN0aW9uIGFjdGlvbiwgaW50IHByaW9yaXR5KQ0KPiAgew0KPiAgCS8qIFdlIHNob3Vs
ZG4ndCBldmVyIHB1dCBhbiBpbmFjdGl2ZSB0YXNrIHRvIHNsZWVwICovDQo+IC0JQlVHX09OKCFS
UENfSVNfQUNUSVZBVEVEKHRhc2spKTsNCj4gKwlXQVJOX09OX09OQ0UoIVJQQ19JU19BQ1RJVkFU
RUQodGFzaykpOw0KPiArCWlmICghUlBDX0lTX0FDVElWQVRFRCh0YXNrKSkgew0KPiArCQlycGNf
ZXhpdCh0YXNrLCAtRUlOVkFMKTsNCj4gKwkJcmV0dXJuOw0KPiArCX0NCj4gIA0KPiAgCS8qDQo+
ICAJICogUHJvdGVjdCB0aGUgcXVldWUgb3BlcmF0aW9ucy4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1
c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVz
dEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0K
