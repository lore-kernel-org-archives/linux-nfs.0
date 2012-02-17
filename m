Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:38845 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751537Ab2BQSlU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Feb 2012 13:41:20 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q1HIf5dc014546
	for <linux-nfs@vger.kernel.org>; Fri, 17 Feb 2012 10:41:05 -0800 (PST)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] NFSv4.1 set highest_used_slotid to NFS4_NO_SLOT
Date: Fri, 17 Feb 2012 18:40:58 +0000
Message-ID: <1329504057.12048.0.camel@lade.trondhjem.org>
References: <1329501923-3999-1-git-send-email-andros@netapp.com>
	 <1329501923-3999-3-git-send-email-andros@netapp.com>
In-Reply-To: <1329501923-3999-3-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEyLTAyLTE3IGF0IDEzOjA1IC0wNTAwLCBhbmRyb3NAbmV0YXBwLmNvbSB3cm90
ZToNCj4gRnJvbTogQW5keSBBZGFtc29uIDxhbmRyb3NAbmV0YXBwLmNvbT4NCj4gDQo+IFNpZ25l
ZC1vZmYtYnk6IEFuZHkgQWRhbXNvbiA8YW5kcm9zQG5ldGFwcC5jb20+DQo+IC0tLQ0KPiAgZnMv
bmZzL25mczRzdGF0ZS5jIHwgICAgMiArLQ0KPiAgMSBmaWxlcyBjaGFuZ2VkLCAxIGluc2VydGlv
bnMoKyksIDEgZGVsZXRpb25zKC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvZnMvbmZzL25mczRzdGF0
ZS5jIGIvZnMvbmZzL25mczRzdGF0ZS5jDQo+IGluZGV4IDRlMzc4MTguLmMxMTExYTMgMTAwNjQ0
DQo+IC0tLSBhL2ZzL25mcy9uZnM0c3RhdGUuYw0KPiArKysgYi9mcy9uZnMvbmZzNHN0YXRlLmMN
Cj4gQEAgLTIxMiw3ICsyMTIsNyBAQCBzdGF0aWMgdm9pZCBuZnM0X2VuZF9kcmFpbl9zZXNzaW9u
KHN0cnVjdCBuZnNfY2xpZW50ICpjbHApDQo+ICBzdGF0aWMgaW50IG5mczRfd2FpdF9vbl9zbG90
X3RibChzdHJ1Y3QgbmZzNF9zbG90X3RhYmxlICp0YmwpDQo+ICB7DQo+ICAJc3Bpbl9sb2NrKCZ0
YmwtPnNsb3RfdGJsX2xvY2spOw0KPiAtCWlmICh0YmwtPmhpZ2hlc3RfdXNlZF9zbG90aWQgIT0g
LTEpIHsNCj4gKwlpZiAodGJsLT5oaWdoZXN0X3VzZWRfc2xvdGlkICE9IE5GUzRfTk9fU0xPVCkg
ew0KPiAgCQlJTklUX0NPTVBMRVRJT04odGJsLT5jb21wbGV0ZSk7DQo+ICAJCXNwaW5fdW5sb2Nr
KCZ0YmwtPnNsb3RfdGJsX2xvY2spOw0KPiAgCQlyZXR1cm4gd2FpdF9mb3JfY29tcGxldGlvbl9p
bnRlcnJ1cHRpYmxlKCZ0YmwtPmNvbXBsZXRlKTsNCg0KR29vZCBjYXRjaCEgQXBwbGllZC4uLg0K
DQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5l
dEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQoNCg==
