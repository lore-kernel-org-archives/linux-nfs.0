Return-Path: <SRS0=F+UG=PM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FFC5C43387
	for <linux-nfs@archiver.kernel.org>; Fri,  4 Jan 2019 04:00:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D88662087F
	for <linux-nfs@archiver.kernel.org>; Fri,  4 Jan 2019 04:00:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Uqc8Kj08"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727321AbfADEAT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 23:00:19 -0500
Received: from mail-eopbgr810131.outbound.protection.outlook.com ([40.107.81.131]:4256
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726747AbfADEAS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Jan 2019 23:00:18 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=aHqgeFvvOEE/WJK57Ne+94u3USWGTuZN5AcGGkya2gw=;
 b=Uqc8Kj08KwbJ9RHGc5jwIPCmuZZFb8B/pGr/E69Vo7EbivSpJAUcX9tTLufkRHNKmIeSs6fHdBj4sevgUscLSjOY2DiiSxTwDnLiPmUfMY3vE/pdoZsV6cn7bPDGMIPgdM2dXncreJ2e2mWZ6qfnWh1Ik82e2H3KjkhhqqQp5Dc=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2349.namprd13.prod.outlook.com (52.135.94.32) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1495.6; Fri, 4 Jan 2019 04:00:13 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%3]) with mapi id 15.20.1495.005; Fri, 4 Jan 2019
 04:00:13 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Remove rpc_xprt::tsh_size
Thread-Topic: [PATCH] SUNRPC: Remove rpc_xprt::tsh_size
Thread-Index: AQHUo5McwpQQZImh0EO/lRKWh6zKuqWd4oaAgAAjNgCAAAPogIAABaEAgAAB8ACAABTMAIAAVtCA
Date:   Fri, 4 Jan 2019 04:00:11 +0000
Message-ID: <1d6779ff05f2d31c4eccd048acbb28563bc9b79b.camel@hammerspace.com>
References: <20190103182649.4148.19838.stgit@manet.1015granger.net>
         <0331de80b8161f8bf16a92de20049cafb0c228da.camel@hammerspace.com>
         <90B38E07-3241-4CCD-A4C8-AB78BADFB0CD@oracle.com>
         <791EE189-59E5-4D58-9CF6-6D2CFC6C1210@oracle.com>
         <076cce85045dbaab3ca40947b2599f96cff66b53.camel@hammerspace.com>
         <1353EAC5-5BEE-461E-A11E-31F00FC7B946@oracle.com>
         <CE340D31-4F14-4C6F-B7C8-958754394C08@oracle.com>
In-Reply-To: <CE340D31-4F14-4C6F-B7C8-958754394C08@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2349;6:iJt7C+9PMobjlU72PfCy7dzx78iO1Jtvder5L4by/M7owLoKprv7H/LBFGDtYq0kE9p6qmJRe0bnSe+/tkUk04vIvsIkHv5GM1Lct0gwRitnDT6xGwFLoNiAd+gGkmjDZd+5fzU3bN4KUWy+HUg917oTFj02qCzQdSlJVt/v7bvzYfd1mJxmuGMHe3Sh0Yty5np0p1QHQOg+Ah3/rQz/aTwz1yZ8jLJcIqoYRiR5SzXSTBTvUL0vOxDU6QXKaAS5WD+Rxl3yJ515syrvbMV0Lxhr2v5YeWmxVbGd5X0ql7pUPD9NnhgzCgD6AsMqH6Nfw+sBId5JLKJdVgXzNZ5sMm9m1mVwJSw+/wpeBijC4oOEhxusfj+q+OJjzkm9cb1tLFmB/PTMUjv73uAklbdq8Oav/3uNm6uGki93nesHff1Kf9oNJhv26frItM+wfmXoL9HKQ5/DLlze4ix5u2iT8w==;5:2sAQetoMoaETAX+Ad6LjJH9I/6wMkAK7GBnDTnGAuzr70mBYxPoO05znqUe06d67ymua0e2RVLuGmYPOONhLPsOVfx8olt3f8Taecd+ikRwsgjEt7dSl3JkuR29jcEm/kCaP4hkM/8HDfmLKC+WyggvoCkwp1nqC75be+9MAdVpiEnxuVKwmFEjWE5mrM1ZyPeF1LutrNxDrxwDAK6tUwg==;7:8avX5QgOj9rKYwn6PnvhYtq55yljZsa3idR9xIabvLLNz/leWo5B46jmK6gVTjB7CUtEYXDsREosEqzfAVUN0UHVNEQs5d5p+TjmgHfGwjG7bl4kI4k6u2u065YqflAzcrsIPTcZvLUe8qjUP8WZFQ==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: ed243f22-5905-48d0-e820-08d671f92113
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2349;
x-ms-traffictypediagnostic: SN6PR13MB2349:
x-microsoft-antispam-prvs: <SN6PR13MB2349B1E3E797E0CB347820CAB88E0@SN6PR13MB2349.namprd13.prod.outlook.com>
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(908002)(999002)(5005026)(6040522)(8220060)(2401047)(8121501046)(10201501046)(3002001)(3231475)(944501520)(52105112)(93006095)(93001095)(6041310)(20161123562045)(20161123558120)(201703131423095)(20161123555045)(201703061421075)(20161123564045)(20161123560045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2349;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2349;
x-forefront-prvs: 0907F58A24
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(346002)(376002)(136003)(199004)(189003)(508600001)(6506007)(106356001)(53546011)(76176011)(102836004)(71190400001)(6916009)(86362001)(36756003)(305945005)(71200400001)(5660300001)(14454004)(7736002)(68736007)(105586002)(6512007)(53936002)(6246003)(2351001)(118296001)(97736004)(3846002)(256004)(6116002)(186003)(26005)(476003)(11346002)(25786009)(2616005)(5640700003)(229853002)(66066001)(99286004)(486006)(4326008)(2501003)(2906002)(81156014)(8676002)(8936002)(6436002)(81166006)(6486002)(93886005)(446003);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2349;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 3fqFcw2CpZABHDWWl7YVHpdkQ/Go79EbVnUo2qE2+nbckYatsJXi2aZb6B8slk6jICH7P/v9gOWkfPa+xKrvm6/Tc+Feh1KPHsVK+gobrI0XjQMX4idXTKHd9BD1QA5GmHNUBrNxsRvqv82ypKTk8pDyV0CKM/7Bh2Aob005uwBH64mAUfPe/h6iC64RDpK+hj10+f1Ols1bUWWkYvKrJrP1tMBCzrL0knWAfw3WkN165JotPBwQUpkkpfVNDmlxnRnkIz/p7wqsJ+k5tkA4L9HcEDqXqpkX/zpR+CqV+puMv01pAuWa0btODeBGqyl8
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <8EF7C28462C8B748BA843547C69AEAAB@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ed243f22-5905-48d0-e820-08d671f92113
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Jan 2019 04:00:13.3845
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2349
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTAxLTAzIGF0IDE3OjQ5IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBKYW4gMywgMjAxOSwgYXQgNDozNSBQTSwgQ2h1Y2sgTGV2ZXIgPGNodWNrLmxldmVyQG9y
YWNsZS5jb20+DQo+ID4gd3JvdGU6DQo+ID4gDQo+ID4gPiBPbiBKYW4gMywgMjAxOSwgYXQgNDoy
OCBQTSwgVHJvbmQgTXlrbGVidXN0IDwNCj4gPiA+IHRyb25kbXlAaGFtbWVyc3BhY2UuY29tPiB3
cm90ZToNCj4gPiA+IA0KPiA+ID4gT24gVGh1LCAyMDE5LTAxLTAzIGF0IDE2OjA3IC0wNTAwLCBD
aHVjayBMZXZlciB3cm90ZToNCj4gPiA+ID4gPiBPbiBKYW4gMywgMjAxOSwgYXQgMzo1MyBQTSwg
Q2h1Y2sgTGV2ZXIgPA0KPiA+ID4gPiA+IGNodWNrLmxldmVyQG9yYWNsZS5jb20+DQo+ID4gPiA+
ID4gd3JvdGU6DQo+ID4gPiA+ID4gDQo+ID4gPiA+ID4gPiBPbiBKYW4gMywgMjAxOSwgYXQgMTo0
NyBQTSwgVHJvbmQgTXlrbGVidXN0IDwNCj4gPiA+ID4gPiA+IHRyb25kbXlAaGFtbWVyc3BhY2Uu
Y29tPiB3cm90ZToNCj4gPiA+ID4gPiA+IA0KPiA+ID4gPiA+ID4gT24gVGh1LCAyMDE5LTAxLTAz
IGF0IDEzOjI5IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4gPiA+ID4gPiA+ID4gKwlyZWNs
ZW4gPSByZXEtPnJxX3NuZF9idWYubGVuOw0KPiA+ID4gPiA+ID4gPiArCW1hcmtlciA9IGNwdV90
b19iZTMyKFJQQ19MQVNUX1NUUkVBTV9GUkFHTUVOVCB8DQo+ID4gPiA+ID4gPiA+IHJlY2xlbik7
DQo+ID4gPiA+ID4gPiA+ICsJcmV0dXJuIGtlcm5lbF9zZW5kbXNnKHRyYW5zcG9ydC0+c29jaywg
Jm1zZywgJmlvdiwgMSwNCj4gPiA+ID4gPiA+ID4gaW92Lmlvdl9sZW4pOw0KPiA+ID4gPiA+ID4g
DQo+ID4gPiA+ID4gPiBTbyB3aGF0IGRvZXMgdGhpcyBkbyBmb3IgcGVyZm9ybWFuY2U/IEknZCBl
eHBlY3QgdGhhdA0KPiA+ID4gPiA+ID4gYWRkaW5nDQo+ID4gPiA+ID4gPiBhbm90aGVyDQo+ID4g
PiA+ID4gPiBkaXZlIGludG8gdGhlIHNvY2tldCBsYXllciB3aWxsIGNvbWUgd2l0aCBwZW5hbHRp
ZXMuDQo+ID4gPiA+ID4gDQo+ID4gPiA+ID4gTkZTdjMgb24gVENQLCBzZWM9c3lzLCA1NkdicyBJ
Qm9JUCwgdjQuMjAgKyBteSB2NC4yMSBwYXRjaGVzDQo+ID4gPiA+ID4gZmlvLCA4S0IgcmFuZG9t
LCA3MCUgcmVhZCwgMzAlIHdyaXRlLCAxNiB0aHJlYWRzLCBpb2RlcHRoPTE2DQo+ID4gPiA+ID4g
DQo+ID4gPiA+ID4gV2l0aG91dCB0aGlzIHBhdGNoOg0KPiA+ID4gPiA+IA0KPiA+ID4gPiA+IHJl
YWQ6IElPUFM9MjguN2ssIEJXPTIyNE1pQi9zICgyMzVNQi9zKSgxMS4yR2lCLzUxMDkybXNlYykN
Cj4gPiA+ID4gPiB3cml0ZTogSU9QUz0xMi4zaywgQlc9OTYuM01pQi9zICgxMDFNQi9zKSg0OTE4
TWlCLzUxMDkybXNlYykNCj4gPiA+ID4gPiANCj4gPiA+ID4gPiBXaXRoIHRoaXMgcGF0Y2g6DQo+
ID4gPiA+ID4gDQo+ID4gPiA+ID4gcmVhZDogSU9QUz0yOC42aywgQlc9MjI0TWlCL3MgKDIzNU1C
L3MpKDExLjJHaUIvNTEyNzZtc2VjKQ0KPiA+ID4gPiA+IHdyaXRlOiBJT1BTPTEyLjNrLCBCVz05
NS44TWlCL3MgKDEwME1CL3MpKDQ5MTRNaUIvNTEyNzZtc2VjKQ0KPiA+ID4gPiA+IA0KPiA+ID4g
PiA+IFNlZW1zIGxpa2UgdGhhdCdzIGluIHRoZSBub2lzZS4NCj4gPiA+ID4gDQo+ID4gPiA+IFNp
Z2guIFRoYXQncyBiZWNhdXNlIGl0IHdhcyB0aGUgc2FtZSBrZXJuZWwuIEFnYWluLCB3aXRoDQo+
ID4gPiA+IGZlZWxpbmc6DQo+ID4gPiA+IA0KPiA+ID4gPiA0LjIwLjAtcmM3LTAwMDQ4LWc5Mjc0
MjU0Og0KPiA+ID4gPiAgcmVhZDogSU9QUz0yOC42aywgQlc9MjI0TWlCL3MgKDIzNU1CL3MpKDEx
LjJHaUIvNTEyNzZtc2VjKQ0KPiA+ID4gPiB3cml0ZTogSU9QUz0xMi4zaywgQlc9OTUuOE1pQi9z
ICgxMDBNQi9zKSg0OTE0TWlCLzUxMjc2bXNlYykNCj4gPiA+ID4gDQo+ID4gPiA+IDQuMjAuMC1y
YzctMDAwNDktZ2E0ZGVhMTU6DQo+ID4gPiA+ICByZWFkOiBJT1BTPTI3LjJrLCBCVz0yMTJNaUIv
cyAoMjIzTUIvcykoMTEuMkdpQi81Mzk3OW1zZWMpDQo+ID4gPiA+IHdyaXRlOiBJT1BTPTExLjdr
LCBCVz05MS4xTWlCL3MgKDk1LjVNQi9zKSg0OTE3TWlCLzUzOTc5bXNlYykNCj4gPiA+ID4gDQo+
ID4gPiANCj4gPiA+IFNvIGFib3V0IGEgNSUgcmVkdWN0aW9uIGluIHBlcmZvcm1hbmNlPw0KPiA+
IA0KPiA+IE9uIHRoaXMgd29ya2xvYWQsIHllcy4NCj4gPiANCj4gPiBDb3VsZCBzZW5kIHRoZSBy
ZWNvcmQgbWFya2VyIGluIHhzX3NlbmRfa3ZlYyB3aXRoIHRoZSBoZWFkWzBdDQo+ID4gaW92ZWMu
DQo+ID4gSSdtIGdvaW5nIHRvIHRyeSB0aGF0IG5leHQuDQo+IA0KPiBUaGF0IGhlbHBzOg0KPiAN
Cj4gTGludXggNC4yMC4wLXJjNy0wMDA0OS1nNjY0ZjY3OSAjNjUxIFNNUCBUaHUgSmFuIDMgMTc6
MzU6MjYgRVNUIDIwMTkNCj4gDQo+ICAgIHJlYWQ6IElPUFM9MjguN2ssIEJXPTIyNE1pQi9zICgy
MzVNQi9zKSgxMS4yR2lCLzUxMTg1bXNlYykNCj4gICB3cml0ZTogSU9QUz0xMi4zaywgQlc9OTYu
MU1pQi9zICgxMDFNQi9zKSg0OTE5TWlCLzUxMTg1bXNlYykNCj4gDQoNCkludGVyZXN0aW5nLi4u
IFBlcmhhcHMgd2UgbWlnaHQgYmUgYWJsZSB0byBla2Ugb3V0IGEgZmV3IG1vcmUgcGVyY2VudA0K
cGVyZm9ybWFuY2Ugb24gZmlsZSB3cml0ZXMgYnkgYWxzbyBjb252ZXJ0aW5nIHhzX3NlbmRfcGFn
ZWRhdGEoKSB0byB1c2UNCmEgc2luZ2xlIHNvY2tfc2VuZG1zZygpIHcvIGlvdl9pdGVyIHJhdGhl
ciB0aGFuIGxvb3BpbmcgdGhyb3VnaCBzZXZlcmFsDQpjYWxscyB0byBzZW5kcGFnZSgpPw0KLS0g
DQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3Bh
Y2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
