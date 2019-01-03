Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DABF5C43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 16:05:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7F1BD2070D
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 16:05:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="SkPC5P11"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731086AbfACQFh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 11:05:37 -0500
Received: from mail-eopbgr740119.outbound.protection.outlook.com ([40.107.74.119]:40112
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726760AbfACQFh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Jan 2019 11:05:37 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=K8y8+OxUgI3FyJI8Pvf/LCUxezaXkt2U0O4Ok53ScIw=;
 b=SkPC5P11G0IK0SH2RenIUH3b8G4TRixu01p3Mn/k2/EWl2A70iuTuDCRgAeh9Zz66IEkhA7ZRkeD3OXqj7egIkO0Jrpbv4XXiJWF7c44hCJz77MGaXvcMU3ms7XklKa8ZqqGcJaKao8zq2/QGVocOqksKal4E9lWvS+OO/6801o=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2319.namprd13.prod.outlook.com (52.135.94.26) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1516.3; Thu, 3 Jan 2019 16:05:32 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%3]) with mapi id 15.20.1495.005; Thu, 3 Jan 2019
 16:05:32 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/4] SUNRPC: Ensure rq_bytes_sent is reset before request
 transmission
Thread-Topic: [PATCH 1/4] SUNRPC: Ensure rq_bytes_sent is reset before request
 transmission
Thread-Index: AQHUou4ciNJmIo9Omk+8lSTAAKbkzqWdrGSAgAAKCoA=
Date:   Thu, 3 Jan 2019 16:05:32 +0000
Message-ID: <6e18b8ce25652bf17d6d1fa95c3a6127767cb45b.camel@hammerspace.com>
References: <20190102225313.2097-1-trond.myklebust@hammerspace.com>
         <20190102225313.2097-2-trond.myklebust@hammerspace.com>
         <1B5E1F96-246A-43AB-B9CE-FA41C595ADFF@oracle.com>
In-Reply-To: <1B5E1F96-246A-43AB-B9CE-FA41C595ADFF@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2319;6:Y0wf/TWCP1qkUKJv/RZbjScGTzR/f0ZU13OP/3QopnkBMDCu5c+q93qIy5V1ut7ff/D//NDAJdZfssDQwulWZm0v7KOrFQvSbAQNrqMI0b76H3lZOxPFPsCBaWEkFppG4HV7evp3BlVj19zWuiE42tRsW46a9/rWlo4WDM8M0MIxaixLyQG6aBoO01E13sBuO2A/RGgmYLJ8Q0iIlKiEyhP5NTgd8GQ7SiEAIavZGeOmLrAUL9T5e0D89I/aMmA9hdWLGj32NqaLpYbYkm+/XJgjeryF+uBLKOcZzYsJxjUaVKS+2ARwt0KoU2Rll3tAj6B5+KqhQTVj4NifRcSReGuD3LAeNRJW/N4XV8xDyYn/FQi4edm7WjsNuO/RwUyXwaUevI6lXZUBgkKWnu3Pecml/W/kztR2WxZFFgIxI75ICncB0JzEGF0Tahat0nyXZDp72+baVU97FoO3XeyPyA==;5:ie9FP//t6frZvfMs8TQycJMAGyhX1yo8td7Zpv2inEoA9xbCEvC+n5XsAOhMaP84I7lZ7ra0kI3Cq8V5HO7bmTkKcAmyqKbtmKMM6yzJ+U6k1KYeD3+cLzLlnIt9+EkzkkppJjhHlRZp44Ore9kvNKuj6BBOxjdqO9aYtCK3Bi8alTfU3Qam8gmM0wtaLj2P+TcQNGE+M/7PZzmo662z6A==;7:t4XxE1qyUIEZeKPg0nLh/WKX1kXTJtzyL0XBXDCObrYCDkJ0VbkmnSK5PgAky5DXzZ+ojF1WVs/dPPTz7cNmrpQsNGvlP0Cb1gCljFXBJjS7mwAsqQ+6jEkAMWrwONPojxa+yD8gBxHbIpL0KuDu5g==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 7738052c-9450-47a2-1506-08d671954a34
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2319;
x-ms-traffictypediagnostic: SN6PR13MB2319:
x-microsoft-antispam-prvs: <SN6PR13MB231912B0A2F0F6B12D8C9F11B88D0@SN6PR13MB2319.namprd13.prod.outlook.com>
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(908002)(999002)(5005026)(6040522)(8220060)(2401047)(8121501046)(3231475)(944501520)(52105112)(3002001)(10201501046)(93006095)(93001095)(6041310)(20161123562045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123560045)(20161123558120)(20161123564045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2319;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2319;
x-forefront-prvs: 0906E83A25
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(39830400003)(136003)(376002)(366004)(396003)(189003)(199004)(229853002)(86362001)(6916009)(5640700003)(6436002)(6512007)(66066001)(118296001)(6486002)(2351001)(5660300001)(2906002)(478600001)(106356001)(105586002)(8676002)(71200400001)(71190400001)(81166006)(81156014)(8936002)(14454004)(305945005)(7736002)(476003)(11346002)(446003)(2501003)(25786009)(97736004)(76176011)(316002)(186003)(68736007)(102836004)(6506007)(53546011)(26005)(6346003)(36756003)(6246003)(486006)(2616005)(53936002)(6116002)(99286004)(256004)(3846002)(14444005)(4326008);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2319;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: TCCQT4CJuprHwJ9F8KbxVQb63Vfs9iagqvVaBK1lAsv+lgPivc1Cd9zTUap4xzS54cnbmUzLgOxpPI23OJAtp+XXrxKsyexQZSqLoBfo3nAtEnpZxekNNsVpk2OqY4lVt1AnM6cucBCymeAEf2ujetRofyWXlIIEX5GLSyfqlO3EDK44mRd357mI+A1Mkw8+f4C/eYPRmmE4hrP2p/VoM3dFTdcDegtn1WWZ+Z8QokPPQM2m5Glx+guzQycwfw7+YziJFESRnkLWlYSna18D42+JdsXBDJVkmAKNYXQzKYrCR+DpWrBAYIuatzrSAcBo
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <00A789F3BD4DB546AFF454DB49464FE5@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7738052c-9450-47a2-1506-08d671954a34
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Jan 2019 16:05:32.7715
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2319
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTAxLTAzIGF0IDEwOjI5IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
SGkgVHJvbmQtDQo+IA0KPiBJIHdhcyBjdXJpb3VzIGFib3V0IHRoaXMgb25lIGJlY2F1c2UgeWVz
dGVyZGF5IEkgc2F3IGV2aWRlbmNlIChmb3INCj4gb3RoZXIgcmVhc29ucykgdGhhdCBycV9ieXRl
c19zZW50IHdhc24ndCBhbHdheXMgemVyb2VkIHdoZW4gaXQgc2hvdWxkDQo+IGJlLg0KPiANCj4g
DQo+ID4gT24gSmFuIDIsIDIwMTksIGF0IDU6NTMgUE0sIFRyb25kIE15a2xlYnVzdCA8dHJvbmRt
eUBnbWFpbC5jb20+DQo+ID4gd3JvdGU6DQo+ID4gDQo+ID4gV2hlbiB3ZSByZXNlbmQgYSByZXF1
ZXN0LCBlbnN1cmUgdGhhdCB0aGUgJ3JxX2J5dGVzX3NlbnQnIGlzIHJlc2V0DQo+ID4gdG8gemVy
by4NCj4gPiANCj4gPiBTaWduZWQtb2ZmLWJ5OiBUcm9uZCBNeWtsZWJ1c3QgPHRyb25kLm15a2xl
YnVzdEBoYW1tZXJzcGFjZS5jb20+DQo+ID4gLS0tDQo+ID4gbmV0L3N1bnJwYy9jbG50LmMgfCAx
IC0NCj4gPiBuZXQvc3VucnBjL3hwcnQuYyB8IDEgKw0KPiA+IDIgZmlsZXMgY2hhbmdlZCwgMSBp
bnNlcnRpb24oKyksIDEgZGVsZXRpb24oLSkNCj4gPiANCj4gPiBkaWZmIC0tZ2l0IGEvbmV0L3N1
bnJwYy9jbG50LmMgYi9uZXQvc3VucnBjL2NsbnQuYw0KPiA+IGluZGV4IDI0Y2JkZGM0NGM4OC4u
MjE4OWZiYzRjNTcwIDEwMDY0NA0KPiA+IC0tLSBhL25ldC9zdW5ycGMvY2xudC5jDQo+ID4gKysr
IGIvbmV0L3N1bnJwYy9jbG50LmMNCj4gPiBAQCAtMTczOCw3ICsxNzM4LDYgQEAgcnBjX3hkcl9l
bmNvZGUoc3RydWN0IHJwY190YXNrICp0YXNrKQ0KPiA+IAl4ZHJfYnVmX2luaXQoJnJlcS0+cnFf
cmN2X2J1ZiwNCj4gPiAJCSAgICAgcmVxLT5ycV9yYnVmZmVyLA0KPiA+IAkJICAgICByZXEtPnJx
X3JjdnNpemUpOw0KPiA+IC0JcmVxLT5ycV9ieXRlc19zZW50ID0gMDsNCj4gDQo+IEkgYWdyZWUg
dGhpcyBsaW5lIGlzIG5vdCBzdWZmaWNpZW50LCBhbmQgaXQgc2hvdWxkIGJlIG1vdmVkLg0KPiBO
b3QgZXZlcnkgcmV0cmFuc21pc3Npb24gcmVxdWlyZXMgYSByZS1lbmNvZGUuIEhvd2V2ZXIsIHRo
ZQ0KPiBwYXRjaCBkZXNjcmlwdGlvbiBzaG91bGQgZXhwbGFpbiB0aGF0LCBhbmQgaXQgcHJvYmFi
bHkgbmVlZHMNCj4gYSBGaXhlczogdGFnLg0KPiANCj4gQ2FuIHlvdSBub3cgYWxzbyByZW1vdmUg
dGhlIHNhbWUgbGluZSBmcm9tIHhwcnRfcmVxdWVzdF9pbml0DQo+IGFuZCB4cHJ0X2luaXRfYmNf
cmVxdWVzdCA/DQo+IA0KPiBBbHNvLCBJIG5vdGljZSB0aGF0IFVEUCBkb2VzIG5vdCB0b3VjaCBy
cV9ieXRlc19zZW50LiBTaW5jZQ0KPiBSRE1BIGFsc28gZG9lcyBub3QgdXNlIHJxX2J5dGVzX3Nl
bnQsIG1heWJlIHRoZSBzYW1lIGxpbmUNCj4gY2FuIGJlIHJlbW92ZWQgZnJvbSB4cHJ0cmRtYS90
cmFuc3BvcnQuYyBhbmQNCj4geHBydHJkbWEvYmFja2NoYW5uZWwuYyA/DQoNClN1cmUuDQoNClNv
IHBsZWFzZSBub3RlIHRoYXQgcnFfYnl0ZXNfc2VudCA9PSAwIG5vIGxvbmdlciBtZWFucyAidGhp
cyByZXF1ZXN0DQpuZWVkcyB0byBiZSByZXRyYW5zbWl0dGVkIiBhbmQgd2Ugbm8gbG9uZ2VyIHRl
c3QgZm9yIGl0IGluDQpuZXQvc3VucnBjL2NsbnQuYy4gV2UgZG8gc3RpbGwgaGF2ZSBhIGNvdXBs
ZSBvZiB0ZXN0cyBvZiBycV9ieXRlc19zZW50DQppbiBuZXQvc3VucnBjL3hwcnQuYyBhbmQgbmV0
L3N1bnJwYy94cHJ0c29jay5jLCBidXQgdGhvc2UgYXJlIG1vcmUNCmFib3V0IGNoZWNraW5nIGlm
IGEgdHJhbnNtaXNzaW9uIG9mIHRoYXQgcmVxdWVzdCBpcyBjdXJyZW50bHkgaW4NCnByb2dyZXNz
LCBpbiB3aGljaCBjYXNlIHdlIGRvbid0IHdhbnQgdG8gcXVldWUgYW55dGhpbmcgaW4gZnJvbnQg
b2YgaXQNCm9uIHRoZSB0cmFuc21pc3Npb24gcXVldWUsIGFuZCB3ZSBkb24ndCB3YW50IHRvIGFi
b3J0IHRoZSB0cmFuc21pc3Npb24NCnVubGVzcyB3ZSBhbHNvIGNsb3NlIHRoZSBzb2NrZXQuDQoN
ClRoZSBpbnRlbnRpb24gbm93IGlzIHRoYXQgaWYgd2Uga25vdyB0aGUgcmVxdWVzdCBuZWVkcyBy
ZXRyYW5zbWlzc2lvbg0KKGR1ZSB0byBhIHRyYW5zcG9ydCBjb25uZWN0aW9uIGxvc3Mgb3IgYSB0
aW1lb3V0KSwgdGhlbiB3ZSBqdXN0IGFkZCBpdA0KdG8gdGhlIHRyYW5zbWlzc2lvbiBxdWV1ZS4N
Cg0KDQo+ID4gCXAgPSBycGNfZW5jb2RlX2hlYWRlcih0YXNrKTsNCj4gPiAJaWYgKHAgPT0gTlVM
TCkgew0KPiA+IGRpZmYgLS1naXQgYS9uZXQvc3VucnBjL3hwcnQuYyBiL25ldC9zdW5ycGMveHBy
dC5jDQo+ID4gaW5kZXggNzM1NDdkMTdkM2M2Li45MDc1YWUxNTBhZTUgMTAwNjQ0DQo+ID4gLS0t
IGEvbmV0L3N1bnJwYy94cHJ0LmMNCj4gPiArKysgYi9uZXQvc3VucnBjL3hwcnQuYw0KPiA+IEBA
IC0xMTUxLDYgKzExNTEsNyBAQCB4cHJ0X3JlcXVlc3RfZW5xdWV1ZV90cmFuc21pdChzdHJ1Y3Qg
cnBjX3Rhc2sNCj4gPiAqdGFzaykNCj4gPiAJc3RydWN0IHJwY194cHJ0ICp4cHJ0ID0gcmVxLT5y
cV94cHJ0Ow0KPiA+IA0KPiA+IAlpZiAoeHBydF9yZXF1ZXN0X25lZWRfZW5xdWV1ZV90cmFuc21p
dCh0YXNrLCByZXEpKSB7DQo+ID4gKwkJcmVxLT5ycV9ieXRlc19zZW50ID0gMDsNCj4gPiAJCXNw
aW5fbG9jaygmeHBydC0+cXVldWVfbG9jayk7DQo+ID4gCQkvKg0KPiA+IAkJICogUmVxdWVzdHMg
dGhhdCBjYXJyeSBjb25nZXN0aW9uIGNvbnRyb2wgY3JlZGl0cyBhcmUNCj4gPiBhZGRlZA0KPiAN
Cj4gU28gSSdtIG5vdCBjb252aW5jZWQgdGhpcyBjb3ZlcnMgZXZlcnkgY2FzZS4gSSBuZWVkIHNv
bWUNCj4gdGltZSB0byBpbnZlc3RpZ2F0ZS4NCg0KSXQgc2hvdWxkIG5vcm1hbGx5IGNvdmVyIGFs
bCBjYXNlcy4gQXMgSSBzYWlkLCB0aGUgb25seSByZW1haW5pbmcgdGVzdHMNCmFyZSBpbiB4cHJ0
LmMgYW5kICB4cHJ0c29jay5jDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xp
ZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2Uu
Y29tDQoNCg0K
