Return-Path: <SRS0=k36n=QA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6229C282C5
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Jan 2019 19:53:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7C90121726
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Jan 2019 19:53:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Wv9+dHxL"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726980AbfAXTxY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 24 Jan 2019 14:53:24 -0500
Received: from mail-eopbgr810117.outbound.protection.outlook.com ([40.107.81.117]:6236
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726122AbfAXTxX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 24 Jan 2019 14:53:23 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=oFDKa+B0Mj2cEMnKqCNYNXmAiLUUrnjAG7u0BJNU80A=;
 b=Wv9+dHxLuhk3UPns9JF7YvWS6geN9Lypo/+TNuLuiaTmp/HwwDn6sE80fvHo3Rg7Olthk//9QljI9AApMH/z/Gx8I57cspiGDowhsx9rOwlUTLIFf4rPS6T/m8DBAIOXNTVp3D/Wqd3uy7AwUvR+qzmepKAXQrm9m/kD8NbW0nQ=
Received: from BYAPR13MB2486.namprd13.prod.outlook.com (52.135.230.12) by
 BYAPR13MB2439.namprd13.prod.outlook.com (52.135.229.153) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1580.6; Thu, 24 Jan 2019 19:53:19 +0000
Received: from BYAPR13MB2486.namprd13.prod.outlook.com
 ([fe80::f003:cf45:194d:8dc1]) by BYAPR13MB2486.namprd13.prod.outlook.com
 ([fe80::f003:cf45:194d:8dc1%4]) with mapi id 15.20.1558.016; Thu, 24 Jan 2019
 19:53:19 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chucklever@gmail.com" <chucklever@gmail.com>,
        "zhangxiaoxu5@huawei.com" <zhangxiaoxu5@huawei.com>
CC:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>
Subject: Re: [PATCH] lockd: NSMPROC_MON should be send only once even if in
 multithread
Thread-Topic: [PATCH] lockd: NSMPROC_MON should be send only once even if in
 multithread
Thread-Index: AQHUriudl5q7ODAObU6c2hbDfkurgqWzhtAAgADNdYCAATDmAIAI31cAgAByIgCAAAnpAA==
Date:   Thu, 24 Jan 2019 19:53:19 +0000
Message-ID: <741d9199bf20e7a20e9ac612bd280b6b285a7cd4.camel@hammerspace.com>
References: <1547705746-69554-1-git-send-email-zhangxiaoxu5@huawei.com>
         <4E812155-4DB4-4EF4-91ED-EDBB1B0BBFF7@gmail.com>
         <00390d85-d2dd-be57-4192-bff562a75684@huawei.com>
         <E87ADB64-FE89-48A8-A401-3153E029D0DA@gmail.com>
         <bdef1ea6-1b71-a638-7274-d2109db5e1d1@huawei.com>
         <DE9790AD-A95E-43CB-9A5C-A55DD10294CC@gmail.com>
In-Reply-To: <DE9790AD-A95E-43CB-9A5C-A55DD10294CC@gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;BYAPR13MB2439;6:tGfHzDnPihHLn0pk4djmQUH7bR6KW9vCHYZm/WbmdOVNxNqMS2h7GjeAyfeexHuu0Z8nvSFg4HAkaK37cDe+enWShcay8GB+iuYF3N3jFLugi1EjEYMHi0/0zoWSM+TP8Sw3EyI+oLeYOYXI4uMUgRBAzxBD+zqUpQpqsuUeNskBGATrrXeOboCl5LJnK7TddqKIiVAl5Q3qfcOW5Nv/slggWJGW5tVsaPaHyKnFdpeFoextVKhR5kMI0j6xTZ9mcBasVAxxjYh7e1NiIQqCbITu4dmw8owukvY1RKZMI/3GeaV0jkPUBxmMcs5SBevgwN/yJJPx28QJ69CKNOQyTvaJelZiCSu7m7vGfYX/zHBhrBGXQLC7beUgzjOI+2FhfpcxcV1aramX1WoIu+21Mf0JG2V9R4goX8f4n++QDlCJ7R5W5EBEBLmMcbv28SdGhvPTTF4Ru1dY118nIwUp2A==;5:AUMjslwnvrofXP+7Eq0L0Ug3yptRVmbZI5VoPMFJaLr2UzRkCoLY4y0/w5uDtkt8ZSCqacatExwjXUUTlVaCAqPePQ0QO2PUggUD50GwV2smc0k0KXCclPQvGx9vSTFGWeBuLjMBDX/3Qh/LOu5z7Gzd1z/NxA16gSk/IQhXjeEvQ7ur+uyIjhGZBlTSkcJSmeRl1nh6UZBh1KnSX/j7lA==;7:BwQWLWVEVPHKclx5+WgYhy/sV+nChzIgC4xZpIAY+M2m8CcFQ5KB1IQ049T/cms/YCO/YzZU4mTX5TgjyhTA2hG3xjda+VbJ2uObGTFMxxr0Dcuw78o1547dxZrwy4BC5tU+izoDyhVVEGaFk+uWdA==
x-ms-office365-filtering-correlation-id: 331342cf-731f-44b1-0ca9-08d682359721
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:BYAPR13MB2439;
x-ms-traffictypediagnostic: BYAPR13MB2439:
x-microsoft-antispam-prvs: <BYAPR13MB2439487F3D9E484698A8A713B89A0@BYAPR13MB2439.namprd13.prod.outlook.com>
x-forefront-prvs: 0927AA37C7
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(376002)(396003)(366004)(136003)(39830400003)(189003)(199004)(76176011)(2906002)(478600001)(8676002)(316002)(99286004)(102836004)(6506007)(53546011)(118296001)(93886005)(305945005)(68736007)(7736002)(486006)(6512007)(8936002)(81156014)(81166006)(97736004)(26005)(54906003)(110136005)(39060400002)(4326008)(14454004)(53936002)(25786009)(6246003)(186003)(86362001)(256004)(2616005)(6486002)(476003)(6436002)(66066001)(14444005)(36756003)(446003)(6116002)(105586002)(3846002)(11346002)(2501003)(106356001)(71200400001)(71190400001)(229853002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR13MB2439;H:BYAPR13MB2486.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 1SCjXRme/tzr7sVzXSC8fwPVcNu1fwDSYWhMeCwUWRGsGXo0/AC1LRkaJ1nWufVVQGJZJvKT92+4ppFmATezjQy2ynFaNWj1Im1HlfQO8mn/YpD8KDTwGKXbzaf6OU4vGLrvI+c1Dt7H94amjtHr8g5ya9iclmfCp/NzvR4ct4pvBkQvtIwbm9M1usTUlY8LN14lCJrVT0NZ9dEQ/mTRC3pLbbS5V+ksM28X6wBclQOcJ/UfOwFacTP8KugPyzTqd4t/vslaj5a3hq9CxmKEd0aHlZffcPupjM/dZNRJGWcmolNaJ1af9j7cFVwwKI79pTLJoLgPKKS0jergpRVFoU5lb9V++oTzxlOL9UY/DKJGfIg5w6bEVVLOFBeSoUNXr6Mai1d1mBxvylMOrXDOwh7T+YrOniasCQkolpESf6k=
Content-Type: text/plain; charset="utf-8"
Content-ID: <030C83EC47059F4CBB17C1E1175C19EC@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 331342cf-731f-44b1-0ca9-08d682359721
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Jan 2019 19:53:19.8075
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR13MB2439
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTAxLTI0IGF0IDExOjE3IC0wODAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBKYW4gMjQsIDIwMTksIGF0IDQ6MjkgQU0sIHpoYW5neGlhb3h1IChBKSA8DQo+ID4gemhh
bmd4aWFveHU1QGh1YXdlaS5jb20+IHdyb3RlOg0KPiA+IA0KPiA+IA0KPiA+IA0KPiA+IE9uIDEv
MTkvMjAxOSA0OjU5IEFNLCBDaHVjayBMZXZlciB3cm90ZToNCj4gPiA+ID4gT24gSmFuIDE3LCAy
MDE5LCBhdCA5OjQ4IFBNLCB6aGFuZ3hpYW94dSAoQSkgPA0KPiA+ID4gPiB6aGFuZ3hpYW94dTVA
aHVhd2VpLmNvbT4gd3JvdGU6DQo+ID4gPiA+IA0KPiA+ID4gPiANCj4gPiA+ID4gDQo+ID4gPiA+
IE9uIDEvMTcvMjAxOSAxMDozMyBQTSwgQ2h1Y2sgTGV2ZXIgd3JvdGU6DQo+ID4gPiA+ID4gSGks
IHdoYXQgaXMgdGhlIGhhcm0gb2Ygc2VuZGluZyBtb3JlIHRoYW4gb25lIE1PTiByZXF1ZXN0IGZv
cg0KPiA+ID4gPiA+IGEgcGVlcj8NCj4gPiA+ID4gTWF5YmUgbm8gaGFybS4NCj4gPiA+ID4gVGhl
IHJwYy5zdGF0ZCB3b24ndCByZWNvcmQgdGhlIHBlZXIgdHdpY2UuDQo+ID4gPiA+IA0KPiA+ID4g
PiBJIGZvdW5kIHRoaXMgd2hlbiBJIHRlc3RlZCB0aGUgeGZzdGVzdCBnZW5lcmljLzA4OS4NCj4g
PiA+ID4gVGhlIHJwYyB0YXNrIGZvciB0aGF0IG1zZyBzb21ldGltZXMgdGFrZSB2ZXJ5IGxvbmcg
dGltZS4NCj4gPiA+ID4gcnBjIHRvb2sgNTcgc2VjIHdobyB0X210YWIvMjM3NyBzcnYgcnBjLnN0
YXRkIHhpZCAyNDUzNDg5MDMxDQo+ID4gPiA+IHByb2cgc3RhdGQvMTAwMDI0LzEgcHJvYyAyIHBy
b3QgNiBmbGFncyAweDY4MA0KPiA+ID4gTU9OIGlzIHN1cHBvc2VkIHRvIGJlIGEgY2FsbCB0byBh
IGxvY2FsIHNlcnZpY2UgKG9uIHRoZSBzYW1lDQo+ID4gPiBob3N0KS4NCj4gPiA+IEl0IHdvdWxk
IGJlIGludGVyZXN0aW5nIGlmIHlvdSBjb3VsZCBkZXRlcm1pbmUgd2h5IGl0IHRha2VzIHNvDQo+
ID4gPiBsb25nLg0KPiA+IFllcywgSSdtIHdvcmtpbmcgZm9yIHRoYXQuDQo+ID4gSSB0aGluayB0
aGlzIGlzIGFuIG9wdGltaXphdGlvbiBwb2ludC4NCj4gPiBXaHkgZG8gd2UgaGF2ZSB0byBzZW5k
IG11bHRpcGxlIHJlcXVlc3RzPw0KPiANCj4gSSBhZ3JlZSB0aGF0IG11bHRpcGxlIHJlcXVlc3Rz
IGFyZSB1bm5lY2Vzc2FyeSwgYnV0DQo+IHRoZXkgYXJlIGhhcm1sZXNzIHRvby4gSSBkb24ndCB0
aGluayBpdCdzIHdvcnRoIHRoZQ0KPiB0cm91YmxlIHRvIGNoYW5nZSB0aGlzIGJlaGF2aW9yLg0K
PiANCj4gVGhlIHByb2JsZW0gaXMgTU9OIHJlcXVlc3RzIG9uIHlvdXIgc3lzdGVtIHRha2VzIHRv
byBsb25nLg0KDQoNCjU3IHNlY29uZHMgaXMgcHJldHR5IG11Y2ggdW5oZWFyZCBvZi4gSXMgcnBj
LnN0YXRkIGNvcnJlY3RseSByZWdpc3RlcmVkDQp3aXRoIHJwY2JpbmQsIGFuZCBpcyB0aGUgcG9y
dCB0aGF0IHJwYy5zdGF0ZCBpcyBsaXN0ZW5pbmcgb24gb3BlbiB0bw0KY29ubmVjdGlvbnMgZnJv
bSBsb2NhbGhvc3QgKGkuZS4gbm8gZmlyZXdhbGwgYmxvY2thZ2UpPw0KDQotLSANClRyb25kIE15
a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQu
bXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
