Return-Path: <SRS0=1lKr=M5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6513ECDE32
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Oct 2018 17:35:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0865A2148E
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Oct 2018 17:35:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="mG20zC/R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0865A2148E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727061AbeJRBbr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 17 Oct 2018 21:31:47 -0400
Received: from mail-eopbgr710129.outbound.protection.outlook.com ([40.107.71.129]:13347
        "EHLO NAM05-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727037AbeJRBbr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 17 Oct 2018 21:31:47 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=OVT58uaH4Ntu6lAtLJNXTuCh8ph6yoDffNfDXIW1KHc=;
 b=mG20zC/RDj3LHPNe1bdgIN3Tbym+6h+CYwnGDA5GQoVE/rT3GPlcqHtasYGDUKHfeNS+ZpaM4OArlkJMr/nK9uAUcq7Foc/ssneE5J34dOu3hoe/nz/4PpOdZDJsMbW8kbwZLG43Yllv3I/ZwyUEdBGFssD+WZEx34y8mqGcm50=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2528.namprd13.prod.outlook.com (52.135.95.158) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1250.12; Wed, 17 Oct 2018 17:34:49 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::cd3a:751f:9a4:7297]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::cd3a:751f:9a4:7297%4]) with mapi id 15.20.1250.013; Wed, 17 Oct 2018
 17:34:49 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bcodding@redhat.com" <bcodding@redhat.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] nfs: Fix a missed page unlock after pg_doio()
Thread-Topic: [PATCH 2/2] nfs: Fix a missed page unlock after pg_doio()
Thread-Index: AQHUZjNAH8bw4FUxWkexIgyAsQpIbqUjsv0A
Date:   Wed, 17 Oct 2018 17:34:48 +0000
Message-ID: <505bf79503b80ffa16740c4d5fb40732f4d790b9.camel@hammerspace.com>
References: <da793f7920f4d263d4a4f47f7f524f3c1eaf59b4.1539792123.git.bcodding@redhat.com>
         <63d8e14cfc732a5224bfd7ecb662f2da4d708ad0.1539792123.git.bcodding@redhat.com>
In-Reply-To: <63d8e14cfc732a5224bfd7ecb662f2da4d708ad0.1539792123.git.bcodding@redhat.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2528;6:+uBP840OVyBqX3e0Aem2Bj3sGmuVErd3wauvi6kuGqRzrhzuu1kyDBI49Ct5t2yz8hIhzSFY9qR8hQdGGhc0HxW2B/ubC8t1FcBHrUQjH8QtPwrh3YCpreN+p4N71T4KkZgxdzBfDZHN3zZhVXpLD8vLvuwJwb2urD0RtX+geI7QvR9oiC7mYEJwt8vv2BUp8kCy8O5Y6NMFQSPSYr69xvPm9CXUHx2AfABJ9PY5sjNrokjS8xr+pk3iyfF+uMhJuGp06Hrl+GE2rAUHcOsJQjdkCP9hSO20fOIhnIZmilP45dtpHL/HTRy9EfQ3Ase9dBSEn9jo5I8RqofAD4OG2aMkOAl9AZIPv0gZ5cMchFaaH2Uq2uw6iPObQH92Y2xZt3by9rJzEuKqhr+tohW52HrwnRzq9jiK2m6ieQcDP6SBSdMvQzQQXMq6YN3mLXXMDzxGc3IjOV0mGnKRNpPnbA==;5:8QSnvRBZXCa/bAPBgJ3ffyjux2DySnP366JR4If9jLihaW8mf8bdiC6+kR4gBYfya9AFBADNElKAnkSxcIw+KV0S78eHSznIlS0jw2jEB11E7AbvRO7/kdDghtqiGGuMbiQs8uj4qLkXQRvHsZDi/Y1ruTPy8jw+l5dowb4XP3A=;7:JNoAws7007M0akawfFm2LTi3iAaZp+rzXdA6Lg2orHMv//m+lrw6ssvLJ6J7FTXlMNfYCOuxYfAPOl40pfGBKWddTsy9BthJsvSVD8QKFQTsJDmuD0EMjw+DS+xujNWvT0dBk9t0qVOG/BAq/HnlBcGizPi3/RQmOenKn/ThKoDFzuk81RK6OtMba8IULGTKe3o1EUj9GOBxpiXhAv29QYTNM/4/R9q/Nt9ZZWHHsmoobBzz2Y1ISWM+DJq0rM6Z
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 8a18301a-befd-4234-bd21-08d63456d67f
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2528;
x-ms-traffictypediagnostic: SN6PR13MB2528:
x-microsoft-antispam-prvs: <SN6PR13MB25286AC0A28F6B9B210682E9B8FF0@SN6PR13MB2528.namprd13.prod.outlook.com>
x-exchange-antispam-report-test: UriScan:;
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(10201501046)(93006095)(93001095)(3231355)(944501410)(52105095)(3002001)(149066)(150057)(6041310)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123558120)(20161123562045)(20161123564045)(20161123560045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2528;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2528;
x-forefront-prvs: 08286A0BE2
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39840400004)(376002)(346002)(396003)(136003)(366004)(199004)(189003)(14454004)(7736002)(305945005)(5660300001)(8676002)(3846002)(81156014)(478600001)(8936002)(2501003)(6116002)(5250100002)(71200400001)(2906002)(66066001)(99286004)(71190400001)(81166006)(4001150100001)(97736004)(229853002)(102836004)(446003)(6506007)(2616005)(486006)(476003)(11346002)(36756003)(14444005)(76176011)(26005)(2900100001)(110136005)(68736007)(6486002)(6436002)(256004)(106356001)(6512007)(118296001)(6246003)(25786009)(53936002)(105586002)(316002)(186003)(86362001)(4326008);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2528;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: NpgFGubzKHOOMbzfyTx1qfEdTROpJQE+Bo4ZVeMf25ZG0oxprSi9uc8IQafxnCFsh0p6Qz/F0kEIKpghARBikdpgPLivV2lXtu/U9HMF8IkvFTAgRLWBbq7QRjdm2Ztsfm8N4GzyKL1swqfRM8AolmqSUdBq53l6a9itX61JFUXyO3W3vAE2DWeR6W+0g7m0kq1d/qLwcCpkBbDT7FhMJv7bMMb60w9LW24HjZ8vpIsj2w8B2HbXZ5iTYz71jRYGIekog26ixFWv9HArGZUDtCpknrYmuEV6pSXkHanMz1+fvqZphIE8UHziBkVUYVF9n6rcq4ZcGr5a+dIlxgDLeitvuuCKiuT86rFw2HiZDQg=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <8B1EBC6FC947E1478E6AA4D39AC5A203@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8a18301a-befd-4234-bd21-08d63456d67f
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Oct 2018 17:34:48.7531
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2528
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
Message-ID: <20181017173448.JabyCO2tsJWOqO9ECKKl1gzK45mPulF0qrmbR0qbfLA@z>

T24gV2VkLCAyMDE4LTEwLTE3IGF0IDEyOjA1IC0wNDAwLCBCZW5qYW1pbiBDb2RkaW5ndG9uIHdy
b3RlOg0KPiBXZSBtdXN0IGNoZWNrIHBnX2Vycm9yIGFuZCBjYWxsIGVycm9yX2NsZWFudXAgYWZ0
ZXIgYW55IGNhbGwgdG8NCj4gcGdfZG9pby4NCj4gQ3VycmVudGx5LCB3ZSBhcmUgc2tpcHBpbmcg
dGhlIHVubG9jayBvZiBhIHBhZ2UgaWYgd2UgZW5jb3VudGVyIGFuDQo+IGVycm9yIGluDQo+IG5m
c19wYWdlaW9fY29tcGxldGUoKSBiZWZvcmUgaGFuZGluZyBvZmYgdGhlIHdvcmsgdG8gdGhlIFJQ
QyBsYXllci4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IEJlbmphbWluIENvZGRpbmd0b24gPGJjb2Rk
aW5nQHJlZGhhdC5jb20+DQo+IC0tLQ0KPiAgZnMvbmZzL3BhZ2VsaXN0LmMgfCAzMyArKysrKysr
KysrKysrKysrKystLS0tLS0tLS0tLS0tLS0NCj4gIDEgZmlsZSBjaGFuZ2VkLCAxOCBpbnNlcnRp
b25zKCspLCAxNSBkZWxldGlvbnMoLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9mcy9uZnMvcGFnZWxp
c3QuYyBiL2ZzL25mcy9wYWdlbGlzdC5jDQo+IGluZGV4IGNkM2JjNDFhYjY4ZC4uNTRjMmJmYzQ1
YTU3IDEwMDY0NA0KPiAtLS0gYS9mcy9uZnMvcGFnZWxpc3QuYw0KPiArKysgYi9mcy9uZnMvcGFn
ZWxpc3QuYw0KPiBAQCAtMTExMCw2ICsxMTEwLDIwIEBAIHN0YXRpYyBpbnQNCj4gbmZzX3BhZ2Vp
b19hZGRfcmVxdWVzdF9taXJyb3Ioc3RydWN0IG5mc19wYWdlaW9fZGVzY3JpcHRvciAqZGVzYywN
Cj4gIAlyZXR1cm4gcmV0Ow0KPiAgfQ0KPiAgDQo+ICtzdGF0aWMgdm9pZCBuZnNfcGFnZWlvX2Vy
cm9yX2NsZWFudXAoc3RydWN0IG5mc19wYWdlaW9fZGVzY3JpcHRvcg0KPiAqZGVzYykNCj4gK3sN
Cj4gKwl1MzIgbWlkeDsNCj4gKwlzdHJ1Y3QgbmZzX3BnaW9fbWlycm9yICptaXJyb3I7DQo+ICsN
Cj4gKwlpZiAoIWRlc2MtPnBnX2Vycm9yKQ0KPiArCQlyZXR1cm47DQo+ICsNCj4gKwlmb3IgKG1p
ZHggPSAwOyBtaWR4IDwgZGVzYy0+cGdfbWlycm9yX2NvdW50OyBtaWR4KyspIHsNCj4gKwkJbWly
cm9yID0gJmRlc2MtPnBnX21pcnJvcnNbbWlkeF07DQo+ICsJCWRlc2MtPnBnX2NvbXBsZXRpb25f
b3BzLT5lcnJvcl9jbGVhbnVwKCZtaXJyb3ItDQo+ID5wZ19saXN0KTsNCj4gKwl9DQo+ICt9DQo+
ICsNCj4gIGludCBuZnNfcGFnZWlvX2FkZF9yZXF1ZXN0KHN0cnVjdCBuZnNfcGFnZWlvX2Rlc2Ny
aXB0b3IgKmRlc2MsDQo+ICAJCQkgICBzdHJ1Y3QgbmZzX3BhZ2UgKnJlcSkNCj4gIHsNCj4gQEAg
LTExNjAsMjAgKzExNzQsNyBAQCBpbnQgbmZzX3BhZ2Vpb19hZGRfcmVxdWVzdChzdHJ1Y3QNCj4g
bmZzX3BhZ2Vpb19kZXNjcmlwdG9yICpkZXNjLA0KPiAgCXJldHVybiAxOw0KPiAgDQo+ICBvdXRf
ZmFpbGVkOg0KPiAtCS8qDQo+IC0JICogV2UgbWlnaHQgaGF2ZSBmYWlsZWQgYmVmb3JlIHNlbmRp
bmcgYW55IHJlcXMgb3ZlciB3aXJlLg0KPiAtCSAqIENsZWFuIHVwIHJlc3Qgb2YgdGhlIHJlcXMg
aW4gbWlycm9yIHBnX2xpc3QuDQo+IC0JICovDQo+IC0JaWYgKGRlc2MtPnBnX2Vycm9yKSB7DQo+
IC0JCXN0cnVjdCBuZnNfcGdpb19taXJyb3IgKm1pcnJvcjsNCj4gLQkJdm9pZCAoKmZ1bmMpKHN0
cnVjdCBsaXN0X2hlYWQgKik7DQo+IC0NCj4gLQkJZnVuYyA9IGRlc2MtPnBnX2NvbXBsZXRpb25f
b3BzLT5lcnJvcl9jbGVhbnVwOw0KPiAtCQlmb3IgKG1pZHggPSAwOyBtaWR4IDwgZGVzYy0+cGdf
bWlycm9yX2NvdW50OyBtaWR4KyspIHsNCj4gLQkJCW1pcnJvciA9ICZkZXNjLT5wZ19taXJyb3Jz
W21pZHhdOw0KPiAtCQkJZnVuYygmbWlycm9yLT5wZ19saXN0KTsNCj4gLQkJfQ0KPiAtCX0NCj4g
KwluZnNfcGFnZWlvX2Vycm9yX2NsZWFudXAoZGVzYyk7DQo+ICAJcmV0dXJuIDA7DQo+ICB9DQo+
ICANCj4gQEAgLTEyNDUsNyArMTI0Niw5IEBAIHZvaWQgbmZzX3BhZ2Vpb19jb21wbGV0ZShzdHJ1
Y3QNCj4gbmZzX3BhZ2Vpb19kZXNjcmlwdG9yICpkZXNjKQ0KPiAgCWZvciAobWlkeCA9IDA7IG1p
ZHggPCBkZXNjLT5wZ19taXJyb3JfY291bnQ7IG1pZHgrKykNCj4gIAkJbmZzX3BhZ2Vpb19jb21w
bGV0ZV9taXJyb3IoZGVzYywgbWlkeCk7DQo+ICANCj4gLQlpZiAoZGVzYy0+cGdfb3BzLT5wZ19j
bGVhbnVwKQ0KPiArCWlmIChkZXNjLT5wZ19lcnJvciA8IDApDQo+ICsJCW5mc19wYWdlaW9fZXJy
b3JfY2xlYW51cChkZXNjKTsNCj4gKwllbHNlIGlmIChkZXNjLT5wZ19vcHMtPnBnX2NsZWFudXAp
DQo+ICAJCWRlc2MtPnBnX29wcy0+cGdfY2xlYW51cChkZXNjKTsNCg0KTmljZSBjYXRjaCwgYnV0
IHNob3VsZG4ndCB3ZSBiZSBjYWxsaW5nIGJvdGggbmZzX3BhZ2Vpb19lcnJvcl9jbGVhbnVwKCkN
CmFuZCBwZ19jbGVhbnVwKCk/IFRoZSBmb3JtZXIgd291bGQgYXBwZWFyIHRvIGJlIGNsZWFuaW5n
IHVwIHRoZSBwYWdlDQpzdHVmZiwgd2hpbGUgdGhlIGxhdHRlciBpcyBtYWlubHkgY2xlYW5pbmcg
dXAgdGhlIGxheW91dC4NCg0KPiAgCW5mc19wYWdlaW9fY2xlYW51cF9taXJyb3JpbmcoZGVzYyk7
DQo+ICB9DQoNClNob3VsZCB0aGlzIHBlcmhhcHMgYmUgYSBzdGFibGUgZml4Pw0KDQotLSANClRy
b25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0K
dHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
