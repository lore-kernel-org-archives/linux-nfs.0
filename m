Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CF7BC04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 22:36:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1D0D720660
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 22:36:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="q7HVgQK/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D0D720660
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725790AbeLAJrd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 04:47:33 -0500
Received: from mail-eopbgr710130.outbound.protection.outlook.com ([40.107.71.130]:23712
        "EHLO NAM05-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725941AbeLAJrd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 1 Dec 2018 04:47:33 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=oJUWoEj/znwtST30fLSw1SKVNpUihDxiqCo5j7zwdOc=;
 b=q7HVgQK/EJ1ZCYffywYEwJIx4/5/jtUJnpfLb5T8smAJjJFMiSM5JieNtTX+QAH7cd5oiaKBTUgfDaOup0mi8RD2EWitgmsOlXpKY7irkQRkc1o7GdENtMdN39XF5K2IG3gJKzN7FqvZGS+t6sokQSrEphBumqI95DH/Km3F/bE=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2429.namprd13.prod.outlook.com (52.135.94.161) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1382.13; Fri, 30 Nov 2018 22:36:02 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1404.011; Fri, 30 Nov 2018
 22:36:02 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 3/3] SUNRPC: Ensure we refresh the bvec after
 RPCSEC_GSS encoding
Thread-Topic: [PATCH v3 3/3] SUNRPC: Ensure we refresh the bvec after
 RPCSEC_GSS encoding
Thread-Index: AQHUiPekUfCRRl/oV0O8KonnDr8pv6Vo4moAgAAA+wCAAAFKgIAAAeKAgAAAYYCAAAFBAA==
Date:   Fri, 30 Nov 2018 22:36:02 +0000
Message-ID: <5916f9e3215d06f8697d63c47f07776c621d6f86.camel@hammerspace.com>
References: <20181130215555.91107-1-trond.myklebust@hammerspace.com>
         <20181130215555.91107-2-trond.myklebust@hammerspace.com>
         <20181130215555.91107-3-trond.myklebust@hammerspace.com>
         <E9450F2D-D888-4EFC-B0BD-6506E4EC2887@oracle.com>
         <545d13619ffe92a69097f8f68fc36df85944cac2.camel@hammerspace.com>
         <7B7D615F-8A5B-4EBD-96DC-FDDA9DC35DD9@oracle.com>
         <499a31eab46be4e0ad0ec13e7ae693cd133a0444.camel@hammerspace.com>
         <5F42A4A1-59EA-4467-8FC1-40E1872351B8@oracle.com>
In-Reply-To: <5F42A4A1-59EA-4467-8FC1-40E1872351B8@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2429;6:xSHnsVmw1oreLNICtxLzoJj3r6ZCGYzNCiDGA3QZTCzvjH4Jg+GF1yusgNwO8plLjDpDkHHuFHBcfvnuJ1tEsRoUhJ6+oihkl/yNqlLDhpaCwXkP4tdPWwx0iJJZ1egZaUmsSCDxrCssr7mpGYG+06P57uvddLJfu7tkVvV7m8npHqrIE9zDHNfofj2g8dho9zrIaYMTWk8gDbW6+HrvM6NY4UKzybpoBbWa9xn/ZJQNPaR3uKVeWFdUZEXXVJstj6nj+TCSi4cWSiBteF2ZKswvR+8Gnhhr/8W4FykCyEo2+hWGW055Po+8WkKmJ16fsXkxyD7q5TOYU5y3azl0KcoqCUz11RCIBUMOKY6+z8jU13jqjxO5IGTzsSCI1HA87JaL2xKJ3fyLVftHOM8FwmzUBvDNGnyJ3MnkLzS+GUxEBJURFf9TphkADs7jfo1KzbUIh2g4hSRDYam1AHFGqw==;5:2yVC6ce10x6gRe87QAVsX3Oe1YYl9N8D0NYy8HdIb1RIkfp+1OsX6Hl8FWjI6sWuUrGD5zYZBqew2KNGV7Zd7/7ciO2ZQmQNFz2zoHGMjx/Pq+pWDUWuyarKpmrCZNXJ1ITeeNQedK0OvIW+t6WqWoR5vBl6iD03XibBzP6E/ro=;7:yR7JPOPIeP9ey+jL8AiROMFtcLhZrLCPlWcdoRdoB67IqD+iTLypT44WBsw/VMFdtl5q/udCUAcvodbsORTeljVi4xkMVnxr3RwwF1wPLWhF9W8imVfVEWQptiX+rXbGkdFfVfAncG72QMDcZEnY0g==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 382af346-e138-479c-be9e-08d657143529
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2429;
x-ms-traffictypediagnostic: SN6PR13MB2429:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-prvs: <SN6PR13MB2429BE07340F1FBA7C8B3B57B8D30@SN6PR13MB2429.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(10201501046)(3231453)(999002)(944501469)(52105112)(3002001)(93006095)(93001095)(148016)(149066)(150057)(6041310)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123564045)(20161123558120)(20161123562045)(20161123560045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2429;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2429;
x-forefront-prvs: 087223B4DA
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39830400003)(136003)(376002)(346002)(366004)(396003)(189003)(199004)(2616005)(11346002)(5640700003)(76176011)(68736007)(5660300001)(305945005)(81156014)(81166006)(6506007)(25786009)(105586002)(478600001)(229853002)(6246003)(106356001)(7736002)(26005)(71190400001)(71200400001)(3846002)(6116002)(6512007)(8936002)(8676002)(86362001)(102836004)(446003)(14444005)(4326008)(486006)(256004)(66066001)(118296001)(186003)(53936002)(93886005)(4001150100001)(99286004)(6436002)(2351001)(476003)(14454004)(6486002)(2501003)(53546011)(2906002)(97736004)(36756003)(6916009)(316002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2429;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: 1Ol4R1N8ITgWB3DJ8G5uQM4PkGQb0YxgKAu42q9hJ9bBBqiIdUULJK2uXECjGoWabL94k5KeYSmdf166G+P8fKsv6ueiQQwyxqf0Aipsl2PkWU1r93c33WihM8PRJ2oMxhdXteQwgKMbLVKpk6B10TqE9X2bThxiyeSsHJuPeNedYdlRZIaMQH7t28W5yWq7sr/Fv9336lfZOD61myW8aNkq6NSAty2Y8MK6rNf9rzwkqZlw0v9ne3NX/J4VmTSUjvfRHD+6DYr5PLm8ozCPksJDolg/FrQoyw/Pq1xuzVMY3KrQ74Iom2ghV2QR4rnp6n0jMIMBBHrvX7IwJJDs93arMSkYC4KDs178kJGDjlA=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <BA448E07C0778C4991C3D846B77EFE58@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 382af346-e138-479c-be9e-08d657143529
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Nov 2018 22:36:02.1073
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2429
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE4LTExLTMwIGF0IDE3OjMxIC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBOb3YgMzAsIDIwMTgsIGF0IDU6MzAgUE0sIFRyb25kIE15a2xlYnVzdCA8DQo+ID4gdHJv
bmRteUBoYW1tZXJzcGFjZS5jb20+IHdyb3RlOg0KPiA+IA0KPiA+IE9uIEZyaSwgMjAxOC0xMS0z
MCBhdCAxNzoyMyAtMDUwMCwgQ2h1Y2sgTGV2ZXIgd3JvdGU6DQo+ID4gPiA+IE9uIE5vdiAzMCwg
MjAxOCwgYXQgNToxOCBQTSwgVHJvbmQgTXlrbGVidXN0IDwNCj4gPiA+ID4gdHJvbmRteUBoYW1t
ZXJzcGFjZS5jb20+IHdyb3RlOg0KPiA+ID4gPiANCj4gPiA+ID4gT24gRnJpLCAyMDE4LTExLTMw
IGF0IDE3OjE1IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4gPiA+ID4gPiA+IE9uIE5vdiAz
MCwgMjAxOCwgYXQgNDo1NSBQTSwgVHJvbmQgTXlrbGVidXN0IDwNCj4gPiA+ID4gPiA+IHRyb25k
bXlAZ21haWwuY29tDQo+ID4gPiA+ID4gPiB3cm90ZToNCj4gPiA+ID4gPiA+IA0KPiA+ID4gPiA+
ID4gQSBjYWxsIHRvIGdzc193cmFwX3JlcV9wcml2KCkgd2lsbCBlbmQgdXAgcmVwbGFjaW5nIHRo
ZQ0KPiA+ID4gPiA+ID4gb3JpZ2luYWwNCj4gPiA+ID4gPiA+IGFycmF5DQo+ID4gPiA+ID4gPiBp
biBycXN0cC0+cnFfc25kX2J1Zi5wYWdlcyB3aXRoIGEgbmV3IG9uZSBjb250YWluaW5nIHRoZQ0K
PiA+ID4gPiA+ID4gZW5jcnlwdGVkDQo+ID4gPiA+ID4gPiBkYXRhLiBJbiBvcmRlciB0byBhdm9p
ZCBoYXZpbmcgdGhlIHJxc3RwLT5ycV9zbmRfYnVmLmJ2ZWMNCj4gPiA+ID4gPiA+IHBvaW50DQo+
ID4gPiA+ID4gPiB0bw0KPiA+ID4gPiA+ID4gdGhlDQo+ID4gPiA+ID4gPiB3cm9uZyBwYWdlIGRh
dGEsIHdlIG5lZWQgdG8gcmVmcmVzaCB0aGF0IHRvby4NCj4gPiA+ID4gPiANCj4gPiA+ID4gPiBJ
IHdvdWxkIGFkZCBhIG5vdGUgaGVyZSB0aGF0IHRoaXMgcGF0Y2ggZml4ZXMgYSBtZW1vcnkgbGVh
ay4NCj4gPiA+ID4gPiBBbmQNCj4gPiA+ID4gPiB5b3UgbWlnaHQgd2FudCB0byBhZGQgYSBGaXhl
czogdGFnLg0KPiA+ID4gPiA+IA0KPiA+ID4gPiANCj4gPiA+ID4gSXQgb25seSBhcHBsaWVzIHRv
IG5ldyBjb2RlIHRoYXQgd2VudCBpbnRvIDQuMjAsIHNvIGl0IHdvbid0DQo+ID4gPiA+IG5lZWQN
Cj4gPiA+ID4gYW55DQo+ID4gPiA+IHN0YWJsZSBiYWNrcG9ydGluZy4NCj4gPiA+ID4gDQo+ID4g
PiA+IFRoYXQgc2FpZCwgSSdtIHJlYWxpc2luZyAoc2xvd2x5IC0gYXBwYXJlbnRseSBJJ20gYXNs
ZWVwIHRvZGF5KQ0KPiA+ID4gPiB0aGF0DQo+ID4gPiA+IHRoaXMgaXMgcmVjZWl2ZSBzaWRlIGNv
ZGUsIHNvDQo+ID4gPiA+IA0KPiA+ID4gPiBhKSBUaGUgY29udGVudHMgb2YgcnFfc25kX2J1ZiBh
cmUgaXJyZWxldmFudC4NCj4gPiA+ID4gYikgV2Ugd2FudCB0byBiZXdhcmUgb2YgY2hhbmdpbmcg
aXQgd2hpbGUgdGhlcmUgaXMgYSBjb3B5IGluDQo+ID4gPiA+IHJxX3ByaXZhdGVfYnVmLg0KPiA+
ID4gPiANCj4gPiA+ID4gSU9XOiBhIHY0IGlzIGZvcnRoY29taW5nLg0KPiA+ID4gDQo+ID4gPiBm
d2l3LCBpIHNlZSB0aGUgc29mdCBJUlEgd2FybmluZ3Mgd2l0aCBORlMvUkRNQSB0b28uDQo+ID4g
PiANCj4gPiA+IEkgd291bGQgbGlrZSB0byB0dXJuIHRob3NlIGludG8gYSBwcl93YXJuX3JhdGVf
bGltaXRlZC4gSSBkb24ndA0KPiA+ID4gc2VlIG11Y2ggcG9pbnQgaW4gdGhlIGJhY2t0cmFjZSBi
bGF0aGVyLg0KPiA+ID4gDQo+ID4gDQo+ID4gWW91ciBpbml0aWFsIGVtYWlsIG1lbnRpb25lZCB0
aGVzZSBzb2Z0IElSUSB3YXJuaW5ncywgYnV0IGRpZG4ndA0KPiA+IHByb3ZpZGUgYW4gZXhhbXBs
ZS4gV2hpY2ggd2FybmluZ3MgYXJlIHRoZXNlIGV4YWN0bHksIGFuZCB3aGVyZSBhcmUNCj4gPiB0
aGV5IGNvbWluZyBmcm9tPw0KPiANCj4gVGhlIFdBUk5fT04gaW4gY2FsbF9kZWNvZGUgdGhhdCBm
aXJlcyB3aGVuIHJxX3Jjdl9idWYgZG9lcyBub3QNCj4gZXhhY3RseSBtYXRjaCBycV9wcml2YXRl
X2J1Zi4NCj4gDQoNCk9oIHRoYXQgd2FybmluZy4uLiBUaGF0IG1pZ2h0IGFjdHVhbGx5IGJlIHRy
aWdnZXJpbmcgb24gdGhlIGJ2ZWMgdmFsdWUNCmNsb2JiZXIuDQoNCi0tIA0KVHJvbmQgTXlrbGVi
dXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWts
ZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
