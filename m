Return-Path: <SRS0=V3X6=Q4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8493FC43381
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 22:33:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 22FC420836
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 22:33:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="l3QHeFtB"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726172AbfBUWde (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Feb 2019 17:33:34 -0500
Received: from mail-eopbgr730119.outbound.protection.outlook.com ([40.107.73.119]:54573
        "EHLO NAM05-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725961AbfBUWde (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Feb 2019 17:33:34 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=lXQRjlrPjTS1lEHLrf7gWI2Vx5+pEDhPasparF3YYpY=;
 b=l3QHeFtBwRvfc4/75eTt2Uo9OVQem0SD5exY1wKpbu0bfygR+uzf54fjkgdKWr+arjasEQ7RFZzw6goXwG9XdXwl7jD5Ffjic0/wvHDJrOFqBej5ctXBHB+qjY72iPe/Zl00vzG++bCJV2nAxjzKwQ+PPih8Auyf+qpjR7B9puU=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2397.namprd13.prod.outlook.com (52.135.94.153) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.11; Thu, 21 Feb 2019 22:33:30 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%3]) with mapi id 15.20.1643.012; Thu, 21 Feb 2019
 22:33:30 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "ito_kazuo_g3@lab.ntt.co.jp" <ito_kazuo_g3@lab.ntt.co.jp>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "konishi.ryusuke@lab.ntt.co.jp" <konishi.ryusuke@lab.ntt.co.jp>,
        "watanabe.hiroyuki@lab.ntt.co.jp" <watanabe.hiroyuki@lab.ntt.co.jp>
Subject: Re: [PATCH v2 0/2] pNFS block/SCSI layouts read-modify-write
 fix&improvement
Thread-Topic: [PATCH v2 0/2] pNFS block/SCSI layouts read-modify-write
 fix&improvement
Thread-Index: AQHUxEiciF/aefdAJkqnlMTFQpfQDKXq4lwA
Date:   Thu, 21 Feb 2019 22:33:30 +0000
Message-ID: <9bb9ab1c96002db928babf5d2dc8ad9315325fbc.camel@hammerspace.com>
References: <92b9e2a4-8880-3fc6-1f6a-e5ab85ed96e6@lab.ntt.co.jp>
In-Reply-To: <92b9e2a4-8880-3fc6-1f6a-e5ab85ed96e6@lab.ntt.co.jp>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 8510ffe2-8aeb-4e37-8d63-08d6984c9b00
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2397;
x-ms-traffictypediagnostic: SN6PR13MB2397:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyMzk3OzIzOkIySkdBaEQ2VnY5UzRPZWpvVWcxVWtldkJh?=
 =?utf-8?B?RFNleC9ENjRnTHZJNm5pbkExWFVyRHRDcEZ3OFJ4a1c3WGdUODlIdjFMcHNm?=
 =?utf-8?B?bzJxenFjekhFQVdXVzltV3ZwZG5PYlJoc29CbGlCQ28zQkFqT2xPNmhZOGtt?=
 =?utf-8?B?UC9Jd1NodGlJVDEzbXNRRDIrL1pMUit2bUxjWExzNDVjdTdvMWN0UERZZnhZ?=
 =?utf-8?B?R2xHQU1zSkVDc3N1MFJ0czU0U2NJaEVFTkhxOGF6TUlNTXZFZDMzU1gweTZn?=
 =?utf-8?B?dTA3NkVzOU16QndjTStSc3k2RkJhek9XVURlZ0tGZmdWeThzR3pSUUJxWDJL?=
 =?utf-8?B?MGJvTUthdk5nOUg5dVVaK2h0ZmNiai8rU1kxcS8rUGJqeTdsaTVaZks0YWIx?=
 =?utf-8?B?dURyVHBORDc3ODRJSUM4b2R4eFl5aFNDQWp2MDBDZTduU1ZSVTNsUGlxM0pI?=
 =?utf-8?B?cmk2M256T0VsUXVYSkorWXY1SHZQZmw2c0xuQWVVZkNqamFYa0tOZmZLV0NM?=
 =?utf-8?B?NSsxNjB3QUZmM2paNWlPM1JZREwvUzJzcnY5NUluR1huaGJjakF1U1VJc1dr?=
 =?utf-8?B?TlY1RlQyWkFKYS8zdk81OTZ5TVZSbnlBU0FNbHBZVXRTbEpHa1JvY1dEVkZt?=
 =?utf-8?B?Z1NMS05WRk5YVHovY05sNVpHRVN0c3BpVkRPQnpxZnJuSHB6YkZRTVdMUUpq?=
 =?utf-8?B?ZnMyQkZudHp6VlE5cHRPZXkwMTBQdmR5RWNhYnh6NktITmtsNEVkeFMxaVUy?=
 =?utf-8?B?eGxqS3BvMWJ0bUI0dU5EVGRRNWw3QmNTV2xOUkw1VUdlV1I0VXBYUCtsNFZr?=
 =?utf-8?B?aUNwcUk5R25VWE40dWJyMmFQaHBtN1JhL2hUc0hVN1dwcndHSVpkV3I0bllD?=
 =?utf-8?B?ZW14ZUZaa1QxWXg0SStkUHp4amhUQkZTV1JhamhGUThyZnJJWVo1bmdlWElR?=
 =?utf-8?B?WWEyUjB4MzI3enZYU0F6V2tlb0NscDZsUXN4M0VmRTR2dDdNQi9YTlNFWnBC?=
 =?utf-8?B?dzRCN2xKQTFJdGU4SGcwOW11RVJZOTdleHlnRlErMnh4Z1pmcFNwRDFHWWJI?=
 =?utf-8?B?MkpEZEkyZFNHNHQ2ZXBGTzU0NmEwd1VlazZYNVBRaGluUkxRenNtOVYyUjJW?=
 =?utf-8?B?Z0xFZi9BQllERWRGWjJ6NElQNmdqTHlQcUhCbk9SSFByenFHRjFWUEoycFFw?=
 =?utf-8?B?dThiUlJtWU1DaEorZlJ6UFNMYXJrVGdtV0JGMm5EZUtyOGI1emRwaDRVckRx?=
 =?utf-8?B?ZjBjQ0pFOUNtWDhaNittRkRId3EvOGJqVklEMEFsK3NoSGxOU2JJQnp5RVpY?=
 =?utf-8?B?TE9MMGk5THZWTXUvb2lKNXNNN3ZpYXhneTYzNTRIbXZodkZLTkFScVZWbDd0?=
 =?utf-8?B?akgrRFZWbk0yNVVCS211bFl0RkNYTjJOUWdObVV5QzVERkdTNTI3M0w0aDNn?=
 =?utf-8?B?bUdUZFF0clRmV1VHY3lUMjJPeXhEVFRwSGpUVnpZRjBpSFNFMVRZVnkxVWJW?=
 =?utf-8?B?Q3k0aVdRSm1RZ0NJdERoSTV6MlZWZk91a1RCT0JKcHIvQXc4eEs3RlZTY3Ev?=
 =?utf-8?Q?Zakt2nb9ZVOZRsbd00DvkbUZbomyMWZtIVX8fqLWkVyc=3D?=
x-microsoft-antispam-prvs: <SN6PR13MB23978E5197E4A91C6C737A76B87E0@SN6PR13MB2397.namprd13.prod.outlook.com>
x-forefront-prvs: 09555FB1AD
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(39830400003)(376002)(136003)(346002)(366004)(189003)(199004)(478600001)(6506007)(53936002)(6246003)(14454004)(2501003)(76176011)(102836004)(25786009)(186003)(106356001)(68736007)(2616005)(105586002)(36756003)(11346002)(476003)(486006)(256004)(71190400001)(66066001)(71200400001)(446003)(305945005)(8676002)(6116002)(86362001)(7736002)(118296001)(229853002)(5660300002)(6512007)(8936002)(3846002)(6436002)(110136005)(6486002)(2201001)(99286004)(316002)(97736004)(81166006)(2906002)(26005)(81156014);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2397;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: znW4mYoBZbu5GBaXQLBPWY8uZBvubxv9ad1dGl/QPyTRO27cI4n+RDEF8D1NIh2k4iiDM9Jd49wlWgaPY7DPnMNZSC3+5CgK+pGMCjRysYVKfxt+g+znsEq1G100pRAlkcBcXAlAyOzEpxdn2nsJ9amZ2GgWcE2Ql0WrtyJKaQwYnQSWtqAaEZVE3ahQ2z7V0L5I/N3fhApbZrEvnbevHaA9Eig0pQDSp1AYCt/x9VkxZnMV/0+4WXK0avR4DI601WduHdttlp1R4bt2Q5j7IkYNhMG3GAVnvo6K+kVc7Pv9g6pQI/8gHQuB3EZUNG+a2+P8JS5Qx9epCZiSiuWa9PBx2wXBkflJQqcVsgEDbZcmzAwL3sJaMKKA4lUiorMmWUL1Ag1RSKYzcHsyWZy1BfNkZAShV9IElN2WRJq6LS0=
Content-Type: text/plain; charset="utf-8"
Content-ID: <D311AAB35CE56A41B31745D3EAEAF36B@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8510ffe2-8aeb-4e37-8d63-08d6984c9b00
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Feb 2019 22:33:30.3213
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2397
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTAyLTE0IGF0IDE4OjM0ICswOTAwLCBLYXp1byBJdG8gd3JvdGU6DQo+IFRo
aXMgc2V0IG9mIHBhdGNoZXMgYXR0ZW1wdCB0byBmaXggcG90ZW50aWFsIGRhdGEgaW50ZWdyaXR5
IHByb2JsZW0NCj4gaW4gbmZzX3dhbnRfcmVhZF9tb2RpZnlfd3JpdGUoKSBhbmQgaW1wcm92ZSBm
dWxsIHBhZ2Ugb3ZlcndyaXRlDQo+IHBlcmZvcm1hbmNlIG9mIHBORlMgYmxvY2svU0NTSSBsYXlv
dXRzLg0KPiANCj4gVGhlIHBhdGNoIHNldCBjb21wcmlzZXMgb2YgdHdvIHBhdGNoZXM6DQo+ICAt
IDEvMiAicE5GUzogRml4IHBvdGVudGlhbCBjb3JydXB0aW9uIG9mIHBhZ2UgYmVpbmcgd3JpdHRl
biINCj4gICAgZml4ZXMgdGhlIGludGVncml0eSBpc3N1ZQ0KPiAgLSAyLzIgInBORlM6IEF2b2lk
IHJlYWQvbW9kaWZ5L3dyaXRlIHdoZW4gaXQgaXMgbm90IG5lY2Vzc2FyeSINCj4gICAgYWRkcmVz
c2VzIHRoZSBjYXNlcyB3aGVyZSByZWFkL21vZGlmeS93cml0ZSB3YXMgcmVxdWVzdGVkIGZvciBh
DQo+IGZ1bGwtDQo+ICAgIHBhZ2Ugd3JpdGUuDQo+IA0KPiB2MSAtPiB2MjoNCj4gIC0gYWRkZWQg
dGhlIGZpeCBmb3IgbWlzc2luZyBQYWdlUHJpdmF0ZSBpbiB0aGUgcE5GUyBibG9jayBsYXlvdXQN
Cj4gIC0gbWFkZSB0aGUgY2hlY2sgZm9yIGZ1bGwgcGFnZSB3cml0ZSBhIHNlcGFyYXRlIGlubGlu
ZSBmdW5jdGlvbg0KPiAgLSBtZXJnZWQgdGhlIGR1cGxpY2F0ZWQgY29kZSBmb3IgdGhlIHBORlMg
YmxvY2svU0NTSSBsYXlvdXRzIGFuZA0KPiAgICBmb3IgdGhlIG90aGVyIGxheW91dCArIG5vcm1h
bCBORlMNCj4gIC0gdHlwZSB1c2FnZSBjbGVhbiB1cCAoaW50IHRvIGJvb2wsIHVuc2lnbmVkIHRv
IHVuc2lnbmVkIGludCkNCj4gDQo+IGthenVvIGl0byAoMik6DQo+ICAgcE5GUzogRml4IHBvdGVu
dGlhbCBjb3JydXB0aW9uIG9mIHBhZ2UgYmVpbmcgd3JpdHRlbg0KPiAgIHBORlM6IEF2b2lkIHJl
YWQvbW9kaWZ5L3dyaXRlIHdoZW4gaXQgaXMgbm90IG5lY2Vzc2FyeQ0KPiANCj4gIGZzL25mcy9m
aWxlLmMgfCA0MCArKysrKysrKysrKysrKysrKysrKysrKysrKy0tLS0tLS0tLS0tLS0tDQo+ICAx
IGZpbGUgY2hhbmdlZCwgMjYgaW5zZXJ0aW9ucygrKSwgMTQgZGVsZXRpb25zKC0pDQo+IA0KDQpU
aGVzZSBsb29rIGdvb2Qgc28gSSd2ZSBhcHBsaWVkIHRoZW0gdG8gdGhlIGxpbnV4LW5leHQgYnJh
bmNoIGZvciB0aGUNCjUuMSBtZXJnZSB3aW5kb3csDQoNClRoYW5rcyENCiAgVHJvbmQNCg0KLS0g
DQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3Bh
Y2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
