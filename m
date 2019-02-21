Return-Path: <SRS0=V3X6=Q4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30D90C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 22:40:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E8832206A3
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 22:40:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="py+t0rC8"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726423AbfBUWk4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Feb 2019 17:40:56 -0500
Received: from mail-eopbgr720118.outbound.protection.outlook.com ([40.107.72.118]:4896
        "EHLO NAM05-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725891AbfBUWkz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Feb 2019 17:40:55 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=epgFfkDOgNiiv4W5v3UbkpcqZ54Lt+VTxtv+WyeeSj8=;
 b=py+t0rC8h6OSR/werJWlruaYmwdLX/9Ep92cJTB4BaKNGyDFI7KFgfs3jDvBTBQHEbNgAXAh7ow0yMsUpaklWvyNlKafEUEFKNOF3Xd2PNf4jRJh40T77sJTT1n6as8b82XAJ00j2JN69J7fF4jAXOO43nWq03lcNcVVtLhxsUA=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2463.namprd13.prod.outlook.com (52.135.95.31) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.11; Thu, 21 Feb 2019 22:40:52 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%3]) with mapi id 15.20.1643.012; Thu, 21 Feb 2019
 22:40:52 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "Julia.Lawall@lip6.fr" <Julia.Lawall@lip6.fr>
CC:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
Subject: Re: [PATCH 15/20] NFS: drop useless LIST_HEAD
Thread-Topic: [PATCH 15/20] NFS: drop useless LIST_HEAD
Thread-Index: AQHUmqKiOdd7+P3TVEK6hnhFX/CrhaXrN7cA
Date:   Thu, 21 Feb 2019 22:40:52 +0000
Message-ID: <81b0b3c72ebb7fc97c3166d945f82ee4184ed657.camel@hammerspace.com>
References: <1545555435-24576-1-git-send-email-Julia.Lawall@lip6.fr>
         <1545555435-24576-16-git-send-email-Julia.Lawall@lip6.fr>
In-Reply-To: <1545555435-24576-16-git-send-email-Julia.Lawall@lip6.fr>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 1d46ca4d-9feb-4030-10f0-08d6984da23e
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2463;
x-ms-traffictypediagnostic: SN6PR13MB2463:
x-ms-exchange-purlcount: 1
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyNDYzOzIzOnh5VmVMZUt6R3RLbU9CQ1MvU0dTdXFLM3FM?=
 =?utf-8?B?M09GRU5GRkxwaVVvNXQ3eHVTWDdMemlWMHBjbTBwUGZ1NVhRK2JaaXY4enhU?=
 =?utf-8?B?QzIwdWt1U0ZyZkcrSWw3dG9DdlhuYzc2a1AwY2lmajZMRUI5ZVlBMkhvTW83?=
 =?utf-8?B?TWdWQ0crVDlhVEUxZHQwbGYyMlJuZGVMNXhwcXdjMXZNazVKb0grdGpIWW1I?=
 =?utf-8?B?WHIzZllaSWRQb2c1emtFekYvT0RSdXpPbWcrU2cxRE5ya0c2b0Q3L1BVeE84?=
 =?utf-8?B?aFZtakREdEZNWFBsVTFTcEtDUG9UcjZKTmxlRGsrSnFBWDFaN2ROQm9Jd2hE?=
 =?utf-8?B?cVhzQ3hXMkpjL2R2RTh0Z2lJdW1DaitzY1FkZ2p1QjBLMk5uMHdjd1g0YWhF?=
 =?utf-8?B?NlBiZUtRRjN6UFBZYlF0YzVybkVXSlYzdjBFSC9iazduYWhsTll5MFFBd1BD?=
 =?utf-8?B?Nmtpak14YkpFdHkzbFhKT1FteU5UYkVaRGtmZTc4amNyV2dqbHVJTWRhQk5Z?=
 =?utf-8?B?YUE1bG5BSTQ1SmlTWVdKNVllYVZXM3Q0UDBpSmY1emJNTU1FM1RtUGF6bjNK?=
 =?utf-8?B?eG1BdGQraHpzVzNRbU52S1h5WUZ1VHhTYlZ2U3N4aGJydDVLZGJObEM0NXRl?=
 =?utf-8?B?RzhyaElEQUZmSWd4ODVNQUV5SFdRL2pVRSsydTFUYTgrM0tGaVR0dnhkV28x?=
 =?utf-8?B?bkhlRDFQQTEzb0swV092VnZFbVVNT2x6eWM4TDZQZ0lpZmUzZTd5VkZYRWdk?=
 =?utf-8?B?T1RlcnhvSUorZEZJTEhYMlBvNk9WNXRIejJNWEhXOGtSbDZkcTZBeDF6U1hy?=
 =?utf-8?B?TUVlSWNzYUNnRERCR3pUYWxPZVhmdTBLNEFsKy90OTkySkVaL0lnelp3R1g5?=
 =?utf-8?B?M3l3YktmdmFwM3RlbDFic2hvaGp6Z2FWNHZJaGl3cnBuYkIzdmFSU2hQT28y?=
 =?utf-8?B?eFp4YjNzQ0t2emlBVk9ZdUtUQXZxdXJZVktNSllaZElqaWQ5SmZ5L2pMMncr?=
 =?utf-8?B?TTBsYVBXdlU3aDVOU3BMY3hoclE5T0cvN05TbW9QY3JIeGZZMXZkOXlQTWZn?=
 =?utf-8?B?Y2x5a2hXODV0NlRha0JBZnI0ZjJhNDdFV0xvTmhMd0xKem5nWldZUGZ0UHlJ?=
 =?utf-8?B?em1RU1JGWHpNU0FXKzBpeklhdXlGMXF5T3BaaCsvTXptN3htMnV3RFJEbUJB?=
 =?utf-8?B?cHhjTWhFa2ozTStHZU5YQytPblk4eklRZkN6YWJLMFhJUlhEZXg1YTd0QnRJ?=
 =?utf-8?B?eEUxYU1YOGZUL2RuRkRTemJjREE0YkhYK1RHUXB2dU9CdURETFF2MVlHNElm?=
 =?utf-8?B?dUY4RjZBZkUxRmE2SEQwOVg3R1cxcmRKRGVwbExaT2pndVF6YzZzS3Q0YmJs?=
 =?utf-8?B?elhQeVM1K3Y3Tm4wZDVWK0pSSmV2V0RwbnZIVi84N1BoZzBPTWt0OFkwcDQ5?=
 =?utf-8?B?c2R4czU5OTNnUGZMWktYQ2dkdFV3RkxTQTNzRTVFd1c4dVRMK0pWOW4xQ20x?=
 =?utf-8?B?SENiSmlNNWsybk04SXJhblg2WE55N3FBa29udkVRTXFucjJ6VXQ1VUVpQXd2?=
 =?utf-8?B?S0IxSEJNRUdtUWl0VVlxUWMwZW9JSW11eXlxbzBaVGZ2aEF1Z3ZQa3VFOS9m?=
 =?utf-8?B?MldpazI3VlRpUGNZcFlvNVpBMzBjaC9nWWZKN2pGTllxRi9kT2VscEczYmdM?=
 =?utf-8?B?K2RXMmYvd05sQ0doM0VsK3Vjamk3ZkhIdXNjYVpnbzhsNVFLVVpzZ09xbWZP?=
 =?utf-8?Q?Zi8Sbiqd+9EJC5Zt6Pa8QP3DWBL1Wj6XjZ8XE=3D?=
x-microsoft-antispam-prvs: <SN6PR13MB2463B118C8320FBE89F9171EB87E0@SN6PR13MB2463.namprd13.prod.outlook.com>
x-forefront-prvs: 09555FB1AD
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39830400003)(396003)(366004)(346002)(136003)(376002)(199004)(189003)(6306002)(446003)(2501003)(478600001)(11346002)(36756003)(2616005)(99286004)(54906003)(476003)(6486002)(68736007)(6512007)(6436002)(66066001)(186003)(97736004)(71200400001)(4001150100001)(71190400001)(486006)(5660300002)(229853002)(5640700003)(26005)(81166006)(6506007)(86362001)(6246003)(81156014)(4326008)(3846002)(8676002)(25786009)(256004)(6916009)(6116002)(102836004)(53936002)(305945005)(118296001)(316002)(2351001)(14444005)(14454004)(106356001)(105586002)(7736002)(2906002)(8936002)(76176011);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2463;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 1HCWIUm8jpXPfzcJxvBL/XAuwYQO/8yFIt4RjEL69sms1a4bM6i7gaUQCF5ChZpCbbjsW+ykcgaGjVPPAoe3qFbFfvWE6LE6B0SUHfZYimJTFp2LMXFPNolGgpIbNCI+oep5BiV9bDBKtQtx+DxKdfOMon31jV82rQcNQTLJtAkqhY3UhgRngG41w2ArVbtDaHC81xxqS09wjuMJ2RVygqrBU7Gvh60sHEMVUFh8Q9akxpeV9spXsV+yDHndaGvRf4VDc8tKd+7BLK/Tq8Y4QsC+FDIvqCahAiuyF9l6mv3LsALuJ896yEIi8w15fsgorgVi9d4IFHSuUMN7uPa5nqmlH5uFB5aRWJdUKz7zJFXJ5L6Pe2JI+8sM+hA9x2xVbLarph3nv19AKLK6YEHIuaOS9Eq5kR+QuREp6SRMgwM=
Content-Type: text/plain; charset="utf-8"
Content-ID: <AD5C7FC5E679694DAAE7A23503C834D4@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 1d46ca4d-9feb-4030-10f0-08d6984da23e
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Feb 2019 22:40:52.0433
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2463
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gU3VuLCAyMDE4LTEyLTIzIGF0IDA5OjU3ICswMTAwLCBKdWxpYSBMYXdhbGwgd3JvdGU6DQo+
IERyb3AgTElTVF9IRUFEIHdoZXJlIHRoZSB2YXJpYWJsZSBpdCBkZWNsYXJlcyBoYXMgbmV2ZXIN
Cj4gYmVlbiB1c2VkLg0KPiANCj4gVGhlIHNlbWFudGljIHBhdGNoIHRoYXQgZml4ZXMgdGhpcyBw
cm9ibGVtIGlzIGFzIGZvbGxvd3M6DQo+IChodHRwOi8vY29jY2luZWxsZS5saXA2LmZyLykNCj4g
DQo+IC8vIDxzbXBsPg0KPiBAQA0KPiBpZGVudGlmaWVyIHg7DQo+IEBADQo+IC0gTElTVF9IRUFE
KHgpOw0KPiAgIC4uLiB3aGVuICE9IHgNCj4gLy8gPC9zbXBsPg0KPiANCj4gRml4ZXM6IDBlMjAx
NjJlZDFlOSAoIk5GU3Y0LjEgVXNlIE1EUyBhdXRoIGZsYXZvciBmb3IgZGF0YSBzZXJ2ZXINCj4g
Y29ubmVjdGlvbiIpDQo+IFNpZ25lZC1vZmYtYnk6IEp1bGlhIExhd2FsbCA8SnVsaWEuTGF3YWxs
QGxpcDYuZnI+DQo+IA0KPiAtLS0NCj4gU3VjY2Vzc2Z1bGx5IDAtZGF5IHRlc3RlZCBvbiAxNTEg
Y29uZmlndXJhdGlvbnMuDQo+IA0KPiAgZnMvbmZzL25mczRjbGllbnQuYyB8ICAgIDEgLQ0KPiAg
MSBmaWxlIGNoYW5nZWQsIDEgZGVsZXRpb24oLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9mcy9uZnMv
bmZzNGNsaWVudC5jIGIvZnMvbmZzL25mczRjbGllbnQuYw0KPiBpbmRleCAyNTQ4NDA1ZGExZjcu
LjczNWMxMDU2YTkxYyAxMDA2NDQNCj4gLS0tIGEvZnMvbmZzL25mczRjbGllbnQuYw0KPiArKysg
Yi9mcy9uZnMvbmZzNGNsaWVudC5jDQo+IEBAIC0xNDUsNyArMTQ1LDYgQEAgc3RhdGljIHZvaWQN
Cj4gIG5mczRfc2h1dGRvd25fZHNfY2xpZW50cyhzdHJ1Y3QgbmZzX2NsaWVudCAqY2xwKQ0KPiAg
ew0KPiAgCXN0cnVjdCBuZnM0X2RzX3NlcnZlciAqZHNzOw0KPiAtCUxJU1RfSEVBRChzaHV0ZG93
bl9saXN0KTsNCj4gIA0KPiAgCXdoaWxlICghbGlzdF9lbXB0eSgmY2xwLT5jbF9kc19jbGllbnRz
KSkgew0KPiAgCQlkc3MgPSBsaXN0X2VudHJ5KGNscC0+Y2xfZHNfY2xpZW50cy5uZXh0LA0KPiAN
Cg0KVGhhbmtzIEp1bGlhISBBcHBsaWVkIHRvIG15IGxpbnV4LW5leHQgYnJhbmNoIGZvciBpbmNs
dXNpb24gaW4gdGhlIDUuMQ0KbWVyZ2Ugd2luZG93Lg0KDQotLSANClRyb25kIE15a2xlYnVzdA0K
TGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0
QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
