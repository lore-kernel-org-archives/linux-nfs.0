Return-Path: <SRS0=hAdq=OX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB5C3C43387
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Dec 2018 21:32:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C6028206DD
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Dec 2018 21:32:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="MOHZmYGe"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730734AbeLNVcU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 Dec 2018 16:32:20 -0500
Received: from mail-eopbgr770098.outbound.protection.outlook.com ([40.107.77.98]:49650
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1730887AbeLNVcU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Dec 2018 16:32:20 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=4fz6BSfRJwmxAeV2ZykmEP0jNaYFLg1SOYKwpGr2aAY=;
 b=MOHZmYGetWFHxZmt8MhayiDbxohZKmGUDjN2HCr3la12SS8rLvSLVB82yz5DzoIB81z00bP2TQrDTJblZcw14aB6pQQEuCRtnNnV8Hk5GfdEusCqtLjyMO9giWBTtasHgKvUdPMsFuT6HKxDUNyhY9ZDEu4umWsz57WHJh4fSK4=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2367.namprd13.prod.outlook.com (52.135.94.147) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1446.11; Fri, 14 Dec 2018 21:32:16 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1425.021; Fri, 14 Dec 2018
 21:32:16 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "santoshkumar.pradhan@wdc.com" <santoshkumar.pradhan@wdc.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: Add xprt after nfs4_test_session_trunk()
Thread-Topic: [PATCH] sunrpc: Add xprt after nfs4_test_session_trunk()
Thread-Index: AQHUkTgj3c9z/skiCUWy55DNJltRS6V+xoUA
Date:   Fri, 14 Dec 2018 21:32:16 +0000
Message-ID: <b9d2d26ca9d89c8a25721b53bbfb4a9300a5703d.camel@hammerspace.com>
References: <20181211095843.5338-1-santoshkumar.pradhan@wdc.com>
In-Reply-To: <20181211095843.5338-1-santoshkumar.pradhan@wdc.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2367;6:Kx5q7jPASxpBtTDD+69x4lZ8naKRnDWxnm80BBuFrzx2487eiVIEFJvIYbTfC6d1hjucY2JgU+yqCXwM7cz+VbkQuT4jSXVrACirNKYPX8YwGKqpa7/5K6KxaC5LIeMmb5/HR3HI7+jsZbCGW+4werDDDprzsLLxCXAGC9BwDznUciAXftcOgXMYxIhkQCC5HxMRhhgBreWx39oGHb7+5EAssV98wj/tMt7MLPwuSddfCs3z0T2xVabn6/cJlyoHQdY8ovcqE1q3F58fuNX8mvrPDjXZ4BtalczcEDv6RIM9hFAo9L9y8XnZKk/6dsNZchE4N+hzl1uaW0uCnJmtyMav5LhOYpbNsg1z5kKc/WlM+4wX5izglogkwlQ48yw7daD9IATjy7vfaI+2eaF3vlC0xEnauZswPCwo9fPrda7XazfxJ/7MXqUBkTQ9MjJGOtj+Ft1A3V/ZreVarlCzvw==;5:/dRzSyOWtsBJB26MqptbDn9eTuBNJtzEuV49mNJtIOJ387rxx+3fpLdLTUSzPMQjPLHu/O311MbNbhOCsg88ReBoOpvPATnCiY/MKp2vEFSgSvk1NBg39tkJGJ6UYlI7rWSbpPMuD5JFVMGAg4T4L0mNISI7MnWKgvzuNdHqocE=;7:lhK+46PVJ5I0PW71z6NjMdiwHKg+rUF5JcAepIirWAIxT/YEGn3QNAD1iMkNOPhVL6Vst7QsGTBB1vf7FDnkc4YbWX8LmgSKZK6oRWlo39S+jNZ4KoP1uh1B8LAWTo4yMQkRb7jnq9k/zEQCYntOOg==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: fb583246-415a-4fcf-235b-08d6620b9e85
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2367;
x-ms-traffictypediagnostic: SN6PR13MB2367:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-prvs: <SN6PR13MB23672C04E80F8DF46451634EB8A10@SN6PR13MB2367.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(999002)(6040522)(2401047)(5005006)(8121501046)(10201501046)(3231475)(944501520)(52105112)(93006095)(93001095)(3002001)(148016)(149066)(150057)(6041310)(20161123562045)(20161123564045)(20161123558120)(20161123560045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2367;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2367;
x-forefront-prvs: 08864C38AC
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39840400004)(376002)(346002)(396003)(136003)(366004)(199004)(189003)(76176011)(7736002)(316002)(6506007)(97736004)(26005)(102836004)(256004)(4326008)(14444005)(110136005)(478600001)(118296001)(486006)(2616005)(6246003)(25786009)(6512007)(3846002)(2906002)(6116002)(53936002)(476003)(446003)(11346002)(6436002)(8936002)(99286004)(106356001)(66066001)(71200400001)(71190400001)(14454004)(68736007)(86362001)(36756003)(105586002)(6486002)(8676002)(4001150100001)(186003)(81156014)(81166006)(229853002)(2501003)(305945005)(5660300001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2367;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: d0z22P5m7qBzfd/vGjY2gxnaoTvr12+Onj3HRpCh3HKgN6SBxe/x9W/aNcJm5+jcAAMOk0p4da5JkKcXJZ26wnr7F6AEj5TV/5a8/ITw4foMqY+9p2ZmrWznC2lfJJcQHxVmF7UmS3fPlZ1yyqH9vPEtJldv2KZqwGHY2x7KElPAwzV0j9jEujYh7erNchWWMf0ieZ3dyCj0rv2d1DItE809mYG3YUQYRaGzSk1wD0v3rG2iE8Rykol23FbcQq2tTkj2hhyGfmO+j4uYjsj/r4K0dAYOcJ6A0U7Cg7ahUES8vqgW1dpoLcQfFWgzriN+
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <7D33C33F9783164E84968A54CBAAA001@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: fb583246-415a-4fcf-235b-08d6620b9e85
X-MS-Exchange-CrossTenant-originalarrivaltime: 14 Dec 2018 21:32:16.1900
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2367
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgU2FudG9zaCwNCg0KT24gVHVlLCAyMDE4LTEyLTExIGF0IDE1OjI4ICswNTMwLCBTYW50b3No
IGt1bWFyIHByYWRoYW4gd3JvdGU6DQo+IEZyb206IFNhbnRvc2ggS3VtYXIgUHJhZGhhbiA8c2Fu
dG9zaGt1bWFyLnByYWRoYW5Ad2RjLmNvbT4NCj4gDQo+IE11bHRpcGF0aGluZzogSW4gY2FzZSBv
ZiBORlN2MywgcnBjX2NsbnRfdGVzdF9hbmRfYWRkX3hwcnQoKSBhZGRzDQo+IHRoZSB4cHJ0IHRv
IHhwcnQgc3dpdGNoIChpLmUuIHhwcykgaWYgcnBjX2NhbGxfbnVsbF9oZWxwZXIoKSByZXR1cm5z
DQo+IHN1Y2Nlc3MuIEJ1dCBpbiBjYXNlIG9mIE5GU3Y0LjEsIGl0IG5lZWRzIHRvIGRvIEVYQ0hB
TkdFSUQgdG8gdmVyaWZ5DQo+IHRoZSBwYXRoIGFsb25nIHdpdGggY2hlY2sgZm9yIHNlc3Npb24g
dHJ1bmtpbmcuDQo+IA0KPiBBZGQgdGhlIHhwcnQgb25jZSBuZnM0X3Rlc3Rfc2Vzc2lvbl90cnVu
aygpIHJldHVybnMgc3VjY2Vzcy4NCj4gQWxzbyByZWxlYXNlIHJlZmNvdW50IGhvbGQgYnkgcnBj
X2NsbnRfc2V0dXBfdGVzdF9hbmRfYWRkX3hwcnQoKS4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IFNh
bnRvc2ggS3VtYXIgUHJhZGhhbiA8c2FudG9zaGt1bWFyLnByYWRoYW5Ad2RjLmNvbT4NCj4gVGVz
dGVkLWJ5OiBTdXJlc2ggSmF5YXJhbWFuIDxzdXJlc2guamF5YXJhbWFuQHdkYy5jb20+DQo+IC0t
LQ0KPiAgbmV0L3N1bnJwYy9jbG50LmMgfCAxMCArKysrKysrLS0tDQo+ICAxIGZpbGUgY2hhbmdl
ZCwgNyBpbnNlcnRpb25zKCspLCAzIGRlbGV0aW9ucygtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL25l
dC9zdW5ycGMvY2xudC5jIGIvbmV0L3N1bnJwYy9jbG50LmMNCj4gaW5kZXggZDgzOWMzM2FlN2Q5
Li4wNTNmNTk0Y2MxNDQgMTAwNjQ0DQo+IC0tLSBhL25ldC9zdW5ycGMvY2xudC5jDQo+ICsrKyBi
L25ldC9zdW5ycGMvY2xudC5jDQo+IEBAIC0yNjU0LDEwICsyNjU0LDE0IEBAIGludCBycGNfY2xu
dF9zZXR1cF90ZXN0X2FuZF9hZGRfeHBydChzdHJ1Y3QNCj4gcnBjX2NsbnQgKmNsbnQsDQo+ICAJ
CWdvdG8gb3V0X2VycjsNCj4gIA0KPiAgCS8qIHJwY194cHJ0X3N3aXRjaCBhbmQgcnBjX3hwcnQg
YXJlIGRlZmVycmVuY2VkIGJ5DQo+IGFkZF94cHJ0X3Rlc3QoKSAqLw0KPiAtCXh0ZXN0LT5hZGRf
eHBydF90ZXN0KGNsbnQsIHhwcnQsIHh0ZXN0LT5kYXRhKTsNCj4gKwlzdGF0dXMgPSB4dGVzdC0+
YWRkX3hwcnRfdGVzdChjbG50LCB4cHJ0LCB4dGVzdC0+ZGF0YSk7DQo+ICsJaWYgKHN0YXR1cyAh
PSAwKQ0KPiArCQlnb3RvIG91dF9lcnI7DQo+ICANCj4gLQkvKiBzbyB0aGF0IHJwY19jbG50X2Fk
ZF94cHJ0IGRvZXMgbm90IGNhbGwNCj4gcnBjX3hwcnRfc3dpdGNoX2FkZF94cHJ0ICovDQo+IC0J
cmV0dXJuIDE7DQo+ICsJeHBydF9wdXQoeHBydCk7DQo+ICsJeHBydF9zd2l0Y2hfcHV0KHhwcyk7
DQo+ICsJLyogc28gdGhhdCBycGNfY2xudF9hZGRfeHBydCBjYWxscyBycGNfeHBydF9zd2l0Y2hf
YWRkX3hwcnQgKi8NCj4gKwlyZXR1cm4gMDsNCj4gIG91dF9lcnI6DQo+ICAJeHBydF9wdXQoeHBy
dCk7DQo+ICAJeHBydF9zd2l0Y2hfcHV0KHhwcyk7DQoNCkknZCByZWFsbHkgcHJlZmVyIHRvIGhh
dmUgY2FsbGJhY2tzIHRoYXQgZG9uJ3QgcmV0dXJuIHZhbHVlcyBoZXJlIHNvDQp0aGF0IHRoZXkg
Y2FuIGJlIG1hZGUgYXN5bmNocm9ub3VzIGF0IHNvbWUgcG9pbnQgaW4gdGhlIGZ1dHVyZS4gRm9y
DQp0aGF0IHJlYXNvbiwgSSdkIHByZWZlciBhIGZpeCBpbiB0aGUgTkZTIGNvZGUsIG5vdCB0aGUg
UlBDIGNvZGUuDQoNCkNhbiB5b3UgdGhlcmVmb3JlIHBsZWFzZSBjaGFuZ2Ugc3RydWN0IHJwY19h
ZGRfeHBydF90ZXN0IHRvIHNvbWV0aGluZw0KbGlrZSB0aGUgZm9sbG93aW5nOg0KDQpzdHJ1Y3Qg
cnBjX2FkZF94cHJ0X3Rlc3Qgew0KICAgICAgICB2b2lkICgqYWRkX3hwcnRfdGVzdCkoc3RydWN0
IHJwY19jbG50ICosDQogICAgICAgICAgICAgICAgc3RydWN0IHJwY194cHJ0ICosDQogICAgICAg
ICAgICAgICAgdm9pZCAqY2FsbGRhdGEpOw0KICAgICAgICB2b2lkICpkYXRhOw0KfTsNCg0KYW5k
IHRoZW4gc2ltcGx5IGhhdmUgbmZzNF90ZXN0X3Nlc3Npb25fdHJ1bmsoKSBjYWxsDQpycGNfY2xu
dF94cHJ0X3N3aXRjaF9hZGRfeHBydCgpIGlmIHRoZSBjYWxsIHRvDQpuZnM0X2RldGVjdF9zZXNz
aW9uX3RydW5raW5nKCkgaXMgc3VjY2Vzc2Z1bD8NCg0KVGhhbmtzIQ0KICBUcm9uZA0KDQotLSAN
ClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFj
ZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
