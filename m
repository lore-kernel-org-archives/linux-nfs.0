Return-Path: <SRS0=DJTG=SU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A9A6C10F0E
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Apr 2019 15:26:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 10CC520821
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Apr 2019 15:26:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Ul4DMmuY"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1733205AbfDRP0r (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 18 Apr 2019 11:26:47 -0400
Received: from mail-eopbgr720114.outbound.protection.outlook.com ([40.107.72.114]:34588
        "EHLO NAM05-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1731317AbfDRP0r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Apr 2019 11:26:47 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ru/DbH8iJ5rgefb3iiWX9oSYZ4v0B9dOcMsJm2bgNwA=;
 b=Ul4DMmuYKtMBUlBkHh/ArcwJfYfnkrm1lqgWAq3Fff5jWgAmW0ecJpuNl2qetxbf35SP3jMK6JI8mwl85t7hRSFCkITTkCfpS2ME/k4PpuEdYVTArVkYhUs5lIj0JLAlZHKR0bp7zZYaYgROReVruPChjVcxP8FdAo0q/45wJN4=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2448.namprd13.prod.outlook.com (52.135.95.28) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1813.9; Thu, 18 Apr 2019 15:26:43 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::48d2:c5de:2651:4c30]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::48d2:c5de:2651:4c30%2]) with mapi id 15.20.1835.003; Thu, 18 Apr 2019
 15:26:43 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "smayhew@redhat.com" <smayhew@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Question about open(CLAIM_FH)
Thread-Topic: Question about open(CLAIM_FH)
Thread-Index: AQHU9evf84hrBN7rMkSy4LhuOmeSbqZB/O+AgAANdYA=
Date:   Thu, 18 Apr 2019 15:26:43 +0000
Message-ID: <2cb06c38ec956753eaf882dd30053f11532f5608.camel@hammerspace.com>
References: <20190418133728.GS3773@coeurl.usersys.redhat.com>
         <213d4ead8a7ae890dadc7785d59117e798f94748.camel@hammerspace.com>
In-Reply-To: <213d4ead8a7ae890dadc7785d59117e798f94748.camel@hammerspace.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 40f1148c-cade-4461-669f-08d6c4124339
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600141)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:SN6PR13MB2448;
x-ms-traffictypediagnostic: SN6PR13MB2448:
x-microsoft-antispam-prvs: <SN6PR13MB244833591EB6D7DFB2C3CE2AB8260@SN6PR13MB2448.namprd13.prod.outlook.com>
x-forefront-prvs: 0011612A55
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(346002)(366004)(136003)(199004)(189003)(14444005)(53936002)(86362001)(99286004)(2906002)(5660300002)(25786009)(446003)(486006)(508600001)(14454004)(229853002)(66066001)(110136005)(6512007)(186003)(26005)(2501003)(6486002)(76176011)(305945005)(6116002)(6506007)(3846002)(71200400001)(71190400001)(102836004)(6436002)(7736002)(8936002)(36756003)(81166006)(476003)(8676002)(6246003)(81156014)(97736004)(2616005)(68736007)(11346002)(5024004)(256004)(118296001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2448;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: tXnfI2Izrm08DXl0bPo+lh4ST9kq2Jw3ZW5si67cf8ZLQ2lhIRIGNcGnnKAx/toQxLwcWxdZnuT9dxPWWklkTdZ+OdJbj3o1S+VAz2Z9JFlygiD6JEcz8UgkSB/rz4YPPSgcOhk4Q7FUW/Vsp6EsvNkblR2s4vr/ln8AlSA8oZzckCEQg9ylY5yIjzv6uQk/y0RbJiPvL9M8dJcLumyYWREwMP8oAJ+uEzgLjC5q5ICLm0vp3D0tFZ+cMIz8/5+Vke2ThlW4/djV8nnRDbPnAChJBJx5k0Qtr6j9MrO2RydAo5sbsgR9bHic2BtttmO2m8vFykfr3OyByyAM4xweQ6dyXXSMQB1/nx1jPCpJNcgCCQkKAOjEuHM+z4TRQ4Oa50P36ZrWRkc7X3cb+jq+PJvIq9gKLf2LyNbKWWgxScs=
Content-Type: text/plain; charset="utf-8"
Content-ID: <9A9197551D914840A368D087CAF97AEF@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 40f1148c-cade-4461-669f-08d6c4124339
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Apr 2019 15:26:43.4133
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2448
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTA0LTE4IGF0IDE0OjM4ICswMDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+IEhpIFNjb3R0LA0KPiANCj4gT24gVGh1LCAyMDE5LTA0LTE4IGF0IDA5OjM3IC0wNDAwLCBT
Y290dCBNYXloZXcgd3JvdGU6DQo+ID4gV2hlbiB0aGUgY2xpZW50IGRvZXMgYW4gb3BlbihDTEFJ
TV9GSCkgYW5kIHRoZSBzZXJ2ZXIgYWxyZWFkeSBoYXMNCj4gPiBvcGVuDQo+ID4gc3RhdGUgZm9y
IHRoYXQgb3BlbiBvd25lciBhbmQgZmlsZSwgd2hhdCdzIHN1cHBvc2VkIHRvIGhhcHBlbj8NCj4g
PiBDdXJyZW50bHkgdGhlIHNlcnZlciByZXR1cm5zIHRoZSBleGlzdGluZyBzdGF0ZWlkIHdpdGgg
dGhlIHNlcWlkDQo+ID4gYnVtcGVkLA0KPiA+IGJ1dCBpdCBsb29rcyBsaWtlIHRoZSBjbGllbnQg
aXMgZXhwZWN0aW5nIGEgbmV3IHN0YXRlaWQgKEknbSBzZWVpbmcNCj4gPiB0aGUNCj4gPiBzdGF0
ZSBtYW5hZ2VyIHNwZW5kaW5nIGEgbG90IG9mIHRpbWUgd2FpdGluZyBpbg0KPiA+IG5mc19zZXRf
b3Blbl9zdGF0ZWlkX2xvY2tlZCgpIGR1ZSB0byBORlNfU1RBVEVfQ0hBTkdFX1dBSVQgYmVpbmcN
Cj4gPiBzZXQNCj4gPiBpbg0KPiA+IHRoZSBzdGF0ZSBmbGFncyBieSBuZnNfbmVlZF91cGRhdGVf
b3Blbl9zdGF0ZWlkKCkpLg0KPiA+IA0KPiA+IExvb2tpbmcgYXQgcmZjNTY2MSBzZWN0aW9uIDE4
LjE2LjMsIEkgc2VlOg0KPiA+IA0KPiA+ICAgIHwgQ0xBSU1fTlVMTCwgQ0xBSU1fRkggfCBGb3Ig
dGhlIGNsaWVudCwgdGhpcyBpcyBhIG5ldyBPUEVODQo+ID4gcmVxdWVzdCB8DQo+ID4gICAgfCAg
ICAgICAgICAgICAgICAgICAgICB8IGFuZCB0aGVyZSBpcyBubyBwcmV2aW91cyBzdGF0ZQ0KPiA+
IGFzc29jaWF0ZWQgIHwNCj4gPiAgICB8ICAgICAgICAgICAgICAgICAgICAgIHwgd2l0aCB0aGUg
ZmlsZSBmb3IgdGhlDQo+ID4gY2xpZW50LiAgV2l0aCAgICAgICAgfA0KPiA+ICAgIHwgICAgICAg
ICAgICAgICAgICAgICAgfCBDTEFJTV9OVUxMLCB0aGUgZmlsZSBpcyBpZGVudGlmaWVkIGJ5DQo+
ID4gdGhlICB8DQo+ID4gICAgfCAgICAgICAgICAgICAgICAgICAgICB8IGN1cnJlbnQgZmlsZWhh
bmRsZSBhbmQgdGhlDQo+ID4gc3BlY2lmaWVkICAgICAgIHwNCj4gPiAgICB8ICAgICAgICAgICAg
ICAgICAgICAgIHwgY29tcG9uZW50IG5hbWUuICBXaXRoIENMQUlNX0ZIIChuZXcNCj4gPiB0byAg
ICAgfA0KPiA+ICAgIHwgICAgICAgICAgICAgICAgICAgICAgfCBORlN2NC4xKSwgdGhlIGZpbGUg
aXMgaWRlbnRpZmllZCBieQ0KPiA+IGp1c3QgICB8DQo+ID4gICAgfCAgICAgICAgICAgICAgICAg
ICAgICB8IHRoZSBjdXJyZW50IGZpbGVoYW5kbGUuICANCj4gPiANCj4gPiBTbyBpdCBzZWVtcyBs
aWtlIG1heWJlIHRoZSBzZXJ2ZXIgc2hvdWxkIGJlIHRvc3NpbmcgdGhlIG9sZCBzdGF0ZQ0KPiA+
IGFuZA0KPiA+IHJldHVybmluZyBhIG5ldyBzdGF0ZWlkPw0KPiA+IA0KPiANCj4gTm8uIEFzIGZh
ciBhcyB0aGUgcHJvdG9jb2wgaXMgY29uY2VybmVkLCB0aGUgb25seSBkaWZmZXJlbmNlIGJldHdl
ZW4NCj4gQ0xBSU1fTlVMTCBhbmQgQ0xBSU1fRkggaXMgdGhyb3VnaCBob3cgdGhlIGNsaWVudCBp
ZGVudGlmaWVzIHRoZSBmaWxlDQo+IChpbiB0aGUgZmlyc3QgY2FzZSwgdGhyb3VnaCBhbiBpbXBs
aWNpdCBsb29rdXAsIGFuZCBpbiB0aGUgc2Vjb25kDQo+IGNhc2UNCj4gdGhyb3VnaCBhIGZpbGUg
aGFuZGxlKS4gVGhlIGNsaWVudCBzaG91bGQgYmUgZnJlZSB0byBpbnRlcm1peCB0aGUgdHdvDQo+
IHR5cGVzIG9mIE9QRU4sIGFuZCBpdCBzaG91bGQgZXhwZWN0IHRoZSByZXN1bHRpbmcgc3RhdGVp
ZHMgdG8gZGVwZW5kDQo+IG9ubHkgb24gd2hldGhlciBvciBub3QgdGhlIG9wZW5fb3duZXIgbWF0
Y2hlcy4gSWYgdGhlIG9wZW5fb3duZXINCj4gbWF0Y2hlcyBhbiBleGlzdGluZyBzdGF0ZWlkLCB0
aGVuIHRoYXQgc3RhdGVpZCBpcyBidW1wZWQgYW5kDQo+IHJldHVybmVkLg0KPiANCj4gSSdtIG5v
dCBhd2FyZSBvZiBhbnkgZXhwZWN0YXRpb24gaW4gdGhlIGNsaWVudCB0aGF0IHRoaXMgc2hvdWxk
IG5vdA0KPiBiZQ0KPiB0aGUgY2FzZSwgc28gaWYgeW91IGFyZSBzZWVpbmcgZGlmZmVyZW50IGJl
aGF2aW91ciwgdGhlbiBzb21ldGhpbmcNCj4gZWxzZQ0KPiBtdXN0IGJlIGF0IHdvcmsgaGVyZS4g
SXMgdGhlIGNsaWVudCBwZXJoYXBzIG1vdW50aW5nIHRoZSBzYW1lDQo+IGZpbGVzeXN0ZW0gaW4g
dHdvIGRpZmZlcmVudCBwbGFjZXMgaW4gc3VjaCBhIHdheSB0aGF0IHRoZSBzdXBlciBibG9jaw0K
PiBpcyBub3QgYmVpbmcgc2hhcmVkPw0KDQpPaCwgb25lIHRoaW5nIHRvIG5vdGUgdGhhdCBpcyBi
b3RoIGEgcHJvdG9jb2wgYW5kIGEgY2xpZW50IGV4cGVjdGF0aW9uOg0KaWYgdGhlIHNlcnZlciBy
ZXR1cm5zIG11bHRpcGxlIGRpZmZlcmVudCBmaWxlaGFuZGxlcyBmb3IgdGhlIHNhbWUgZmlsZQ0K
KGkuZS4gc2FtZSBmc2lkOmZpbGVpZCBjb21iaW5hdGlvbiksIHRoZW4gdGhlIHN0YXRlaWQgaXMg
YXR0YWNoZWQgdG8NCnRoZSBfZmlsZWhhbmRsZV8gYW5kIG5vdCB0aGUgZnNpZDtmaWxlaWQgY29t
YmluYXRpb24uIFNvIGlmIHRoZSBzZXJ2ZXINCmlzIGNvZGVkIHRvIHJldHVybiBhIGRpZmZlcmVu
dCBmaWxlaGFuZGxlIGluIHRoZSBDTEFJTV9OVUxMIGNhc2UgdGhhbg0KdGhlIG9uZSB1c2VkIGZv
ciBDTEFJTV9GSCwgdGhlbiB0aGF0IHdvdWxkIGV4cGxhaW4gdGhlIGV4cGVjdGF0aW9uDQphYm92
ZS4NCg0KVGhpcyBzaG91bGQgbmV2ZXIgYmUgdGhlIGNhc2UgZm9yIGtuZnNkLg0KDQotLSANClRy
b25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0K
dHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
