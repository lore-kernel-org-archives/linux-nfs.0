Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:7014 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751588Ab2BPTbV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Feb 2012 14:31:21 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q1GJVKLM000374
	for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 11:31:20 -0800 (PST)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFSv4.1 set the cl_hostname for data servers
Date: Thu, 16 Feb 2012 19:31:14 +0000
Message-ID: <1329420674.4279.15.camel@lade.trondhjem.org>
References: <1329339546-1899-1-git-send-email-andros@netapp.com>
In-Reply-To: <1329339546-1899-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTAyLTE1IGF0IDE1OjU5IC0wNTAwLCBhbmRyb3NAbmV0YXBwLmNvbSB3cm90
ZToNCj4gRnJvbTogQW5keSBBZGFtc29uIDxhbmRyb3NAbmV0YXBwLmNvbT4NCj4gDQo+IFVzZWQg
YnkgL3Byb2MvZnMvbmZzZnMgZmlsZXMuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBBbmR5IEFkYW1z
b24gPGFuZHJvc0BuZXRhcHAuY29tPg0KPiAtLS0NCj4gIGZzL25mcy9jbGllbnQuYyB8ICAgMTQg
KysrKysrKysrKysrKysNCj4gIDEgZmlsZXMgY2hhbmdlZCwgMTQgaW5zZXJ0aW9ucygrKSwgMCBk
ZWxldGlvbnMoLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9mcy9uZnMvY2xpZW50LmMgYi9mcy9uZnMv
Y2xpZW50LmMNCj4gaW5kZXggZDBmODUwZi4uOWU5Y2I1MCAxMDA2NDQNCj4gLS0tIGEvZnMvbmZz
L2NsaWVudC5jDQo+ICsrKyBiL2ZzL25mcy9jbGllbnQuYw0KPiBAQCAtMTQ2OCw3ICsxNDY4LDIx
IEBAIHN0cnVjdCBuZnNfY2xpZW50ICpuZnM0X3NldF9kc19jbGllbnQoc3RydWN0IG5mc19jbGll
bnQqIG1kc19jbHAsDQo+ICAJICovDQo+ICAJY2xwID0gbmZzX2dldF9jbGllbnQoJmNsX2luaXQs
ICZkc190aW1lb3V0LCBtZHNfY2xwLT5jbF9pcGFkZHIsDQo+ICAJCQkgICAgIG1kc19jbHAtPmNs
X3JwY2NsaWVudC0+Y2xfYXV0aC0+YXVfZmxhdm9yLCAwKTsNCj4gKwlpZiAoSVNfRVJSKGNscCkp
DQo+ICsJCXJldHVybiBjbHA7DQo+ICANCj4gKwkvKg0KPiArCSAqIGNsX2luaXQuc2VydmVybmFt
ZSBpcyBOVUxMIHNvIHRoZSBjbF9ob3N0bmFtZSBpcyBub3Qgc2V0IGZvciBuZXcNCj4gKwkgKiBk
cyBuZnNfY2xpZW50cw0KPiArCSAqLw0KPiArCWlmIChjbHAtPmNsX2hvc3RuYW1lID09IE5VTEwp
IHsNCj4gKwkJY2xwLT5jbF9ob3N0bmFtZSA9IGtzdHJkdXAoY2xwLT5jbF9ycGNjbGllbnQtPmNs
X3NlcnZlciwNCj4gKwkJCQkJICAgR0ZQX0tFUk5FTCk7DQo+ICsJCWlmIChjbHAtPmNsX2hvc3Ru
YW1lID09IE5VTEwpIHsNCj4gKwkJCW5mc19wdXRfY2xpZW50KGNscCk7DQo+ICsJCQlyZXR1cm4g
RVJSX1BUUigtRU5PTUVNKTsNCj4gKwkJfQ0KPiArCX0NCj4gIAlkcHJpbnRrKCI8LS0gJXMgJXBc
biIsIF9fZnVuY19fLCBjbHApOw0KPiAgCXJldHVybiBjbHA7DQo+ICB9DQoNCkNvdWxkIHdlIHBs
ZWFzZSBqdXN0IHNldCBpdCBjb3JyZWN0bHkgaW4gdGhlIGNsX2luaXQgc3RydWN0dXJlIGluDQpu
ZnM0X3NldF9kc19jbGllbnQgaW5zdGVhZD8NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4
IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAu
Y29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
