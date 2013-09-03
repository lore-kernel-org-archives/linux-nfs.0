Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:24190 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755723Ab3ICQHs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Sep 2013 12:07:48 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 5 1/5] SUNRPC: don't map EKEYEXPIRED to EACCES
 in call_refreshresult
Date: Tue, 3 Sep 2013 16:07:47 +0000
Message-ID: <1378224467.6410.3.camel@leira.trondhjem.org>
References: <1376495957-7482-1-git-send-email-andros@netapp.com>
	 <1376495957-7482-2-git-send-email-andros@netapp.com>
In-Reply-To: <1376495957-7482-2-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEzLTA4LTE0IGF0IDExOjU5IC0wNDAwLCBhbmRyb3NAbmV0YXBwLmNvbSB3cm90
ZToNCj4gRnJvbTogQW5keSBBZGFtc29uIDxhbmRyb3NAbmV0YXBwLmNvbT4NCj4gDQo+IFRoZSBO
RlMgbGF5ZXIgbmVlZHMgdG8ga25vdyB3aGVuIGEga2V5IGhhcyBleHBpcmVkLg0KPiBUaGlzIGNo
YW5nZSBhbHNvIHJldHVybnMgLUVLRVlFWFBJUkVEIHRvIHRoZSBhcHBsaWNhdGlvbiwgYW5kIHRo
ZSBpbmZvcm1hdGl2ZQ0KPiAiS2V5IGhhcyBleHBpcmVkIiBlcnJvciBtZXNzYWdlIGlzIGRpc3Bs
YXllZC4gVGhlIHVzZXIgdGhlbiBrbm93cyB0aGF0DQo+IGNyZWRlbnRpYWwgcmVuZXdhbCBpcyBy
ZXF1aXJlZC4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IEFuZHkgQWRhbXNvbiA8YW5kcm9zQG5ldGFw
cC5jb20+DQo+IC0tLQ0KPiAgbmV0L3N1bnJwYy9jbG50LmMgfCAyICstDQo+ICAxIGZpbGUgY2hh
bmdlZCwgMSBpbnNlcnRpb24oKyksIDEgZGVsZXRpb24oLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9u
ZXQvc3VucnBjL2NsbnQuYyBiL25ldC9zdW5ycGMvY2xudC5jDQo+IGluZGV4IGVjYmM0ZTMuLmI1
NDQ5NjUgMTAwNjQ0DQo+IC0tLSBhL25ldC9zdW5ycGMvY2xudC5jDQo+ICsrKyBiL25ldC9zdW5y
cGMvY2xudC5jDQo+IEBAIC0xNDIzLDkgKzE0MjMsOSBAQCBjYWxsX3JlZnJlc2hyZXN1bHQoc3Ry
dWN0IHJwY190YXNrICp0YXNrKQ0KPiAgCQlyZXR1cm47DQo+ICAJY2FzZSAtRVRJTUVET1VUOg0K
PiAgCQlycGNfZGVsYXkodGFzaywgMypIWik7DQo+IC0JY2FzZSAtRUtFWUVYUElSRUQ6DQo+ICAJ
Y2FzZSAtRUFHQUlOOg0KPiAgCQlzdGF0dXMgPSAtRUFDQ0VTOw0KPiArCWNhc2UgLUVLRVlFWFBJ
UkVEOg0KPiAgCQlpZiAoIXRhc2stPnRrX2NyZWRfcmV0cnkpDQo+ICAJCQlicmVhazsNCj4gIAkJ
dGFzay0+dGtfY3JlZF9yZXRyeS0tOw0KDQpBcHBsaWVkLg0KDQotLSANClRyb25kIE15a2xlYnVz
dA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0
QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQo=
