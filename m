Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:49971 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751563Ab2JRTAG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Oct 2012 15:00:06 -0400
Received: from vmwexceht03-prd.hq.netapp.com (vmwexceht03-prd.hq.netapp.com [10.106.76.241])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q9IJ05BC029010
	for <linux-nfs@vger.kernel.org>; Thu, 18 Oct 2012 12:00:06 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 21/25] SUNRPC: remove BUG_ON() in svc_register()
Date: Thu, 18 Oct 2012 19:00:04 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9092813CE@SACEXCMBX04-PRD.hq.netapp.com>
References: <1350405043-39316-1-git-send-email-dros@netapp.com>
	 <1350405043-39316-21-git-send-email-dros@netapp.com>
In-Reply-To: <1350405043-39316-21-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTEwLTE2IGF0IDEyOjMwIC0wNDAwLCBXZXN0b24gQW5kcm9zIEFkYW1zb24g
d3JvdGU6DQo+IEluc3RlYWQgb2YgY2FsbGluZyBCVUdfT04oKSByZXR1cm4gLUVJTlZBTC4NCj4g
DQo+IFNpZ25lZC1vZmYtYnk6IFdlc3RvbiBBbmRyb3MgQWRhbXNvbiA8ZHJvc0BuZXRhcHAuY29t
Pg0KPiAtLS0NCj4gIG5ldC9zdW5ycGMvc3ZjLmMgfCAgICAzICsrLQ0KPiAgMSBmaWxlIGNoYW5n
ZWQsIDIgaW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbigtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL25l
dC9zdW5ycGMvc3ZjLmMgYi9uZXQvc3VucnBjL3N2Yy5jDQo+IGluZGV4IDNiZjVhNTQuLmI1YWM4
YjMgMTAwNjQ0DQo+IC0tLSBhL25ldC9zdW5ycGMvc3ZjLmMNCj4gKysrIGIvbmV0L3N1bnJwYy9z
dmMuYw0KPiBAQCAtOTUwLDcgKzk1MCw4IEBAIGludCBzdmNfcmVnaXN0ZXIoY29uc3Qgc3RydWN0
IHN2Y19zZXJ2ICpzZXJ2LCBzdHJ1Y3QgbmV0ICpuZXQsDQo+ICAJdW5zaWduZWQgaW50CQlpOw0K
PiAgCWludAkJCWVycm9yID0gMDsNCj4gIA0KPiAtCUJVR19PTihwcm90byA9PSAwICYmIHBvcnQg
PT0gMCk7DQo+ICsJaWYgKHByb3RvID09IDAgJiYgcG9ydCA9PSAwKQ0KPiArCQlyZXR1cm4gLUVJ
TlZBTDsNCg0KQWdhaW4sIHRoaXMgaXMgYSBjb25kaXRpb24gdGhhdCB0aGUgdXNlciBuZWVkcyB0
byByZXBvcnQgdG8gdXMsIHNvIGENCldBUk5fT05fT05DRSgpIHdvdWxkIGJlIHVzZWZ1bC4NCg0K
PiAgCWZvciAocHJvZ3AgPSBzZXJ2LT5zdl9wcm9ncmFtOyBwcm9ncDsgcHJvZ3AgPSBwcm9ncC0+
cGdfbmV4dCkgew0KPiAgCQlmb3IgKGkgPSAwOyBpIDwgcHJvZ3AtPnBnX252ZXJzOyBpKyspIHsN
Cg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpO
ZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0K
