Return-Path: <SRS0=saDi=QU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2B62C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 22:02:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 30BAE222A4
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 22:02:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="OPR9e18O"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727894AbfBMWCS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 13 Feb 2019 17:02:18 -0500
Received: from mail-eopbgr690127.outbound.protection.outlook.com ([40.107.69.127]:27008
        "EHLO NAM04-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728440AbfBMWCS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Feb 2019 17:02:18 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=vIjVBGDCJClNSzqqaD/fP5MWHbCrNL0loq/H3s1QLbQ=;
 b=OPR9e18Omi7iYiuGDwSfSN3o714BRbux0w4uSdkWKWJXH5wtN3wZHO2haXZiNmjR+Zb0N5RxYRU/a1ecjkCD6rpFWP9buyfAr0+R68vBelbQcfpepm4TaEGZ4NmgaVJAI8hUJCo5xjl6JhmwYLhOJd5v282IznuKNOg7XrAi6oI=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2574.namprd13.prod.outlook.com (52.135.96.22) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1622.13; Wed, 13 Feb 2019 22:01:35 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::f4e2:9f89:7255:36f0]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::f4e2:9f89:7255:36f0%3]) with mapi id 15.20.1622.016; Wed, 13 Feb 2019
 22:01:35 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFS: Fix I/O request leakages
Thread-Topic: [PATCH 1/2] NFS: Fix I/O request leakages
Thread-Index: AQHUw+bKhucSZxL17ky74sroHTUTe6XeR4+A
Date:   Wed, 13 Feb 2019 22:01:35 +0000
Message-ID: <5ccaed47dece0486f2fb7db9ed9674724affe987.camel@hammerspace.com>
References: <20190213215357.19696-1-trond.myklebust@hammerspace.com>
In-Reply-To: <20190213215357.19696-1-trond.myklebust@hammerspace.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 50429f6d-53bd-4913-60e2-08d691fed224
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2574;
x-ms-traffictypediagnostic: SN6PR13MB2574:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyNTc0OzIzOkRKYnF0RnArbFJEczZpbkpJQXlBbklTaTEw?=
 =?utf-8?B?TzdlaS9aaFFxMW8reGZ1S3RLMGtaVExzKzZxWXRMWDBiKzVsaTR1N3hFWDgr?=
 =?utf-8?B?cHBOWDMvUGxGclFCN0NSRERJOENuOTBwMXZPODQrdkkvc01oWU8rVHlWOXZw?=
 =?utf-8?B?bmFuc1VXVjZhU0MxT1lhU2hBeFpOSzBhdGRSK3IwdUpUNSs4VWlFNWJ4Um44?=
 =?utf-8?B?eWJMUmFxbDRLOUFmWm1TR2phY0FQM09SRi9iUDIvSzYrK204R3BteFFNNWNF?=
 =?utf-8?B?WDdRTE5NOWhXa1g3Z3pPOHdNM0dsZWdiVUI5dVVINmFsa0tXNWhJeTZTVVd3?=
 =?utf-8?B?M25EbExUM1FHS0VpV3JvRDBCbXVPM2pCUE1TUlJ5cWhNYmM4OFNRRnp2UWxF?=
 =?utf-8?B?bmo5RU05b3ZKdjJGNEM0OWtMVzNYZDZmaytDV25tbE51VnA2WFNTMUxQejln?=
 =?utf-8?B?eThoM3M1bU4xVGloZk16MUdzVUM4bXMwS3JXaCtxbUFDeDZ1MFJCaEIzanlv?=
 =?utf-8?B?RUdQUEtPRVpiQWFwU2NTMWhXa05DeHpnUnd4NWhkMXpDU1VkdDFBb29ucjhF?=
 =?utf-8?B?MUhrYlN6TkdaaG5wZ1ptSk1FT3V1V3ZXcHBNa0Z2QTBualFYKzJBNjRTc2ti?=
 =?utf-8?B?ODdiSFprUHlXZkFsSzRFVHNMNmNWTTAwb3d2WWhvRmM4N1IycUFpS0IrRzUv?=
 =?utf-8?B?RTJUYks0N0lJYW9JWW5YUTV0RksxUHgxWk5pSitmTWkvTVZUeng4ZDFSMExT?=
 =?utf-8?B?VVp0emJ4TlVHMnJJMU13MnFyR1FiY1JPL2huREpmdjNUNGp5MUdhcXZldkNI?=
 =?utf-8?B?cExLc21iN1F5alI4VFhVMGhpYUtCUzhWL21zZ21CWWIrOCsyR2I2K0gyblgv?=
 =?utf-8?B?bmVZemlyTTFFU3ZGenVzUnJMRUZ5TUo1VS9RcTBITUM5OXNZV0x6M1EwMGFH?=
 =?utf-8?B?eGtjTFlhNTlGOG5vZi9MUWtwR1cwUk15d3pJSGw5Szc2TGNXTUx1emZEaWNJ?=
 =?utf-8?B?N1NjWFpqNjErZDV3dGpMR2R2UlM0VzZyclloTFZhZWdPN1pEZ2hMdHpCRFRX?=
 =?utf-8?B?aXNhZ0ovcDNkN05NaTZHRkplbEFNZWsycjhDUzZKaFZ4TUVrdVk2dGJJVk9a?=
 =?utf-8?B?RWUzU3M5TzFFWVZKalZMZ0ptbUU1dVdJYUcyR1VjTzNBMEJ2ajZ3MEV2dW9o?=
 =?utf-8?B?TlRtOFJHcmNCamV0aUZOOWMya3YxVXF6ZFhzVGdOTFM4SHU2N1lxQnd6bUsz?=
 =?utf-8?B?c0FMMkE2NW5NRnVpbnlZR1RGNGlZWkFDcHB4cTZId3BVbnhoUjk4SHZ2bjgr?=
 =?utf-8?B?S0N2bGZXRGo4Y05MMHhOY0FXajJ2MTA3aFdla0FFKytaNmt5NmxYVTVIYVRD?=
 =?utf-8?B?aFh4V1ZOOHVoZUZCeDlqeWxwbDBtWWN2d2U4YksyNHlWWlN5SFg1SHE0WE93?=
 =?utf-8?B?Skhad2wyNnBRemFjMTV1L1BadnV1YVVqek41Umw5WEtOT1dSZHdPMUxRLzFM?=
 =?utf-8?B?bi85bEJlU2pnSjNMeUVaWnR2Z056VmUvUWNBQmQ2d2JFMmEwaW5FR3JOcW9S?=
 =?utf-8?B?YzNiM3V3MkhxbTluNnVUbGhNM0xxbzN3NVVBQ0M5Z3pSYmZsYnJPcjdweHJj?=
 =?utf-8?B?OE55V2NUcWZwRE01YnNKRXBVb0lHaFlhekFtK1VZTGdBSU1nSWkwVmRZTnV5?=
 =?utf-8?Q?mpZQY+M8FhK7ys7HtA=3D?=
x-microsoft-antispam-prvs: <SN6PR13MB25742F2846D63DAC8FAE50B1B8660@SN6PR13MB2574.namprd13.prod.outlook.com>
x-forefront-prvs: 094700CA91
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39830400003)(396003)(346002)(376002)(366004)(136003)(199004)(189003)(14454004)(71200400001)(53936002)(26005)(486006)(2351001)(106356001)(71190400001)(4326008)(6246003)(105586002)(186003)(118296001)(478600001)(11346002)(2616005)(97736004)(476003)(6346003)(68736007)(2501003)(6506007)(446003)(102836004)(36756003)(6116002)(3846002)(8676002)(81166006)(6916009)(76176011)(81156014)(86362001)(305945005)(2906002)(8936002)(14444005)(6486002)(66066001)(6512007)(7736002)(229853002)(256004)(6436002)(5640700003)(316002)(25786009)(99286004);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2574;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: F2PXKi+3D7MAtXoSOF3naJJKMVoAIx52B7KCXPBhXKtebsQpggSlkj2Dotrn75IUNzW+XKh5wPUQY9hc1GI8toclxmp7cfK8+airxKVJc+3YETuEmVCVrxQ12BhQQ8CNYvkz8n875iP2FmjPc9kQ7YOtZuqJkF7gbHnh60sua+abvtkTeqYXY/f7enCMW17UYvIdf3cxgup49Ut3OaBbxaq8bU8NRSbQdZfUCs7FCHhcKtaec5tHyxLp8jNjY/1W27Z8uFYdHCu6ZO5/V3Yrt7kzTmY+SZFQCayqm1Gw1/nsi8EUbHxbbaU7m4ZOqNVKgCGeEhs6AFpyvmPy9Aq6hqUdYMob6d4Twck7MlM0Ob4UbOWycWu0fAD3C0IZvjIOj5k/QvNldm3Zr8FRZTmQFpZakPt+gticEagpnR2CqdY=
Content-Type: text/plain; charset="utf-8"
Content-ID: <1FADEE81380BF948A40B382EF21C3F97@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 50429f6d-53bd-4913-60e2-08d691fed224
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Feb 2019 22:01:35.1483
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2574
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgQW5uYSwNCg0KT24gV2VkLCAyMDE5LTAyLTEzIGF0IDE2OjUzIC0wNTAwLCBUcm9uZCBNeWts
ZWJ1c3Qgd3JvdGU6DQo+IFdoZW4gd2UgZmFpbCB0byBhZGQgdGhlIHJlcXVlc3QgdG8gdGhlIEkv
TyBxdWV1ZSwgd2UgY3VycmVudGx5IGxlYXZlDQo+IGl0DQo+IHRvIHRoZSBjYWxsZXIgdG8gZnJl
ZSB0aGUgZmFpbGVkIHJlcXVlc3QuIEhvd2V2ZXIgc2luY2Ugc29tZSBvZiB0aGUNCj4gcmVxdWVz
dHMgdGhhdCBmYWlsIGFyZSBhY3R1YWxseSBjcmVhdGVkIGJ5IG5mc19wYWdlaW9fYWRkX3JlcXVl
c3QoKQ0KPiBpdHNlbGYsIGFuZCBhcmUgbm90IHBhc3NlZCBiYWNrIHRoZSBjYWxsZXIsIHRoaXMg
bGVhZHMgdG8gYSBsZWFrYWdlDQo+IGlzc3VlLCB3aGljaCBjYW4gYWdhaW4gY2F1c2UgcGFnZSBs
b2NrcyB0byBsZWFrLg0KPiANCj4gVGhpcyBjb21taXQgYWRkcmVzc2VzIHRoZSBsZWFrYWdlIGJ5
IGZyZWVpbmcgdGhlIGNyZWF0ZWQgcmVxdWVzdHMgb24NCj4gZXJyb3IsIHVzaW5nIGRlc2MtPnBn
X2NvbXBsZXRpb25fb3BzLT5lcnJvcl9jbGVhbnVwKCkNCj4gDQo+IFNpZ25lZC1vZmYtYnk6IFRy
b25kIE15a2xlYnVzdCA8dHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbT4NCj4gRml4ZXM6
IGE3ZDQyZGRiMzA5OTcgKCJuZnM6IGFkZCBtaXJyb3Jpbmcgc3VwcG9ydCB0byBwZ2lvIGxheWVy
IikNCj4gQ2M6IHN0YWJsZUB2Z2VyLmtlcm5lbC5vcmcgIyB2NC4wKw0KDQpJIGJlbGlldmUgdGhp
cyBwYXRjaCBzaG91bGQgZml4IHRoZSBwYWdlIGxvY2sgbGVhayB0aGF0IEkgbWVudGlvbmVkDQp5
ZXN0ZXJkYXkuIFRoZSBpc3N1ZSBpcyB0aGF0IHdlJ3JlIGNyZWF0aW5nIG5mc19wYWdlIHN0cnVj
dHVyZXMgYXMgcGFydA0Kb2YgYSBwYWdlIGdyb3VwLCBidXQgdGhlbiBhYmFuZG9uaW5nIHRob3Nl
IHN0cnVjdHVyZXMgdG8gdGhlaXIgZmF0ZS4gSXQNCm1lYW5zIHRoYXQgdGhlIGNhbGxzIHRvIG5m
c19wYWdlX2dyb3VwX3N5bmNfb25fYml0KHJlcSwgUEdfVU5MT0NLUEFHRSksDQpuZnNfcGFnZV9n
cm91cF9zeW5jX29uX2JpdChyZXEsIFBHX1dCX0VORCksIGFuZCBldmVuDQpuZnNfcGFnZV9ncm91
cF9zeW5jX29uX2JpdChyZXEsIFBHX1RFQVJET1dOKSBjYW4gbmV2ZXIgc3VjY2VlZCwgYW5kIHNv
DQp3ZSBlbmQgdXAgbGVha2luZywgcGFnZSBsb2NrcywgcGFnZSB3cml0ZWJhY2sgbG9ja3MsIGFu
ZCBuZnNfcGFnZQ0KcmVxdWVzdHMuLi4NCg0KQ2hlZXJzDQogIFRyb25kDQoNCi0tIA0KVHJvbmQg
TXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9u
ZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
