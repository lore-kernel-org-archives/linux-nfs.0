Return-Path: <SRS0=JsnX=SK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17F17C10F14
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 15:20:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B9FE220883
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 15:20:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="NYYG8Ynn"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727529AbfDHPUw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Apr 2019 11:20:52 -0400
Received: from mail-eopbgr800092.outbound.protection.outlook.com ([40.107.80.92]:12544
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727356AbfDHPUv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Apr 2019 11:20:51 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=VkgxvSegJ1myofcBCA36yskUKEFooXpfCBceWuGZCaU=;
 b=NYYG8YnnT1v7ca47hyxFo44D2ebhOFlvKNCv2KSWqILTh9Rxlb8HzPYMkOIj6eUgqzAe6nnoqi6FxLsVE4UDTet4WTB4xV4JhalKXUC6FjPz9qF3cyHPyOxuf3HS8RKqUpok7EiLCIMYtUaReoajOuqrbagS7UUSJ/pUHJheMNU=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2318.namprd13.prod.outlook.com (52.135.94.25) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1792.10; Mon, 8 Apr 2019 15:20:48 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1792.007; Mon, 8 Apr 2019
 15:20:48 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@redhat.com" <bfields@redhat.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] nfsd: Don't release the callback slot unless it was
 actually held
Thread-Topic: [PATCH v2] nfsd: Don't release the callback slot unless it was
 actually held
Thread-Index: AQHU68guSUpusONVv0Gu5SenJuNaWaYyZbYA
Date:   Mon, 8 Apr 2019 15:20:48 +0000
Message-ID: <4bf043aa23b4230bf41fbcd5611b3baff4977f1d.camel@hammerspace.com>
References: <20190405155437.5545-1-trond.myklebust@hammerspace.com>
In-Reply-To: <20190405155437.5545-1-trond.myklebust@hammerspace.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 710f1a85-b7bf-471a-495c-08d6bc35c76a
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2318;
x-ms-traffictypediagnostic: SN6PR13MB2318:
x-microsoft-antispam-prvs: <SN6PR13MB231849C33A17C2AC29607D52B82C0@SN6PR13MB2318.namprd13.prod.outlook.com>
x-forefront-prvs: 0001227049
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(366004)(346002)(376002)(39830400003)(136003)(199004)(189003)(6916009)(256004)(99286004)(25786009)(6116002)(6436002)(5660300002)(5640700003)(4326008)(476003)(486006)(3846002)(97736004)(2616005)(305945005)(7736002)(53936002)(86362001)(446003)(36756003)(316002)(11346002)(2351001)(2906002)(6512007)(106356001)(6486002)(6246003)(186003)(66066001)(229853002)(118296001)(105586002)(81166006)(2501003)(68736007)(71190400001)(76176011)(71200400001)(26005)(81156014)(102836004)(8676002)(14454004)(6506007)(8936002)(1730700003)(478600001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2318;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: ouK1Bb++nRzZuIoI2ThTttA8CA6YxYheUgYNzQ/2YCygTlqeeF4Se/zWLODInmKyzl9dUNmfc0gw8OTIXr+7ttNv1eT+SFum+nmNJJZ2eB0IDwdOvfwW+t9SF92bVDA8P5JzNycZCSW43CWWy3p7XvFlzj0bB/xE4ERWak7LxRb/nAnW2GAEnqjcQKY3ubeP+O+wiLm+cpuA/N40BKJB9nQLBeWCxBBbzZSZ6kPjzZJn+QA0RO41kNMAxV95/7pWEfQuf9SL09j6+QT1eCoXgv7m782CiQnMmKFBDgWCgTcqo2646Ui7BMrjESuNZM54TgHm3G/S2R0WFOHuZDaFHeMuCv+cddAjwqqHZ1Jrza0YyrfJ6Qgd8UIYR1XMwId13SX/kaxo+JWb+VaU+QD7QKdB8KlE4p9kf16r0rJkhjI=
Content-Type: text/plain; charset="utf-8"
Content-ID: <84101AC74DC1BD4DB5AC0925DC180B16@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 710f1a85-b7bf-471a-495c-08d6bc35c76a
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 Apr 2019 15:20:48.3573
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2318
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE5LTA0LTA1IGF0IDA4OjU0IC0wNzAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+IElmIHRoZXJlIGFyZSBtdWx0aXBsZSBjYWxsYmFja3MgcXVldWVkLCB3YWl0aW5nIGZvciB0
aGUgY2FsbGJhY2sNCj4gc2xvdCB3aGVuIHRoZSBjYWxsYmFjayBnZXRzIHNodXQgZG93biwgdGhl
biB0aGV5IGFsbCBjdXJyZW50bHkNCj4gZW5kIHVwIGFjdGluZyBhcyBpZiB0aGV5IGhvbGQgdGhl
IHNsb3QsIGFuZCBjYWxsDQo+IG5mc2Q0X2NiX3NlcXVlbmNlX2RvbmUoKSByZXN1bHRpbmcgaW4g
aW50ZXJlc3Rpbmcgc2lkZS1lZmZlY3RzLg0KPiANCj4gSW4gYWRkaXRpb24sIHRoZSAncmV0cnlf
bm93YWl0JyBwYXRoIGluIG5mc2Q0X2NiX3NlcXVlbmNlX2RvbmUoKQ0KPiBjYXVzZXMgYSBsb29w
IGJhY2sgdG8gbmZzZDRfY2JfcHJlcGFyZSgpIHdpdGhvdXQgZmlyc3QgZnJlZWluZyB0aGUNCj4g
c2xvdCwgd2hpY2ggY2F1c2VzIGEgZGVhZGxvY2sgd2hlbiBuZnNkNDFfY2JfZ2V0X3Nsb3QoKSBn
ZXRzIGNhbGxlZA0KPiBhIHNlY29uZCB0aW1lLg0KPiANCj4gVGhpcyBwYXRjaCB0aGVyZWZvcmUg
YWRkcyBhIGJvb2xlYW4gdG8gdHJhY2sgd2hldGhlciBvciBub3QgdGhlDQo+IGNhbGxiYWNrIGRp
ZCBwaWNrIHVwIHRoZSBzbG90LCBzbyB0aGF0IGl0IGNhbiBkbyB0aGUgcmlnaHQgdGhpbmcNCj4g
aW4gdGhlc2UgMiBjYXNlcy4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IFRyb25kIE15a2xlYnVzdCA8
dHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbT4NCj4gLS0tDQo+IHYyOiB0cnkgdG8gcmVz
dGFydCB0aGUgY2FsbGJhY2sgaWYgd2UgaGl0IG5mc2Q0X2NiX3NlcXVlbmNlX2RvbmUoKQ0KPiAg
ICAgd2l0aG91dCBhIHNsb3QuDQo+IA0KPiANCg0KSGkgQnJ1Y2UsDQoNClNob3VsZCB0aGlzIHBh
dGNoIHBlcmhhcHMgYmUgY29uc2lkZXJlZCBmb3Igc3RhYmxlPyBUaGUgY2FsbGJhY2sgc2xvdA0K
bGVhayBpcyBwZXJtYW5lbnQgKG9yIGF0IGxlYXN0IGZvciB0aGUgbGlmZXRpbWUgb2YgdGhlIG5m
czRfY2xpZW50KS4NCg0KQ2hlZXJzDQogIFRyb25kDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpM
aW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RA
aGFtbWVyc3BhY2UuY29tDQoNCg0K
