Return-Path: <SRS0=QgGt=SL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DD04C10F0E
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 14:44:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 293F42084F
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 14:44:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=spinetix.com header.i=@spinetix.com header.b="WM2vfxkA"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726588AbfDIOos (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 10:44:48 -0400
Received: from mail-eopbgr60089.outbound.protection.outlook.com ([40.107.6.89]:42501
        "EHLO EUR04-DB3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726492AbfDIOos (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 Apr 2019 10:44:48 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=spinetix.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=jEyuwqYqaofjG8idSB2pvuUGBB6aqVZG6Ey77ls59L0=;
 b=WM2vfxkAqQY9J0qhttgCWAGA6TJyJciHLKgIL9+aex4ytPj7A4TFXAja/lmYNZd0rk0U6UD6CEe2CeM+4tTMKbaqsdaGG21+TLnM/f/46uMPdk9j4zsVlUO65PE66yHjdDzEqed2p0xP23bkGKvE7f8tN/g4FfJfm3uPKrkNu3Q=
Received: from VI1PR01MB5167.eurprd01.prod.exchangelabs.com (20.178.120.225)
 by VI1PR01MB5005.eurprd01.prod.exchangelabs.com (20.177.203.81) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.1771.21; Tue, 9 Apr
 2019 14:44:43 +0000
Received: from VI1PR01MB5167.eurprd01.prod.exchangelabs.com
 ([fe80::d15f:49aa:fe02:511c]) by VI1PR01MB5167.eurprd01.prod.exchangelabs.com
 ([fe80::d15f:49aa:fe02:511c%4]) with mapi id 15.20.1771.021; Tue, 9 Apr 2019
 14:44:43 +0000
From:   Diego Santa Cruz <Diego.SantaCruz@spinetix.com>
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: Write access check not correct on world writable directories
 (regression)
Thread-Topic: Write access check not correct on world writable directories
 (regression)
Thread-Index: AdTurF3PJLe1IvUXS+qxCgYbn/IAGgAJub4AAAAKcsA=
Date:   Tue, 9 Apr 2019 14:44:42 +0000
Message-ID: <VI1PR01MB516743EF0FE8748973D3CA77882D0@VI1PR01MB5167.eurprd01.prod.exchangelabs.com>
References: <VI1PR01MB5167A74BA4409EE4C27B592F882D0@VI1PR01MB5167.eurprd01.prod.exchangelabs.com>
 <1aea7647abe49e21b64630ba123559fe0eb774c4.camel@hammerspace.com>
In-Reply-To: <1aea7647abe49e21b64630ba123559fe0eb774c4.camel@hammerspace.com>
Accept-Language: en-GB, fr-CH, fr-FR, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Diego.SantaCruz@spinetix.com; 
x-originating-ip: [46.14.255.78]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 7c66c4f5-64cd-4781-ea65-08d6bcf9e726
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(7021145)(8989299)(4534185)(7022145)(4603075)(4627221)(201702281549075)(8990200)(7048125)(7024125)(7027125)(7023125)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:VI1PR01MB5005;
x-ms-traffictypediagnostic: VI1PR01MB5005:
x-microsoft-antispam-prvs: <VI1PR01MB50057D3DCC43A236A15D1004882D0@VI1PR01MB5005.eurprd01.prod.exchangelabs.com>
x-forefront-prvs: 000227DA0C
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(346002)(136003)(39840400004)(366004)(376002)(396003)(13464003)(189003)(199004)(6506007)(71190400001)(71200400001)(81166006)(72206003)(229853002)(110136005)(4326008)(53546011)(55016002)(81156014)(5660300002)(8676002)(2501003)(8936002)(9686003)(7736002)(52536014)(25786009)(3846002)(6116002)(508600001)(316002)(86362001)(105586002)(305945005)(97736004)(68736007)(256004)(74316002)(6436002)(106356001)(486006)(76176011)(6246003)(186003)(446003)(476003)(99286004)(26005)(11346002)(14444005)(2906002)(7696005)(14454004)(53936002)(33656002)(66066001)(102836004)(5024004);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR01MB5005;H:VI1PR01MB5167.eurprd01.prod.exchangelabs.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: spinetix.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: y5JZf7mLaOOlK/4NtD2rtWT595mSvbJ6C24ln7xj2DUtN54z+cMTsZQHp2ThiN+j8t4uPtHBlL7mp3k8svxZB0h7EPXEHE4v9BKYklA/GrNsIpAHGmCcLKwBTDc+im3ZMBUW9SWBzZTuClBcfNEGcpAxNFpYS1exZB/TqWL7aXgTSxJnJSWkiF4iyppTfpB/LUl1IxTH0kdOrrpoWz5g3paJEOHHmbeF6rPlGOpznNqEiGPEJZWbRYbCz0IccNdumkh4NBFW+eTznnyY7/FY1+kObdGIyRSuxrQd1zQCdHZfPdoq29gGPk6REaYoz2+BI9oEheP90qaCdvZD3BwaxpYXnEV5VcTebbS1DE3Tu53kmaM1GNzX3PT/qFI4usqRqPRqe42Y0/rhKns0Q7Qe/v54GoPWuEXWsySTfAx0ErE=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: spinetix.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7c66c4f5-64cd-4781-ea65-08d6bcf9e726
X-MS-Exchange-CrossTenant-originalarrivaltime: 09 Apr 2019 14:44:42.9378
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 5f4034fa-ed2d-4840-a93f-acb1e9633b93
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR01MB5005
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBUcm9uZCBNeWtsZWJ1c3QgPHRy
b25kbXlAaGFtbWVyc3BhY2UuY29tPg0KPiBTZW50OiAwOSBBcHJpbCAyMDE5IDE0OjU0DQo+IFRv
OiBhbm5hLnNjaHVtYWtlckBuZXRhcHAuY29tOyBEaWVnbyBTYW50YSBDcnV6DQo+IDxEaWVnby5T
YW50YUNydXpAc3BpbmV0aXguY29tPg0KPiBDYzogbGludXgtbmZzQHZnZXIua2VybmVsLm9yZw0K
PiBTdWJqZWN0OiBSZTogV3JpdGUgYWNjZXNzIGNoZWNrIG5vdCBjb3JyZWN0IG9uIHdvcmxkIHdy
aXRhYmxlIGRpcmVjdG9yaWVzDQo+IChyZWdyZXNzaW9uKQ0KPiANCj4gT24gVHVlLCAyMDE5LTA0
LTA5IGF0IDA5OjI2ICswMDAwLCBEaWVnbyBTYW50YSBDcnV6IHdyb3RlOg0KPiA+IEhlbGxvLA0K
PiA+DQo+ID4gSSBoYXZlIGVuY291bnRlcmVkIGEgcHJvYmxlbSB3aXRoIGFjY2VzcyhkaXIsIFdf
T0spIGNhbGxzIGFuZCB3b3JsZA0KPiA+IHdyaXRhYmxlIGRpcmVjdG9yaWVzIG9uIE5GUyB3aGlj
aCBhcmUgbm90IG93bmVyIGJ5IHRoZSBjYWxsaW5nIHVzZXIuDQo+ID4gVGhlIGNhbGwgcmV0dXJu
cyBFQUNDRVMsIGV2ZW4gdGhvdWdoIHRoZSB1c2VyIGNhbiBjcmVhdGUgZmlsZXMgaW4gdGhlDQo+
ID4gZGlyZWN0b3J5LiBJIHVzZSBORlN2MywgYnV0IHRoaXMgbWF5IGFsc28gaW1wYWN0IG90aGVy
IE5GUyB2ZXJzaW9ucy4NCj4gPg0KPiA+IFRlc3QgY2FzZSwgb24gYW4gTkZTdjMgbW91bnRlZCBk
aXJlY3RvcnkgaXM6DQo+ID4gMS4gQ3JlYXRlIHdvcmxkIHdyaXRhYmxlIGRpcmVjdG9yeSBhcyBy
b290OiBzdWRvIG1rZGlyIC1tIDc3NyB0ZXN0ZGlyDQo+ID4gMi4gVGVzdCB0aGF0IG5vcm1hbCB1
c2VyIGNhbiBjcmVhdGUgYSBmaWxlOiBybSAtZiB0ZXN0ZGlyL2ZvbyAmJg0KPiA+IHRvdWNoIHRl
c3RkaXIvZm9vDQo+ID4gMy4gVGVzdCBmb3Igd3JpdGFiaWxpdHkgd2l0aCBhY2Nlc3M6IHN0cmFj
ZSAtbyBsb2cgdGVzdCAtdyB0ZXN0ZGlyICYmDQo+ID4gZWNobyBQQVNTIHx8IGVjaG8gRkFJTA0K
PiA+IDQuIENoZWNraW5nIHRoZSBzdHJhY2UgbG9nIHNob3dzIHRoYXQgYWNjZXNzKCJ0ZXN0ZGly
IiwgV19PSykgZmFpbHMNCj4gPiB3aXRoIEVBQ0NFUw0KPiA+DQo+ID4gSSBhbSB1c2luZyB0aGUg
bGludXgtaW50ZWwga2VybmVsIDQuMTkuMTMsIGJ1dCBJIHRyYWNlZCB0aGlzIHRvDQo+ID4gY29t
bWl0IGVjYmI5MDNjNTY3NDUgaW4gbGludXggbWFzdGVyIChORlM6IEJlIG1vcmUgY2FyZWZ1bCBh
Ym91dA0KPiA+IG1hcHBpbmcgZmlsZSBwZXJtaXNzaW9ucyksIHRoYXQgd2VudCBpbnRvIGtlcm5l
bCA0LjEzLiBUaGUgdGVzdCB3b3Jrcw0KPiA+IGZpbmUgaW4gZWFybGllciBrZXJuZWxzLiBUaGUg
cHJvYmxlbSBkb2VzIG5vdCBhbHdheXMgc2hvdyB1cCBvbg0KPiA+IGRpcmVjdG9yaWVzIG93bmVk
IGJ5IHRoZSBjYWxsaW5nIHVzZXIsIGJ1dCBpdCBtYXkgYmUgZHVlIHRvIGF0dHJpYnV0ZQ0KPiA+
IGNhY2hpbmcgb3Igc2ltaWxhci4NCj4gPg0KPiA+IEkgYW0gbm90IHZlcnkgTkZTIHNhdnZ5IGJ1
dCBhcyBmYXIgYXMgSSB1bmRlcnN0YW5kIHRoZSBjb21taXQgYWJvdmUNCj4gPiBjaGFuZ2VkIHRo
ZSB0ZXN0cyBpbiBuZnNfYWNjZXNzX2NhbGNfbWFzaygpIGZyb20gImFueSBiaXQgaW4gbWFzayBp
cw0KPiA+IHNldCIgdG8gImFsbCBiaXRzIGluIG1hc2sgYXJlIHNldCIuIFRoZSBtYXNrIGZvciB3
cml0YWJsZSBkaXJlY3Rvcmllcw0KPiA+IGlzIEFDQ0VTU19NT0RJRlksIEFDQ0VTU19FWFRFTkQs
IEFDQ0VTU19ERUxFVEUgYnV0IGZyb20gd2hhdCBJIHNlZSBpbg0KPiA+IGEgbmV0d29yayBjYXB0
dXJlIHRoZSByZXNwb25zZSBmcm9tIHRoZSBORlMgc2VydmVyIGlzIGxhY2tpbmcgdGhlDQo+ID4g
QUNDRVNTX0RFTEVURSBiaXQuDQo+ID4NCj4gPiBUaGUgYXR0YWNoZWQgcGF0Y2ggcmV2ZXJ0cyB0
aGUgdGVzdHMgaW4gbmZzX2FjY2Vzc19jYWxjX21hc2soKSB0bw0KPiA+ICJhbnkgYml0IGluIG1h
c2sgaXMgc2V0Iiwgd2hpY2ggbWFrZXMgdGhlIHRlc3QgY2FzZSB3b3JrIGFnYWluLCBidXQgSQ0K
PiA+IGFtIG5vdCBzdXJlIGl0IGlzIGVudGlyZWx5IGNvcnJlY3QgdG8gY2hhbmdlIGFsbCB0aGUg
dGVzdHMsIG9yIGlmIGl0DQo+ID4gd291bGQgYmUgbW9yZSBhcHByb3ByaWF0ZSB0byBkcm9wIEFD
Q0VTU19ERUxFVEUgZnJvbSB0aGUNCj4gPiBORlNfRElSX01BWV9XUklURSBtYXNrLiBUaGUgcGF0
Y2ggYXBwbGllcyBjbGVhbmx5IG9uIGN1cnJlbnQgbGludXgNCj4gPiBtYXN0ZXIuDQo+ID4NCj4g
PiBJIGNoZWNrZWQgdGhlIE5GU3YzIGFuZCBORlN2NCBSRkNzLCBidXQgaXQgaXMgbm90IGNsZWFy
IHRvIG1lIGlmDQo+ID4gQUNDRVNTX0RFTEVURSBpcyBmb3IgdGhlIGRpcmVjdG9yeSBpdHNlbGYg
b3IgaXRzIGNoaWxkcmVuLiBJbiBhbnkNCj4gPiBjYXNlIG15IE5GUyBzZXJ2ZXIgaXMgb21pdHRp
bmcgQUNDRVNTX0RFTEVURSBmcm9tIHRoZSByZXNwb25zZSAoaXQgaXMNCj4gPiBhIFN5bm9sb2d5
IHJ1bm5pbmcgTGludXgga2VybmVsIDMuMTAuMTA1KS4NCj4gPg0KPiANCj4gVGhlIEFDQ0VTU19E
RUxFVEUgYml0IGFwcGxpZXMgX29ubHlfIHRvIGRpcmVjdG9yaWVzLCBzbyBpZiBpdCBpcw0KPiBt
aXNzaW5nIGluIHRoZSByZXBseSBmcm9tIHlvdXIgc2VydmVyIGZvciBhIGRpcmVjdG9yeSB3aXRo
IFBPU0lYIDc3Nw0KPiBwZXJtaXNzaW9ucywgdGhlbiB5b3Ugc2hvdWxkIHRhbGsgdG8gdGhlIHNl
cnZlciB2ZW5kb3IuDQo+IA0KPiBBcyBmYXIgYXMgSSBjYW4gc2VlLCB0aGUgY3VycmVudCBjb2Rl
IGlzIGNvcnJlY3QuIElmIHlvdSBkbyBub3QgaGF2ZQ0KPiB0aGUgQUNDRVNTX0RFTEVURSBiaXQg
c2V0IG9uIHlvdXIgZGlyZWN0b3J5LCB0aGVuIHRoZSBzZXJ2ZXIgaXMgdGVsbGluZw0KPiB0aGUg
Y2xpZW50IHRoYXQgeW91ciBwcm9jZXNzIGRvZXMgbm90IGhhdmUgZnVsbCB3cml0ZSBwZXJtaXNz
aW9ucyB0bw0KPiB0aGF0IGRpcmVjdG9yeSBpbiBhY2NvcmRhbmNlIHdpdGggdGhlIFBPU0lYIHNw
ZWMuDQo+IA0KDQpTb3JyeSBmb3IgdGhlIG5vaXNlLiBJbmRlZWQgaXQgYXBwZWFycyB0aGF0IHRo
ZSBiZWhhdmlvciBpcyBzcGVjaWZpYyB0byBteSBORlMgdmVuZG9yLCBJIHdyb25nbHkgYXNzdW1l
ZCB0aGF0IGJlaW5nIGEgTGludXgga2VybmVsIHRoZXkgZGlkIG5vdCB0d2VhayB0aGlzIGtpbmQg
b2Ygc3R1ZmYgaW4gdGhlIE5GUyBzZXJ2ZXIuLi4gSSByZXBlYXRlZCB0aGUgdGVzdCB3aXRoIENl
bnRPUyA3IGFuZCBDZW50T1MgNSBzZXJ2ZXJzIGFuZCB0aGV5IGJlaGF2ZSBjb3JyZWN0bHksIHRo
ZSBBQ0NFU1NfREVMRVRFIGlzIGFwcGFyZW50bHkgc2V0IGJhc2VkIG9uIHRoZSBkaXJlY3Rvcnkg
YmVpbmcgd3JpdGFibGUgYnkgdGhlIGNhbGxlciBJRCBhdCB0aGUgc2VydmVyLg0KDQpCdXQgaXQg
cmVtYWlucyB0aGF0IHRoZSBjb21taXQgZG9lcyBicmVhayBjb21wYXRpYmlsaXR5IHdpdGggZXhp
c3RpbmcgcHJvZHVjdHMgKGFuZCBmYWlybHkgcG9wdWxhciBJIGJlbGlldmUpLiBJJ2xsIHJlcG9y
dCB0aGUgaXNzdWUgdG8gdGhlIE5GUyB2ZW5kb3IsIGJ1dCBpdCBpcyBhbHdheXMgcHJvYmxlbWF0
aWMgd2hlbiBjb21wYXRpYmlsaXR5IGJyZWFrcyBsaWtlIHRoaXMsIGl0IG1heSB0YWtlIGEgbG9u
ZyB0aW1lIHRvIGNvbnZpbmNlIHRoZSB2ZW5kb3IgdGhhdCB0aGVyZSBpcyBhIGJ1ZyBvbiB0aGVp
ciBzaWRlLg0KDQpGb3IgY29tcGxldGVuZXNzLCBJIHRoaW5rIG15IGluaXRpYWwgdW5kZXJzdGFu
ZGluZyBhbmQgZGVzY3JpcHRpb24gd2FzIG5vdCBlbnRpcmVseSBjb3JyZWN0LCBhcyBpdCBpcyBu
b3QgcmVhbGx5IHRoZSBmYWN0IHRoYXQgdGhlIGRpcmVjdG9yeSBpcyB3b3JsZCByZWFkYWJsZSB0
aGF0IGlzIGEgcHJvYmxlbSwgYnV0IHRoYXQgdGhlIGNhbGxlciBJRCBoYXMgbm8gd3JpdGUgcGVy
bWlzc2lvbnMgdG8gdGhlIHBhcmVudCBkaXJlY3RvcnkuIEluIHRoYXQgY2FzZSB0aGUgZGlyZWN0
b3J5IGNhbm5vdCBiZSByZW1vdmVkIGJ5IHRoZSBjYWxsZXIgYmVjYXVzZSBoZSBoYXMgbm8gd3Jp
dGUgcGVybWlzc2lvbnMgdG8gdGhlIHBhcmVudC4gVGhlIHRlc3QgY2FzZSB3b3VsZCB0aHVzIGJl
IHRoZSBmb2xsb3dpbmcNCg0KIyBDaGFuZ2UgZGlyZWN0b3J5IHRvIGEgTkZTIG1vdW50DQojIENy
ZWF0ZSBwYXJlbnQgZGlyZWN0b3J5IGFzIHJvb3QNCnN1ZG8gbWtkaXIgLW0gNzU1IHBhcmVudGRp
cg0KIyBDcmVhdGUgYSB3b3JsZCByZWFkYWJsZSBjaGlsZCBkaXJlY3RvcnkNCnN1ZG8gbWtkaXIg
LW0gNzc3IHBhcmVudGRpci9jaGlsZGRpcg0KIyBUZXN0IHRoYXQgbm9ybWFsIHVzZXIgY2FuIGNy
ZWF0ZSBhIGZpbGUNCnJtIC1mIHBhcmVudGRpci9jaGlsZGRpci9mb28gJiYgdG91Y2ggcGFyZW50
ZGlyL2NoaWxkZGlyL2Zvbw0KIyBUZXN0IGZvciB3cml0YWJpbGl0eSB3aXRoIGFjY2Vzcw0Kc3Ry
YWNlICAtbyBwYXJlbnRkaXIvY2hpbGRkaXIvbG9nIHRlc3QgLXcgcGFyZW50ZGlyL2NoaWxkZGly
IFwNCiYmIGVjaG8gU1VDQ0VTUyB8fCBlY2hvIEZBSUwNCiMgSW4gdGhlIHN0cmFjZSBsb2cNCiMg
YWNjZXNzKCJwYXJlbnRkaXIvY2hpbGRkaXIiLCBXX09LKSAgICAgID0gLTEgRUFDQ0VTIChQZXJt
aXNzaW9uIGRlbmllZCkNCg0KQXMgZmFyIGFzIEkgdW5kZXJzdGFuZCwgdGhlIHByb2JsZW1hdGlj
IE5GUyBzZXJ2ZXIgc2V0cyBBQ0NFU1NfREVMRVRFIGlmIHRoZSBkaXJlY3RvcnkgZW50cnkgaXRz
ZWxmIGNhbiBiZSByZW1vdmVkLCBub3QgaWYgZW50cmllcyB3aXRoaW4gdGhlIGRpcmVjdG9yeSBj
YW4gYmUgcmVtb3ZlZCAocmVwZWF0aW5nIHRoZSB0ZXN0IHdpdGggcGVyZW50ZGlyIGhhdmluZyBt
b2RlIDc3NyBzdWNjZWVkcyBhbmQgdGhlIG5ldHdvcmsgY2FwdHVyZSBzaG93cyB0aGF0IEFDQ0VT
U19ERUxFVEUgaXMgcHJlc2VudCBpbiB0aGUgQUNDRVNTIHJlc3BvbnNlKS4NCg0KQmVzdCwNCg0K
RGllZ28NCg0KPiBDaGVlcnMNCj4gICBUcm9uZA0KPiAtLQ0KPiBUcm9uZCBNeWtsZWJ1c3QNCj4g
TGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KPiB0cm9uZC5teWtsZWJ1
c3RAaGFtbWVyc3BhY2UuY29tDQo+IA0KDQo=
