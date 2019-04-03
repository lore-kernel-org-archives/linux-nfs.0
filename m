Return-Path: <SRS0=5sV6=SF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9174DC4360F
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Apr 2019 02:07:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4B866206B8
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Apr 2019 02:07:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="MFwWT5Mn"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726411AbfDCCHu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 22:07:50 -0400
Received: from mail-eopbgr730111.outbound.protection.outlook.com ([40.107.73.111]:11075
        "EHLO NAM05-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726089AbfDCCHu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 2 Apr 2019 22:07:50 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=LJAH9DsMmTifBC7MRySDQ2wQkvPacRKjmmiWLjwxYzQ=;
 b=MFwWT5Mn3MdPDgKMCRv34PeYoEFDqFCefTC2G2/3xS3sS1+pywbg3yOF9k39doEotPdOhyXxjZdH7mr8YY5OlmyMX0tB78iGtuI/SEkkv81M8KZ+OMQK2hRz5B2cJ/L+Q1Wv8qaLXUOb3ATbvbIl6fbt8YpqP5sO3zanYCTp8i0=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2319.namprd13.prod.outlook.com (52.135.94.26) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1771.10; Wed, 3 Apr 2019 02:07:44 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1771.007; Wed, 3 Apr 2019
 02:07:44 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@redhat.com" <bfields@redhat.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/6] Allow containerised knfsd to set supported NFS
 versions
Thread-Topic: [PATCH 0/6] Allow containerised knfsd to set supported NFS
 versions
Thread-Index: AQHU6aot/r43Nv1xEUaSuE1QDbOAB6YplzEAgAAZg4A=
Date:   Wed, 3 Apr 2019 02:07:43 +0000
Message-ID: <5c89f28600b3336bc2545fdd80a64f7fd13df05e.camel@hammerspace.com>
References: <20190402231448.27743-1-trond.myklebust@hammerspace.com>
         <20190403003619.GA11222@parsley.fieldses.org>
In-Reply-To: <20190403003619.GA11222@parsley.fieldses.org>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [63.235.104.78]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 185846fe-58d5-4c8d-9706-08d6b7d928f5
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600139)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:SN6PR13MB2319;
x-ms-traffictypediagnostic: SN6PR13MB2319:
x-microsoft-antispam-prvs: <SN6PR13MB231917E93F38009986C8FEEDB8570@SN6PR13MB2319.namprd13.prod.outlook.com>
x-forefront-prvs: 0996D1900D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(396003)(136003)(39830400003)(366004)(376002)(199004)(189003)(229853002)(476003)(68736007)(446003)(11346002)(97736004)(6246003)(4326008)(2616005)(6512007)(486006)(53936002)(305945005)(6486002)(5660300002)(6436002)(5640700003)(76176011)(478600001)(186003)(3846002)(14454004)(6506007)(36756003)(26005)(102836004)(6116002)(86362001)(71190400001)(14444005)(256004)(118296001)(66066001)(2501003)(71200400001)(2906002)(106356001)(8936002)(8676002)(7736002)(25786009)(2351001)(99286004)(6916009)(81166006)(105586002)(1730700003)(316002)(81156014);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2319;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: MQOERngtZ/fBB1nL09hwu4cjhdT/fb0+pQWfv5luK1v2Kw+vIFDhrbxhQEoxhGq5HLwqX6mz8dST4xBVBxjHf/g3TXBaHCe/94YkHaDtdWNDCEf7bNJslFn0r5tk1HkqZIZ3UKIqZNvzs/85gmfMmfSdy2rBL15AGY5tsEY3JEvGMNUSA+i13hiTn553/n1TGogckySbelhpQRAm1frgHg/tV7BjytNRlZSICl+b8qgWLNCMBhybyWz023vSEUr5vTP7DNmjRZiIhzyAN38GtV5unhvziaWLnn9r69x8DNBXtrsTa/vVxOb9vW03Zw6T3/T/Uy5xrLedlatKhRa5lAQf7RDZ1TuteYAUCmPwJ4UKH5aFZCPxXEOvO+KAd+tWYQqdnb/fybfLkhEJp0YnH8xg+WbsbTZo9Tc8wbJaTSg=
Content-Type: text/plain; charset="utf-8"
Content-ID: <39E0C351A0A7614EB8036E01F2BAC2D2@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 185846fe-58d5-4c8d-9706-08d6b7d928f5
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Apr 2019 02:07:44.0792
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2319
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE5LTA0LTAyIGF0IDIwOjM2IC0wNDAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6
DQo+IE9uIFR1ZSwgQXByIDAyLCAyMDE5IGF0IDA0OjE0OjQyUE0gLTA3MDAsIFRyb25kIE15a2xl
YnVzdCB3cm90ZToNCj4gPiBUaGUgY3VycmVudCBrbmZzZCBpbXBsZW1lbnRhdGlvbiBpcyB1bmFi
bGUgdG8gc3VwcG9ydCBjb250YWluZXJzDQo+ID4gdGhhdA0KPiA+IHdhbnQgdG8gcnVuIGRpZmZl
cmVudCBjb21iaW5hdGlvbnMgb2YgTkZTIHZlcnNpb25zLiBUaGlzIGlzIGJlY2F1c2UNCj4gPiBv
Zg0KPiA+IHRoZSB3YXkgd2UgZGVmaW5lIHdoaWNoIHZlcnNpb25zIGFyZSBzdXBwb3J0ZWQ6IGJ5
IGRpcmVjdGx5IGVkaXRpbmcNCj4gPiB0aGUNCj4gPiBnbG9iYWwgdmVyc2lvbiB0YWJsZSBpbiAn
bmZzZF9wcm9ncmFtJy4NCj4gPiBUaGUgZm9sbG93aW5nIHBhdGNoIHNldCBtb2RpZmllcyB0aGUg
bWV0aG9kIHVzZWQgdG8gZGVmaW5lIHZlcnNpb24NCj4gPiBpbmZvcm1hdGlvbiBieSBtb3Zpbmcg
c29tZSBvZiB0aGUgc2VydmVyIFJQQyByZXF1ZXN0IGluaXRpYWxpc2F0aW9uDQo+ID4gZG93biBp
bnRvIGtuZnNkIGl0c2VsZiwgYWxsb3dpbmcgaXQgdG8gbWFuYWdlIHRoZSB2ZXJzaW9uLXNwZWNp
ZmljDQo+ID4gaW5pdGlhbGlzYXRpb24uDQo+IA0KPiBTb3VuZHMgZmluZSwgdGhvdWdoIEknbSBj
dXJpb3VzIHdoYXQgdGhlIG1vdGl2YXRpb24gaXMuDQo+IA0KPiBJIGFzc3VtZSB0aGUgY3VycmVu
dCBiZWhhdmlvciBpcyB0aGF0IHNldHRpbmcgdmVyc2lvbnMgZnJvbSBhbnkNCj4gY29udGFpbmVy
IHNldHMgdGhlbSBnbG9iYWxseSAocmF0aGVyIHRoYW4gZXJyb3Jpbmcgb3V0IG9yIHNvbWV0aGlu
ZyktDQo+IC1zbw0KPiBpcyB0aGVyZSBhbnkgd2F5IHNvbWUgY2FuIGRldGVjdCB3aGV0aGVyIHRo
ZXkndmUgZ290IHRoZSBuZXcgYmVoYXZpb3INCj4gb3RoZXIgdGhhbiB0cnlpbmcgaXQgYW5kIHNl
ZWluZyB3aGF0IHRoZSByZXN1bHQgaXMgaW4gYW5vdGhlcg0KPiBjb250YWluZXI/DQo+IA0KDQpU
aGUgbWFpbiBtb3RpdmF0aW9uIGlzIHRvIGFsbG93IGtuZnNkIHRvIHdvcmsgaW4gYSBjb250YWlu
ZXIsIGp1c3QgbGlrZQ0KaXQgd291bGQgaW4gYSBWTS4NCg0KV2UgaGF2ZSBhbiBhcHBsaWNhdGlv
biB3aGVyZSB3ZSB3YW50IHRvIGV4cG9ydCB0d28gZGlmZmVyZW50IHNldHMgb2YNCmZpbGVzeXN0
ZW1zIG9uIHRoZSBzYW1lIGhvc3QsIGJ1dCB3ZSB3YW50IHRvIGV4cG9ydCB0aGUgZmlyc3Qgc2V0
IG9mDQpmaWxlc3lzdGVtcyBhcyBORlN2MyBvbmx5LCBhbmQgdGhlIHNlY29uZCBhcyBORlN2MytO
RlN2NC54LiBXZSBjb3VsZA0KcG90ZW50aWFsbHkgZG8gdGhpcyBieSBleHRlbmRpbmcgdGhlIGV4
cG9ydCBmaWxlIHN5bnRheCwgYnV0IHdoeSBkbw0KdGhhdCB3aGVuIHlvdSBjYW4gYWNoaWV2ZSB0
aGUgc2FtZSByZXN1bHQganVzdCBieSBmaXhpbmcgY29udGFpbmVycyB0bw0Kd29yayBhcyBleHBl
Y3RlZD8NCg0KPiAtLWIuDQo+IA0KPiA+IE5vdGUgdGhhdCB3ZSBtaWdodCB3YW50IHRvIGNvbnNp
ZGVyIGEgZmV3IGZvbGxvdyB1cHMgdG8gdGhpcw0KPiA+IHBhdGNoc2V0DQo+ID4gdG8gZ2V0IHJp
ZCBvZiBzb21lIG9mIHRoZSB2ZXJzaW9uLXNwZWNpZmljIGZsYWdzIChlLmcuIHZzX2hpZGRlbikN
Cj4gPiB0aGF0DQo+ID4gY3VycmVudGx5IG5lZWQgdG8gYmUgbWFuYWdlZCBpbiB0aGUgZ2VuZXJp
YyBTVU5SUEMgc2VydmVyIGNvZGUgb24NCj4gPiBiZWhhbGYNCj4gPiBvZiBqdXN0IG9uZSBvciB0
d28gUlBDIHByb2dyYW1zLiBUaGVzZSBmbGFncyBjYW4gZWFzaWx5IGJ5IHJlcGxhY2VkDQo+ID4g
YnkNCj4gPiBjdXN0b20gUlBDIHJlcXVlc3QgaW5pdGlhbGlzZXJzLg0KPiA+IA0KPiA+IFRyb25k
IE15a2xlYnVzdCAoNik6DQo+ID4gICBTVU5SUEMvbmZzOiBGaXggcmV0dXJuIHZhbHVlIGZvciBu
ZnM0X2NhbGxiYWNrX2NvbXBvdW5kKCkNCj4gPiAgIFNVTlJQQzogQWRkIGEgY2FsbGJhY2sgdG8g
aW5pdGlhbGlzZSBzZXJ2ZXIgcmVxdWVzdHMNCj4gPiAgIFNVTlJQQzogQ2xlYW4gdXAgZ2VuZXJp
YyBkaXNwYXRjaGVyIGNvZGUNCj4gPiAgIFNVTlJQQzogQWxsb3cgZnVydGhlciBjdXN0b21pc2F0
aW9uIG9mIFJQQyBwcm9ncmFtIHJlZ2lzdHJhdGlvbg0KPiA+ICAgbmZzZDogQWRkIGN1c3RvbSBy
cGNiaW5kIGNhbGxiYWNrcyBmb3Iga25mc2QNCj4gPiAgIG5mc2Q6IEFsbG93IGNvbnRhaW5lcnMg
dG8gc2V0IHN1cHBvcnRlZCBuZnMgdmVyc2lvbnMNCj4gPiANCj4gPiAgZnMvbG9ja2Qvc3ZjLmMg
ICAgICAgICAgICAgfCAgIDQgKy0NCj4gPiAgZnMvbmZzL2NhbGxiYWNrLmMgICAgICAgICAgfCAg
IDIgKw0KPiA+ICBmcy9uZnMvY2FsbGJhY2tfeGRyLmMgICAgICB8ICAgMiArLQ0KPiA+ICBmcy9u
ZnNkL25ldG5zLmggICAgICAgICAgICB8ICAgOCArDQo+ID4gIGZzL25mc2QvbmZzNHByb2MuYyAg
ICAgICAgIHwgICAzICstDQo+ID4gIGZzL25mc2QvbmZzY3RsLmMgICAgICAgICAgIHwgIDI1ICst
LQ0KPiA+ICBmcy9uZnNkL25mc2QuaCAgICAgICAgICAgICB8ICAgOCArLQ0KPiA+ICBmcy9uZnNk
L25mc3N2Yy5jICAgICAgICAgICB8IDI1MSArKysrKysrKysrKysrKysrKysrKysrKysrLS0tLS0N
Cj4gPiAgaW5jbHVkZS9saW51eC9zdW5ycGMvc3ZjLmggfCAgMzMgKysrKw0KPiA+ICBuZXQvc3Vu
cnBjL3N2Yy5jICAgICAgICAgICB8IDMxMCArKysrKysrKysrKysrKysrKysrKysrKystLS0tLS0t
LS0NCj4gPiAtLS0tDQo+ID4gIDEwIGZpbGVzIGNoYW5nZWQsIDQ4MCBpbnNlcnRpb25zKCspLCAx
NjYgZGVsZXRpb25zKC0pDQo+ID4gDQo+ID4gLS0gDQo+ID4gMi4yMC4xDQo+ID4gDQotLSANClRy
b25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0K
dHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
