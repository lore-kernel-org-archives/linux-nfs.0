Return-Path: <SRS0=6MPh=RA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58F8CC43381
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Feb 2019 21:04:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2174E20842
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Feb 2019 21:04:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="NmNQXaK9"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727323AbfBYVD6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 25 Feb 2019 16:03:58 -0500
Received: from mail-eopbgr720092.outbound.protection.outlook.com ([40.107.72.92]:55008
        "EHLO NAM05-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727113AbfBYVD6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Feb 2019 16:03:58 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=0e2SN3JnpOPOHVnOQxFAOOBwj9pbD5yuQ8MWdeU85QA=;
 b=NmNQXaK9yg7anV9C7FJMWQzNeiAVIWS2ZhQ7kyQEI78aoAXE/AN5LEuWAtYW81bMICmznEuty7lgjC0YVTxxHsRAaHqnnC4i20jzsBeh3yl87kJEZoWxw+QgT/d4VMcQfXbS1PzF+rsOUYyqymFyfFDbniVgpmrEQlI70Xtanyg=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2429.namprd13.prod.outlook.com (52.135.94.161) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.11; Mon, 25 Feb 2019 21:03:48 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%4]) with mapi id 15.20.1665.012; Mon, 25 Feb 2019
 21:03:48 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "jonathanh@nvidia.com" <jonathanh@nvidia.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>
Subject: Re: Regression: SUNRPC: Use poll() to fix up the socket requeue races
Thread-Topic: Regression: SUNRPC: Use poll() to fix up the socket requeue
 races
Thread-Index: AQHUzUhAfjY8UpPesU2cJZ8XbzkbuKXxAJ4A
Date:   Mon, 25 Feb 2019 21:03:48 +0000
Message-ID: <ab485d7ba4f9603850b81e6c2242dc25026eabcb.camel@hammerspace.com>
References: <95702994-6762-e42b-06ee-ae945c2137bd@nvidia.com>
In-Reply-To: <95702994-6762-e42b-06ee-ae945c2137bd@nvidia.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 71a7dc61-ed1e-4df0-5f8f-08d69b64bcc8
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2429;
x-ms-traffictypediagnostic: SN6PR13MB2429:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyNDI5OzIzOm5BM2Q0TzFKQ1JtUnFuTjk1Z0dncjBmbkF6?=
 =?utf-8?B?SDVESGs5TjdxZEUxbWhoS21qUjJ6ZnhWWTJVRjFIUHA0WmFkS2gxK0drMjJN?=
 =?utf-8?B?RWdSUVhrVU42SXRhUVpia21FOHo4Sm5JQnYzSFNIendwVnVOd3Y5WnVqSC9v?=
 =?utf-8?B?T0k4L0lqYW9JR0lXemlFVTVtd28zZnpFOVB2ZFEwUDV1OStpbzZocWtmaUNo?=
 =?utf-8?B?bXBxRmJLS3Y1TE83RWtTMkdSM3ZJeUxLZnpmd1p2cEZncjQwYnV5aGY4QWtq?=
 =?utf-8?B?U1pkT2xNcVFCRTJ2QnhPSytQT2REY1lNaE0zT2VnTGo1d2pHNmxVYnVGRTlB?=
 =?utf-8?B?ODNRRXZqZEI4Z2YweDMrd2NFcFZaVkNTMW9ZYnNQaW5ERGxxY2VrV2t2cEVi?=
 =?utf-8?B?Um96WldqQUlKMW5iR2dGNjBJcUg4dnhxU0VGdUtmQ3djSWh0NVNOeEdGaEM0?=
 =?utf-8?B?emhwSUczM0hwZHZ5ajZkT3Z5UUk3elpCMWxiK096ZkVIcmRPQVZRYzNHYm9i?=
 =?utf-8?B?UkZMTkFRTS9YSmJ1eGtVUWFUQXJBU3k3Q212c0prUGFqbVRqYklMejlOblRj?=
 =?utf-8?B?Y3Nuemd3NUI5QUhuNmRxSjlsK09TNEtaNElDMEE4RndBS0JKOGxwRWFOTFZN?=
 =?utf-8?B?eUgvZ2JjdzQzMno0TFN1NmJHeFIyY1dHMXVWTjlneUNRTnE3TTl1QmQ0ZU5w?=
 =?utf-8?B?dDJ2U3dxMTNFK1Izcm5lbE9EWUE3V0pWdmZNWk4zZHFmd3FCaWMzb09IV3kw?=
 =?utf-8?B?VHZyZTdnWmJYbmNOKzJtWHMzUHhreGM0MEFjNlBrMFpMZ0dzNTFjT1dkRTBv?=
 =?utf-8?B?L3N6dmNaRi9QS3BPYm9JbmY5UGY1bXBWaG5GcjdpWWpLd04yK1hyZ3k5em5W?=
 =?utf-8?B?VkFHbXFhanI4VTdVcXE3aGtIZWFEaGVDZC9oWEdLMnk1RUtySmNLQ2M2MWF0?=
 =?utf-8?B?Y1ByQmVoZWpiVnVuK1lVQzdFTGdHSkpYd2JIMVNyN21HWmhhQkcwb1A0dEQ0?=
 =?utf-8?B?RmU3YlhmQ1R0d3NVYkp6YjYxQnJoTFUyNTFiVEFXeGVCNzNLVVZuK3JaMnJR?=
 =?utf-8?B?RVNBVUM2M25rTnlmZG5mSENHN1UyRnRpUTBoYUM0bDFhaDM3UmpLZE1DelZh?=
 =?utf-8?B?OEsyN1NUNXFWTnhlbVl4ZkhpVzhOdjFBNzNKRmF2N1Rjc2hPWTZsVjU2TGNu?=
 =?utf-8?B?b3VweDJ1U2d0aDBiOTN0VVRPeHRsNVBNRHhMQTQrQ2dKQ2wrODhsdzIrdWdC?=
 =?utf-8?B?aXd4R1drWitWbkRCTDVTYUVXdUxuQ0Jqb2VMNmJ3SU1PalpnLy9DM2s3Y2J4?=
 =?utf-8?B?UXZDSzBWS29HVGFxVXBvNjNmc284Zjc0aDNGai9FTEU4MEZEQWU1bi91MjZC?=
 =?utf-8?B?SG9ydHhRU1hhUGJSMXhpWFpLdVN6RFR4YWVwUUIvVlVyOHUvb1dHbFpkVWZp?=
 =?utf-8?B?M2NaYjZFOVhObVNMRlVFWUxEeFRDYllhckdUcVBjUmlMOG5RY0pBQzhVaGhO?=
 =?utf-8?B?WmFEdFltWHE1b2lUZXhxNHhxQ0M3NjB0VGx4djd1c2VTc0FleFpkRDBDcFlK?=
 =?utf-8?B?QUl6d2tRd0hkTjNCYXZ0d1UyYUs3aHNhMzZDSTZ1QlJqNUEyY25taXd6STlp?=
 =?utf-8?B?cFdzSTF6MFYvMjNMZUlJZkhQdGovUFdheXFmTGdxR3lFYzFKbDVWekxBPT0=?=
x-microsoft-antispam-prvs: <SN6PR13MB24296398B7C9BDC48AD4EF78B87A0@SN6PR13MB2429.namprd13.prod.outlook.com>
x-forefront-prvs: 095972DF2F
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(376002)(39830400003)(366004)(346002)(396003)(199004)(189003)(229853002)(2501003)(71200400001)(66066001)(106356001)(6436002)(4744005)(6486002)(478600001)(105586002)(71190400001)(118296001)(68736007)(36756003)(97736004)(486006)(5660300002)(6116002)(3846002)(7736002)(76176011)(256004)(81156014)(8676002)(102836004)(11346002)(446003)(2201001)(2616005)(476003)(6512007)(99286004)(110136005)(6246003)(305945005)(6506007)(316002)(26005)(2906002)(6346003)(53936002)(14454004)(86362001)(81166006)(25786009)(8936002)(186003);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2429;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: zqp6Uswceo6jj6P7MS3lqHG7uHTqPx31r+3VCYlOcz87f7ozIYCwjdn0zIDhTwq2hVo4mKZVH8b5/ziaP/0vDFo/wCW8hu39p+y7fM9MUob7oVkpOWi3q9rfa0tGkebLg1fNUFG7J/qxIjduPHCedZYrIPob6aZm4s72zTSoGJUgAhZ+yY4nZOnoSPRQWPetQ2uMtJa6wtaSdJkP8WNITr7QCbyLZgGEs/4CWHOAKPMPfhH02id5WkZAxw7dp9hxwos7Bz0cGRabB+lDVvvZc0/v8viUBDgS2fY3FqWc9H9h4c+EQrMyfTAocWxlpbBEKGJ4mwTXtS5mXTZA3xZ+dDhNhuYDFtkQubCKNPRz0seMdTZFAV9o7F8hOZFX2DkUaor4eqdqLhXm+ISlZUXyGA0OluD3syNuMoXM6k51Y00=
Content-Type: text/plain; charset="utf-8"
Content-ID: <273E302E5EDAB447A081E11307CDFB63@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 71a7dc61-ed1e-4df0-5f8f-08d69b64bcc8
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Feb 2019 21:03:48.4526
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2429
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE5LTAyLTI1IGF0IDIwOjI1ICswMDAwLCBKb24gSHVudGVyIHdyb3RlOg0KPiBI
aSBUcm9uZCwNCj4gDQo+IFN0YXJ0aW5nIGluIG5leHQtMjAxOTAyMjIgSSBoYXZlIG9ic2VydmVk
IGEgcmVncmVzc2lvbiB3aXRoIE5GUw0KPiBjYXVzaW5nDQo+IHNvbWUgb2Ygb3VyIGJvYXJkcyB0
byBmYWlsIHRvIGJvb3QuIEJpc2VjdCBwb2ludHMgdG8geW91ciBjb21taXQgLi4uDQo+IA0KPiBj
b21taXQgMGZmZTg2ZjQ4MDI2YjdmMzRkYjIyZDEwMDRiYzk5OTJmMGRiOGIzMw0KPiBBdXRob3I6
IFRyb25kIE15a2xlYnVzdCA8dHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbT4NCj4gRGF0
ZTogICBXZWQgSmFuIDMwIDE0OjUxOjI2IDIwMTkgLTA1MDANCj4gDQo+ICAgICBTVU5SUEM6IFVz
ZSBwb2xsKCkgdG8gZml4IHVwIHRoZSBzb2NrZXQgcmVxdWV1ZSByYWNlcw0KPiANCj4gDQo+IEFm
dGVyIHJldmVydGluZyB0aGlzIG9uIHRvcCBvZiAtbmV4dCBJIG5vIGxvbmdlciBzZWUgdGhlIHBy
b2JsZW0uIEkNCj4gaGF2ZQ0KPiBub3QgaGFkIGNoYW5jZSB0byBsb29rIGFueSBjbG9zZXIsIGJ1
dCB3YW50ZWQgdG8gc2VlIGlmIHlvdSBoYWQgYW55DQo+IGlkZWFzIHdoYXQgbWlnaHQgYmUgdGhl
IHByb2JsZW0uDQo+IA0KPiBDaGVlcnMNCj4gSm9uDQoNCldoYXQga2luZCBvZiBib290IGlzIHRo
aXM/IFVEUCBvciBUQ1A/IG5mc3Jvb3Q/IE5GU3YzIG9yIE5GU3Y0PyANCg0KLS0gDQpUcm9uZCBN
eWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25k
Lm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
