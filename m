Return-Path: <SRS0=v8AN=PI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AEAEC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 31 Dec 2018 19:18:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 272352081B
	for <linux-nfs@archiver.kernel.org>; Mon, 31 Dec 2018 19:18:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="qmg0nlG8"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727714AbeLaTSu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 31 Dec 2018 14:18:50 -0500
Received: from mail-eopbgr790105.outbound.protection.outlook.com ([40.107.79.105]:27252
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726903AbeLaTSu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 31 Dec 2018 14:18:50 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=GrMpr1IIv6gGLe7kLEFz7V+HuAFh6QHPFmNUKbS5ByY=;
 b=qmg0nlG83fACdNmJNSZKFPYeMPA0uRmv5Dks5h0i5ahOnnO3fnmmmix8kzi7bm4L7DkGB2w9Rclv2oz7p1KXYQOgwast+kj5VLH3SX9Hx3WGDnoaWmU7M+IGxpxMQlZAK5Dll9bumpk59/wDKbhKY4u633Hc53sQH4C557qtpRs=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2366.namprd13.prod.outlook.com (52.135.94.146) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1495.5; Mon, 31 Dec 2018 19:18:46 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%3]) with mapi id 15.20.1495.005; Mon, 31 Dec 2018
 19:18:46 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 26/44] SUNRPC: Improve latency for interactive tasks
Thread-Topic: [PATCH v3 26/44] SUNRPC: Improve latency for interactive tasks
Thread-Index: AQHUTob5qK09WaTXZkeMo/gY+CHqD6WTldAAgAAwIgCAAAW4AIAF/x2AgAAJ4YCAAAQ7gIAAAqsAgAACmQA=
Date:   Mon, 31 Dec 2018 19:18:45 +0000
Message-ID: <c4bd04d525a1355e3dfff054985d697f0f391816.camel@hammerspace.com>
In-Reply-To: <FEAFD5B3-7E93-4545-A364-DE453852B76C@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2366;6:C/X7c5EOgmBO+mCImEeIVfSNeefgL0X13xxkss2XHZSfKJDRz4/9U73yKbFMKAP23fKOYDGPyGxQmBByD9efYo5fqQWStDP7Cl1xnI9nMePcey527k76XVHfmHm/2+0LGWuuEAppwuY0srTy51Iu95qy/WOoswvapYjJHhqqm43e2e2alvygGSBPb5Qvt2Y3Fc6QhVswdH8b05Cx1DH6PnCefxKJ4m6sE2/GSdnF9dFa64xEDoWfwNhSWTx1uPqGCzVHYVTY6jQ1ABNI+QSt32AXxHIvVjt6QMgeD0wvOjdEsJXraEPr4WyJB73a/T10GLJHw/yuBPnIX9zDmGIAZ3g9G4N/2QrV9Iz525m5a1bKwAyMRj8EtZodxhIy554cyr86YW3v/1ZXv2PG6irWPIcAMiAtPrEVvPQrP0/+KKr1/DcrW/PA7GsSy/zpjWlOp0DBx5jZfTRUeFiT3pJr7g==;5:uFVaG8VMczNnCsS4vTkC+8QQiX6/C08qhPUA34scEnziBasl8lW02/jB3rNQrLzXVKlXuDlvFHA1x8xWeKO011XAuldImetpenerqCv8Q+HIH+SYLKF+flwuyY4bY9KoHg1ebTltlljVyKW8ViT5nZpahOBtPINFKzwoSrBBMB4sr3nmnfJWaZ/G6PHZQ4ZBQyShV2pLM5sSHHZ8KOobZQ==;7:GeH3YTbgdXRDaefCG8gjLfaD7O/TdBWuAlSyYCgzB6AOjU9HhZKz57rSXsS8Gg7BD1cRSWohfwbSFqwrManKV5ThuI9qqr+fTIneFGE+EfyGQUQYhifMsRHkh/e5IOAfAhIrANA9D3NVwgpPPQI08Q==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 424d27b3-f6e7-4110-ca20-08d66f54c90a
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2366;
x-ms-traffictypediagnostic: SN6PR13MB2366:
x-microsoft-antispam-prvs: <SN6PR13MB2366247AD02357B13FC92BE9B8B20@SN6PR13MB2366.namprd13.prod.outlook.com>
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(908002)(999002)(5005026)(6040522)(8220055)(2401047)(8121501046)(10201501046)(3002001)(93006095)(93001095)(3231475)(944501520)(52105112)(6041310)(20161123564045)(20161123558120)(20161123562045)(20161123560045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2366;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2366;
x-forefront-prvs: 0903DD1D85
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(366004)(346002)(376002)(136003)(39830400003)(189003)(199004)(4326008)(25786009)(305945005)(68736007)(7736002)(5660300001)(3846002)(6116002)(6512007)(53936002)(118296001)(6246003)(8936002)(81166006)(81156014)(8676002)(6916009)(71200400001)(71190400001)(105586002)(86362001)(5640700003)(486006)(256004)(14444005)(2906002)(106356001)(2351001)(4001150100001)(6436002)(97736004)(316002)(6506007)(53546011)(6486002)(14454004)(2501003)(229853002)(478600001)(36756003)(476003)(2616005)(6346003)(186003)(26005)(99286004)(102836004)(11346002)(66066001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2366;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 3uGYklZ14/8xYMheB+AwAmyYsi4+51G5A6qCEqJDGwsSRjCTqupL+3A395vzaUOhEH7PeTE35k3e6+acWQHYc3ffG5SO4cRYcI6UCer2ezMX8dxijUUAqvB5qNNXZziFRK80uksLuRG7p6O9MvZgJELV6p/FF/rBUfVnvyx2Mo3dm0XLTT/KkuEkNMlTCztQMjHN4j/uPhR72OvYQWwCPPkV9wEROxKBqR52NtgzRKyIrj/R5uU6KpM05xBAdRL7M45mN3+vzm0dBXX1froey7OoJpsMCAXfiqm2+WOUyZ1ryYuA7hEh/i7BApqfmziq
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <5753470F332E4B4C927F334BD1C5F972@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 424d27b3-f6e7-4110-ca20-08d66f54c90a
X-MS-Exchange-CrossTenant-originalarrivaltime: 31 Dec 2018 19:18:45.9429
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2366
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE4LTEyLTMxIGF0IDE0OjA5IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBEZWMgMzEsIDIwMTgsIGF0IDE6NTkgUE0sIFRyb25kIE15a2xlYnVzdCA8DQo+ID4gdHJv
bmRteUBoYW1tZXJzcGFjZS5jb20+IHdyb3RlOg0KPiA+IA0KPiA+IE9uIE1vbiwgMjAxOC0xMi0z
MSBhdCAxMzo0NCAtMDUwMCwgQ2h1Y2sgTGV2ZXIgd3JvdGU6DQo+ID4gPiA+IE9uIERlYyAzMSwg
MjAxOCwgYXQgMTowOSBQTSwgVHJvbmQgTXlrbGVidXN0IDwNCj4gPiA+ID4gdHJvbmRteUBoYW1t
ZXJzcGFjZS5jb20+IHdyb3RlOg0KPiA+ID4gPiANCj4gPiA+ID4gT24gVGh1LCAyMDE4LTEyLTI3
IGF0IDE3OjM0IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4gPiA+ID4gPiA+IE9uIERlYyAy
NywgMjAxOCwgYXQgNToxNCBQTSwgVHJvbmQgTXlrbGVidXN0IDwNCj4gPiA+ID4gPiA+IHRyb25k
bXlAaGFtbWVyc3BhY2UuY29tPiB3cm90ZToNCj4gPiA+ID4gPiA+IA0KPiA+ID4gPiA+ID4gDQo+
ID4gPiA+ID4gPiANCj4gPiA+ID4gPiA+ID4gT24gRGVjIDI3LCAyMDE4LCBhdCAyMDoyMSwgQ2h1
Y2sgTGV2ZXIgPA0KPiA+ID4gPiA+ID4gPiBjaHVjay5sZXZlckBvcmFjbGUuY29tPg0KPiA+ID4g
PiA+ID4gPiB3cm90ZToNCj4gPiA+ID4gPiA+ID4gDQo+ID4gPiA+ID4gPiA+IEhpIFRyb25kLQ0K
PiA+ID4gPiA+ID4gPiANCj4gPiA+ID4gPiA+ID4gSSd2ZSBjaGFzZWQgZG93biBhIGNvdXBsZSBv
ZiByZW1haW5pbmcgcmVncmVzc2lvbnMgd2l0aA0KPiA+ID4gPiA+ID4gPiB0aGUNCj4gPiA+ID4g
PiA+ID4gdjQuMjANCj4gPiA+ID4gPiA+ID4gTkZTIGNsaWVudCwNCj4gPiA+ID4gPiA+ID4gYW5k
IHRoZXkgc2VlbSB0byBiZSByb290ZWQgaW4gdGhpcyBjb21taXQuDQo+ID4gPiA+ID4gPiA+IA0K
PiA+ID4gPiA+ID4gPiBXaGVuIHVzaW5nIHNlYz1rcmI1LCBrcmI1aSwgb3Iga3JiNXAgSSBmb3Vu
ZCB0aGF0IG11bHRpLQ0KPiA+ID4gPiA+ID4gPiB0aHJlYWRlZA0KPiA+ID4gPiA+ID4gPiB3b3Jr
bG9hZHMNCj4gPiA+ID4gPiA+ID4gdHJpZ2dlciBhIGxvdCBvZiBzZXJ2ZXItc2lkZSBkaXNjb25u
ZWN0cy4gVGhpcyBpcyB3aXRoDQo+ID4gPiA+ID4gPiA+IFRDUA0KPiA+ID4gPiA+ID4gPiBhbmQN
Cj4gPiA+ID4gPiA+ID4gUkRNQSB0cmFuc3BvcnRzLg0KPiA+ID4gPiA+ID4gPiBBbiBpbnN0cnVt
ZW50ZWQgc2VydmVyIHNob3dzIHRoYXQgdGhlIGNsaWVudCBpcyB1bmRlci0NCj4gPiA+ID4gPiA+
ID4gcnVubmluZyANCj4gPiA+ID4gPiA+ID4gdGhlDQo+ID4gPiA+ID4gPiA+IEdTUyBzZXF1ZW5j
ZQ0KPiA+ID4gPiA+ID4gPiBudW1iZXIgd2luZG93LiBJIG1vbml0b3JlZCB0aGUgb3JkZXIgaW4g
d2hpY2ggR1NTDQo+ID4gPiA+ID4gPiA+IHNlcXVlbmNlDQo+ID4gPiA+ID4gPiA+IG51bWJlcnMg
YXBwZWFyIG9uDQo+ID4gPiA+ID4gPiA+IHRoZSB3aXJlLCBhbmQgYWZ0ZXIgdGhpcyBjb21taXQs
IHRoZSBzZXF1ZW5jZSBudW1iZXJzIGFyZQ0KPiA+ID4gPiA+ID4gPiB3aWxkbHkNCj4gPiA+ID4g
PiA+ID4gbWlzb3JkZXJlZC4NCj4gPiA+ID4gPiA+ID4gSWYgSSByZXZlcnQgdGhlIGh1bmsgaW4g
eHBydF9yZXF1ZXN0X2VucXVldWVfdHJhbnNtaXQsDQo+ID4gPiA+ID4gPiA+IHRoZQ0KPiA+ID4g
PiA+ID4gPiBwcm9ibGVtIGdvZXMgYXdheS4NCj4gPiA+ID4gPiA+ID4gDQo+ID4gPiA+ID4gPiA+
IEkgYWxzbyBmb3VuZCB0aGF0IHJldmVydGluZyB0aGF0IGh1bmsgcmVzdWx0cyBpbiBhIDMtNCUN
Cj4gPiA+ID4gPiA+ID4gaW1wcm92ZW1lbnQgaW4gZmlvDQo+ID4gPiA+ID4gPiA+IElPUFMgcmF0
ZXMsIGFzIHdlbGwgYXMgaW1wcm92ZW1lbnQgaW4gYXZlcmFnZSBhbmQgbWF4aW11bQ0KPiA+ID4g
PiA+ID4gPiBsYXRlbmN5DQo+ID4gPiA+ID4gPiA+IGFzIHJlcG9ydGVkDQo+ID4gPiA+ID4gPiA+
IGJ5IGZpby4NCj4gPiA+ID4gPiA+ID4gDQo+ID4gPiA+ID4gPiANCj4gPiA+ID4gPiA+IEhtbeKA
piBQcm92aWRlZCB0aGUgc2VxdWVuY2UgbnVtYmVycyBzdGlsbCBsaWUgd2l0aGluIHRoZQ0KPiA+
ID4gPiA+ID4gd2luZG93LA0KPiA+ID4gPiA+ID4gdGhlbiB3aHkgd291bGQgdGhlIG9yZGVyIG1h
dHRlcj8NCj4gPiA+ID4gPiANCj4gPiA+ID4gPiBUaGUgbWlzb3JkZXJpbmcgaXMgc28gYmFkIHRo
YXQgb25lIHJlcXVlc3QgaXMgZGVsYXllZCBsb25nDQo+ID4gPiA+ID4gZW5vdWdoDQo+ID4gPiA+
ID4gdG8NCj4gPiA+ID4gPiBmYWxsIG91dHNpZGUgdGhlIHdpbmRvdy4gVGhlIG5ldyDigJxuZWVk
IHJlLWVuY29kZeKAnSBsb2dpYyBkb2VzDQo+ID4gPiA+ID4gbm90DQo+ID4gPiA+ID4gdHJpZ2dl
ci4NCj4gPiA+ID4gPiANCj4gPiA+ID4gDQo+ID4gPiA+IFRoYXQncyB3ZWlyZC4gSSBjYW4ndCBz
ZWUgYW55dGhpbmcgd3Jvbmcgd2l0aCBuZWVkIHJlLWVuY29kZSBhdA0KPiA+ID4gPiB0aGlzDQo+
ID4gPiA+IHBvaW50Lg0KPiA+ID4gDQo+ID4gPiBJIGRvbid0IHRoaW5rIHRoZXJlIGlzIGFueXRo
aW5nIHdyb25nIHdpdGggaXQsIGl0IGxvb2tzIGxpa2UgaXQncw0KPiA+ID4gbm90IGNhbGxlZCBp
biB0aGlzIGNhc2UuDQo+ID4gDQo+ID4gU28geW91IGFyZSBzYXlpbmcgdGhhdCB0aGUgY2FsbCB0
byBycGNhdXRoX3htaXRfbmVlZF9yZWVuY29kZSgpIGlzDQo+ID4gdHJpZ2dlcmluZyB0aGUgRUJB
RE1TRywgYnV0IHRoYXQgdGhpcyBmYWlscyB0byBjYXVzZSBhIHJlLWVuY29kZSBvZg0KPiA+IHRo
ZQ0KPiA+IG1lc3NhZ2U/DQo+IA0KPiBObywgSSB0aGluayB3aGF0J3MgZ29pbmcgb24gaXMgdGhh
dCB0aGUgbmVlZF9yZWVuY29kZSBoYXBwZW5zIHdoZW4NCj4gdGhlDQo+IFJQQyBpcyBlbnF1ZXVl
ZCwgYW5kIGlzIHN1Y2Nlc3NmdWwuDQo+IA0KPiBCdXQgeHBydF9yZXF1ZXN0X2VucXVldWVfdHJh
bnNtaXQgcGxhY2VzIHRoZSBSUEMgc29tZXdoZXJlIGluIHRoZQ0KPiBtaWRkbGUNCj4gb2YgeG1p
dF9xdWV1ZS4geG1pdF9xdWV1ZSBpcyBsb25nIGVub3VnaCB0aGF0IG1vcmUgdGhhbiAxMjggcmVx
dWVzdHMNCj4gYXJlDQo+IGJlZm9yZSB0aGUgZW5xdWV1ZWQgcmVxdWVzdC4NCg0KVGhlIHRlc3Qg
Zm9yIHJwY2F1dGhfeG1pdF9uZWVkX3JlZW5jb2RlKCkgaGFwcGVucyB3aGVuIHdlIGNhbGwNCnhw
cnRfcmVxdWVzdF90cmFuc21pdCgpIHRvIGFjdHVhbGx5IHB1dCB0aGUgUlBDIGNhbGwgb24gdGhl
IHdpcmUuIFRoZQ0KZW5xdWV1ZSBvcmRlciBzaG91bGQgbm90IGJlIGFibGUgdG8gZGVmZWF0IHRo
YXQgdGVzdC4NCg0KSG1tLi4uIElzIGl0IHBlcmhhcHMgdGhlIHRlc3QgZm9yIHJlcS0+cnFfYnl0
ZXNfc2VudCB0aGF0IGlzIGZhaWxpbmcNCmJlY2F1c2UgdGhpcyBpcyBhIHJldHJhbnNtaXNzaW9u
IGFmdGVyIGEgZGlzY29ubmVjdC9yZWNvbm5lY3QgdGhhdA0KZGlkbid0IHRyaWdnZXIgYSByZS1l
bmNvZGU/DQoNCj4gPiA+ID4gRG8gdGhlIHdpbmRvdyBzaXplcyBhZ3JlZSBvbiB0aGUgY2xpZW50
IGFuZCB0aGUgc2VydmVyPw0KPiA+ID4gDQo+ID4gPiBZZXMsIGJvdGggYXJlIDEyOC4gSSBhbHNv
IHRyaWVkIHdpdGggNjQgb24gdGhlIGNsaWVudCBzaWRlIGFuZA0KPiA+ID4gMTI4DQo+ID4gPiBv
biB0aGUgc2VydmVyIHNpZGUuIFRoYXQgcmVkdWNlcyB0aGUgZnJlcXVlbmN5IG9mIGRpc2Nvbm5l
Y3RzLA0KPiA+ID4gYnV0DQo+ID4gPiBkb2VzIG5vdCBlbGltaW5hdGUgdGhlbS4NCj4gPiA+IA0K
PiA+ID4gSSdtIG5vdCBjbGVhciB3aGF0IHByb2JsZW0gdGhlIGxvZ2ljIGluDQo+ID4gPiB4cHJ0
X3JlcXVlc3RfZW5xdWV1ZV90cmFuc21pdA0KPiA+ID4gaXMgdHJ5aW5nIHRvIGFkZHJlc3MuIEl0
IHNlZW1zIHRvIG1lIHRoYXQgdGhlIGluaXRpYWwsIHNpbXBsZQ0KPiA+ID4gaW1wbGVtZW50YXRp
b24gb2YgdGhpcyBmdW5jdGlvbiBpcyBlbnRpcmVseSBhZGVxdWF0ZS4uPw0KPiA+IA0KPiA+IEkg
YWdyZWUgdGhhdCB0aGUgZmFpciBxdWV1ZWluZyBjb2RlIGNvdWxkIHJlc3VsdCBpbiBhIHJlb3Jk
ZXJpbmcNCj4gPiB0aGF0DQo+ID4gY291bGQgc2NyZXcgdXAgdGhlIFJQQ1NFQ19HU1Mgc2VxdWVu
Y2luZy4gSG93ZXZlciwgd2UgZG8gZXhwZWN0IHRoZQ0KPiA+IG5lZWQgcmVlbmNvZGUgc3R1ZmYg
dG8gY2F0Y2ggdGhhdC4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQg
bWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20N
Cg0KDQo=
