Return-Path: <SRS0=XA/Y=QT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB24DC282C4
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 21:28:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9A083222BE
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 21:28:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=netapp.onmicrosoft.com header.i=@netapp.onmicrosoft.com header.b="TX0CXEC6"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730306AbfBLV2b (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Feb 2019 16:28:31 -0500
Received: from mail-eopbgr700083.outbound.protection.outlook.com ([40.107.70.83]:55376
        "EHLO NAM04-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1729783AbfBLV2b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Feb 2019 16:28:31 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=netapp.onmicrosoft.com; s=selector1-netapp-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=0AApw2cL+VhzedG5QM+L1kExRsYS8C4OovAD7TXsiww=;
 b=TX0CXEC6Cq/K0pSBpR3GSk/statFJveg1avMfolRmEaLhLnHqNr3sHtDCvG4i+pb+u3pvisMm6sshOoOJXujeEaLv84deNGXIzzlB+iMsPhhpBVUOYkVBAsnl8OAJShV9Aax94PuzYDkNOx8YeHvAItEvj1SYB0KjpXrlb/RhBU=
Received: from BN8PR06MB6228.namprd06.prod.outlook.com (20.178.217.156) by
 BN8PR06MB5857.namprd06.prod.outlook.com (20.179.138.154) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.19; Tue, 12 Feb 2019 21:28:28 +0000
Received: from BN8PR06MB6228.namprd06.prod.outlook.com
 ([fe80::d2f:dbea:270:9aea]) by BN8PR06MB6228.namprd06.prod.outlook.com
 ([fe80::d2f:dbea:270:9aea%3]) with mapi id 15.20.1601.023; Tue, 12 Feb 2019
 21:28:28 +0000
From:   "Schumaker, Anna" <Anna.Schumaker@netapp.com>
To:     "bcodding@redhat.com" <bcodding@redhat.com>,
        "trond.myklebust@hammerspace.com" <trond.myklebust@hammerspace.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] NFS: Don't use page_file_mapping after removing the
 page
Thread-Topic: [PATCH v2] NFS: Don't use page_file_mapping after removing the
 page
Thread-Index: AQHUvgx5vM58tZE+TEOHAvIhWTKvWKXcjCQAgAAri4A=
Date:   Tue, 12 Feb 2019 21:28:28 +0000
Message-ID: <65aefd627038c626c49b793165f1ca21d524f914.camel@netapp.com>
References: <5eb439e690e72e3a69ad0a5bb48827c7e5ce32a8.1549451324.git.bcodding@redhat.com>
         <D1443158-8840-4D21-8215-68B96138F45C@redhat.com>
In-Reply-To: <D1443158-8840-4D21-8215-68B96138F45C@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Evolution 3.30.5 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Anna.Schumaker@netapp.com; 
x-originating-ip: [73.145.169.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a13bb8ef-3865-413e-b426-08d6913107be
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7193020);SRVR:BN8PR06MB5857;
x-ms-traffictypediagnostic: BN8PR06MB5857:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtCTjhQUjA2TUI1ODU3OzIzOi84cnBhSWwzR2diTjJ4TGIzZmlNYkRLL3R0?=
 =?utf-8?B?d3oxU2g4OUkxZldBdXN0V1hhbWo5a3N3VTV6RGFicnhwc3dRbGNzQnVVOVB3?=
 =?utf-8?B?M1lWSktkNzAwOG5sQmdSSlA0RTQ4MXZ3ckVTOENrcm55TXVNRldjQ3VxSk5I?=
 =?utf-8?B?a1NFY2NwRmpHYVZxeTJjRTY1OSt4YklCdmpyMCsrSlpFakQ4dHNib1JxYStG?=
 =?utf-8?B?UnFTZ0dBS0NhYWV5NmRQeUVEMUw5VU1FcTU2ZGUrRkphMndIbENqUDlmRnA3?=
 =?utf-8?B?azJST1psUmxPTURsdFN0TmxDa2xrem1uaVljM3p2T2dHclFTdmJBOXBWeHhp?=
 =?utf-8?B?REtlOU5IWkJuZjZiRXJuNzNLOGowSnlsbFJkbk5oeHlHTzVDQitmK1A5eTZN?=
 =?utf-8?B?NzhCenFGZlRYZVowZ1NMRTZsWEV2QUNRMUVGSm56ZzJ0VXJJMCs1VVZTN2hz?=
 =?utf-8?B?UTQ2Q3RkKzdCYVduMmlDbUtzcHg2Q2Q2emdMQ0tpYjJNSWNLL1hBZC9VSFgr?=
 =?utf-8?B?SXo1eDk2dTBzMmFKaWl1aVlNWkM4WkxERlh3elIzN0NGWEx3VHRNdmV5MGhH?=
 =?utf-8?B?YkV6TGRUVGRWQ25OR1NqK1NQYUZVQjZVUDlhSWxlU3ErdEMzeFo2ZlpmRDRW?=
 =?utf-8?B?TnNDOUZLR3plcEpObUdVQlk5VXpSZjVDS2F6cm5LdnJhM3U5YSt0N2w0V0pM?=
 =?utf-8?B?MDAzTmFiU29OMHNiK0IxV3phV2g5dDJ0NFU5TGlZdFpIbmVKWGZ6Y09TOG5u?=
 =?utf-8?B?aEl1bndYTlRSSkd2NmJGUDNaZWlyQ2pHL1I0b3hVcjFneHA1M1pmMWJBRUVo?=
 =?utf-8?B?RldyMTZZOVB1MGtuRUs3aXRGZTExcGs5VW5Fc0E1SFBXS3pQaWJmTnA5N0xH?=
 =?utf-8?B?OFpqNjdwUThXbUZ3bmpqL2F6OXRvNTlsZkZIWHc0cENCSFFoTWRvWjJ1UzY2?=
 =?utf-8?B?Y3pualdLbWFmYnJqMXhlbzFRVDRQNzZpTVFIK3I2bjVodlRwNm1tWG5EY3dO?=
 =?utf-8?B?OWQ2OVJ6WEV4MFpGdE1ZVXJ3WWdFQmlIQTBUWGVxTHlSQ21LbkZHUVhlV2Qr?=
 =?utf-8?B?OWd4WnNuZm04UDdzdEV2bUwwOCsvL3UvdkdReUJ6b3NTVmcwU0VBaU9KU2NQ?=
 =?utf-8?B?akhEZUJKY0lRSW9Jb1hGYWx5ZElXdXh4TG1jNEt4RndYbnU1Qnh0N2RJYWV3?=
 =?utf-8?B?Yi9XWlRFRGJxOGdwbVY0UGh4M05LdER4R2VsZFlqa0tKNndPbEE5RHRlZE9D?=
 =?utf-8?B?Wk0yaER4cWpwUnBCaWgxN0NmQ1orMlBPN0xVSzZESHN3VU0xRVNpRUJjVDg0?=
 =?utf-8?B?RzN4dDdOYmlZMHRhc0Z0TWJIT2J0aWtrS1Yyc3Q2U0JiNEM0bVArOTZPbDVY?=
 =?utf-8?B?N2FzS1hpcXRkT3RhdW1uWFB2THVpNDA3VEZvQXpKNjhEQ2VXbmpTVURaclFt?=
 =?utf-8?B?QnVVRFdydnJKYkYzTDZNYVhrYkhSTjZsbDlhSGI4TDhNZnVMZmg1YUdOeDJ6?=
 =?utf-8?B?K1VIZFcyVTlZWkgxeEwwZjgxYnpIZUYxMGxwNWZQeThpQnRkUWs4OWxCeStD?=
 =?utf-8?B?dzFkQ3g5QnRjQ3RGbm5pZDNUL2ZmcFhxbHhRbWNVNHprV1YxM1dhT0JScS8x?=
 =?utf-8?B?aDdHQmxPbk10NytBUXFoeE5pUTdHYjdTcXFvaTA2UGxETmdQRHRnL041ZTFr?=
 =?utf-8?Q?6WR6mNyOhzEavuYlm8=3D?=
x-microsoft-antispam-prvs: <BN8PR06MB58573C8A4E3D928AEB06C230F8650@BN8PR06MB5857.namprd06.prod.outlook.com>
x-forefront-prvs: 0946DC87A1
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(136003)(39860400002)(396003)(376002)(346002)(366004)(189003)(199004)(76176011)(97736004)(6506007)(8676002)(186003)(102836004)(99286004)(6116002)(71200400001)(81166006)(3846002)(81156014)(8936002)(105586002)(72206003)(71190400001)(2906002)(25786009)(106356001)(478600001)(14454004)(53546011)(36756003)(26005)(6246003)(229853002)(66066001)(11346002)(6436002)(446003)(316002)(14444005)(53936002)(6486002)(110136005)(4326008)(68736007)(86362001)(2501003)(6512007)(118296001)(305945005)(7736002)(2616005)(486006)(476003)(256004)(58126008);DIR:OUT;SFP:1101;SCL:1;SRVR:BN8PR06MB5857;H:BN8PR06MB6228.namprd06.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: netapp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: IudOE0PQt3nYSiX61gKyQkjRtD7p89BVXxi+pLitFIkIVGQqoC8u3JsiCUgzsT3PiqKnYzhoYg1Qnz+HmJJGGHilgJURGR8w3YtKJGZ7uDnkt0jBvAwP98UDdWvOJF8PInqRR5v2z4A+coVyLNQBn5oehmsJ7sWQVr3MIt9qP2zk74DGYV//CVJi43zV1r+3WOykV8Xgt+K+ziwHg+VByHIe9LEzQY35qgQOF/aLJ8wpsdzS4SOZ6Y4MjeB8iWNK64bnN5tCqiu8zCGonMkwv//Yn6d8n/bS31wwkx+oKemVlWydhQkpezdnGcUMe5jqdQXZXOkCVR5CpaRx/eJron/OokrUp8gVdsMSsBu5hertUk0rCLhC6cgFAySPv0/nCEgzeuWYfQqAwh77WwsFMr2x8IJHlrqn0sZKsILxprU=
Content-Type: text/plain; charset="utf-8"
Content-ID: <E675DFBA779316419E1136370AE8B4E2@namprd06.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a13bb8ef-3865-413e-b426-08d6913107be
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Feb 2019 21:28:28.7756
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN8PR06MB5857
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE5LTAyLTEyIGF0IDEzOjUyIC0wNTAwLCBCZW5qYW1pbiBDb2RkaW5ndG9uIHdy
b3RlOg0KPiBIaSBUcm9uZCBhbmQgQW5uYSwNCj4gDQo+IEkgd2FudCB0byBidW1wIHRoaXMuICBU
aGUgcHJvYmxlbSB3ZSBjcmVhdGVkIGlzIGVhc2llciB0byBoaXQgbm93IHRoYW4NCj4gdGhlIHBy
b2JsZW0gd2Ugd2VyZSBmaXhpbmcsIHNvIHNvbWV0aGluZyBzaG91bGQgYmUgZG9uZSBmb3IgNS4w
IGlmDQo+IHBvc3NpYmxlLg0KDQpTb3VuZHMgZ29vZC4gIEknbGwgc2VuZCBpdCBpbiBhIHB1bGwg
cmVxdWVzdCB0aGlzIHdlZWsuDQoNClRoYW5rcywNCkFubmENCg0KPiANCj4gQmVuDQo+IA0KPiBP
biA2IEZlYiAyMDE5LCBhdCA2OjA5LCBCZW5qYW1pbiBDb2RkaW5ndG9uIHdyb3RlOg0KPiANCj4g
PiBJZiBuZnNfcGFnZV9hc3luY19mbHVzaCgpIHJlbW92ZXMgdGhlIHBhZ2UgZnJvbSB0aGUgbWFw
cGluZywgdGhlbiB3ZQ0KPiA+IGNhbid0DQo+ID4gdXNlIHBhZ2VfZmlsZV9tYXBwaW5nKCkgb24g
aXQgYXMgbmZzX3VwZGF0ZXBhdGUoKSBpcyB3b250IHRvIGRvIHdoZW4NCj4gPiByZWNlaXZpbmcg
YW4gZXJyb3IuICBJbnN0ZWFkLCBwdXNoIHRoZSBtYXBwaW5nIHRvIHRoZSBzdGFjayBiZWZvcmUg
dGhlDQo+ID4gcGFnZQ0KPiA+IGlzIHBvc3NpYmx5IHRydW5jYXRlZC4NCj4gPiANCj4gPiBGaXhl
czogOGZjNzViZWQ5NmJiICgiTkZTOiBGaXggdXAgcmV0dXJuIHZhbHVlIG9uIGZhdGFsIGVycm9y
cyBpbg0KPiA+IG5mc19wYWdlX2FzeW5jX2ZsdXNoKCkiKQ0KPiA+IFNpZ25lZC1vZmYtYnk6IEJl
bmphbWluIENvZGRpbmd0b24gPGJjb2RkaW5nQHJlZGhhdC5jb20+DQo+ID4gLS0tDQo+ID4gIGZz
L25mcy93cml0ZS5jIHwgMTEgKysrKysrLS0tLS0NCj4gPiAgMSBmaWxlIGNoYW5nZWQsIDYgaW5z
ZXJ0aW9ucygrKSwgNSBkZWxldGlvbnMoLSkNCj4gPiANCj4gPiBkaWZmIC0tZ2l0IGEvZnMvbmZz
L3dyaXRlLmMgYi9mcy9uZnMvd3JpdGUuYw0KPiA+IGluZGV4IGYxMmNiMzFhNDFlNS4uZDA5Yzlm
ODc4MTQxIDEwMDY0NA0KPiA+IC0tLSBhL2ZzL25mcy93cml0ZS5jDQo+ID4gKysrIGIvZnMvbmZz
L3dyaXRlLmMNCj4gPiBAQCAtMjM4LDkgKzIzOCw5IEBAIHN0YXRpYyB2b2lkIG5mc19ncm93X2Zp
bGUoc3RydWN0IHBhZ2UgKnBhZ2UsDQo+ID4gdW5zaWduZWQgaW50IG9mZnNldCwgdW5zaWduZWQg
aW50IGMNCj4gPiAgfQ0KPiA+IA0KPiA+ICAvKiBBIHdyaXRlYmFjayBmYWlsZWQ6IG1hcmsgdGhl
IHBhZ2UgYXMgYmFkLCBhbmQgaW52YWxpZGF0ZSB0aGUgcGFnZQ0KPiA+IGNhY2hlICovDQo+ID4g
LXN0YXRpYyB2b2lkIG5mc19zZXRfcGFnZWVycm9yKHN0cnVjdCBwYWdlICpwYWdlKQ0KPiA+ICtz
dGF0aWMgdm9pZCBuZnNfc2V0X3BhZ2VlcnJvcihzdHJ1Y3QgYWRkcmVzc19zcGFjZSAqbWFwcGlu
ZykNCj4gPiAgew0KPiA+IC0gICAgIG5mc196YXBfbWFwcGluZyhwYWdlX2ZpbGVfbWFwcGluZyhw
YWdlKS0+aG9zdCwNCj4gPiBwYWdlX2ZpbGVfbWFwcGluZyhwYWdlKSk7DQo+ID4gKyAgICAgbmZz
X3phcF9tYXBwaW5nKG1hcHBpbmctPmhvc3QsIG1hcHBpbmcpOw0KPiA+ICB9DQo+ID4gDQo+ID4g
IC8qDQo+ID4gQEAgLTk5NCw3ICs5OTQsNyBAQCBzdGF0aWMgdm9pZCBuZnNfd3JpdGVfY29tcGxl
dGlvbihzdHJ1Y3QNCj4gPiBuZnNfcGdpb19oZWFkZXIgKmhkcikNCj4gPiAgICAgICAgICAgICAg
IG5mc19saXN0X3JlbW92ZV9yZXF1ZXN0KHJlcSk7DQo+ID4gICAgICAgICAgICAgICBpZiAodGVz
dF9iaXQoTkZTX0lPSERSX0VSUk9SLCAmaGRyLT5mbGFncykgJiYNCj4gPiAgICAgICAgICAgICAg
ICAgICAoaGRyLT5nb29kX2J5dGVzIDwgYnl0ZXMpKSB7DQo+ID4gLSAgICAgICAgICAgICAgICAg
ICAgIG5mc19zZXRfcGFnZWVycm9yKHJlcS0+d2JfcGFnZSk7DQo+ID4gKyAgICAgICAgICAgICAg
ICAgICAgIG5mc19zZXRfcGFnZWVycm9yKHBhZ2VfZmlsZV9tYXBwaW5nKHJlcS0+d2JfcGFnZSkp
Ow0KPiA+ICAgICAgICAgICAgICAgICAgICAgICBuZnNfY29udGV4dF9zZXRfd3JpdGVfZXJyb3Io
cmVxLT53Yl9jb250ZXh0LCBoZHItDQo+ID4gPmVycm9yKTsNCj4gPiAgICAgICAgICAgICAgICAg
ICAgICAgZ290byByZW1vdmVfcmVxOw0KPiA+ICAgICAgICAgICAgICAgfQ0KPiA+IEBAIC0xMzQ4
LDcgKzEzNDgsOCBAQCBpbnQgbmZzX3VwZGF0ZXBhZ2Uoc3RydWN0IGZpbGUgKmZpbGUsIHN0cnVj
dA0KPiA+IHBhZ2UgKnBhZ2UsDQo+ID4gICAgICAgICAgICAgICB1bnNpZ25lZCBpbnQgb2Zmc2V0
LCB1bnNpZ25lZCBpbnQgY291bnQpDQo+ID4gIHsNCj4gPiAgICAgICBzdHJ1Y3QgbmZzX29wZW5f
Y29udGV4dCAqY3R4ID0gbmZzX2ZpbGVfb3Blbl9jb250ZXh0KGZpbGUpOw0KPiA+IC0gICAgIHN0
cnVjdCBpbm9kZSAgICAqaW5vZGUgPSBwYWdlX2ZpbGVfbWFwcGluZyhwYWdlKS0+aG9zdDsNCj4g
PiArICAgICBzdHJ1Y3QgYWRkcmVzc19zcGFjZSAqbWFwcGluZyA9IHBhZ2VfZmlsZV9tYXBwaW5n
KHBhZ2UpOw0KPiA+ICsgICAgIHN0cnVjdCBpbm9kZSAgICAqaW5vZGUgPSBtYXBwaW5nLT5ob3N0
Ow0KPiA+ICAgICAgIGludCAgICAgICAgICAgICBzdGF0dXMgPSAwOw0KPiA+IA0KPiA+ICAgICAg
IG5mc19pbmNfc3RhdHMoaW5vZGUsIE5GU0lPU19WRlNVUERBVEVQQUdFKTsNCj4gPiBAQCAtMTM2
Niw3ICsxMzY3LDcgQEAgaW50IG5mc191cGRhdGVwYWdlKHN0cnVjdCBmaWxlICpmaWxlLCBzdHJ1
Y3QNCj4gPiBwYWdlICpwYWdlLA0KPiA+IA0KPiA+ICAgICAgIHN0YXR1cyA9IG5mc193cml0ZXBh
Z2Vfc2V0dXAoY3R4LCBwYWdlLCBvZmZzZXQsIGNvdW50KTsNCj4gPiAgICAgICBpZiAoc3RhdHVz
IDwgMCkNCj4gPiAtICAgICAgICAgICAgIG5mc19zZXRfcGFnZWVycm9yKHBhZ2UpOw0KPiA+ICsg
ICAgICAgICAgICAgbmZzX3NldF9wYWdlZXJyb3IobWFwcGluZyk7DQo+ID4gICAgICAgZWxzZQ0K
PiA+ICAgICAgICAgICAgICAgX19zZXRfcGFnZV9kaXJ0eV9ub2J1ZmZlcnMocGFnZSk7DQo+ID4g
IG91dDoNCj4gPiAtLQ0KPiA+IDIuMTQuMw0K
