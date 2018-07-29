Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr700122.outbound.protection.outlook.com ([40.107.70.122]:37600
        "EHLO NAM04-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728528AbeG3Ay7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 29 Jul 2018 20:54:59 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "Suresh.Jayaraman@wdc.com" <Suresh.Jayaraman@wdc.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "Aditya.Agnihotri@wdc.com" <Aditya.Agnihotri@wdc.com>
Subject: Re: pNFS, multiple paths to Data Server not used by pNFS linux
 client.
Date: Sun, 29 Jul 2018 23:22:42 +0000
Message-ID: <e8093d124a34f08ec4c1053df14ba760c4b57efb.camel@hammerspace.com>
References: <SN6PR04MB4909ED311126ACD9341E339E82520@SN6PR04MB4909.namprd04.prod.outlook.com>
         <BYAPR04MB4757AB8C13E8FA228B679D4083550@BYAPR04MB4757.namprd04.prod.outlook.com>
In-Reply-To: <BYAPR04MB4757AB8C13E8FA228B679D4083550@BYAPR04MB4757.namprd04.prod.outlook.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

SGkgU3VyZXNoLA0KDQpPbiBUdWUsIDIwMTgtMDctMjQgYXQgMDk6NTggKzAwMDAsIFN1cmVzaCBK
YXlhcmFtYW4gd3JvdGU6DQo+IEhpIFRyb25kIGV0IGFsLA0KPiANCj4gT24gMDcvMTkvMjAxOCAx
MjozOSBQTSwgQWRpdHlhIEFnbmlob3RyaSB3cm90ZToNCj4gPiANCj4gPiBXZSBhcmUgdGVzdGlu
ZyBvdXIgcE5GUyBzZXJ2ZXIgd2l0aCBsaW51eCBjbGllbnQsIHdoZW4gdGhlIHNlcnZlcg0KPiA+
IHJldHVybnMgbXVsdGlwbGUgcGF0aHMgdG8gYSB2NCBEUyB2aWEgR0VUREVWSU5GTywgd2Ugc2Vl
IHRoYXQgdGhlDQo+ID4gY2xpZW50IHZhbGlkYXRlZCB0aGUgcGF0aHMgKGRvZXMgZXhjaGFuZ2Ug
aWQpIGJ1dCBkb2VzIG5vdCB1c2UgdGhlDQo+ID4gYWx0ZXJuYXRlIHBhdGhzIGluIElPLg0KPiA+
IFRyYWNpbmcgdGhlIGNvZGUgcGF0aCwgaXQgc2VlbXMgdGhhdCB3aGVuIERTIGlzIGEgTkZTIHYz
IHNlcnZlciwNCj4gPiBwYXRoIGlzIGFkZGVkLCBidXQgZm9yIE5GUyB2NCBEUyBzZXJ2ZXIsIGNs
aWVudCBzZXR1cCBmdW5jdGlvbg0KPiA+IGNhbGxiYWNrIHBhdGggZmFpbHMgdG8gYWRkLg0KPiAN
Cj4gSXMgdGhpcyBvYnNlcnZhdGlvbiB0aGF0IHJwY19jbG50X3NldHVwX3Rlc3RfYW5kX2FkZF94
cHJ0KCkgZG9lc24ndA0KPiBjYWxsDQo+IHJwY194cHJ0X3N3aXRjaF9hZGRfeHBydCgpIG5laXRo
ZXIgaW4gdGhlIHRlc3QgZnVuY3Rpb24gbm9yIGxldA0KPiBycGNfY2xudF9hZGRfeHBydCgpIGFk
ZCB0aGUgeHBydCBjb3JyZWN0PyBUaGlzIHNlZW1zIHRvIGJlIGxpbWl0aW5nDQo+IExpbnV4IHBO
RlMgY2xpZW50IGZyb20gdXNpbmcgbXVsdGlwbGUgcGF0aHMgd2l0aCBUZWdpbGUvV0QgcE5GUw0K
PiBzZXJ2ZXIuDQo+IA0KPiBJZiB5ZXMsIHdvdWxkIHlvdSBsaWtlIGEgcGF0Y2ggdGhhdCBhdHRl
bXB0cyB0byBmaXggdGhpcz8NCj4gDQoNCkkgYmVsaWV2ZSB0aGF0IHRoZSBvbmx5IHJlYXNvbiB3
aHkgdGhlIE5GU3Y0IERTIHNlcnZlciBjb2RlIHdhcyBuZXZlcg0KY2hhbmdlZCBpcyB0aGF0IGl0
IHdvdWxkIG5lZWQgdG8gYmUgdGVzdGVkLCBhbmQgbm9uZSBvZiB1cyBoYXMgc3VjaCBhDQpzZXR1
cCB0byB0ZXN0IHdpdGguDQoNClNvIHllcywgaWYgeW91J3JlIGFibGUgdG8gdGVzdCBvdXQgdGhh
dCBzZXR1cCBhbmQgYXJlIHNlZWluZyBhIGJ1ZywNCnRoZW4gd2UncmUgaGFwcHkgdG8gdGFrZSBh
IGZpeC4NCg0KQ2hlZXJzDQogIFRyb25kDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZT
IGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNw
YWNlLmNvbQ0KDQoNCg==
