Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:11874 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751062Ab2JRStP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Oct 2012 14:49:15 -0400
Received: from vmwexceht04-prd.hq.netapp.com (vmwexceht04-prd.hq.netapp.com [10.106.77.34])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q9IInFl3027401
	for <linux-nfs@vger.kernel.org>; Thu, 18 Oct 2012 11:49:15 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 04/25] SUNRPC: remove BUG_ON() from call_transmit()
Date: Thu, 18 Oct 2012 18:49:14 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA909281240@SACEXCMBX04-PRD.hq.netapp.com>
References: <1350405043-39316-1-git-send-email-dros@netapp.com>
	 <1350405043-39316-4-git-send-email-dros@netapp.com>
In-Reply-To: <1350405043-39316-4-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTEwLTE2IGF0IDEyOjMwIC0wNDAwLCBXZXN0b24gQW5kcm9zIEFkYW1zb24g
d3JvdGU6DQo+IFJlcGxhY2UgQlVHX09OKCkgd2l0aCBXQVJOX09OX09OQ0UoKSBhbmQgaWYgdGhl
IGVycm9yIGNvbmRpdGlvbiBpcyB0cnVlDQo+IGF0dGVtcHQgdG8gZ3JhY2VmdWxseSByZWNvdmVy
IGJ5IGNhbGxpbmcgcnBjX2V4aXQoKS4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IFdlc3RvbiBBbmRy
b3MgQWRhbXNvbiA8ZHJvc0BuZXRhcHAuY29tPg0KPiAtLS0NCj4gIG5ldC9zdW5ycGMvY2xudC5j
IHwgICAgNiArKysrKy0NCj4gIDEgZmlsZSBjaGFuZ2VkLCA1IGluc2VydGlvbnMoKyksIDEgZGVs
ZXRpb24oLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9uZXQvc3VucnBjL2NsbnQuYyBiL25ldC9zdW5y
cGMvY2xudC5jDQo+IGluZGV4IGZlOGExMzMuLjc2ZDE3MzAgMTAwNjQ0DQo+IC0tLSBhL25ldC9z
dW5ycGMvY2xudC5jDQo+ICsrKyBiL25ldC9zdW5ycGMvY2xudC5jDQo+IEBAIC0xNjYxLDcgKzE2
NjEsMTEgQEAgY2FsbF90cmFuc21pdChzdHJ1Y3QgcnBjX3Rhc2sgKnRhc2spDQo+ICAJdGFzay0+
dGtfYWN0aW9uID0gY2FsbF90cmFuc21pdF9zdGF0dXM7DQo+ICAJLyogRW5jb2RlIGhlcmUgc28g
dGhhdCBycGNzZWNfZ3NzIGNhbiB1c2UgY29ycmVjdCBzZXF1ZW5jZSBudW1iZXIuICovDQo+ICAJ
aWYgKHJwY190YXNrX25lZWRfZW5jb2RlKHRhc2spKSB7DQo+IC0JCUJVR19PTih0YXNrLT50a19y
cXN0cC0+cnFfYnl0ZXNfc2VudCAhPSAwKTsNCj4gKwkJV0FSTl9PTih0YXNrLT50a19ycXN0cC0+
cnFfYnl0ZXNfc2VudCAhPSAwKTsNCg0KV0FSTl9PTl9PTkNFKCk/DQoNCj4gKwkJaWYgKHRhc2st
PnRrX3Jxc3RwLT5ycV9ieXRlc19zZW50ICE9IDApIHsNCj4gKwkJCXJwY19leGl0KHRhc2ssIC1F
SU5WQUwpOw0KPiArCQkJcmV0dXJuOw0KPiArCQl9DQo+ICAJCXJwY194ZHJfZW5jb2RlKHRhc2sp
Ow0KPiAgCQkvKiBEaWQgdGhlIGVuY29kZSByZXN1bHQgaW4gYW4gZXJyb3IgY29uZGl0aW9uPyAq
Lw0KPiAgCQlpZiAodGFzay0+dGtfc3RhdHVzICE9IDApIHsNCg0KLS0gDQpUcm9uZCBNeWtsZWJ1
c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVz
dEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0K
