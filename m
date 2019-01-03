Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB316C43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 21:28:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 378BF217F5
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 21:28:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="HIAu2Rh4"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727754AbfACV2K (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 16:28:10 -0500
Received: from mail-eopbgr800118.outbound.protection.outlook.com ([40.107.80.118]:52544
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727433AbfACV2K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Jan 2019 16:28:10 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Go9NqSrV/FSDOXuk8njdAojdFKXJ5f15v6oIyov1aMw=;
 b=HIAu2Rh4E0tx8b63iD10Mi9rEjIjkfpM9rwD+3PP0c3zwvgKxXVWcrloNyYVCe04OJeF7XEbhcWM6qTvTXS2Z+gLY5yVC+6qDhOTbyMX8k4LjnahgJa9Oxz3KK2ds1x1XL4mlAJZWFxBJHc02yWTf0ZBA+0WJ0nVx9jSUDsyyTg=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2416.namprd13.prod.outlook.com (52.135.94.160) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1495.4; Thu, 3 Jan 2019 21:28:06 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%3]) with mapi id 15.20.1495.005; Thu, 3 Jan 2019
 21:28:06 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Remove rpc_xprt::tsh_size
Thread-Topic: [PATCH] SUNRPC: Remove rpc_xprt::tsh_size
Thread-Index: AQHUo5McwpQQZImh0EO/lRKWh6zKuqWd4oaAgAAjNgCAAAPogIAABaEA
Date:   Thu, 3 Jan 2019 21:28:06 +0000
Message-ID: <076cce85045dbaab3ca40947b2599f96cff66b53.camel@hammerspace.com>
References: <20190103182649.4148.19838.stgit@manet.1015granger.net>
         <0331de80b8161f8bf16a92de20049cafb0c228da.camel@hammerspace.com>
         <90B38E07-3241-4CCD-A4C8-AB78BADFB0CD@oracle.com>
         <791EE189-59E5-4D58-9CF6-6D2CFC6C1210@oracle.com>
In-Reply-To: <791EE189-59E5-4D58-9CF6-6D2CFC6C1210@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2416;6:ay+3TpMveeFX3Iu+5nnhYaEoQqztT8xqBnK5Kh0GP4a3YqYzncf9RKgSz9zHA+olr6PzvCdlj1N3fnJaaU6trW5kjL7LeNLECUj6wjBPeuUjfy9E9hJ/V2GkKQUFq0htXybkF+spkw1Llqi0Ak+a0XO+Y73jNeMqmT1cpciCymlWNNSEOe5C14oitwsd3jmuzn46uJjC7MRaIBVdAaFAEYto95Eq7aG8AMf0zg8ldeREtSdsuNKs2l6BQ/KEJ3ye5hsZ2VsuK74Uz1NGZoyN1hvtKdx2ZERoc8fwNDbjK3aCRKqPRZqXPlMiGv7xv0ivjjljh8aiewvVbws1pUL5kuu7mh/h+opGrC6zfmi4dSBTPKnLPnWdoeSl6EdjXijxp7zcxkE23uuuTFsOLjlhQriQGkTgcrfXxLypEJ01zDHUTHbJynjpQzB9a8CNgk0M2wilQ6R5TLblSvUnSfmCVg==;5:0QN8DCeiuVHJyVIpZe4y5jg6zZ+onZ4dVrHQO57MLFOKOJv9tkxwl9eeJrqU+/+UZpWAZeJb2/FzLy49wddnkEhB63JizgmlHsU1/2zhlC9alf7HONY0E4OzFTLazNK0FS1YK6SCRZeZUNDQruO26Bzpq+7WF7NUX4spvcez4iXR8QyY0JeHuap2g4LcEVKbHPjQnPRUfwiQJeGS3oYZtg==;7:SNn4/TWvibQoSCDIVXRUViNMyIx5+OkB59NHSvWLSIECljTpWxFcnt2S7pLLpSlay9S0YVTrymOqEwtMmhtpX+qwSpx93e37h/H8fnhTEbuawUtK0oeUVcLBi3XbjSw2CWceDnKDo7c4RGtigvj3hw==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 0f755131-7643-45c6-a9a1-08d671c259e5
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2416;
x-ms-traffictypediagnostic: SN6PR13MB2416:
x-microsoft-antispam-prvs: <SN6PR13MB2416882604707EF0398860ACB88D0@SN6PR13MB2416.namprd13.prod.outlook.com>
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(908002)(999002)(5005026)(6040522)(8220060)(2401047)(8121501046)(3002001)(3231475)(944501520)(52105112)(10201501046)(93006095)(93001095)(6041310)(20161123562045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123560045)(20161123558120)(20161123564045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2416;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2416;
x-forefront-prvs: 0906E83A25
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39830400003)(366004)(136003)(346002)(376002)(396003)(199004)(189003)(2351001)(93886005)(36756003)(106356001)(105586002)(2906002)(66066001)(3846002)(71200400001)(7736002)(256004)(86362001)(2501003)(305945005)(8936002)(6116002)(81166006)(81156014)(71190400001)(8676002)(6512007)(5640700003)(5660300001)(26005)(446003)(2616005)(486006)(11346002)(476003)(68736007)(186003)(118296001)(25786009)(99286004)(53546011)(53936002)(316002)(97736004)(6506007)(4326008)(102836004)(76176011)(229853002)(6246003)(6486002)(6436002)(6916009)(14454004)(478600001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2416;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: j1o7QdY/BkWozz1tME8vQrEVP31dcqluS+5mXaidOR2cc9Fko7RVgVdHFb+7cLIyZjH+Qa4VTO9tdtVwf5YExjgp41SbzSToYIBfOSwizCZaJP9qMo3jswx1Fp5eVHH0x99ImuQDyz+V0pc0Uuw6imG18wPli5NH3pz2ZtD7iaTTa1n+KYmzxc9iSjpbXuwMvJI4VTIwTZzMwCUo8O6OuUZa+DRYe4n660OpN8muSYXhMGJfQ6Ylp/dJSupq+/IlsFCzsMYwk9fvQCLyjXPm7s86aio/cfMMZjlIZMpCqhWspLYASj2r31U5KEM0OP7x
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <3F590CEB3C77074CB96CC1DDD783141D@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 0f755131-7643-45c6-a9a1-08d671c259e5
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Jan 2019 21:28:06.3758
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2416
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTAxLTAzIGF0IDE2OjA3IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBKYW4gMywgMjAxOSwgYXQgMzo1MyBQTSwgQ2h1Y2sgTGV2ZXIgPGNodWNrLmxldmVyQG9y
YWNsZS5jb20+DQo+ID4gd3JvdGU6DQo+ID4gDQo+ID4gPiBPbiBKYW4gMywgMjAxOSwgYXQgMTo0
NyBQTSwgVHJvbmQgTXlrbGVidXN0IDwNCj4gPiA+IHRyb25kbXlAaGFtbWVyc3BhY2UuY29tPiB3
cm90ZToNCj4gPiA+IA0KPiA+ID4gT24gVGh1LCAyMDE5LTAxLTAzIGF0IDEzOjI5IC0wNTAwLCBD
aHVjayBMZXZlciB3cm90ZToNCj4gPiA+ID4gKwlyZWNsZW4gPSByZXEtPnJxX3NuZF9idWYubGVu
Ow0KPiA+ID4gPiArCW1hcmtlciA9IGNwdV90b19iZTMyKFJQQ19MQVNUX1NUUkVBTV9GUkFHTUVO
VCB8DQo+ID4gPiA+IHJlY2xlbik7DQo+ID4gPiA+ICsJcmV0dXJuIGtlcm5lbF9zZW5kbXNnKHRy
YW5zcG9ydC0+c29jaywgJm1zZywgJmlvdiwgMSwNCj4gPiA+ID4gaW92Lmlvdl9sZW4pOw0KPiA+
ID4gDQo+ID4gPiBTbyB3aGF0IGRvZXMgdGhpcyBkbyBmb3IgcGVyZm9ybWFuY2U/IEknZCBleHBl
Y3QgdGhhdCBhZGRpbmcNCj4gPiA+IGFub3RoZXINCj4gPiA+IGRpdmUgaW50byB0aGUgc29ja2V0
IGxheWVyIHdpbGwgY29tZSB3aXRoIHBlbmFsdGllcy4NCj4gPiANCj4gPiBORlN2MyBvbiBUQ1As
IHNlYz1zeXMsIDU2R2JzIElCb0lQLCB2NC4yMCArIG15IHY0LjIxIHBhdGNoZXMNCj4gPiBmaW8s
IDhLQiByYW5kb20sIDcwJSByZWFkLCAzMCUgd3JpdGUsIDE2IHRocmVhZHMsIGlvZGVwdGg9MTYN
Cj4gPiANCj4gPiBXaXRob3V0IHRoaXMgcGF0Y2g6DQo+ID4gDQo+ID4gICByZWFkOiBJT1BTPTI4
LjdrLCBCVz0yMjRNaUIvcyAoMjM1TUIvcykoMTEuMkdpQi81MTA5Mm1zZWMpDQo+ID4gIHdyaXRl
OiBJT1BTPTEyLjNrLCBCVz05Ni4zTWlCL3MgKDEwMU1CL3MpKDQ5MThNaUIvNTEwOTJtc2VjKQ0K
PiA+IA0KPiA+IFdpdGggdGhpcyBwYXRjaDoNCj4gPiANCj4gPiAgIHJlYWQ6IElPUFM9MjguNmss
IEJXPTIyNE1pQi9zICgyMzVNQi9zKSgxMS4yR2lCLzUxMjc2bXNlYykNCj4gPiAgd3JpdGU6IElP
UFM9MTIuM2ssIEJXPTk1LjhNaUIvcyAoMTAwTUIvcykoNDkxNE1pQi81MTI3Nm1zZWMpDQo+ID4g
DQo+ID4gU2VlbXMgbGlrZSB0aGF0J3MgaW4gdGhlIG5vaXNlLg0KPiANCj4gU2lnaC4gVGhhdCdz
IGJlY2F1c2UgaXQgd2FzIHRoZSBzYW1lIGtlcm5lbC4gQWdhaW4sIHdpdGggZmVlbGluZzoNCj4g
DQo+IDQuMjAuMC1yYzctMDAwNDgtZzkyNzQyNTQ6DQo+ICAgIHJlYWQ6IElPUFM9MjguNmssIEJX
PTIyNE1pQi9zICgyMzVNQi9zKSgxMS4yR2lCLzUxMjc2bXNlYykNCj4gICB3cml0ZTogSU9QUz0x
Mi4zaywgQlc9OTUuOE1pQi9zICgxMDBNQi9zKSg0OTE0TWlCLzUxMjc2bXNlYykNCj4gDQo+IDQu
MjAuMC1yYzctMDAwNDktZ2E0ZGVhMTU6DQo+ICAgIHJlYWQ6IElPUFM9MjcuMmssIEJXPTIxMk1p
Qi9zICgyMjNNQi9zKSgxMS4yR2lCLzUzOTc5bXNlYykNCj4gICB3cml0ZTogSU9QUz0xMS43aywg
Qlc9OTEuMU1pQi9zICg5NS41TUIvcykoNDkxN01pQi81Mzk3OW1zZWMpDQo+IA0KDQpTbyBhYm91
dCBhIDUlIHJlZHVjdGlvbiBpbiBwZXJmb3JtYW5jZT8NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QN
CkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVz
dEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
