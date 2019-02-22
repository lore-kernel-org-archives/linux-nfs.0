Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72959C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 04:06:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 00123207E0
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 04:06:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="gY56995D"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726178AbfBVEGu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Feb 2019 23:06:50 -0500
Received: from mail-eopbgr780119.outbound.protection.outlook.com ([40.107.78.119]:23360
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725961AbfBVEGt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Feb 2019 23:06:49 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=UbYT3HL9hkKSyWv+JHxybJ+Pax3EsnxHfgYcne8pSVw=;
 b=gY56995DC7lZq8ZMmU/z2h2APn/LdL0rNM5/6W+W5srViaxhbyCNGD0XMO3pCnBtczk5UdDTNyl6nhPOJw1RkeTVODfaDmPubA0fMOiSWvBBcY1wHDnp0OY56IHXnu2abICPwV/UXB5Q9vlzaAXafc492ZKgKmacROCcQFOjuPQ=
Received: from BYAPR13MB2486.namprd13.prod.outlook.com (52.135.230.12) by
 BYAPR13MB2261.namprd13.prod.outlook.com (52.135.228.155) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.11; Fri, 22 Feb 2019 04:06:45 +0000
Received: from BYAPR13MB2486.namprd13.prod.outlook.com
 ([fe80::99c9:6baf:9e05:7b1]) by BYAPR13MB2486.namprd13.prod.outlook.com
 ([fe80::99c9:6baf:9e05:7b1%5]) with mapi id 15.20.1665.006; Fri, 22 Feb 2019
 04:06:45 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "neilb@suse.com" <neilb@suse.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Another OPEN / OPEN_DOWNGRADE race
Thread-Topic: Another OPEN / OPEN_DOWNGRADE race
Thread-Index: AQHUyknDrOo848w8v0GuYj32XpMMvqXrM2qA
Date:   Fri, 22 Feb 2019 04:06:44 +0000
Message-ID: <b09d70c86e962a93555b30ead4d1c283c43198b7.camel@hammerspace.com>
References: <874l8wwsed.fsf@notabene.neil.brown.name>
In-Reply-To: <874l8wwsed.fsf@notabene.neil.brown.name>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 83f48b2c-9e69-40dd-f2d2-08d6987b28f1
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR13MB2261;
x-ms-traffictypediagnostic: BYAPR13MB2261:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtCWUFQUjEzTUIyMjYxOzIzOlNoenBQbVNsODJRSVVnTTZTa3RUZjd2OVdw?=
 =?utf-8?B?eTRHWVNhWHFCVmt4VHdjTFViSU1JYzVhdUFSMjlOZm5BT3Q5N25PL0UzM3RG?=
 =?utf-8?B?RlcwY3BLcGdpNllqdXV2VE5pQ2RxR2hkbXRnbVhGb0hTZUFPWVQ3MHgxOFZv?=
 =?utf-8?B?a25JSFg5KzVtLy9rODQ5cGZNMjAxYXp5NjVQUk90V2o0eFFRSittWUtSeGps?=
 =?utf-8?B?bmFLZks5Wlp1d2ZXRnpxb0IyMFYydDc1OUpFaHllb1BlODYzNHE0Sk9RWlBy?=
 =?utf-8?B?VVkyNUVhMHB3MDd5TjNxdzhRQ205c1ZtWkY2TjQ3QWlaa1EvanN3MVpCYmRQ?=
 =?utf-8?B?ODk1Y1BQNTV5NGxNU1lXVG8wZm1pMHBYaGtEbThHb2VUcHA2ZzlTM0gxaGVO?=
 =?utf-8?B?c3pnNHBUMVNOWjVhVEdNam9NMkEweFFXMklZQlB0dlU1VzZGVjAwU2tBN3Ev?=
 =?utf-8?B?SlRrNk9peGlKWXBScDI4MHpKc1M0cWpWUExZeGNFM2h4ektkNzlvOVVYQlBP?=
 =?utf-8?B?R0ZlQ3d0QzMvbnlnNlJtR0hUU0dvU0xsY2J0Wkt3Y2E1MVJWSVhoRVRlUjhT?=
 =?utf-8?B?TzdjSysycmdZSEZ0TVA2MGUrU1lpNXhPOUpqUW4wQkpBcEc2cmt0bVM5dkpt?=
 =?utf-8?B?SlJhNjQzcDFJbDhlR2FmVzBEUWp3V2FVbVd3S05rcVdjcUFGUm9MN1FteGZn?=
 =?utf-8?B?YUJma3FqbmdVNDhPRGhLNnNhc1R3blF3ZWVkSnIxcnMva2NLUWZqdDJQY0w4?=
 =?utf-8?B?QTUrMVJYYVVZcDE3TkZJWExqTHVwL050SWxMR3JvWnhnYkhMQjUyV2hVc1Jy?=
 =?utf-8?B?WjBzNkFoQW9TUnJrSUE1cFFxY1BtdkorZWFoN1huQ0NJZ3hHNHN1KzYvZjcz?=
 =?utf-8?B?NjI5cjg4VmhQY25lOHNnaVR3QVlFYVdrMGdhVFZFQ1pGQ0I5VWNpZFRpbkpl?=
 =?utf-8?B?ejVUNjZYL0txd0FrenR6bGJVM1VUZzFWTWFnNm9lWG9ja3JVa0NzSXVFNFNS?=
 =?utf-8?B?ekJ2RGtvRkUvek4rUkVxamo5dlhiSjBkMmpKQmtSQnFjMlp3M1Qwc0JLM0dG?=
 =?utf-8?B?bjAyQWovUmF6cURyVnkvc2d4SU1waG5Zd0kyNVVzeGZqVkloeU1JbER3TjR6?=
 =?utf-8?B?dkJKUnRCRHp5a3FZaVlEbUNyT2g0d1R1em5vakpEQkx5NVU2V2RVbE5sMlN4?=
 =?utf-8?B?OEVHeW9wZTFVSXBQSURjU1BqQmRiU2hMYWRGcTZqdG82RFkyM3RmczRFL2Iy?=
 =?utf-8?B?OFpGLzc5ZWUyYURCTFVhT3lia1BaWldtWXFxcVJWUXh4bjJnY1IzZzdWT2hV?=
 =?utf-8?B?bUN0MFNQRTBYVUp0ZFpmNXlxd2VVdjhWOGRlN2Q0NlkzamlUYm9yN2hjaXFa?=
 =?utf-8?B?NWc0MkJRSzJJdmZCai9FV3JxeUlnU09tSlJmemtKU29FV1VQeE1oQWZ0ODdC?=
 =?utf-8?B?cU9Sc3JkSlE3NHNrUmE2TlBoa205c2ZmMUNaUEZseTFscTZUWE9FMXRqV0kv?=
 =?utf-8?B?UlViQXcxenNadUpsRTJuc1BpZHhIeFNkQ2R5VnhmaWhqOVUvbTcrQjd0WmlH?=
 =?utf-8?Q?GO40p1Gd4P/nH9QNmxbw9Ln3qByogJzbFQRL1taeihic=3D?=
x-microsoft-antispam-prvs: <BYAPR13MB2261AB8B42AF6E90AC04E8FBB87F0@BYAPR13MB2261.namprd13.prod.outlook.com>
x-forefront-prvs: 09565527D6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(136003)(376002)(396003)(39830400003)(346002)(189003)(199004)(6512007)(2501003)(8936002)(2906002)(106356001)(68736007)(105586002)(3846002)(6116002)(6436002)(305945005)(7736002)(14454004)(8676002)(81156014)(86362001)(36756003)(53936002)(316002)(110136005)(97736004)(81166006)(6486002)(118296001)(99286004)(186003)(102836004)(6246003)(66066001)(76176011)(25786009)(6506007)(478600001)(229853002)(486006)(5660300002)(26005)(71190400001)(71200400001)(446003)(11346002)(2616005)(476003)(14444005)(256004);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR13MB2261;H:BYAPR13MB2486.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: FD+SLjdklw8XqJdgZ1PIoOdKI34TCTYE1PMXvSEcs7rQKl01pwoAe9ChNLNE7s8Pkv7Kmj2dlfX9tSTkjGv2wf6eFm4fFViXhrk3MHbGgZOZy+tRucvGnsnrMZE8uMexBqvURXuY9FSNcf4CrLxX18AyTPqmmp5ggsvKVKvNz3/9npS+3WNn+TcyfTgCiJ1YwI9enTKTAvBYXg3uiYAcvHOdMHRFh7d8nhEBWGCLExXD+0P/iyEoLA3jDp+H45XVuPLqBFzZHDycDIw+5ZQYsYaDpok9Q4zwiK/lDke2+UqEilpr7n8iX/puuIgKFnFIcSwCG8rPH2fXD2k5XPlm/h7FzAA8tPKWTuACsMD/CaPH+mp+E3TuZtgOjnM3plET09u3nmjPBIVmvpHZ0ijkhYfRYB63AOy+Lp5qNJwXR5A=
Content-Type: text/plain; charset="utf-8"
Content-ID: <E596F8999929204F85AF20A34A95664D@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 83f48b2c-9e69-40dd-f2d2-08d6987b28f1
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Feb 2019 04:06:45.1896
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR13MB2261
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgTmVpbA0KDQpPbiBGcmksIDIwMTktMDItMjIgYXQgMTE6NTggKzExMDAsIE5laWxCcm93biB3
cm90ZToNCj4gSGksDQo+ICBJIGhhdmUgYSByZXBvcnQgb2YgYW4gTkZTdjQuMSBzdGF0ZSBtYW5h
Z2VtZW50IHByb2JsZW0gaW4gb3VyIDQuNA0KPiAga2VybmVsIHdoaWNoIGFwcGVhcnMgdG8gYmUg
Y2F1c2VkIGJ5IGEgcmFjZSBiZXR3ZWVuIE9QRU4gYW5kDQo+ICBPUEVOX0RPV05HUkFERSwgYW5k
IEkgZG9uJ3QgdGhpbmsgdGhlIHJhY2UgaXMgZml4ZWQgaW4gbWFpbmxpbmUuDQo+IA0KPiAgVGhl
IHRlc3QgcHJvZ3JhbSBjcmVhdGVzIG11bHRpcGxlIHRocmVhZHMgd2hpY2ggb3BlbiBhIGZpbGUg
T19SRFdSDQo+IGFuZA0KPiAgd3JpdGUgdG8gaXQsIHRoZW4gb3BlbnMgZm9yIE9fUkRPTkxZIGFu
ZCByZWFkcyBmcm9tIGl0Lg0KPiAgQSBuZXR3b3JrIHRyYWNlIHdoaWNoIHNob3dzIHRoZSBwcm9i
bGVtIHN1Z2dlc3RzIHRoYXQgYXQgYSBwb2ludCBpbg0KPiAgdGltZSB3aGVyZSB0aGVyZSBhcmUg
c29tZSBPX1JET05MWSBvcGVucyBhbmQgb25lIE9fUkRXUiBvcGVuLCBhIG5ldw0KPiAgT19SRFdS
IG9wZW4gaXMgcmVxdWVzdGVkIGp1c3QgYXMgdGhlIE9fUkRXUiBvcGVuIGlzIGJlaW5nIGNsb3Nl
ZC4NCj4gDQo+ICBUaGUgY2xvc2Ugb2YgdGhlIE9fUkRXUiBjbGVhcnMgc3RhdGUtPm5fcmR3ciBl
YXJseSBzbw0KPiBjYW5fb3Blbl9jYWNoZWQoKQ0KPiAgZmFpbHMgZm9yIHRoZSBPX1JEV1Igb3Bl
biwgYW5kIGl0IG5lZWRzIHRvIGdvIHRvIHRoZSBzZXJ2ZXIuDQo+ICBUaGUgb3BlbiBmb3IgT19S
RFdSIGRvZXNuJ3QgaW5jcmVtZW50IG5fcmR3ciB1bnRpbCBhZnRlciB0aGUgb3Blbg0KPiAgc3Vj
Y2VlZHMsIHNvIG5mczRfY2xvc2VfcHJlcGFyZSBzZWVzDQo+ICAgICBuX3Jkd3IgPT0gMA0KPiAg
ICAgbl9yZG9ubHkgPiAwDQo+ICAgICBORlNfT19SRFdSX1NUQVRFIGFuZCBORlNfT19SRE9OTFlf
U1RBVEUgc2V0DQo+ICB3aGljaCBjYXVzZXMgaXQgdG8gY2hvb3NlIGFuIE9QRU5fRE9XTkdSQURF
Lg0KPiANCj4gIFdoYXQgd2Ugc2VlIGlzIGEgT1BFTi9zaGFyZS1hbGwgYW5kIGFuIE9QRU5fRE9X
TkdSQURFL3NoYXJlLXJlYWQNCj4gIHJlcXVlc3QgYXJlIHNlbnQgb25lIGFmdGVyIHRoZSBvdGhl
ciB3aXRob3V0IHdhaXRpbmcgZm9yIGEgcmVwbHkuDQo+ICBUaGUgT1BFTiBpcyBwcm9jZXNzZWQg
Zmlyc3QsIHRoZW4gdGhlIE9QRU5fRE9XTkdSQURFLCByZXN1bHRpbmcgaW4gYQ0KPiAgc3RhdGUg
dGhhdCBvbmx5IGFsbG93cyByZWFkcy4gIFRoZW4gYSBXUklURSBpcyBhdHRlbXB0ZWQgd2hpY2gN
Cj4gZmFpbHMuDQo+ICBUaGlzIGVudGVycyBhIGluZmluaXRlIGxvb3Agd2l0aCAyIHN0ZXBzOg0K
PiAgIC0gYSBXUklURSBnZXRzIE5GUzRFUlJfT1BFTk1PREUNCj4gICAtIGEgVEVTVF9TVEFURUlE
IHN1Y2NlZWRzDQo+IA0KPiAgT25jZSBhbiBPUEVOL3NoYXJlLWFsbCByZXF1ZXN0IGhhcyBiZWVu
IHNlbnQsIGl0IGlzbid0IHJlYWxseQ0KPiBjb3JyZWN0DQo+ICB0byBzZW5kIGFuIE9QRU5fRE9X
TkdSQURFL3NoYXJlLXJlYWQgcmVxdWVzdC4gIEhvd2V2ZXIgdGhlIGZhY3QgdGhhdA0KPiAgdGhl
IE9QRU4gaGFzIGJlZW4gc2VudCBpc24ndCB2aXNpYmxlIHRvIG5mczRfY2xvc2VfcHJlcGFyZSgp
Lg0KPiANCj4gIFRoZXJlIGlzIGFuIGFzeW1tZXRyeSBiZXR3ZWVuIG9wZW4gYW5kIGNsb3NlIHcu
ci50LiB1cGRhdGluZyB0aGUNCj4gIG5fW21vZGVdIGNvdW50ZXIgYW5kIHNldHRpbmcgdGhlIE5G
U19PX21vZGVfU1RBVEUgYml0cy4NCj4gDQo+ICBGb3IgY2xvc2UsIHRoZSBjb3VudGVyIGlzIGRl
Y3JlbWVudGVkLCB0aGVuIHRoZSBzZXJ2ZXIgaXMgdG9sZCwgdGhlbg0KPiAgdGhlIHN0YXRlIGJp
dHMgYXJlIGNsZWFyZWQuDQo+ICBGb3Igb3BlbiwgdGhlIGNvdW50ZXIgYW5kIHN0YXRlIGJpdHMg
YXJlIGJvdGggY2xlYXJlZCBhZnRlciB0aGUNCj4gc2VydmVyDQo+ICBpcyBhc2tlZC4NCj4gDQo+
ICBJIHVuZGVyc3RhbmQgdGhhdCB0aGlzIGlzIHByb2JhYmx5IGJlY2F1c2UgdGhlIE9QRU4gY291
bGQgZmFpbCwgYW5kDQo+ICBpbmNyZW1lbnRpbmcgYSBjb3VudGVyIGJlZm9yZSB3ZSBhcmUgc3Vy
ZSBvZiBzdWNjZXNzIHNlZW1zDQo+IHVud2lzZS4gIEJ1dA0KPiAgZG9pbmcgc28gd291bGQgYWxs
b3cgdXMgdG8gYXZvaWQgdGhlIGluY29ycmVjdCBPUEVOX0RPV05HUkFERS4NCj4gDQo+ICBBbnkg
c3VnZ2VzdGlvbnMgb24gd2hhdCBhIGdvb2Qgc29sdXRpb24gd291bGQgbG9vayBsaWtlPyAgRG9l
cyBpdA0KPiBldmVyDQo+ICBtYWtlIHNlbnNlIGZvciBhbiBPUEVOIHJlcXVlc3QgdG8gYmUgY29u
Y3VycmVudCB3aXRoIGEgQ0xPU0Ugb3INCj4gIE9QRU5fRE9XTkdSQURFID8/ICBNYXliZSB0aGV5
IHNob3VsZCBiZSBzZXJpYWxpemVkIHdpdGggZWFjaCBvdGhlcg0KPiAgKG1heWJlIG5vdCBhcyBm
dWxseSBzZXJpYWxpemVkIGFzIE5GU3Y0LjAsIGJ1dCBtb3JlIHRoYW4gdGhleQ0KPiBjdXJyZW50
bHkNCj4gIGFyZSBpbiBORlN2NC4xKQ0KDQpJZiB0aGUgQ0xPU0UvT1BFTl9ET1dOR1JBREUgaXMg
cHJvY2Vzc2VkIGJ5IHRoZSBzZXJ2ZXIgX2FmdGVyXyB0aGUNCk9QRU4sIHRoZW4gdGhlIHN0YXRl
aWQgcHJlc2VudGVkIGJ5IHRoZSBjbGllbnQgd2lsbCBoYXZlIGFuIGluY29ycmVjdA0Kc2VxaWQs
IGFuZCBzbyB0aGUgc2VydmVyIHNob3VsZCByZWplY3QgdGhlIG9wZXJhdGlvbiB3aXRoIGENCk5G
UzRFUlJfT0xEX1NUQVRFSUQuDQoNCklmLCBvbiB0aGUgb3RoZXIgaGFuZCwgdGhlIENMT1NFL09Q
RU5fRE9XTkdSQURFIGlzIHByb2Nlc3NlZCBiZWZvcmUgdGhlDQpPUEVOLCB0aGVuIHRoZSBjbGll
bnQgc2hvdWxkIGVpdGhlciBzZWUgYSBuZXcgc3RhdGVpZCB3aXRoIGEgbmV3DQonb3RoZXInIGZp
ZWxkIChDTE9TRSkgb3IgaXQgd2lsbCBzZWUgdGhlIHNhbWUgc3RhdGVpZCBidXQgd2l0aCBhIHNl
cWlkDQp0aGF0IGRvZXMgbm90IG1hdGNoIHdoYXQgaXQgZXhwZWN0cyAoT1BFTl9ET1dOR1JBREUp
LiBJbiB0aGUgY3VycmVudA0KbWFpbmxpbmUgY29kZSwgdGhlIGNsaWVudCB3aWxsIHRoZW4gYXR0
ZW1wdCB0byB3YWl0IGZvciBhbnkgIm1pc3NpbmciDQpzZXFpZHMgdG8gZ2V0IHByb2Nlc3NlZCAo
c2VlIG5mc19zZXRfb3Blbl9zdGF0ZWlkX2xvY2tlZCgpKS4NCg0KQ2hlZXJzDQogIFRyb25kDQoN
Ci0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1l
cnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
