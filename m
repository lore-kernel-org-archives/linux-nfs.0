Return-Path: <SRS0=v8AN=PI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44511C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 31 Dec 2018 19:21:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0600B2081B
	for <linux-nfs@archiver.kernel.org>; Mon, 31 Dec 2018 19:21:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Hspjd54p"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727627AbeLaTVc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 31 Dec 2018 14:21:32 -0500
Received: from mail-eopbgr790095.outbound.protection.outlook.com ([40.107.79.95]:16702
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726903AbeLaTVc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 31 Dec 2018 14:21:32 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=liSSBQ/1lAscehuByS6RBgE6ZC6xPCSHL+Y5BOfEE5g=;
 b=Hspjd54pLjsaMIGMX11RgGpC+vb2xUBnb0ahh4eAcjZT2lcTpIiZq1MvCJELxJp2rfJBYg6LpX0VESxETWK/kTToTBWkby1u6vY5Li8NL4EK159y0BBhZVk+N5gtHVSNasgxsuSRMEm+mG3yhZg8C0q5seEytFJEfHV5HAIGQWo=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2366.namprd13.prod.outlook.com (52.135.94.146) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1495.5; Mon, 31 Dec 2018 19:21:28 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%3]) with mapi id 15.20.1495.005; Mon, 31 Dec 2018
 19:21:28 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 26/44] SUNRPC: Improve latency for interactive tasks
Thread-Topic: [PATCH v3 26/44] SUNRPC: Improve latency for interactive tasks
Thread-Index: AQHUTob5qK09WaTXZkeMo/gY+CHqD6WTldAAgAAwIgCAAAW4AIAF/x2AgAAJ4YCAAAQ7gIAAAqsAgAACmQCAAADYgA==
Date:   Mon, 31 Dec 2018 19:21:28 +0000
Message-ID: <07dcc1731996d6e59d882c5e4e7e7765d013c337.camel@hammerspace.com>
References: <c4bd04d525a1355e3dfff054985d697f0f391816.camel@hammerspace.com>
In-Reply-To: <c4bd04d525a1355e3dfff054985d697f0f391816.camel@hammerspace.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2366;6:QT3L1JR98eai2CK4kDVGNMM0wfeDSx2SV+QAPuCVCu6cJbgekDy9BRHIo00V1oDDSQ+Mj+Q1bwwl1fZ3/2hyoWpDg6M1YyKiar+cAdg44NkyV9K1OhJTaJTqchl8TdyBAUWKR1RKQAlHCSV7h1VmvIIEPqur74XlI9uNhD+hQyYCL7VUnBcoWFAgbOvMtBr9KSIg6xvmym2viu2WJw25Tx5ryo9gir/TnbdoCAUmJZ6+pBbXvPyFJ2MwlE0KfeX0K2ZSsiaZ4zPsULUcJg5aERPFQimGIrDrMj0bAL8Ny13uwkLOHkg/kHa863elym30axDUIOCqEpcrYTO7LALonIis3q2i1IW4MrHlJ7LoHSWR+khfM6Z8OBSjFVJ9R54+5ffTRb/k52atBXjYZZPYIgwchjW2Hbw5WS6ug0QafwM2sAqBQ4zflp9bxcI+xEQiXvSuvAIgJdDKrqbmBnTSPQ==;5:8t8T7jAD2AgrbzRSD32bVCvR2l5+9upncvCTL7vkennEGgWQyp/PtfbaeYLgMsMxMTXoEPWgb/H3yBUfz0UBy5g0jTviFMwiQSn1/TB7UGU8cv1m4HYh+BWzEavjQ8toUyOxOezSrHR7XI2BRQV54+62eiyil9izrZyt1qnTsicPSTzzpWixFgspr9e4sFmRMMg8Erj2KG+qnuISai4Mxg==;7:kjnkalUrV0NinYHgunbOCE9m8bEQj1iPjyxoaSmlsUGnUXyaKtybiL7PuRZ/KUMbW3e1DsuiqfkIVHWj2jFqly9gyNDDR9olHqEIEFcq4eZ3mi3JNwbApeWpVjfllBM6ynIcjdR8A3uvA9UlOiuKzw==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 55b81546-311e-4bae-4def-08d66f552a0a
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2366;
x-ms-traffictypediagnostic: SN6PR13MB2366:
x-microsoft-antispam-prvs: <SN6PR13MB2366D1F6232382323AA70089B8B20@SN6PR13MB2366.namprd13.prod.outlook.com>
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(908002)(999002)(5005026)(6040522)(8220055)(2401047)(8121501046)(10201501046)(3002001)(93006095)(93001095)(3231475)(944501520)(52105112)(6041310)(20161123564045)(20161123558120)(20161123562045)(20161123560045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2366;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2366;
x-forefront-prvs: 0903DD1D85
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(366004)(346002)(376002)(136003)(39830400003)(189003)(199004)(4326008)(25786009)(305945005)(68736007)(7736002)(5660300001)(3846002)(6116002)(6512007)(53936002)(118296001)(6246003)(8936002)(81166006)(81156014)(8676002)(6916009)(71200400001)(71190400001)(105586002)(86362001)(5640700003)(486006)(256004)(14444005)(2906002)(106356001)(2351001)(4001150100001)(6436002)(97736004)(316002)(6506007)(53546011)(76176011)(6486002)(14454004)(2501003)(229853002)(478600001)(36756003)(476003)(2616005)(6346003)(186003)(26005)(99286004)(102836004)(446003)(11346002)(66066001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2366;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: cdwHmRChGXmuk4NMjS/5GDIMRvp3FzAuPPH0ARa/0ENVwh9jBSy4qhwL+v9jBEpp/Wclw+oupWw4rGpmoPP9QC4aWTVqWe4Ew6jSmbg+eukF47m+Z6Auv9CT/0R20L2KAnHdL6LAm3KH93E4alJkqFf5lKobS65N8lNE031JKPyBLJBWWzPlT2TBqrLr8DsRvg/8dxrMugtlSn9vZZ9at/IdWSGX0lfBNE+6tENeoBPN0uKoXKWitwbbLX1hprQ4x2HNn26/9uEvkBQuRDDn06QK1cAZ0AUAYOwPZTU/G1w5DbPhacYfggSmymwrjyRd
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <0682481E450B43488D1612354A3D54AC@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 55b81546-311e-4bae-4def-08d66f552a0a
X-MS-Exchange-CrossTenant-originalarrivaltime: 31 Dec 2018 19:21:28.6944
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2366
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE4LTEyLTMxIGF0IDE5OjE4ICswMDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+IE9uIE1vbiwgMjAxOC0xMi0zMSBhdCAxNDowOSAtMDUwMCwgQ2h1Y2sgTGV2ZXIgd3JvdGU6
DQo+ID4gPiBPbiBEZWMgMzEsIDIwMTgsIGF0IDE6NTkgUE0sIFRyb25kIE15a2xlYnVzdCA8DQo+
ID4gPiB0cm9uZG15QGhhbW1lcnNwYWNlLmNvbT4gd3JvdGU6DQo+ID4gPiANCj4gPiA+IE9uIE1v
biwgMjAxOC0xMi0zMSBhdCAxMzo0NCAtMDUwMCwgQ2h1Y2sgTGV2ZXIgd3JvdGU6DQo+ID4gPiA+
ID4gT24gRGVjIDMxLCAyMDE4LCBhdCAxOjA5IFBNLCBUcm9uZCBNeWtsZWJ1c3QgPA0KPiA+ID4g
PiA+IHRyb25kbXlAaGFtbWVyc3BhY2UuY29tPiB3cm90ZToNCj4gPiA+ID4gPiANCj4gPiA+ID4g
PiBPbiBUaHUsIDIwMTgtMTItMjcgYXQgMTc6MzQgLTA1MDAsIENodWNrIExldmVyIHdyb3RlOg0K
PiA+ID4gPiA+ID4gPiBPbiBEZWMgMjcsIDIwMTgsIGF0IDU6MTQgUE0sIFRyb25kIE15a2xlYnVz
dCA8DQo+ID4gPiA+ID4gPiA+IHRyb25kbXlAaGFtbWVyc3BhY2UuY29tPiB3cm90ZToNCj4gPiA+
ID4gPiA+ID4gDQo+ID4gPiA+ID4gPiA+IA0KPiA+ID4gPiA+ID4gPiANCj4gPiA+ID4gPiA+ID4g
PiBPbiBEZWMgMjcsIDIwMTgsIGF0IDIwOjIxLCBDaHVjayBMZXZlciA8DQo+ID4gPiA+ID4gPiA+
ID4gY2h1Y2subGV2ZXJAb3JhY2xlLmNvbT4NCj4gPiA+ID4gPiA+ID4gPiB3cm90ZToNCj4gPiA+
ID4gPiA+ID4gPiANCj4gPiA+ID4gPiA+ID4gPiBIaSBUcm9uZC0NCj4gPiA+ID4gPiA+ID4gPiAN
Cj4gPiA+ID4gPiA+ID4gPiBJJ3ZlIGNoYXNlZCBkb3duIGEgY291cGxlIG9mIHJlbWFpbmluZyBy
ZWdyZXNzaW9ucyB3aXRoDQo+ID4gPiA+ID4gPiA+ID4gdGhlDQo+ID4gPiA+ID4gPiA+ID4gdjQu
MjANCj4gPiA+ID4gPiA+ID4gPiBORlMgY2xpZW50LA0KPiA+ID4gPiA+ID4gPiA+IGFuZCB0aGV5
IHNlZW0gdG8gYmUgcm9vdGVkIGluIHRoaXMgY29tbWl0Lg0KPiA+ID4gPiA+ID4gPiA+IA0KPiA+
ID4gPiA+ID4gPiA+IFdoZW4gdXNpbmcgc2VjPWtyYjUsIGtyYjVpLCBvciBrcmI1cCBJIGZvdW5k
IHRoYXQNCj4gPiA+ID4gPiA+ID4gPiBtdWx0aS0NCj4gPiA+ID4gPiA+ID4gPiB0aHJlYWRlZA0K
PiA+ID4gPiA+ID4gPiA+IHdvcmtsb2Fkcw0KPiA+ID4gPiA+ID4gPiA+IHRyaWdnZXIgYSBsb3Qg
b2Ygc2VydmVyLXNpZGUgZGlzY29ubmVjdHMuIFRoaXMgaXMgd2l0aA0KPiA+ID4gPiA+ID4gPiA+
IFRDUA0KPiA+ID4gPiA+ID4gPiA+IGFuZA0KPiA+ID4gPiA+ID4gPiA+IFJETUEgdHJhbnNwb3J0
cy4NCj4gPiA+ID4gPiA+ID4gPiBBbiBpbnN0cnVtZW50ZWQgc2VydmVyIHNob3dzIHRoYXQgdGhl
IGNsaWVudCBpcyB1bmRlci0NCj4gPiA+ID4gPiA+ID4gPiBydW5uaW5nIA0KPiA+ID4gPiA+ID4g
PiA+IHRoZQ0KPiA+ID4gPiA+ID4gPiA+IEdTUyBzZXF1ZW5jZQ0KPiA+ID4gPiA+ID4gPiA+IG51
bWJlciB3aW5kb3cuIEkgbW9uaXRvcmVkIHRoZSBvcmRlciBpbiB3aGljaCBHU1MNCj4gPiA+ID4g
PiA+ID4gPiBzZXF1ZW5jZQ0KPiA+ID4gPiA+ID4gPiA+IG51bWJlcnMgYXBwZWFyIG9uDQo+ID4g
PiA+ID4gPiA+ID4gdGhlIHdpcmUsIGFuZCBhZnRlciB0aGlzIGNvbW1pdCwgdGhlIHNlcXVlbmNl
IG51bWJlcnMNCj4gPiA+ID4gPiA+ID4gPiBhcmUNCj4gPiA+ID4gPiA+ID4gPiB3aWxkbHkNCj4g
PiA+ID4gPiA+ID4gPiBtaXNvcmRlcmVkLg0KPiA+ID4gPiA+ID4gPiA+IElmIEkgcmV2ZXJ0IHRo
ZSBodW5rIGluIHhwcnRfcmVxdWVzdF9lbnF1ZXVlX3RyYW5zbWl0LA0KPiA+ID4gPiA+ID4gPiA+
IHRoZQ0KPiA+ID4gPiA+ID4gPiA+IHByb2JsZW0gZ29lcyBhd2F5Lg0KPiA+ID4gPiA+ID4gPiA+
IA0KPiA+ID4gPiA+ID4gPiA+IEkgYWxzbyBmb3VuZCB0aGF0IHJldmVydGluZyB0aGF0IGh1bmsg
cmVzdWx0cyBpbiBhIDMtNCUNCj4gPiA+ID4gPiA+ID4gPiBpbXByb3ZlbWVudCBpbiBmaW8NCj4g
PiA+ID4gPiA+ID4gPiBJT1BTIHJhdGVzLCBhcyB3ZWxsIGFzIGltcHJvdmVtZW50IGluIGF2ZXJh
Z2UgYW5kDQo+ID4gPiA+ID4gPiA+ID4gbWF4aW11bQ0KPiA+ID4gPiA+ID4gPiA+IGxhdGVuY3kN
Cj4gPiA+ID4gPiA+ID4gPiBhcyByZXBvcnRlZA0KPiA+ID4gPiA+ID4gPiA+IGJ5IGZpby4NCj4g
PiA+ID4gPiA+ID4gPiANCj4gPiA+ID4gPiA+ID4gDQo+ID4gPiA+ID4gPiA+IEhtbeKApiBQcm92
aWRlZCB0aGUgc2VxdWVuY2UgbnVtYmVycyBzdGlsbCBsaWUgd2l0aGluIHRoZQ0KPiA+ID4gPiA+
ID4gPiB3aW5kb3csDQo+ID4gPiA+ID4gPiA+IHRoZW4gd2h5IHdvdWxkIHRoZSBvcmRlciBtYXR0
ZXI/DQo+ID4gPiA+ID4gPiANCj4gPiA+ID4gPiA+IFRoZSBtaXNvcmRlcmluZyBpcyBzbyBiYWQg
dGhhdCBvbmUgcmVxdWVzdCBpcyBkZWxheWVkIGxvbmcNCj4gPiA+ID4gPiA+IGVub3VnaA0KPiA+
ID4gPiA+ID4gdG8NCj4gPiA+ID4gPiA+IGZhbGwgb3V0c2lkZSB0aGUgd2luZG93LiBUaGUgbmV3
IOKAnG5lZWQgcmUtZW5jb2Rl4oCdIGxvZ2ljDQo+ID4gPiA+ID4gPiBkb2VzDQo+ID4gPiA+ID4g
PiBub3QNCj4gPiA+ID4gPiA+IHRyaWdnZXIuDQo+ID4gPiA+ID4gPiANCj4gPiA+ID4gPiANCj4g
PiA+ID4gPiBUaGF0J3Mgd2VpcmQuIEkgY2FuJ3Qgc2VlIGFueXRoaW5nIHdyb25nIHdpdGggbmVl
ZCByZS1lbmNvZGUNCj4gPiA+ID4gPiBhdA0KPiA+ID4gPiA+IHRoaXMNCj4gPiA+ID4gPiBwb2lu
dC4NCj4gPiA+ID4gDQo+ID4gPiA+IEkgZG9uJ3QgdGhpbmsgdGhlcmUgaXMgYW55dGhpbmcgd3Jv
bmcgd2l0aCBpdCwgaXQgbG9va3MgbGlrZQ0KPiA+ID4gPiBpdCdzDQo+ID4gPiA+IG5vdCBjYWxs
ZWQgaW4gdGhpcyBjYXNlLg0KPiA+ID4gDQo+ID4gPiBTbyB5b3UgYXJlIHNheWluZyB0aGF0IHRo
ZSBjYWxsIHRvIHJwY2F1dGhfeG1pdF9uZWVkX3JlZW5jb2RlKCkNCj4gPiA+IGlzDQo+ID4gPiB0
cmlnZ2VyaW5nIHRoZSBFQkFETVNHLCBidXQgdGhhdCB0aGlzIGZhaWxzIHRvIGNhdXNlIGEgcmUt
ZW5jb2RlDQo+ID4gPiBvZg0KPiA+ID4gdGhlDQo+ID4gPiBtZXNzYWdlPw0KPiA+IA0KPiA+IE5v
LCBJIHRoaW5rIHdoYXQncyBnb2luZyBvbiBpcyB0aGF0IHRoZSBuZWVkX3JlZW5jb2RlIGhhcHBl
bnMgd2hlbg0KPiA+IHRoZQ0KPiA+IFJQQyBpcyBlbnF1ZXVlZCwgYW5kIGlzIHN1Y2Nlc3NmdWwu
DQo+ID4gDQo+ID4gQnV0IHhwcnRfcmVxdWVzdF9lbnF1ZXVlX3RyYW5zbWl0IHBsYWNlcyB0aGUg
UlBDIHNvbWV3aGVyZSBpbiB0aGUNCj4gPiBtaWRkbGUNCj4gPiBvZiB4bWl0X3F1ZXVlLiB4bWl0
X3F1ZXVlIGlzIGxvbmcgZW5vdWdoIHRoYXQgbW9yZSB0aGFuIDEyOA0KPiA+IHJlcXVlc3RzDQo+
ID4gYXJlDQo+ID4gYmVmb3JlIHRoZSBlbnF1ZXVlZCByZXF1ZXN0Lg0KPiANCj4gVGhlIHRlc3Qg
Zm9yIHJwY2F1dGhfeG1pdF9uZWVkX3JlZW5jb2RlKCkgaGFwcGVucyB3aGVuIHdlIGNhbGwNCj4g
eHBydF9yZXF1ZXN0X3RyYW5zbWl0KCkgdG8gYWN0dWFsbHkgcHV0IHRoZSBSUEMgY2FsbCBvbiB0
aGUgd2lyZS4gVGhlDQo+IGVucXVldWUgb3JkZXIgc2hvdWxkIG5vdCBiZSBhYmxlIHRvIGRlZmVh
dCB0aGF0IHRlc3QuDQo+IA0KPiBIbW0uLi4gSXMgaXQgcGVyaGFwcyB0aGUgdGVzdCBmb3IgcmVx
LT5ycV9ieXRlc19zZW50IHRoYXQgaXMgZmFpbGluZw0KPiBiZWNhdXNlIHRoaXMgaXMgYSByZXRy
YW5zbWlzc2lvbiBhZnRlciBhIGRpc2Nvbm5lY3QvcmVjb25uZWN0IHRoYXQNCj4gZGlkbid0IHRy
aWdnZXIgYSByZS1lbmNvZGU/DQoNCkFjdHVhbGx5LCBpdCBtaWdodCBiZSB3b3J0aCBhIHRyeSB0
byBtb3ZlIHRoZSB0ZXN0IGZvcg0KcnBjYXV0aF94bWl0X25lZWRfcmVlbmNvZGUoKSBvdXRzaWRl
IHRoZSBlbmNsb3NpbmcgdGVzdCBmb3IgcmVxLQ0KPnJxX2J5dGVzX3NlbnQgYXMgdGhhdCBpcyBq
dXN0IGEgbWlub3Igb3B0aW1pc2F0aW9uLg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXgg
TkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1l
cnNwYWNlLmNvbQ0KDQoNCg==
