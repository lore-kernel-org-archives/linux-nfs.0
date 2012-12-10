Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:35369 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751442Ab2LJUCZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2012 15:02:25 -0500
Received: from vmwexceht05-prd.hq.netapp.com (exchsmtp.hq.netapp.com [10.106.77.35])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id qBAK2PMZ010457
	for <linux-nfs@vger.kernel.org>; Mon, 10 Dec 2012 12:02:25 -0800 (PST)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] SUNRPC: release clear_bit memory barrier
Date: Mon, 10 Dec 2012 20:02:24 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91191F135@SACEXCMBX04-PRD.hq.netapp.com>
References: <1354298985-2344-1-git-send-email-andros@netapp.com>
In-Reply-To: <1354298985-2344-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEyLTExLTMwIGF0IDEzOjA5IC0wNTAwLCBhbmRyb3NAbmV0YXBwLmNvbSB3cm90
ZToNCj4gRnJvbTogQW5keSBBZGFtc29uIDxhbmRyb3NAbmV0YXBwLmNvbT4NCj4gDQo+IFNpZ25l
ZC1vZmYtYnk6IEFuZHkgQWRhbXNvbiA8YW5kcm9zQG5ldGFwcC5jb20+DQo+IC0tLQ0KPiBBIGNs
ZWFudXAgcGF0Y2guDQo+IA0KPiAgbmV0L3N1bnJwYy9hdXRoLmMgICAgICAgICAgICAgIHwgICAg
MSArDQo+ICBuZXQvc3VucnBjL2F1dGhfZ3NzL2F1dGhfZ3NzLmMgfCAgICAxICsNCj4gIDIgZmls
ZXMgY2hhbmdlZCwgMiBpbnNlcnRpb25zKCspLCAwIGRlbGV0aW9ucygtKQ0KPiANCj4gZGlmZiAt
LWdpdCBhL25ldC9zdW5ycGMvYXV0aC5jIGIvbmV0L3N1bnJwYy9hdXRoLmMNCj4gaW5kZXggYjVj
MDY3Yi4uOGI3Njc1MyAxMDA2NDQNCj4gLS0tIGEvbmV0L3N1bnJwYy9hdXRoLmMNCj4gKysrIGIv
bmV0L3N1bnJwYy9hdXRoLmMNCj4gQEAgLTIyNSw2ICsyMjUsNyBAQCBycGNhdXRoX3VuaGFzaF9j
cmVkX2xvY2tlZChzdHJ1Y3QgcnBjX2NyZWQgKmNyZWQpDQo+ICAJaGxpc3RfZGVsX3JjdSgmY3Jl
ZC0+Y3JfaGFzaCk7DQo+ICAJc21wX21iX19iZWZvcmVfY2xlYXJfYml0KCk7DQo+ICAJY2xlYXJf
Yml0KFJQQ0FVVEhfQ1JFRF9IQVNIRUQsICZjcmVkLT5jcl9mbGFncyk7DQo+ICsJc21wX21iX19h
ZnRlcl9jbGVhcl9iaXQoKTsNCj4gIH0NCj4gIA0KPiAgc3RhdGljIGludA0KPiBkaWZmIC0tZ2l0
IGEvbmV0L3N1bnJwYy9hdXRoX2dzcy9hdXRoX2dzcy5jIGIvbmV0L3N1bnJwYy9hdXRoX2dzcy9h
dXRoX2dzcy5jDQo+IGluZGV4IDkwOWRjMGMuLjkyYTdkNmQgMTAwNjQ0DQo+IC0tLSBhL25ldC9z
dW5ycGMvYXV0aF9nc3MvYXV0aF9nc3MuYw0KPiArKysgYi9uZXQvc3VucnBjL2F1dGhfZ3NzL2F1
dGhfZ3NzLmMNCj4gQEAgLTEyNiw2ICsxMjYsNyBAQCBnc3NfY3JlZF9zZXRfY3R4KHN0cnVjdCBy
cGNfY3JlZCAqY3JlZCwgc3RydWN0IGdzc19jbF9jdHggKmN0eCkNCj4gIAlzZXRfYml0KFJQQ0FV
VEhfQ1JFRF9VUFRPREFURSwgJmNyZWQtPmNyX2ZsYWdzKTsNCj4gIAlzbXBfbWJfX2JlZm9yZV9j
bGVhcl9iaXQoKTsNCj4gIAljbGVhcl9iaXQoUlBDQVVUSF9DUkVEX05FVywgJmNyZWQtPmNyX2Zs
YWdzKTsNCj4gKwlzbXBfbWJfX2FmdGVyX2NsZWFyX2JpdCgpOw0KPiAgfQ0KPiAgDQo+ICBzdGF0
aWMgY29uc3Qgdm9pZCAqDQoNCldoeSBhcmUgdGhlc2UgbmVlZGVkPw0KDQotLSANClRyb25kIE15
a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlr
bGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQo=
