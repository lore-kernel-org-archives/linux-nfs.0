Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6F33C04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 17:15:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 533A520848
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 17:15:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="KyCzum59"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 533A520848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726855AbeLCRPR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 12:15:17 -0500
Received: from mail-eopbgr740127.outbound.protection.outlook.com ([40.107.74.127]:46976
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726814AbeLCRPQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Dec 2018 12:15:16 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=C6Nfv43oNSbDUV5jYI7EaGa7h8uZKlwi9TizRscdHBc=;
 b=KyCzum59JL0NeB/I9B1AGx4dBwY4JmL8km0bq80SitTpMz0CalMsdgBMDPGXIK4wGn2/sOMso3jTaxFPRxnkXK3AfbvhrehRoLBpnKaD9++2lmhTmUPGubrM9+j/+NnfiFzQXvgohlXC3M9rvjBHpQSBIexziHPbpW6c4e2SiqM=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2493.namprd13.prod.outlook.com (52.135.95.147) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1404.11; Mon, 3 Dec 2018 17:15:11 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1404.016; Mon, 3 Dec 2018
 17:15:11 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Fix a potential race in xprt_connect()
Thread-Topic: [PATCH] SUNRPC: Fix a potential race in xprt_connect()
Thread-Index: AQHUik1oMF03twklr0CrKFvNFhpg7qVrrkwAgAAFVYCAAXlFgIAAFfoA
Date:   Mon, 3 Dec 2018 17:15:11 +0000
Message-ID: <3ee22a93e7ac2853605ff6833af76a59bb5516c3.camel@hammerspace.com>
References: <20181202144223.42562-1-trond.myklebust@hammerspace.com>
         <4BAC007E-35BE-423B-BA11-5413D0EEDDBD@oracle.com>
         <fdb18aece66221c91c0f8ce4e0a7849bc60505fc.camel@hammerspace.com>
         <8D79F3BF-74BE-418A-85A8-7E8AF508B0AE@oracle.com>
In-Reply-To: <8D79F3BF-74BE-418A-85A8-7E8AF508B0AE@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2493;6:m12FtsfZbNIOC7G7VMKMcgXT7sAx2BWXP6v7kPkbpx6yeACllX/7qPIGRvijZqbEBewUcxCL9NHyESDCxSbOV8O3e2l59o4esDllwMRbj/PEvypIPbr7Pt3ee0SEYunuZwAu8Nk6vI33BukHYST0wa9rHrQ36aTPdyTVHlBCi31AmtfBK2pEWo1L4wDNwBIv+ATtbts+srRVAAb2GjbOoqA7a6i+dDrouG5//j/BouPQ6zVnriRSFf+y+2xEDFYYhzb5Kn4N8q0JTFxDn497FXIAg5BazDTTsD0XSKnY/gjy3j1I2m2S2AUN7scOjM3vvFCwMIhPKardbCFjojzdZZGkXFJGpEBIw7r6nPIYSEw724nCbDya4odxQec0LZGxYVU8sqUnCntjbw/9b7FP39i0I7/oDoz6PnKg0iOyFXUGDjYZZRXif6k4tYaOqiT+wyGo2I+aenLwdpthXau92A==;5:SVTvTmNNQuH8l1DIJQ+Skgo92+PFuXiBjsB4BPt8iZ+V31+xV96bFZwB8qn3vpqeCrQwyGE7ogfKjo3q7cVSvG77qCgP3AUooWv3qgHWs6Ji8nFPOhmBHP+uOnrRaFGoUcl8R4HYmhEONzNTUj5pUT6tK5uh2w5ovkuIUl5m3/8=;7:izP+GEjqfGyEguBqJvTaf2CdFlgYFSqYApJBg2L51tWFTsX0jOHIbs1aAtAcO9/xN8KJ5SMkhTaL2nLwlC0UaIDL1N09Vz42+UuVm2pAvtM42ehHuqirJECNzR3PWszCvRlmd0F/EqcyxvTs3tuTBg==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 1feab7b6-69b5-4f40-40ed-08d65942e222
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2493;
x-ms-traffictypediagnostic: SN6PR13MB2493:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-prvs: <SN6PR13MB24938588674AD5739CC8EE4CB8AE0@SN6PR13MB2493.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(8121501046)(5005006)(10201501046)(3002001)(3231455)(999002)(944501493)(52105112)(93006095)(93001095)(148016)(149066)(150057)(6041310)(20161123558120)(20161123564045)(20161123560045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123562045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2493;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2493;
x-forefront-prvs: 08756AC3C8
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39830400003)(366004)(396003)(136003)(376002)(346002)(189003)(199004)(8936002)(6512007)(102836004)(81156014)(53936002)(81166006)(6436002)(8676002)(106356001)(118296001)(6916009)(68736007)(229853002)(105586002)(86362001)(2351001)(6486002)(2906002)(5660300001)(5640700003)(478600001)(7736002)(305945005)(14444005)(93886005)(256004)(97736004)(6246003)(14454004)(26005)(486006)(186003)(446003)(66066001)(476003)(36756003)(4326008)(6116002)(25786009)(3846002)(2616005)(2501003)(316002)(76176011)(11346002)(99286004)(71200400001)(53546011)(6506007)(71190400001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2493;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: 7mBpw7JEsKmFnc8NQ7vfFt05wZZc4inwn6VTKKmL7Qp9QjL1n1uQuDRubbExAlurzl/f1Cu7/4mH6tWT1icyr9QGsK20hV2BjVhe3AUoZlmajJwZ+PK2mhBr2ZdciLUW/33f5rm9VTYYpkKlKz61Axrxq9HclT0ANmdMOm5CpCZkpFy7TvO08DTPdnJsx8L2yfvKgE34Hzq+vSzMNlh2H8fvjjvyD77laStzE93csgYtxnC+SSNLNAcLa6eUAb1KO9Kk0uFPQQnHmN0nrEeyR4yn8TXaNDqUZifWzN5EyjD8cleA21RjmoYRHq+DZXUXs5gn84sAJbPo+Z+/GfEK1CmrrvsKF8jHrSHUAYjY8o8=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <A31F355DC561DC478055090DE8758906@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 1feab7b6-69b5-4f40-40ed-08d65942e222
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Dec 2018 17:15:11.4622
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2493
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE4LTEyLTAzIGF0IDEwOjU2IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBEZWMgMiwgMjAxOCwgYXQgMTI6MjYgUE0sIFRyb25kIE15a2xlYnVzdCA8dHJvbmRteUBn
bWFpbC5jb20+DQo+ID4gd3JvdGU6DQo+ID4gDQo+ID4gT24gU3VuLCAyMDE4LTEyLTAyIGF0IDEy
OjA3IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4gPiA+IFRlc3QgcmVwb3J0Lg0KPiA+ID4g
DQo+ID4gPiBJIGFwcGxpZWQgdGhpcyBvbiB0b3Agb2YgdGhlIHRocmVlIHY0IHBhdGNoZXMgZnJv
bSBGcmlkYXkuDQo+ID4gPiANCj4gPiA+IFdpdGggVENQLCBJIG5vIGxvbmdlciBzZWUgdGhlIHNv
ZnQgSVJRIHdhcm5pbmdzIG9yIGJkZXYgbGVha3MuDQo+ID4gPiBIb3dldmVyLCBhdCBzb21lIHBv
aW50IGR1cmluZyBteSB0ZXN0IChzZWM9a3JiNXAsdmVycz0zKSB0aGUNCj4gPiA+IG1vdW50IHN0
b3BzIHJlc3BvbmRpbmcgYW5kIHRoZSBjbGllbnQgYmVjb21lcyBpZGxlLiBeQyBsZWF2ZXMNCj4g
PiA+IHRoZSBpb3pvbmUgcHJvY2Vzc2VzIGluIEQgc3RhdGUuDQo+ID4gDQo+ID4gRG9lcyAvcHJv
Yy8qL3N0YWNrIHNob3cgYW55IHRhc2tzIHdpdGggYW55IGludGVyZXN0aW5nIHN0YWNrDQo+ID4g
YmVoYXZpb3VyPw0KPiA+IA0KPiA+ID4gV2l0aCBSRE1BLCBJIGNhbiBzZWUgYSBmZXcgaXNzdWVz
Og0KPiA+ID4gLSBBIGxvdCBvZiAtNzQgYW5kIHNlcnZlciBkaXNjb25uZWN0cy4gSSBzdXNwZWN0
IHRoaXMgaXMgZHVlDQo+ID4gPiAgIHRvIEdTUyBzZXF1ZW5jZSB3aW5kb3cgb3ZlcnJ1bnMNCj4g
PiA+IC0geHBydF9jb25uZWN0IHB1dHMgdGhlIGNhbGxpbmcgdGFzayB0byBzbGVlcCBpZiB0aGUg
Y3JlZGl0DQo+ID4gPiAgIGxpbWl0IGhhcyBiZWVuIHJlYWNoZWQsIGFuZCB0aGF0IGNhbiByZXN1
bHQgaW4gYSBkZWFkbG9jaw0KPiA+ID4gLSBUaGUgcmVjb25uZWN0IGxvZ2ljIGFwcGVhcnMgdG8g
YnVzeS13YWl0IHVudGlsIHNvbWV0aGluZw0KPiA+ID4gICBlbHNlIChlZywgYW4gUlRPKSBmb3Jj
ZXMgYSByZWNvbm5lY3QNCj4gPiA+IC0gQSBjb25uZWN0IG9yIGRpc2Nvbm5lY3Qgd2FrZS11cCB0
aGF0IG9jY3VycyB3aGlsZSBhbiBSUEMNCj4gPiA+ICAgcmVwbHkgaXMgYmVpbmcgaGFuZGxlZCAo
aWUsIGlzIHN0aWxsIG9uIHhwcnQtPnBlbmRpbmcpDQo+ID4gPiAgIHJlc3VsdHMgaW4gdGhhdCBS
UEMgYmVpbmcgcmV0cmllZCB1bm5lY2Vzc2FyaWx5Lg0KPiA+ID4gDQo+ID4gPiBJJ20gbm90IHN1
cmUgaG93IHRvIGFkZHJlc3MgdGhhdCBsYXN0IG9uZS4gU29tZXRpbWVzIFJETUEgaGFzDQo+ID4g
PiB0byBpbnZhbGlkYXRlIE1ScywgYW5kIHRoYXQgaW52b2x2ZXMgYSB3YWl0L2NvbnRleHQgc3dp
dGggd2hpY2gNCj4gPiA+IG9wZW5zIHRoZSByYWNlIHdpbmRvdyBzaWduaWZpY2FudGx5Lg0KPiA+
IA0KPiA+IEluIHByaW5jaXBsZSB0aGUgbGF0dGVyIGlzc3VlIGlzIHN1cHBvc2VkIHRvIGJlIGhh
bmRsZWQgYnkgdGhlDQo+ID4gY29ubmVjdA0KPiA+IGNvb2tpZXMuIEFyZSB0aGUgdXBkYXRlcyBw
ZXJoYXBzIGJlaW5nIG9yZGVyZWQgaW5jb3JyZWN0bHkgdy5yLnQuDQo+ID4gdGhlDQo+ID4geHBy
dC0+cGVuZGluZyB3YWtldXA/IElmIHNvLCB0aGVuIHRoYXQgY291bGQgY2F1c2UgcmFjZXMuDQo+
ID4gDQo+ID4gSSdkIGV4cGVjdCB0aGUgY29va2llIHdvdWxkIG5lZWQgdG8gYmUgdXBkYXRlZCBi
ZWZvcmUgdGhlIGNhbGwgdG8NCj4gPiB4cHJ0LQ0KPiA+IHBlbmRpbmcgYm90aCBvbiBjb25uZWN0
IGFuZCBkaXNjb25uZWN0Lg0KPiANCj4gSSd2ZSBmb3VuZCBvbmUgcGVjdWxpYXIgY29va2llLXJl
bGF0ZWQgYmVoYXZpb3IuDQo+IA0KPiBBdCBzb21lIHBvaW50LCB4cHJ0X3JlcXVlc3RfcmV0cmFu
c21pdF9hZnRlcl9kaXNjb25uZWN0KCkgc3RhcnRzDQo+IHRvIGNsYWltIHRoYXQgYWxsIHJlcXVl
c3RzIGhhdmUgdG8gYmUgcmV0cmFuc21pdHRlZCBhbmQgdGhhdCB0aGUNCj4gY29ubmVjdGlvbiBp
cyBjbG9zZWQuIENsb3NlciBpbnNwZWN0aW9uIHNob3dzIHRoYXQgdGhlIGNvb2tpZQ0KPiBjaGVj
ayBoZXJlIGlzIGZhaWxpbmcgYmVjYXVzZSBpdCBzZWVtcyB0byBiZSB0ZXN0aW5nIGEgcmVxdWVz
dA0KPiB0aGF0IGhhc24ndCBiZWVuIHRyYW5zbWl0dGVkIHlldC4NCg0KUmlnaHQsIGJ1dCBhcyBm
YXIgYXMgdGhlIHRyYW5zcG9ydCBsYXllciBpcyBjb25jZXJuZWQsIHRoZXJlIHNob3VsZCBiZQ0K
bm8gZGlmZmVyZW5jZSBiZXR3ZWVuICduZWVkIHRyYW5zbWl0JyBhbmQgJ25lZWQgcmV0cmFuc21p
dCcuIEl0IGlzIHVwDQp0byB0aGUgaGlnaGVyIFJQQyBjbGllbnQgbGF5ZXIgdG8gZGVjaWRlIHdo
ZXRoZXIgb3Igbm90IHRoZXJlIGlzIGENCnBvbGljeSBkaWZmZXJlbmNlIGluIGJlaGF2aW91ciwg
YW5kIEFGQUlDUyBycGNfdGFza19uZWVkX2VuY29kZSgpDQpzaG91bGQgYmUgZG9pbmcgdGhlIHJp
Z2h0IHRoaW5nLg0KDQo+ID4gPiA+IE9uIERlYyAyLCAyMDE4LCBhdCA5OjQyIEFNLCBUcm9uZCBN
eWtsZWJ1c3QgPHRyb25kbXlAZ21haWwuY29tPg0KPiA+ID4gPiB3cm90ZToNCj4gPiA+ID4gDQo+
ID4gPiA+IElmIGFuIGFzeW5jaHJvbm91cyBjb25uZWN0aW9uIGF0dGVtcHQgY29tcGxldGVzIHdo
aWxlIGFub3RoZXINCj4gPiA+ID4gdGFzaw0KPiA+ID4gPiBpcw0KPiA+ID4gPiBpbiB4cHJ0X2Nv
bm5lY3QoKSwgdGhlbiB0aGUgY2FsbCB0byBycGNfc2xlZXBfb24oKSBjb3VsZCBlbmQgdXANCj4g
PiA+ID4gcmFjaW5nIHdpdGggdGhlIGNhbGwgdG8geHBydF93YWtlX3BlbmRpbmdfdGFza3MoKS4N
Cj4gPiA+ID4gU28gYWRkIGEgc2Vjb25kIHRlc3Qgb2YgdGhlIGNvbm5lY3Rpb24gc3RhdGUgYWZ0
ZXIgd2UndmUgcHV0DQo+ID4gPiA+IHRoZQ0KPiA+ID4gPiB0YXNrIHRvIHNsZWVwIGFuZCBzZXQg
dGhlIFhQUlRfQ09OTkVDVElORyBmbGFnLCB3aGVuIHdlIGtub3cNCj4gPiA+ID4gdGhhdA0KPiA+
ID4gPiB0aGVyZQ0KPiA+ID4gPiBjYW4gYmUgbm8gYXN5bmNocm9ub3VzIGNvbm5lY3Rpb24gYXR0
ZW1wdHMgc3RpbGwgaW4gcHJvZ3Jlc3MuDQo+ID4gPiA+IA0KPiA+ID4gPiBGaXhlczogMGI5ZTc5
NDMxMzc3ZCAoIlNVTlJQQzogTW92ZSB0aGUgdGVzdCBmb3INCj4gPiA+ID4gWFBSVF9DT05ORUNU
SU5HDQo+ID4gPiA+IGludG8uLi4iKQ0KPiA+ID4gPiBTaWduZWQtb2ZmLWJ5OiBUcm9uZCBNeWts
ZWJ1c3QgPHRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCj4gPiA+ID4gPg0KPiA+ID4g
PiAtLS0NCj4gPiA+ID4gbmV0L3N1bnJwYy94cHJ0LmMgfCAxMSArKysrKysrKystLQ0KPiA+ID4g
PiAxIGZpbGUgY2hhbmdlZCwgOSBpbnNlcnRpb25zKCspLCAyIGRlbGV0aW9ucygtKQ0KPiA+ID4g
PiANCj4gPiA+ID4gZGlmZiAtLWdpdCBhL25ldC9zdW5ycGMveHBydC5jIGIvbmV0L3N1bnJwYy94
cHJ0LmMNCj4gPiA+ID4gaW5kZXggMTIyYzkxYzI4ZTdjLi5jZTkyNzAwMjg2MmEgMTAwNjQ0DQo+
ID4gPiA+IC0tLSBhL25ldC9zdW5ycGMveHBydC5jDQo+ID4gPiA+ICsrKyBiL25ldC9zdW5ycGMv
eHBydC5jDQo+ID4gPiA+IEBAIC04MjYsOCArODI2LDE1IEBAIHZvaWQgeHBydF9jb25uZWN0KHN0
cnVjdCBycGNfdGFzayAqdGFzaykNCj4gPiA+ID4gCQkJcmV0dXJuOw0KPiA+ID4gPiAJCWlmICh4
cHJ0X3Rlc3RfYW5kX3NldF9jb25uZWN0aW5nKHhwcnQpKQ0KPiA+ID4gPiAJCQlyZXR1cm47DQo+
ID4gPiA+IC0JCXhwcnQtPnN0YXQuY29ubmVjdF9zdGFydCA9IGppZmZpZXM7DQo+ID4gPiA+IC0J
CXhwcnQtPm9wcy0+Y29ubmVjdCh4cHJ0LCB0YXNrKTsNCj4gPiA+ID4gKwkJLyogUmFjZSBicmVh
a2VyICovDQo+ID4gPiA+ICsJCWlmICgheHBydF9jb25uZWN0ZWQoeHBydCkpIHsNCj4gPiA+ID4g
KwkJCXhwcnQtPnN0YXQuY29ubmVjdF9zdGFydCA9IGppZmZpZXM7DQo+ID4gPiA+ICsJCQl4cHJ0
LT5vcHMtPmNvbm5lY3QoeHBydCwgdGFzayk7DQo+ID4gPiA+ICsJCX0gZWxzZSB7DQo+ID4gPiA+
ICsJCQl4cHJ0X2NsZWFyX2Nvbm5lY3RpbmcoeHBydCk7DQo+ID4gPiA+ICsJCQl0YXNrLT50a19z
dGF0dXMgPSAwOw0KPiA+ID4gPiArCQkJcnBjX3dha2VfdXBfcXVldWVkX3Rhc2soJnhwcnQtPnBl
bmRpbmcsIA0KPiA+ID4gPiB0YXNrKTsNCj4gPiA+ID4gKwkJfQ0KPiA+ID4gPiAJfQ0KPiA+ID4g
PiAJeHBydF9yZWxlYXNlX3dyaXRlKHhwcnQsIHRhc2spOw0KPiA+ID4gPiB9DQo+ID4gPiA+IC0t
IA0KPiA+ID4gPiAyLjE5LjINCj4gPiA+ID4gDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXgg
TkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1l
cnNwYWNlLmNvbQ0KDQoNCg==
