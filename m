Return-Path: <SRS0=XDbB=OV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9DCEC65BAF
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 16:56:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6D6382080F
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 16:56:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="jgJ2hsXD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D6382080F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727881AbeLLQ4N (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 11:56:13 -0500
Received: from mail-eopbgr820097.outbound.protection.outlook.com ([40.107.82.97]:36785
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727691AbeLLQ4N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Dec 2018 11:56:13 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=zYIr08b/l3A8oWtIRf0sZN+kt+BEcRmlDkdYmEAaV8E=;
 b=jgJ2hsXDGsLsqB3pPscFJ5mwap38poj0NPYodOuayV2W7mzr5vcLGURuNeYhIdeTtEVLdE2SVExveAuThjIiVwfvSyEAN1ic3IXNILLxS+KaWhy1BUUVpNJOaRfbJl2wNF6Ne16EtEciSaa5LAYBAD9cxaF43RcgCDTeBM5hyJ0=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2349.namprd13.prod.outlook.com (52.135.94.32) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1425.14; Wed, 12 Dec 2018 16:56:09 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1425.016; Wed, 12 Dec 2018
 16:56:09 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "dwysocha@redhat.com" <dwysocha@redhat.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] SUNRPC: Ensure XPRT_CONNECTED is cleared while
 handling TCP RST
Thread-Topic: [PATCH 1/1] SUNRPC: Ensure XPRT_CONNECTED is cleared while
 handling TCP RST
Thread-Index: AQHUkiHeJLBUoo3NPE2KzZb14GrSrKV7UuKA
Date:   Wed, 12 Dec 2018 16:56:09 +0000
Message-ID: <03049f893dfd265abb90fd2692bc41e1534f85d0.camel@hammerspace.com>
References: <20181212135157.4489-1-dwysocha@redhat.com>
         <20181212135157.4489-2-dwysocha@redhat.com>
In-Reply-To: <20181212135157.4489-2-dwysocha@redhat.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [24.75.238.68]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2349;6:c9Gp1CXRoUjCLsSPlgO4J7/BrkksWJe+awH22DbBRSALMAheqT4Y8rjDjIxHI2I47Krxxallk+XEHzd5mxOeyT7p8hmUVnOznnDsVC67ulpmd3NlqP0/hs0loPf3qMNElXUDajsbaERJiXpgOh4nNG7JKCcGrT8tcVJpu6usV3vZcdeYJikCZz28rzAazN6xibyx0VdjBtGi2ufgeylAJFuk8usRU0pA9w83jOfggEJpno3Fael9BRf4AHKXdneptPBKl+rbAgVDCs0eWdBrjnKiSJ0vO3BcSvybwKVarkZtLrFGm6zO9yD6Qjgo5f0Gdl1hiyfzt9SJdZ52l50BFoD7+XkQfGFut5cnPAIYLl6DEDn5vpEObCD2DJLTCAAdcGxBbuBVXqUzSkBfmq/GSf1VAxhC2Moctspv3wYXBCIoJ6VNf7QeNcMzj8rVZ2qSMVUeu2JVlF+l6Litw9Mnmg==;5:cEuj4pH5pQApPf0syGQjuiMo0izB2bJFFQcgrR7SN00sBNGFUTKKntY2mxKaz++l7SDPRNvJQo9ssj10qEO1f7RmM4ZClKHUJ0VhfWFMRcYD7kVsqaFtAm9OB+6Q6pilGeWD5y+gunSWTjD/nn7U6x1VfueHVzd7Uj0fIJ+O0+Y=;7:Qj0NsIP04ZgJqNIZLz18CsB/IV4yiVRs1kycdsHZjl/TpQoiwAgnIic+nUBb9MMxAYXw15/kA/fcNVVeH89C1B6j5Je+ONcJTBUQvIr16XIh/abR177Azok8Bc0RsUlK3GCzireBfpzP25hir4WmRQ==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 8e3d6a8d-7128-44b5-0f98-08d66052b70d
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2349;
x-ms-traffictypediagnostic: SN6PR13MB2349:
x-microsoft-antispam-prvs: <SN6PR13MB23498A6316CF2BAAA5C052B0B8A70@SN6PR13MB2349.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(8121501046)(5005006)(93006095)(93001095)(10201501046)(3231455)(999002)(944501520)(52105112)(3002001)(148016)(149066)(150057)(6041310)(20161123560045)(20161123558120)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123564045)(20161123562045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2349;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2349;
x-forefront-prvs: 0884AAA693
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(376002)(346002)(366004)(396003)(39830400003)(199004)(189003)(4326008)(14454004)(229853002)(186003)(86362001)(575784001)(26005)(5660300001)(6246003)(2501003)(3846002)(99286004)(6116002)(105586002)(106356001)(76176011)(8936002)(68736007)(2906002)(6506007)(305945005)(118296001)(102836004)(7736002)(81166006)(81156014)(8676002)(11346002)(446003)(476003)(2616005)(486006)(478600001)(6512007)(256004)(14444005)(97736004)(25786009)(316002)(71200400001)(71190400001)(110136005)(4001150100001)(6486002)(36756003)(6436002)(66066001)(53936002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2349;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: wLzPSA46RGcKfe+wSXNojkxJeah/15IcFzKfkRScw9Cj8SHgYNlExwwlTPHTFffO++Snd9NjpCNx3D924hDhJoWeo5CawMIlvvu7jieSq58dyrRQ96N0MDLf/LU6ajFgTIEGAp6HoKlH/rAVF6p/Avv5Q3EzZMJxQT+lJIM2bTOiWFkvDSZCeuWaaUEt1jDCrVdxChzHybenHcr7bUrJJYG0A+1Itx6PJiiuE6JVywa/5YZa8b6crOFV6potL1sGKKEo2tCyfPi0Oox9awyj3j2fXuIHrWFyr3IubXL7i2GOxd3ySyIEnm6d8im8Dlhv
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <FD9889BE3F7B7C4EAE5C0F6ACAF7CD67@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8e3d6a8d-7128-44b5-0f98-08d66052b70d
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Dec 2018 16:56:09.2804
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2349
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gV2VkLCAyMDE4LTEyLTEyIGF0IDA4OjUxIC0wNTAwLCBEYXZlIFd5c29jaGFuc2tpIHdyb3Rl
Og0KPiBDb21taXQgOWIzMDg4OWM1NDhhIGNoYW5nZWQgdGhlIGhhbmRsaW5nIG9mIFRDUF9DTE9T
RSBpbnNpZGUNCj4geHNfdGNwX3N0YXRlX2NoYW5nZS4gIFByaW9yIHRvIHRoaXMgY2hhbmdlLCB0
aGUgWFBSVF9DT05ORUNURUQgYml0DQo+IHdhcyBjbGVhcmVkIHVuY29uZGl0aW9uYWxseSBpbnNp
ZGUgeHBydF9kaXNjb25uZWN0X2RvbmUsIHNpbWlsYXINCj4gdG8gdGhlIGhhbmRsaW5nIG9mIFRD
UF9DTE9TRV9XQUlULiAgQWZ0ZXIgdGhlIGNoYW5nZSB0aGUgY2xlYXJpbmcNCj4gb2YgWFBSVF9D
T05ORUNURUQgZGVwZW5kcyBvbiBzdWNjZXNzZnVsbHkgcXVldWVpbmcgYSB3b3JrIGJhc2VkDQo+
IHhwcnRfYXV0b2Nsb3NlIHdoaWNoIGRlcGVuZHMgb24gWFBSVF9MT0NLRUQgYW5kIG1heSBub3Qg
aGFwcGVuLg0KPiBUaGlzIGlzIHNpZ25pZmljYW50IGluIHRoZSBjYXNlIG9mIGFuIHVuZXhwZWN0
ZWQgUlNUIGZyb20gdGhlDQo+IHNlcnZlciwgYXMgdGhlIGNsaWVudCB3aWxsIG9ubHkgc2VlIHhz
X3RjcF9zdGF0ZV9jaGFuZ2UgY2FsbGVkIHdpdGgNCj4gc2tfc3RhdGUgPT0gVENQX0NMT1NFLiAg
UmVzdG9yZSB0aGUgdW5jb25kaXRpb25hbCBjbGVhcl9iaXQgb24NCj4gWFBSVF9DT05ORUNURUQg
d2hpbGUgaGFuZGxpbmcgVENQX0NMT1NFIGFuZCBtYWtlIGl0IGNvbnNpc3RlbnQNCj4gd2l0aCBo
YW5kbGluZyBUQ1BfQ0xPU0VfV0FJVC4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IERhdmUgV3lzb2No
YW5za2kgPGR3eXNvY2hhQHJlZGhhdC5jb20+DQo+IC0tLQ0KPiAgbmV0L3N1bnJwYy94cHJ0c29j
ay5jIHwgMSArDQo+ICAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24oKykNCj4gDQo+IGRpZmYg
LS1naXQgYS9uZXQvc3VucnBjL3hwcnRzb2NrLmMgYi9uZXQvc3VucnBjL3hwcnRzb2NrLmMNCj4g
aW5kZXggOGE1ZTgyM2UwYjMzLi5iOTc4OTAzNjA1MWQgMTAwNjQ0DQo+IC0tLSBhL25ldC9zdW5y
cGMveHBydHNvY2suYw0KPiArKysgYi9uZXQvc3VucnBjL3hwcnRzb2NrLmMNCj4gQEAgLTE0OTIs
NiArMTQ5Miw3IEBAIHN0YXRpYyB2b2lkIHhzX3RjcF9zdGF0ZV9jaGFuZ2Uoc3RydWN0IHNvY2sN
Cj4gKnNrKQ0KPiAgCQlpZiAoc2stPnNrX2VycikNCj4gIAkJCXhwcnRfd2FrZV9wZW5kaW5nX3Rh
c2tzKHhwcnQsIC1zay0+c2tfZXJyKTsNCj4gIAkJLyogVHJpZ2dlciB0aGUgc29ja2V0IHJlbGVh
c2UgKi8NCj4gKwkJY2xlYXJfYml0KFhQUlRfQ09OTkVDVEVELCAmeHBydC0+c3RhdGUpOw0KPiAg
CQl4c190Y3BfZm9yY2VfY2xvc2UoeHBydCk7DQo+ICAJfQ0KPiAgIG91dDoNCg0KSGkgRGF2ZSwN
Cg0KVGhpcyBpc24ndCBuZWVkZWQgZm9yIDQuMjAgb3IgbmV3ZXIgYmVjYXVzZSBjYWxsX3RyYW5z
bWl0KCkgd2lsbCBub3cNCmFsd2F5cyBjYWxsIHhwcnRfZW5kX3RyYW5zbWl0KCkuIEkgc3VnZ2Vz
dCB0aGF0IGEgc3RhYmxlIGZpeCBkbw0Kc29tZXRoaW5nIHNpbWlsYXIgKHBlcmhhcHMgY29uZGl0
aW9uYWwgb24gdGhlIGVycm9yIHJldHVybmVkIGJ5DQp4cHJ0X3RyYW5zbWl0KCk/KS4NCg0KQ2hl
ZXJzDQogIFRyb25kDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1h
aW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoN
Cg0K
