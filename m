Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:22624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752429Ab2JAWPg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 18:15:36 -0400
Received: from vmwexceht01-prd.hq.netapp.com (vmwexceht01-prd.hq.netapp.com [10.106.76.239])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q91MFLY4025286
	for <linux-nfs@vger.kernel.org>; Mon, 1 Oct 2012 15:15:21 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFSv4.0 reclaim reboot state when re-establishing
 clientid
Date: Mon, 1 Oct 2012 22:15:20 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA908FFAAF9@SACEXCMBX04-PRD.hq.netapp.com>
References: <1348866309-2049-1-git-send-email-andros@netapp.com>
	 <1348866309-2049-2-git-send-email-andros@netapp.com>
In-Reply-To: <1348866309-2049-2-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEyLTA5LTI4IGF0IDE3OjA1IC0wNDAwLCBhbmRyb3NAbmV0YXBwLmNvbSB3cm90
ZToNCj4gRnJvbTogQW5keSBBZGFtc29uIDxhbmRyb3NAbmV0YXBwLmNvbT4NCj4gDQo+IFdlIHNo
b3VsZCBhbHdheXMgcmVjbGFpbSBzdGF0ZSB3aGVuIHRoZSBsZWFzZSBhbmQgdGhlcmVmb3JlIHRo
ZSBjbGllbnRpZA0KPiBpcyBleHBpcmVkLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogQW5keSBBZGFt
c29uIDxhbmRyb3NAbmV0YXBwLmNvbT4NCj4gLS0tDQo+ICBmcy9uZnMvbmZzNHN0YXRlLmMgfCAg
ICA2ICsrKystLQ0KPiAgMSBmaWxlcyBjaGFuZ2VkLCA0IGluc2VydGlvbnMoKyksIDIgZGVsZXRp
b25zKC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvZnMvbmZzL25mczRzdGF0ZS5jIGIvZnMvbmZzL25m
czRzdGF0ZS5jDQo+IGluZGV4IGE1MzMxZWMuLjEzNDMyM2EgMTAwNjQ0DQo+IC0tLSBhL2ZzL25m
cy9uZnM0c3RhdGUuYw0KPiArKysgYi9mcy9uZnMvbmZzNHN0YXRlLmMNCj4gQEAgLTE2MDAsOCAr
MTYwMCw4IEBAIG91dDoNCj4gIAlyZXR1cm4gbmZzNF9yZWNvdmVyeV9oYW5kbGVfZXJyb3IoY2xw
LCBzdGF0dXMpOw0KPiAgfQ0KPiAgDQo+IC0vKiBTZXQgTkZTNENMTlRfTEVBU0VfRVhQSVJFRCBm
b3IgYWxsIHY0LjAgZXJyb3JzIGFuZCBmb3IgcmVjb3ZlcmFibGUgZXJyb3JzDQo+IC0gKiBvbiBF
WENIQU5HRV9JRCBmb3IgdjQuMQ0KPiArLyogU2V0IE5GUzRDTE5UX0xFQVNFX0VYUElSRUQgYW5k
IHJlY2xhaW0gcmVib290IHN0YXRlIGZvciBhbGwgdjQuMCBlcnJvcnMNCj4gKyAqIGFuZCBmb3Ig
cmVjb3ZlcmFibGUgZXJyb3JzIG9uIEVYQ0hBTkdFX0lEIGZvciB2NC4xDQo+ICAgKi8NCj4gIHN0
YXRpYyBpbnQgbmZzNF9oYW5kbGVfcmVjbGFpbV9sZWFzZV9lcnJvcihzdHJ1Y3QgbmZzX2NsaWVu
dCAqY2xwLCBpbnQgc3RhdHVzKQ0KPiAgew0KPiBAQCAtMTY0Nyw2ICsxNjQ3LDggQEAgc3RhdGlj
IGludCBuZnM0X2hhbmRsZV9yZWNsYWltX2xlYXNlX2Vycm9yKHN0cnVjdCBuZnNfY2xpZW50ICpj
bHAsIGludCBzdGF0dXMpDQo+ICAJCXJldHVybiBzdGF0dXM7DQo+ICAJfQ0KPiAgCXNldF9iaXQo
TkZTNENMTlRfTEVBU0VfRVhQSVJFRCwgJmNscC0+Y2xfc3RhdGUpOw0KPiArCW5mczRfc3RhdGVf
Y2xlYXJfcmVjbGFpbV9yZWJvb3QoY2xwKTsNCj4gKwluZnM0X3N0YXRlX3N0YXJ0X3JlY2xhaW1f
cmVib290KGNscCk7DQoNClRoaXMgaXMgcHJvYmFibHkgY29ycmVjdCBmb3IgTkZTNEVSUl9TVEFM
RV9DTElFTlRJRCwgYnV0IGNlcnRhaW5seSBub3QNCmZvciBORlM0RVJSX1NFUV9NSVNPUkRFUkVE
LCBvciBORlM0RVJSX0RFTEFZLi4uDQoNCj4gIAlkcHJpbnRrKCIlczogaGFuZGxlZCBlcnJvciAl
ZCBmb3Igc2VydmVyICVzXG4iLCBfX2Z1bmNfXywgc3RhdHVzLA0KPiAgCQkJY2xwLT5jbF9ob3N0
bmFtZSk7DQo+ICAJcmV0dXJuIDA7DQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMg
Y2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0K
d3d3Lm5ldGFwcC5jb20NCg==
