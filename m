Return-Path: <SRS0=GLKr=PR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74E61C43387
	for <linux-nfs@archiver.kernel.org>; Wed,  9 Jan 2019 17:44:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0DC0520656
	for <linux-nfs@archiver.kernel.org>; Wed,  9 Jan 2019 17:44:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="XsbN1FAM"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727075AbfAIRod (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 9 Jan 2019 12:44:33 -0500
Received: from mail-eopbgr690135.outbound.protection.outlook.com ([40.107.69.135]:6171
        "EHLO NAM04-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726674AbfAIRod (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 9 Jan 2019 12:44:33 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=a1JBTC6eYx9H9bniIuciLj4hde4Xn4YpjCewhu0oWPc=;
 b=XsbN1FAMhc+PQMpzb3XDD2htQ3wMLPXjBEb9IuPD/RQdIHNmKP0CXIYvu8nhv8GkvjaKFxKErVMM13/JC0HgT2cXvt7yTiRrC+NHVx1WyZJB/9zpIVJM7bgD0VVpKbLahlmMXFcIiE9y10hKDzPkba8c2kMPUZmd6RcCDiv5DSM=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2318.namprd13.prod.outlook.com (52.135.94.25) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1516.2; Wed, 9 Jan 2019 17:41:37 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%4]) with mapi id 15.20.1516.010; Wed, 9 Jan 2019
 17:41:37 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Don't allow compiler optimisation of
 svc_xprt_release_slot()
Thread-Topic: [PATCH] SUNRPC: Don't allow compiler optimisation of
 svc_xprt_release_slot()
Thread-Index: AQHUo28wQYHfdyrJOkiXFnTxUjWqjaWeJS6AgAAPUoCAAS1wAIAE+B8AgAAJf4CAARuKgIAAFneAgAGaxACAAA3uAA==
Date:   Wed, 9 Jan 2019 17:41:36 +0000
Message-ID: <300445038b75d5efafe9391eb4b8e83d9d6e3633.camel@hammerspace.com>
References: <20190103141712.24381-1-trond.myklebust@hammerspace.com>
         <20190103224529.GA6907@fieldses.org>
         <a0493a5f022a666779d19fde5cdfbfdf9c7316c4.camel@hammerspace.com>
         <20190104173912.GC11787@fieldses.org> <20190107213218.GD7753@fieldses.org>
         <e14e17167ef98c456e7648ad0536827b7870f0ff.camel@hammerspace.com>
         <20190108150107.GA15921@fieldses.org>
         <4077991d3d3acee4c37c7c8c6dc2b76930c9584e.camel@hammerspace.com>
         <20190109165142.GB32189@fieldses.org>
In-Reply-To: <20190109165142.GB32189@fieldses.org>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2318;6:mV6apYcdmtwIqD6Ch5XeonzpIBok2BudA27iY1ZTmEWORS8F0yIOlKAh55NAC8tgPM/QnYnt65waM4i1yDe8LcR34gKGunJyaRNHpi5+s28YAV+kvWFka0aHGl45VIp2ee9cG10dHz1a1Wn7tOBm3jvns5Z6mAFNQH/xDianIfywP0TC5VViZ04LjUfwBNmnhISqZZ8SpUsG+8IFnsDuOMzCWIJdppqTqbLXJfC5B6H7MXVKwp2LUBMr7RC1pblWN2I2zXtNk9RMKZgijQ+0bjbHXEo8NFcQ6JCXn5+UPSDE5B+abP5GYIHKgCyFzp+cvjrXht4mBLJRozG/3Ro9aGT4xizXkB7nu67sv+4dBz4wrbsGeiaz3PhIDvqYTtrghVKTNVO6VqOK1RP7r1Dc18mOjUy6UrDfOL6L6NDOmevyRP7Xpv/x+fGyr1g+1a83MdZeLKV4dTomr4wTGw1nmg==;5:GssCs+qp7N88Kgk9RZWhwUhJxD0L8F5q2SDlAiBnw8QugB0wfs5i+Lrs5snStRRN+DKfWR2HCokYJyBnHnSZ3vgaSGlHoaQUxoHTUU77w3egUcfsN6xNevNFSLAV1AGu1oREI9fzXymixubUvswxkK44uUvS3JSLiZ1Vc+MX7E+t282Mvem9aHh08/DfPrO6NWu4mf/umlb3E6YhyktikA==;7:YHwBpnjcyQ8HQGQI3qmf/Ta0nYrshf4XAiBYkX388lUdNdYT14uxtr9Lw12wkBsVDGkFOigVQb0OVOHS6VaashOqz5tym7FlGdkwEbCYPm11vgIZVyd1cyjAgaS2jmXLKNa1nCT9FdxL+fw7DUDXxA==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: d428140c-746c-4661-db61-08d67659b47b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2318;
x-ms-traffictypediagnostic: SN6PR13MB2318:
x-microsoft-antispam-prvs: <SN6PR13MB2318104036D62D7D4A6E3BB5B88B0@SN6PR13MB2318.namprd13.prod.outlook.com>
x-forefront-prvs: 0912297777
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(366004)(396003)(376002)(39840400004)(346002)(189003)(199004)(106356001)(6486002)(99286004)(8676002)(2501003)(4326008)(6246003)(6436002)(1730700003)(8936002)(81156014)(81166006)(105586002)(2351001)(68736007)(97736004)(14444005)(86362001)(11346002)(486006)(476003)(2616005)(71190400001)(71200400001)(6116002)(446003)(5640700003)(118296001)(3846002)(478600001)(256004)(186003)(6506007)(6346003)(14454004)(102836004)(2906002)(76176011)(26005)(36756003)(7736002)(5660300001)(93886005)(66066001)(25786009)(316002)(6916009)(305945005)(53936002)(229853002)(6512007);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2318;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Xv+pG8Sxuf/H3b1+ENptvpradzAUztV2qZ6uqmZdkEznf35TH6J28sI0YXLxgGSjLCbRFpCB+LwShRCx+5TokRa9L/LQykBhD3TPi4b3PYfbOSmY4/MKvuzTtSF2mEZkUKJ5PHza9aEojgd/RX+zB2YOmYdq7d7HHPFlqLsgmoEKl1NM9eV7w3UWv9MGse3qG++EE1hKltBywotoXqOxHGZsCQ9IDlA9pUbsuL6JkzGZ7myVcqiRmgfgwcLjUWURw0oJaiT0uXgBVd5OrGIB1erwSc/NEN0Tomh74PnrKIELwZrhIVs9vclnskr7R93N
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <3628E69FB56A56449160D03FD860EA8D@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: d428140c-746c-4661-db61-08d67659b47b
X-MS-Exchange-CrossTenant-originalarrivaltime: 09 Jan 2019 17:41:37.0125
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2318
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gV2VkLCAyMDE5LTAxLTA5IGF0IDExOjUxIC0wNTAwLCBiZmllbGRzQGZpZWxkc2VzLm9yZyB3
cm90ZToNCj4gT24gVHVlLCBKYW4gMDgsIDIwMTkgYXQgMDQ6MjE6NDBQTSArMDAwMCwgVHJvbmQg
TXlrbGVidXN0IHdyb3RlOg0KPiA+IE9uIFR1ZSwgMjAxOS0wMS0wOCBhdCAxMDowMSAtMDUwMCwg
YmZpZWxkc0BmaWVsZHNlcy5vcmcgd3JvdGU6DQo+ID4gPiBPbiBNb24sIEphbiAwNywgMjAxOSBh
dCAxMDowNjoxOVBNICswMDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6DQo+ID4gPiA+IE9uIE1v
biwgMjAxOS0wMS0wNyBhdCAxNjozMiAtMDUwMCwgYmZpZWxkc0BmaWVsZHNlcy5vcmcgd3JvdGU6
DQo+ID4gPiA+ID4gU28gbWF5YmUgd2UgYWN0dWFsbHkgbmVlZA0KPiA+ID4gPiA+IA0KPiA+ID4g
PiA+ICBzdGF0aWMgYm9vbCAoc3RydWN0IHN2Y194cHJ0ICp4cHJ0KQ0KPiA+ID4gPiA+ICB7DQo+
ID4gPiA+ID4gKwltYigpOw0KPiA+ID4gPiANCj4gPiA+ID4gWW91IHdvdWxkIGF0IGJlc3QgbmVl
ZCBhICdzbXBfcm1iKCknLiBUaGVyZSBpcyBub3RoaW5nIHRvIGdhaW4NCj4gPiA+ID4gZnJvbQ0K
PiA+ID4gPiBhZGRpbmcgYSB3cml0ZSBiYXJyaWVyIGhlcmUsDQo+ID4gPiANCj4gPiA+IFRoYXQn
cyBub3QgbXkgdW5kZXJzdGFuZGluZy4NCj4gPiA+IA0KPiA+ID4gV2hhdCB3ZSBoYXZlIGlzIGJh
c2ljYWxseToNCj4gPiA+IA0KPiA+ID4gCTEJCQkyDQo+ID4gPiAJLS0tLQkJCS0tLS0NCj4gPiA+
IAlXUklURSB0byBBCQlXUklURSB0byBCDQo+ID4gPiANCj4gPiA+IAlSRUFEIGZyb20gQSBhbmQg
QglSRUFEIGZyb20gQSBhbmQgQg0KPiA+ID4gDQo+ID4gPiBhbmQgd2Ugd2FudCB0byBndWFyYW50
ZWUgdGhhdCBhdCBsZWFzdCBvbmUgb2YgdGhvc2UgdHdvIHJlYWRzDQo+ID4gPiB3aWxsDQo+ID4g
PiBzZWUNCj4gPiA+IGJvdGggb2YgdGhlIHdyaXRlcy4NCj4gPiA+IA0KPiA+ID4gQSByZWFkIGJh
cnJpZXIgb25seSBvcmRlcnMgcmVhZHMgd2l0aCByZXNwZWN0IHRvIHRoZSBiYXJyaWVyLCBpdA0K
PiA+ID4gZG9lc24ndA0KPiA+ID4gZG8gYW55dGhpbmcgYWJvdXQgd3JpdGVzLCBzbyBkb2Vzbid0
IGd1YXJhbnRlZSBhbnl0aGluZyBoZXJlLg0KPiA+IA0KPiA+IEluIHRoaXMgY29udGV4dCAnV1JJ
VEUgdG8gQScgYW5kL29yICdXUklURSB0byBCJyBhcmUgcHJlc3VtYWJseSB0aGUNCj4gPiBvcGVy
YXRpb25zIG9mIHNldHRpbmcgdGhlIGZsYWcgYml0cyBpbiB4cHJ0LT54cHRfZmxhZ3MsIG5vPw0K
PiANCj4gUmlnaHQsIG9yIEkgZ3Vlc3Mgc2tfc29jay0+ZmxhZ3MsIG9yIGFuIGF0b21pYyBvcGVy
YXRpb24gb24NCj4geHB0X3Jlc2VydmVkDQo+IG9yIHhwdF9ucl9ycXN0cy4NCj4gDQo+ID4gVGhh
dCdzIG5vdCBvY2N1cnJpbmcgaGVyZSwgaXQgaXMgb2NjdXJyaW5nIGVsc2V3aGVyZS4NCj4gDQo+
IFJpZ2h0LiAgQW5kIEkgaGFkbid0IHRyaWVkIHRvIHZlcmlmeSB3aGV0aGVyIHRoZXJlIHdlcmUg
Y29ycmVzcG9uZGluZw0KPiAocG9zc2libHkgaW1wbGljaXQpIHdyaXRlIGJhcnJpZXJzIGluIHRo
b3NlIHBsYWNlcywgdGhhbmtzIGZvciBkb2luZw0KPiB0aGF0IHdvcms6DQo+IA0KPiA+IFRoZSB0
ZXN0X2FuZF9zZXRfYml0KFhQVF9EQVRBLCAmeHBydC0+eHB0X2ZsYWdzKSBpbg0KPiA+IHN2Y19k
YXRhX3JlYWR5KCkNCj4gPiBwZXJmb3JtcyBhbiBleHBsaWNpdCBiYXJyaWVyLCBzbyB3ZSBzaG91
bGRuJ3QgcmVhbGx5IGNhcmUuDQo+IA0KPiBPSy4NCj4gDQo+ID4gVGhlIG90aGVyIGNhc2VzIHdo
ZXJlIHdlIGRvIHNldF9iaXQoWFBUX0RBVEEpIGRvbid0IG1hdHRlciBzaW5jZQ0KPiA+IHRoZQ0K
PiA+IHNvY2tldCBoYXMgaXRzIG93biBsb2NraW5nLCBhbmQgc28gdGhlIFhQVF9EQVRBIGlzIHJl
YWxseSBqdXN0IGENCj4gPiB0ZXN0DQo+ID4gZm9yIHdoZXRoZXIgb3Igbm90IHdlIG5lZWQgdG8g
ZW5xdWV1ZSB0aGUgc3ZjX3hwcnQuDQo+IA0KPiBJJ20gbm90IGZvbGxvd2luZywgYXBvbG9naWVz
Lg0KPiANCj4gSW4gYW55IGNhc2UgaXQncyBzZXQgb25seSBvbiBpbml0aWFsaXphdGlvbiBvciBp
biByZWN2ZnJvbSwgYW5kIGluDQo+IHRoZQ0KPiByZWN2ZnJvbSBjYXNlIEkgdGhpbmsgdGhlDQo+
IA0KPiAJc21wX21iX19iZWZvcmVfYXRvbWljKCk7DQo+IAljbGVhcl9iaXQoWFBUX0JVU1ksICZ4
cHJ0LT54cHRfZmxhZ3MpOw0KPiANCj4gaW4gc3ZjX3hwcnRfcmVjZWl2ZWQoKSBwcm92aWRlcyB0
aGUgbmVjZXNzYXJ5IHdyaXRlIGJhcnJpZXIuDQo+IA0KPiBCdXQgdGhlcmUgYXJlIHNvbWUgZXhj
ZXB0aW9ucyBpbiB0aGUgcmRtYSBjb2RlLCBpbg0KPiBzdmNfcmRtYV93Y19yZWNlaXZlDQo+IGFu
ZCBzdmNfcmRtYV93Y19kb25lLg0KPiANCj4gPiBJbiB0aGUgb25seSBwbGFjZSB3aGVyZSBYUFRf
REVGRVJSRUQgaXMgc2V0LCB5b3UgaGF2ZSBhbiBpbXBsaWNpdA0KPiA+IHdyaXRlDQo+ID4gYmFy
cmllciAoZHVlIHRvIGEgc3Bpbl91bmxvY2spIGJldHdlZW4gdGhlIGNhbGwgdG8gc2V0X2JpdCgp
IGFuZA0KPiA+IHRoZQ0KPiA+IGNhbGwgdG8gc3ZjX3hwcnRfZW5xdWV1ZSgpLCBzbyBhbGwgZGF0
YSB3cml0ZXMgYXJlIGd1YXJhbnRlZWQgdG8gYmUNCj4gPiBjb21wbGV0ZSBiZWZvcmUgYW55IGF0
dGVtcHQgdG8gZW5xdWV1ZSB0aGUgc29ja2V0Lg0KPiANCj4gT0suDQo+IA0KPiA+IEkgY2FuJ3Qg
c2VlIHRoYXQgeW91IHJlYWxseSBjYXJlIGZvciB0aGUgY2FzZSBvZiBYUFRfQ09OTiwgc2luY2UN
Cj4gPiB0aGUNCj4gPiBqdXN0LWNyZWF0ZWQgc29ja2V0IGlzbid0IGdvaW5nIHRvIGJlIHZpc2li
bGUgdG8gb3RoZXIgY3B1cyB1bnRpbA0KPiA+IHlvdSd2ZSBhZGRlZCBpdCB0byAmcG9vbC0+c3Bf
c29ja2V0cyAod2hpY2ggYWxzbyBoYXMgaW1wbGljaXQgd3JpdGUNCj4gPiBiYXJyaWVycyBkdWUg
dG8gc3BpbiBsb2NrcykuDQo+ID4gDQo+ID4gSSBkb24ndCB0aGluayB5b3UgcmVhbGx5IGNhcmUg
Zm9yIHRoZSBjYXNlIG9mIFhQVF9DTE9TRSBlaXRoZXINCj4gPiBzaW5jZQ0KPiA+IHN2Y19kZWxl
dGVfeHBydCgpIGRvZXNuJ3QgZGVwZW5kIG9uIGFueSBvdGhlciBkYXRhIHdyaXRlcyB0aGF0DQo+
ID4gYXJlbid0DQo+ID4gYWxyZWFkeSBwcm90ZWN0ZWQgYnkgc3BpbmxvY2tzLg0KPiANCj4gT0su
ICBZZXMsIEknbSBub3Qgd29ycmllZCBhYm91dCBYUFRfQ09OTiBvciBYUFRfQ0xPU0UuDQo+IA0K
PiA+IFNvIHRoZSBjb25jbHVzaW9uIHdvdWxkIGJlIHRvIGFkZCBzbXBfcm1iKCkgaW4NCj4gPiBz
dmNfeHBydF9oYXNfc29tZXRoaW5nX3RvX2RvKCkuIE5vIGV4dHJhIHdyaXRlIGJhcnJpZXJzIGFy
ZSBuZWVkZWQNCj4gPiBBRkFJQ1MuDQo+ID4gWW91IG1heSBzdGlsbCBuZWVkIHRoZSBSRUFEX09O
Q0UoKSBpbiBvcmRlciB0byBhZGQgYSBkYXRhDQo+ID4gZGVwZW5kZW5jeQ0KPiA+IGJhcnJpZXIg
KGkuZS4gdG8gZW5zdXJlIHRoYXQgYWxwaGEgcHJvY2Vzc29ycyBkb24ndCByZW9yZGVyIHJlYWRz
DQo+ID4gb2YNCj4gPiB0aGUgeHB0X2ZsYWdzIHdpdGggb3RoZXIgc3BlY3VsYXRpdmUgcmVhZHMp
LiBUaGF0IHNob3VsZCByZWR1Y2UgdG8NCj4gPiBhDQo+ID4gc3RhbmRhcmQgcmVhZCBvbiBhbGwg
bm9uLWFscGhhIGFyY2hpdGVjdHVyZXMuDQo+IA0KPiBUaGF0IGxvb2tzIHVubmVjZXNzYXJ5OyBt
ZW1vcnktYmFycmllcnMudHh0IHNheSAiUmVhZCBtZW1vcnkgYmFycmllcnMNCj4gaW1wbHkgZGF0
YSBkZXBlbmRlbmN5IGJhcnJpZXJzIiwgYW5kIGxhdGVyICJBcyBvZiB2NC4xNSBvZiB0aGUgTGlu
dXgNCj4ga2VybmVsLCBhbiBzbXBfcmVhZF9iYXJyaWVyX2RlcGVuZHMoKSB3YXMgYWRkZWQgdG8g
UkVBRF9PTkNFKCkiLg0KPiANCg0KVGhlIGFib3ZlIGlzIHN0YXRpbmcgdGhhdA0KDQpzbXBfcm1i
KCk7DQpzbXBfcmVhZF9iYXJyaWVyX2RlcGVuZHMoKTsNCmlmICh4cHJ0LT54cHRfZmxhZ3MgJiAu
Li4uKQ0KDQppcyByZWR1bmRhbnQgYW5kIGNhbiBiZSByZXBsYWNlZCB3aXRoIGp1c3QNCg0Kc21w
X3JtYigpOw0KaWYgKHhwcnQtPnhwdF9mbGFncyAmIC4uLi4pDQoNCkhvd2V2ZXIgdGhhdCdzIG5v
dCB0aGUgY2FzZSBmb3Igc21wX3JtYigpIGZvbGxvd2VkIGJ5IFJFQURfT05DRSgpLiBUaGF0DQp3
b3VsZCBleHBhbmQgdG8NCg0Kc21wX3JtYigpOw0KaWYgKHhwcnQtPnhwdF9mbGFncyAmIC4uLikg
ew0KICAgIHNtcF9yZWFkX2JhcnJpZXJfZGVwZW5kcygpOw0KfSBlbHNlDQogICAgc21wX3JlYWRf
YmFycmllcl9kZXBlbmRzKCk7DQoNCndoaWNoIGlzIG5vdCByZWR1bmRhbnQuIEl0IGlzIGVuc3Vy
aW5nIChvbiBhbHBoYSBvbmx5KSB0aGF0IHRoZSByZWFkIG9mDQp4cHJ0LT54cHRfZmxhZ3MgaXMg
YWxzbyBub3QgcmUtb3JkZXJlZCB3LnIudC4gb3RoZXIgZGF0YSByZWFkcyB0aGF0DQpmb2xsb3cu
DQoNClNlZSwgZm9yIGluc3RhbmNlLCBrZXJuZWwvZXZlbnRzL2NvcmUuYyB3aGljaCBoYXMgc2V2
ZXJhbCBleGFtcGxlcywgb3INCmtlcm5lbC9leGl0LmMuDQoNCj4gSSBzdGlsbCB3b25kZXIgYWJv
dXQ6DQo+IA0KPiAJLSB0aGUgUkRNQSBjYXNlcyBhYm92ZS4NCj4gCS0gc3ZjX3hwcnRfcmVsZWFz
ZV9zbG90OiBubyB3cml0ZSBiYXJyaWVyIGFmdGVyIHdyaXRpbmcgdG8NCj4gCSAgeHBydC0+eHB0
X25yX3Jxc3RzLg0KPiAJLSBzdmNfcmVzZXJ2ZTogbm8gYmFycmllciBhZnRlciB3cml0aW5nIHRv
IHhwdF9yZXNlcnZlZA0KPiANCj4gQWxzbyBzdmNfd3JpdGVfc3BhY2UgaXMgc2V0dGluZyBTT0NL
X05PU1BBQ0UgYW5kIHRoZW4gY2FsbGluZw0KPiBzdmNfeHBydF9lbnF1ZXVlLiAgSSdtIHByZXR0
eSBzdXJlIHRoZSBza193cml0ZV9zcGFjZSBtZXRob2QgaGFzIHRvDQo+IGhhdmUNCj4gYSB3cml0
ZSBiYXJyaWVyIGFmdGVyIHRoYXQsIHRob3VnaCwgc28gdGhpcyBpcyBPSy4NCj4gDQo+IC0tYi4N
Cj4gDQo+ID4gPiAtLWIuDQo+ID4gPiANCj4gPiA+IA0KPiA+ID4gDQo+ID4gPiA+IGFuZCB5b3Ug
ZG9uJ3QgZXZlbiBuZWVkIGEgcmVhZCBiYXJyaWVyIGluDQo+ID4gPiA+IHRoZSBub24tc21wIGNh
c2UuDQo+ID4gPiA+IA0KPiA+ID4gPiA+ICAJaWYgKHhwcnQtPnhwdF9mbGFncyAmICgoMTw8WFBU
X0NPTk4pfCgxPDxYUFRfQ0xPU0UpKSkNCj4gPiA+ID4gPiAgCQlyZXR1cm4gdHJ1ZTsNCj4gPiA+
ID4gPiAgCWlmICh4cHJ0LT54cHRfZmxhZ3MgJg0KPiA+ID4gPiA+ICgoMTw8WFBUX0RBVEEpfCgx
PDxYUFRfREVGRVJSRUQpKSkgew0KPiA+ID4gPiA+IA0KPiA+ID4gPiA+IFRoZW4gd2hpY2hldmVy
IG1lbW9yeSBiYXJyaWVyIGV4ZWN1dGVzIHNlY29uZCBndWFyYW50ZWVzIHRoYXQNCj4gPiA+ID4g
PiB0aGUNCj4gPiA+ID4gPiBmb2xsb3dpbmcgY2hlY2sgc2VlcyB0aGUgcmVzdWx0IG9mIGJvdGgg
dGhlIFhQVF9EQVRBIGFuZA0KPiA+ID4gPiA+IHhwdF9ucl9ycXN0cw0KPiA+ID4gPiA+IGNoYW5n
ZXMuICBJIHRoaW5rLi4uLg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQg
bWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20N
Cg0KDQo=
