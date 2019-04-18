Return-Path: <SRS0=DJTG=SU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15FD3C10F0E
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Apr 2019 14:38:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AE8D821479
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Apr 2019 14:38:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="fYWLm9yx"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388070AbfDROif (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 18 Apr 2019 10:38:35 -0400
Received: from mail-eopbgr750129.outbound.protection.outlook.com ([40.107.75.129]:64327
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1733205AbfDROif (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Apr 2019 10:38:35 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=AmKHlbvKS9pbnKC4wdBTyQadVwMbuIeBv2MZ3H0Cq6A=;
 b=fYWLm9yxkZMwaE1Az/Q4uQqTtBQDcA53+ZXQxFrtthGKv1EbkKN99IsxFANa1u0xExyLpc7dxr5IMzjA2ZJ9zLt1GfjzZTH0qMigr6hwC2Del7kYDCvDyFuy/wiPjGzzSp0bZl2auft/PB5I8OAkaoyQkFj9sbUyHVzD0cjXGY8=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2383.namprd13.prod.outlook.com (52.135.94.151) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1813.9; Thu, 18 Apr 2019 14:38:31 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::48d2:c5de:2651:4c30]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::48d2:c5de:2651:4c30%2]) with mapi id 15.20.1835.003; Thu, 18 Apr 2019
 14:38:31 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "smayhew@redhat.com" <smayhew@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Question about open(CLAIM_FH)
Thread-Topic: Question about open(CLAIM_FH)
Thread-Index: AQHU9evf84hrBN7rMkSy4LhuOmeSbqZB/O+A
Date:   Thu, 18 Apr 2019 14:38:31 +0000
Message-ID: <213d4ead8a7ae890dadc7785d59117e798f94748.camel@hammerspace.com>
References: <20190418133728.GS3773@coeurl.usersys.redhat.com>
In-Reply-To: <20190418133728.GS3773@coeurl.usersys.redhat.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b8752c7b-15bf-4d65-a4f1-08d6c40b8782
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600141)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:SN6PR13MB2383;
x-ms-traffictypediagnostic: SN6PR13MB2383:
x-microsoft-antispam-prvs: <SN6PR13MB23837700C2DB3E1C0A46B0DDB8260@SN6PR13MB2383.namprd13.prod.outlook.com>
x-forefront-prvs: 0011612A55
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(979002)(396003)(39830400003)(366004)(376002)(346002)(136003)(199004)(189003)(8676002)(14454004)(11346002)(6116002)(2906002)(476003)(3846002)(86362001)(97736004)(76176011)(186003)(478600001)(6506007)(102836004)(486006)(25786009)(316002)(26005)(66066001)(99286004)(118296001)(81156014)(6246003)(2616005)(53936002)(71200400001)(5660300002)(110136005)(7736002)(446003)(305945005)(81166006)(2501003)(8936002)(6512007)(36756003)(14444005)(6436002)(229853002)(6486002)(68736007)(256004)(71190400001)(969003)(989001)(999001)(1009001)(1019001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2383;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: XVd0h1ZaQKEP/PEf2ujSHlJoBGoN15KCem+MF6Qm+e7Vv1KxahIbUHpWMeS2tEkeOV37HhI5TxzNPc1Op6DmP3z6ZDUddBzF8X7JHSTmmqzWdxXcpJKEZOdM0aHhq2eu8ymVWzPCukimeTFw9JSVLj9fIzLR3x6BG/h2kul83I9SQu1DRVa8paOFU2YvAIoLY2Z68EQ5s9kc11wjImch8aqHV06NXS/g60qs7X9fPgsSj0G4HJygQgq084dJ3ti4r64+MKLrYWUjmAenZv44TNCWsVWt978KUijr6Mz73/zh6JArecqB7rKEDVmVXhxnALAJY2Nw2rKxOpEF/QRUwgUNNIy03IJxH000mo54POMyexm/Bub7GIwbAhNwK1IYQ49hy9aojM9iLgs0Hx0QRVa5wNHBBYxWjBz3XWPA+Y0=
Content-Type: text/plain; charset="utf-8"
Content-ID: <86AD392D71697D4F84E61EA2F2FAA4D1@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b8752c7b-15bf-4d65-a4f1-08d6c40b8782
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Apr 2019 14:38:31.5383
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2383
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgU2NvdHQsDQoNCk9uIFRodSwgMjAxOS0wNC0xOCBhdCAwOTozNyAtMDQwMCwgU2NvdHQgTWF5
aGV3IHdyb3RlOg0KPiBXaGVuIHRoZSBjbGllbnQgZG9lcyBhbiBvcGVuKENMQUlNX0ZIKSBhbmQg
dGhlIHNlcnZlciBhbHJlYWR5IGhhcw0KPiBvcGVuDQo+IHN0YXRlIGZvciB0aGF0IG9wZW4gb3du
ZXIgYW5kIGZpbGUsIHdoYXQncyBzdXBwb3NlZCB0byBoYXBwZW4/DQo+IEN1cnJlbnRseSB0aGUg
c2VydmVyIHJldHVybnMgdGhlIGV4aXN0aW5nIHN0YXRlaWQgd2l0aCB0aGUgc2VxaWQNCj4gYnVt
cGVkLA0KPiBidXQgaXQgbG9va3MgbGlrZSB0aGUgY2xpZW50IGlzIGV4cGVjdGluZyBhIG5ldyBz
dGF0ZWlkIChJJ20gc2VlaW5nDQo+IHRoZQ0KPiBzdGF0ZSBtYW5hZ2VyIHNwZW5kaW5nIGEgbG90
IG9mIHRpbWUgd2FpdGluZyBpbg0KPiBuZnNfc2V0X29wZW5fc3RhdGVpZF9sb2NrZWQoKSBkdWUg
dG8gTkZTX1NUQVRFX0NIQU5HRV9XQUlUIGJlaW5nIHNldA0KPiBpbg0KPiB0aGUgc3RhdGUgZmxh
Z3MgYnkgbmZzX25lZWRfdXBkYXRlX29wZW5fc3RhdGVpZCgpKS4NCj4gDQo+IExvb2tpbmcgYXQg
cmZjNTY2MSBzZWN0aW9uIDE4LjE2LjMsIEkgc2VlOg0KPiANCj4gICAgfCBDTEFJTV9OVUxMLCBD
TEFJTV9GSCB8IEZvciB0aGUgY2xpZW50LCB0aGlzIGlzIGEgbmV3IE9QRU4NCj4gcmVxdWVzdCB8
DQo+ICAgIHwgICAgICAgICAgICAgICAgICAgICAgfCBhbmQgdGhlcmUgaXMgbm8gcHJldmlvdXMg
c3RhdGUNCj4gYXNzb2NpYXRlZCAgfA0KPiAgICB8ICAgICAgICAgICAgICAgICAgICAgIHwgd2l0
aCB0aGUgZmlsZSBmb3IgdGhlDQo+IGNsaWVudC4gIFdpdGggICAgICAgIHwNCj4gICAgfCAgICAg
ICAgICAgICAgICAgICAgICB8IENMQUlNX05VTEwsIHRoZSBmaWxlIGlzIGlkZW50aWZpZWQgYnkN
Cj4gdGhlICB8DQo+ICAgIHwgICAgICAgICAgICAgICAgICAgICAgfCBjdXJyZW50IGZpbGVoYW5k
bGUgYW5kIHRoZQ0KPiBzcGVjaWZpZWQgICAgICAgfA0KPiAgICB8ICAgICAgICAgICAgICAgICAg
ICAgIHwgY29tcG9uZW50IG5hbWUuICBXaXRoIENMQUlNX0ZIIChuZXcNCj4gdG8gICAgIHwNCj4g
ICAgfCAgICAgICAgICAgICAgICAgICAgICB8IE5GU3Y0LjEpLCB0aGUgZmlsZSBpcyBpZGVudGlm
aWVkIGJ5DQo+IGp1c3QgICB8DQo+ICAgIHwgICAgICAgICAgICAgICAgICAgICAgfCB0aGUgY3Vy
cmVudCBmaWxlaGFuZGxlLiAgDQo+IA0KPiBTbyBpdCBzZWVtcyBsaWtlIG1heWJlIHRoZSBzZXJ2
ZXIgc2hvdWxkIGJlIHRvc3NpbmcgdGhlIG9sZCBzdGF0ZSBhbmQNCj4gcmV0dXJuaW5nIGEgbmV3
IHN0YXRlaWQ/DQo+IA0KDQpOby4gQXMgZmFyIGFzIHRoZSBwcm90b2NvbCBpcyBjb25jZXJuZWQs
IHRoZSBvbmx5IGRpZmZlcmVuY2UgYmV0d2Vlbg0KQ0xBSU1fTlVMTCBhbmQgQ0xBSU1fRkggaXMg
dGhyb3VnaCBob3cgdGhlIGNsaWVudCBpZGVudGlmaWVzIHRoZSBmaWxlDQooaW4gdGhlIGZpcnN0
IGNhc2UsIHRocm91Z2ggYW4gaW1wbGljaXQgbG9va3VwLCBhbmQgaW4gdGhlIHNlY29uZCBjYXNl
DQp0aHJvdWdoIGEgZmlsZSBoYW5kbGUpLiBUaGUgY2xpZW50IHNob3VsZCBiZSBmcmVlIHRvIGlu
dGVybWl4IHRoZSB0d28NCnR5cGVzIG9mIE9QRU4sIGFuZCBpdCBzaG91bGQgZXhwZWN0IHRoZSBy
ZXN1bHRpbmcgc3RhdGVpZHMgdG8gZGVwZW5kDQpvbmx5IG9uIHdoZXRoZXIgb3Igbm90IHRoZSBv
cGVuX293bmVyIG1hdGNoZXMuIElmIHRoZSBvcGVuX293bmVyDQptYXRjaGVzIGFuIGV4aXN0aW5n
IHN0YXRlaWQsIHRoZW4gdGhhdCBzdGF0ZWlkIGlzIGJ1bXBlZCBhbmQgcmV0dXJuZWQuDQoNCkkn
bSBub3QgYXdhcmUgb2YgYW55IGV4cGVjdGF0aW9uIGluIHRoZSBjbGllbnQgdGhhdCB0aGlzIHNo
b3VsZCBub3QgYmUNCnRoZSBjYXNlLCBzbyBpZiB5b3UgYXJlIHNlZWluZyBkaWZmZXJlbnQgYmVo
YXZpb3VyLCB0aGVuIHNvbWV0aGluZyBlbHNlDQptdXN0IGJlIGF0IHdvcmsgaGVyZS4gSXMgdGhl
IGNsaWVudCBwZXJoYXBzIG1vdW50aW5nIHRoZSBzYW1lDQpmaWxlc3lzdGVtIGluIHR3byBkaWZm
ZXJlbnQgcGxhY2VzIGluIHN1Y2ggYSB3YXkgdGhhdCB0aGUgc3VwZXIgYmxvY2sNCmlzIG5vdCBi
ZWluZyBzaGFyZWQ/DQoNCkNoZWVycw0KICBUcm9uZA0KDQotLSANClRyb25kIE15a2xlYnVzdA0K
TGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0
QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
