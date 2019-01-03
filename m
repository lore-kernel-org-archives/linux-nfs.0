Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECE51C43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 18:48:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AAB5B217F5
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 18:48:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="cFSMEQGq"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726200AbfACSsB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 13:48:01 -0500
Received: from mail-eopbgr710103.outbound.protection.outlook.com ([40.107.71.103]:36992
        "EHLO NAM05-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726163AbfACSsB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Jan 2019 13:48:01 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=l9JOfcBgBHNhJ8FixYWd/8a0sC1IQuOANIrNc+ehFbM=;
 b=cFSMEQGqL2Q2P2mnMbP0c7uyKBJKFXHBKhsWiUd5kUl8Llf1fEjND2RVQ+ujXF4qF6mS+ppUyeeTnVPhYoKWmvxg8WlxxWKpP2ZtFLYsPPiFrT2yKZSJMRFSrEj3igDZtstdl1JFK38Wx5eCnj+Igq9h6bms6R0wXKJxuuPKy/I=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2303.namprd13.prod.outlook.com (52.135.94.22) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1516.3; Thu, 3 Jan 2019 18:47:57 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%3]) with mapi id 15.20.1495.005; Thu, 3 Jan 2019
 18:47:57 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Subject: Re: [PATCH] SUNRPC: Remove rpc_xprt::tsh_size
Thread-Topic: [PATCH] SUNRPC: Remove rpc_xprt::tsh_size
Thread-Index: AQHUo5McwpQQZImh0EO/lRKWh6zKuqWd4oaA
Date:   Thu, 3 Jan 2019 18:47:57 +0000
Message-ID: <0331de80b8161f8bf16a92de20049cafb0c228da.camel@hammerspace.com>
References: <20190103182649.4148.19838.stgit@manet.1015granger.net>
In-Reply-To: <20190103182649.4148.19838.stgit@manet.1015granger.net>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2303;6:ooPQWVvoM0cyX4ZAcuoTy6tTw0HI6NP8rmJMm6xG4GDqO//qvU5z0WDRzuNYKkqn6acarWoDMJ3+ObnOe6s0S4bIk7W+MzDO0f8IFBbfyn0A7p1pUXAOaLGF0QOjra6hOtQ4j9Z9r1/ipRnL76oXcPL0+eyKGG6mNCzQWmjC06PB2Agu848RoaSNDE3mnVohrxSxOOuE1CQ0RZ+/UzylxPL8sKWw09PxnCvdNpBrpQh4DU0CqjXOXeEUN2erfaoFSHZrcGf8gZFV3JPzKBkxNk/ZXJFMMXp1Zfqf1S/4LNuUzORqWl2/SHR/ayePwDj89vwQee/+zd3PwlPoGPFUQLFdFyNd4Q6gTqATyQNBcfJKj8Tz22jo/cBWbgPsGNQBQEkRdkeqOz6e/rhScu7bNK3gH4CbHDv/dWTv3fB8c0X4zPrETBiGQwp/lrwaAOfSm+uIJAVnHyO71MtzOkVPBA==;5:B991zSDu8Mkl3YlYRvIEfGc+hl1Sewd7NI1ZHnVWHnmmicYcoVktAy4l954967pZCm+FfFY9kCidRkidVpm8K1HY4JsUL7Jq3I3Fst2t4ZyOjVb4DDMzUlbbUqXtcdMBUFPX9ZWioqkf4SIW4it3YR3UYGD9scD0MhnLAtYpRPxJYYGU6aMKTotz/8RhB9WqMivLuF8AwSqFohPTmTLb1Q==;7:tH0tjiOSrQ/UoEv2+Y+TQNsXL9ZIw8YIUJEpZL9dQgj+pmgl1mGSc89lzqhvNrG4m+EqrfWMnAG5zAi2gtl4vdfEodZIRuD585u80yPzfv+pGIMrZZcWheJH752NzVE651ytUn5atU+fcpUZeLSYTQ==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: ca5a92c4-735e-49e4-246c-08d671abfaa0
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2303;
x-ms-traffictypediagnostic: SN6PR13MB2303:
x-microsoft-antispam-prvs: <SN6PR13MB23032B863732EFFAAB9E9703B88D0@SN6PR13MB2303.namprd13.prod.outlook.com>
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(908002)(999002)(5005026)(6040522)(8220060)(2401047)(8121501046)(3002001)(3231475)(944501520)(52105112)(10201501046)(93006095)(93001095)(6041310)(20161123562045)(20161123558120)(20161123560045)(20161123564045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2303;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2303;
x-forefront-prvs: 0906E83A25
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39830400003)(136003)(366004)(396003)(376002)(346002)(199004)(189003)(11346002)(8676002)(2906002)(486006)(2616005)(99286004)(476003)(446003)(316002)(36756003)(8936002)(478600001)(6116002)(3846002)(256004)(14444005)(110136005)(7736002)(5660300001)(305945005)(81156014)(81166006)(14454004)(6506007)(53936002)(102836004)(25786009)(6246003)(118296001)(97736004)(71190400001)(66066001)(186003)(106356001)(105586002)(26005)(71200400001)(6436002)(6486002)(76176011)(2501003)(68736007)(86362001)(229853002)(6512007);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2303;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: jWa9Pfz56UO6HF3RY6ASk9RbkfRWcWY9guGFT5SxFEI4avIv5UfkXE9lud9ucH8BKcaZwrnbiYEvZyhTwt5CZRW2vPNehiboe7e0tRxJwTx4mDDBq8m+jTsVGzBvV5D8EX8dbHRaTujO14xZnCtVtXbBvipBHjjnFU5tj/bZVCYuU5dhX9dsYnEFic6fIteMYLDiRsW40xVPKXSQE9iqTP+ROpvpXKoZ2sPPOZzFpfekX/uW/WZDsdrU+LbQl6uyR1ZyexQ/S97LFVRbxJPBy7628GQc54Je9nkn9VfmPjX16quTMxBEOm4dwGXoAigH
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <15B3F23A9206944AA5EFB010CC7DC2B3@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ca5a92c4-735e-49e4-246c-08d671abfaa0
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Jan 2019 18:47:57.6399
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2303
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTAxLTAzIGF0IDEzOjI5IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
ZGlmZiAtLWdpdCBhL25ldC9zdW5ycGMveHBydHNvY2suYyBiL25ldC9zdW5ycGMveHBydHNvY2su
Yw0KPiBpbmRleCBkNWNlMWE4Li42NmIwOGFhIDEwMDY0NA0KPiAtLS0gYS9uZXQvc3VucnBjL3hw
cnRzb2NrLmMNCj4gKysrIGIvbmV0L3N1bnJwYy94cHJ0c29jay5jDQo+IEBAIC02NzgsNiArNjc4
LDMxIEBAIHN0YXRpYyB2b2lkIHhzX3N0cmVhbV9kYXRhX3JlY2VpdmVfd29ya2ZuKHN0cnVjdA0K
PiB3b3JrX3N0cnVjdCAqd29yaykNCj4gIA0KPiAgI2RlZmluZSBYU19TRU5ETVNHX0ZMQUdTCShN
U0dfRE9OVFdBSVQgfCBNU0dfTk9TSUdOQUwpDQo+ICANCj4gK3N0YXRpYyBpbnQgeHNfc2VuZF9y
ZWNvcmRfbWFya2VyKHN0cnVjdCBzb2NrX3hwcnQgKnRyYW5zcG9ydCwNCj4gKwkJCQkgY29uc3Qg
c3RydWN0IHJwY19ycXN0ICpyZXEpDQo+ICt7DQo+ICsJc3RhdGljIHN0cnVjdCBtc2doZHIgbXNn
ID0gew0KPiArCQkubXNnX25hbWUJPSBOVUxMLA0KPiArCQkubXNnX25hbWVsZW4JPSAwLA0KPiAr
CQkubXNnX2ZsYWdzCT0gKFhTX1NFTkRNU0dfRkxBR1MgfCBNU0dfTU9SRSksDQo+ICsJfTsNCj4g
KwlycGNfZnJhZ2hkciBtYXJrZXI7DQo+ICsJc3RydWN0IGt2ZWMgaW92ID0gew0KPiArCQkuaW92
X2Jhc2UJPSAmbWFya2VyLA0KPiArCQkuaW92X2xlbgk9IHNpemVvZihtYXJrZXIpLA0KPiArCX07
DQo+ICsJdTMyIHJlY2xlbjsNCj4gKw0KPiArCWlmICh1bmxpa2VseSghdHJhbnNwb3J0LT5zb2Nr
KSkNCj4gKwkJcmV0dXJuIC1FTk9UU09DSzsNCj4gKwlpZiAocmVxLT5ycV9ieXRlc19zZW50KQ0K
PiArCQlyZXR1cm4gMDsNCg0KVGhlIHRlc3QgbmVlZHMgdG8gdXNlIHRyYW5zcG9ydC0+eG1pdC5v
ZmZzZXQsIG5vdCByZXEtPnJxX2J5dGVzX3NlbnQNCllvdSBhbHNvIG5lZWQgdG8gdXBkYXRlIHRy
YW5zcG9ydC0+eG1pdC5vZmZzZXQgb24gc3VjY2VzcywgYW5kIGJlDQpwcmVwYXJlZCB0byBoYW5k
bGUgdGhlIGNhc2Ugd2hlcmUgPCBzaXplb2YobWFya2VyKSBieXRlcyBnZXQNCnRyYW5zbWl0dGVk
IGR1ZSB0byBhIHdyaXRlX3NwYWNlIGNvbmRpdGlvbi4NCg0KPiArDQo+ICsJcmVjbGVuID0gcmVx
LT5ycV9zbmRfYnVmLmxlbjsNCj4gKwltYXJrZXIgPSBjcHVfdG9fYmUzMihSUENfTEFTVF9TVFJF
QU1fRlJBR01FTlQgfCByZWNsZW4pOw0KPiArCXJldHVybiBrZXJuZWxfc2VuZG1zZyh0cmFuc3Bv
cnQtPnNvY2ssICZtc2csICZpb3YsIDEsDQo+IGlvdi5pb3ZfbGVuKTsNCg0KDQpTbyB3aGF0IGRv
ZXMgdGhpcyBkbyBmb3IgcGVyZm9ybWFuY2U/IEknZCBleHBlY3QgdGhhdCBhZGRpbmcgYW5vdGhl
cg0KZGl2ZSBpbnRvIHRoZSBzb2NrZXQgbGF5ZXIgd2lsbCBjb21lIHdpdGggcGVuYWx0aWVzLg0K
DQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhh
bW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
