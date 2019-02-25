Return-Path: <SRS0=6MPh=RA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62335C43381
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Feb 2019 22:42:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 21AB020C01
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Feb 2019 22:42:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="c1SkrQIx"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727574AbfBYWl7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 25 Feb 2019 17:41:59 -0500
Received: from mail-eopbgr770137.outbound.protection.outlook.com ([40.107.77.137]:37728
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727396AbfBYWl7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Feb 2019 17:41:59 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=hA+tXepepHiPfKSOu/zfKYVyHQDzLoXzal2g509SWm8=;
 b=c1SkrQIxmGFoSoMw9dqnsy3dnfjwhn6jT6CXObgCDKRYK/7RU4QXZEOn5CjuKi+Gy+Yy3j4vM4nWjmPA3zA5lpjTgctJu7UZpywAWeEeW3kMrqx72gjhzIpiEFaD4qxkk4GZMFN7jE+q3CM1xPEX+KYpm67LPPp+YX0F0r4jE7U=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2365.namprd13.prod.outlook.com (52.135.94.145) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.6; Mon, 25 Feb 2019 22:41:55 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%4]) with mapi id 15.20.1665.012; Mon, 25 Feb 2019
 22:41:55 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "jonathanh@nvidia.com" <jonathanh@nvidia.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>
Subject: Re: Regression: SUNRPC: Use poll() to fix up the socket requeue races
Thread-Topic: Regression: SUNRPC: Use poll() to fix up the socket requeue
 races
Thread-Index: AQHUzUhAfjY8UpPesU2cJZ8XbzkbuKXxAJ4AgAAXXgCAAAQNAA==
Date:   Mon, 25 Feb 2019 22:41:54 +0000
Message-ID: <9b9a6c5e34edea13b3ace42d39d97c27fd21c0db.camel@hammerspace.com>
References: <95702994-6762-e42b-06ee-ae945c2137bd@nvidia.com>
         <ab485d7ba4f9603850b81e6c2242dc25026eabcb.camel@hammerspace.com>
         <88677895-7f89-ae1d-3060-819f4b04f530@nvidia.com>
In-Reply-To: <88677895-7f89-ae1d-3060-819f4b04f530@nvidia.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 10cf53ff-77fc-4f08-e001-08d69b72715d
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2365;
x-ms-traffictypediagnostic: SN6PR13MB2365:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyMzY1OzIzOks4YXZFZzdjNTN1Z1d1MG52MjZvMWd5dEZp?=
 =?utf-8?B?MEdmaDlQZzBPY0xDT1ErbzE0Umowd0tjdnJDNVFhQjhndnBCdnl3UmtxQnVz?=
 =?utf-8?B?V0RwTmk1UDhwY1ROUEVOSGVzRS9CM0x4dGd5MGROT2RsaEZtVkhPeWFTeVRM?=
 =?utf-8?B?NytWUG9mdXNFYU1UeitzZGdLSDhuTmNPcU1SbWluUWtnWFpXejk5bHlHbUF5?=
 =?utf-8?B?Q2tsNXBhWFZqaTRlSHRKc1NkbzIvOE9xS09Rd05CbjMvTDkyNVhZSk5VSnpl?=
 =?utf-8?B?aXFZaWRXa2VXV2hRUFh3SXFneFM1a3YzOVdkSWF0RjlvemFKbWhqaFlYN1NX?=
 =?utf-8?B?ZE12eDFoWVd2MnRnZFVxbVV5R1MrT0Q4Y0s0WUVUMWFINTljeTZxWlZxZHBn?=
 =?utf-8?B?S2R2TmNEKzVRdVpVVGxNQ1N5dnZkSkRzdnRuM28vdExGV1NnZ3UzdlpFYXNl?=
 =?utf-8?B?YzY1dU5ySmxWeTREaTZIbDF1S3lmeTNQdEZsdW1rdWt6R2NBcUw1V1BDRW8w?=
 =?utf-8?B?UVhnaDJEZ0hiNmY2dEp4bmFRVG1aeUExUWZjRm9yMFV5b25hZWR4MnoyVFZ0?=
 =?utf-8?B?NHZOV01QSXd5eWlGTTgxMDBHUW50bHg1SitReThzdm5MaDl6QmpUMmRwM0hZ?=
 =?utf-8?B?ck1neit3N212ajdYeVFVQnIzWEsxSVVDQ01DTG13WEFSZHNucS9sS2MrQXhR?=
 =?utf-8?B?Si80L0lwclRZSmM1c0JtYWtJTGJCd0lXdkNSeFpRcjBkYWtxc3pPRFNhaEpo?=
 =?utf-8?B?a3ovUWpNQ2NvZjMzUDdyT3FnNklXTHljLzRITmtnRDFKR1JFQXNJVzVyelUr?=
 =?utf-8?B?V0xDOW1tK0VteStTMmpWSnJlU1RtdFBUQW05Yis2c3RBdEY5RjZMSFN5enBG?=
 =?utf-8?B?L2ZrQUdqVXNnRjhTOGxOSEJVcS8zWnNMOGtFeEkrZ1JkYW8vd3pMOGJnYkZU?=
 =?utf-8?B?UnJrK25iOWk3WTJUWmY1d2Z2M3pzMkJicC83WVlTVDRtTXJpMXQvVWkrenVN?=
 =?utf-8?B?Vk1LODU3MUxZVUhPdlgxb0pmc0NwcmVWdUR6R21qTitSbTgwZ2ZzcENrMmlw?=
 =?utf-8?B?L1d1bUovYk0zQ2JvZzBBT1NqVFl0dk54Zkg5M0Q1WHJ2Q296VjY2dTRUcmti?=
 =?utf-8?B?SnBtY2Z5V0IwWHNWcGoxU0N2RU9EY2VlYStTUGNNQnZtaGVYeDJQNXl5b3BL?=
 =?utf-8?B?eTY3aG84U3lLU3JzTE5nYzhsazBFZ1dnbnlhWjFUQVpaOE5CWFh5ZnpmakJE?=
 =?utf-8?B?MXZPLys0NnpKa0lTelJTRlZuait4eC9WQ2IrL2djYTE4WUp1N1M1ZWorMHFy?=
 =?utf-8?B?d1pPaDZaUlVxUzVyZUVvL1BkSXV4K1ZzclZVN0hCM3lqUFIzR0hzekJCSURm?=
 =?utf-8?B?UHJFM3BwdXdvOTNUWU1JSkp1bk1GQ1hCcmRnRkoyS3diZDdjMElnWWpUQXNw?=
 =?utf-8?B?MDJzUjBWeUlQcGZTcGJUTjQzcUlSd0JiUDB6K2ZkUE5OMER4YTdhQ3F6b0FL?=
 =?utf-8?B?WTQzTWlUb3lXbCt1dVRXWmlpdDU3ZVBXWWhhbk9Td2RkazdDQmNtQ2RUWWZV?=
 =?utf-8?B?S1R6bkxmZmdaZFp4K0hxTmp0RE9MNlorb2ZEdm9oL1ZGeW54WDR3R2tBTUFD?=
 =?utf-8?B?Z0hjSURTQTFzQTZWR2xsb3pqNFBFdHIyTXExclNwbWZyU2dldGc0emYreWVE?=
 =?utf-8?Q?UIMFmIbCddXRgWXf5XlvnAW/63562Lk4HYpFNVq?=
x-microsoft-antispam-prvs: <SN6PR13MB2365DE55B72613017F9AF1DEB87A0@SN6PR13MB2365.namprd13.prod.outlook.com>
x-forefront-prvs: 095972DF2F
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(39830400003)(136003)(346002)(396003)(366004)(51234002)(189003)(199004)(106356001)(316002)(2616005)(305945005)(118296001)(76176011)(110136005)(6486002)(7736002)(6506007)(486006)(25786009)(36756003)(53546011)(53936002)(102836004)(476003)(81166006)(81156014)(71200400001)(11346002)(86362001)(446003)(8936002)(2201001)(6246003)(8676002)(71190400001)(14454004)(105586002)(26005)(97736004)(256004)(66066001)(478600001)(6512007)(45080400002)(186003)(68736007)(5660300002)(2501003)(2906002)(6436002)(3846002)(6116002)(229853002)(99286004);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2365;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 0FOlTYAlxQVCLL73hsOx8/g9pf4vtAPPnt38wxoA3sk9wPWPtO/OrFEHBUCZHu7Udp+P8yN3nJ/4CtlzT6sxy8k+srxyitVwRuybYkPloCzNaH0MfSSC5ayna7jO5QmFjHDpJct1oqBVmdQls2Kx0WVlBAEM4txYMURAs9f+8ixuzBe7PVp8EyTJ4ZxaVu9butyDdLrSazs5fXn+PmJ008XQ1VASPrX7OU8u7xTaEuec4qpMYWhOGEUl0XtV0GkBInxVw4OsdDfOqrTP8ETYsoL5ygp1LWmtafuxcb8fuK9x+IHb2mhkERlZmj8RzaZN1ODRgZcOIlhlijCnzcmMFr5pag12lAuUksoFrVB9M3m1S9oCxU1FPDyci0736hnfxHHfiUzmI473lUIA12bmqUEAfZRlbPC+LGfSlCp+BLk=
Content-Type: text/plain; charset="utf-8"
Content-ID: <7173E62304E3CB41814930014C5CC14F@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 10cf53ff-77fc-4f08-e001-08d69b72715d
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Feb 2019 22:41:54.9167
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2365
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE5LTAyLTI1IGF0IDIyOjI3ICswMDAwLCBKb24gSHVudGVyIHdyb3RlOg0KPiBP
biAyNS8wMi8yMDE5IDIxOjAzLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6DQo+ID4gT24gTW9uLCAy
MDE5LTAyLTI1IGF0IDIwOjI1ICswMDAwLCBKb24gSHVudGVyIHdyb3RlOg0KPiA+ID4gSGkgVHJv
bmQsDQo+ID4gPiANCj4gPiA+IFN0YXJ0aW5nIGluIG5leHQtMjAxOTAyMjIgSSBoYXZlIG9ic2Vy
dmVkIGEgcmVncmVzc2lvbiB3aXRoIE5GUw0KPiA+ID4gY2F1c2luZw0KPiA+ID4gc29tZSBvZiBv
dXIgYm9hcmRzIHRvIGZhaWwgdG8gYm9vdC4gQmlzZWN0IHBvaW50cyB0byB5b3VyIGNvbW1pdA0K
PiA+ID4gLi4uDQo+ID4gPiANCj4gPiA+IGNvbW1pdCAwZmZlODZmNDgwMjZiN2YzNGRiMjJkMTAw
NGJjOTk5MmYwZGI4YjMzDQo+ID4gPiBBdXRob3I6IFRyb25kIE15a2xlYnVzdCA8dHJvbmQubXlr
bGVidXN0QGhhbW1lcnNwYWNlLmNvbT4NCj4gPiA+IERhdGU6ICAgV2VkIEphbiAzMCAxNDo1MToy
NiAyMDE5IC0wNTAwDQo+ID4gPiANCj4gPiA+ICAgICBTVU5SUEM6IFVzZSBwb2xsKCkgdG8gZml4
IHVwIHRoZSBzb2NrZXQgcmVxdWV1ZSByYWNlcw0KPiA+ID4gDQo+ID4gPiANCj4gPiA+IEFmdGVy
IHJldmVydGluZyB0aGlzIG9uIHRvcCBvZiAtbmV4dCBJIG5vIGxvbmdlciBzZWUgdGhlIHByb2Js
ZW0uDQo+ID4gPiBJDQo+ID4gPiBoYXZlDQo+ID4gPiBub3QgaGFkIGNoYW5jZSB0byBsb29rIGFu
eSBjbG9zZXIsIGJ1dCB3YW50ZWQgdG8gc2VlIGlmIHlvdSBoYWQNCj4gPiA+IGFueQ0KPiA+ID4g
aWRlYXMgd2hhdCBtaWdodCBiZSB0aGUgcHJvYmxlbS4NCj4gPiA+IA0KPiA+ID4gQ2hlZXJzDQo+
ID4gPiBKb24NCj4gPiANCj4gPiBXaGF0IGtpbmQgb2YgYm9vdCBpcyB0aGlzPyBVRFAgb3IgVENQ
PyBuZnNyb290PyBORlN2MyBvciBORlN2ND8gDQo+IA0KPiBUaGlzIGlzIG5mc3Jvb3QuIEkgZG9u
J3Qgc3BlY2lmeSBhbnkgcGFydGljdWxhciBORlMgdmVyc2lvbiBmcm9tIA0KPiB0aGUga2VybmVs
IGNtZGxpbmUsIGJ1dCB0aGlzIGlzIHNlZW4gd2l0aCBBUk0ga2VybmVsIGNvbmZpZ3MNCj4gdGVn
cmFfZGVmY29uZmlnIGFuZCBtdWx0aV92N19kZWZjb25maWcuIA0KPiANCj4gTG9va2luZyBhdCB0
aGUgbG9ncyBJIGFtIHNlZWluZyB0aGUgZm9sbG93aW5nIGNyYXNoIHdoaWNoIGFwcGVhcnMNCj4g
dG8gcG9pbnQgdG8gVURQIC4uLg0KPiANCj4gWyAgICA4LjAzMjk1Nl0gVW5hYmxlIHRvIGhhbmRs
ZSBrZXJuZWwgTlVMTCBwb2ludGVyIGRlcmVmZXJlbmNlIGF0DQo+IHZpcnR1YWwgYWRkcmVzcyAw
MDAwMDAyNA0KPiBbICAgIDguMDQxMTM3XSBwZ2QgPSAocHRydmFsKQ0KPiBbICAgIDguMDQzODU4
XSBbMDAwMDAwMjRdICpwZ2Q9MDAwMDAwMDANCj4gWyAgICA4LjA0NzQzN10gSW50ZXJuYWwgZXJy
b3I6IE9vcHM6IDUgWyMxXSBTTVAgQVJNDQo+IFsgICAgOC4wNTIwNDldIE1vZHVsZXMgbGlua2Vk
IGluOg0KPiBbICAgIDguMDU1MTA0XSBDUFU6IDEgUElEOiAxMDAgQ29tbToga3dvcmtlci91OToy
IE5vdCB0YWludGVkIDUuMC4wLQ0KPiByYzctbmV4dC0yMDE5MDIyMi1nOTRhNDc1MiAjMQ0KPiBb
ICAgIDguMDYzNjk5XSBIYXJkd2FyZSBuYW1lOiBOVklESUEgVGVncmEgU29DIChGbGF0dGVuZWQg
RGV2aWNlDQo+IFRyZWUpDQo+IFsgICAgOC4wNjk5NjBdIFdvcmtxdWV1ZTogeHBydGlvZCB4c191
ZHBfZGF0YV9yZWNlaXZlX3dvcmtmbg0KPiBbICAgIDguMDc1MzUzXSBQQyBpcyBhdCB1ZHBfcG9s
bCsweDMwLzB4NjQNCj4gWyAgICA4LjA3OTE3OF0gTFIgaXMgYXQgdWRwX3BvbGwrMHgxMC8weDY0
DQoNClRoYW5rcyEgSSBzZWUgd2hhdCB0aGUgaXNzdWUgaXMgbm93IGFuZCBJJ2xsIGJlIGZpeGlu
ZyBpdCBBU0FQLg0KDQpDaGVlcnMNCiAgIFRyb25kDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpM
aW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RA
aGFtbWVyc3BhY2UuY29tDQoNCg0K
