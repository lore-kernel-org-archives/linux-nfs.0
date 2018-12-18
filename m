Return-Path: <SRS0=g2h7=O3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF1F6C43387
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 12:52:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7ADD8217D9
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 12:52:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="ICJSNgk7"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726419AbeLRMwQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Dec 2018 07:52:16 -0500
Received: from mail-eopbgr690134.outbound.protection.outlook.com ([40.107.69.134]:8016
        "EHLO NAM04-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726403AbeLRMwP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Dec 2018 07:52:15 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=rfSB1hmzPw+1njS7ua5EH6AM5Q8ArvrWOKHV1GJhMH4=;
 b=ICJSNgk7z88ilB9c3IEbJgMz8Oz8XNq3e2PqmAQJWD+/2Fn4G24ZJOJ220QrGqdtxrGcEwZi9dSrxYiAuFlUkanfvqjv3MYfuS6VPOa1/3SYVNyGXRROUAhH4/9wEXpHxEk4+ChmLuR2ytOKmRTN2gmBodSItgp9XgAAke8celI=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2544.namprd13.prod.outlook.com (52.135.96.15) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1446.15; Tue, 18 Dec 2018 12:49:16 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1446.015; Tue, 18 Dec 2018
 12:49:15 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "vvs@virtuozzo.com" <vvs@virtuozzo.com>
CC:     "eshatokhin@virtuozzo.com" <eshatokhin@virtuozzo.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "khorenko@virtuozzo.com" <khorenko@virtuozzo.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "jlayton@kernel.org" <jlayton@kernel.org>
Subject: Re: [PATCH 1/4] nfs: use-after-free in svc_process_common()
Thread-Topic: [PATCH 1/4] nfs: use-after-free in svc_process_common()
Thread-Index: AQHUliTq8x5/j6ovkEmcMIRcXEAVYaWDeL8AgACVn4CAAGV+AA==
Date:   Tue, 18 Dec 2018 12:49:15 +0000
Message-ID: <67f477b704d34b369f0530891a219f383f964001.camel@hammerspace.com>
References: <134cf19c-e698-abed-02de-1659f9a5d4fb@virtuozzo.com>
         <20181217215026.GA8564@fieldses.org>
         <cb8d51ae-2745-58ca-8b4d-86c7a4bd2ffe@virtuozzo.com>
In-Reply-To: <cb8d51ae-2745-58ca-8b4d-86c7a4bd2ffe@virtuozzo.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2544;6:1AW+0VdxcQpcj0GVoOHRCy3cWkzCcnKAsKWmn2vlhemDeUnmNN+xjd0V/JJTfXVDzwTg4Xp7SWF1sg3P8yy1N38BzeUFEFMc6IeMCIaTWDzLM2EgQ4i5lv9WCx975KcCB2H1e3qvvnP0zfZn21q2XqRnrbzo4lp3AKj0ZP+gEus46j4OfTPhI67p4dhdfp6iaGrUT4irFwl22MO1tzWHtses/pVrBIKKZST7vgPAZgdotUH1kDw1shX3bj7Hum7do91ycvcBePdIyUrW7PTG/IMuHGeYujShrrHozwj5J8HzmerLzL0y4qRYXauxsv4AXeq1F8oRrhQ3mum1EkraQKOOihCKt4Nwq+sW47hk2eEDe7Dzt33GMgcVx9INdm8YxK/wkSGDpruke8bIvMRr9Odyfzd6uY77aV9dglC/OCPdSYOeo2u4OAslRafzG18yjVSFe1YYHVnUJ+B8eBjUTQ==;5:T4slQC3GucqTP/LIWKrs1Tg5TiCa7JAHfE2+5L788O/jSaPCw8e7mqD3cFuIbzMytAU0ds/5Wl7QypHvzXTVls64yS8sbBJ9TZrp8wJOHE0c5cOrAmsz+iytTMhYMCz2IcXWz65Vfoc7jVwdXxF6bNM0pLtYeFkBnaOPgHpMfGk=;7:yseAvSzklFS3pewRhWgBEKXmHKq/0CXp2IrcgKlS5bgo0Im6B4VnfNWUJ64z95liZRoV0AjzHaisdypis9a07Qtk8TqRRxOo9fidNCZZYoYiFd6D47/BJ+8LAsrUAuWV/MRaspMnkKnUElMUKeX2iw==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 8036a9cd-1fc2-4562-4bbf-08d664e73804
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2544;
x-ms-traffictypediagnostic: SN6PR13MB2544:
x-microsoft-antispam-prvs: <SN6PR13MB2544A29BC5677A39CC015701B8BD0@SN6PR13MB2544.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(999002)(6040522)(2401047)(8121501046)(5005006)(3231475)(944501520)(52105112)(93006095)(93001095)(10201501046)(3002001)(148016)(149066)(150057)(6041310)(20161123564045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123558120)(20161123560045)(20161123562045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2544;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2544;
x-forefront-prvs: 08902E536D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39840400004)(346002)(396003)(136003)(366004)(376002)(199004)(189003)(11346002)(71190400001)(476003)(71200400001)(6436002)(486006)(2616005)(446003)(25786009)(8676002)(36756003)(8936002)(229853002)(81166006)(81156014)(478600001)(256004)(14444005)(76176011)(6486002)(3846002)(53546011)(102836004)(6506007)(6116002)(53936002)(6512007)(106356001)(4326008)(99286004)(2906002)(105586002)(118296001)(66066001)(68736007)(14454004)(2501003)(26005)(97736004)(186003)(4001150100001)(5660300001)(110136005)(7736002)(305945005)(54906003)(316002)(6246003)(86362001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2544;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: yR1LgjipwIzKqfWuRSycwWOs4RzpDqoKR10IPY1bqxPdKqnPhP6V6Go/KwfnXtShBm1Rm+v7q0iLvcPOYwoM81YSQiFilPOCzWf4+pKFstOS++jxX5LZNi1Ln8IcVG97/YF/939tzIMeGxzXjNl/j8VexZnRuDu2DXVkmdKifET+tjqZ2k9kcYsqyATXYtP5OZnDa45eEWgminoLhccKlsJg2taoiBjtDhOBEfZsKXewKhKr1dgO0HSuj6i/f8Ju/jV0sZF2aMgaHhO4LLW6rTpemNnO9Hd1+Ip03yaXJmeIYf0SRnO+0dE3guJAA8MX
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <E7891865796A574997F235723D5CD73F@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8036a9cd-1fc2-4562-4bbf-08d664e73804
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Dec 2018 12:49:15.6140
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2544
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE4LTEyLTE4IGF0IDA5OjQ1ICswMzAwLCBWYXNpbHkgQXZlcmluIHdyb3RlOg0K
PiBPbiAxMi8xOC8xOCAxMjo1MCBBTSwgSi4gQnJ1Y2UgRmllbGRzIHdyb3RlOg0KPiA+IE9uIE1v
biwgRGVjIDE3LCAyMDE4IGF0IDA3OjIzOjU0UE0gKzAzMDAsIFZhc2lseSBBdmVyaW4gd3JvdGU6
DQo+ID4gPiBpZiBub2RlIGhhdmUgTkZTdjQxKyBtb3VudHMgaW5zaWRlIHNldmVyYWwgbmV0IG5h
bWVzcGFjZXMNCj4gPiA+IGl0IGNhbiBsZWFkIHRvIHVzZS1hZnRlci1mcmVlIGluIHN2Y19wcm9j
ZXNzX2NvbW1vbigpDQo+ID4gPiANCj4gPiA+IHN2Y19wcm9jZXNzX2NvbW1vbigpIA0KPiA+ID4g
ICAgICAgICAvKiBTZXR1cCByZXBseSBoZWFkZXIgKi8NCj4gPiA+ICAgICAgICAgcnFzdHAtPnJx
X3hwcnQtPnhwdF9vcHMtPnhwb19wcmVwX3JlcGx5X2hkcihycXN0cCk7IDw8PA0KPiA+ID4gSEVS
RQ0KPiA+ID4gDQo+ID4gPiBzdmNfcHJvY2Vzc19jb21tb24oKSBjYW4gdXNlIGFscmVhZHkgZnJl
ZWQgcnFzdHAtPnJxX3hwcnQsDQo+ID4gPiBpdCB3YXMgYXNzaWduZWQgaW4gYmNfc3ZjX3Byb2Nl
c3MoKSB3aGVyZSBpdCB3YXMgdGFrZW4gZnJvbSBzZXJ2LQ0KPiA+ID4gPnN2X2JjX3hwcnQuDQo+
ID4gPiANCj4gPiA+IHNlcnYgaXMgZ2xvYmFsIHN0cnVjdHVyZSBidXQgc3ZfYmNfeHBydCBpcyBh
c3NpZ25lZCBwZXItDQo+ID4gPiBuZXRuYW1lc3BhY2UsDQo+ID4gPiBzbyBpZiBuZnN2NDErIHNo
YXJlcyBhcmUgbW91bnRlZCBpbiBzZXZlcmFsIGNvbnRhaW5lcnMgdG9nZXRoZXINCj4gPiA+IGJj
X3N2Y19wcm9jZXNzKCkgY2FuIHVzZSB3cm9uZyBiYWNrY2hhbm5lbCBvciBldmVuIGFjY2VzcyBm
cmVlZA0KPiA+ID4gbWVtb3J5Lg0KPiA+ID4gDQo+ID4gPiBUbyBmaW5kIGNvcnJlY3Qgc3ZjX3hw
cnQgb2YgY2xpZW50LXJlbGF0ZWQgYmFja2NoYW5uZWwNCj4gPiA+IGJjX3N2Y19wcm9jZXNzKCkg
bm93IGNhbGxzIG5ldyAuYmNfZ2V0X3hwcnQgY2FsbGJhY2sNCj4gPiA+IHRoYXQgZXhlY3V0ZXMg
c3ZjX2ZpbmRfeHBydCgpIHdpdGggcHJvcGVyIHhwcnQgbmFtZS4NCj4gPiANCj4gPiBUaGlzIHN0
dWZmIGlzIGNvbmZ1c2luZyBhbmQgSSBuZWVkIHRvIHN0YXJlIGF0IGl0IHNvbWUgbW9yZSBiZWZv
cmUNCj4gPiBJDQo+ID4gdW5kZXJzdGFuZCwgYnV0IGl0J3Mgd2VpcmQgdGhhdCB3ZSdkIG5lZWQg
dG8gc2VhcmNoIGZvciB0aGUgcmlnaHQNCj4gPiB4cHJ0Lg0KPiANCj4gQWxsIE5GUyBjbGllbnRz
IGluIGFsbCBuZXQgbmFtZXNwYWNlcyB1c2VkIHRoZSBzYW1lIG1pbm9ydmVyc2lvbiANCj4gc2hh
cmVzIGNvbW1vbiBuZnNfY2FsbGJhY2tfZGF0YSB0YWtlbiBmcm9tIGdsb2JhbCBuZnNfY2FsbGJh
Y2tfaW5mbw0KPiBhcnJheS4NCj4gDQo+IE1vcmVvdmVyIHRoZXNlIGNsaWVudHMgY2FuIHVzZSBl
aXRoZXIgcmRtYSBvciBuZnMgdHJhbnNwb3J0LA0KPiBob3dldmVyIG9ubHkgb25lIG9mIHRoZW0g
Y2FuIGJlIHVzZWQgaW4gb25lIG5ldCBuYW1lc3BhY2UuDQo+IA0KPiBFYWNoIG5ldCBuYW1lc3Bh
Y2UgbXVzdCBoYXZlIG93biBiYWNrY2hhbm5lbCwgDQo+IGl0IGNhbm5vdCBkZXBlbmQgb24gb3Ro
ZXIgbmV0IG5hbWVzcGFjZXMsIA0KPiBiZWNhdXNlIGF0IGxlYXN0IHRoZXkgY2FuIHVzZSBkaWZm
ZXJlbnQgdHJhbnNwb3J0cy4NCj4gDQo+IFNvIG9uZSBzdmNfc2VydiBzaG91bGQgYmUgYWJsZSB0
byBoYW5kbGUgc2V2ZXJhbCAocGVyLW5ldG5zKQ0KPiBiYWNrY2hhbm5lbHMuDQo+IA0KPiBGcmFu
a2x5IHNwZWFraW5nIElmIHlvdSBwcmVmZXIgSSBjYW4gZWFzaWx5IGNvbnZlcnQgZ2xvYmFsDQo+
IG5mc19jYWxsYmFja19pbmZvIHRvIHBlciBuZXQtbmFtZXNwYWNlLg0KPiBJJ3ZlIGNoZWNrZWQs
IGl0IHdvcmtzIHRvby4gSG93ZXZlciBjdXJyZW50IHNvbHV0aW9uIGxvb2tzIGJldHRlciBmb3IN
Cj4gbWUuDQo+IA0KPiA+IFdlIGtub3cgd2hpY2ggY29ubmVjdGlvbiB0aGUgYmFja2NoYW5uZWwg
cmVxdWVzdCBjYW1lIG92ZXIsIGFuZA0KPiA+IHRoZXJlDQo+ID4gc2hvdWxkIG9ubHkgYmUgb25l
IGJhY2tjaGFubmVsIHVzaW5nIHRoYXQgY29ubmVjdGlvbiwgd2h5IGNhbid0IHdlDQo+ID4gZmlu
ZA0KPiA+IGl0IGJ5IGp1c3QgY2hhc2luZyBwb2ludGVycyB0aGUgcmlnaHQgd2F5Pw0KPiANCj4g
aXQgaXMgYWxsb2NhdGVkIGJ5IHVzaW5nIGZvbGx3aW5nIGNhbGx0cmFjZToNCj4gbmZzX2NhbGxi
YWNrX3VwDQo+ICBuZnNfY2FsbGJhY2tfdXBfbmV0DQo+ICAgeHBydC0+b3BzLT5iY191cChzZXJ2
LCBuZXQpIC0+IHhzX3RjcF9iY191cA0KPiAgICBzdmNfY3JlYXRlX3hwcnQoc2VydiwgInRjcC1i
YyIpDQo+ICAgICBfX3N2Y194cG9fY3JlYXRlDQo+ICAgICAgc3ZjX2JjX3RjcF9jcmVhdGUNCj4g
ICAgICAgc3ZjX2JjX2NyZWF0ZV9zb2NrZXQNCj4gDQo+IEhlcmUgYmFja2NoYW5uZWwncyBzdmNf
c29jay9zdmMveHBydCBpcyBjcmVhdGVkLg0KPiBJdCBpcyBwZXItbmV0bnMgYW5kIHRoZXJlZm9y
ZSBpdCBjYW5ub3QgYmUgc2F2ZWQgYXMgcG9pbnRlciBvbiBnbG9iYWwNCj4gc3ZjX3NlcnYuDQo+
IA0KPiBJdCBjb3VsZCBiZSBzYXZlZCBvbiBzb21lIHhwcnQgcmVsYXRlZCB0byBmb3JlY2hhbm5l
bCwNCj4gSSd2ZSBleHBlY3RlZCBpdCB3YXMgZG9uZSBhbHJlYWR5IC0tIGJ1dCBpdCB3YXMgbm90
IGRvbmUuDQo+IEkndmUgdHJpZWQgdG8gZmluZCBhbnkgd2F5IHRvIGRvIGl0IC0tIGJ1dCB3aXRo
b3V0IHN1Y2Nlc3MsDQo+IGFjY29yZGluZyBzdHJ1Y3R1cmVzIHNlZW1zIGFyZSBub3QgYWNjZXNz
aWJsZSBpbiBzdmNfYmNfdGNwX2NyZWF0ZS4NCj4gDQo+IEZpbmFsbHkgSSd2ZSBmb3VuZCB0aGF0
IGJhY2tjaGFubmVsJ3MgeHBydCBpcyBhZGRlZCBpbnRvIHNlcnYtDQo+ID5zdl9wZXJtc29ja3MN
Cj4gYW5kIHN2Y19maW5kX3hwcnQgY2FuIGZpbmQgaXQgYnkgbmFtZS4NCj4gDQo+IEl0IHdvdWxk
IGJlIGdyZWF0IGlmIHlvdSBjYW4gYWR2aXNlIHNvbWUgbW9yZSBzaW1wbGUgd2F5LiAgDQo+IA0K
PiA+IE9LLCBJIGRvIG5lZWQgdG8gbG9vayBhdCBpdCBtb3JlLg0KPiANCj4gSXQgaXMgcXVpdGUg
aW1wb3J0YW50IGZvciBjb250YWluZXJzIHNvIEkgdGhpbmsgdGhpcyBwYXRjaCAob3IgYW55DQo+
IGFsdGVybmF0aXZlIHNvbHV0aW9uKQ0KPiBzaG91bGQgYmUgcHVzaGVkIGluIHN0YWJsZUAuDQo+
IA0KDQpUaGUgd2hvbGUgImxldCdzIHNldCB1cCBycXN0cC0+cnFfeHBydCBmb3IgdGhlIGJhY2sg
Y2hhbm5lbCIgaXMgbm90aGluZw0KYnV0IGEgZ2lhbnQgaGFjayBpbiBvcmRlciB0byB3b3JrIGFy
b3VuZCB0aGUgZmFjdCB0aGF0DQpzdmNfcHJvY2Vzc19jb21tb24oKSB1c2VzIGl0IHRvIGZpbmQg
dGhlIHhwdF9vcHMsIGFuZCBwZXJmb3JtIGEgY291cGxlDQpvZiAobWVhbmluZ2xlc3MgZm9yIHRo
ZSBiYWNrIGNoYW5uZWwpIHRlc3RzIG9mIHhwdF9mbGFncy4NCg0KV2hhdCBzYXkgd2UganVzdCBw
YXNzIGluIHRoZSB4cHRfb3BzIGFzIGEgcGFyYW1ldGVyIHRvDQpzdmNfcHJvY2Vzc19jb21tb24o
KSwgYW5kIG1ha2UgdGhvc2UgeHB0X2ZsYWdzIHRlc3RzIGNoZWNrIGZvciB3aGV0aGVyDQpvciBu
b3QgcnFzdHAtPnJxX3hwcnQgaXMgYWN0dWFsbHkgbm9uLU5VTEw/DQoNCkl0IHByb2JhYmx5IGFs
c28gcmVxdWlyZXMgdXMgdG8gc3RvcmUgYSBwb2ludGVyIHRvIHN0cnVjdCBuZXQgaW4gdGhlDQpz
dHJ1Y3Qgc3ZjX3Jxc3Qgc28gdGhhdCBuZnM0X2NhbGxiYWNrX2NvbXBvdW5kKCkgYW5kDQpzdmNh
dXRoX2dzc19hY2NlcHQoKSBjYW4gZmluZCBpdCwgYnV0IHRoYXQgc2hvdWxkIGJlIE9LIHNpbmNl
IHRoZQ0KdHJhbnNwb3J0IGFscmVhZHkgaGFzIHRoYXQgcmVmZXJlbmNlZC4NCg0KQ2hlZXJzLA0K
ICBUcm9uZA0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5l
ciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
