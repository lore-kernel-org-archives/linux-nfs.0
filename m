Return-Path: <SRS0=kagm=SN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5331CC10F13
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 16:46:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E85902146F
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 16:46:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="t/YQjuNO"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726595AbfDKQqz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 11 Apr 2019 12:46:55 -0400
Received: from mail-eopbgr800132.outbound.protection.outlook.com ([40.107.80.132]:25957
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726538AbfDKQqz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 11 Apr 2019 12:46:55 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ZPbzLHm3eHWHpeuG1B6k665i4M8jG8LQIE3nb1Ih344=;
 b=t/YQjuNO7nSMJvyN2rZm0YnVWR1lbLEiFLAcUR6clc8b5q4w1GpZBVeMKHBacHI6UMFW7MHHH3koneK8hrwsdbCJhkhZWeRfl2/lDvkd/88XpJHw2mTY1BKVhAO1bgJIeDnAw2d97uQiit84uEnsV7Njpp/m9FU4dYhSHb22nQI=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2304.namprd13.prod.outlook.com (52.135.94.23) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1792.15; Thu, 11 Apr 2019 16:46:51 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1792.007; Thu, 11 Apr 2019
 16:46:51 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "olga.kornievskaia@gmail.com" <olga.kornievskaia@gmail.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFSv4.1 fix incorrect return value in copy_file_range
Thread-Topic: [PATCH 1/1] NFSv4.1 fix incorrect return value in
 copy_file_range
Thread-Index: AQHU8IOGkX0JgFjPkkOfyqt8wY1bPqY3K0gA
Date:   Thu, 11 Apr 2019 16:46:51 +0000
Message-ID: <0de6cbcd86a69d2e19e4adc2cd70822ce0ae557a.camel@hammerspace.com>
References: <20190411162747.4360-1-olga.kornievskaia@gmail.com>
In-Reply-To: <20190411162747.4360-1-olga.kornievskaia@gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 818543b2-5cea-4660-b74c-08d6be9d4bdd
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2304;
x-ms-traffictypediagnostic: SN6PR13MB2304:
x-microsoft-antispam-prvs: <SN6PR13MB23049CACC40D0B23F1FDE887B82F0@SN6PR13MB2304.namprd13.prod.outlook.com>
x-forefront-prvs: 00046D390F
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(396003)(136003)(376002)(346002)(39830400003)(199004)(189003)(71190400001)(6436002)(97736004)(14454004)(7736002)(8936002)(81156014)(105586002)(81166006)(2501003)(106356001)(8676002)(486006)(6506007)(478600001)(66066001)(76176011)(110136005)(6512007)(186003)(6486002)(5660300002)(14444005)(256004)(118296001)(102836004)(26005)(25786009)(6246003)(53936002)(68736007)(446003)(99286004)(11346002)(2616005)(4326008)(316002)(476003)(3846002)(6116002)(86362001)(229853002)(305945005)(36756003)(2906002)(71200400001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2304;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Au3B98xeIl0kCchYxSMVcVHMBsxIkK+hk+iC391DideJ48OTgq1s7zBFiOMlOo0x+e8BqstTBFdw3sXbC2Gsx8JavHD/5/hihLwjsb7UFqdHntHdRUYjR/eIzqECN9qiPD0tOnQgtV+8G5wDsPCKi8Eu4PY7dTVjvgIWEGReRiHmDs29Lyonncqc64WjeyisO35rrKj351nFCeJZsTnErBQ6LqLfGumc34UvyLM7dKOigHNVNzdXYMbEg94rmRSJOR6I0O4DDo8cBYopcQdB2OS1Tpa0NUE/VGhzaYlWALpc305+3e/2g+nBnEaIAhxPlSowCV3OLJBzAWdQPsWfTG5Uoxr/yR1WW8jULgurg+Z1MKsdkkayowy3DZKjXsE5gpGTFFlC6gqpP+T7TYOUBtHACkK734Dpdd1PJgD/INM=
Content-Type: text/plain; charset="utf-8"
Content-ID: <C0D1527493ED8F4CA24782B2138BA362@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 818543b2-5cea-4660-b74c-08d6be9d4bdd
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Apr 2019 16:46:51.0627
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2304
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTA0LTExIGF0IDEyOjI3IC0wNDAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90
ZToNCj4gRnJvbTogT2xnYSBLb3JuaWV2c2thaWEgPGtvbGdhQG5ldGFwcC5jb20+DQo+IA0KPiBX
aGVuIFZGUyBjYWxscyBjb3B5X2ZpbGVfcmFuZ2Ugb24gYSA0LjAgbW91bnQgKGFuZCB3aGVuIGlu
IGFuZCBvdXQNCj4gZmlsZSBpcyB0aGUgc2FtZSksIHdlIG5lZWQgdG8gcmV0dXJuIEVOT1RTVVBQ
IGluc3RlYWQgb2YgRUlOVkFMLg0KPiBTaW5jZSBubyBDT1BZIG9wZXJhdGlvbiBpcyBkZWZpbmVk
IGluIDQuMCwgdGhlbiBsaWtlIDMuMCwgaXQgc2hvdWxkDQo+IGZhbGxiYWNrIHRvIGRvaW5nIGRv
X3NwbGljZV9kaXJlY3QoKS4NCj4gDQo+IE90aGVyd2lzZSB4ZnN0ZXN0IGdlbmVyaWMvMDc1LDA5
MSwxMTIsMjYzIGZhaWwuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBPbGdhIEtvcm5pZXZza2FpYSA8
a29sZ2FAbmV0YXBwLmNvbT4NCj4gLS0tDQo+ICBmcy9uZnMvbmZzNGZpbGUuYyB8IDYgKysrKysr
DQo+ICAxIGZpbGUgY2hhbmdlZCwgNiBpbnNlcnRpb25zKCspDQo+IA0KPiBkaWZmIC0tZ2l0IGEv
ZnMvbmZzL25mczRmaWxlLmMgYi9mcy9uZnMvbmZzNGZpbGUuYw0KPiBpbmRleCA0NWIyMzIyLi45
YTIyMmIwIDEwMDY0NA0KPiAtLS0gYS9mcy9uZnMvbmZzNGZpbGUuYw0KPiArKysgYi9mcy9uZnMv
bmZzNGZpbGUuYw0KPiBAQCAtMTMzLDYgKzEzMywxMiBAQCBzdGF0aWMgc3NpemVfdCBuZnM0X2Nv
cHlfZmlsZV9yYW5nZShzdHJ1Y3QgZmlsZQ0KPiAqZmlsZV9pbiwgbG9mZl90IHBvc19pbiwNCj4g
IAkJCQkgICAgc3RydWN0IGZpbGUgKmZpbGVfb3V0LCBsb2ZmX3QNCj4gcG9zX291dCwNCj4gIAkJ
CQkgICAgc2l6ZV90IGNvdW50LCB1bnNpZ25lZCBpbnQgZmxhZ3MpDQo+ICB7DQo+ICsJc3RydWN0
IG5mc19zZXJ2ZXIgKnNlcnZlciA9IE5GU19TRVJWRVIoZmlsZV9pbm9kZShmaWxlX2luKTsNCj4g
KwlzdHJ1Y3QgbmZzX2NsaWVudCAqY2xpZW50ID0gc2VydmVyLT5uZnNfY2xpZW50Ow0KPiArDQo+
ICsJaWYgKGNsaWVudC0+Y2xfbWlub3J2ZXJzaW9uIDwgMSkNCj4gKwkJcmV0dXJuIC1FT1BOT1RT
VVBQOw0KPiArDQo+ICAJaWYgKGZpbGVfaW5vZGUoZmlsZV9pbikgPT0gZmlsZV9pbm9kZShmaWxl
X291dCkpDQo+ICAJCXJldHVybiAtRUlOVkFMOw0KPiAgCXJldHVybiBuZnM0Ml9wcm9jX2NvcHko
ZmlsZV9pbiwgcG9zX2luLCBmaWxlX291dCwgcG9zX291dCwNCj4gY291bnQpOw0KDQpMZXQncyBw
bGVhc2UganVzdCBtb3ZlIHRoZSB0ZXN0IGZvciBORlNfQ0FQX0NPUFkgZnJvbSBuZnM0Ml9wcm9j
X2NvcHkoKQ0KaW50byB0aGUgYWJvdmUgZnVuY3Rpb24uDQoNCkJUVzogV2h5IGRvIHdlIHJldHVy
biAtRUlOVkFMIGluIHRoZSBmaWxlX2luID09IGZpbGVfb3V0IGNhc2U/IElzIHRoZXJlDQphbnkg
cmVhc29uIHdoeSB3ZSBzaG91bGRuJ3QganVzdCByZXR1cm4gRU9QTk9UU1VQUCB0aGVyZSB0b28g
aW4gb3JkZXINCnRvIGxldCBzcGxpY2UoKSBmdWxmaWwgdGhlIG9wZXJhdGlvbj8NCg0KLS0gDQpU
cm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UN
CnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
