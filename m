Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:16023 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755921Ab3DYPmx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Apr 2013 11:42:53 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Matt W. Benjamin" <matt@linuxbox.com>
CC: David Wysochanski <dwysocha@redhat.com>,
        Dave Chiluk <chiluk@canonical.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>
Subject: RE: [PATCH] NFSv4: Use exponential backoff delay for Ni
Date: Thu, 25 Apr 2013 15:42:50 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9287414AA@SACEXCMBX04-PRD.hq.netapp.com>
References: <1366899034.6812.4.camel@leira.trondhjem.org>
 <916743278.65.1366903701195.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <916743278.65.1366903701195.JavaMail.root@thunderbeast.private.linuxbox.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

SXQncyBsZWdhbCwgYnV0IGR1bWIuLi4NCg0KPiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0K
PiBGcm9tOiBNYXR0IFcuIEJlbmphbWluIFttYWlsdG86bWF0dEBsaW51eGJveC5jb21dDQo+IFNl
bnQ6IFRodXJzZGF5LCBBcHJpbCAyNSwgMjAxMyAxMToyOCBBTQ0KPiBUbzogTXlrbGVidXN0LCBU
cm9uZA0KPiBDYzogRGF2aWQgV3lzb2NoYW5za2k7IERhdmUgQ2hpbHVrOyBsaW51eC1uZnNAdmdl
ci5rZXJuZWwub3JnOyBsaW51eC0NCj4ga2VybmVsQHZnZXIua2VybmVsLm9yZzsgYmZpZWxkc0Bm
aWVsZHNlcy5vcmcNCj4gU3ViamVjdDogUmU6IFtQQVRDSF0gTkZTdjQ6IFVzZSBleHBvbmVudGlh
bCBiYWNrb2ZmIGRlbGF5IGZvciBOaQ0KPiANCj4gSGksDQo+IA0KPiBKdXN0IHRvIGNsYXJpZnks
IHRoZSBJQk0gZGVsYXkgYmVoYXZpb3IgaXMgbm90IGxlZ2FsPw0KPiANCj4gTWF0dA0KPiANCj4g
LS0tLS0gIlRyb25kIE15a2xlYnVzdCIgPFRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tPiB3cm90
ZToNCj4gDQo+ID4NCj4gPiBPSywgdGhlbi4gTm93IGFsbCBJIG5lZWQgaXMgYWN0dWFsIG1vdGl2
YXRpb24gZm9yIGNoYW5naW5nIHRoZQ0KPiA+IGV4aXN0aW5nIGNvZGUgb3RoZXIgdGhhbiBoYW5k
d2F2aW5nIGFyZ3VtZW50cyBhYm91dCAicG9sbGluZyBpcyBiZXR0ZXINCj4gPiB0aGFuIGZsYXQg
d2FpdHMiLg0KPiA+IFdoYXQgYWN0dWFsIHVzZSBjYXNlcyBhcmUgaW1wYWN0aW5nIHVzIG5vdywg
b3RoZXIgdGhhbiB0aGUgQUlYIGRlc2lnbg0KPiA+IGRlY2lzaW9uIHRvIGZvcmNlIENMT1NFIHRv
IHJldHJ5IGF0IGxlYXN0IG9uY2UgYmVmb3JlIHN1Y2NlZWRpbmc/DQo+ID4NCj4gDQo+IA0KPiAt
LQ0KPiBNYXR0IEJlbmphbWluDQo+IFRoZSBMaW51eCBCb3gNCj4gMjA2IFNvdXRoIEZpZnRoIEF2
ZS4gU3VpdGUgMTUwDQo+IEFubiBBcmJvciwgTUkgIDQ4MTA0DQo+IA0KPiBodHRwOi8vbGludXhi
b3guY29tDQo+IA0KPiB0ZWwuICA3MzQtNzYxLTQ2ODkNCj4gZmF4LiAgNzM0LTc2OS04OTM4DQo+
IGNlbC4gIDczNC0yMTYtNTMwOQ0K
