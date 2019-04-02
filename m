Return-Path: <SRS0=y3t/=SE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28F5AC4360F
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 22:33:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E4D2C20700
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 22:33:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="caW62/Tk"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726157AbfDBWd5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 18:33:57 -0400
Received: from mail-eopbgr740103.outbound.protection.outlook.com ([40.107.74.103]:41690
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726071AbfDBWd4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 2 Apr 2019 18:33:56 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=A+9hzLRms0j8OLv2tohIoABc/G5ToJfgf9f1+BRjer4=;
 b=caW62/TkZf/soR1jzYkmE38q4WqB5ITHqwpz6+4SepqCAlJrTUCo/F5V0S+QPdO7rMGboE6tYxE3T2+2+xrC5oIERutGPGq3lcJTfClBao5YqW8gJQBZSoBZWTpGkPsHjZm2gKtvHsFpHy/bh88eqZb3+jBBbzvtcEuaruUSTgQ=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2462.namprd13.prod.outlook.com (52.135.95.30) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1771.6; Tue, 2 Apr 2019 22:33:52 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1771.007; Tue, 2 Apr 2019
 22:33:52 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "bradley.kuszmaul@oracle.com" <bradley.kuszmaul@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: directory delegations
Thread-Topic: directory delegations
Thread-Index: AQHU6KcNiRPQ7r4+DEebmwXdEDXzDKYpDBcAgAAU+ICAACXbAIAAJEkAgAALyYA=
Date:   Tue, 2 Apr 2019 22:33:52 +0000
Message-ID: <a9baff89369b961f35317d73a9edca8b9dc85a41.camel@hammerspace.com>
References: <2065755c-f888-9c62-f6e5-f143d42c51ee@oracle.com>
         <20190402161116.GA2828@fieldses.org>
         <2f1f6582-3672-1361-4392-80cb1e62e19c@oracle.com>
         <20190402194148.GA5269@fieldses.org>
         <58230e155813e866cb057e6543ab7e61f51fedf6.camel@hammerspace.com>
In-Reply-To: <58230e155813e866cb057e6543ab7e61f51fedf6.camel@hammerspace.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [63.235.104.78]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 71836fd6-ed0b-47c1-33ee-08d6b7bb48c0
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600139)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:SN6PR13MB2462;
x-ms-traffictypediagnostic: SN6PR13MB2462:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs: <SN6PR13MB246267F8B6F4880F201BC7AFB8560@SN6PR13MB2462.namprd13.prod.outlook.com>
x-forefront-prvs: 0995196AA2
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(346002)(396003)(136003)(39830400003)(366004)(199004)(189003)(110136005)(305945005)(476003)(71190400001)(36756003)(14454004)(316002)(71200400001)(186003)(68736007)(486006)(8936002)(97736004)(93886005)(66066001)(2616005)(6506007)(229853002)(106356001)(102836004)(25786009)(3480700005)(6486002)(7736002)(105586002)(5660300002)(53936002)(11346002)(256004)(478600001)(2906002)(446003)(7116003)(26005)(966005)(2501003)(6116002)(118296001)(6436002)(81166006)(3846002)(99286004)(8676002)(6306002)(76176011)(221733001)(81156014)(86362001)(4326008)(6246003)(6512007)(111123002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2462;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 8ZbIwTlCjxThxKv5H7zmyR/O5ZVIanhA9Kruf89Zps4IuKViPH4eyrmjY3EyvgbIOl94Q0k202Y4YzSKbXk6vWolS4Y95pyZJvYXoKbJentmlwObX648IUl6JsV5W4+yK/PRCeu1bAoj6aWGOGxOVkQsw/9yKBoFHFFzWWvsxfhPs7HKJJxYcoYfTylePF424GG3ndQDCFkGLJWWXZ8T7rAMw8z4oXzOkULSMRlz8rUkhdGeBkCKwTiksSSDJ2jCFBL2gp8Y41VEF/nsdiwEgO5vpkDJsGR0vKDPemfpKDPVLzdyr6kAQo3c4hJc8G5VAWz/Hx8gRjk3hSwaPcdMKIrHi2MxJsu2sA6N1ZGpj/Fv3hvih3hVt3CPzjB8RihZmUYlRMgJlGqu0L3xoGZjJV4B2c/Cbjq1xipUt303klU=
Content-Type: text/plain; charset="utf-8"
Content-ID: <F5B4F564B5C9704A834C19C9D8C4207E@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 71836fd6-ed0b-47c1-33ee-08d6b7bb48c0
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Apr 2019 22:33:52.5385
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2462
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE5LTA0LTAyIGF0IDIxOjUxICswMDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+IE9uIFR1ZSwgMjAxOS0wNC0wMiBhdCAxNTo0MSAtMDQwMCwgSi4gQnJ1Y2UgRmllbGRzIHdy
b3RlOg0KPiA+IE9uIFR1ZSwgQXByIDAyLCAyMDE5IGF0IDAxOjI2OjE5UE0gLTA0MDAsIEJyYWRs
ZXkgQy4gS3Vzem1hdWwNCj4gPiB3cm90ZToNCj4gPiA+IE15IHNpbXBsZSBtb2RlbCBvZiBtZXRh
ZGF0YSBvcGVyYXRpb25zIGlzIHRvIHVudGFyIHNvbWV0aGluZyBsaWtlDQo+ID4gPiB0aGUgbGlu
dXggc291cmNlcy4NCj4gPiA+IA0KPiA+ID4gRWFjaCBmaWxlIGluY3VycyBhIExPT0tVUCwgQ1JF
QVRFLCBTRVRBVFRSLCBhbmQgV1JJVEUsIGVhY2ggb2YNCj4gPiA+IHdoaWNoDQo+ID4gPiBpcyBm
YWlybHkgaGlnaCBsYXRlbmN5IChldmVuIHRoZSBXUklURSBlbmRzIHVwIGJlaW5nIGRvbmUNCj4g
PiA+IGVzc2VudGlhbGx5IHN5bmNocm9ub3VzbHkgYmVjYXVzZSB0YXIgY2xvc2VzIHRoZSBmaWxl
IGFmdGVyIGl0cw0KPiA+ID4gd3JpdGUoMikgY2FsbC4pDQo+ID4gDQo+ID4gQW4gb3JkaW5hcnkg
ZmlsZSB3cml0ZSBkZWxlZ2F0aW9uIGNhbiBoZWxwIHdpdGggc29tZSBvZiB0aGF0Lg0KPiA+IA0K
PiA+ID4gSSBndWVzcyBkaXJlY3RvcnkgZGVsZWdhdGlvbnMgbWlnaHQgc2F2ZSB0aGUgY29zdCBv
ZiBMT09LVVAuDQo+ID4gPiANCj4gPiA+IElzIHRoZXJlIGFueSBob3BlIGZvciBnZXR0aW5nIHdy
aXRlIGRlbGVnYXRpb25zPw0KPiA+ID4gDQo+ID4gPiBXaGF0IG90aGVyIHN0ZXBzIG1pZ2h0IGJl
IHBvc3NpYmxlPw0KPiA+IA0KPiA+IFRyb25kLCB3YXNuJ3QgdGhlcmUgYSBkcmFmdCBkZXNjcmli
aW5nIHlvdXIgaWRlYSB0aGF0IGEgc2VydmVyDQo+ID4gc2hvdWxkDQo+ID4gYmUNCj4gPiBhYmxl
IHRvIGdyYW50IGEgd3JpdGUgZGVsZWdhdGlvbiBvbiBjcmVhdGUgYW5kIGRlbGF5IHRoZSBzeW5j
PyAgSQ0KPiA+IGNhbid0DQo+ID4gZmluZCBpdCByaWdodCBub3cuDQo+IA0KPiBEbyB5b3UgbWVh
biB0aGlzIG9uZT8gDQo+IGh0dHBzOi8vdG9vbHMuaWV0Zi5vcmcvaHRtbC9kcmFmdC1oYXluZXMt
bmZzdjQtZGVsc3RpZC0wMA0KPiANCg0KQlRXOiBhc3N1bWluZyB0aGF0IHdlIGRvIGdldCB0aGUg
YWJvdmUgZHJhZnQgdGhyb3VnaCB0aGUgSUVURiwgdGhlbiB3ZQ0Kc2hvdWxkIGxvb2sgaW50byBk
ZWxheWluZyB0aGF0IFNFVEFUVFIgYXMgd2VsbC4gUmVjYWxsIHRoYXQgdGhlIFNFVEFUVFINCmV4
aXN0cyBiZWNhdXNlIHRoZSBzZXJ2ZXIgcHVzaGVzIHRoZSBleGNsdXNpdmUgY3JlYXRlIHZlcmlm
aWVyIGludG8gdGhlDQpmaWxlIHRpbWVzdGFtcHMuIFdpdGggdGhlIGF0dHJpYnV0ZSBkZWxlZ2F0
aW9ucyBwcm9wb3NlZCBpbiB0aGUgYWJvdmUNCmRyYWZ0LCB0aGVuIHdlIGNhbiBlc3NlbnRpYWxs
eSBkZWZlciB0aGF0IFNFVEFUVFIgdG8gd2hlbiB3ZSByZXR1cm4gdGhlDQpkZWxlZ2F0aW9uLCB3
aGljaCBtZWFucyB5b3Ugd291bGQgZW5kIHVwIHdpdGggMyBvcGVyYXRpb25zIHBlciBmaWxlIHRv
DQp1bnRhcjogT1BFTiwgV1JJVEUsIERFTEVHUkVUVVJOICh3aXRoIGVtYmVkZGVkIFNFVEFUVFIg
b3ApLiBPbmx5IHRoZQ0KZmlyc3Qgb3BlcmF0aW9uIHdvdWxkIG5lZWQgdG8gYmUgc3luY2hyb25v
dXMuLi4NCg0KQ2hlZXJzDQogIFRyb25kDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZT
IGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNw
YWNlLmNvbQ0KDQoNCg==
