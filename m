Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:45823 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752027Ab2JRTJk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Oct 2012 15:09:40 -0400
Received: from vmwexceht01-prd.hq.netapp.com (vmwexceht01-prd.hq.netapp.com [10.106.76.239])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q9IJ9dmx024001
	for <linux-nfs@vger.kernel.org>; Thu, 18 Oct 2012 12:09:39 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 07/25] SUNRPC: remove BUG_ON() from call_bc_transmit()
Date: Thu, 18 Oct 2012 19:09:38 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA909281580@SACEXCMBX04-PRD.hq.netapp.com>
References: <1350405043-39316-1-git-send-email-dros@netapp.com>
	 <1350405043-39316-7-git-send-email-dros@netapp.com>
In-Reply-To: <1350405043-39316-7-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTEwLTE2IGF0IDEyOjMwIC0wNDAwLCBXZXN0b24gQW5kcm9zIEFkYW1zb24g
d3JvdGU6DQo+IFJlcGxhY2UgQlVHX09OKCkgd2l0aCBXQVJOX09OX09OQ0UoKSBhbmQgaGFuZGxl
IGVycm9yIGNvbmRpdGlvbiBieQ0KPiBjYWxsaW5nIHJwY19leGl0KCkuDQo+IA0KPiBTaWduZWQt
b2ZmLWJ5OiBXZXN0b24gQW5kcm9zIEFkYW1zb24gPGRyb3NAbmV0YXBwLmNvbT4NCj4gLS0tDQo+
ICBuZXQvc3VucnBjL2NsbnQuYyB8ICAgIDcgKysrKysrLQ0KPiAgMSBmaWxlIGNoYW5nZWQsIDYg
aW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbigtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL25ldC9zdW5y
cGMvY2xudC5jIGIvbmV0L3N1bnJwYy9jbG50LmMNCj4gaW5kZXggY2VkMGYzNi4uYmZmNjQzOCAx
MDA2NDQNCj4gLS0tIGEvbmV0L3N1bnJwYy9jbG50LmMNCj4gKysrIGIvbmV0L3N1bnJwYy9jbG50
LmMNCj4gQEAgLTE3NTAsNyArMTc1MCwxMiBAQCBjYWxsX2JjX3RyYW5zbWl0KHN0cnVjdCBycGNf
dGFzayAqdGFzaykNCj4gIHsNCj4gIAlzdHJ1Y3QgcnBjX3Jxc3QgKnJlcSA9IHRhc2stPnRrX3Jx
c3RwOw0KPiAgDQo+IC0JQlVHX09OKHRhc2stPnRrX3N0YXR1cyAhPSAwKTsNCj4gKwlXQVJOX09O
X09OQ0UodGFzay0+dGtfc3RhdHVzICE9IDApOw0KPiArCWlmICh0YXNrLT50a19zdGF0dXMgIT0g
MCkgew0KPiArCQlycGNfZXhpdCh0YXNrLCB0YXNrLT50a19zdGF0dXMpOw0KPiArCQlyZXR1cm47
DQo+ICsJfQ0KPiArDQoNCkxldCdzIGp1c3QgZ2V0IHJpZCBvZiB0aGlzLiBHaXZlbiB0aGUgY3Vy
cmVudCB1c2Ugb2YgY2FsbF9iY190cmFuc21pdCwNCml0IGxvb2tzIGNvbXBsZXRlbHkgcmVkdW5k
YW50Lg0KDQo+ICAJdGFzay0+dGtfc3RhdHVzID0geHBydF9wcmVwYXJlX3RyYW5zbWl0KHRhc2sp
Ow0KPiAgCWlmICh0YXNrLT50a19zdGF0dXMgPT0gLUVBR0FJTikgew0KPiAgCQkvKg0KDQotLSAN
ClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0K
VHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQo=
