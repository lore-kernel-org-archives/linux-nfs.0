Return-Path: <SRS0=azWf=RW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72502C10F03
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Mar 2019 16:58:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1FE492083D
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Mar 2019 16:58:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="ANjLEENq"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726778AbfCSQ6N (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Mar 2019 12:58:13 -0400
Received: from mail-eopbgr820100.outbound.protection.outlook.com ([40.107.82.100]:46912
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727708AbfCSQ6M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Mar 2019 12:58:12 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=BkvJ0s97Bz/owlBoW4xmuVptI5Y2W1dDi9OkIUxQyfs=;
 b=ANjLEENqjAX/HYbK6Esl8pR+UR8TPQPPufJxHRlGf0zNL4tOX7OX3cAPDXmaOSYqRIMt4xRm3iC2HgnRTFLbbw3lt/sLmCiuJcyaCtzQfcAzlSpm/PbB3VNwAAoCWEpz4nkIyYOhCOBhFceooi+24iS1SGRwFOfrxbO8+LHzjX4=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2352.namprd13.prod.outlook.com (52.135.94.144) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.12; Tue, 19 Mar 2019 16:58:08 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%5]) with mapi id 15.20.1730.013; Tue, 19 Mar 2019
 16:58:08 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "olga.kornievskaia@gmail.com" <olga.kornievskaia@gmail.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFSv4.1 don't free interrupted slot on open
Thread-Topic: [PATCH 1/1] NFSv4.1 don't free interrupted slot on open
Thread-Index: AQHU3m6KRIz4MVliH0Oye+eJa7VOMqYTLPqA
Date:   Tue, 19 Mar 2019 16:58:07 +0000
Message-ID: <69bf9ff828146f64524e59284df23633244ba2fc.camel@hammerspace.com>
References: <20190319161213.11691-1-olga.kornievskaia@gmail.com>
In-Reply-To: <20190319161213.11691-1-olga.kornievskaia@gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c3e639de-0af8-4de0-c797-08d6ac8c1001
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2352;
x-ms-traffictypediagnostic: SN6PR13MB2352:
x-microsoft-antispam-prvs: <SN6PR13MB2352234C8C55E9128257EFC8B8400@SN6PR13MB2352.namprd13.prod.outlook.com>
x-forefront-prvs: 0981815F2F
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(136003)(346002)(366004)(396003)(39830400003)(189003)(199004)(5660300002)(6486002)(53936002)(305945005)(81166006)(81156014)(6246003)(8676002)(7736002)(6512007)(229853002)(3846002)(14454004)(478600001)(66066001)(97736004)(8936002)(118296001)(2906002)(6116002)(316002)(6436002)(110136005)(68736007)(256004)(4326008)(86362001)(76176011)(105586002)(11346002)(25786009)(106356001)(2501003)(446003)(36756003)(102836004)(2616005)(186003)(26005)(486006)(71190400001)(71200400001)(6506007)(476003)(99286004)(14444005);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2352;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: BKsmk3euSGb+8EoiiTAtjmBykg8YhAynLrKUs+o5U+K6xGrjr12cF3Lsl77OyB/jnhNX9CnCSL3E+r7tE9YDj7Z/L/0yEIopxPm3h7F8Sq2/QWbEgDSfL5TTtSu+m9hFYtvBZFRzy4q7sLSS+4wF4wV4Ty0Ht2Fd/i1fXenu2I9Huv3/Ts0DvtdMtTr3uoTH68/uFPYa9Id5sBIhXpateA9+ZaD23jhyXp/xPQ7mmeol46SOZ7KJKJM42x6ZLp287xH3BDDa/yWP57gjiYGs5wx0smMdrm5sz9dwJAKelk1o0Tmy5MaVG6sa3E8Ia/pSk3D0f2S1AE+J6JEmoWX8/WyOgbmEGiamV5axWBRmYAJbqH6QGdjcpYEbVDg9hHLRiLsFHkefrTRTBDUj4czP6qkWa8LXnFOvkV+byHr7Ew4=
Content-Type: text/plain; charset="utf-8"
Content-ID: <0B78CA064E3F5346A1FA4D0AFDAB0CEA@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c3e639de-0af8-4de0-c797-08d6ac8c1001
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Mar 2019 16:58:08.2454
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2352
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE5LTAzLTE5IGF0IDEyOjEyIC0wNDAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90
ZToNCj4gRnJvbTogT2xnYSBLb3JuaWV2c2thaWEgPGtvbGdhQG5ldGFwcC5jb20+DQo+IA0KPiBB
bGxvdyB0aGUgYXN5bmMgcnBjIHRhc2sgZm9yIGZpbmlzaCBhbmQgdXBkYXRlIHRoZSBvcGVuIHN0
YXRlIGlmDQo+IG5lZWRlZCwNCj4gdGhlbiBmcmVlIHRoZSBzbG90LiBPdGhlcndpc2UsIHRoZSBh
c3luYyBycGMgdW5hYmxlIHRvIGRlY29kZSB0aGUNCj4gcmVwbHkuDQo+IA0KPiBTaWduZWQtb2Zm
LWJ5OiBPbGdhIEtvcm5pZXZza2FpYSA8a29sZ2FAbmV0YXBwLmNvbT4NCj4gLS0tDQo+ICBmcy9u
ZnMvbmZzNHByb2MuYyB8IDMgKystDQo+ICAxIGZpbGUgY2hhbmdlZCwgMiBpbnNlcnRpb25zKCsp
LCAxIGRlbGV0aW9uKC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvZnMvbmZzL25mczRwcm9jLmMgYi9m
cy9uZnMvbmZzNHByb2MuYw0KPiBpbmRleCA0ZGJiMGVlLi45NmMyNDk5IDEwMDY0NA0KPiAtLS0g
YS9mcy9uZnMvbmZzNHByb2MuYw0KPiArKysgYi9mcy9uZnMvbmZzNHByb2MuYw0KPiBAQCAtMjkz
Myw3ICsyOTMzLDggQEAgc3RhdGljIGludCBfbmZzNF9vcGVuX2FuZF9nZXRfc3RhdGUoc3RydWN0
DQo+IG5mczRfb3BlbmRhdGEgKm9wZW5kYXRhLA0KPiAgCX0NCj4gIA0KPiAgb3V0Og0KPiAtCW5m
czRfc2VxdWVuY2VfZnJlZV9zbG90KCZvcGVuZGF0YS0+b19yZXMuc2VxX3Jlcyk7DQo+ICsJaWYg
KCFvcGVuZGF0YS0+Y2FuY2VsbGVkKQ0KPiArCQluZnM0X3NlcXVlbmNlX2ZyZWVfc2xvdCgmb3Bl
bmRhdGEtPm9fcmVzLnNlcV9yZXMpOw0KPiAgCXJldHVybiByZXQ7DQo+ICB9DQo+ICANCg0KTmlj
ZSBjYXRjaCEgVGhhbmsgeW91LCBPbGdhLiBJIGFncmVlIHRoYXQgY2FuIGNhdXNlIG1ham9yIGNv
bmZ1c2lvbg0Kd2hlbiBzb21lIG90aGVyIHByb2Nlc3Mgc2VuZHMgYSBuZXcgcmVxdWVzdCBvbiB0
aGUgc2FtZSBzbG90Lg0KDQpBcHBseWluZyBmb3IgbGludXgtbmV4dCBhbmQgbWFya2luZyBhcyBh
IHN0YWJsZSBmaXguDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1h
aW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoN
Cg0K
