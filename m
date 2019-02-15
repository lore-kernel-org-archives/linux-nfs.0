Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95A22C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 13:24:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2B63221925
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 13:24:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="J1Ax7Hjc"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728465AbfBONYH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 08:24:07 -0500
Received: from mail-eopbgr690122.outbound.protection.outlook.com ([40.107.69.122]:18758
        "EHLO NAM04-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726026AbfBONYH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 08:24:07 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=UKi+1CQF/OthKvGWe8gvLWJKrX0FX+25TncQQvwi0Mc=;
 b=J1Ax7HjcG9o9zHosgTHbTLuW42kCDqtzH3QR5C7jY4/ti79N+SttlSBjY4MTGZ/LPIReEzlyXpX3fcL3LE6PKnk5yFxT3iO+AEaPBwSXFJO/18q3kHe6B7lfJn/tkePrFQCnzM82n3r16L/oOTEvqML29lnfeuYL5whyCgZ2u0w=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2368.namprd13.prod.outlook.com (52.135.94.148) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.7; Fri, 15 Feb 2019 13:24:02 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::f4e2:9f89:7255:36f0]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::f4e2:9f89:7255:36f0%3]) with mapi id 15.20.1622.016; Fri, 15 Feb 2019
 13:24:02 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "jlayton@redhat.com" <jlayton@redhat.com>,
        "wuyihao@linux.alibaba.com" <wuyihao@linux.alibaba.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Why doesn't NFSv3 implement LOOKUPP?
Thread-Topic: Why doesn't NFSv3 implement LOOKUPP?
Thread-Index: AQHUw3fioQrBxA7kyUC8CK1Rhg25wKXdnaIAgAK18gCAAIjoAA==
Date:   Fri, 15 Feb 2019 13:24:01 +0000
Message-ID: <85e8567209e349de91b8c26590924effd344cc37.camel@hammerspace.com>
References: <3dc67361-9c2f-d183-09e5-0a4d5c48d0f7@linux.alibaba.com>
         <0bd905c30a652d19404eef82b40f6b92987ca814.camel@redhat.com>
         <2a2b8156-69c1-ad7f-6000-716f28690fb7@linux.alibaba.com>
In-Reply-To: <2a2b8156-69c1-ad7f-6000-716f28690fb7@linux.alibaba.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 31ec638f-7a09-4cf0-9aec-08d69348d9c7
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605077)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2368;
x-ms-traffictypediagnostic: SN6PR13MB2368:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyMzY4OzIzOkR1R3BzMGVLNGZkZkhxU09DOWNROFVyQWth?=
 =?utf-8?B?VXR2djIzZ2VyVFZCYkd6TExjY09NTmlNdnZ4L25RSG9NQ2trNVVieTA1RGNT?=
 =?utf-8?B?cm5XcmRJK1p0dGpkVGt2SWh3ZlpzUXNsUWhIM1g5NjNYYnpZSC9RNGJleGs0?=
 =?utf-8?B?dE1Nb0dGcHBRYTNGMDhOMGhWSmJleitNcjBic25PUjVmaU5uOGczQTFSdG5y?=
 =?utf-8?B?OU5aMnVwZXdaS3JPYytBMzhoeDFybmovTU9sOUtoWjVCWU03NkQvWU1FVm54?=
 =?utf-8?B?cGRJaTdqV0RQT1U3b3ZRN0p3aHlZZ2o1UmdTSloxYnNCS3RZM1o1NDVVZlZV?=
 =?utf-8?B?b0Vuc3V1Y2VIdFFMM3JqRC9oK3hCUnVuQW0rdmo4bW80SDQxT0kxUDJSQWJp?=
 =?utf-8?B?dXpsUDdvT0ZQTDBKUFpBZmJPWGp1MlIrWHRyWlhjRXJLMG9EZk55aDIrckNM?=
 =?utf-8?B?YUtUeHJJYTdXc3VtSys3ZlNPMm5JbmtXdDRMN0kxNE1TNGJyaDFKV3FkcnV6?=
 =?utf-8?B?YVBubm5HcVNndXdoY2FGVFJOcnpoamY1ZCtvT1F3V1ZpRVh0TUhJRzJsaXRu?=
 =?utf-8?B?ZFlHUnd5b0YwcStkUUd3SVR2RkZjdHJ1Y1NOZmxOTkxPN0RsY2xtUzZrQmlv?=
 =?utf-8?B?RVZtSEh2M0phQVdEa1d2Tm8wYzlmbkxxb2VhV05WNWpKa05YWHhwc25NeUVC?=
 =?utf-8?B?cmp4dGh1VDZMV3NISjc2KzljL0F0bUZ4WndlTEQzQitDTHlIQTQya1RDVUcx?=
 =?utf-8?B?YkFUQ29jV3VodWwxUzdqd2dZLzBUeitzYWo4M1pENzFMZWpXRXpCd3l1aDRu?=
 =?utf-8?B?OTh6ckxvWUlFVWZ2ZGIrWjBTOFNHRkxFc3VQWkdrZ295MFA0UVpzUmFFQWhR?=
 =?utf-8?B?SGhCeTJKcHhTT0ZLbEVsU3h4WFhQclNaa3RGbmhSQkUzMWF0MzErSGppOTJO?=
 =?utf-8?B?T2VsTGhJd2xEUDM5dFhHbDh2MTd3NlBXQ0NUV0lJYm1RYm1TZ2lMckpMcTV1?=
 =?utf-8?B?SUFtaWI4dWpjTVRTZDF6M0diUmVxb0g4K2szenY3aVJpSVVvZWw1UStIdWxJ?=
 =?utf-8?B?MWVPaDNHUlNrWXFtTGVTN2ZIaStQUk10M09BVGJ2Y25XODVUZFNCbUdOV01s?=
 =?utf-8?B?bm5UVjRRU0tuZVhKYUswRFpMSkdDQ3hyRTV4ZVk0KzBNRzhCZmlONi8vQjlu?=
 =?utf-8?B?TVNhRzVZUlBsZkJqL0kvTU1JdSs1NGhFR1VEN1V0OUhnNGFvZ09MbEZmYXQ5?=
 =?utf-8?B?MUdrM01wWndLVVpvMlU2aHhObUUzcHg2RVNXWnhpSGFaVUNyMFhyRXV6Z2NP?=
 =?utf-8?B?STVuVzBiSWRTa0hsUENBSEwxS0dFWE9qR2hhUnkyY3hmZmlVYk1vQ0NUSEJG?=
 =?utf-8?B?TzJ3UEgzNXVHTUxlRWVWNFl2UC93UThmeUxDdDlkVjhGd29qdk1vOHhYRDZ6?=
 =?utf-8?B?b1BMd1ZyNzdRWGY0RllYczdOUlBZS0NHcXU4dkVZMHJab1ZVOFhnOEUxL3FT?=
 =?utf-8?B?dUJvR3lQOFVjMkthWXVQc1ZRK0xZL0F2VWdUTHdLT2N6Y244bFZ1andUdFYr?=
 =?utf-8?B?d1BMMWNhaXk2K0g4WjlPWnd0SGJPMllvZDB5QU0zRlJzak1JcEIzVm51S1Vz?=
 =?utf-8?B?U0MyQldDdFQ1eTk1cElJellEZGpMbm5BTFNUaVMreXBVY3dKcXd2UzlXUWE0?=
 =?utf-8?B?ck1ncVNVRTZHU0hpM29NcVYyMlBJZkVvUDhlSWZ2WjNKOGpxZUdOeDRXSXVN?=
 =?utf-8?B?WnV1bm1hbVAxRk5mNVFwd0YvZGs0ZDdWZjVyZTAzUFZJQ3hJQUF4QmtWbmlv?=
 =?utf-8?Q?fvWVwZpixP+tA?=
x-microsoft-antispam-prvs: <SN6PR13MB2368931318A2F408CDF99466B8600@SN6PR13MB2368.namprd13.prod.outlook.com>
x-forefront-prvs: 09497C15EB
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(979002)(346002)(376002)(136003)(366004)(396003)(39830400003)(189003)(199004)(53754006)(446003)(11346002)(14444005)(256004)(86362001)(36756003)(476003)(2616005)(186003)(68736007)(26005)(53546011)(2201001)(6346003)(6506007)(102836004)(486006)(8936002)(76176011)(7736002)(81156014)(3846002)(81166006)(478600001)(99286004)(14454004)(8676002)(118296001)(305945005)(6116002)(6436002)(229853002)(6512007)(53936002)(2501003)(6246003)(316002)(110136005)(25786009)(6486002)(105586002)(66066001)(106356001)(71190400001)(71200400001)(2906002)(97736004)(969003)(989001)(999001)(1009001)(1019001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2368;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: FDXH3uGJ6JtpA6J3zYGSdes3uyIpbh9YsF8X4IKH9lRxQ60B1Ib4eBYpQQnEP+mYFUF/VepqDjTRgWvGyRrOrN0pRMhKYNGf1LVuXkBQGjhHK3Ac9n6GsD4bEJ8yptHM6E6Hd3P/nFDNLN5v/hRifxWU6rGUzaP07dw+pg0GRZ9FmyJcPjelZOL/KXt2lAQQvbC4AGbEOyf4nWxc7tFt0BnaYUEnlMUeXpR3KEylRleXvOPEzEqFYzbMf4Hm+EDemdp+kr5E0CTOW//RHEFyi4PZ+X+Uqv2fknF3CXfxinL7r6S4MJrcUA1KpQRIofEgd7t9uuKk5ZhGpIZZlTPGrY0bGH5y/PXsuwleE8Z+GkKxdauFXrV4p3cu8yT85285rckUy/D34QizmK2Xr2ZBhDgbVQjVPtD2Pw8m+PSQaAY=
Content-Type: text/plain; charset="utf-8"
Content-ID: <D5DAE357A4609D4D899A108138A624DD@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 31ec638f-7a09-4cf0-9aec-08d69348d9c7
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Feb 2019 13:24:01.8868
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2368
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE5LTAyLTE1IGF0IDEzOjE0ICswODAwLCBZaWhhbyBXdSB3cm90ZToNCj4gT24g
MjAxOS8yLzEzIDc6NTAgUE0sIEplZmYgTGF5dG9uIHdyb3RlOg0KPiA+IE9uIFdlZCwgMjAxOS0w
Mi0xMyBhdCAxNjo0MSArMDgwMCwgWWloYW8gV3Ugd3JvdGU6DQo+ID4gPiBIaSBhbGwsDQo+ID4g
PiANCj4gPiA+IFdoZW4gbG9va2luZyBpbnRvICJGYWlsdXJlczogZ2VuZXJpYy80NjciIGdpdmVu
IGJ5IHhmc3Rlc3RzLCBJDQo+ID4gPiBmb3VuZCB0aGF0IE5GU3YzDQo+ID4gPiBkaWRuJ3QgaW1w
bGVtZW50IExPT0tVUFAuIEkga25vdyB0aGF0IHRoaXMgbWlnaHQgYmUgYnkgZGVzaWduLg0KPiA+
ID4gQnV0IExPT0tVUFAgd2FzDQo+ID4gPiBtZWFudCB0byByZXBsYWNlICIuLiIgaW4gTkZTdjMs
IHJpZ2h0Pw0KPiA+ID4gDQo+ID4gPiB4ZnN0ZXN0cydzIGdlbmVyaWMvNDY3IHRlc3QgY2FzZSBw
ZXJmb3JtcyB0aGUgZm9sbG93aW5nIHNlcXVlbmNlDQo+ID4gPiBvZiBvcGVyYXRpb25zLg0KPiA+
ID4gDQo+ID4gPiBuYW1lX3RvX2hhbmRsZSAtPiBkcm9wX2NhY2hlcyAtPiBvcGVuX2J5X2hhbmRs
ZQ0KPiA+ID4gDQo+ID4gPiBEZW50cnkgYmVjb21lcyBkaXNjb25uZWN0ZWQgZHVlIHRvIGRyb3Bf
Y2FjaGVzLiBORlN2MyBkb2Vzbid0DQo+ID4gPiBzdXBwb3J0IExPT0tVUFAuDQo+ID4gPiBTbyB3
aGVuIGl0IHBlcmZvcm1zIG9wZW5fYnlfaGFuZGxlIHRvIGFuIGRpcmVjdG9yeSwgdGhpcyB0ZXN0
DQo+ID4gPiBjYXNlIGZhaWxzLg0KPiA+ID4gDQo+ID4gPiBJIGRpZCBzb21lIHNtYWxsIGV4cGVy
aW1lbnQgYnkgaW1wbGVtZW50aW5nIExPT0tVUFAgZm9yIE5GU3YzLg0KPiA+ID4gVGhlIHdheSBJ
IHRyaWVkDQo+ID4gPiBpcyB0byBtZXJlbHkgcGFzcyAiLi4iIHRvIG5mczNfcHJvY19sb29rdXAu
IEFuZCBpdCBzZWVtcyB0byB3b3JrLg0KPiA+ID4gQXQgbGVhc3QgaXQncw0KPiA+ID4gYSB3b3Jr
YXJvdW5kIGZvciB4ZnN0ZXN0cy4NCj4gPiA+IA0KPiA+ID4gSSdtIGN1cmlvdXMgd2hldGhlciB0
aGlzIHNvcnQgb2Ygc2ltdWxhdGlvbiBvZiBMT09LVVBQIHdpbGwgd29yaw0KPiA+ID4gb3IgbWFr
ZSBzZW5zZS4NCj4gPiA+IA0KPiA+ID4gVGhhbmtzLA0KPiA+ID4gWWloYW8gV3UNCj4gPiANCj4g
PiB2MyB3YXMgbW9zdGx5IGRlc2lnbmVkIHdpdGggdW5peC1saWtlIGNsaWVudHMgaW4gbWluZC4g
Rm9yIHY0LCB0aGUNCj4gPiBzcGVjDQo+ID4gd3JpdGVycyBjYXN0IGEgd2lkZXIgbmV0IGFuZCBk
ZWNpZGVkIG5vdCB0byBwdXQgc3BlY2lhbCBtZWFuaW5nIG9uDQo+ID4gbG9va3VwcyBvZiAiLiIg
YW5kICIuLiIsIGJ1dCB0aGV5IHN0aWxsIG5lZWRlZCBhIHdheSB0byBkbyBhIGxvb2t1cA0KPiA+
IG9mDQo+ID4gIi4uIi4NCj4gPiANCj4gPiBUaGUgcXVlc3Rpb24gaXMgd2h5IHlvdSB3YW50IHRv
IGltcGxlbWVudCBMT09LVVBQIGluIHYzLiBNb3N0bHkgd2UNCj4gPiBhZGRlZA0KPiA+IGl0IHRv
IHRoZSBjbGllbnQgdG8gc3VwcG9ydCByZWV4cG9ydGluZyBORlN2NCBmaWxlc3lzdGVtcyB2aWEN
Cj4gPiBORlN2My4gQXJlDQo+ID4geW91IGxvb2tpbmcgdG8gcmVleHBvcnQgdjMgZmlsZXN5c3Rl
bXMgZm9yIHNvbWUgcmVhc29uPw0KPiA+IA0KPiANCj4gVGhhbmtzIGEgbG90IGZvciB5b3VyIHJl
cGx5LCBKZWZmIQ0KPiANCj4gSSdtIGp1c3QgbWFuYWdpbmcgdG8gZmlndXJlIG91dCB0aGUgc291
cmNlIG9mIHRoaXMgeGZzdGVzdHMgZmFpbHVyZSwNCj4gdGhhdA0KPiBvcGVuX2J5X2hhbmRsZSBp
cyBzaW1wbHkgbm90IHdvcmtpbmcgZm9yIE5GU3YzIGFmdGVyIGRyb3BfY2FjaGVzLiBJDQo+IHRo
aW5rIE5GU3YzDQo+IG1pZ2h0IGJlY29tZSBhYmxlIHRvIHJlY29ubmVjdF9wYXRoIHRvbywgd2l0
aCBMT09LVVAgIi4uIi4gSG93ZXZlcg0KPiBpdCdzIG5vdCwNCj4gYmVjYXVzZSBuZnNfZ2V0X3Bh
cmVudCBmYWlscyBhcyBsb25nIGFzIExPT0tVUFAgaXMgbm90IHN1cHBvcnRlZC4NCj4gDQo+IE15
IHNlcnZlciAmIGNsaWVudCBib3RoIHN1cHBvcnQgTkZTdjMuIENhbiBJIHRha2UgaXQgdGhhdCBy
ZS0NCj4gZXhwb3J0aW5nIGlzIG5vdCBhDQo+IHJlcXVpcmVkIG9wdGlvbiBpbiB0aGlzIGNhc2U/
DQoNCldoaWxlIGxpbnV4IGNsaWVudCBkb24ndCBnZW5lcmFsbHkgbmVlZCBpdCwgeW91IG1heSB3
YW50IHRvIG5vdGUgdGhhdA0Kc29tZSBub24tbGludXggY2xpZW50cyBkbyBuZWVkIHRvIG1ha2Ug
dXNlIG9mIExPT0tVUCAiLi4iIGluIG9yZGVyIHRvDQpuYXZpZ2F0ZSB0aGUgc2VydmVyJ3MgbmFt
ZXNwYWNlLiBJIGtub3cgdGhhdCB0aGUgU29sYXJpcyBjbGllbnQgZG9lcw0KcmVseSBvbiBpdCwg
YW5kIEkgc3VzcGVjdCB0aGF0IEZyZWVCU0QgZG9lcyB0b28uDQoNCkknZCB0aGVyZWZvcmUgc3Ry
b25nbHkgcmVjb21tZW5kIHRoYXQgeW91IGRvIHN1cHBvcnQgdGhlIExPT0tVUCAiLi4iDQpmdW5j
dGlvbmFsaXR5IGluIHlvdXIgc2VydmVyIGlmIHlvdSBjYXJlIGFib3V0IE5GU3YzIGNsaWVudA0K
aW50ZXJvcGVyYWJpbGl0eS4NCg0KQ2hlZXJzDQogIFRyb25kDQoNCi0tIA0KVHJvbmQgTXlrbGVi
dXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWts
ZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
