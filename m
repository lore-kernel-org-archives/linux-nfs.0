Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42791C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 15:06:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CF2D32070B
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 15:06:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="t+YsDEO/"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726582AbfBVPGG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 10:06:06 -0500
Received: from mail-eopbgr680115.outbound.protection.outlook.com ([40.107.68.115]:47264
        "EHLO NAM04-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726627AbfBVPGF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Feb 2019 10:06:05 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=bl1PAW64FWGMUdcdZJ1hqXCKJk6NqlLrR+ojGgJqZkU=;
 b=t+YsDEO/xlQZ375AAm0g5GKPzrx9oxRGgnDiW/k5eaULqQufAIWdz6TqC6AjKv2OU7viXh8Fz542jZChxHP9QAzgkilGj75Sy0LXMBYlhrYnEJkP1PIOJshOkIqUTMeQZ/nUgxr1+EtBoreDnhNWw40DM/dRLlWpRouWL6n2grU=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2479.namprd13.prod.outlook.com (52.135.95.145) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.6; Fri, 22 Feb 2019 15:05:59 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%3]) with mapi id 15.20.1643.018; Fri, 22 Feb 2019
 15:05:59 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "olga.kornievskaia@gmail.com" <olga.kornievskaia@gmail.com>
CC:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "dwysocha@redhat.com" <dwysocha@redhat.com>
Subject: Re: [PATCH 1/1] SUNRPC: fix handling of half-closed connection
Thread-Topic: [PATCH 1/1] SUNRPC: fix handling of half-closed connection
Thread-Index: AQHUySyIDqRlQFwo+E+ucUjvP+DatqXrvYkAgAAZ7ACAABEcgIAABU+A
Date:   Fri, 22 Feb 2019 15:05:59 +0000
Message-ID: <05e439b3c419f3ac173feb770d3d2ae1d7500a2d.camel@hammerspace.com>
References: <20190220145650.21566-1-olga.kornievskaia@gmail.com>
         <1550837576.6456.3.camel@redhat.com>
         <a124c78ca5a5eefce34e8a84e92d87516345ee0c.camel@hammerspace.com>
         <CAN-5tyE5dm07V_8Qqse5qrLQVzrYXELM1EY2ySpCedBUBKYsLQ@mail.gmail.com>
In-Reply-To: <CAN-5tyE5dm07V_8Qqse5qrLQVzrYXELM1EY2ySpCedBUBKYsLQ@mail.gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 77253c55-3abc-4ca4-71f9-08d698d74106
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2479;
x-ms-traffictypediagnostic: SN6PR13MB2479:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyNDc5OzIzOlh5K3ZWa29McE14S3IzUmVBMllFcUZXTlJX?=
 =?utf-8?B?U1lsMmgwTHBxYlNyUFQ5UHhwZWRJbjd3eU53Nk1Mc2ZibnlEdXFBQjE4RGhs?=
 =?utf-8?B?WlpJRGtWZXlKQkpNVUs0SXB0QmdXTys1UFhGSEZZejdLdk9qRk5hZCttNnlV?=
 =?utf-8?B?MDVBQWxqaFRiVGNIalBlaDNJcG1yb1BCVEwwYWtKeG5WMDYzU1E1czdEMTND?=
 =?utf-8?B?YTlaN1VaNWgzeENzSWhXRzRWcmM4Mytuald2WWhoeVhsaHp0TDEvd0t5ODND?=
 =?utf-8?B?WTNPUFduQlpaZWNpNGUzUjB4bGJJb2tyZ3pTV0RkazcxaG4zVDQwNUt3R0pr?=
 =?utf-8?B?MUViM2ROWHdiN3ZhWGdZVnBNOC9WWTg3U1dlTUJnUUROcDNFNWJMcXFYQWFE?=
 =?utf-8?B?MkhMWTVHTzZRZDRIOUF4OHBWK080T3NkNFBsYmhHZkJ5RUphM3ZHUWxKLzBi?=
 =?utf-8?B?RHlqUnFjOEdybGhTUGdRc1djd0l1NE02cExVcEt2SjNyZ3R5V2VTV3psWmg4?=
 =?utf-8?B?Ry9FWU42SVBZOGhONndQcGJXOXl6dzZlbjZ1N3ZuTUM3ZEQwSWlGMDdCSHFX?=
 =?utf-8?B?WExhRXBXTWtXZWMremN1UFB0ZkFuZTBxNmFlWTJwZ2taSm1TZFVMRmxtLzY0?=
 =?utf-8?B?QTVhWjdyZkpKZWJOMkUrS213VnZRVDNVUlRRN3JRa0dUaklNR0Q4T3B0THZ3?=
 =?utf-8?B?bDJjRDc3bzJCNldPby9QcTRjdjdmU2k2SElIRXdjeVNSL0hrMll5MUtiQmg5?=
 =?utf-8?B?Z0R3SHp3VnRtdVBZemJLZWtuY3pkd1BQRzhrR1N4azF5MnFuMUVybXpmYlpz?=
 =?utf-8?B?TVlleW15aUNReTI2SEEyVzZXcUpIL1ByVmNMcmZjVVF3ZmhIdEoxbjdlL1Iw?=
 =?utf-8?B?a21QbGsvbUxJRHpCNFRacG5RTGxPNXVRS2NlQXNJdTliU3lKU3hGak52VGRr?=
 =?utf-8?B?a1hId3Q4ek5NOFNCbnpYWThkSmZqaWRDWVRKTnVvTDJPaE5zQkxwa003Ykgw?=
 =?utf-8?B?MnlTSVdCaU9SRDV1V2s2SmtVMW05a1Y2S2NyQnkzTDh6R3VqdERQTThlRkVS?=
 =?utf-8?B?bUNNVXY4V0ZHZmRjYkNQa2p6OVBoTjJkL1JiemxRbkM3MjMxdG5IVHFsR056?=
 =?utf-8?B?c2ozK1A3YVp5Y3JTaXhLSEtNK0RhV3VlT3BkWGlUZ3ViNno0OHBabVRvRk4r?=
 =?utf-8?B?Wk9ST2JYdkYwRmNQODBEZ2IxUXNBL3dDKzU2cnZXUHk2enRXVVkweHJIY05i?=
 =?utf-8?B?dHRMR2w5WDg2KzQ3WHV5dXdXMitBdWluMkNsTlVDcnpjYkVOU1cvc0hDN3N5?=
 =?utf-8?B?Q24xcWsvVHVLbmJZdWVYQmg2WlZmSjBCckRkSkJaV3R4dHk1OFFLYnB6U0l6?=
 =?utf-8?B?V04yVXEyTjBnV0g1NnNXTzJFUG16K3BIYWhGYUZ4bDF1WWlyUm1FRy9JZG5G?=
 =?utf-8?B?c0k4TGRCYnBCaVpsekc0dWFxTytLcHZEWnE2d1FmL0JLVWJZYm5hVStkMHhX?=
 =?utf-8?B?THFRT0lqZnN4ZzZkS21neVd3cExnNTk5c1NUYmYwNzgrMUtYK3VTb2hjMGk0?=
 =?utf-8?B?SUduNlhiNGd5ZXZiTUZubnNKa3VFWG5IYm1vTUhkMEloelNPd1hPTGxzMFJp?=
 =?utf-8?B?ZXlNSVJQdjJqTGVXNkZxLzJjUlpwd1ErTjFwb0tSSFEvYjZnTjdKU3JzS1Bl?=
 =?utf-8?B?U2ExYjlIcUFzWkxqSEFlNHBkL2JkbXZVM3dEWVgyL2dJbStFRndRaVF0LzlO?=
 =?utf-8?B?MVBCenduRzY0UTQ3VEp3Y0ZUUndiSGR4U2xGZTV4ZGh0elNrMDlpWXM0UEN6?=
 =?utf-8?B?UUNMd01CVm9QZHFWbDg0bDlKWWlEaE9HeE9oQXoxR0R3MXc9PQ==?=
x-microsoft-antispam-prvs: <SN6PR13MB2479F0D17DFDC64096CE6684B87F0@SN6PR13MB2479.namprd13.prod.outlook.com>
x-forefront-prvs: 09565527D6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(366004)(346002)(396003)(39830400003)(376002)(189003)(199004)(66066001)(105586002)(93886005)(476003)(76176011)(97736004)(6246003)(25786009)(2616005)(71190400001)(71200400001)(446003)(7736002)(305945005)(6346003)(2351001)(486006)(6916009)(316002)(14444005)(1361003)(53546011)(106356001)(256004)(6506007)(54906003)(68736007)(11346002)(14454004)(102836004)(99286004)(186003)(8936002)(8676002)(229853002)(6436002)(2906002)(118296001)(4326008)(26005)(6486002)(478600001)(5640700003)(6512007)(2501003)(86362001)(5660300002)(36756003)(3846002)(53936002)(81156014)(81166006)(6116002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2479;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: FRmtfevdgNpxmE58GRb90bzlxUvw2SjOZiqeLx9gH5VrZYc6uSINa5VD60kbC/KY1B36Frs/twT2mh9AUjiyib2OSWC/5t2UPkP6XnXyvStKp6A6JFOnmZxgDG0phYS+yYj4dqozi42UbaIiHj+MWp16S1E5s3f8L1gktLNQlhvrXVRGHNNsEVXmbi8ncdMlB3JvCtylktI/i6meYUdNpFq8EM4U8tCCLRRba84brhoyksvyzA/4q5/KwfwD3gxkr2pZN7B5LFNTWjfEHa6wyhYYh5sMUVnNICBcCxSq6HMUF36rS1Y6PLnlJXlhbK70n9CYA54RyMLGYD9HLzc/4nuIgLTya4lu3xw7E94VJK2bwAIKthEonF6V8DOxAdWbbDAMpUGPjUcxuW+NN8SpiVI+kYAf2f6T8oBSk9/iGrc=
Content-Type: text/plain; charset="utf-8"
Content-ID: <81D764A6C5C3704683444ECB70C6A125@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 77253c55-3abc-4ca4-71f9-08d698d74106
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Feb 2019 15:05:59.4915
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2479
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE5LTAyLTIyIGF0IDA5OjQ2IC0wNTAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90
ZToNCj4gT24gRnJpLCBGZWIgMjIsIDIwMTkgYXQgODo0NSBBTSBUcm9uZCBNeWtsZWJ1c3QgPA0K
PiB0cm9uZG15QGhhbW1lcnNwYWNlLmNvbT4gd3JvdGU6DQo+ID4gT24gRnJpLCAyMDE5LTAyLTIy
IGF0IDA3OjEyIC0wNTAwLCBEYXZlIFd5c29jaGFuc2tpIHdyb3RlOg0KPiA+ID4gSGkgT2xnYSwN
Cj4gPiA+IA0KPiA+ID4gRG8geW91IGhhdmUgYSByZXByb2R1Y2VyIGZvciB0aGlzPyAgQSBudW1i
ZXIgb2YgbW9udGhzIGFnbyBJIGRpZA0KPiA+ID4gYQ0KPiA+ID4gc2lnbmlmaWNhbnQgYW1vdW50
IG9mIHRlc3Rpbmcgd2l0aCBoYWxmLWNsb3NlZCBjb25uZWN0aW9ucywgYWZ0ZXINCj4gPiA+IHdl
DQo+ID4gPiBoYWQgcmVwb3J0cyBvZiBjb25uZWN0aW9ucyBzdHVjayBpbiBGSU5fV0FJVDIgaW4g
c29tZSBvbGRlcg0KPiA+ID4ga2VybmVscy4NCj4gPiA+IFdoYXQgSSBmb3VuZCB3YXMgd2l0aCBr
ZXJuZWxzIHRoYXQgaGFkIHRoZSB0Y3Aga2VlcGFsaXZlcyAoY29tbWl0DQo+ID4gPiA3ZjI2MGU4
NTc1YmY1M2I5M2I3Nzk3OGMxZTM5ZjhlNjc2MTI3NTljKSwgSSBjb3VsZCBvbmx5IHJlcHJvZHVj
ZQ0KPiA+ID4gYQ0KPiA+ID4gaGFuZyBvZiBhIGZldyBtaW51dGVzLCBhZnRlciB3aGljaCB0aW1l
IHRoZSB0Y3Aga2VlcGFsaXZlIGNvZGUNCj4gPiA+IHdvdWxkDQo+ID4gPiByZXNldCB0aGUgY29u
bmVjdGlvbi4NCj4gPiA+IA0KPiA+ID4gVGhhdCBzYWlkIGl0IHdhcyBhIHdoaWxlIGFnbyBhbmQg
c29tZXRoaW5nIHN1YnRsZSBtYXkgaGF2ZQ0KPiA+ID4gY2hhbmdlZC4NCj4gPiA+IEFsc28gSSdt
IG5vdCBub3Qgc3VyZSBpZiB5b3VyIGhlYWRlciBpbXBsaWVzIGFuIGluZGVmaW5pdGUgaGFuZw0K
PiA+ID4gb3INCj4gPiA+IGp1c3QNCj4gPiA+IGEgZmV3IG1pbnV0ZXMuDQo+ID4gPiANCj4gPiA+
IFRoYW5rcy4NCj4gPiA+IA0KPiA+ID4gDQo+ID4gPiBPbiBXZWQsIDIwMTktMDItMjAgYXQgMDk6
NTYgLTA1MDAsIE9sZ2EgS29ybmlldnNrYWlhIHdyb3RlOg0KPiA+ID4gPiBGcm9tOiBPbGdhIEtv
cm5pZXZza2FpYSA8a29sZ2FAbmV0YXBwLmNvbT4NCj4gPiA+ID4gDQo+ID4gPiA+IFdoZW4gc2Vy
dmVyIHJlcGxpZXMgd2l0aCBhbiBBQ0sgdG8gY2xpZW50J3MgRklOL0FDSywgY2xpZW50DQo+ID4g
PiA+IGVuZHMNCj4gPiA+ID4gdXAgc3R1Y2sgaW4gYSBUQ1BfRklOX1dBSVQyIHN0YXRlIGFuZCBj
bGllbnQncyBtb3VudCBoYW5ncy4NCj4gPiA+ID4gSW5zdGVhZCwgbWFrZSBzdXJlIHRvIGNsb3Nl
IGFuZCByZXNldCBjbGllbnQncyBzb2NrZXQgYW5kDQo+ID4gPiA+IHRyYW5zcG9ydA0KPiA+ID4g
PiB3aGVuIHRyYW5zaXRpb25lZCBpbnRvIHRoYXQgc3RhdGUuDQo+IA0KPiBIaSBUcm9uZCwNCj4g
DQo+ID4gU28sIHBsZWFzZSBkbyBub3RlIHRoYXQgd2UgZG8gbm90IHdhbnQgdG8gaWdub3JlIHRo
ZSBGSU5fV0FJVDINCj4gPiBzdGF0ZQ0KPiANCj4gQnV0IHdlIGRvIGlnbm9yZSB0aGUgRklOX1dB
SVQyIHN0YXRlLg0KDQpXZSBkbyBub3QuIFdlIHdhaXQgZm9yIHRoZSBzZXJ2ZXIgdG8gc2VuZCBh
IEZJTiwgd2hpY2ggaXMgcHJlY2lzZWx5IHRoZQ0KcmVhc29uIGZvciB3aGljaCBGSU5fV0FJVDIg
ZXhpc3RzLg0KDQo+IA0KPiA+IGJlY2F1c2UgaXQgaW1wbGllcyB0aGF0IHRoZSBzZXJ2ZXIgaGFz
IG5vdCBjbG9zZWQgdGhlIHNvY2tldCBvbiBpdHMNCj4gPiBzaWRlLg0KPiANCj4gVGhhdCdzIGNv
cnJlY3QuDQo+IA0KPiA+IFRoYXQgYWdhaW4gbWVhbnMgdGhhdCB3ZSBjYW5ub3QgcmUtZXN0YWJs
aXNoIGEgY29ubmVjdGlvbiB1c2luZw0KPiA+IHRoZSBzYW1lIHNvdXJjZSBJUCtwb3J0IHRvIHRo
ZSBzZXJ2ZXIsIHdoaWNoIGlzIHByb2JsZW1hdGljIGZvcg0KPiA+IHByb3RvY29scyBzdWNoIGFz
IE5GU3YzIHdoaWNoIHJlbHkgb24gc3RhbmRhcmQgZHVwbGljYXRlIHJlcGx5DQo+ID4gY2FjaGUN
Cj4gPiBmb3IgY29ycmVjdCByZXBsYXkgc2VtYW50aWNzLg0KPiANCj4gdGhhdCdzIGV4YWN0bHkg
d2hhdCdzIGhhcHBlbmluZyB0aGF0IGEgY2xpZW50IGlzIHVuYWJsZSB0byBlc3RhYmxpc2gNCj4g
YQ0KPiBuZXcgY29ubmVjdGlvbiB0byB0aGUgc2VydmVyLiBXaXRoIHRoZSBwYXRjaCwgdGhlIGNs
aWVudCBkb2VzIGFuIFJTVA0KPiBhbmQgaXQgcmUtdXNlcyB0aGUgcG9ydCBhbmQgYWxsIGlzIHdl
bGwgZm9yIE5GU3YzLg0KDQpSU1QgaXMgbm90IGd1YXJhbnRlZWQgdG8gYmUgZGVsaXZlcmVkIHRv
IHRoZSByZWNpcGllbnQuIFRoYXQncyB3aHkgdGhlDQpUQ1AgcHJvdG9jb2wgZGVmaW5lcyBGSU46
IGl0IGlzIGEgZ3VhcmFudGVlZCB0byBiZSBkZWxpdmVyZWQgYmVjYXVzZSBpdA0KaXMgQUNLZWQu
DQoNCj4gPiBUaGlzIGlzIHdoeSB3ZSBkb24ndCBqdXN0IHNldCB0aGUgVENQX0xJTkdFUjIgc29j
a2V0IG9wdGlvbiBhbmQNCj4gPiBjYWxsDQo+ID4gc29ja19yZWxlYXNlKCkuIFRoZSBjaG9pY2Ug
dG8gdHJ5IHRvIHdhaXQgaXQgb3V0IGlzIGRlbGliZXJhdGUNCj4gPiBiZWNhdXNlDQo+ID4gdGhl
IGFsdGVybmF0aXZlIGlzIHRoYXQgd2UgZW5kIHVwIHdpdGggYnVzeS13YWl0aW5nIHJlLWNvbm5l
Y3Rpb24NCj4gPiBhdHRlbXB0cy4NCj4gDQo+IFdoeSB3b3VsZCBpdCBidXN5LXdhaXQ/IEluIG15
IHRlc3RpbmcsIFJTVCBoYXBwZW5zIGFuZCBuZXcgY29ubmVjdGlvbg0KPiBpcyBlc3RhYmxpc2hl
ZD8NCg0KT25seSBpZiB0aGUgc2VydmVyIGhhcyBkcm9wcGVkIHRoZSBjb25uZWN0aW9uIHdpdGhv
dXQgbm90aWZ5aW5nIHRoZQ0KY2xpZW50Lg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXgg
TkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1l
cnNwYWNlLmNvbQ0KDQoNCg==
