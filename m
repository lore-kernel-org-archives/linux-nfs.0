Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20774 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756909Ab2CIWwI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Mar 2012 17:52:08 -0500
Received: from vmwexceht02-prd.hq.netapp.com (vmwexceht02-prd.hq.netapp.com [10.106.76.240])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q29Mpu33019943
	for <linux-nfs@vger.kernel.org>; Fri, 9 Mar 2012 14:51:56 -0800 (PST)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Isaman, Fred" <Fred.Isaman@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFSv4.1 cleanup DS stateid error handling
Date: Fri, 9 Mar 2012 22:51:55 +0000
Message-ID: <1331333515.2763.63.camel@lade.trondhjem.org>
References: <1331222633-2645-1-git-send-email-andros@netapp.com>
	 <CADnza46qMiagwV39sJU7E4AKY0KMFyyHNTAis_+PO-0b8955Yg@mail.gmail.com>
In-Reply-To: <CADnza46qMiagwV39sJU7E4AKY0KMFyyHNTAis_+PO-0b8955Yg@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEyLTAzLTA5IGF0IDE0OjMxIC0wODAwLCBGcmVkIElzYW1hbiB3cm90ZToNCj4g
T24gVGh1LCBNYXIgOCwgMjAxMiBhdCA4OjAzIEFNLCAgPGFuZHJvc0BuZXRhcHAuY29tPiB3cm90
ZToNCj4gPiBGcm9tOiBBbmR5IEFkYW1zb24gPGFuZHJvc0BuZXRhcHAuY29tPg0KPiA+DQo+ID4g
VGhlIGVycm9yIGhhbmRsZXIgbmZzNF9zdGF0ZSBwYXJhbWV0ZXIgaXMgbmV2ZXIgTlVMTCBpbiB0
aGUgcE5GUyBjYXNlIGFzDQo+ID4gdGhlIG9wZW5fY29udGV4dCBtdXN0IGNhcnJ5IGFuIG5mc19z
dGF0ZS4NCj4gPg0KPiANCj4gDQo+IE5vdGUgVHJvbmQncyBhcmd1bWVudCBpcyB0aGF0IHdpdGgg
Y29tbWl0IHRoZSBzdGF0ZSBpcyBhdmFpbCBmb3IgdGhlDQo+IGNhbGxlciwgc28gaXQgbmVlZCBu
b3QgYmUgTlVMTC4NCj4gQnV0IHRoZSBjYWxsZXIgZmlsZWxheW91dF9jb21taXRfZG9uZV9jYigp
IG5lZWRzIHRvIGJlIGFkanVzdGVkLg0KPiBDdXJyZW50bHkgY29tbWl0IHRvIGRzIG9vcHNlcw0K
PiBkdWUgdG8gdGhhdC4NCg0KQXJlIHlvdSBzdXJlPyBBcyBmYXIgYXMgSSBjYW4gc2VlLCBmaWxl
bGF5b3V0X2NvbW1pdF9wYWdlbGlzdCBfZG9lc18NCmNhbGwgbmZzX2luaXRfY29tbWl0KCksIHdo
aWNoIGFnYWluIHNldHMgdGhlIGRhdGEtPmFyZ3MuY29udGV4dC4NCkxhdGVyLCBmaWxlbGF5b3V0
X2NvbW1pdF9kb25lX2NiIGNhbGxzIGZpbGVsYXlvdXRfYXN5bmNfaGFuZGxlX2Vycm9yKCkNCnVz
aW5nIHRoZSBkYXRhLT5hcmdzLmNvbnRleHQtPnN0YXRlIGFyZ3VtZW50Lg0KDQpIb3cgaXMgdGhh
dCBmYWlsaW5nIHRvIHByb3ZpZGUgYSB2YWxpZCBvcGVuIHN0YXRlIGFyZ3VtZW50Pw0KDQotLSAN
ClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0K
VHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQoNCg==
