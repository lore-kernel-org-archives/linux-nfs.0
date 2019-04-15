Return-Path: <SRS0=/Mrm=SR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A78FC10F0E
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Apr 2019 16:08:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C764720880
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Apr 2019 16:08:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="tX/zjdHU"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727832AbfDOQIv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 15 Apr 2019 12:08:51 -0400
Received: from mail-eopbgr700131.outbound.protection.outlook.com ([40.107.70.131]:1438
        "EHLO NAM04-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727882AbfDOQF7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 15 Apr 2019 12:05:59 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=7TBqMf/f1hxUYrmpSUHM5PbZPQ2yr2LqBOVSzQeNINk=;
 b=tX/zjdHUpj3F5uah93U8Q6G98pxMNCabSg8TXe6UK0J/17TaOyYgKufGp/60XcU+Mp8jJFRC+HX5EafrmE7gIo68PBwyGHISqw3bBpL7AgbiSgFpkeH1zycESbIJYz7DVkeGn1Q58xJjf5ob93gWxsGiF0S3bNJRLvik+9yvUlY=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2447.namprd13.prod.outlook.com (52.135.95.27) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1813.9; Mon, 15 Apr 2019 16:05:56 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1813.009; Mon, 15 Apr 2019
 16:05:56 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: error=Invalid slot
Thread-Topic: error=Invalid slot
Thread-Index: AQHU85ydVB0rnpfSJkGGMtmyhXgDYKY9YvYA
Date:   Mon, 15 Apr 2019 16:05:55 +0000
Message-ID: <76d240e019d0ccc35bce05c1edb1ca104d7c18bf.camel@hammerspace.com>
References: <2996CEEE-0A1A-4C15-AA8B-A97E917D7924@oracle.com>
In-Reply-To: <2996CEEE-0A1A-4C15-AA8B-A97E917D7924@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: bec5c3b5-af1c-4d9b-7813-08d6c1bc3e2c
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600140)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2447;
x-ms-traffictypediagnostic: SN6PR13MB2447:
x-microsoft-antispam-prvs: <SN6PR13MB2447603836E90796E9DAF7C3B82B0@SN6PR13MB2447.namprd13.prod.outlook.com>
x-forefront-prvs: 000800954F
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(39830400003)(376002)(396003)(136003)(346002)(189003)(199004)(2616005)(99286004)(66066001)(76176011)(8676002)(36756003)(118296001)(476003)(2351001)(7736002)(229853002)(3480700005)(316002)(53936002)(105586002)(6916009)(6246003)(14454004)(8936002)(11346002)(305945005)(4326008)(81156014)(81166006)(478600001)(446003)(86362001)(106356001)(53546011)(68736007)(6506007)(256004)(486006)(14444005)(5640700003)(6512007)(3846002)(6116002)(71200400001)(71190400001)(2501003)(25786009)(2906002)(102836004)(186003)(97736004)(5660300002)(26005)(6436002)(6486002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2447;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: +vkG+M3erTiRW+vZHs9EKghVKqMb1F0gjaT1zueKfQ6pERYRCZnozYVYGxq/KbzzlspXwgbyKu8j3sM/FLLA/oOh4oVgfUHojwDMFyI4YZ6GYbm/yJH1yjVw3Df04EliyfE9uaEYnjYEJud2TFmWzPPhTnbAJuztv09VYXrqGkJtUBJ+6VrYWLDSLYc6Vq+tv/Jnc9SqDxXIoV3QVJHjRMiKmzzpInIiaIWSvZ7304YQFXUpCbTLZW6ZdbksCxTMHfzPSCcixSPBrs9VaDyWdupbL5/Zicv77MB0OzWfsaIYKrnKf2JDpZZJbK4i+uEgJKIJt+Mt62p9myNq/h73L2kLACMtu48HT3DCB5pH51ss4tp1agQIUJoLpxZND58TfDC2lwJsRpskKKL2uEKrD8g9RBSe86IDXX0v5OetFAo=
Content-Type: text/plain; charset="utf-8"
Content-ID: <535D46C800680F498B7943BD137455E4@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: bec5c3b5-af1c-4d9b-7813-08d6c1bc3e2c
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Apr 2019 16:05:55.9487
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2447
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgQ2h1Y2ssDQoNCg0KT24gTW9uLCAyMDE5LTA0LTE1IGF0IDExOjA0IC0wNDAwLCBDaHVjayBM
ZXZlciB3cm90ZToNCj4gSnVzdCBoYXBwZW5lZCBhZ2Fpbi4gQW55IHRob3VnaHRzIGFib3V0IHdo
ZXJlIEkgc2hvdWxkIHN0YXJ0IGxvb2tpbmc/DQo+IA0KPiBNb24gQXByIDE1IDExOjAxOjQwIEVE
VCAyMDE5DQo+IDRrMTAwdGVzdDogKGc9MCk6IHJ3PXJhbmRyZWFkLCBicz0oUikgNDA5NkItNDA5
NkIsIChXKSA0MDk2Qi00MDk2QiwNCj4gKFQpIDQwOTZCLTQwOTZCLCBpb2VuZ2luZT1saWJhaW8s
IGlvZGVwdGg9MTAyNA0KPiAuLi4NCj4gZmlvLTMuMQ0KPiBTdGFydGluZyAxMiBwcm9jZXNzZXMN
Cj4gNGsxMDB0ZXN0OiBMYXlpbmcgb3V0IElPIGZpbGUgKDEgZmlsZSAvIDEwMjRNaUIpDQo+IGZp
bzogbmF0aXZlX2ZhbGxvY2F0ZSBjYWxsIGZhaWxlZDogT3BlcmF0aW9uIG5vdCBzdXBwb3J0ZWQN
Cj4gNGsxMDB0ZXN0OiBMYXlpbmcgb3V0IElPIGZpbGUgKDEgZmlsZSAvIDEwMjRNaUIpDQo+IGZp
bzogbmF0aXZlX2ZhbGxvY2F0ZSBjYWxsIGZhaWxlZDogT3BlcmF0aW9uIG5vdCBzdXBwb3J0ZWQN
Cj4gNGsxMDB0ZXN0OiBMYXlpbmcgb3V0IElPIGZpbGUgKDEgZmlsZSAvIDEwMjRNaUIpDQo+IGZp
bzogbmF0aXZlX2ZhbGxvY2F0ZSBjYWxsIGZhaWxlZDogT3BlcmF0aW9uIG5vdCBzdXBwb3J0ZWQN
Cj4gNGsxMDB0ZXN0OiBMYXlpbmcgb3V0IElPIGZpbGUgKDEgZmlsZSAvIDEwMjRNaUIpDQo+IGZp
bzogbmF0aXZlX2ZhbGxvY2F0ZSBjYWxsIGZhaWxlZDogT3BlcmF0aW9uIG5vdCBzdXBwb3J0ZWQN
Cj4gNGsxMDB0ZXN0OiBMYXlpbmcgb3V0IElPIGZpbGUgKDEgZmlsZSAvIDEwMjRNaUIpDQo+IGZp
bzogbmF0aXZlX2ZhbGxvY2F0ZSBjYWxsIGZhaWxlZDogT3BlcmF0aW9uIG5vdCBzdXBwb3J0ZWQN
Cj4gNGsxMDB0ZXN0OiBMYXlpbmcgb3V0IElPIGZpbGUgKDEgZmlsZSAvIDEwMjRNaUIpDQo+IGZp
bzogbmF0aXZlX2ZhbGxvY2F0ZSBjYWxsIGZhaWxlZDogT3BlcmF0aW9uIG5vdCBzdXBwb3J0ZWQN
Cj4gNGsxMDB0ZXN0OiBMYXlpbmcgb3V0IElPIGZpbGUgKDEgZmlsZSAvIDEwMjRNaUIpDQo+IGZp
bzogbmF0aXZlX2ZhbGxvY2F0ZSBjYWxsIGZhaWxlZDogT3BlcmF0aW9uIG5vdCBzdXBwb3J0ZWQN
Cj4gNGsxMDB0ZXN0OiBMYXlpbmcgb3V0IElPIGZpbGUgKDEgZmlsZSAvIDEwMjRNaUIpDQo+IGZp
bzogbmF0aXZlX2ZhbGxvY2F0ZSBjYWxsIGZhaWxlZDogT3BlcmF0aW9uIG5vdCBzdXBwb3J0ZWQN
Cj4gNGsxMDB0ZXN0OiBMYXlpbmcgb3V0IElPIGZpbGUgKDEgZmlsZSAvIDEwMjRNaUIpDQo+IGZp
bzogbmF0aXZlX2ZhbGxvY2F0ZSBjYWxsIGZhaWxlZDogT3BlcmF0aW9uIG5vdCBzdXBwb3J0ZWQN
Cj4gNGsxMDB0ZXN0OiBMYXlpbmcgb3V0IElPIGZpbGUgKDEgZmlsZSAvIDEwMjRNaUIpDQo+IGZp
bzogbmF0aXZlX2ZhbGxvY2F0ZSBjYWxsIGZhaWxlZDogT3BlcmF0aW9uIG5vdCBzdXBwb3J0ZWQN
Cj4gNGsxMDB0ZXN0OiBMYXlpbmcgb3V0IElPIGZpbGUgKDEgZmlsZSAvIDEwMjRNaUIpDQo+IGZp
bzogbmF0aXZlX2ZhbGxvY2F0ZSBjYWxsIGZhaWxlZDogT3BlcmF0aW9uIG5vdCBzdXBwb3J0ZWQN
Cj4gNGsxMDB0ZXN0OiBMYXlpbmcgb3V0IElPIGZpbGUgKDEgZmlsZSAvIDEwMjRNaUIpDQo+IGZp
bzogbmF0aXZlX2ZhbGxvY2F0ZSBjYWxsIGZhaWxlZDogT3BlcmF0aW9uIG5vdCBzdXBwb3J0ZWQN
Cj4gZmlvOiBpb191IGVycm9yIG9uIGZpbGUgNGsxMDB0ZXN0LjcuMDogSW52YWxpZCBzbG90OiBy
ZWFkDQo+IG9mZnNldD05MzgyMjk3NjAsIGJ1Zmxlbj00MDk2DQoNCkRvZXMgdGhlIGZvbGxvd2lu
ZyBwYXRjaCBmaXggdGhlIHJhY2U/DQoNCjg8LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0NCkZyb20gNGM4NzU5ZWFmYWQ5YmI3ZWEyNjI2YTUzMjk2ZTMwNjE4YWVlZmNjNyBN
b24gU2VwIDE3IDAwOjAwOjAwIDIwMDENCkZyb206IFRyb25kIE15a2xlYnVzdCA8dHJvbmQubXlr
bGVidXN0QGhhbW1lcnNwYWNlLmNvbT4NCkRhdGU6IE1vbiwgMTUgQXByIDIwMTkgMTE6NTQ6MTMg
LTA0MDANClN1YmplY3Q6IFtQQVRDSF0gU1VOUlBDOiBJZ25vcmUgcXVldWUgdHJhbnNtaXNzaW9u
IGVycm9ycyBvbiBzdWNjZXNzZnVsDQogdHJhbnNtaXNzaW9uDQoNCklmIGEgcmVxdWVzdCB0cmFu
c21pc3Npb24gZmFpbHMgZHVlIHRvIHdyaXRlIHNwYWNlIG9yIHNsb3QgdW5hdmFpbGFiaWxpdHkN
CmVycm9ycywgYnV0IHRoZSBxdWV1ZWQgdGFzayB0aGVuIGdldHMgdHJhbnNtaXR0ZWQgYmVmb3Jl
IGl0IGhhcyB0aW1lIHRvDQpwcm9jZXNzIHRoZSBlcnJvciBpbiBjYWxsX3RyYW5zbWl0X3N0YXR1
cygpIG9yIGNhbGxfYmNfdHJhbnNtaXRfc3RhdHVzKCksDQp3ZSBuZWVkIHRvIHN1cHByZXNzIHRo
ZSB0cmFuc21pc3Npb24gZXJyb3IgY29kZSB0byBwcmV2ZW50IGl0IGZyb20gbGVha2luZw0Kb3V0
IG9mIHRoZSBSUEMgbGF5ZXIuDQoNClJlcG9ydGVkLWJ5OiBDaHVjayBMZXZlciA8Y2h1Y2subGV2
ZXJAb3JhY2xlLmNvbT4NClNpZ25lZC1vZmYtYnk6IFRyb25kIE15a2xlYnVzdCA8dHJvbmQubXlr
bGVidXN0QGhhbW1lcnNwYWNlLmNvbT4NCi0tLQ0KIG5ldC9zdW5ycGMvY2xudC5jIHwgNyArKysr
Ky0tDQogMSBmaWxlIGNoYW5nZWQsIDUgaW5zZXJ0aW9ucygrKSwgMiBkZWxldGlvbnMoLSkNCg0K
ZGlmZiAtLWdpdCBhL25ldC9zdW5ycGMvY2xudC5jIGIvbmV0L3N1bnJwYy9jbG50LmMNCmluZGV4
IGZhOTAwYmI0NGNkNS4uMzY5YTI2NDhkYWZjIDEwMDY0NA0KLS0tIGEvbmV0L3N1bnJwYy9jbG50
LmMNCisrKyBiL25ldC9zdW5ycGMvY2xudC5jDQpAQCAtMjEwMSw4ICsyMTAxLDggQEAgY2FsbF90
cmFuc21pdF9zdGF0dXMoc3RydWN0IHJwY190YXNrICp0YXNrKQ0KIAkgKiB0ZXN0IGZpcnN0Lg0K
IAkgKi8NCiAJaWYgKHJwY190YXNrX3RyYW5zbWl0dGVkKHRhc2spKSB7DQotCQlpZiAodGFzay0+
dGtfc3RhdHVzID09IDApDQotCQkJeHBydF9yZXF1ZXN0X3dhaXRfcmVjZWl2ZSh0YXNrKTsNCisJ
CXRhc2stPnRrX3N0YXR1cyA9IDA7DQorCQl4cHJ0X3JlcXVlc3Rfd2FpdF9yZWNlaXZlKHRhc2sp
Ow0KIAkJcmV0dXJuOw0KIAl9DQogDQpAQCAtMjE4Nyw2ICsyMTg3LDkgQEAgY2FsbF9iY190cmFu
c21pdF9zdGF0dXMoc3RydWN0IHJwY190YXNrICp0YXNrKQ0KIHsNCiAJc3RydWN0IHJwY19ycXN0
ICpyZXEgPSB0YXNrLT50a19ycXN0cDsNCiANCisJaWYgKHJwY190YXNrX3RyYW5zbWl0dGVkKHRh
c2spKQ0KKwkJdGFzay0+dGtfc3RhdHVzID0gMDsNCisNCiAJZHByaW50X3N0YXR1cyh0YXNrKTsN
CiANCiAJc3dpdGNoICh0YXNrLT50a19zdGF0dXMpIHsNCi0tIA0KMi4yMC4xDQoNCi0tIA0KVHJv
bmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0
cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
