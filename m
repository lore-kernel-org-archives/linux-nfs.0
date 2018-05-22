Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-by2nam03on0134.outbound.protection.outlook.com ([104.47.42.134]:28832
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751319AbeEVTDD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 22 May 2018 15:03:03 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "kolga@netapp.com" <kolga@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] [SUNRPC] make sure to clone timeout values
Date: Tue, 22 May 2018 19:03:01 +0000
Message-ID: <d9d84d1b2cdb6054aba1ed5124f4d632355dec0b.camel@hammerspace.com>
References: <20180522184048.21586-1-kolga@netapp.com>
In-Reply-To: <20180522184048.21586-1-kolga@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDE4LTA1LTIyIGF0IDE0OjQwIC0wNDAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90
ZToNCj4gRnJvbTogT2xnYSBLb3JuaWV2c2thaWEgPG9sZ2Eua29ybmlldnNrYWlhQGdtYWlsLmNv
bT4NCj4gDQo+IEZvciBwTkZTLCB0aGUgb3BlcmF0aW9ucyB0byBEUyBjdXJyZW50bHkgdGltZW91
dCBpbiAxMHMuIEFjY29yZGluZw0KPiB0byB0aGUgc3BlYywgdGhlIGNsaWVudCBtdXN0IG5vdCBi
ZSByZS10cnlpbmcgYW4gTkZTdjQuMSBvcGVyYXRpb24NCj4gdW5sZXNzIHRoZSBjb25uZWN0aW9u
IHdhcyBicm9rZW4uDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBPbGdhIEtvcm5pZXZza2FpYSA8a29s
Z2FAbmV0YXBwLmNvbT4NCj4gLS0tDQo+ICBuZXQvc3VucnBjL2NsbnQuYyB8IDEgKw0KPiAgMSBm
aWxlIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCspDQo+IA0KPiBkaWZmIC0tZ2l0IGEvbmV0L3N1bnJw
Yy9jbG50LmMgYi9uZXQvc3VucnBjL2NsbnQuYw0KPiBpbmRleCA2ZTQzMmVjLi45NzUxN2ViIDEw
MDY0NA0KPiAtLS0gYS9uZXQvc3VucnBjL2NsbnQuYw0KPiArKysgYi9uZXQvc3VucnBjL2NsbnQu
Yw0KPiBAQCAtNjY4LDYgKzY2OCw3IEBAIHN0cnVjdCBycGNfY2xudCAqDQo+ICAJCS5wcm9nbnVt
YmVyCT0gY2xudC0+Y2xfcHJvZywNCj4gIAkJLnZlcnNpb24JPSBjbG50LT5jbF92ZXJzLA0KPiAg
CQkuYXV0aGZsYXZvcgk9IGZsYXZvciwNCj4gKwkJLnRpbWVvdXQJPSBjbG50LT5jbF90aW1lb3V0
LA0KPiAgCX07DQo+ICAJcmV0dXJuIF9fcnBjX2Nsb25lX2NsaWVudCgmYXJncywgY2xudCk7DQo+
ICB9DQoNCldoYXQgZG9lcyB0aGlzIHBhdGNoIGhhdmUgdG8gZG8gd2l0aCBwTkZTPyBUaGF0J3Mg
dGhlIGdlbmVyaWMgUlBDDQpjbGllbnQgY2xvbmluZyBBUEkgeW91IGFyZSBjaGFuZ2luZy4NCg0K
VGhlIHBORlMvZmlsZXMgdGltZW91dHMgYXJlIGludGVuZGVkIHRvIGJlIHNldCB1c2luZyB0aGUN
CmRhdGFzZXJ2ZXJfcmV0cmFucyBhbmQgZGF0YXNlcnZlcl90aW1lbyBtb2R1bGUgcGFyYW1ldGVy
cyBkZXNjcmliZWQgYXQNCnRoZSBib3R0b20gb2YgZnMvbmZzL2ZpbGVsYXlvdXQvZmlsZWxheW91
dGRldi5jDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWlu
ZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg==
