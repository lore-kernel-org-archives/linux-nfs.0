Return-Path: <SRS0=lcGf=NX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4EB1C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Nov 2018 23:58:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 23C442241E
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Nov 2018 23:58:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="vBcA4fis"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23C442241E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726198AbeKMJxs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 13 Nov 2018 04:53:48 -0500
Received: from mail-eopbgr700123.outbound.protection.outlook.com ([40.107.70.123]:31893
        "EHLO NAM04-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726028AbeKMJxs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Nov 2018 04:53:48 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=8b93i2fQWRZ0ZNW55F2oCNnD1H2PsyeDVy/dIchxO3M=;
 b=vBcA4fispEFc0F1FWw6ohPBQlxgTpyHK0ia55WxxmgPbMq3R6OWGTvd28CeWUzm68Rrc29xmQ+Aj4BBS6vJBhnpcvVlAdkGHcvrXnXP1r83Gymtc/OdsaPZVAdxMvM6FbcYwg40acDgvTE4OpBIhJ4hG4/hdQzxnyzWH4JMPjRA=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2352.namprd13.prod.outlook.com (52.135.94.144) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1339.11; Mon, 12 Nov 2018 23:57:40 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475%3]) with mapi id 15.20.1339.019; Mon, 12 Nov 2018
 23:57:40 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>
CC:     "schumakeranna@gmail.com" <schumakeranna@gmail.com>,
        "chucklever@gmail.com" <chucklever@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NULL dereference in rpcauth_lookup_credcache
Thread-Topic: NULL dereference in rpcauth_lookup_credcache
Thread-Index: AQHUd6xJVdpNrPMTaUWtaTxXqXNyo6VHvSMAgAHSE4CAAuRdgIAABxgAgAAwJgCAAB04gIAAD5eA
Date:   Mon, 12 Nov 2018 23:57:40 +0000
Message-ID: <9d36177854ba176f46e7a9842aa0368cc508b599.camel@hammerspace.com>
References: <20181108214452.GH6090@fieldses.org>
         <04114B00-B5A8-4F8A-B052-A266AED7725D@gmail.com>
         <20181110214939.GA16755@fieldses.org>
         <c986450a2d19fa796078ed51b9d0fb8a79eda696.camel@hammerspace.com>
         <20181112182454.GE16755@fieldses.org>
         <2e62a77385b4e5d91e2ca9128313cf817c46a1ae.camel@hammerspace.com>
         <20181112230149.GF16755@fieldses.org>
In-Reply-To: <20181112230149.GF16755@fieldses.org>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2352;6:K9XOzGu2DnQzo3rLQsFQl2LRlBQr8tr61crl/31Z9YR1S2HU2WduwhEKnsl7zJvltRwkz7s+8nReOjszd0u/77AtaekK370/fkU9/VIFQxQpMNzfVs3z+I7Qdg3jkKrWYASePgbwatOCijxWshQfI7aRcFBsq7Uag088sBg75s0tF0DPIgGmbGsBlpO7WTHRhDxGxAx3WxSZ1YAivuOJF1jHIJW+UsWFKDsiddK6xpHtk2oZ0pMnvgYuG4D3y/xOi3Wg2dlpuRNurpAmPCVA19NqOtolp+/EqZ/vdZCLJWJLJmozYF6uwtx8znRoU1TyVPqTnTvudFagYyRDtOv6QkDcK5EO7wdSVHgublh/npHQisJ3wsQkIcKXbQTH37AmvD9+L45LlOC1pH9RUUjIgPna1JI1vPGjZixvKS2WkP02+sN96dOzli3nsbvOCpzg+Z5lXIXETYUJ3deTRE31wg==;5:CtSJy4J2uHYEyGD+s2rxLP/GlioD8NQNFJeWK7OE6NMebY9mpcxe2jxwBoxRo9Hkc2VGvHjU8uDFqmmSM16Pze7NJXFcZRaiIAZ9rlHdmTfMmoCbW3q1rqBq/YHRRYkdmW5rwEtnoz/keKcN41gSSwFkbD2URra8R3qTZofSRNE=;7:masolfy7MWfd4DuB6674pMl+D1a9V6g7zK8IyYs8yr/CTSKLnKN52XBwr1LNg22o+FrTUKVZ1dKU2Btt7dUcB/WdSysIml49T0lzHtQ20E3rhettYrFibEqR3u/b6WRgARqfHM5Df3kH9hkWl3qFAw==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 8f488d3f-e00e-4c43-7962-08d648faa12d
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390040)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2352;
x-ms-traffictypediagnostic: SN6PR13MB2352:
x-microsoft-antispam-prvs: <SN6PR13MB2352A2A4F34E56F18C1549F0B8C10@SN6PR13MB2352.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(93006095)(93001095)(10201501046)(3002001)(3231382)(944501410)(52105112)(148016)(149066)(150057)(6041310)(20161123562045)(20161123558120)(20161123560045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123564045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2352;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2352;
x-forefront-prvs: 0854128AF0
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(366004)(396003)(346002)(136003)(39830400003)(189003)(199004)(26005)(6486002)(3846002)(6116002)(102836004)(256004)(6506007)(76176011)(4326008)(25786009)(5660300001)(6436002)(478600001)(2906002)(118296001)(53936002)(93886005)(186003)(14454004)(66066001)(6512007)(36756003)(2900100001)(68736007)(5640700003)(81156014)(4001150100001)(39060400002)(99286004)(486006)(2616005)(54906003)(11346002)(446003)(1730700003)(86362001)(81166006)(8676002)(8936002)(476003)(229853002)(6916009)(105586002)(7736002)(97736004)(305945005)(106356001)(6246003)(2351001)(2501003)(316002)(71190400001)(71200400001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2352;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: 8viYSuPYOD02dyg1eloQVIh/hGLxg1hve1Uedxy8KWt0/xa81J+X3XW4xOc+ImWAvkOvFh9ppXhNUB+Pj2meEjxV3IjdT+WYD6nEquTl690oBWGgdtRaBsQMmDunU3HXKOY17viZq+QBN3FNdFFrUl6d1mWAGNkx6JyJpYAloD1G+hjssK81hEd+5CWkC3TqOJc00DXKtnFpe/2XydioT+L7y97q5562hJgQb4aUcugQPx6MK7O44WixAN8RKTN843A+6Z/GJF5mT49YbukpljOOVTdP/u5QUNpUjPM7wBGtMifXp4FLsOkPzhx74unilwkiAWhfKFTidK+8jA0exoQ/qlH278Lnr1pHE+tYbc4=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <DDEF8A1348CA7149B9615F25ECFD4EC1@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8f488d3f-e00e-4c43-7962-08d648faa12d
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Nov 2018 23:57:40.1088
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2352
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE4LTExLTEyIGF0IDE4OjAxIC0wNTAwLCBiZmllbGRzQGZpZWxkc2VzLm9yZyB3
cm90ZToNCj4gT24gTW9uLCBOb3YgMTIsIDIwMTggYXQgMDk6MTc6MTZQTSArMDAwMCwgVHJvbmQg
TXlrbGVidXN0IHdyb3RlOg0KPiA+IE9uIE1vbiwgMjAxOC0xMS0xMiBhdCAxMzoyNCAtMDUwMCwg
YmZpZWxkc0BmaWVsZHNlcy5vcmcgd3JvdGU6DQo+ID4gPiBPbiBNb24sIE5vdiAxMiwgMjAxOCBh
dCAwNTo1OTozM1BNICswMDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6DQo+ID4gPiA+IE9uIFNh
dCwgMjAxOC0xMS0xMCBhdCAxNjo0OSAtMDUwMCwgQnJ1Y2UgRmllbGRzIHdyb3RlOg0KPiA+ID4g
PiA+IExvb2tzIGxpa2UgaXQncyB0aGUgZmF1bHQgb2YNCj4gPiA+ID4gPiANCj4gPiA+ID4gPiAw
N2QwMmE2N2I3ZmFhZSAiU1VOUlBDOiBTaW1wbGlmeSBsb29rdXAgY29kZSINCj4gPiA+ID4gDQo+
ID4gPiA+IEknbSBoYXZpbmcgdHJvdWJsZSByZXByb2R1Y2luZyB0aGlzIGJ1Zy4gSSd2ZSB0cmll
ZCBib3RoIGN0aG9uDQo+ID4gPiA+IGFuZA0KPiA+ID4gPiB4ZnN0ZXN0cyBpbiBhIGxvb3AsIHNv
IGZhciB3aXRob3V0IHN1Y2Nlc3MgKGJvdGggTkZTdjMgYW5kDQo+ID4gPiA+IHY0LjEsDQo+ID4g
PiA+IGJ1dA0KPiA+ID4gPiBvbmx5IHNlYz1zeXMpLiBJcyB0aGVyZSBhbnl0aGluZyBlbHNlIHlv
dSdyZSBkb2luZyB0aGF0IEkgbWlnaHQNCj4gPiA+ID4gdHJ5Pw0KPiA+ID4gPiANCj4gPiA+ID4g
ZS5nLiBBcmUgeW91IHJ1bm5pbmcgbXVsdGlwbGUgd29ya2xvYWRzIGluIHBhcmFsbGVsPyBEaWZm
ZXJlbnQNCj4gPiA+ID4gdXNlcnM/Li4NCj4gPiA+IA0KPiA+ID4gTm90aGluZyB0aGF0IGludGVy
ZXN0aW5nLiAgQ3VycmVudGx5IGl0J3MgY29ubmVjdGF0aG9uIG92ZXIgdjQsDQo+ID4gPiB2MywN
Cj4gPiA+IHY0L2tyYjUsIHYzL2tyYjUsIHY0L2tyYjVpLCB2NC9rcmI1cCwgdjQuMSwgdjQuMS9r
cmI1LCBidXQganVzdA0KPiA+ID4gc2VyaWFsbHkNCj4gPiA+IG9uZSBhZnRlciB0aGUgb3RoZXIu
ICBUaGVuIHNvbWUgcHluZnMgdGVzdHMgKHdoaWNoIGJ5cGFzcyB0aGUNCj4gPiA+IGNsaWVudCks
DQo+ID4gPiB0aGVuIHhmc3Rlc3RzIG92ZXIgdjQuMi9zeXMuICBBbmQgYWxzbyBhIGZldyBvbmUt
b2ZmIGxvY2tpbmcNCj4gPiA+IHRlc3RzIG9mDQo+ID4gPiBteQ0KPiA+ID4gb3duIHRoYXQgcHJv
YmFibHkgYXJlbid0IGEgZmFjdG9yIGhlcmUuDQo+ID4gPiANCj4gPiA+IChIYWgsIEkganVzdCBy
ZWFsaXplZCBJIHdhcyBtb3VudGluZyB3aXRoIHZlcnM9NCBhbmQgYXNzdW1pbmcNCj4gPiA+IHRo
YXQNCj4gPiA+IG1lYW50DQo+ID4gPiA0LjAsIGJ1dCBhY3R1YWxseSBpdCdzIGNoYW5nZWQgb3Zl
ciB0aW1lIGRlcGVuZGluZyBvbiB0aGUNCj4gPiA+IGRlZmF1bHRzLA0KPiA+ID4gc28NCj4gPiA+
IGN1cnJlbnRseSB0aG9zZSAidjQiIHJ1bnMgYXJlIGFjdHVhbGx5IGFsbCA0LjIuICBHYWguKQ0K
PiA+IA0KPiA+IEFyZSB5b3UgcGVyaGFwcyBib3RoIHVzaW5nIFJQQ1NFQ19HU1Mgdy8gaW50ZWdy
aXR5IGNoZWNraW5nIGZvcg0KPiA+IHlvdXINCj4gPiBFWENIQU5HRV9JRCBhdXRoZW50aWNhdGlv
bj8gVGhlIGNsaWVudCB3aWxsIGF0dGVtcHQgdG8gdXNlIHRoYXQgYnkNCj4gPiBkZWZhdWx0IGlm
IHJwYy5nc3NkIGlzIHJ1bm5pbmcuDQo+IA0KPiBZZXMsIGluIGFkZGl0aW9uIHRvIHRoZSBrcmI1
aSBtb3VudCBJJ2QgZXhwZWN0IHRoZSBzeXMva3JiNS9rcmI1cA0KPiBtb3VudHMNCj4gYXJlIHVz
aW5nIGtyYjVpIGZvciBFWENIQU5HRV9JRC4NCj4gDQo+ID4gSSBhc2sgYmVjYXVzZSBJIHRoaW5r
IHRoZSBpc3N1ZSBtaWdodCBiZSB3aXRoIFJQQ1NFQ19HU1MsDQo+ID4gc3BlY2lmaWNhbGx5DQo+
ID4gd2l0aCB0aGUgUlBDU0VDX0dTUyBjb250ZXh0IGRlc3Ryb3kgY29kZSwgaGVuY2UgdGhlIDIg
cGF0Y2hlcyB0aGF0DQo+ID4gSQ0KPiA+IGp1c3Qgc2VudCBvdXQuDQo+IA0KPiBMb29rcyBsaWtl
IG15IHRlc3RzIHBhc3MgYWZ0ZXIgYXBwbHlpbmcgdGhvc2UgdHdvIHBhdGNoZXMuDQo+IA0KDQpD
b29sISBUaGFua3MgZm9yIHRlc3RpbmcuDQoNCkNodWNrLCBkbyB5b3UgdGhpbmsgdGhlIGFib3Zl
IG1pZ2h0IGFsc28gZXhwbGFpbiB5b3VyIHNpZ2h0aW5nIG9mIHRoZQ0Kc2FtZSBPb3BzPw0KDQpD
aGVlcnMNCiAgVHJvbmQNCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQg
bWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20N
Cg0KDQo=
