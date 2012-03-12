Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:1616 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756110Ab2CLSM2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Mar 2012 14:12:28 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Always use the same SETCLIENTID boot verifier
Date: Mon, 12 Mar 2012 18:12:08 +0000
Message-ID: <1331575925.8219.34.camel@lade.trondhjem.org>
References: <20120309223445.4005.78869.stgit@degas.1015granger.net>
	 <776DF26C-1223-42ED-B356-234A5C66E034@oracle.com>
In-Reply-To: <776DF26C-1223-42ED-B356-234A5C66E034@oracle.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTAzLTEyIGF0IDEzOjM5IC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
SGktDQo+IA0KPiBPbiBNYXIgOSwgMjAxMiwgYXQgNTozNSBQTSwgQ2h1Y2sgTGV2ZXIgd3JvdGU6
DQo+IA0KPiA+IGRpZmYgLS1naXQgYS9mcy9uZnMvbmZzNHByb2MuYyBiL2ZzL25mcy9uZnM0cHJv
Yy5jDQo+ID4gaW5kZXggYzBkNzIyMC4uNzQ3YmY3YSAxMDA2NDQNCj4gPiAtLS0gYS9mcy9uZnMv
bmZzNHByb2MuYw0KPiA+ICsrKyBiL2ZzL25mcy9uZnM0cHJvYy5jDQo+ID4gQEAgLTM3NzMsMTMg
KzM3NzMsMTIgQEAgd2FpdF9vbl9yZWNvdmVyeToNCj4gPiAJcmV0dXJuIC1FQUdBSU47DQo+ID4g
fQ0KPiA+IA0KPiA+IC1zdGF0aWMgdm9pZCBuZnM0X2NvbnN0cnVjdF9ib290X3ZlcmlmaWVyKHN0
cnVjdCBuZnNfY2xpZW50ICpjbHAsDQo+ID4gLQkJCQkJIG5mczRfdmVyaWZpZXIgKmJvb3R2ZXJm
KQ0KPiA+ICtzdGF0aWMgdm9pZCBuZnM0X2dlbl9ib290X3ZlcmlmaWVyKG5mczRfdmVyaWZpZXIg
KmJvb3R2ZXJmKQ0KPiA+IHsNCj4gPiAJX19iZTMyIHZlcmZbMl07DQo+ID4gDQo+ID4gLQl2ZXJm
WzBdID0gaHRvbmwoKHUzMiljbHAtPmNsX2Jvb3RfdGltZS50dl9zZWMpOw0KPiA+IC0JdmVyZlsx
XSA9IGh0b25sKCh1MzIpY2xwLT5jbF9ib290X3RpbWUudHZfbnNlYyk7DQo+ID4gKwl2ZXJmWzBd
ID0gY3B1X3RvX2JlMzIoKHUzMiluZnNfYm9vdF90aW1lLnR2X3NlYyk7DQo+ID4gKwl2ZXJmWzFd
ID0gY3B1X3RvX2JlMzIoKHUzMiluZnNfYm9vdF90aW1lLnR2X25zZWMpOw0KPiA+IAltZW1jcHko
Ym9vdHZlcmYtPmRhdGEsIHZlcmYsIHNpemVvZihib290dmVyZi0+ZGF0YSkpOw0KPiA+IH0NCj4g
PiANCj4gDQo+IA0KPiBPbmUgb3RoZXIgcXVlc3Rpb24gSSBoYWQgYWJvdXQgdGhpcy4gIERvIHdl
IHJlYWxseSBuZWVkIHRvIHBlcmZvcm0gYnl0ZS1zd2FwcGluZyB3aGVuIGNvbnN0cnVjdGluZyBh
IGJvb3QgdmVyaWZpZXI/ICBJdCdzIHN1cHBvc2VkIHRvIGJlIG9wYXF1ZS4NCg0KTm8gd2UgZG9u
J3QgbmVlZCB0byBkbyB0aGF0Lg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNs
aWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3
dy5uZXRhcHAuY29tDQoNCg==
