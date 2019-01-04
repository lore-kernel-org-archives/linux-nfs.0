Return-Path: <SRS0=F+UG=PM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A015CC43387
	for <linux-nfs@archiver.kernel.org>; Fri,  4 Jan 2019 22:44:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1DEDE2173B
	for <linux-nfs@archiver.kernel.org>; Fri,  4 Jan 2019 22:44:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Yt4ndSB9"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726100AbfADWoj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 4 Jan 2019 17:44:39 -0500
Received: from mail-eopbgr810111.outbound.protection.outlook.com ([40.107.81.111]:43136
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726094AbfADWoi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 4 Jan 2019 17:44:38 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=pfNsciZkYDvwdcuBYL/3kMlnlFKDK76GrSxGf2VrHSQ=;
 b=Yt4ndSB9Vo9Meq5Ea5aaWAOUssrIhyh3w7UEHa1hRyMl7lFyNcZI8VIWckLQFaxi+6vkIzVkdK/KEGNXuqn0+Z56Pr2Z9QsuxsoopbjYbw/HsCAAPR3pHav+XZJm0bX7ZGubwFfRP8GszrvMI0kRjku85RyrHa5hUFP4m2lQGww=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2493.namprd13.prod.outlook.com (52.135.95.147) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1495.4; Fri, 4 Jan 2019 22:44:19 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%3]) with mapi id 15.20.1495.005; Fri, 4 Jan 2019
 22:44:19 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Remove rpc_xprt::tsh_size
Thread-Topic: [PATCH] SUNRPC: Remove rpc_xprt::tsh_size
Thread-Index: AQHUo5McwpQQZImh0EO/lRKWh6zKuqWd4oaAgAAjNgCAAAPogIAABaEAgAAB8ACAABTMAIAAVtCAgAEm1ICAABNAgA==
Date:   Fri, 4 Jan 2019 22:44:19 +0000
Message-ID: <e69a8e3965258109772f1adaedebc02d0863f3d9.camel@hammerspace.com>
References: <20190103182649.4148.19838.stgit@manet.1015granger.net>
         <0331de80b8161f8bf16a92de20049cafb0c228da.camel@hammerspace.com>
         <90B38E07-3241-4CCD-A4C8-AB78BADFB0CD@oracle.com>
         <791EE189-59E5-4D58-9CF6-6D2CFC6C1210@oracle.com>
         <076cce85045dbaab3ca40947b2599f96cff66b53.camel@hammerspace.com>
         <1353EAC5-5BEE-461E-A11E-31F00FC7B946@oracle.com>
         <CE340D31-4F14-4C6F-B7C8-958754394C08@oracle.com>
         <1d6779ff05f2d31c4eccd048acbb28563bc9b79b.camel@hammerspace.com>
         <EE4DED67-E4A7-4F82-A5D0-9137381A2B4A@oracle.com>
In-Reply-To: <EE4DED67-E4A7-4F82-A5D0-9137381A2B4A@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2493;6:fyBdTcyRi3hsPgD0/vgIMCZW6jKONycZWbfQetEbPEcrMVohaJZ/SRvjiUZ/m1lW1OjoqZY/yUYdIDy1XcUoXjUFzRrPyXwyiYx974q4zqxnzAzrn4ST+DLZxZwEnbK8zQlNA9vgtkfN/Vbb1JPRCjEF/s3xiAQzu8tIUJ/hKhNGvlU7pbs8DZfNPJkeBJmCVQuu9tbANw4K9KH1r991J94PaOLT721nNZmLfxPlrOQVopcBqh+Rp1fpF00ji4APvVll4nRVxqHdtE+5HV55y/VYAQgEJ28o+zP6SKokRHS803Y6K2OfLawzAGpSbmsJFjlbNpie0KNt+7LGphdw4aEFCAjOujY4KVeJYbxu5fOxuchNxIgHpLmcVUWNoNPX+NIvqGxGWsEd8i6o7VvCNdedz3RlieYpK7SAAEPIJZAQWLHZMuRO/tzpmHjMtYzga/ZdlpZtvPallujL+YLsSw==;5:EvKI5E2oEsWSv3gHCP3fypGNgTp6+CdgqWUTC/etivPWvvLICrlLI82u1WqB0SpmLSRm5ne2wQeSqPq8KoZP/l/FykQ86b1Qgdn3k3gKrVVgcuyEZBAdQsLgM9iFje+3/9vH43JICQmJWz3cNVuoygL2Fol0MhzfKtB7edk4grnnMf3mlItnLgec1igwe+Ho/7frJRwmBW39g1cBY2IOLQ==;7:UbDQ31a8IlRgFVqp3vP8DdTJXZQM8Ecf9yO1F30tcdGb4H1fT22Vky9Zi88ZQv92Vs1uEufYGvnEw5cXJl/Rl1eam8KQ7ErBHR/B45g7BK5xpjpoLM8x40B3pzfs+oiw05CeQNhGzp4qxlFVQCMRVw==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 7d513a2c-fd9c-4d8a-699b-08d672962a26
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2493;
x-ms-traffictypediagnostic: SN6PR13MB2493:
x-microsoft-antispam-prvs: <SN6PR13MB2493ECF706AE146B63CC307FB88E0@SN6PR13MB2493.namprd13.prod.outlook.com>
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(908002)(999002)(5005026)(6040522)(8220060)(2401047)(8121501046)(10201501046)(3002001)(3231475)(944501520)(52105112)(93006095)(93001095)(6041310)(20161123564045)(20161123558120)(20161123562045)(20161123560045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2493;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2493;
x-forefront-prvs: 0907F58A24
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(366004)(39830400003)(396003)(346002)(136003)(189003)(199004)(26005)(4326008)(6512007)(2501003)(186003)(6116002)(2616005)(106356001)(105586002)(3846002)(25786009)(93886005)(86362001)(6346003)(7736002)(478600001)(118296001)(66066001)(305945005)(476003)(11346002)(2351001)(446003)(6506007)(102836004)(53546011)(2906002)(6486002)(6436002)(229853002)(76176011)(14444005)(256004)(81156014)(5640700003)(99286004)(8936002)(53936002)(486006)(14454004)(5660300001)(71200400001)(68736007)(97736004)(36756003)(71190400001)(6246003)(8676002)(6916009)(316002)(81166006);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2493;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: LjfH1emb7mQM8loXtpCnmS/0yFTfor5rQdRTaKVl852ge/EW5AR3Uy+0n5GwadATiWXeN5eytlUSmPVSt8Lp/T3Eu7igrfU+ALLcH1lZrlAhrdgv+CKrQAdl+/L7RBp1S9uqDwPA2mth7twISqRvoLEyjd3aRJW1cBhFw1IcJqBRzPMcMknhNA40TEj0az6VzJpb8/7/2o/mlyOKzFtvq45YxaJT6b8OpDwqwmyGh4qg+2OXRHl0ZEUN5N1qbkLT0yxZVS0lJE1QjhFvheWI3ZiY+WoIJ8IT7bELXqDIQx9lzfJ7BksuMZKrMtt8q6Uy
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <5ABCCCFC97D29E4DBB5E61A7E9C810E3@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7d513a2c-fd9c-4d8a-699b-08d672962a26
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Jan 2019 22:44:19.5918
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2493
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE5LTAxLTA0IGF0IDE2OjM1IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBKYW4gMywgMjAxOSwgYXQgMTE6MDAgUE0sIFRyb25kIE15a2xlYnVzdCA8DQo+ID4gdHJv
bmRteUBoYW1tZXJzcGFjZS5jb20+IHdyb3RlOg0KPiA+IA0KPiA+IE9uIFRodSwgMjAxOS0wMS0w
MyBhdCAxNzo0OSAtMDUwMCwgQ2h1Y2sgTGV2ZXIgd3JvdGU6DQo+ID4gPiA+IE9uIEphbiAzLCAy
MDE5LCBhdCA0OjM1IFBNLCBDaHVjayBMZXZlciA8Y2h1Y2subGV2ZXJAb3JhY2xlLmNvbQ0KPiA+
ID4gPiA+DQo+ID4gPiA+IHdyb3RlOg0KPiA+ID4gPiANCj4gPiA+ID4gPiBPbiBKYW4gMywgMjAx
OSwgYXQgNDoyOCBQTSwgVHJvbmQgTXlrbGVidXN0IDwNCj4gPiA+ID4gPiB0cm9uZG15QGhhbW1l
cnNwYWNlLmNvbT4gd3JvdGU6DQo+ID4gPiA+ID4gDQo+ID4gPiA+ID4gT24gVGh1LCAyMDE5LTAx
LTAzIGF0IDE2OjA3IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4gPiA+ID4gPiA+ID4gT24g
SmFuIDMsIDIwMTksIGF0IDM6NTMgUE0sIENodWNrIExldmVyIDwNCj4gPiA+ID4gPiA+ID4gY2h1
Y2subGV2ZXJAb3JhY2xlLmNvbT4NCj4gPiA+ID4gPiA+ID4gd3JvdGU6DQo+ID4gPiA+ID4gPiA+
IA0KPiA+ID4gPiA+ID4gPiA+IE9uIEphbiAzLCAyMDE5LCBhdCAxOjQ3IFBNLCBUcm9uZCBNeWts
ZWJ1c3QgPA0KPiA+ID4gPiA+ID4gPiA+IHRyb25kbXlAaGFtbWVyc3BhY2UuY29tPiB3cm90ZToN
Cj4gPiA+ID4gPiA+ID4gPiANCj4gPiA+ID4gPiA+ID4gPiBPbiBUaHUsIDIwMTktMDEtMDMgYXQg
MTM6MjkgLTA1MDAsIENodWNrIExldmVyIHdyb3RlOg0KPiA+ID4gPiA+ID4gPiA+ID4gKwlyZWNs
ZW4gPSByZXEtPnJxX3NuZF9idWYubGVuOw0KPiA+ID4gPiA+ID4gPiA+ID4gKwltYXJrZXIgPSBj
cHVfdG9fYmUzMihSUENfTEFTVF9TVFJFQU1fRlJBR01FTlQgfA0KPiA+ID4gPiA+ID4gPiA+ID4g
cmVjbGVuKTsNCj4gPiA+ID4gPiA+ID4gPiA+ICsJcmV0dXJuIGtlcm5lbF9zZW5kbXNnKHRyYW5z
cG9ydC0+c29jaywgJm1zZywNCj4gPiA+ID4gPiA+ID4gPiA+ICZpb3YsIDEsDQo+ID4gPiA+ID4g
PiA+ID4gPiBpb3YuaW92X2xlbik7DQo+ID4gPiA+ID4gPiA+ID4gDQo+ID4gPiA+ID4gPiA+ID4g
U28gd2hhdCBkb2VzIHRoaXMgZG8gZm9yIHBlcmZvcm1hbmNlPyBJJ2QgZXhwZWN0IHRoYXQNCj4g
PiA+ID4gPiA+ID4gPiBhZGRpbmcNCj4gPiA+ID4gPiA+ID4gPiBhbm90aGVyDQo+ID4gPiA+ID4g
PiA+ID4gZGl2ZSBpbnRvIHRoZSBzb2NrZXQgbGF5ZXIgd2lsbCBjb21lIHdpdGggcGVuYWx0aWVz
Lg0KPiA+ID4gPiA+ID4gPiANCj4gPiA+ID4gPiA+ID4gTkZTdjMgb24gVENQLCBzZWM9c3lzLCA1
NkdicyBJQm9JUCwgdjQuMjAgKyBteSB2NC4yMQ0KPiA+ID4gPiA+ID4gPiBwYXRjaGVzDQo+ID4g
PiA+ID4gPiA+IGZpbywgOEtCIHJhbmRvbSwgNzAlIHJlYWQsIDMwJSB3cml0ZSwgMTYgdGhyZWFk
cywNCj4gPiA+ID4gPiA+ID4gaW9kZXB0aD0xNg0KPiA+ID4gPiA+ID4gPiANCj4gPiA+ID4gPiA+
ID4gV2l0aG91dCB0aGlzIHBhdGNoOg0KPiA+ID4gPiA+ID4gPiANCj4gPiA+ID4gPiA+ID4gcmVh
ZDogSU9QUz0yOC43aywgQlc9MjI0TWlCL3MNCj4gPiA+ID4gPiA+ID4gKDIzNU1CL3MpKDExLjJH
aUIvNTEwOTJtc2VjKQ0KPiA+ID4gPiA+ID4gPiB3cml0ZTogSU9QUz0xMi4zaywgQlc9OTYuM01p
Qi9zDQo+ID4gPiA+ID4gPiA+ICgxMDFNQi9zKSg0OTE4TWlCLzUxMDkybXNlYykNCj4gPiA+ID4g
PiA+ID4gDQo+ID4gPiA+ID4gPiA+IFdpdGggdGhpcyBwYXRjaDoNCj4gPiA+ID4gPiA+ID4gDQo+
ID4gPiA+ID4gPiA+IHJlYWQ6IElPUFM9MjguNmssIEJXPTIyNE1pQi9zDQo+ID4gPiA+ID4gPiA+
ICgyMzVNQi9zKSgxMS4yR2lCLzUxMjc2bXNlYykNCj4gPiA+ID4gPiA+ID4gd3JpdGU6IElPUFM9
MTIuM2ssIEJXPTk1LjhNaUIvcw0KPiA+ID4gPiA+ID4gPiAoMTAwTUIvcykoNDkxNE1pQi81MTI3
Nm1zZWMpDQo+ID4gPiA+ID4gPiA+IA0KPiA+ID4gPiA+ID4gPiBTZWVtcyBsaWtlIHRoYXQncyBp
biB0aGUgbm9pc2UuDQo+ID4gPiA+ID4gPiANCj4gPiA+ID4gPiA+IFNpZ2guIFRoYXQncyBiZWNh
dXNlIGl0IHdhcyB0aGUgc2FtZSBrZXJuZWwuIEFnYWluLCB3aXRoDQo+ID4gPiA+ID4gPiBmZWVs
aW5nOg0KPiA+ID4gPiA+ID4gDQo+ID4gPiA+ID4gPiA0LjIwLjAtcmM3LTAwMDQ4LWc5Mjc0MjU0
Og0KPiA+ID4gPiA+ID4gcmVhZDogSU9QUz0yOC42aywgQlc9MjI0TWlCL3MgKDIzNU1CL3MpKDEx
LjJHaUIvNTEyNzZtc2VjKQ0KPiA+ID4gPiA+ID4gd3JpdGU6IElPUFM9MTIuM2ssIEJXPTk1LjhN
aUIvcw0KPiA+ID4gPiA+ID4gKDEwME1CL3MpKDQ5MTRNaUIvNTEyNzZtc2VjKQ0KPiA+ID4gPiA+
ID4gDQo+ID4gPiA+ID4gPiA0LjIwLjAtcmM3LTAwMDQ5LWdhNGRlYTE1Og0KPiA+ID4gPiA+ID4g
cmVhZDogSU9QUz0yNy4yaywgQlc9MjEyTWlCL3MgKDIyM01CL3MpKDExLjJHaUIvNTM5Nzltc2Vj
KQ0KPiA+ID4gPiA+ID4gd3JpdGU6IElPUFM9MTEuN2ssIEJXPTkxLjFNaUIvcw0KPiA+ID4gPiA+
ID4gKDk1LjVNQi9zKSg0OTE3TWlCLzUzOTc5bXNlYykNCj4gPiA+ID4gPiA+IA0KPiA+ID4gPiA+
IA0KPiA+ID4gPiA+IFNvIGFib3V0IGEgNSUgcmVkdWN0aW9uIGluIHBlcmZvcm1hbmNlPw0KPiA+
ID4gPiANCj4gPiA+ID4gT24gdGhpcyB3b3JrbG9hZCwgeWVzLg0KPiA+ID4gPiANCj4gPiA+ID4g
Q291bGQgc2VuZCB0aGUgcmVjb3JkIG1hcmtlciBpbiB4c19zZW5kX2t2ZWMgd2l0aCB0aGUgaGVh
ZFswXQ0KPiA+ID4gPiBpb3ZlYy4NCj4gPiA+ID4gSSdtIGdvaW5nIHRvIHRyeSB0aGF0IG5leHQu
DQo+ID4gPiANCj4gPiA+IFRoYXQgaGVscHM6DQo+ID4gPiANCj4gPiA+IExpbnV4IDQuMjAuMC1y
YzctMDAwNDktZzY2NGY2NzkgIzY1MSBTTVAgVGh1IEphbiAzIDE3OjM1OjI2IEVTVA0KPiA+ID4g
MjAxOQ0KPiA+ID4gDQo+ID4gPiAgIHJlYWQ6IElPUFM9MjguN2ssIEJXPTIyNE1pQi9zICgyMzVN
Qi9zKSgxMS4yR2lCLzUxMTg1bXNlYykNCj4gPiA+ICB3cml0ZTogSU9QUz0xMi4zaywgQlc9OTYu
MU1pQi9zICgxMDFNQi9zKSg0OTE5TWlCLzUxMTg1bXNlYykNCj4gPiA+IA0KPiA+IA0KPiA+IElu
dGVyZXN0aW5nLi4uIFBlcmhhcHMgd2UgbWlnaHQgYmUgYWJsZSB0byBla2Ugb3V0IGEgZmV3IG1v
cmUNCj4gPiBwZXJjZW50DQo+ID4gcGVyZm9ybWFuY2Ugb24gZmlsZSB3cml0ZXMgYnkgYWxzbyBj
b252ZXJ0aW5nIHhzX3NlbmRfcGFnZWRhdGEoKSB0bw0KPiA+IHVzZQ0KPiA+IGEgc2luZ2xlIHNv
Y2tfc2VuZG1zZygpIHcvIGlvdl9pdGVyIHJhdGhlciB0aGFuIGxvb3BpbmcgdGhyb3VnaA0KPiA+
IHNldmVyYWwNCj4gPiBjYWxscyB0byBzZW5kcGFnZSgpPw0KPiANCj4gSU1PLi4uDQo+IA0KPiBG
b3Igc21hbGwgcmVxdWVzdHMgKHNheSwgc21hbGxlciB0aGFuIDE3IHBhZ2VzKSwgcGFja2luZyB0
aGUgaGVhZCwNCj4gcGFnZXZlYywNCj4gYW5kIHRhaWwgaW50byBhbiBpb3ZfaXRlciBhbmQgc2Vu
ZGluZyB0aGVtIGFsbCB2aWEgYSBzaW5nbGUNCj4gc29ja19zZW5kbXNnDQo+IGNhbGwgd291bGQg
bGlrZWx5IGJlIGVmZmljaWVudC4NCj4gDQo+IEZvciBsYXJnZXIgcmVxdWVzdHMsIG90aGVyIG92
ZXJoZWFkcyB3b3VsZCBkb21pbmF0ZS4gQW5kIHlvdSdkIGhhdmUNCj4gdG8ga2VlcCBhcm91bmQg
YW4gaXRlciBhcnJheSB0aGF0IGhlbGQgMjU3IGVudHJpZXMuLi4gWW91IGNvdWxkIHBhc3MNCj4g
YQ0KPiBsYXJnZSBwYWdldmVjIHRvIHNvY2tfc2VuZG1zZyBpbiBzbWFsbGVyIGNodW5rcy4NCj4g
DQo+IEFyZSB5b3UgdGhpbmtpbmcgb2YgY29udmVydGluZyB4c19zZW5kcGFnZXMgKG9yIGV2ZW4g
eGRyX2J1ZnMpIHRvIHVzZQ0KPiBpb3ZfaXRlciBkaXJlY3RseT8NCg0KRm9yIG5vdywgSSB3YXMg
dGhpbmtpbmcgb2YganVzdCBjb252ZXJ0aW5nIHhzX3NlbmRwYWdlcyB0byBjYWxsDQp4ZHJfYWxs
b2NfYnZlYygpLCBhbmQgdGhlbiBkbyB0aGUgZXF1aXZhbGVudCBvZiB3aGF0IHhzX3JlYWRfYnZl
YygpDQpkb2VzIGZvciByZWNlaXZlcyB0b2RheS4NCg0KVGhlIG5leHQgc3RlcCBpcyB0byBjb252
ZXJ0IHhkcl9idWZzIHRvIHVzZSBidmVjcyBuYXRpdmVseSBpbnN0ZWFkIG9mDQpoYXZpbmcgdG8g
YWxsb2NhdGUgdGhlbSB0byBzaGFkb3cgdGhlIGFycmF5IG9mIHBhZ2VzLiBJIGJlbGlldmUgc29t
ZW9uZQ0Kd2FzIHdvcmtpbmcgb24gYWxsb3dpbmcgYSBzaW5nbGUgYnZlYyB0byB0YWtlIGFuIGFy
cmF5IG9mIHBhZ2VzDQooY29udGFpbmluZyBjb250aWd1b3VzIGRhdGEpLCB3aGljaCB3b3VsZCBt
YWtlIHRoYXQgY29udmVyc2lvbiBhbG1vc3QNCnRyaXZpYWwuDQoNClRoZSBmaW5hbCBzdGVwIHdv
dWxkIGJlIHRvIGRvIGFzIHlvdSBzYXksIHRvIHBhY2sgdGhlIGt2ZWNzIGludG8gdGhlDQpzYW1l
IGNhbGwgdG8gc29ja19zZW5kbXNnKCkgYXMgdGhlIGJ2ZWNzLiBXZSBtaWdodCBpbWFnaW5lIGFk
ZGluZyBhIG5ldw0KdHlwZSBvZiBpb3ZfaXRlciB0aGF0IGNhbiBpdGVyYXRlIG92ZXIgYW4gYXJy
YXkgb2Ygc3RydWN0IGlvdl9pdGVyIGluDQpvcmRlciB0byBkZWFsIHdpdGggdGhpcyBjYXNlPw0K
DQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1t
ZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
