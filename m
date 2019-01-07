Return-Path: <SRS0=jPLZ=PP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16E49C43387
	for <linux-nfs@archiver.kernel.org>; Mon,  7 Jan 2019 22:06:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B54552070B
	for <linux-nfs@archiver.kernel.org>; Mon,  7 Jan 2019 22:06:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="UPT4I7Xt"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727119AbfAGWGY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 7 Jan 2019 17:06:24 -0500
Received: from mail-eopbgr710120.outbound.protection.outlook.com ([40.107.71.120]:56331
        "EHLO NAM05-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726821AbfAGWGX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 7 Jan 2019 17:06:23 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=5VJZLFnKxN2xL2pPcJAXKnyzjjmoSvJckm6CTHo6oI0=;
 b=UPT4I7XtLvVzKY2PDoyTadwupDf/p8GYE4GaWJ0GT9Th4WNvI6v5PI840Q9aI4rE64wnHBf9npY8So2wm7q9zX6Br5ks7zmeIswpbukcZX6rZ9zH0cq+vgEVdvj9b2b68MRQVfSkoO1RooyGUDbAqDfn6yyF26efQLlMRiDt2lM=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2333.namprd13.prod.outlook.com (52.135.94.28) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1516.4; Mon, 7 Jan 2019 22:06:20 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%4]) with mapi id 15.20.1516.010; Mon, 7 Jan 2019
 22:06:20 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Don't allow compiler optimisation of
 svc_xprt_release_slot()
Thread-Topic: [PATCH] SUNRPC: Don't allow compiler optimisation of
 svc_xprt_release_slot()
Thread-Index: AQHUo28wQYHfdyrJOkiXFnTxUjWqjaWeJS6AgAAPUoCAAS1wAIAE+B8AgAAJf4A=
Date:   Mon, 7 Jan 2019 22:06:19 +0000
Message-ID: <e14e17167ef98c456e7648ad0536827b7870f0ff.camel@hammerspace.com>
References: <20190103141712.24381-1-trond.myklebust@hammerspace.com>
         <20190103224529.GA6907@fieldses.org>
         <a0493a5f022a666779d19fde5cdfbfdf9c7316c4.camel@hammerspace.com>
         <20190104173912.GC11787@fieldses.org> <20190107213218.GD7753@fieldses.org>
In-Reply-To: <20190107213218.GD7753@fieldses.org>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2333;6:kAOZ/s91fdnWsF3VdSYDOqUhNMZ/9a+9sovCkjDewybNaUPWa0t6X4YglffhkD0IQNai+zXLkS1FOTj0C1G3pX/utOtor7XAgo8MezI5LE2LtIZZ90EgSAaHfGOadOGMgX9Sqc6cjhicCjEHtdFOYDRpRbT1iIqZqzSYk5u0FW7LutyXaEnjmjzCDXiky3eLHoI3VdwwPv2UZGNq8khL0VcpxarVan7vGDfOkQOMtbh7vqvHQaTwz1e0dGxsd3V5BD4ud5C3R7Pwed4yaPbaGggn1wg0Eo+EWHG9ragYhIb2kmUxEWCCMbGypu2KVWHQiZ88qRITx5bTI81p0KuSOFtFgDgG7aD2KQPhFidKj4XRMTnQonTykdCBdhVD+uMcJmteh+4Hem1XKDXyKPn54mcX5526WcXDstE42nIz/dy3JmEu04rxw7XvkJi8XVymMvSCkuqP6xd5siTqgkDU/w==;5:7/pIYeeBsvXgBNqcgsNWxF1p6HFgM3MxSsRS2MR9OGZ2wfRcD6XpcECZcYfqnzD6SbwlKb4b3G7Z+A3TzclHJEWZKBhrKDaZVr+y0vjVqsHll4e3unpPkbfc+h0ANyMGfTA+7UaFh/G/ik12WbxEN5SxqrLBwu2w9CMwQB0hhIVrEvfWZtyhU33dJ5cFEiAQFR6190MSoWxcepZ8Tc3DlQ==;7:9I9PAuO49I708jMjMIlnrc21TZEiyjzqxDjqQ/LqB7F0Gpw35qWNgBhe97F/ticqcFVx4kvH66q8iKGzdRMOi5UnBWu30IMy8cvb1dGxveIBk+wAMLvQzSIBs8BX04Vafpro1eoGWqLMk5B0fPNFSw==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 6db78351-4f46-4507-51e4-08d674ec5ab3
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600109)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2333;
x-ms-traffictypediagnostic: SN6PR13MB2333:
x-microsoft-antispam-prvs: <SN6PR13MB2333876EFA879399F5845A71B8890@SN6PR13MB2333.namprd13.prod.outlook.com>
x-forefront-prvs: 0910AAF391
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(376002)(39840400004)(396003)(346002)(136003)(54094003)(189003)(199004)(106356001)(8936002)(118296001)(6116002)(3846002)(66066001)(81166006)(486006)(14444005)(14454004)(446003)(71190400001)(81156014)(11346002)(105586002)(71200400001)(1730700003)(478600001)(6346003)(86362001)(26005)(256004)(8676002)(6506007)(102836004)(5660300001)(76176011)(2351001)(97736004)(186003)(2501003)(6916009)(6246003)(6512007)(36756003)(99286004)(316002)(2906002)(53936002)(5640700003)(25786009)(2616005)(7736002)(476003)(305945005)(68736007)(93886005)(6486002)(229853002)(4326008)(6436002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2333;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: GlC8hC17c34v5GRMadCxvpyLUed6vMysiL5C5SUzW8RNt6zdWC7ti7752JB3tKO2jAXKy22PmW6BnYOU1Sf8AOF5bvbaFFxtS/jJyvUzVaEpbUnX3FORKlKw3uPk1I7NNiW7dfJJ8jTaijE7XE1guVd6elzOH7NCi/12wtlBGe7LeZdcbrjcyPIBh9Q1g0Y16pVcGe+3v7+J1V13c8JVL6S5a3bDxAY37A8vgVPVl/ey6UYhjs3I6Cfsd6evZJWedYegSz/P5l4tP6nvi7fG+CG/Qh4vNqNqJ9CMOBhNIo5T65AsnnHOJ2VP/Yxzhy5O
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <A9C8C49DDB1D9F4181EDAF64180E3C5D@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 6db78351-4f46-4507-51e4-08d674ec5ab3
X-MS-Exchange-CrossTenant-originalarrivaltime: 07 Jan 2019 22:06:20.1348
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2333
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE5LTAxLTA3IGF0IDE2OjMyIC0wNTAwLCBiZmllbGRzQGZpZWxkc2VzLm9yZyB3
cm90ZToNCj4gT24gRnJpLCBKYW4gMDQsIDIwMTkgYXQgMTI6Mzk6MTJQTSAtMDUwMCwgYmZpZWxk
c0BmaWVsZHNlcy5vcmcgd3JvdGU6DQo+ID4gSSB3b25kZXIgaWYgdGhlcmUncyBhIHJhY2UgaGVy
ZSBpbmRlcGVuZGVudCBvZiB0aGF0IGNoYW5nZToNCj4gPiANCj4gPiBzdmNfeHBydF9lbnF1ZXVl
KCkgY2FsbGVycyBhbGwgZG8gc29tZXRoaW5nIGxpa2U6DQo+ID4gDQo+ID4gCTEuIGNoYW5nZSBz
b21lIGNvbmRpdGlvbg0KPiA+IAkyLiBjYWxsIHN2Y194cHJ0X2VucXVldWUoKSB0byBjaGVjayB3
aGV0aGVyIHRoZSB4cHJ0IHNob3VsZCANCj4gPiAJICAgbm93IGJlIGVucXVldWVkLg0KPiA+IA0K
PiA+IHdoZXJlIHRoZSBjb25kaXRpb25zIGFyZSBzZXR0aW5ncyBvZiB0aGUgeHB0X2ZsYWdzLCBv
ciBzb2NrZXQNCj4gPiB3c3BhY2UsIG9yDQo+ID4geHB0X25yX3Jxc3RzLg0KPiA+IA0KPiA+IElu
IHRoZW9yeSBpZiB3ZSBtaXNzIHNvbWUgY29uY3VycmVudCBjaGFuZ2Ugd2UncmUgT0sgYmVjYXVz
ZQ0KPiA+IHdob2V2ZXIncw0KPiA+IG1ha2luZyB0aGF0IGNoYW5nZSB3aWxsIHRoZW4gYWxzbyBj
YWxsIHN2Y194cHJ0X2VucXVldWUuICBCdXQNCj4gPiB0aGF0J3Mgbm90DQo+ID4gZW5vdWdoOyBl
LmcuOg0KPiA+IA0KPiA+IAl0YXNrIDEJCQkJdGFzayAyDQo+ID4gCS0tLS0tLQkJCQktLS0tLS0N
Cj4gPiAJc2V0IFhQVF9EQVRBDQo+ID4gCQkJCQlhdG9taWNfZGVjKHhwdF9ucl9ycXN0cykNCj4g
PiANCj4gPiAJY2hlY2sgWFBUX0RBVEEgJiYgY2hlY2sgeHB0X25yX3Jxc3RzDQo+ID4gDQo+ID4g
CQkJCQljaGVjayBYUFRfREFUQSAmJiBjaGVjaw0KPiA+IHhwdF9ucl9ycXN0cw0KPiA+IA0KPiA+
IElmIHRoZSB0YXNrcyBvbmx5IHNlZSB0aGVpciBsb2NhbCBjaGFuZ2VzLCB0aGVuIG5laXRoZXIg
c2VlIGJvdGgNCj4gPiBjb25kaXRpb25zIHRydWUsIHNvIHRoZSBzb2NrZXQgZG9lc24ndCBnZXQg
ZW5xdWV1ZWQuICAoQW5kIGENCj4gPiByZXF1ZXN0DQo+ID4gdGhhdCB3YXMgcmVhZHkgdG8gYmUg
cHJvY2Vzc2VkIHdpbGwgc2l0IGFyb3VuZCB1bnRpbCBzb21lb25lIGVsc2UNCj4gPiBjb21lcw0K
PiA+IGNhbGxzIHN2Y194cHJ0X2VucXVldWUoKSBvbiB0aGF0IHhwcnQuKQ0KPiANCj4gU28gbWF5
YmUgd2UgYWN0dWFsbHkgbmVlZA0KPiANCj4gIHN0YXRpYyBib29sIHN2Y194cHJ0X2hhc19zb21l
dGhpbmdfdG9fZG8oc3RydWN0IHN2Y194cHJ0ICp4cHJ0KQ0KPiAgew0KPiArCW1iKCk7DQoNCllv
dSB3b3VsZCBhdCBiZXN0IG5lZWQgYSAnc21wX3JtYigpJy4gVGhlcmUgaXMgbm90aGluZyB0byBn
YWluIGZyb20NCmFkZGluZyBhIHdyaXRlIGJhcnJpZXIgaGVyZSwgYW5kIHlvdSBkb24ndCBldmVu
IG5lZWQgYSByZWFkIGJhcnJpZXIgaW4NCnRoZSBub24tc21wIGNhc2UuDQoNCj4gIAlpZiAoeHBy
dC0+eHB0X2ZsYWdzICYgKCgxPDxYUFRfQ09OTil8KDE8PFhQVF9DTE9TRSkpKQ0KPiAgCQlyZXR1
cm4gdHJ1ZTsNCj4gIAlpZiAoeHBydC0+eHB0X2ZsYWdzICYgKCgxPDxYUFRfREFUQSl8KDE8PFhQ
VF9ERUZFUlJFRCkpKSB7DQo+IA0KPiBUaGVuIHdoaWNoZXZlciBtZW1vcnkgYmFycmllciBleGVj
dXRlcyBzZWNvbmQgZ3VhcmFudGVlcyB0aGF0IHRoZQ0KPiBmb2xsb3dpbmcgY2hlY2sgc2VlcyB0
aGUgcmVzdWx0IG9mIGJvdGggdGhlIFhQVF9EQVRBIGFuZCB4cHRfbnJfcnFzdHMNCj4gY2hhbmdl
cy4gIEkgdGhpbmsuLi4uDQoNCg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNs
aWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNl
LmNvbQ0KDQoNCg==
