Return-Path: <SRS0=ZJCY=PT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3DA9C43387
	for <linux-nfs@archiver.kernel.org>; Fri, 11 Jan 2019 19:04:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C3B292183F
	for <linux-nfs@archiver.kernel.org>; Fri, 11 Jan 2019 19:04:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=netapp.onmicrosoft.com header.i=@netapp.onmicrosoft.com header.b="XLJzXyLV"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389132AbfAKTEb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 11 Jan 2019 14:04:31 -0500
Received: from mail-eopbgr770081.outbound.protection.outlook.com ([40.107.77.81]:15648
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1732354AbfAKTEa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 11 Jan 2019 14:04:30 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=netapp.onmicrosoft.com; s=selector1-netapp-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=pcVZmtFLahuEldA22OeudKRUgMhkEqEKBLU6mMU4YsY=;
 b=XLJzXyLVUVlAVAb6a+UBYNYrpYKr5FhDMKbpTpvgSfphqsJG6kEHjbjFZp1x8oB9loMY2JB5ryUaR/95P0NHh8UX0cRJ8PdAaWd0wpwbdp9mfru4clBNwCijask53jOT4bWzixTFqchBotWfLRV9q0nqZPYAnQJK37xbXKU4PHA=
Received: from DM5PR06MB3161.namprd06.prod.outlook.com (10.174.240.148) by
 DM5PR06MB2474.namprd06.prod.outlook.com (10.168.178.144) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1516.18; Fri, 11 Jan 2019 19:04:27 +0000
Received: from DM5PR06MB3161.namprd06.prod.outlook.com
 ([fe80::e942:888d:b5bb:44fb]) by DM5PR06MB3161.namprd06.prod.outlook.com
 ([fe80::e942:888d:b5bb:44fb%5]) with mapi id 15.20.1495.011; Fri, 11 Jan 2019
 19:04:27 +0000
From:   "Schumaker, Anna" <Anna.Schumaker@netapp.com>
To:     "olga.kornievskaia@gmail.com" <olga.kornievskaia@gmail.com>,
        "trond.myklebust@hammerspace.com" <trond.myklebust@hammerspace.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFSv4.2 fix unnecessary retry in nfs4_copy_file_range
Thread-Topic: [PATCH 1/1] NFSv4.2 fix unnecessary retry in
 nfs4_copy_file_range
Thread-Index: AQHUp3tfOoOjW+kZtkisdfrtAO6LKaWqcfoA
Date:   Fri, 11 Jan 2019 19:04:27 +0000
Message-ID: <769dd5d01d37b7e4a9f81fa160fdab109a912c88.camel@netapp.com>
References: <20190108175532.2348-1-olga.kornievskaia@gmail.com>
In-Reply-To: <20190108175532.2348-1-olga.kornievskaia@gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Evolution 3.30.4 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Anna.Schumaker@netapp.com; 
x-originating-ip: [23.28.75.121]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;DM5PR06MB2474;6:X66OYJqs810HL8GtaRs4f9x9Sy5ou3ms+9drbKVh00erveT6KdHDi6Zy1r4RtPKxfEE5WHxaEz2emzoVZOgVvP6UQvUVeRFDHzMlxtlb9kFHWEZSeqkFyjUcqK6Qw36DojBKmd10vB7mwWdYtktbs+dPOrzlzRQ0fzEXJzAxTuxFFSkMk+bLBMVGAKi5n4pCaGQjQ++2Wyv4B8AdMmuhKIhqVJ+sgkJ7vniGEVIYiAfyAI59BiX5IPwvKmp8kssaytwSSo8CyoX8avqoBlgPTBrR0LHdNQxsk9A7Cx7oSLl3u5wnt1OSPau7Cva6rwSfF3afYHJsMCGy/OUYGn5gMz1NfMSn2vLSqgk/LcnfIimjlekSQgIazefS7U7l52slyDaQuk6ioD6BlmpRnIxDFVbGiXRXlFwKA9KsFt0SU257ciQxS0EsMgjxf3oF/vPfdHn/to+ivQ5yrkoUxgjvBQ==;5:/jJX0xWxiUmnHl99qvCpWFuolHEPouZ5U/MDHtWdCHqMz9hGgI5wywFg4zz8XZnrgl2IMGaxal5cnzUwL0xQ84dmDxJy3gW0/p4TVVgPblGR6ZMSKnffH9N8cRW5F6kmA4HaGzr5rq4uTOD+E7Q35QyyVajBo1lWpfqtba9vfTyEISQ4kfwXuoC6nmfYkjsgvr1+RUZTG4gO3ZMy2OKPMA==;7:Ak18qIAEY0qlacUqQOuPrCzs3mD0028paxudwkmTniLfpV0SG4S4MuAb/qDVTUPodylfopvOE1Nr2IjDN951nwdXEkLHdEirDKmOEd3+oezdCq8fcV8jIH6mubC7EIh7x32cVJPj9RX1dnuE0NDn6w==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: a1e47c4e-fee8-4f01-7dc5-08d677f79c10
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(2017052603328)(7193020);SRVR:DM5PR06MB2474;
x-ms-traffictypediagnostic: DM5PR06MB2474:
x-microsoft-antispam-prvs: <DM5PR06MB247490EF9AB24176C92F428CF8850@DM5PR06MB2474.namprd06.prod.outlook.com>
x-forefront-prvs: 09144DB0F7
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(396003)(366004)(39860400002)(376002)(346002)(136003)(189003)(199004)(25786009)(14454004)(7736002)(305945005)(186003)(66066001)(2501003)(229853002)(68736007)(102836004)(6486002)(5660300001)(6436002)(53936002)(8676002)(81156014)(6506007)(4326008)(39060400002)(81166006)(86362001)(26005)(6246003)(6512007)(76176011)(8936002)(71200400001)(71190400001)(316002)(486006)(3846002)(6116002)(2906002)(99286004)(36756003)(118296001)(97736004)(105586002)(58126008)(110136005)(106356001)(256004)(11346002)(478600001)(446003)(2616005)(72206003)(476003);DIR:OUT;SFP:1101;SCL:1;SRVR:DM5PR06MB2474;H:DM5PR06MB3161.namprd06.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: netapp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: TrcxjqjHIb+mMkHnpotzxXx1SD5xRf/3Ke8jZ29aASqxyoFJCsanLE/p61LATOk/3b4E5O1qymQsKGujtHtb8u1qTDF0fNsA8BleXOtG9VKUfqNQiwsXoT4pagQoYLiFPaPsTdMKm/Oc41pM02HXF+uR2AS69coDorPTWVFxP1ugHepqUcp08WFFd1WQaOsNFKVYfJpjyT3mC9lx2lnmQ9QaOT7Py6it+C/8SthPD1H6W+Fdjrbn3+2COQGj9vINhRvTw6DeLHpTGPvwev/OkkYHTi0I/ZcPb0eg7N+GInZNcARb065BtMVRmo2waJeF99eFd2btNLB+RFCr34xEFAOd9brRIgB6rjdi57YoEjb6+0fMVRu/93/zd2NYc2Iu39xw03x4PyrEYPJlwsfY+lQ56nEahHAJWaByJhtRctQ=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <4F2888893494EB41A0F294C82129F8CC@namprd06.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a1e47c4e-fee8-4f01-7dc5-08d677f79c10
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Jan 2019 19:04:27.7327
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM5PR06MB2474
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgT2xnYSwNCg0KT24gVHVlLCAyMDE5LTAxLTA4IGF0IDEyOjU1IC0wNTAwLCBPbGdhIEtvcm5p
ZXZza2FpYSB3cm90ZToNCj4gQ3VycmVudGx5IG5mczQyX3Byb2NfY29weV9maWxlX3JhbmdlKCkg
Y2FuIG5vdCByZXR1cm4gRUFHQUlOLg0KPiANCj4gRml4ZXM6IGU0NjQ4YWE0Zjk4YSAoIk5GUyBy
ZWNvdmVyIGZyb20gZGVzdGluYXRpb24gc2VydmVyIHJlYm9vdCBmb3IgY29waWVzIikNCj4gU2ln
bmVkLW9mZi1ieTogT2xnYSBLb3JuaWV2c2thaWEgPGtvbGdhQG5ldGFwcC5jb20+DQo+IC0tLQ0K
PiAgZnMvbmZzL25mczRmaWxlLmMgfCA2ICstLS0tLQ0KPiAgMSBmaWxlIGNoYW5nZWQsIDEgaW5z
ZXJ0aW9uKCspLCA1IGRlbGV0aW9ucygtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL2ZzL25mcy9uZnM0
ZmlsZS5jIGIvZnMvbmZzL25mczRmaWxlLmMNCj4gaW5kZXggNDZkNjkxYi4uODE1NTRhZiAxMDA2
NDQNCj4gLS0tIGEvZnMvbmZzL25mczRmaWxlLmMNCj4gKysrIGIvZnMvbmZzL25mczRmaWxlLmMN
Cj4gQEAgLTEzNywxMSArMTM3LDcgQEAgc3RhdGljIHNzaXplX3QgbmZzNF9jb3B5X2ZpbGVfcmFu
Z2Uoc3RydWN0IGZpbGUgKmZpbGVfaW4sDQo+IGxvZmZfdCBwb3NfaW4sDQo+ICANCj4gIAlpZiAo
ZmlsZV9pbm9kZShmaWxlX2luKSA9PSBmaWxlX2lub2RlKGZpbGVfb3V0KSkNCj4gIAkJcmV0dXJu
IC1FSU5WQUw7DQo+IC1yZXRyeToNCj4gLQlyZXQgPSBuZnM0Ml9wcm9jX2NvcHkoZmlsZV9pbiwg
cG9zX2luLCBmaWxlX291dCwgcG9zX291dCwgY291bnQpOw0KPiAtCWlmIChyZXQgPT0gLUVBR0FJ
TikNCj4gLQkJZ290byByZXRyeTsNCj4gLQlyZXR1cm4gcmV0Ow0KPiArCXJldHVybiBuZnM0Ml9w
cm9jX2NvcHkoZmlsZV9pbiwgcG9zX2luLCBmaWxlX291dCwgcG9zX291dCwgY291bnQpOw0KDQpJ
IHRoaW5rIHRoaXMgaXMgdGhlIG9ubHkgdXNlciBvZiB0aGUgdmFyaWFibGUgInJldCIsIHNvIGNh
biB5b3UgcmVtb3ZlIGl0cw0KZGVjbGFyYXRpb24gYXQgdGhlIHRvcCBvZiB0aGlzIGZ1bmN0aW9u
IHRvbz8NCg0KICBDQyBbTV0gIGZzL25mcy9uZnM0ZmlsZS5vDQpmcy9uZnMvbmZzNGZpbGUuYzog
SW4gZnVuY3Rpb24g4oCYbmZzNF9jb3B5X2ZpbGVfcmFuZ2XigJk6DQpmcy9uZnMvbmZzNGZpbGUu
YzoxMzY6MTA6IGVycm9yOiB1bnVzZWQgdmFyaWFibGUg4oCYcmV04oCZIFstV2Vycm9yPXVudXNl
ZC12YXJpYWJsZV0NCiAgc3NpemVfdCByZXQ7DQogICAgICAgICAgXn5+DQpjYzE6IGFsbCB3YXJu
aW5ncyBiZWluZyB0cmVhdGVkIGFzIGVycm9ycw0KDQpUaGFua3MsDQpBbm5hDQoNCj4gIH0NCj4g
IA0KPiAgc3RhdGljIGxvZmZfdCBuZnM0X2ZpbGVfbGxzZWVrKHN0cnVjdCBmaWxlICpmaWxlcCwg
bG9mZl90IG9mZnNldCwgaW50IHdoZW5jZSkNCg==
