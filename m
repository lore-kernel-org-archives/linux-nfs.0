Return-Path: <SRS0=yawm=RB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D5F6C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Feb 2019 20:40:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 46A5721852
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Feb 2019 20:40:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="nTORKGgu"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728766AbfBZUk0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Feb 2019 15:40:26 -0500
Received: from mail-eopbgr820090.outbound.protection.outlook.com ([40.107.82.90]:65184
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727981AbfBZUk0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Feb 2019 15:40:26 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=8lcs1UZ0YKYqd+7Izw2Q/oyf3L/beySPsbFwu9CqVYw=;
 b=nTORKGguEqfk01e+DaO5Icu/t/xWpBBlotzL7IyRAza8quV/0HOWut4JnWucBqLZ5tOtzI+vMirertGACRn5AdOiBH+vF1lx4pn+8OP0bFkn2tP/bVl3jjK5qnhcDW22y/Uo+2Ku6+zrCXdtMo8649xR3EMiKYl8ki0o40z71qY=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2573.namprd13.prod.outlook.com (52.135.96.21) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.6; Tue, 26 Feb 2019 20:40:21 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%4]) with mapi id 15.20.1665.012; Tue, 26 Feb 2019
 20:40:20 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "tony@atomide.com" <tony@atomide.com>
CC:     "jonathanh@nvidia.com" <jonathanh@nvidia.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>
Subject: Re: Regression: SUNRPC: Use poll() to fix up the socket requeue races
Thread-Topic: Regression: SUNRPC: Use poll() to fix up the socket requeue
 races
Thread-Index: AQHUzUhAfjY8UpPesU2cJZ8XbzkbuKXxAJ4AgAAXXgCAAAQNAIABTPwAgAAjYYA=
Date:   Tue, 26 Feb 2019 20:40:20 +0000
Message-ID: <eeb255aca46e9b1d9d030c5b917c663b83468bcb.camel@hammerspace.com>
References: <95702994-6762-e42b-06ee-ae945c2137bd@nvidia.com>
         <ab485d7ba4f9603850b81e6c2242dc25026eabcb.camel@hammerspace.com>
         <88677895-7f89-ae1d-3060-819f4b04f530@nvidia.com>
         <9b9a6c5e34edea13b3ace42d39d97c27fd21c0db.camel@hammerspace.com>
         <20190226183340.GD39872@atomide.com>
In-Reply-To: <20190226183340.GD39872@atomide.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 2ccb5f8d-613b-4013-8368-08d69c2aa033
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2573;
x-ms-traffictypediagnostic: SN6PR13MB2573:
x-ms-exchange-purlcount: 1
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyNTczOzIzOkRHVWVGeGpGTmtFK0ZKUTJPTXRvYzdpampn?=
 =?utf-8?B?VGdMSFVGREJTcmM2Rm5XdzFQYVNQRlB0bi93aTZ6eko3bWNDeVY2SloxOWhp?=
 =?utf-8?B?TGhLNmNtbkYvYWEwamFiWFk3NmpNNFBHT010eEFNejRpU0kxREh0WGtqOW1N?=
 =?utf-8?B?elZiaGFaT09EQ1YrbEVhQjErdmU0VWdIVjB0WlNGMkMrNGlZY2dTSFRhR0hv?=
 =?utf-8?B?enVaV1l2Mm5NYlVmMUhFVHU3OWNCdWNnVkNwQUVNc0tBY2RHTEhyTjhGL0Ez?=
 =?utf-8?B?dWxETW5ONy90VnJRUlF4MkFIVUplNkp1UXZkZGhBVTIvSlBlUDdZenEzL3ZP?=
 =?utf-8?B?Mjg4Q1hPSHNnT2ZRVSs1QjI5dXFnbVVoRVhmSHlyL3ZtdDR5dlliMUR4N242?=
 =?utf-8?B?ZFNqeU1JUDZWTW4yR1RESElJUWZpUEFyYk16OWZ3bzB1MW9LQkRwd3dPY3BO?=
 =?utf-8?B?TWNrYkJHT3BBVkZoL1BGMWFySFJmMzE3WFpXcTNXanJyOTlBSU4xaXVMQVBu?=
 =?utf-8?B?N1lnbS85enFEaGlvc0dGVXBUdnh0ejBCdXlqTnhocms4WVpiUVUwMHQ4T01I?=
 =?utf-8?B?R0FNT2xlNkdiWTJXQTRMMzRIYzM4MlBIVytPWDlqY1ZEc3ZveSsxUi9KNnkr?=
 =?utf-8?B?bGw3WS9sTllhYzJUQis1VWxTUWJiNDR4dERCQ1FRbEtTOEphOVZ0b2RSSzlS?=
 =?utf-8?B?VEJQSG55SWhaeTd4T1RTSFp2b3k3Z3p6UEk0K2RYNi9EWlhhQ3lILzdwaDcz?=
 =?utf-8?B?SmduWlQ1MzdsbVpYaVR6ZlAwN1ZCdW4rWnc1Y3c5VjlvN005OTNYMU1PQXlQ?=
 =?utf-8?B?ZThDVkRsNUdKdTN6NlpuYWxLS29UeVBOUXQrSDJvbXZLeUUrVTVRQTlsdFVQ?=
 =?utf-8?B?cUhNL3dPTUppRmdSaU9zZ3RtYXJDd0FVcWwxMnlORklVTEE3Zmxxa2p1Q3da?=
 =?utf-8?B?QnA3NXUrVTRQZ3dPYldjV2xxaDZPUS9TKzd4MUI5cWVVekNmdWlOTWFiQjVi?=
 =?utf-8?B?bnI3Mk5XV0REc3krV0hJSi96VWJ6NUorSWREcHc2TGdsbElFR1poR3N0UGEw?=
 =?utf-8?B?bjNpemNXZDNlSTBKczIzSjRsL1RZeVNZLzZSOFJ2bktoTGRSTi8rZCsrYVNj?=
 =?utf-8?B?VTFucURTQ2d5OFBpeXJiVmZta2c5bEpNbklsMXVVQXZtR0ZIZnUyY25lV1Ra?=
 =?utf-8?B?T0ZZcDZJdXBpNkY2bnloQWhuU0MvZ2JmVFlOdHNmZHVsaG5tV0R2RkpjM1p0?=
 =?utf-8?B?ekxGZVQ2Y21TWlZvN21OR2I5TEM4UVhxVzVrcjRXaGdqTWVhNTg3clRLU1pN?=
 =?utf-8?B?V2p6M0l0NEhTZmRlV3lOY2MxZkQ2d1VlOWIydXJ5YjhzWGhEQlF3RjNzZjhM?=
 =?utf-8?B?Qy83QjNNMnp1RXRnaENEVFRWK014NDhGL3U5cE5GR3c3aWJzWk9jb1lHTUdx?=
 =?utf-8?B?ZHVRcWt4Z2cyTGNQL2NKSkhPWGhxZWM5clpxVDF4KzliZ2pzcHNLY3QzWXJ0?=
 =?utf-8?B?RDUwVFIxbnd5S3ExcjRtdm9MOEZmWGk4V2xTWXp1MWlXdDRyWkU5dVM4LzFp?=
 =?utf-8?B?QWdGMXBMVXpCcDZRc0JSdnhXWk5YMTJtOFVkS1dlblZpSHFiRDltMzFISGQ0?=
 =?utf-8?B?ZGphQkxSbVZsdi8raWxTMnJhdnQ2eUJQTTV1eVk1WnZsWnloUjZTejZ3S1BX?=
 =?utf-8?B?QUVlR0VvWGlJVDhrSlI2YzZFUTdYSHQ2cU5vY0xISXgrZ0lPOWxFbHFwOVpD?=
 =?utf-8?B?aWhHdnVyaDdwSXFNZFpHVmVCSUtFSklyTVZpNkxyd2xsV1hCMnJreVVvaDFv?=
 =?utf-8?B?d0xiRFArTFgxUHVkN3JxY2RzNC9WWURoYVlUVm9pZndGQkN5cnZZOGFPd0Zl?=
 =?utf-8?Q?3KheNJzXOWEdSRxtJI6WcIvJh6egjTWd?=
x-microsoft-antispam-prvs: <SN6PR13MB257393607A8CEF099F431E34B87B0@SN6PR13MB2573.namprd13.prod.outlook.com>
x-forefront-prvs: 096029FF66
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(366004)(396003)(136003)(39840400004)(376002)(51234002)(199004)(189003)(8936002)(81156014)(81166006)(86362001)(68736007)(53936002)(71200400001)(71190400001)(446003)(76176011)(486006)(6512007)(6306002)(45080400002)(6436002)(6506007)(53546011)(102836004)(5640700003)(476003)(2616005)(256004)(14454004)(229853002)(54906003)(1730700003)(478600001)(6916009)(966005)(11346002)(2906002)(93886005)(6486002)(97736004)(186003)(25786009)(3846002)(6246003)(66066001)(6116002)(316002)(26005)(118296001)(2501003)(2351001)(99286004)(105586002)(5660300002)(106356001)(8676002)(4326008)(7736002)(305945005)(36756003);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2573;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: kCMPpFmudqJ6/YhCj85eWieXQorudZK0qnN5WJeiLPugHVwbQNu6PsmJ9Czhjqj/XKyHszhhIneikONopqRyJFpmcqjtUnEqi7gFQwAgbLCDbpDtV2fpIniesPEtIcO04M5m4/oRah7e+j5ehsUHva6aPRiQ5DIuc2FSlufN0+0ms9v+v9y964Sycv3pmg7NP31XlhCkRzpxVLkbsB8bdo8DMuXWTMO5V/R/3YBNNxeMnOnlnREbhB42KyZHM08iAwjtCk/ODNtM+6AHih+b2aob/tBa92AXT8Lqp/nQj0f0P70P8+e4YYF9kzORUwAVOoKlhwiQalgxiT5bWPFVovmGCNEDlL2yrvDnLyMuixJw5X8YJHHpXMQRlLGBAZ3Fi0JNFt4diTrhbVHMXS8zMQmktlV9SCJlxK3pAJB2T3k=
Content-Type: text/plain; charset="utf-8"
Content-ID: <3130DCFECA879F4686199B76AACCA618@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 2ccb5f8d-613b-4013-8368-08d69c2aa033
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Feb 2019 20:40:20.6111
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2573
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE5LTAyLTI2IGF0IDEwOjMzIC0wODAwLCBUb255IExpbmRncmVuIHdyb3RlOg0K
PiBIaSwNCj4gDQo+ICogVHJvbmQgTXlrbGVidXN0IDx0cm9uZG15QGhhbW1lcnNwYWNlLmNvbT4g
WzcwMDEwMSAwMDowMF06DQo+ID4gT24gTW9uLCAyMDE5LTAyLTI1IGF0IDIyOjI3ICswMDAwLCBK
b24gSHVudGVyIHdyb3RlOg0KPiA+ID4gT24gMjUvMDIvMjAxOSAyMTowMywgVHJvbmQgTXlrbGVi
dXN0IHdyb3RlOg0KPiA+ID4gVGhpcyBpcyBuZnNyb290LiBJIGRvbid0IHNwZWNpZnkgYW55IHBh
cnRpY3VsYXIgTkZTIHZlcnNpb24gZnJvbSANCj4gPiA+IHRoZSBrZXJuZWwgY21kbGluZSwgYnV0
IHRoaXMgaXMgc2VlbiB3aXRoIEFSTSBrZXJuZWwgY29uZmlncw0KPiA+ID4gdGVncmFfZGVmY29u
ZmlnIGFuZCBtdWx0aV92N19kZWZjb25maWcuIA0KPiA+ID4gDQo+ID4gPiBMb29raW5nIGF0IHRo
ZSBsb2dzIEkgYW0gc2VlaW5nIHRoZSBmb2xsb3dpbmcgY3Jhc2ggd2hpY2ggYXBwZWFycw0KPiA+
ID4gdG8gcG9pbnQgdG8gVURQIC4uLg0KPiA+ID4gDQo+ID4gPiBbICAgIDguMDMyOTU2XSBVbmFi
bGUgdG8gaGFuZGxlIGtlcm5lbCBOVUxMIHBvaW50ZXIgZGVyZWZlcmVuY2UNCj4gPiA+IGF0DQo+
ID4gPiB2aXJ0dWFsIGFkZHJlc3MgMDAwMDAwMjQNCj4gPiA+IFsgICAgOC4wNDExMzddIHBnZCA9
IChwdHJ2YWwpDQo+ID4gPiBbICAgIDguMDQzODU4XSBbMDAwMDAwMjRdICpwZ2Q9MDAwMDAwMDAN
Cj4gPiA+IFsgICAgOC4wNDc0MzddIEludGVybmFsIGVycm9yOiBPb3BzOiA1IFsjMV0gU01QIEFS
TQ0KPiA+ID4gWyAgICA4LjA1MjA0OV0gTW9kdWxlcyBsaW5rZWQgaW46DQo+ID4gPiBbICAgIDgu
MDU1MTA0XSBDUFU6IDEgUElEOiAxMDAgQ29tbToga3dvcmtlci91OToyIE5vdCB0YWludGVkDQo+
ID4gPiA1LjAuMC0NCj4gPiA+IHJjNy1uZXh0LTIwMTkwMjIyLWc5NGE0NzUyICMxDQo+ID4gPiBb
ICAgIDguMDYzNjk5XSBIYXJkd2FyZSBuYW1lOiBOVklESUEgVGVncmEgU29DIChGbGF0dGVuZWQg
RGV2aWNlDQo+ID4gPiBUcmVlKQ0KPiA+ID4gWyAgICA4LjA2OTk2MF0gV29ya3F1ZXVlOiB4cHJ0
aW9kIHhzX3VkcF9kYXRhX3JlY2VpdmVfd29ya2ZuDQo+ID4gPiBbICAgIDguMDc1MzUzXSBQQyBp
cyBhdCB1ZHBfcG9sbCsweDMwLzB4NjQNCj4gPiA+IFsgICAgOC4wNzkxNzhdIExSIGlzIGF0IHVk
cF9wb2xsKzB4MTAvMHg2NA0KPiA+IA0KPiA+IFRoYW5rcyEgSSBzZWUgd2hhdCB0aGUgaXNzdWUg
aXMgbm93IGFuZCBJJ2xsIGJlIGZpeGluZyBpdCBBU0FQLg0KPiANCj4gSSdtIHNlZWluZyB0aGlz
IGFsc28gd2l0aCBORlNyb290LiBJIGNhbiB0ZXN0IHRoZSBmaXggd2hlbiBhdmFpbGFibGUsDQo+
IHRoYXQgaXMgaWYgeW91IGNhbiBwbGVhc2UgQ2MgbWUgb24gdGhlIGZpeC4NCj4gDQo+IFRoYW5r
cywNCj4gDQo+IFRvbnkNCg0KSSd2ZSBhcHBsaWVkIHRoZSBmb2xsb3dpbmcgcGF0Y2ggdG8gbXkg
J3Rlc3RpbmcnIGJyYW5jaDogDQpodHRwOi8vZ2l0LmxpbnV4LW5mcy5vcmcvP3A9dHJvbmRteS9s
aW51eC1uZnMuZ2l0O2E9cGF0Y2g7aD1hNzM4ODFjOTZkNzNlZTcyYjdkYmJkMzhhNmVlZWY2NjE4
MmE4ZWY3DQoNCkl0IGhhcyBzbyBmYXIgc3Rvb2QgdXAgdG8gdGVzdGluZyBvbiBteSBzaWRlLCBz
byBJJ20gZXhwZWN0aW5nIHRvIHB1c2gNCml0IHRvIGxpbnV4LW5leHQgdGhpcyBldmVuaW5nLg0K
DQpDaGVlcnMNCiAgVHJvbmQNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50
IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29t
DQoNCg0K
