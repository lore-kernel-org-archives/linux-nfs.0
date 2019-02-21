Return-Path: <SRS0=V3X6=Q4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F6DAC43381
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 22:36:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 23C6A206A3
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 22:36:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="kYSABzfe"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726123AbfBUWgF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Feb 2019 17:36:05 -0500
Received: from mail-eopbgr770117.outbound.protection.outlook.com ([40.107.77.117]:33641
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726075AbfBUWgF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Feb 2019 17:36:05 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Vg78ZobTJBY5+iDig8dgDQFTW1rx8qxNF/5jgI+xGAA=;
 b=kYSABzfe/45FFvWsrWqu7QpRgq8E6juW+WbrDnah/7qvf+qbvVOXgnihiU+oG+589OaK1UxAUHQRdLxB5SxYlq/Gf5E0dAWFreyXA39R1d3jV4W526p6k5eyi+CdQ3sDaF4tGdugXxFtZKawOt8yn5iqMIIBKCqOGC0QVy2NRXY=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2365.namprd13.prod.outlook.com (52.135.94.145) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.6; Thu, 21 Feb 2019 22:36:01 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%3]) with mapi id 15.20.1643.012; Thu, 21 Feb 2019
 22:36:01 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "zhangxiaoxu5@huawei.com" <zhangxiaoxu5@huawei.com>
Subject: Re: [PATCH] nfs: fix xfstest generic/099 failed on nfsv3
Thread-Topic: [PATCH] nfs: fix xfstest generic/099 failed on nfsv3
Thread-Index: AQHUx5mb3ExT6QSXUESZfNAf4FfYXaXq3HAA
Date:   Thu, 21 Feb 2019 22:36:01 +0000
Message-ID: <0595f47e0a2efd2a94139f820ed4717c859dfd38.camel@hammerspace.com>
References: <1550501803-27999-1-git-send-email-zhangxiaoxu5@huawei.com>
In-Reply-To: <1550501803-27999-1-git-send-email-zhangxiaoxu5@huawei.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e418fa99-c2ef-4426-3feb-08d6984cf52c
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2365;
x-ms-traffictypediagnostic: SN6PR13MB2365:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyMzY1OzIzOnJHMkp2Y3JNeUtoWS85VnExRENvQnNiT1M4?=
 =?utf-8?B?YUhEY01QQittNkRTei8ybFlQSFZzRXlPdUFXdnlLQy9GTzJGTFArNmdyVFlr?=
 =?utf-8?B?eEZZSmlLRlNOai83ekxTUlVFTFJNMEdQMnc3ZEtEYWlGOHQ5L2tzaVlKREpj?=
 =?utf-8?B?Wld4OFRHbTM2dFdTdXYyVXVXOFE2V0RsSlpoeUZPTlB4SzRpRFlzcW0zczRO?=
 =?utf-8?B?Z1ZNUjhyM25TaUFhVldBNjVaL1dBSmtlL2ZXNzF3amRLNStrWVBKWkExb2Rs?=
 =?utf-8?B?aFgyRXNjTWpueEk1R09TcFFVc0phbDVBTnRsNU9aS2RYcmhGU3QrTDJRRUk4?=
 =?utf-8?B?MHZFVTl5UnBkWWxsT01Fc3o2eEQwY2NEbGtNMW1NNFRiSTdWdE84SG1zQlpZ?=
 =?utf-8?B?ditOSlY0bnRVN0FuRVlJTjRIY281ak8ranFZaUFWeGxtVkVQbCttTmt4Q1Jv?=
 =?utf-8?B?dThtQ0JWUjh4cGw4UnZHVU5tQWQwR1JUdUdkUm1vdzdDRWZKMytPSkdISVdH?=
 =?utf-8?B?SEd0RW9VT0svNU8xYzJ4REhjcEZWK3dNQm1vb09EcmtsaFd4WWFybWRPejVk?=
 =?utf-8?B?Sm0vbVlybi9HVXBNaWt1Qk43b2pvellnNWtCNloxaXVRby9nazBrbUVSWDJU?=
 =?utf-8?B?ME9IanJnTk8vYWFROGh5Y1hCT1ZxZTdoZXg2WDJMUU12MzZGbkpyVGJzek4y?=
 =?utf-8?B?MkZkVU52a2JxNStBWHA3bGVtQ2xEdE83TXh3akdxQUtBTDVmL2Rkei8xbVhh?=
 =?utf-8?B?RnpaVzQ3WkRjLzZPdmJDbVBwYUZwRDN6bWNwQkZCcnpPVlFwSGZuWlFmeGdM?=
 =?utf-8?B?NHBKTFc0NDJkTXY1bm5yd2w0WjFMWjlRRVU5YnhtNHNGVmwwckptYjlNZmcv?=
 =?utf-8?B?SHVJbnBybWVTclZqcmhXRXBBM3NtN3lKMEU1TVhRVERFMkttcHBzZk9EMzU2?=
 =?utf-8?B?NDkyd0JnSWVmVEk4REFscGU0Z0wvVXdkYkhmQmFlZG9NTkk4VDJwckFkd0U1?=
 =?utf-8?B?Wk5OcXlWZ0YwZVQyaUI0aG9YTGZnMHNMTFRwNzN0b1V4K3g4S3dxSDhJU2dj?=
 =?utf-8?B?ZkVxREZuU2N4eEV0aDE0WWR6MEJPbTh6WHZ0NUZQK2hnRFprRVFrRnBxbGZQ?=
 =?utf-8?B?eVJQbVpYMHhoQ3BucUs2d3lZRjdZTFRMdzA4RVk4dCtUOFMxMVNKREkrY2FF?=
 =?utf-8?B?Tk96Sm4rZG9Mc1dYOEFwLzBOblZmbGtobDc4WXVLaHBRS3JsbGNEVi9JNUdU?=
 =?utf-8?B?cyttY1lNRUJmR3FNQnNFMVJQSFcyS3pCRTQ3aVo5UmFGWTJ0MEJzUnd1ck9h?=
 =?utf-8?B?YnJwMGhkbytSdmVTNzlaS2owVzhQT2k3dmNpYnJXcUJ2Ui95Uk1yS1dxSkMy?=
 =?utf-8?B?RGp4NWdpNFEwMkxvb0I5MlRxZmk0Rk5NTHcyakdSamQ2QWpIUVIvSHRWZlIx?=
 =?utf-8?B?T0NhRnpWbHBaTHhTazdwL1kxajQ5cDNnYzVZYXNUQmxvbVQxeHp3SGVFRDR5?=
 =?utf-8?B?ejYzWVM4WTBqc2JwZXNHTVVBVXVOY0FHbjl6eXZ4dHZOZ0ZQY216bHhaTllQ?=
 =?utf-8?B?U2JGU09Zemh5VkhEL2dSREFBZG9ET2FSdi9vL1IwVmRkSW5PU0tlM00xVzdU?=
 =?utf-8?B?UUZudGlvVjFrbWlmQUN2Mkp0T3RlS3FGYlJtR2ltOGpHV0xBeXFKRndhczJI?=
 =?utf-8?B?MzhXYml4ckx6OHcwSXlvNHVKU25KeFFaTGNPTXJhNWJoWVVINERHR2FLRU83?=
 =?utf-8?B?eXFhVlZlV3Y5T0dMYlVLZWlSbDFUWkpRWXBlTG54QkFIR2ZxM2gxS2lhRnNl?=
 =?utf-8?Q?4l/AXRY2vqthd?=
x-microsoft-antispam-prvs: <SN6PR13MB2365B15D685D620E900A8F0DB87E0@SN6PR13MB2365.namprd13.prod.outlook.com>
x-forefront-prvs: 09555FB1AD
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(979002)(376002)(396003)(346002)(136003)(39830400003)(366004)(189003)(199004)(5660300002)(229853002)(2906002)(6246003)(105586002)(106356001)(2616005)(8676002)(118296001)(6486002)(81156014)(81166006)(476003)(6436002)(6512007)(446003)(7736002)(11346002)(486006)(305945005)(256004)(53936002)(14444005)(186003)(25786009)(71190400001)(71200400001)(8936002)(14454004)(26005)(102836004)(2201001)(6506007)(3846002)(68736007)(6116002)(478600001)(110136005)(2501003)(99286004)(316002)(36756003)(76176011)(97736004)(86362001)(66066001)(41533002)(969003)(989001)(999001)(1009001)(1019001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2365;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 1ZMuS4N12R3Nx9iZ1eWBG4Dx93IL+rYchxiXWNxUDFf3LyGDzHRxzqlb8rhMiIWBuwKWBQh/03uZy1rRiWiFx1HeG1NtLn9EZ9grIQ9muEDC6QlQ0qj5wtR4ADC7PF1JqUq7jkCOQ1E436dQpMdwxYkHNpiDo41HI0aTII4Lu9LzLLLdRGAoxYTWi0qdKNddDmka+MQHqCyUFkScRMQDA0aOSOupoYliq9zuPaxdSmhifyS837SkVfjaO41VhK4coF39oyN7mOsheNCBrwXZnhzHqo22wlZffyVyvae8WXQh0tv+KaYvIqPhNiar8BAFVTxC7RoSQCqf16ELZVBp2MwNl/CuTwhvqZHGw4NlWkpUFaP0IZ5VCG3I2naqZrb9V30olslxPrFdPk+M/fPGR7bsirspMvddJC4nb8aLDDI=
Content-Type: text/plain; charset="utf-8"
Content-ID: <0A2C4724BB08BE47B85DF2592FB8AF8B@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e418fa99-c2ef-4426-3feb-08d6984cf52c
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Feb 2019 22:36:01.6177
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2365
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE5LTAyLTE4IGF0IDIyOjU2ICswODAwLCBaaGFuZ1hpYW94dSB3cm90ZToNCj4g
QWZ0ZXIgc2V0eGF0dHIsIHRoZSBuZnN2MyBjYWNoZWQgdGhlIGFjbCB3aGljaCBzZXQgYnkgdXNl
ci4NCj4gDQo+IEJ1dCBhdCB0aGUgYmFja2VuZCwgdGhlIHNoYXJlZCBmaWxlIHN5c3RlbSAoZWcu
IGV4dDQpIHdpbGwgY2hlY2sNCj4gdGhlIGFjbCwgaWYgaXQgY2FuIG1lcmdlZCB3aXRoIG1vZGUs
IGl0IHdvbid0IGFkZCBhY2wgdG8gdGhlIGZpbGUuDQo+IFNvLCB0aGUgbmZzdjMgY2FjaGVkIGFj
bCBpcyByZWR1bmRhbnQuDQo+IA0KPiBEb24ndCAnc2V0X2NhY2hlZF9hY2wnIHdoZW4gc2V0eGF0
dHIuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBaaGFuZ1hpYW94dSA8emhhbmd4aWFveHU1QGh1YXdl
aS5jb20+DQo+IC0tLQ0KPiAgZnMvbmZzL25mczNhY2wuYyB8IDIgLS0NCj4gIDEgZmlsZSBjaGFu
Z2VkLCAyIGRlbGV0aW9ucygtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL2ZzL25mcy9uZnMzYWNsLmMg
Yi9mcy9uZnMvbmZzM2FjbC5jDQo+IGluZGV4IDlmY2UxODUuLmM1YzNmYzYgMTAwNjQ0DQo+IC0t
LSBhL2ZzL25mcy9uZnMzYWNsLmMNCj4gKysrIGIvZnMvbmZzL25mczNhY2wuYw0KPiBAQCAtMjIy
LDggKzIyMiw2IEBAIHN0YXRpYyBpbnQgX19uZnMzX3Byb2Nfc2V0YWNscyhzdHJ1Y3QgaW5vZGUN
Cj4gKmlub2RlLCBzdHJ1Y3QgcG9zaXhfYWNsICphY2wsDQo+ICAJc3dpdGNoIChzdGF0dXMpIHsN
Cj4gIAkJY2FzZSAwOg0KPiAgCQkJc3RhdHVzID0gbmZzX3JlZnJlc2hfaW5vZGUoaW5vZGUsIGZh
dHRyKTsNCj4gLQkJCXNldF9jYWNoZWRfYWNsKGlub2RlLCBBQ0xfVFlQRV9BQ0NFU1MsIGFjbCk7
DQo+IC0JCQlzZXRfY2FjaGVkX2FjbChpbm9kZSwgQUNMX1RZUEVfREVGQVVMVCwgZGZhY2wpOw0K
PiAgCQkJYnJlYWs7DQo+ICAJCWNhc2UgLUVQRk5PU1VQUE9SVDoNCj4gIAkJY2FzZSAtRVBST1RP
Tk9TVVBQT1JUOg0KDQpMb29rcyBnb29kLiBJJ3ZlIGFwcGxpZWQgaXQgdG8gdGhlIGxpbnV4LW5l
eHQgYnJhbmNoIGZvciB0aGUgNS4xIG1lcmdlDQp3aW5kb3cuDQoNClRoYW5rcywNCiAgVHJvbmQN
Cg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFt
bWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
