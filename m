Return-Path: <SRS0=NEh4=OI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 186ABC43441
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 19:56:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A6A0B21104
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 19:56:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="BINfCx1e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6A0B21104
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726725AbeK3HCq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Nov 2018 02:02:46 -0500
Received: from mail-eopbgr710119.outbound.protection.outlook.com ([40.107.71.119]:6209
        "EHLO NAM05-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726207AbeK3HCp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Nov 2018 02:02:45 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=W/EYdk2EaxW/rYIoK9h4i1K8i9NSiQOK1wF38R26eMw=;
 b=BINfCx1eWDHp3sU+R+GnX+Ll2MlQqkVZc7bEPfIo2LLpZS+yakqZx5Vkv/ngsZiKzpv6DzZZcxo554y/DIwCkMFjFBaPbPiqHNxcsGOFq1l6YorNybt3jzKdpuFGy0msfQPj9MM+gfd4paQg6PaDzYw+XRwmvasO1w8dXwMoG4k=
Received: from BYAPR13MB2486.namprd13.prod.outlook.com (52.135.230.12) by
 BYAPR13MB2309.namprd13.prod.outlook.com (52.135.229.15) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1382.7; Thu, 29 Nov 2018 19:56:06 +0000
Received: from BYAPR13MB2486.namprd13.prod.outlook.com
 ([fe80::4c50:319e:6ba0:dfb7]) by BYAPR13MB2486.namprd13.prod.outlook.com
 ([fe80::4c50:319e:6ba0:dfb7%4]) with mapi id 15.20.1382.017; Thu, 29 Nov 2018
 19:56:06 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "cristian.marussi@arm.com" <cristian.marussi@arm.com>,
        "catalin.marinas@arm.com" <catalin.marinas@arm.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 40/44] SUNRPC: Simplify TCP receive code by switching
 to using iterators
Thread-Topic: [PATCH v3 40/44] SUNRPC: Simplify TCP receive code by switching
 to using iterators
Thread-Index: AQHUTocCwahWu1c0eEqSYU1l+AHxY6VHnxwAgB/3VYCAAAefAA==
Date:   Thu, 29 Nov 2018 19:56:06 +0000
Message-ID: <356631f8d49b5d0698d769ab9c916c84fadd3be6.camel@hammerspace.com>
References: <20180917130335.112832-32-trond.myklebust@hammerspace.com>
         <20180917130335.112832-33-trond.myklebust@hammerspace.com>
         <20180917130335.112832-34-trond.myklebust@hammerspace.com>
         <20180917130335.112832-35-trond.myklebust@hammerspace.com>
         <20180917130335.112832-36-trond.myklebust@hammerspace.com>
         <20180917130335.112832-37-trond.myklebust@hammerspace.com>
         <20180917130335.112832-38-trond.myklebust@hammerspace.com>
         <20180917130335.112832-39-trond.myklebust@hammerspace.com>
         <20180917130335.112832-40-trond.myklebust@hammerspace.com>
         <20180917130335.112832-41-trond.myklebust@hammerspace.com>
         <20181109111930.idve77thgcnsg5u3@localhost>
         <e85fe63f-b142-5075-edb6-da6c9e2609fd@arm.com>
In-Reply-To: <e85fe63f-b142-5075-edb6-da6c9e2609fd@arm.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;BYAPR13MB2309;6:jM+tydVZPoDBr/dChBqOGuEc/5Smbff2TOjYXXXOs3Nf72elxjXDnjuYa15clZsfMh8mMtobTm+xoqj5BvPJgH/vWSJGqZxJUoogqqFaOhWwARocVYvHeXQpZC3zkwzfA1C8uD2UNC/RzPtEUPM1LLRLkm5gMTOiy9jdDJCSSrU38zCJTmNOxXpNIC1beumXPl3ZMiTUDJfexa02t4Zrr0wq0S/CWd4o1ETBlcADqyI8dn1Nyokoi+1aD6bGRoa+d7h2Pm51k9bFfJW1OR3gZ6mcDFVGcVJSFN1jPIKRe2lTe5z0SVVp5vS42KZM86zGRUK7Zt7Ed3Gb4bbtMhtOzg3z6iMjOc/ITDvBL1kNKpP8ktkFOt6vWIROAMskyWz33+6enszGK1jhjVmIfW0WlH2Ry8uCrCoibQVGVsYRcXDHzCTAuv40Fd43sPOcuqiBwzPaVut4m4YpKFgezQHU+Q==;5:YXmHz3VnPMfeWbwnt7xQM3UQGPrzHIhrx8bzGrIfxDd7btOjrF+iWypJEDAyfJDSX7iGvof7oWhwKLticV6BK/tXxja0hYjny/ttMeN1eJIWp+PM0++C8aeKPTpIyB5sQ/OISpXgAON9qzCfXkUCRzhvChHd47XTOJD9WVzO71s=;7:c+bbyNprdQtV5yhMVRdqpf/xCwv2pPsPKIlvinJo5BESMTSeZsI9h2yq7j2RCjq22BGzWaP5H4h6Rfl5JlwoScMXLijosrmK8hkhstUwSM/lfrbnVZsTZyEeZpDhXE7mW8iqdVO1Hy4Tn3gtOL8GEQ==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: fb804d45-e42f-4269-b971-08d65634b359
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:BYAPR13MB2309;
x-ms-traffictypediagnostic: BYAPR13MB2309:
x-microsoft-antispam-prvs: <BYAPR13MB23097E96B2CA979F91775494B8D20@BYAPR13MB2309.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(8121501046)(5005006)(10201501046)(3002001)(3231453)(999002)(944501410)(52105112)(93006095)(93001095)(148016)(149066)(150057)(6041310)(20161123562045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123560045)(20161123558120)(20161123564045)(201708071742011)(7699051)(76991095);SRVR:BYAPR13MB2309;BCL:0;PCL:0;RULEID:;SRVR:BYAPR13MB2309;
x-forefront-prvs: 0871917CDA
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(396003)(136003)(346002)(39830400003)(366004)(199004)(189003)(6486002)(76176011)(68736007)(229853002)(53546011)(6506007)(14454004)(118296001)(256004)(316002)(66066001)(81156014)(186003)(3846002)(6116002)(71190400001)(71200400001)(81166006)(8676002)(8936002)(26005)(6512007)(53936002)(6246003)(6436002)(99286004)(478600001)(36756003)(305945005)(93886005)(7736002)(102836004)(4326008)(11346002)(486006)(446003)(476003)(2616005)(4001150100001)(105586002)(25786009)(97736004)(5660300001)(106356001)(2501003)(110136005)(2906002)(86362001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR13MB2309;H:BYAPR13MB2486.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: UEY4m9a2/X5IyCTMj50EupM7JOWbnuzi47XGzMiOYdVEHfs0+5RIVEPoghGSoeSgQ+0+2nCfwoTNMh+UJUeIINHHsv2JtsuURPZwo0rS2lWxNGKjTUSPeMAFkIRGAj0uxFXMBOVXkoQjzUr/EbG7hmypFwyxXQV9GFPiyalZWxFmJYY3XTGzc/X3UfGWVAEn08cNrVza3oqZCAdp36M09B/HC3b6Q6zMZQ02YLqnrSVQoCG7EPgms5LkgBYN7UnG7hdvRveoVojtEBm+PSpIukQCdAS+RU2yxdj9uqIfltp83/FbLFlnkYkimCPu5aqsfO1Y26MItGKEQUc2BOU7ND8Civo/Ri6/8DBOgt+YN5Q=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <BD6E052073E4034FAC4A49F49639A19F@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: fb804d45-e42f-4269-b971-08d65634b359
X-MS-Exchange-CrossTenant-originalarrivaltime: 29 Nov 2018 19:56:06.4892
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR13MB2309
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE4LTExLTI5IGF0IDE5OjI4ICswMDAwLCBDcmlzdGlhbiBNYXJ1c3NpIHdyb3Rl
Og0KPiBIaSBUcm9uZCwgQ2F0YWxpbg0KPiANCj4gT24gMDkvMTEvMjAxOCAxMToxOSwgQ2F0YWxp
biBNYXJpbmFzIHdyb3RlOg0KPiA+IEhpIFRyb25kLA0KPiA+IA0KPiA+IE9uIE1vbiwgU2VwIDE3
LCAyMDE4IGF0IDA5OjAzOjMxQU0gLTA0MDAsIFRyb25kIE15a2xlYnVzdCB3cm90ZToNCj4gPiA+
IE1vc3Qgb2YgdGhpcyBjb2RlIHNob3VsZCBhbHNvIGJlIHJldXNhYmxlIHdpdGggb3RoZXIgc29j
a2V0DQo+ID4gPiB0eXBlcy4NCj4gPiA+IA0KPiA+ID4gU2lnbmVkLW9mZi1ieTogVHJvbmQgTXlr
bGVidXN0IDx0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tPg0KPiA+ID4gLS0tDQo+ID4g
PiAgaW5jbHVkZS9saW51eC9zdW5ycGMveHBydHNvY2suaCB8ICAxOSArLQ0KPiA+ID4gIGluY2x1
ZGUvdHJhY2UvZXZlbnRzL3N1bnJwYy5oICAgfCAgMTUgKy0NCj4gPiA+ICBuZXQvc3VucnBjL3hw
cnRzb2NrLmMgICAgICAgICAgIHwgNjk0ICsrKysrKysrKysrKysrKy0tLS0tLS0tLS0tDQo+ID4g
PiAtLS0tLS0NCj4gPiA+ICAzIGZpbGVzIGNoYW5nZWQsIDMzNSBpbnNlcnRpb25zKCspLCAzOTMg
ZGVsZXRpb25zKC0pDQo+ID4gDQo+ID4gV2l0aCBsYXRlc3QgbWFpbmxpbmUgKDI0Y2NlYTdlMTAy
ZCwgaXQgaW5jbHVkZXMgQWwgVmlybydzIGlvdl9pdGVyDQo+ID4gZml4dXApIEkgc3RhcnRlZCBo
aXR0aW5nIHNvbWUgc2V2ZXJlIHNsb3dkb3duIGFuZCBzeXN0ZW1kIHRpbWVvdXRzDQo+ID4gd2l0
aA0KPiA+IG5mc3Jvb3Qgb24gYXJtNjQgbWFjaGluZXMgKHBoeXNpY2FsIG9yIGd1ZXN0cyB1bmRl
ciBLVk0pLg0KPiA+IEludGVyZXN0aW5nbHksDQo+ID4gaXQgb25seSBoYXBwZW5zIHdoZW4gdGhl
IGNsaWVudCBrZXJuZWwgaXMgY29uZmlndXJlZCB3aXRoIDY0Sw0KPiA+IHBhZ2VzLCB0aGUNCj4g
PiA0SyBwYWdlcyBjb25maWd1cmF0aW9uIHJ1bnMgZmluZS4gSXQgYWxzbyBydW5zIGZpbmUgaWYg
SSBhZGQNCj4gPiByc2l6ZT02NTUzNg0KPiA+IHRvIHRoZSBuZnNyb290PSBhcmd1bWVudC4NCj4g
PiANCj4gPiBCaXNlY3RpbmcgbGVkIG1lIHRvIGNvbW1pdCAyNzdlNGFiN2Q1MzAgKCJTVU5SUEM6
IFNpbXBsaWZ5IFRDUA0KPiA+IHJlY2VpdmUNCj4gPiBjb2RlIGJ5IHN3aXRjaGluZyB0byB1c2lu
ZyBpdGVyYXRvcnMiKS4gUHJpb3IgdG8gdGhpcyBjb21taXQsIGl0DQo+ID4gd29ya3MNCj4gPiBm
aW5lLg0KPiA+IA0KPiA+IFNvbWUgbW9yZSBpbmZvOg0KPiA+IA0KPiA+IC0gZGVmY29uZmlnIHdp
dGggQ09ORklHX0FSTTY0XzY0S19QQUdFUyBlbmFibGVkDQo+ID4gDQo+ID4gLSBrZXJuZWwgY21k
bGluZSBhcmc6IG5mc3Jvb3Q9PHNvbWUtc2VydmVyPjovc3J2L25mcy9kZWJpYW4tDQo+ID4gYXJt
NjQsdGNwLHY0DQo+ID4gDQo+ID4gLSBpZiBpdCBtYXR0ZXJzLCB0aGUgc2VydmVyIGlzIGFsc28g
YW4gYXJtNjQgbWFjaGluZSBydW5uaW5nIDQuMTkNCj4gPiB3aXRoDQo+ID4gICA0SyBwYWdlcyBj
b25maWd1cmF0aW9uDQo+ID4gDQoNClF1ZXN0aW9uIHRvIHlvdSBib3RoOiB3aGVuIHRoaXMgaGFw
cGVucywgZG9lcyAvcHJvYy8qL3N0YWNrIHNob3cgYW55IG9mDQp0aGUgcHJvY2Vzc2VzIGhhbmdp
bmcgaW4gdGhlIHNvY2tldCBvciBzdW5ycGMgY29kZT8gSWYgc28sIGNhbiB5b3UNCnBsZWFzZSBz
ZW5kIG1lIGV4YW1wbGVzIG9mIHRob3NlIHN0YWNrIHRyYWNlcyAoaS5lLiB0aGUgY29udGVudHMg
b2YNCi9wcm9jLzxwaWQ+L3N0YWNrIGZvciB0aGUgcHJvY2Vzc2VzIHRoYXQgYXJlIGhhbmdpbmcp
DQoNCkknZCBiZSBwYXJ0aWN1bGFybHkgaW50ZXJlc3RlZCAgaWYgdGhlIHByb2Nlc3NlcyBpbiBx
dWVzdGlvbiBhcmUNCnJlbGF0ZWQgdG8gdGhlIHJwY2lvZCB3b3JrcXVldWUuDQoNClRoYW5rcw0K
ICAgVHJvbmQNCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRh
aW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
