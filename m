Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0B4BC43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 14:07:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6B3EC2070D
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 14:07:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="DTNJQc01"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729885AbfACOH5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 09:07:57 -0500
Received: from mail-eopbgr760121.outbound.protection.outlook.com ([40.107.76.121]:6559
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728132AbfACOH4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Jan 2019 09:07:56 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=uKX8yH2tfS3CC5ggY0G+kMCKWGLLYtMm0fS9LxkrMOc=;
 b=DTNJQc01CjRab7R/LQTyEqUCj+hYnMFadQsQYY5GVVcQ2Wy6iLjV5nIdVL7ZJ2HkkOUG2q3UtN2rhwqLS4jPjlLDMcj1HBgCi+8w2HMhXVXjN07au1/hwhtR90e6IXgnsLVwAKV9TcWMnwD4+ump+XaArdvpYUR+aJeamEAOyNI=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2416.namprd13.prod.outlook.com (52.135.94.160) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1495.4; Thu, 3 Jan 2019 14:07:51 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%3]) with mapi id 15.20.1495.005; Thu, 3 Jan 2019
 14:07:51 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "geert@linux-m68k.org" <geert@linux-m68k.org>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>
Subject: Re: [PATCH v2] SUNRPC: Fix TCP receive code on archs with
 flush_dcache_page()
Thread-Topic: [PATCH v2] SUNRPC: Fix TCP receive code on archs with
 flush_dcache_page()
Thread-Index: AQHUoyua7l5ZKHM4hESBaVcRAYnWxaWdVHGAgABAooA=
Date:   Thu, 3 Jan 2019 14:07:51 +0000
Message-ID: <3f4ee085ffde4c9823719e6607f521836c4158cf.camel@hammerspace.com>
References: <20190103061324.16607-1-trond.myklebust@hammerspace.com>
         <CAMuHMdXpHLjJBMQWDaWKYQFfY4_3yVi9NdBYnWr6Xfzttrb5iA@mail.gmail.com>
In-Reply-To: <CAMuHMdXpHLjJBMQWDaWKYQFfY4_3yVi9NdBYnWr6Xfzttrb5iA@mail.gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2416;6:Hj4HNz677zw9IMpphNIVGg6pnZpBa9dJMNqSwD2j9+hNZ8C2D3SY3rxAqHHlIWyP2hqo1cl7HH8oleknI0QF41o57KfeGwj4zv/yS5kB98NlU8GELET1aIrvnvs5q4+No1DowcLjJ4CuIGXoofi5fwkXbz4PWXzVMCcQh1tI59TCTOz53MOUIyYm9G1JpYyoYaNGH44Omgq8MzFI5Jh65DX+vu9nuLpW3ovUzH6PXr0jxkvCyutqW2o4AoBUDIWHkLcTheH2/C56521jANieNj3TG46UDXdxMy+P7NniO1O8UDFfyQSyu8VBgXTw1KKgQOT8uIM0I2Eg2fRIXWZQVf2BVnFFnR3TBrQwTnqygQfrfMMRnuFJLPcP2NC77g9LHrBhXMPQHSt+KU47Lc3qgSwPbO4THKdJp9qNLAKu7ag5g3ZJT/TxGezC1tqUVBduP05oOns1CmEHltyqn5VD0A==;5:hDTzc8Nq6Dl4SNj2aJL+rZe8suoytsb63T3a/1TuFtKkLWumtoKOsLz3GDf/1CFr+869QNyR/J/7JO+U+KYU3xlXMWfdReW7bNuCwW666J/2fs/Lk5OyVyQ8Rthm41rqCIWcmUtaaJkXOFpJV538UxLH1D+uOPBkUp48uQypyqacwzX9L/BAUXb10ISAh6nHti5Yr2mJXjpsAyfHxIgZDw==;7:6B0FJYw3FPk8H1FF7yIR596IFU8tDo0e24dEV23ElCrasl++Fujd5sOm1DGdhAYXPAvUiDWEpxQdmK4O9lclRBOFdv/yDtiajux09SSmKQ4mhK/esrD9VuKi8Fsj6t1RzL8JhSvlDlU0hbxyLJFRTg==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 4e85fce7-e12d-4d7b-f793-08d67184d93b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2416;
x-ms-traffictypediagnostic: SN6PR13MB2416:
x-microsoft-antispam-prvs: <SN6PR13MB241609EC6E0481BDE8B8B12AB88D0@SN6PR13MB2416.namprd13.prod.outlook.com>
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(908002)(999002)(5005026)(6040522)(8220060)(2401047)(8121501046)(93006095)(93001095)(10201501046)(3231475)(944501520)(52105112)(3002001)(6041310)(20161123564045)(20161123558120)(20161123560045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123562045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2416;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2416;
x-forefront-prvs: 0906E83A25
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(366004)(346002)(396003)(136003)(39830400003)(189003)(199004)(11346002)(486006)(476003)(25786009)(446003)(2616005)(68736007)(186003)(118296001)(5660300001)(6512007)(26005)(5640700003)(54906003)(6916009)(6436002)(6246003)(6486002)(478600001)(14454004)(229853002)(97736004)(6506007)(4326008)(102836004)(53546011)(99286004)(53936002)(316002)(76176011)(2351001)(2906002)(106356001)(105586002)(36756003)(8936002)(305945005)(8676002)(81156014)(81166006)(1730700003)(66066001)(6116002)(71190400001)(86362001)(2501003)(7736002)(71200400001)(256004)(3846002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2416;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: kySP1o/OsXgFkhk6HyW4rCxoLAwhaRbk83/9I+aYZ2c2z9qBmNdqD6996yFabeUf8lWrB0NBdCyH6/T/RoPxE6aEhIKZCDlSB7uDoXoZQ4plu5JeOAgCnxjTIAiVcCNKv7JE9GkYxKLV/nuC87vcJaozm2VBD39beM6HwAFWuv5IG0U3jfel6igZS+Sw535WPV2OCkMAmjMZLcwmNjyG9gD1J7BmRVNLxfnWelcY8vvTUqidAkU0Xr3UaI8JjqXoNI5UzdQS68qu9/mNwdtWqd75hwalHGSTt7Yf4xdabOY/GYhw87lOvdfXJPODZX4X
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <FFD78518198C2540A69C07D6BA94791F@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 4e85fce7-e12d-4d7b-f793-08d67184d93b
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Jan 2019 14:07:51.2774
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2416
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTAxLTAzIGF0IDExOjE2ICswMTAwLCBHZWVydCBVeXR0ZXJob2V2ZW4gd3Jv
dGU6DQo+IEhpIFRyb25kLA0KPiANCj4gT24gVGh1LCBKYW4gMywgMjAxOSBhdCA3OjE0IEFNIFRy
b25kIE15a2xlYnVzdCA8dHJvbmRteUBnbWFpbC5jb20+DQo+IHdyb3RlOg0KPiA+IEFmdGVyIHJl
Y2VpdmluZyBkYXRhIGludG8gdGhlIHBhZ2UgY2FjaGUsIHdlIG5lZWQgdG8gY2FsbA0KPiA+IGZs
dXNoX2RjYWNoZV9wYWdlKCkNCj4gPiBmb3IgdGhlIGFyY2hpdGVjdHVyZXMgdGhhdCBkZWZpbmUg
aXQuDQo+ID4gDQo+ID4gRml4ZXM6IDI3N2U0YWI3ZDUzMGIgKCJTVU5SUEM6IFNpbXBsaWZ5IFRD
UCByZWNlaXZlIGNvZGUgYnkNCj4gPiBzd2l0Y2hpbmcuLi4iKQ0KPiA+IFJlcG9ydGVkLWJ5OiBH
ZWVydCBVeXR0ZXJob2V2ZW4gPGdlZXJ0QGxpbnV4LW02OGsub3JnPg0KPiA+IFNpZ25lZC1vZmYt
Ynk6IFRyb25kIE15a2xlYnVzdCA8dHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbT4NCj4g
PiBDYzogc3RhYmxlQHZnZXIua2VybmVsLm9yZyAjIHY0LjIwDQo+IA0KPiBUaGFua3MgZm9yIHlv
dXIgcGF0Y2ghDQo+IA0KPiA+IC0tLSBhL25ldC9zdW5ycGMveHBydHNvY2suYw0KPiA+ICsrKyBi
L25ldC9zdW5ycGMveHBydHNvY2suYw0KPiA+IEBAIC00OCw2ICs0OCw3IEBADQo+ID4gICNpbmNs
dWRlIDxuZXQvdWRwLmg+DQo+ID4gICNpbmNsdWRlIDxuZXQvdGNwLmg+DQo+ID4gICNpbmNsdWRl
IDxsaW51eC9idmVjLmg+DQo+ID4gKyNpbmNsdWRlIDxsaW51eC9oaWdobWVtLmg+DQo+ID4gICNp
bmNsdWRlIDxsaW51eC91aW8uaD4NCj4gPiANCj4gPiAgI2luY2x1ZGUgPHRyYWNlL2V2ZW50cy9z
dW5ycGMuaD4NCj4gPiBAQCAtMzgwLDYgKzM4MSwyNyBAQCB4c19yZWFkX2Rpc2NhcmQoc3RydWN0
IHNvY2tldCAqc29jaywgc3RydWN0DQo+ID4gbXNnaGRyICptc2csIGludCBmbGFncywNCj4gPiAg
ICAgICAgIHJldHVybiBzb2NrX3JlY3Ztc2coc29jaywgbXNnLCBmbGFncyk7DQo+ID4gIH0NCj4g
PiANCj4gPiArI2lmIEFSQ0hfSU1QTEVNRU5UU19GTFVTSF9EQ0FDSEVfUEFHRQ0KPiA+ICtzdGF0
aWMgdm9pZA0KPiA+ICt4c19mbHVzaF9idmVjKGNvbnN0IHN0cnVjdCBiaW9fdmVjICpidmVjLCBz
aXplX3QgY291bnQsIHNpemVfdA0KPiA+IHNlZWspDQo+ID4gK3sNCj4gPiArICAgICAgIHN0cnVj
dCBidmVjX2l0ZXIgYmksIF9fc3RhcnQgPSB7DQo+IA0KPiBBcyBmb3JfZWFjaF9idmVjKCkgYXNz
aWducyBfX3N0YXJ0IHRvIGJpLCBhbmQgeW91IGRvbid0IG5lZWQgX19zdGFydA0KPiBhZnRlcndh
cmRzLCBib3RoIHZhcmlhYmxlcyBjYW4gYmUgbWVyZ2VkIGludG8gYSBzaW5nbGUgb25lLg0KPiBC
dXQgcGVyaGFwcyB0aGF0IHdvdWxkIG1ha2UgdG9vIG1hbnkgYXNzdW1wdGlvbnMgYWJvdXQgdGhl
DQo+IGltcGxlbWVudGF0aW9uIG9mIGZvcl9lYWNoX2J2ZWMoKT8NCg0KTm8sIHRoYXQncyBhIGdv
b2Qgc3VnZ2VzdGlvbi4gSSd2ZSBzZW50IG91dCBhIChob3BlZnVsbHkpIGZpbmFsIHYzIHdpdGgN
CnRoYXQgY2hhbmdlLg0KDQo+IA0KPiA+ICsgICAgICAgICAgICAgICAuYmlfc2l6ZSA9IGNvdW50
LA0KPiA+ICsgICAgICAgfTsNCj4gPiArICAgICAgIHN0cnVjdCBiaW9fdmVjIGJ2Ow0KPiA+ICsN
Cj4gPiArICAgICAgIGJ2ZWNfaXRlcl9hZHZhbmNlKGJ2ZWMsICZfX3N0YXJ0LCBzZWVrICYgUEFH
RV9NQVNLKTsNCj4gPiArDQo+ID4gKyAgICAgICBmb3JfZWFjaF9idmVjKGJ2LCBidmVjLCBiaSwg
X19zdGFydCkNCj4gPiArICAgICAgICAgICAgICAgZmx1c2hfZGNhY2hlX3BhZ2UoYnYuYnZfcGFn
ZSk7DQo+ID4gK30NCj4gPiArI2Vsc2UNCj4gPiArc3RhdGljIGlubGluZSB2b2lkDQo+ID4gK3hz
X2ZsdXNoX2J2ZWMoY29uc3Qgc3RydWN0IGJpb192ZWMgKmJ2ZWMsIHNpemVfdCBjb3VudCwgc2l6
ZV90DQo+ID4gc2VlaykNCj4gPiArew0KPiA+ICt9DQo+ID4gKyNlbmRpZg0KPiA+ICsNCj4gPiAg
c3RhdGljIHNzaXplX3QNCj4gPiAgeHNfcmVhZF94ZHJfYnVmKHN0cnVjdCBzb2NrZXQgKnNvY2ss
IHN0cnVjdCBtc2doZHIgKm1zZywgaW50DQo+ID4gZmxhZ3MsDQo+ID4gICAgICAgICAgICAgICAg
IHN0cnVjdCB4ZHJfYnVmICpidWYsIHNpemVfdCBjb3VudCwgc2l6ZV90IHNlZWssDQo+ID4gc2l6
ZV90ICpyZWFkKQ0KPiA+IEBAIC00MTMsNiArNDM1LDcgQEAgeHNfcmVhZF94ZHJfYnVmKHN0cnVj
dCBzb2NrZXQgKnNvY2ssIHN0cnVjdA0KPiA+IG1zZ2hkciAqbXNnLCBpbnQgZmxhZ3MsDQo+ID4g
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBzZWVrICsgYnVmLT5wYWdlX2Jhc2UpOw0K
PiA+ICAgICAgICAgICAgICAgICBpZiAocmV0IDw9IDApDQo+ID4gICAgICAgICAgICAgICAgICAg
ICAgICAgZ290byBzb2NrX2VycjsNCj4gPiArICAgICAgICAgICAgICAgeHNfZmx1c2hfYnZlYyhi
dWYtPmJ2ZWMsIHJldCwgc2VlayArIGJ1Zi0NCj4gPiA+cGFnZV9iYXNlKTsNCj4gPiAgICAgICAg
ICAgICAgICAgb2Zmc2V0ICs9IHJldCAtIGJ1Zi0+cGFnZV9iYXNlOw0KPiA+ICAgICAgICAgICAg
ICAgICBpZiAob2Zmc2V0ID09IGNvdW50IHx8IG1zZy0+bXNnX2ZsYWdzICYNCj4gPiAoTVNHX0VP
UnxNU0dfVFJVTkMpKQ0KPiA+ICAgICAgICAgICAgICAgICAgICAgICAgIGdvdG8gb3V0Ow0KPiAN
Cj4gSSBkb24ndCB1bmRlcnN0YW5kIHRoZSBjb2RlIHdlbGwgZW5vdWdoIHRvIHNlZSB3aHkgdGhl
IGNhbGwgdG8NCj4geHNfZmx1c2hfYnZlYygpIGlzIG5lZWRlZCBpbiB0aGlzIGJyYW5jaCBvbmx5
LCBidXQgaXQgZG9lcyBmaXggVENQDQo+IE5GUyBvbiBSQlRYNDkyNywgc28NCj4gVGVzdGVkLWJ5
OiBHZWVydCBVeXR0ZXJob2V2ZW4gPGdlZXJ0QGxpbnV4LW02OGsub3JnPg0KDQpUaGFua3MhDQog
IFRyb25kDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWlu
ZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
