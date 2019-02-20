Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF6F2C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 12:17:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 485672147A
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 12:17:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Rtrppp8S"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726360AbfBTMRD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 07:17:03 -0500
Received: from mail-eopbgr740120.outbound.protection.outlook.com ([40.107.74.120]:7360
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726317AbfBTMRD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Feb 2019 07:17:03 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=fWmAmddIncysKM5l0Xa/4BOV/Almz6oA9gY9oJYTtUU=;
 b=Rtrppp8SgPrlvOZTYGD7w1jJ0RDgw7G6jfVHYsaeH3qxBTbvL+HhmyAl9/L+rt95kKUxGvtigh2acrDL0FhDLR950g8h7+jSKttcqDrFhN733pBrGZtiYbuB3FVavHDt58rXcRm9VPEKLXrlGK5ytwnzXK+YjojGjck+ViO6avg=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2351.namprd13.prod.outlook.com (52.135.94.141) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.11; Wed, 20 Feb 2019 12:16:58 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%3]) with mapi id 15.20.1643.012; Wed, 20 Feb 2019
 12:16:58 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "cuiyue-fnst@cn.fujitsu.com" <cuiyue-fnst@cn.fujitsu.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: open_by_handle_at() cannot open file after drop_caches
Thread-Topic: open_by_handle_at() cannot open file after drop_caches
Thread-Index: AQHUyQAbFFWkwEkWfUmq1GnPMt0MnaXomlcA
Date:   Wed, 20 Feb 2019 12:16:58 +0000
Message-ID: <e60f1ee83c85cae5b02bbd2d00db62ab289455a7.camel@hammerspace.com>
References: <e703a3e1-64b9-c225-0087-f29d4d2915de@cn.fujitsu.com>
In-Reply-To: <e703a3e1-64b9-c225-0087-f29d4d2915de@cn.fujitsu.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 1219e3e7-b679-405a-b360-08d6972d4fbc
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2351;
x-ms-traffictypediagnostic: SN6PR13MB2351:
x-ms-exchange-purlcount: 1
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyMzUxOzIzOlVRL1I0NEtKZHd3a09GSmJHV3dCc3I2MjFw?=
 =?utf-8?B?cktXR1oyblU1TW03UHVXcExEZHdXOGhFMUZtWDhhL1NLdDdIT29tU2g3MVNj?=
 =?utf-8?B?bWJYQmJPUm5ZckFYTmh4VkZZejR3UndsWUl0b1R2Q2kycHhpaklpN0FDMmZW?=
 =?utf-8?B?OHhUYTB5clg4TnF4OE1TdnB4bkZqNUxIOFl3UEIvYmlGREd2Z3Arc1BLYm9l?=
 =?utf-8?B?TytqYVdKSHpPVHZGMGZMZWVOcFczdHdnMGJiakpyYm1xZHY0elF5NlEweENC?=
 =?utf-8?B?VnlOVExSUGR1K1VlOVlKK1BuaExMRkc3Z0RXNzFRQ3VoRjF3aDd0cGdzUlps?=
 =?utf-8?B?b0Q2S3d6VFJRZzN0MC9FY3VwbTh3QlRJYnVMM3hGQjdnYk1LeTR6eTVOc0pT?=
 =?utf-8?B?MjRENzFScnppdlRoV2pMeU1mV2Nqbm1iOS8xL0hrdm5KTWNXQmdLYzM5UllG?=
 =?utf-8?B?OFVxeEMzZmlqcU5pMUJYd3cxaGhWdTk5MlhEak9qeGx0bElwSlpEUVBOZmxY?=
 =?utf-8?B?S0NoYVFwVzJKWTFGc25abXY4aGIwUWV3ZHV5bGNzQXJiRWZyM3FrRVFPZk9N?=
 =?utf-8?B?Z25QRldpNktkYjd4bzVIcnZJU1BQNTJkeDBUajBYVEdSb2pUMzRud0NYQUlq?=
 =?utf-8?B?cytmckFNcmR5Y1BFNVpEcjlnNjVFbXR4N0x2N1M2NzJtdDdMbi9CMit5UDlU?=
 =?utf-8?B?bHRLdk1Zck13UStuUTZTdEdjRjZoT0xwYmJkOFR2Wm9HT1VhSk94OFdaaElp?=
 =?utf-8?B?NG1GM0JaWjQ0UjZZRUFXeFpsMlN6WkZMRG04WVlMY25pOTEwUXpPeUFocTJo?=
 =?utf-8?B?NDlpbFR1M21EbEVJczBIWHkySGxPMEV2V2lFOVYvaW1MVHF5T2VqaER6SVJF?=
 =?utf-8?B?SkNvR1hSeXBSTTVhbG9HdDhlclA0SExjWDU5b0ZVMmt1bXFKenBld2pwSmlu?=
 =?utf-8?B?TzJsazlNcVBFWGFaK2JwSHMySTdPZ0ROZ29UQWtOOThGZTl4R3R4M0FSQzFt?=
 =?utf-8?B?K2N5Qmsva2RCVUZIN3dzYW10aFU5UkJTUTlVVk5STmhkVExVb1paeXVSd3po?=
 =?utf-8?B?UnV5WHJFdzhwU0tmcExBU1U1a0ttRlh5YlNGK0tHVENqMCtIT3p0Y1RENjRp?=
 =?utf-8?B?d3RvcC94QVczZnhjU0FZREJXTVAxb2YwbnRtNlp2M3VUNnNzeUZQZ2lVWC80?=
 =?utf-8?B?SHBZMDhWYTBFMGxWNGVjU05yZS9scGE0VVIyU3pmdTlkSFpmdkVBQjZtaEFU?=
 =?utf-8?B?aUJnclR6M3ZWeWVMZzdycW5jT3ZhaGtEMkk4NUxRK3ZsNk1UbWlhWDlOZk9v?=
 =?utf-8?B?NlpVUHIvMk00Mmx5MThaQWxRMmR6ZWF0QWE5V3ZlQmFYZEFnZ0x6ZTh1cnF5?=
 =?utf-8?B?SWd4NFFHdUkrNmlENkVvV0djbURSbjVIN0VxMzUwaklPUWw2Ry9rOHcxekxu?=
 =?utf-8?B?ZHhBYWpRVXc0R2pVOFd3K253U3VqK3hBdUpaTndYVEZEMldjQzhEYTdPa2ZT?=
 =?utf-8?B?TUZIeXN6bVJZT2NjeWkvay8vNlZSVTEzNGhBZGc5cXU4Vk5MZnhHUCtFcVN5?=
 =?utf-8?B?ZndScnRmTmF6bTZRSTZTR01nN2ZqQ09yQjM3bmF1ejhxdEtvUi9Hdmo0NVFY?=
 =?utf-8?Q?HDScJXmlWdEC/UCr9n7+?=
x-microsoft-antispam-prvs: <SN6PR13MB235193F5A79D340435DD217FB87D0@SN6PR13MB2351.namprd13.prod.outlook.com>
x-forefront-prvs: 0954EE4910
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(396003)(39830400003)(136003)(376002)(366004)(199004)(189003)(186003)(86362001)(53936002)(305945005)(446003)(105586002)(2501003)(106356001)(71200400001)(71190400001)(2906002)(7736002)(102836004)(26005)(81156014)(8676002)(6506007)(68736007)(76176011)(81166006)(8936002)(36756003)(118296001)(3846002)(6116002)(110136005)(486006)(6512007)(316002)(99286004)(14454004)(6486002)(25786009)(6306002)(2616005)(256004)(476003)(6246003)(6436002)(229853002)(11346002)(478600001)(66066001)(966005)(97736004)(5660300002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2351;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: O+foxQfJ7K9120M7M5Mp98GUW1b43UBSJmoSU8XpFhp36eTJl/VBku29RzOkCS1h5SpGvLC6wUztwnldvxsea4j4xP3pD0Y8lPVnh7WDsdzphBQcM7fwJ0PMtvfPC7k9h+TITxcZgfdq6qpr5WSt24zGjWowhzb5P/zCZU9NmylRbj8LQuRh94BLYVu6L6sc7gv179zj8GecOSKAuDCAI9HlqBIB0CLTXqKkBifm8ksjy85Gyy4kFHPa4xh5jz8Sl7S2bKwmHCx5gkXWnJxD1jdKi9TfW9GzJV+JxrqZSPA/54xD19OaSe5a0Tbs6YyrpHt6rH/Ir35we2DHVSyNj7oJxJ+T7OlcuLc0bErHlZ8h5Dn9ilRqeiFCXgLjKIUjJTMT/cIQgcXR5PYpGkYPpu90Jr0U9eiUPaZ7rKvySTU=
Content-Type: text/plain; charset="utf-8"
Content-ID: <0155832F4730564D900F140B839EBA66@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 1219e3e7-b679-405a-b360-08d6972d4fbc
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Feb 2019 12:16:58.4401
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2351
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gV2VkLCAyMDE5LTAyLTIwIGF0IDE3OjM4ICswODAwLCBDdWksIFl1ZS/ltJQg5oKmIHdyb3Rl
Og0KPiBIaSwNCj4gDQo+IFdoZW4gSSB0ZXN0ZWQgeGZzdGVzdC9nZW5lcmljLzQyNiB3aXRoIE5G
U3Y0LjAsIGl0IGZhaWxlZC4uDQo+IA0KPiBUaGUgdGVzdCBzdGVwcyBhcmUgYXMgZm9sbG93czoN
Cj4gDQo+IDEuIFVzZSBuYW1lX3RvX2hhbmRsZV9hdCgpIHRvIGNoYW5nZSB0aGUgZmlsZW5hbWUg
dG8gZmlsZWhhbmRsZS4NCj4gDQo+IDIuIEV4ZWN1dGUgImVjaG8gMyA+IC9wcm9jL3N5cy92bS9k
cm9wX2NhY2hlcyIuDQo+IA0KPiAzLiBVc2Ugb3Blbl9ieV9oYW5kbGVfYXQoKSB0byBvcGVuIGZp
bGVzIHdpdGggdGhlIGZpbGVoYW5kbGUgY3JlYXRlZCANCj4gYnlzdGVwIDEuDQo+IA0KPiBTdGVw
IDMgY2FsbHMgbmZzX2ZoX3RvX2RlbnRyeSgpIHRvIGNvbnZlcnQgdGhlIGZpbGVoYW5kbGUgdG8g
ZGVudHJ5Lg0KPiANCj4gQnV0IGJlY2F1c2UgdGhlIGlub2RlIGFuZCBkZW50cnkgY2FjaGUgaW5m
b3JtYXRpb24gd2FzIGRlbGV0ZWQgaW4NCj4gc3RlcCANCj4gMiwgYSBuZXcgaW5vZGUgaXMgZ2Vu
ZXJhdGVkIHVzaW5nIHRoZSBuZnNfZmhnZXQoKS4NCj4gDQo+IEFuZCB0aGVuIGEgbmV3IGRlbnRy
eSBpcyBnZW5lcmF0ZWQgdXNpbmcgdGhlIGRfb2J0YWluX2FsaWFzKCkuDQo+IA0KPiBIb3dldmVy
LCBkdXJpbmcgdGhlIGNhbGwgdG8gdGhlIGRfb2J0YWluX2FsaWFzKCkgZnVuY3Rpb24sIHRoZQ0K
PiBkX2luYW1lIA0KPiBvZiB0aGUgZGVudHJ5IGlzIGFzc2lnbmVkIHRoZSBzbGFzaF9uYW1lIi8i
Lg0KPiANCj4gTmZzZCB3aWxsIGNoZWNrIHRoZSBkZW50cnkncyBkX2luYW1lLCB3aGVuIG9wZW4g
Y2xhaW0gdHlwZSBpcyANCj4gTkZTNF9PUEVOX0NMQUlNX05VTEwuDQo+IA0KPiBTbyB3aGVuIGRl
bnRyeSdzIGRfaW5hbWVpcyAiLyIsIGl0IGZhaWxzIHdpdGggdGhlIGVycm9yDQo+ICJuZnNlcnJf
YmFkbmFtZSINCj4gDQo+IFNvIEkgd2FudCB0byBrbm93IHdoeSB0aGUgbmV3bHkgY3JlYXRlZCBk
ZW50cnkgaXMgbmFtZWQgIi8iLA0KPiANCj4gYW5kIHdoZW4gdXNpbmcgb3Blbl9ieV9oYW5kbGVf
YXQoKSB0byBvcGVuIGEgZmlsZSwgaXMgaXQgcG9zc2libGUgdG8NCj4gc2V0IA0KPiB0aGUgY2xh
aW0gdHlwZSB0byBORlM0X09QRU5fQ0xBSU1fUFJFVklPVVMgPw0KDQpUaGF0IHdvdWxkIGJyZWFr
IE5GU3Y0LjAgc3VwcG9ydC4NCg0KU2VydmVycyBhcmUgZXhwZWN0ZWQgdG8gcmV0dXJuIE5GUzRF
UlJfTk9fR1JBQ0UgaWYgeW91IHRyeSB0byB1c2UNCk5GUzRfT1BFTl9DTEFJTV9QUkVWSU9VUyBp
biBhIHNpdHVhdGlvbiB0aGF0IGRvZXMgbm90IGludm9sdmUgcmVib290DQpyZWNvdmVyeS4gTW9z
dCBvZiB0aGVtIGFsc28gcmVseSBvbiBjbGllbnRzIG5vdCBhYnVzaW5nIHJlY2xhaW0NCm9wZXJh
dGlvbnMgdG8gb2J0YWluIG5ldyBzaGFyZSBsb2NrcyB3aGVuIHRoZSBzZXJ2ZXIgaXMgaW4gdGhl
IGdyYWNlDQpwZXJpb2QuDQoNClRoZSBpc3N1ZSBpcyB0aGF0IE5GU3Y0LjAgaGFzIG5vIHJlbGlh
YmxlIHN1cHBvcnQgZm9yIG9wZW4gYnkNCmZpbGVoYW5kbGUuIFRoYXQgY29uY2VwdCB3YXMgZmly
c3QgaW50cm9kdWNlZCBpbiBORlN2NC4xIHdpdGggdGhlDQonQ0xBSU1fRkgnIGFyZ3VtZW50IChz
ZWUgIA0KaHR0cHM6Ly90b29scy5pZXRmLm9yZy9odG1sL3JmYzU2NjEjc2VjdGlvbi0xOC4xNi4z
ICkuDQoNCkNoZWVycw0KIFRyb25kDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMg
Y2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3Bh
Y2UuY29tDQoNCg0K
