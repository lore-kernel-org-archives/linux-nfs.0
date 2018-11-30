Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89441C04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 18:48:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 48BF620868
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 18:48:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="EAlSVoCg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48BF620868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725842AbeLAF6h (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 00:58:37 -0500
Received: from mail-eopbgr790138.outbound.protection.outlook.com ([40.107.79.138]:10946
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725817AbeLAF6h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 1 Dec 2018 00:58:37 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=y6EU+mUFeWADuzaWlXGrGLm6HhVUCVwje5aZuF95aCM=;
 b=EAlSVoCgYhuU11bxAX42uZt+z8AxFsgfPss4ko9vHYyvO4xBsyFqy2PBi8s5R6Pa+GljYDo0LVnyHyEPzS9VMEm7MSCGAvu/roD8IZL2hrammE2tSiLzCg7qbYDfW4+yZUljF15TIcHJqDd7FyZ0ANsi/yd9EcaZ1K9aD6IiQjg=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2237.namprd13.prod.outlook.com (52.135.93.150) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1382.14; Fri, 30 Nov 2018 18:48:21 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1404.011; Fri, 30 Nov 2018
 18:48:21 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "smayhew@redhat.com" <smayhew@redhat.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: deal with v4.0 servers that request confirmation
 on reclaim-type opens
Thread-Topic: [PATCH] NFSv4: deal with v4.0 servers that request confirmation
 on reclaim-type opens
Thread-Index: AQHUiNP86X56NnEjSEGzDNxYkRi52qVoqN2A
Date:   Fri, 30 Nov 2018 18:48:21 +0000
Message-ID: <00437311617dcd1bd316b452e8b9670c4dc0942f.camel@hammerspace.com>
References: <20181130174151.19448-1-smayhew@redhat.com>
         <20181130174151.19448-2-smayhew@redhat.com>
In-Reply-To: <20181130174151.19448-2-smayhew@redhat.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2237;6:OGiEO28/w1erZ3VZJ2LYgmG3yqEWMMW7QDWQZ0x/CyDzzd6CWG0RbZ/dt8MUjiXgs+X0HdiCAVmchHpx/xY7pD/vyc2pVQhI8dDpPDocXu2dGOX9n1X1Qq/FeyAfxwvIpwTRZpx/w+A+MdhFZ9SpiZb40JF2O/HEn0hn9oApp6Qp6i6LK5jKgFpoYGFrE86uYhqe5qHHFg0XNl7eMeW0G5xPUg4sXVS2DeSHdvaiV8TSDFBzW0Iv/lSxPPAidmg+N05OUn06EmBnQzg+N90V8d6PYPdtwae7huJiL976igiZ8ApYXk9uED99et56Vmz4hV3roYaAamc6Qi+yAcJkulksjCyT9HnO04ocyiIfVcZXCfBAS3WXX0uA9GojUxXGU52+zBf4MyEfMjjKsHsSWP0lCniDxeCGF941PEJ0nyvMo8/85JeHnD/ML+WR5o9OLhfsjrrZg5VYWR9h4hX1eQ==;5:dw7VkC17VeR1axZhXVmzPo9cYs/wgGFX38vemjPhwmWjK0gbw4BzAFlRTLobvvWxxQtnz9o79+yKDCQ3LC/TeCbD87WFjiP3esCsAUzrn08nJuKJxTeXY2f3tXD7VrkV/NuORZAPnTIipS19uysiEZ7ndcIsgaWjVqzxmTQvccE=;7:EXSBTLbhIwwKuoVvowAFgAnxzok24TXfdvN0eWeLaWW2L2WXKAw91yEXxhrsCFrxb/dhBr4EkBcZgk4Ds9JNjbjH+5bvwDwxvIKKIIw28vHr5DooDQDAM3WZAEmomgZlbRAHjOeBLSSTZYuVxlxzVQ==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: b5af1ba5-2772-44eb-40e2-08d656f466d6
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2237;
x-ms-traffictypediagnostic: SN6PR13MB2237:
x-microsoft-antispam-prvs: <SN6PR13MB22373C45F7BB65B4B3968817B8D30@SN6PR13MB2237.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(10201501046)(93006095)(93001095)(3231453)(999002)(944501410)(52105112)(3002001)(148016)(149066)(150057)(6041310)(20161123560045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123564045)(20161123562045)(20161123558120)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2237;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2237;
x-forefront-prvs: 087223B4DA
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(396003)(39830400003)(376002)(136003)(366004)(189003)(199004)(81166006)(6436002)(6512007)(97736004)(7736002)(8676002)(8936002)(102836004)(229853002)(81156014)(53936002)(5660300001)(36756003)(6246003)(186003)(110136005)(305945005)(4326008)(4001150100001)(66066001)(26005)(25786009)(71190400001)(2501003)(71200400001)(14454004)(476003)(2616005)(6506007)(118296001)(446003)(316002)(6486002)(478600001)(486006)(11346002)(6116002)(76176011)(106356001)(14444005)(105586002)(256004)(99286004)(68736007)(2906002)(86362001)(3846002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2237;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: 8JN921I32cGqxzgf9wFuE9En0vQAViJccY3qCa8nuUnz1MnzkqU+RiaiuDHiy9OvmAagfbH3fDlR/PCSDUm0zcCdINHH4Nyw07Y40L1rjI1O9XpH/8xzItchUK+KNF9qy6b+D6pLyXC21J3K1fTf/FtrqXhY3eLUSoyAKcLOktY2zummp+6Rbxbb9OAGysWdpb/cqc+WtqaHOSnk6SyRwoSriwLbKozEYCe6+3flg6xp9A7CW4EGizcB6XugqN1UQ2ttRMa5+pJuxli4uxi2TeVyfqqr+4Todt273+5MeAX6kIGg5asXep5pyl3vGnNtN+/BKvuu5Wmt7wy2hAJKMX/h9RRNtTSQCfd/YrGCU/A=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <5CCF7DEF9EE1574393869F54C108A594@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b5af1ba5-2772-44eb-40e2-08d656f466d6
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Nov 2018 18:48:21.5839
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2237
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE4LTExLTMwIGF0IDEyOjQxIC0wNTAwLCBTY290dCBNYXloZXcgd3JvdGU6DQo+
IFRoZXJlIGFyZSBzb21lIE5GUyB2NC4wIHNlcnZlcnMgdGhhdCByZXF1ZXN0IGNvbmZpcm1hdGlv
biBvbg0KPiByZWNsYWltLXR5cGUgb3BlbnMgZXZlbiB0aG91Z2ggaXQgaXMgZGlzYWxsb3dlZCBi
eSBSRkMgNzUzMC4NCj4gDQo+IFRoZSBMaW51eCBORlMgY2xpZW50IHVzZWQgdG8gY29wZSB3aXRo
IHRob3NlIG9rYXkgZHVlIHRvDQo+IDEpIG5mczRfb3BlbmRhdGFfYWxsb2MoKSBzZXR0aW5nIHRo
ZSBmaWxlaGFuZGxlIGluIHRoZSBhcmdzIGZvciB0aGUNCj4gT1BFTl9DT05GSVJNIHRvIHBvaW50
IHRvIHRoZSBmaWxlaGFuZGxlIGluIHRoZSBPUEVOIHJlc3VsdHMsIGFuZA0KPiAyKSBuZnM0X29w
ZW5fcHJlcGFyZSgpIGNvcHlpbmcgdGhlIGZpbGVoYW5kbGUgZnJvbSB0aGUgT1BFTiBhcmdzIHRv
DQo+IHRoZQ0KPiBPUEVOIHJlc3VsdHMgd2hlbiBkb2luZyBhbiBvcGVuIGJ5IGZpbGVoYW5kbGUN
Cj4gDQo+IFRoZSBsYXR0ZXIgcGFydCB3YXMgcmVtb3ZlZCBieSBjb21taXQgNGUyZmNhYzc3Mzkw
ICgibmZzdjQ6IFVzZQ0KPiBjb3JyZWN0DQo+IGlub2RlIGluIF9uZnM0X29wZW5kYXRhX3RvX25m
czRfc3RhdGUoKSIpLi4uIGFuZCBzaW5jZSB0aGVyZSdzIG5vDQo+IEdFVEZIDQo+IGluIHRoZSBP
UEVOIGNvbXBvdW5kIHdoZW4gZG9pbmcgYSByZWNsYWltLXR5cGUgb3BlbiwgaWYgb25lIG9mIHRo
ZXNlDQo+IHNlcnZlcnMgZG9lcyByZXF1ZXN0IGNvbmZpcm1hdGlvbiB3ZSB3aW5kIHVwIHNlbmRp
bmcgYSB6ZXJvDQo+IGZpbGVoYW5kbGUNCj4gaW4gdGhlIFBVVEZIIG9mIHRoZSBPUEVOX0NPTkZJ
Uk0gY29tcG91bmQgYW5kIHRoZSBPUEVOX0NPTkZJUk0gZmFpbHMNCj4gd2l0aCBORlM0RVJSX0JB
REhBTkRMRSwgY2F1c2luZyB0aGUgcmVjbGFpbSB0byBmYWlsLg0KPiANCj4gQWRkIHRoZSBjb3B5
aW5nIG9mIHRoZSBmaWxlaGFuZGxlIGJhY2sgdG8gbmZzNF9vcGVuX3ByZXBhcmUoKSBhbmQNCj4g
bG9nIGEgd2FybmluZyBpbiB0aGUgZXZlbnQgdGhhdCB0aGUgY2xpZW50IGRvZXMgZ2V0IGEgcmVw
bHkgdG8NCj4gT1BFTihDTEFJTV9QUkVWSU9VUykgdGhhdCBoYXMgTkZTNF9PUEVOX1JFU1VMVF9D
T05GSVJNIHNldC4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IFNjb3R0IE1heWhldyA8c21heWhld0By
ZWRoYXQuY29tPg0KPiAtLS0NCj4gIGZzL25mcy9uZnM0cHJvYy5jIHwgOSArKysrKysrKy0NCj4g
IDEgZmlsZSBjaGFuZ2VkLCA4IGluc2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkNCj4gDQo+IGRp
ZmYgLS1naXQgYS9mcy9uZnMvbmZzNHByb2MuYyBiL2ZzL25mcy9uZnM0cHJvYy5jDQo+IGluZGV4
IDg2NzQ1N2Q2ZGZiZS4uNWU1MjFhNTA2ZGEzIDEwMDY0NA0KPiAtLS0gYS9mcy9uZnMvbmZzNHBy
b2MuYw0KPiArKysgYi9mcy9uZnMvbmZzNHByb2MuYw0KPiBAQCAtMjMyMyw2ICsyMzIzLDcgQEAg
c3RhdGljIHZvaWQgbmZzNF9vcGVuX3ByZXBhcmUoc3RydWN0IHJwY190YXNrDQo+ICp0YXNrLCB2
b2lkICpjYWxsZGF0YSkNCj4gIAkJLyogRmFsbCB0aHJvdWdoICovDQo+ICAJY2FzZSBORlM0X09Q
RU5fQ0xBSU1fRkg6DQo+ICAJCXRhc2stPnRrX21zZy5ycGNfcHJvYyA9DQo+ICZuZnM0X3Byb2Nl
ZHVyZXNbTkZTUFJPQzRfQ0xOVF9PUEVOX05PQVRUUl07DQo+ICsJCW5mc19jb3B5X2ZoKCZkYXRh
LT5vX3Jlcy5maCwgZGF0YS0+b19hcmcuZmgpOw0KPiAgCX0NCj4gIAlkYXRhLT50aW1lc3RhbXAg
PSBqaWZmaWVzOw0KPiAgCWlmIChuZnM0X3NldHVwX3NlcXVlbmNlKGRhdGEtPm9fYXJnLnNlcnZl
ci0+bmZzX2NsaWVudCwNCj4gQEAgLTI0NzAsOCArMjQ3MSwxNCBAQCBzdGF0aWMgaW50IF9uZnM0
X3JlY292ZXJfcHJvY19vcGVuKHN0cnVjdA0KPiBuZnM0X29wZW5kYXRhICpkYXRhKQ0KPiAgDQo+
ICAJbmZzX2ZhdHRyX21hcF9hbmRfZnJlZV9uYW1lcyhORlNfU0VSVkVSKGRpciksICZkYXRhLT5m
X2F0dHIpOw0KPiAgDQo+IC0JaWYgKG9fcmVzLT5yZmxhZ3MgJiBORlM0X09QRU5fUkVTVUxUX0NP
TkZJUk0pDQo+ICsJaWYgKG9fcmVzLT5yZmxhZ3MgJiBORlM0X09QRU5fUkVTVUxUX0NPTkZJUk0p
IHsNCj4gKwkJaWYgKGRhdGEtPm9fYXJnLmNsYWltID09IE5GUzRfT1BFTl9DTEFJTV9QUkVWSU9V
UykNCj4gKwkJCXByX2Vycl9yYXRlbGltaXRlZCgiTkZTOiBCcm9rZW4gTkZTdjQgc2VydmVyICVz
DQo+IGlzICINCj4gKwkJCQkJInJlcXVlc3Rpbmcgb3BlbiBjb25maXJtYXRpb24NCj4gZm9yICIN
Cj4gKwkJCQkJIk9QRU4oQ0xBSU1fUFJFVklPVVMpXG4iLA0KPiArCQkJCQlORlNfU0VSVkVSKGRp
ciktPm5mc19jbGllbnQtDQo+ID5jbF9ob3N0bmFtZSk7DQo+ICAJCXN0YXR1cyA9IF9uZnM0X3By
b2Nfb3Blbl9jb25maXJtKGRhdGEpOw0KPiArCX0NCj4gIA0KPiAgCXJldHVybiBzdGF0dXM7DQo+
ICB9DQoNCklmIHRoZSBzcGVjIHNheXMgdGhhdCB0aGUgc2VydmVyIGlzIGJyb2tlbiwgdGhlbiB3
ZSBkb24ndCBjaGFuZ2UgdGhlDQpjbGllbnQuIFdlIGFscmVhZHkgaGF2ZSBvbmUgdWdseSBoYWNr
IGxpa2UgdGhpcywgYnV0IHRoYXQgaXMgbm8gZXhjdXNlDQpmb3IgYWRkaW5nIGEgc2Vjb25kLg0K
DQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1t
ZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
