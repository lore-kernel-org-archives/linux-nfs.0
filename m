Return-Path: <SRS0=iDPq=RH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CBEEC43381
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 16:02:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DCB02206B6
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 16:02:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="CMMEO+Bn"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726693AbfCDQCQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Mar 2019 11:02:16 -0500
Received: from mail-eopbgr770139.outbound.protection.outlook.com ([40.107.77.139]:44672
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726552AbfCDQCQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Mar 2019 11:02:16 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=p2ygLI1NlZLRh+mmfO+CvO/oGaaMT/L1gARdXrNeuWI=;
 b=CMMEO+Bn5mEN+ZX2g7wJGljcPOeCAWbC19qs4wu2mK89DKJwJsqu8OwySjdtVPvg9KVENb0ZrnKLlSPzHSbuKoXwR56Oox7RD4vr5ps8vSC59mtz2mW6yNrB7HNzeylp0AHYVlk2LhXnnbA2BKeHRefjT8zJXmP0Hx4ZXfdHMFQ=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2512.namprd13.prod.outlook.com (52.135.95.154) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1686.6; Mon, 4 Mar 2019 16:02:09 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb%3]) with mapi id 15.20.1686.016; Mon, 4 Mar 2019
 16:02:09 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Subject: Re: [PATCH RFC] SUNRPC: Avoid digging into the ATOMIC pool
Thread-Topic: [PATCH RFC] SUNRPC: Avoid digging into the ATOMIC pool
Thread-Index: AQHU0p+GWIUi+XSmkUiwgoUZcRbqDKX7ofyA
Date:   Mon, 4 Mar 2019 16:02:09 +0000
Message-ID: <ddaf320c5c7a4e90f7a1b034fbbabf9bba899fea.camel@hammerspace.com>
References: <20190304153222.27638.90558.stgit@manet.1015granger.net>
In-Reply-To: <20190304153222.27638.90558.stgit@manet.1015granger.net>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 0f593c68-13a1-405f-d0f3-08d6a0bac19f
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2512;
x-ms-traffictypediagnostic: SN6PR13MB2512:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyNTEyOzIzOktXTTJRRXEyazlUY0cyY3h2SkxOMi9pL2Yx?=
 =?utf-8?B?dk1BbDRjYXBDRitBZG5FVk40YmdWK2k0dHVJWVdSUENpMzdXQ2dScmhWaDUr?=
 =?utf-8?B?cCtkdGlHSGEyS0gwZklBZkdveUpqa2g4c1hLWUFueldOWmpGL3VDTWU3d2h3?=
 =?utf-8?B?cE9jeHA1M2ViTFhFY240WUFOQ2N1U3BkN08xek1yaUY5SEpOdUVMVFhsR3hj?=
 =?utf-8?B?YjJxY0FrUnFQU1BYUVBDcTFpZzhYUk1kWDVLNWNnTDYwbmlaZzdsOTVkUDVL?=
 =?utf-8?B?VEFwWGVhTkQ1bnVvOWF2dmthREdabVp0Uzd5YmlieGkxbE41QWtlaTg5aFd3?=
 =?utf-8?B?b2t1YkhDeXpHZythWUZGNmdJdElaUXNoVGxPcHFlNkRpVmJ4d0Y0ZThIdC9a?=
 =?utf-8?B?Q1lBcG9YVFhxSi9LUjJzYk5iOXBFYnNNZndRNmxNWUY2ZlBwUmpHTlEzUDZ1?=
 =?utf-8?B?UjVjUitwem5DWXdTZzRqUVlSOTN5ajZkMnEvakIycFNzZVR2YlRJcW9Xc0dU?=
 =?utf-8?B?ZGJzOTJQaG1vN3RQTVJUd1pGY1l2SGVDcER5cFR4YzIrQmZhdHlZSTBUMDRV?=
 =?utf-8?B?VFBvUUJEdnRaWVkySTFMLzlOWUl4UHVlSks1eGcrbzRJWDNzaTdETGQvWHF6?=
 =?utf-8?B?MXNaSENGUmRaVHlyUXZjU2s3eURxeFJ3VXRZV2pQZkNBMEFtdSt2aXpJVG1z?=
 =?utf-8?B?dUdLa1VUNGFkQmlJZ0I3SlBZRm1IU0pJcm5iSlRrSWVZa1p0Ty9Lc2tmb2RU?=
 =?utf-8?B?Ny9yaXdIWHhBUzZDTzE4cHNmd1VCTm1DdE1TSzRNdElEYVhMcFZub3dSdnk2?=
 =?utf-8?B?VFZKcEJGSGlzYlEvSWJrbFB0QStzTllMbVF6YWdIazJwOWQ3N1VMYStiRk9E?=
 =?utf-8?B?c3laZmR6Nkk5YXFDMjZTU1E3d3lod1Y4eStSUWhXOWpDWE1BQ0VySzE3YXZ2?=
 =?utf-8?B?QWdrYmNlcmdHVVl6Rlg5UkEyck5MenpTMWlONEU5ejJuRU95QTlURVo2V1Zr?=
 =?utf-8?B?TWJrL3dWUElCRUFoNFhIRXk0QUlkbVZydjRmZkVYVzJ5TmZPZkxRV1IyM2dZ?=
 =?utf-8?B?WmV2enlsOS9yTG54dTdzYkdvWXBLRUgzQUN4M3pvd2hsSjBQNlRFdlFhUnZM?=
 =?utf-8?B?SURuQXoyNEpOc3Y4M1UvVUVGcWEzWDdvTWNUV0wvY0Mwc2RBQmcwTW1UaWdo?=
 =?utf-8?B?NWtORjdERGhyQkdsOStVdFY4WC9VcHAycUdncjRvakZ2ckJlTldHb1ZRQ0s3?=
 =?utf-8?B?UGhqUVJ0Rmk3UXdCM0pUVlRRcFlkN0lBenFqZ2x0aVpQYVEyNmNhRVlycUFj?=
 =?utf-8?B?bVVSeTdnRTJsRjVmamh1SE5MbXhzSnhOLzIwRCt6aHdBNFUydFpvS3FWcDRD?=
 =?utf-8?B?MjRaS3B1VzZZalMrZXN2ZG5FMXdwVWo2MFJYT0FPS1JZTFB6WmZHYjNMdjBj?=
 =?utf-8?B?TkFXRVZpb1R3aXcxY01LVy8xUWJCcXA0bzY1WlBJR012OHBQdXJPZXk2Rmkw?=
 =?utf-8?B?SVV4cXVoR2pzdEhpYXhKV0xHakl0enNyNVJRTWtYaWJDQjdlMElocng1ZW5Y?=
 =?utf-8?Q?TMRkWL+Rt6SnMaKeg50fTBMOYByMmfWOVG3xh8xkpdw8=3D?=
x-microsoft-antispam-prvs: <SN6PR13MB2512C42EDE18C685C920DF7BB8710@SN6PR13MB2512.namprd13.prod.outlook.com>
x-forefront-prvs: 09669DB681
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39830400003)(376002)(396003)(366004)(346002)(136003)(189003)(199004)(316002)(14454004)(478600001)(106356001)(446003)(186003)(11346002)(99286004)(110136005)(118296001)(36756003)(76176011)(476003)(229853002)(5660300002)(26005)(6436002)(6506007)(6486002)(2906002)(68736007)(71200400001)(102836004)(105586002)(71190400001)(97736004)(6346003)(486006)(66066001)(8936002)(256004)(7736002)(6246003)(305945005)(8676002)(86362001)(81166006)(81156014)(25786009)(6116002)(6512007)(2501003)(3846002)(2616005)(53936002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2512;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: fooL2YqVR6kZvZR8Xr2NR/QGyF9Dx+h7/iqlhzLmeHFO6bufU41bE5VmPkUtPv2FnyL3KqmTb8pFZ79h5thhPJniG5js2FFSQrxiwwKPFCuO2vwwdJ0Wpwx6vswWa8SGtVZ4bRS6R8Rp709B+BLi9Z4iKfrGp1soywMAk5fSLn2RQZX04cOK3LP/ucPY6tsglQe3EYB0dM1PSORuo1NAN86uPSaolzeMnXO6pWF7x2H+qdfEtUQCp18/8HLo2nNBKg35rm1G/f1N2tIkQIUCxZMm93XS9bhjtcuCQh1AR2FBbZBFiHRGA6hSjdMzAG5M/uvK1MdEioE0Z/wkcrYYjBCMT3E62hSP39zs7LDS9Q+roZGotH7GDzIcRW3XYXcVRYvx057ZypSeY13yhYVYjxtwXZ2XZr/XBDQMmMYB3M4=
Content-Type: text/plain; charset="utf-8"
Content-ID: <1F87D2FFB36DFE4DB62021ADBFFC720B@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 0f593c68-13a1-405f-d0f3-08d6a0bac19f
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Mar 2019 16:02:09.0330
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2512
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE5LTAzLTA0IGF0IDEwOjMyIC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
UGFnZSBhbGxvY2F0aW9uIHJlcXVlc3RzIG1hZGUgd2hlbiB0aGUgU1BBUlNFX1BBR0VTIGZsYWcg
aXMgc2V0IGFyZQ0KPiBhbGxvd2VkIHRvIGZhaWwsIGFuZCBhcmUgbm90IGNyaXRpY2FsLiBObyBu
ZWVkIHRvIHNwZW5kIGEgcmFyZQ0KPiByZXNvdXJjZS4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IENo
dWNrIExldmVyIDxjaHVjay5sZXZlckBvcmFjbGUuY29tPg0KPiAtLS0NCj4gIG5ldC9zdW5ycGMv
c29ja2xpYi5jICAgICAgICAgICB8ICAgIDIgKy0NCj4gIG5ldC9zdW5ycGMveHBydHJkbWEvcnBj
X3JkbWEuYyB8ICAgIDIgKy0NCj4gIDIgZmlsZXMgY2hhbmdlZCwgMiBpbnNlcnRpb25zKCspLCAy
IGRlbGV0aW9ucygtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL25ldC9zdW5ycGMvc29ja2xpYi5jIGIv
bmV0L3N1bnJwYy9zb2NrbGliLmMNCj4gaW5kZXggN2U1NWNmYy4uOWZhZWExMiAxMDA2NDQNCj4g
LS0tIGEvbmV0L3N1bnJwYy9zb2NrbGliLmMNCj4gKysrIGIvbmV0L3N1bnJwYy9zb2NrbGliLmMN
Cj4gQEAgLTEwNiw3ICsxMDYsNyBAQCBzdGF0aWMgc2l6ZV90IHhkcl9za2JfcmVhZF9hbmRfY3N1
bV9iaXRzKHN0cnVjdA0KPiB4ZHJfc2tiX3JlYWRlciAqZGVzYywgdm9pZCAqdG8sDQo+ICAJCS8q
IEFDTCBsaWtlcyB0byBiZSBsYXp5IGluIGFsbG9jYXRpbmcgcGFnZXMgLSBBQ0xzDQo+ICAJCSAq
IGFyZSBzbWFsbCBieSBkZWZhdWx0IGJ1dCBjYW4gZ2V0IGh1Z2UuICovDQo+ICAJCWlmICgoeGRy
LT5mbGFncyAmIFhEUkJVRl9TUEFSU0VfUEFHRVMpICYmICpwcGFnZSA9PQ0KPiBOVUxMKSB7DQo+
IC0JCQkqcHBhZ2UgPSBhbGxvY19wYWdlKEdGUF9BVE9NSUMpOw0KPiArCQkJKnBwYWdlID0gYWxs
b2NfcGFnZShHRlBfTk9XQUlUIHwgX19HRlBfTk9XQVJOKTsNCj4gIAkJCWlmICh1bmxpa2VseSgq
cHBhZ2UgPT0gTlVMTCkpIHsNCj4gIAkJCQlpZiAoY29waWVkID09IDApDQo+ICAJCQkJCWNvcGll
ZCA9IC1FTk9NRU07DQoNCkhtbS4uLiBDYW4ndCB3ZSBtYWtlIHRoaXMgR0ZQX0tFUk5FTD8gSSBj
YW4ndCBzZWUgdGhhdCB3ZSdyZSBob2xkaW5nDQphbnkgbG9ja3MgaGVyZS4gSXQgZG9lcyBsb29r
IGxpa2Ugc3ZjX3VkcF9yZWN2ZnJvbSgpIGlzIHdyYXBwaW5nIHRoZQ0KY2FsbCB0byBjc3VtX3Bh
cnRpYWxfY29weV90b194ZHIoKSBpbiBhIGxvY2FsX2JoX2Rpc2FibGUoKS9lbmFibGUoKQ0KcGFp
ciwgYnV0IGlzIHRoYXQgYWN0dWFsbHkgbmVlZGVkPyBJZiBzbywgZm9yIHdoYXQ/DQoNCj4gZGlm
ZiAtLWdpdCBhL25ldC9zdW5ycGMveHBydHJkbWEvcnBjX3JkbWEuYw0KPiBiL25ldC9zdW5ycGMv
eHBydHJkbWEvcnBjX3JkbWEuYw0KPiBpbmRleCA2YzFmYjI3Li5iNzU5YjE2IDEwMDY0NA0KPiAt
LS0gYS9uZXQvc3VucnBjL3hwcnRyZG1hL3JwY19yZG1hLmMNCj4gKysrIGIvbmV0L3N1bnJwYy94
cHJ0cmRtYS9ycGNfcmRtYS5jDQo+IEBAIC0yMzgsNyArMjM4LDcgQEAgc3RhdGljIGJvb2wgcnBj
cmRtYV9yZXN1bHRzX2lubGluZShzdHJ1Y3QNCj4gcnBjcmRtYV94cHJ0ICpyX3hwcnQsDQo+ICAJ
CSAqLw0KPiAgCQlpZiAodW5saWtlbHkoeGRyYnVmLT5mbGFncyAmIFhEUkJVRl9TUEFSU0VfUEFH
RVMpKSB7DQo+ICAJCQlpZiAoISpwcGFnZXMpDQo+IC0JCQkJKnBwYWdlcyA9IGFsbG9jX3BhZ2Uo
R0ZQX0FUT01JQyk7DQo+ICsJCQkJKnBwYWdlcyA9IGFsbG9jX3BhZ2UoR0ZQX05PV0FJVCB8DQo+
IF9fR0ZQX05PV0FSTik7DQo+ICAJCQlpZiAoISpwcGFnZXMpDQo+ICAJCQkJcmV0dXJuIC1FTk9C
VUZTOw0KPiAgCQl9DQo+IA0KDQpDaGVlcnMNCiAgVHJvbmQNCi0tIA0KVHJvbmQgTXlrbGVidXN0
DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1
c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
