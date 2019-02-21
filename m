Return-Path: <SRS0=V3X6=Q4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82B17C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 22:39:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 490E420665
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 22:39:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="kde1o6yE"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726074AbfBUWjT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Feb 2019 17:39:19 -0500
Received: from mail-eopbgr690120.outbound.protection.outlook.com ([40.107.69.120]:21815
        "EHLO NAM04-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726035AbfBUWjT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Feb 2019 17:39:19 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=UzCK9kJkh/4bLMgex/xZFn7RZ5dU8ksIWmIR6shZNGg=;
 b=kde1o6yEBA80/rIUqGrXQA58/5jqLsio8QL0bQZfxLrANeeCkZmuEnFkjsgc+KOM5Y00oTzVLkq9KsDh0KSn6gdWyY21GffxmqIHX2x0AFcaoaqX3tiruKuSRyxpZagxQUyS2E74bVw0dqAl21I7CAaZGdz3CcF660kcxDGo9m8=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2496.namprd13.prod.outlook.com (52.135.95.150) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.10; Thu, 21 Feb 2019 22:39:15 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%3]) with mapi id 15.20.1643.012; Thu, 21 Feb 2019
 22:39:15 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "neilb@suse.com" <neilb@suse.com>
CC:     "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: remove pointless test in unx_match()
Thread-Topic: [PATCH] SUNRPC: remove pointless test in unx_match()
Thread-Index: AQHUplXHClkTaW6RkkCPVbaWTLjyoqXrH92A
Date:   Thu, 21 Feb 2019 22:39:15 +0000
Message-ID: <ac353cb75792fbeea79fd53c4e477bee455a6ae5.camel@hammerspace.com>
References: <20181221091024.GF2735@kadam>
         <87d0p9j6v3.fsf@notabene.neil.brown.name>
In-Reply-To: <87d0p9j6v3.fsf@notabene.neil.brown.name>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a406778a-6c07-4cc9-410e-08d6984d6895
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2496;
x-ms-traffictypediagnostic: SN6PR13MB2496:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyNDk2OzIzOlpsL2RrWGJ1K3hnNHRJODhtODZOQ3d2OWdh?=
 =?utf-8?B?VE1pVXE1Y3BVWFM0Y2d5TDJBaG9XK3dRdHZ2U1RvcGtHalBoN2tHUmt4dXp4?=
 =?utf-8?B?QjVLSjU4T2ljcEtnSGE4Vzc0cWRNc1craUg3Zk1OQ0NPQk45ZlNGYmwyREZS?=
 =?utf-8?B?Z3BnQ1pPQTlrbVk1NUpZcHVTakVOang5NWRZNG5TTTA1ek54UTJIb0JLbHBD?=
 =?utf-8?B?Mk9DV3BoVHVvY0Zmc3B3NmR6QXE1eUNvemtNbmkyNGdraGZZUXJEcE1uR0xD?=
 =?utf-8?B?V1Q3alN6NmxHNVk1Y3NIYzJDUXZML1BCME1oMUxpMzNQS0lGcllPWkM1NTQx?=
 =?utf-8?B?VUZOZkhqYnNyVjZSenRjcGNHM2srWEZPdEF0bTNGTzRTVUhJSkZkaFZZcVZm?=
 =?utf-8?B?dFBIWWVyeFUzZ0JxYjE4dGJOMlV1bUtWbmdNN1NrWldtQzRJWHVPQldKTlM2?=
 =?utf-8?B?STRaVlc0elQvYVdGT2dsZUsveTIwRmZsL2ROaUgvZVlFVG8yM2R2S0daOHVS?=
 =?utf-8?B?T3FxOWhDYkZqNE05cmI4akdoVkRWTWsrNkVFMFpleit1Tmt1SXBrT3hpTWFL?=
 =?utf-8?B?YkpRRTdHNTY4YiswOE5mS2p1M2liQk5TcklHS3NjbHVVSUt1RGd3NDdGdVVS?=
 =?utf-8?B?UTNERklxSXI1TndUenQwV0RHenhaaWlWbmticzdGT3JWN3RIc3pzSlBET3pX?=
 =?utf-8?B?YXJ0Z2tZZHk2ODRjVGlUcUZEd1Y3UkIrM3VOaU1QaVZhSSt3dVpJMGxWLzNx?=
 =?utf-8?B?bFdBWWdWNkVmdjJMNGFINlRldmZHemdtN0hJeDRjYUt4aU5QQ3FFdUp5NTBD?=
 =?utf-8?B?QVFhWUNBR0VoUkgvQi94OEx3UlEzU2RrT1B6Sm5jREVYMjNOUy9lZFVJampm?=
 =?utf-8?B?QXNYbk9NajFzNkdDZEFCQUd4MUhuMUl2RFpnVFpnVnB6Tjg0RmNBcmJVekt3?=
 =?utf-8?B?NFd0aEZldkxIa2srdEdkSGZkbXFGbnphZDlmWWt0aVNnU1R3TUtROGVwZjFm?=
 =?utf-8?B?VXdrQnNabThOalhRb3NkTWRqUTBlS0hQSXVoQ3UvanFKUE9nUTFmTnJ6KzNj?=
 =?utf-8?B?c3VIb0E3RkhFMVFxS1Z3TmdGMSs2b1NCSTM2YU5pSEdBNFJLUVNSMXQwUHQz?=
 =?utf-8?B?QkhEdmR0SytKdUJDSW02alFQKzMwSXloOU5FMXJ2YTFvamZpQ2Fqam04MEgw?=
 =?utf-8?B?RUptcVFMQVZCQlVaQXNxN2JwVzVsTFNremRrajBMZlJ5K2hONVpVYm1rSExG?=
 =?utf-8?B?bS9vUDYrOTRxUmlQN2Z2VVRHQ1hZSWcxSWZJNVR0WVlPMHRVNEpvSDllMDd6?=
 =?utf-8?B?NUtMeFErdHV4MEQzT2V3VDk4WTZqOGptUXFUL0tqVi9JTi83L3ZWWnBuY0ht?=
 =?utf-8?B?RnpyTUpVSHg5OXQ1L2x4blVSQnMyUHIySmFDSkdyTzdMcUpaRi9oNVUyNEtZ?=
 =?utf-8?B?T2E0cnFLeHlNbGpJVVhHdStEZkZ1c0xKK3NWZWZ2dExUeGtLUmtjcW1wdlBQ?=
 =?utf-8?B?b3V4WUdibTZxclh0Zko3WkNuWWFnRGdKSGs0WjRCNGU4VDVMZlRRa3JOTlda?=
 =?utf-8?B?ZC9KZi9yUkNvRElqSHpreDdNMUdTQ0lJTjlGQ2ptalNIYURjWkJMN01ZemNq?=
 =?utf-8?B?MW50MUVYY2cvd1pIWFVHVUJWNEovekFFNDdOTWw3eVhOVGkzK09iSzdRPT0=?=
x-microsoft-antispam-prvs: <SN6PR13MB24960DD306E9C2E12DADF719B87E0@SN6PR13MB2496.namprd13.prod.outlook.com>
x-forefront-prvs: 09555FB1AD
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(136003)(39830400003)(396003)(376002)(346002)(199004)(189003)(3846002)(86362001)(6116002)(68736007)(486006)(71200400001)(6246003)(36756003)(229853002)(8936002)(26005)(2906002)(7736002)(4326008)(71190400001)(110136005)(81156014)(8676002)(81166006)(186003)(4744005)(102836004)(54906003)(476003)(25786009)(66066001)(11346002)(97736004)(5660300002)(305945005)(106356001)(478600001)(76176011)(6436002)(2616005)(105586002)(6486002)(14454004)(256004)(446003)(316002)(6506007)(99286004)(6512007)(2501003)(118296001)(53936002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2496;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: RaFgEw60OPyaI5Q68tuQqZk4pyUeBzGJms8etgxcd8HkaTud1h402OoEQ+0XTDun0B7TH/55TxS3Bf8G6Q8BDNMNluqZftibJXJZ+aoVVHYw93Il+0gKzJp1IvEhNKNEG5IFJN7cKhhEXfLvQZDyZKwF8Y56A21bvVZLFWaHLXXm3VO/b+45A7LvZm3ywTGSqpA8IwR/WQ6BIxDcnAO9cQ1OvAihaRdT3GuVlCIoOLcmIFMsUhcc47OEm3IeoLXMJTy0B+Yc4tClyrLv3VxIR3k9hb879voqJTjGPkSKk7dDSaTccJd/+46puisJDcfi6642yhQbY9HLXUOUd0U+1leQT3lxrw4luw1maN2UC5I6Rbar2Zntkh65irx00KcYUPr5TqmrC5kxnC/uP8sl6t6XQ+/gchUuIzeflRLn/oQ=
Content-Type: text/plain; charset="utf-8"
Content-ID: <E04C9339205DC34792FEF7E69B97ACFB@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a406778a-6c07-4cc9-410e-08d6984d6895
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Feb 2019 22:39:15.3239
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2496
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE5LTAxLTA3IGF0IDE3OjUzICsxMTAwLCBOZWlsQnJvd24gd3JvdGU6DQo+IEFz
IHJlcG9ydGVkIGJ5IERhbiBDYXJwZW50ZXIsIHRoaXMgdGVzdCBmb3IgYWNyZWQtPmNyZWQgYmVp
bmcgc2V0IGlzDQo+IGluY29uc2lzdGVudCB3aXRoIHRoZSBkZXJlZmVyZW5jZSBvZiB0aGUgcG9p
bnRlciBhIGZldyBsaW5lcyBlYXJsaWVyLg0KPiANCj4gQW4gJ2F1dGhfY3JlZCcgKmFsd2F5cyog
aGFzIC0+Y3JlZCBzZXQgLSBldmVyeSBwbGFjZSB0aGF0IGNyZWF0ZXMgb25lDQo+IGluaXRpYWxp
emVzIHRoaXMgZmllbGQsIG9mdGVuIGFzIHRoZSBmaXJzdCB0aGluZyBkb25lLg0KPiANCj4gU28g
cmVtb3ZlIHRoaXMgdGVzdC4NCj4gDQo+IFJlcG9ydGVkLWJ5OiBEYW4gQ2FycGVudGVyIDxkYW4u
Y2FycGVudGVyQG9yYWNsZS5jb20+DQo+IFNpZ25lZC1vZmYtYnk6IE5laWxCcm93biA8bmVpbGJA
c3VzZS5jb20+DQo+IA0KDQpUaGFua3MgTmVpbCEgQXBwbGllZCB0byB0aGUgbGludXgtbmV4dCBi
cmFuY2ggZm9yIGluY2x1c2lvbiBpbiB0aGUgNS4xDQptZXJnZSB3aW5kb3cuDQoNCi0tIA0KVHJv
bmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0
cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
