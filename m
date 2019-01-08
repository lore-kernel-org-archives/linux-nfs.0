Return-Path: <SRS0=4uXo=PQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95A42C43387
	for <linux-nfs@archiver.kernel.org>; Tue,  8 Jan 2019 16:22:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3B9A82087F
	for <linux-nfs@archiver.kernel.org>; Tue,  8 Jan 2019 16:22:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="QievRCWj"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729416AbfAHQWY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 8 Jan 2019 11:22:24 -0500
Received: from mail-eopbgr820110.outbound.protection.outlook.com ([40.107.82.110]:7807
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728483AbfAHQWX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 8 Jan 2019 11:22:23 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=r0p91gVxFpEv6PySC8LNHHTJvhj5DGpZ7IwAR9oicJE=;
 b=QievRCWjUU2eQ+g7ae0S7+n3wNNd+0Rd5Ezo+wId8LfpL2LJshmge7mjfSqSsE7worammrQXt47k9uWZS5sxM8dfpzqmCIep/+KULiz6K33Ibe/UMYAQQX/LmI7Z1nVHecW07gKps/bEunY00LAW8Ud4HjA3bHjnVMgbPxJgaLo=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2477.namprd13.prod.outlook.com (52.135.95.33) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1516.13; Tue, 8 Jan 2019 16:21:40 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%4]) with mapi id 15.20.1516.010; Tue, 8 Jan 2019
 16:21:40 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Don't allow compiler optimisation of
 svc_xprt_release_slot()
Thread-Topic: [PATCH] SUNRPC: Don't allow compiler optimisation of
 svc_xprt_release_slot()
Thread-Index: AQHUo28wQYHfdyrJOkiXFnTxUjWqjaWeJS6AgAAPUoCAAS1wAIAE+B8AgAAJf4CAARuKgIAAFneA
Date:   Tue, 8 Jan 2019 16:21:40 +0000
Message-ID: <4077991d3d3acee4c37c7c8c6dc2b76930c9584e.camel@hammerspace.com>
References: <20190103141712.24381-1-trond.myklebust@hammerspace.com>
         <20190103224529.GA6907@fieldses.org>
         <a0493a5f022a666779d19fde5cdfbfdf9c7316c4.camel@hammerspace.com>
         <20190104173912.GC11787@fieldses.org> <20190107213218.GD7753@fieldses.org>
         <e14e17167ef98c456e7648ad0536827b7870f0ff.camel@hammerspace.com>
         <20190108150107.GA15921@fieldses.org>
In-Reply-To: <20190108150107.GA15921@fieldses.org>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2477;6:L7in+l4M/zT7td7DB6Kqyy+1WKz4K7XSBGX9s/khtXAs3mrNd8QZX0HoURJTBq4b8xElSGDC46b0G7SKUbYYLz34dsH5MqVuyZw2gP8r24itPTWqFKgQCtf3rgCFgPNl+dO8XN2SSXPczdXTQKFzwfJdwXVdaxqSBC2+Vf9kNp21o3hkpPf5MDJrVG30UKXcSECVzr/TQrdWOHWrgN1wQOCKkRuJVUCkGdHPlxfhH+SxGrx3OOdv0gXYQGLeH9C/fajCx7mkoofHJKeHQ//hzO01ObTrCjCdAmaRJgFgCj+gyMuLBpZma+o3h5A3/JBFzd+IFy/p5Y8gHObFQXOKCncTg4mv8WnIYCXcspJa4sqrD/XVtl4ZFg9YoCmC9oEzubHXE1fLua35zspm+yo6S0/zYzvVZcScHXE9z4mRoRdCCnf6J1I1NMQqFtbQuFBtDKNj+9DqLBCzE8O8ufjCUQ==;5:Q9EOB5vXUZvjzN61C3cybi8TVh2dOVkjFalmJ6nljMy9lIMcr/4aXP/21mUoiqL2I5ZlPIkd5eUI7CmGwJrhyjWdKfTj+Z8LqlWa389x3gidk2Q5V5cFxoqRXsypvvr5y42yWsgEK5gD6bwhQzYRaMIFxTDv/QjAEzYGVcdx4yCZQJgVTv1U9biQ8wY0HmG2RKqFfW5euyMFMW3DvOpo9w==;7:F9IUEFqI62srPvwRpTx3ZJKJ82cd+myQNJ1j5AATc8xwQfFdtKCl1Rsg++Ab3S2o+innvOEHy+CqC6iriV18uaLc7xL0yF4VCm1l0QNcm/LtvOcGt1tod5Q9si6juaCWCYiYjbcbqPtHfMLMLqed8Q==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 7bf98b83-cf87-46bf-30c6-08d675855eff
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600109)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2477;
x-ms-traffictypediagnostic: SN6PR13MB2477:
x-microsoft-antispam-prvs: <SN6PR13MB247769776D731631159B2AA8B88A0@SN6PR13MB2477.namprd13.prod.outlook.com>
x-forefront-prvs: 0911D5CE78
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(396003)(366004)(376002)(136003)(39840400004)(199004)(189003)(66066001)(26005)(186003)(8936002)(6116002)(102836004)(6346003)(3846002)(6512007)(99286004)(6506007)(68736007)(2501003)(8676002)(7736002)(305945005)(2351001)(105586002)(106356001)(118296001)(14454004)(1730700003)(81166006)(81156014)(486006)(11346002)(2616005)(476003)(446003)(478600001)(6486002)(36756003)(229853002)(6436002)(5640700003)(25786009)(6916009)(6246003)(5660300001)(53936002)(97736004)(86362001)(4326008)(14444005)(256004)(71200400001)(76176011)(71190400001)(93886005)(2906002)(316002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2477;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: DnC4h8Hbb8FVAGyGMJDEkD4Uu/oNk4ABxpoU1CwJDLBotXOYbIa9viN2ZaQQHJ0Ds8qMZpPLAr6SfJ4Gcn11MDVcD+nFYut+vv4zH3x9BekeVzvG2RjVfpRg7XcYl3O33gZyCFvupDq06lU/gOivpAiB1WpHHWfUR1ysZBfx5ZRxh791FnrzqroFux1oTG396My8CG2ObCZInemfY1k99+NqSiBjvuCcLQyl4xuF5SiwhO6bH2iOD3qiXGnJiBKx19PqMaEImV8fvKt8QqAOCkoE7PktBygL7KSiDIgsF3RJk2mj3EPEu76GxCTR9t51
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <09D7142FF68A4C4EAEC2EC286C860D26@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7bf98b83-cf87-46bf-30c6-08d675855eff
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 Jan 2019 16:21:40.3135
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2477
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE5LTAxLTA4IGF0IDEwOjAxIC0wNTAwLCBiZmllbGRzQGZpZWxkc2VzLm9yZyB3
cm90ZToNCj4gT24gTW9uLCBKYW4gMDcsIDIwMTkgYXQgMTA6MDY6MTlQTSArMDAwMCwgVHJvbmQg
TXlrbGVidXN0IHdyb3RlOg0KPiA+IE9uIE1vbiwgMjAxOS0wMS0wNyBhdCAxNjozMiAtMDUwMCwg
YmZpZWxkc0BmaWVsZHNlcy5vcmcgd3JvdGU6DQo+ID4gPiBTbyBtYXliZSB3ZSBhY3R1YWxseSBu
ZWVkDQo+ID4gPiANCj4gPiA+ICBzdGF0aWMgYm9vbCAoc3RydWN0IHN2Y194cHJ0ICp4cHJ0KQ0K
PiA+ID4gIHsNCj4gPiA+ICsJbWIoKTsNCj4gPiANCj4gPiBZb3Ugd291bGQgYXQgYmVzdCBuZWVk
IGEgJ3NtcF9ybWIoKScuIFRoZXJlIGlzIG5vdGhpbmcgdG8gZ2FpbiBmcm9tDQo+ID4gYWRkaW5n
IGEgd3JpdGUgYmFycmllciBoZXJlLA0KPiANCj4gVGhhdCdzIG5vdCBteSB1bmRlcnN0YW5kaW5n
Lg0KPiANCj4gV2hhdCB3ZSBoYXZlIGlzIGJhc2ljYWxseToNCj4gDQo+IAkxCQkJMg0KPiAJLS0t
LQkJCS0tLS0NCj4gCVdSSVRFIHRvIEEJCVdSSVRFIHRvIEINCj4gDQo+IAlSRUFEIGZyb20gQSBh
bmQgQglSRUFEIGZyb20gQSBhbmQgQg0KPiANCj4gYW5kIHdlIHdhbnQgdG8gZ3VhcmFudGVlIHRo
YXQgYXQgbGVhc3Qgb25lIG9mIHRob3NlIHR3byByZWFkcyB3aWxsDQo+IHNlZQ0KPiBib3RoIG9m
IHRoZSB3cml0ZXMuDQo+IA0KPiBBIHJlYWQgYmFycmllciBvbmx5IG9yZGVycyByZWFkcyB3aXRo
IHJlc3BlY3QgdG8gdGhlIGJhcnJpZXIsIGl0DQo+IGRvZXNuJ3QNCj4gZG8gYW55dGhpbmcgYWJv
dXQgd3JpdGVzLCBzbyBkb2Vzbid0IGd1YXJhbnRlZSBhbnl0aGluZyBoZXJlLg0KDQpJbiB0aGlz
IGNvbnRleHQgJ1dSSVRFIHRvIEEnIGFuZC9vciAnV1JJVEUgdG8gQicgYXJlIHByZXN1bWFibHkg
dGhlDQpvcGVyYXRpb25zIG9mIHNldHRpbmcgdGhlIGZsYWcgYml0cyBpbiB4cHJ0LT54cHRfZmxh
Z3MsIG5vPyBUaGF0J3Mgbm90DQpvY2N1cnJpbmcgaGVyZSwgaXQgaXMgb2NjdXJyaW5nIGVsc2V3
aGVyZS4NCg0KVGhlIHRlc3RfYW5kX3NldF9iaXQoWFBUX0RBVEEsICZ4cHJ0LT54cHRfZmxhZ3Mp
IGluIHN2Y19kYXRhX3JlYWR5KCkNCnBlcmZvcm1zIGFuIGV4cGxpY2l0IGJhcnJpZXIsIHNvIHdl
IHNob3VsZG4ndCByZWFsbHkgY2FyZS4gVGhlIG90aGVyDQpjYXNlcyB3aGVyZSB3ZSBkbyBzZXRf
Yml0KFhQVF9EQVRBKSBkb24ndCBtYXR0ZXIgc2luY2UgdGhlIHNvY2tldCBoYXMNCml0cyBvd24g
bG9ja2luZywgYW5kIHNvIHRoZSBYUFRfREFUQSBpcyByZWFsbHkganVzdCBhIHRlc3QgZm9yIHdo
ZXRoZXINCm9yIG5vdCB3ZSBuZWVkIHRvIGVucXVldWUgdGhlIHN2Y194cHJ0Lg0KDQpJbiB0aGUg
b25seSBwbGFjZSB3aGVyZSBYUFRfREVGRVJSRUQgaXMgc2V0LCB5b3UgaGF2ZSBhbiBpbXBsaWNp
dCB3cml0ZQ0KYmFycmllciAoZHVlIHRvIGEgc3Bpbl91bmxvY2spIGJldHdlZW4gdGhlIGNhbGwg
dG8gc2V0X2JpdCgpIGFuZCB0aGUNCmNhbGwgdG8gc3ZjX3hwcnRfZW5xdWV1ZSgpLCBzbyBhbGwg
ZGF0YSB3cml0ZXMgYXJlIGd1YXJhbnRlZWQgdG8gYmUNCmNvbXBsZXRlIGJlZm9yZSBhbnkgYXR0
ZW1wdCB0byBlbnF1ZXVlIHRoZSBzb2NrZXQuDQoNCkkgY2FuJ3Qgc2VlIHRoYXQgeW91IHJlYWxs
eSBjYXJlIGZvciB0aGUgY2FzZSBvZiBYUFRfQ09OTiwgc2luY2UgdGhlDQpqdXN0LWNyZWF0ZWQg
c29ja2V0IGlzbid0IGdvaW5nIHRvIGJlIHZpc2libGUgdG8gb3RoZXIgY3B1cyB1bnRpbA0KeW91
J3ZlIGFkZGVkIGl0IHRvICZwb29sLT5zcF9zb2NrZXRzICh3aGljaCBhbHNvIGhhcyBpbXBsaWNp
dCB3cml0ZQ0KYmFycmllcnMgZHVlIHRvIHNwaW4gbG9ja3MpLg0KDQpJIGRvbid0IHRoaW5rIHlv
dSByZWFsbHkgY2FyZSBmb3IgdGhlIGNhc2Ugb2YgWFBUX0NMT1NFIGVpdGhlciBzaW5jZQ0Kc3Zj
X2RlbGV0ZV94cHJ0KCkgZG9lc24ndCBkZXBlbmQgb24gYW55IG90aGVyIGRhdGEgd3JpdGVzIHRo
YXQgYXJlbid0DQphbHJlYWR5IHByb3RlY3RlZCBieSBzcGlubG9ja3MuDQoNCg0KU28gdGhlIGNv
bmNsdXNpb24gd291bGQgYmUgdG8gYWRkIHNtcF9ybWIoKSBpbg0Kc3ZjX3hwcnRfaGFzX3NvbWV0
aGluZ190b19kbygpLiBObyBleHRyYSB3cml0ZSBiYXJyaWVycyBhcmUgbmVlZGVkDQpBRkFJQ1Mu
DQpZb3UgbWF5IHN0aWxsIG5lZWQgdGhlIFJFQURfT05DRSgpIGluIG9yZGVyIHRvIGFkZCBhIGRh
dGEgZGVwZW5kZW5jeQ0KYmFycmllciAoaS5lLiB0byBlbnN1cmUgdGhhdCBhbHBoYSBwcm9jZXNz
b3JzIGRvbid0IHJlb3JkZXIgcmVhZHMgb2YNCnRoZSB4cHRfZmxhZ3Mgd2l0aCBvdGhlciBzcGVj
dWxhdGl2ZSByZWFkcykuIFRoYXQgc2hvdWxkIHJlZHVjZSB0byBhDQpzdGFuZGFyZCByZWFkIG9u
IGFsbCBub24tYWxwaGEgYXJjaGl0ZWN0dXJlcy4NCg0KPiANCj4gLS1iLg0KPiANCj4gDQo+IA0K
PiA+IGFuZCB5b3UgZG9uJ3QgZXZlbiBuZWVkIGEgcmVhZCBiYXJyaWVyIGluDQo+ID4gdGhlIG5v
bi1zbXAgY2FzZS4NCj4gPiANCj4gPiA+ICAJaWYgKHhwcnQtPnhwdF9mbGFncyAmICgoMTw8WFBU
X0NPTk4pfCgxPDxYUFRfQ0xPU0UpKSkNCj4gPiA+ICAJCXJldHVybiB0cnVlOw0KPiA+ID4gIAlp
ZiAoeHBydC0+eHB0X2ZsYWdzICYgKCgxPDxYUFRfREFUQSl8KDE8PFhQVF9ERUZFUlJFRCkpKSB7
DQo+ID4gPiANCj4gPiA+IFRoZW4gd2hpY2hldmVyIG1lbW9yeSBiYXJyaWVyIGV4ZWN1dGVzIHNl
Y29uZCBndWFyYW50ZWVzIHRoYXQgdGhlDQo+ID4gPiBmb2xsb3dpbmcgY2hlY2sgc2VlcyB0aGUg
cmVzdWx0IG9mIGJvdGggdGhlIFhQVF9EQVRBIGFuZA0KPiA+ID4geHB0X25yX3Jxc3RzDQo+ID4g
PiBjaGFuZ2VzLiAgSSB0aGluay4uLi4NCj4gPiANCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51
eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFt
bWVyc3BhY2UuY29tDQoNCg0K
