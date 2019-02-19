Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 757A3C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 15:13:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2037D20665
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 15:13:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="A+jpOJar"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726352AbfBSPNb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 10:13:31 -0500
Received: from mail-eopbgr820128.outbound.protection.outlook.com ([40.107.82.128]:31520
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727846AbfBSPNa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Feb 2019 10:13:30 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=j3UFEPmMtfVai6GxNKSaxgzpBfWo3CH3dK6bjlo9UO8=;
 b=A+jpOJarYHygmFdrZt2mF02RllXMWetla8D3z9t3OAXMKj01JHK748hWCTZjOOsVw3nX/s6NOUFFcuqG1duB/ZKfX7qSXz4qCG03HxMSiangWmmGn4BxRWqsyXE84ujUZfGqGAskryqxNNcMnhxQKvq8py15Aj8DVX3i1qc+9rE=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2367.namprd13.prod.outlook.com (52.135.94.147) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.8; Tue, 19 Feb 2019 15:13:27 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%3]) with mapi id 15.20.1643.012; Tue, 19 Feb 2019
 15:13:27 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Use poll() to fix up the socket requeue races
Thread-Topic: [PATCH] SUNRPC: Use poll() to fix up the socket requeue races
Thread-Index: AQHUyFyJR973skBS7kOFl7asZXFqtaXnNW2AgAAFKgA=
Date:   Tue, 19 Feb 2019 15:13:26 +0000
Message-ID: <e0a1f082b017aadb98dec3f8df6de7a49c078fac.camel@hammerspace.com>
References: <20190219140616.123141-1-trond.myklebust@hammerspace.com>
         <A2BBC175-F60D-4C61-B70F-479952D2CD21@oracle.com>
In-Reply-To: <A2BBC175-F60D-4C61-B70F-479952D2CD21@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 120708e6-72b4-409e-d950-08d6967cccad
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2367;
x-ms-traffictypediagnostic: SN6PR13MB2367:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyMzY3OzIzOmUwR3RBVlByK2ZWc0UvNHNiWU1uVkZEUmE1?=
 =?utf-8?B?QmhERmdqWTg1V2c0VVZrbDc2QmkyTmpNd1VSNG0zRlVrMHEwL0tXM3pZTkFD?=
 =?utf-8?B?U1U0VjdGRlcvQ3RwZno5bStUazV5emlIdjk4YmlVc3FrRTZJbU9rRTkzR0Nn?=
 =?utf-8?B?NDlOdnJJOXdDeHdJTFpONWJ6d0ptSHFuRE8wdjQ2V2U4OEJkSFF2YUNwSDZ4?=
 =?utf-8?B?RXlnY09lS21raHF1Q1pZZVVndmRPYTZzTE4wRER3SU9pT3pHM0tOLzdwMFYy?=
 =?utf-8?B?Z1k5eDBTb0dRME5ZWVhpdWwyRzB0N2tjQzNsNVhMK0NkMjFTTkhObUZkV2Ro?=
 =?utf-8?B?TG80VW5ER0VCUFJ1RWw0TWVwOVc5ellSaWJuK3pQYVVubGVnUXdQemFSUEFK?=
 =?utf-8?B?L2M4Y1kyekEweng2MTlYREpmV0F5ZjhHRUlDSHh3OGFXaysvcm50MU9rM3ZK?=
 =?utf-8?B?VEhEeEFML0x5Q2tDOG9CQW5tZTlzQVZERERjWm1zVDlHRjFQb3BwWGVzWFBX?=
 =?utf-8?B?bjNXcUhzSnFhWUZyQlV0cFphQjRxMlVhOGtIVkVNdW16QTlKUHNRRVVCR21z?=
 =?utf-8?B?dytJYVU5aUlRNEtVRjRFbFVNUGxrOFI0OUVDa2xVR0ZPZEFERzVSb0lNZHl1?=
 =?utf-8?B?ZFFsS1dwck9CUUJCN0k2YVNYZFJUSmFmRWt5UDJxU2l0cXhzQjZmaDdvODlN?=
 =?utf-8?B?UWhwWkFzRGdCaHQ1ZkdteWpOeHZJVWUwNjB4Mmg1Vk5vYlJCZ1liYS9HTXAr?=
 =?utf-8?B?dk1lU29UYk0yZFNNbHZCeWx6b3owYjFHS1JIMW1wdlNBdG5oaHFHUWZxM1V5?=
 =?utf-8?B?TlpoL2N2b0NOdURCc1NxWGYrUjJENzdkV2JlYjhTV0k1eko4UGhsbTNUMTc2?=
 =?utf-8?B?STVXME5tNFd0eklnbDZMOWZEbXhBWDdsdWdSMHYreTZIbmkxWm8wWUx5N3Rn?=
 =?utf-8?B?NTZ1NnkzQzFJWDE4eTlDUGhzRXRWR00yQWlyQXN4VFp4bTBkSUdEcXQ5NVdz?=
 =?utf-8?B?a1hCTlpFVUdPaUd1TFlJWlJvL0tzTGxLWkg4ZGpnUTNnY3pzMGZaVHplaFV6?=
 =?utf-8?B?ZVBuTWRzNURMK0N3MVJ5ajU4K2lyM3BPUUQ5RUI4YXFWMStOMXhNK3UyMmY0?=
 =?utf-8?B?dzdZWU9qREYwZFZqRXhwTWc1cHNPUGs3MHo0WlVFQUFDR0Q2RHB3ZDhYYy9n?=
 =?utf-8?B?MGVxeVJmdVFYZVZxejBnWkY0SEkvS3J1aGRGNHllMjV3Mzk4L2dmNmhmYnJs?=
 =?utf-8?B?anRwT05SdWp1SENTanJBSGdwV1NJTDNTc2Qvd2MyaG9DUHdZbGZ2R3dLZUwx?=
 =?utf-8?B?Z2pDWnk2TUJTRTliaW4zeDJWaTJPaXVLQU8ySFZBM2VqZlVBL1BYMDJZWVdM?=
 =?utf-8?B?b2c4R2pwc1lTOXg1SDZmdXhnQkxydXpuOUJJRlp2cVExT3dJSGdOeHdrbmg3?=
 =?utf-8?B?cGpZelE0UDEyc0owSWtzZGVXTS9ZYUh5YUhSRWsydnB4d1hlb0tXQ2E1MTc5?=
 =?utf-8?B?RTN6U3VUOS9RNncxVE8yZFBtcTJWOVlmZVNtVnBtWStTWXFFbi81Y0tMUXBn?=
 =?utf-8?B?MityaTIrTnN2QlIrVUgwL2srWWovS0VYTXBwTVZZNHhvV1pLMWpiVUttTHcw?=
 =?utf-8?B?SVJHcy96QmxJTHczNmtrRWhOa1VTWFFKYnB0ZDN5aXlDNnk2MW01YzIrdDZM?=
 =?utf-8?B?NmpIZmF2aW04RUsyUnM3S0JkdHZ3Z0RVdEFITjdKT3cwZm1ydGJ5TmJzQ1Vj?=
 =?utf-8?Q?tNK/2ZajjEs18VgKFduYvO9hCTE/544MPoz5o=3D?=
x-microsoft-antispam-prvs: <SN6PR13MB23679BFF5477EE84FCDF2896B87C0@SN6PR13MB2367.namprd13.prod.outlook.com>
x-forefront-prvs: 09538D3531
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(366004)(136003)(346002)(39830400003)(396003)(189003)(199004)(14454004)(53936002)(6246003)(36756003)(6512007)(2906002)(105586002)(106356001)(71190400001)(68736007)(4744005)(71200400001)(6916009)(478600001)(2501003)(6506007)(53546011)(7736002)(305945005)(2351001)(6346003)(102836004)(76176011)(6486002)(86362001)(66066001)(6116002)(3846002)(118296001)(2616005)(316002)(476003)(486006)(5660300002)(81166006)(5640700003)(11346002)(81156014)(26005)(6436002)(186003)(8676002)(446003)(229853002)(8936002)(97736004)(25786009)(99286004)(4326008)(14444005)(256004);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2367;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Z2E8ZwN/qYOiujaAXUSOWGguYMxr7MEKMiVIbSIyAjbtUUJlRgJyaMfck4EMqhzJ5Gwuy1jGRwDzpZn2UOJ0wF+CXl9sOcwYGcCrgdoi5je/lxKLtc461A9UX/ufVJbYc0hCVeoSU20r/2/oKBcOyUkyR47q+2O6jgdYx6Me4H7Oc+3YmHcnfH39N1zF+2kGKAmgKySqebSBFb2sfKVpt5veH7SJWQmxO+44ld/KtTHVS+AuM1SQbTLOCK+K08t2BUr1Ue7WqcSuHs01/4wxpXymbLk6gMDHOWIZRCPT/UZNWe6bgDcpQ6c27pmxcr2Jz5EUIMnaqukxJHpUgCYoEkQcpGZv4ZwdylefR/UPd1rwBlBjOI6G67NbvAAUl4VyYy5zCze2KlX/4FKHVmsqYEe/8Mqch80i3JaPyvhrWvI=
Content-Type: text/plain; charset="utf-8"
Content-ID: <6FE6241FF9BA1E42B90A41374AA6A20A@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 120708e6-72b4-409e-d950-08d6967cccad
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Feb 2019 15:13:27.2329
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2367
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE5LTAyLTE5IGF0IDA5OjU0IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
SGkgVHJvbmQtDQo+IA0KPiA+IE9uIEZlYiAxOSwgMjAxOSwgYXQgOTowNiBBTSwgVHJvbmQgTXlr
bGVidXN0IDx0cm9uZG15QGdtYWlsLmNvbT4NCj4gPiB3cm90ZToNCj4gPiANCj4gPiBCZWNhdXNl
IHdlIGNsZWFyIFhQUlRfU09DS19EQVRBX1JFQURZIGJlZm9yZSByZWFkaW5nLCB3ZSBjYW4gZW5k
IHVwDQo+ID4gd2l0aCBhIHNpdHVhdGlvbiB3aGVyZSBuZXcgZGF0YSBhcnJpdmVzLCBjYXVzaW5n
IHhzX2RhdGFfcmVhZHkoKSB0bw0KPiA+IHF1ZXVlIHVwIGEgc2Vjb25kIHJlY2VpdmUgd29ya2Vy
IGpvYiBmb3IgdGhlIHNhbWUgc29ja2V0LCB3aGljaA0KPiA+IHRoZW4NCj4gPiBpbW1lZGlhdGVs
eSBnZXRzIHN0dWNrIHdhaXRpbmcgb24gdGhlIHRyYW5zcG9ydCByZWNlaXZlIG11dGV4Lg0KPiA+
IFRoZSBmaXggaXMgdG8gb25seSBjbGVhciBYUFJUX1NPQ0tfREFUQV9SRUFEWSBvbmNlIHdlJ3Jl
IGRvbmUNCj4gPiByZWFkaW5nLA0KPiA+IGFuZCB0aGVuIHRvIHVzZSBwb2xsKCkgdG8gY2hlY2sg
aWYgd2UgbWlnaHQgbmVlZCB0byBxdWV1ZSB1cCBhIG5ldw0KPiA+IGpvYiBpbiBvcmRlciB0byBk
ZWFsIHdpdGggYW55IG5ldyBkYXRhLg0KPiANCj4gRG9lcyB0aGlzIGZpeCBhbiBhcHBsaWNhdGlv
bi12aXNpYmxlIGhhbmcsIG9yIGlzIGl0IG1lcmVseSBhDQo+IHBlcmZvcm1hbmNlDQo+IG9wdGlt
aXphdGlvbj8NCg0KSSdtIG5vdCBhd2FyZSBvZiBhbnkgaGFuZyBhc3NvY2lhdGVkIHdpdGggdGhp
cyBiZWhhdmlvdXIuIFRoZSBwYXRjaCBpcw0KcmF0aGVyIGludGVuZGVkIGFzIGFuIG9wdGltaXNh
dGlvbiB0byBhdm9pZCBoYXZpbmcgdGhlc2UgdGhyZWFkcyBibG9jaw0KdXNlbGVzc2x5IG9uIGEg
bXV0ZXguDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWlu
ZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
