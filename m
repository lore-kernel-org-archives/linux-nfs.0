Return-Path: <SRS0=6MPh=RA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PULL_REQUEST,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 243F6C43381
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Feb 2019 17:51:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A4B3F20645
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Feb 2019 17:51:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="EPCMH9FZ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726171AbfBYRvZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 25 Feb 2019 12:51:25 -0500
Received: from mail-eopbgr690127.outbound.protection.outlook.com ([40.107.69.127]:52198
        "EHLO NAM04-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725936AbfBYRvY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Feb 2019 12:51:24 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=fnBWtqft3pXk8VheG+6PlDT0xQc3Otf/bbk2VW0h+pA=;
 b=EPCMH9FZt+6THo9FiPlBxbyY2xgCtE4MEwFQEYl6zrXTayLG95uSvpMjRlEFxP4UAdG2PUxHwT0r715SAJRu62AjWQk+becCl8s79znu76XtV48NkJO4Y4XU55MHbFMMuiTvBSuMLu8VevLvPNTaQeBPsuLpuaJcUhPbVRMuylg=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2253.namprd13.prod.outlook.com (52.135.93.154) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.11; Mon, 25 Feb 2019 17:51:22 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%4]) with mapi id 15.20.1665.012; Mon, 25 Feb 2019
 17:51:22 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "schumaker.anna@gmail.com" <schumaker.anna@gmail.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [GIT PULL] Please pull NFS client updates for 5.1
Thread-Topic: [GIT PULL] Please pull NFS client updates for 5.1
Thread-Index: AQHUyvDU6ztVPjMLJUqI0HoZ+NnKiqXwz4qA
Date:   Mon, 25 Feb 2019 17:51:21 +0000
Message-ID: <ceb01e5f018a38aa772d23d4ba0ef669b512c101.camel@hammerspace.com>
References: <486306ab8bb34942b2719b8250950727f382f5ce.camel@gmail.com>
In-Reply-To: <486306ab8bb34942b2719b8250950727f382f5ce.camel@gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 2b6cf735-8de7-4936-4db1-08d69b49da7f
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2253;
x-ms-traffictypediagnostic: SN6PR13MB2253:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyMjUzOzIzOjh4L3BYSUV0QkJBVHJPdXYvRXQ4emFIWjl2?=
 =?utf-8?B?bXJsMWFNWmJhbnhNVmxEWU9DeGhkUW9QT21sdUppaE8vR1JMRkQ0My9wT3li?=
 =?utf-8?B?T1JuYk0yd1cxcTV2WDhoWUEzM3FFUXZpMDJVY1NROUR1Ukx0aTZxcDRlNVBW?=
 =?utf-8?B?QnBORUE2TkhTZjh3VG5BY2Y1NjdnSmlDcllzL1Bhd1dSN0orTHJ2SWhjNE5a?=
 =?utf-8?B?SmJhWFFuV2kzeFIxaSs0QXNjbWhZM3FKdE5HUXYzQnJIa3VQeENRd3I3aC82?=
 =?utf-8?B?SEZBODFHUnN1cUlyT1BlbDBxTXN1NHVmMEhQYk9YcEhPRk9PT0U4SDR5NUZ6?=
 =?utf-8?B?UERaZC83YjZRNHpjdHVNeXY1aVo0WDh4ZkVsUmMwb1hsQUZ4NkprUk04QjdY?=
 =?utf-8?B?Y1l1RW1jTEttYmpkS05JVk13T01ocEZkVXB6MzJiZDZ6TW1XcFZEc2l2alR1?=
 =?utf-8?B?aXN6Ri84czYxc2ZESUhLMnkrTmppbk9XSVAxUEIzTFNmNGx0NC93bkNrQ256?=
 =?utf-8?B?UmlNUWF1eFJYYjZQMjh5U1pzQmJrcTRDOXoyWFBneCtmWnJ1ckNWWU55RFVS?=
 =?utf-8?B?RGxWcld5N1lnMnFzN3FmalBkSk9kcVRKaXBNYm9SQUoxVzhWcnMybG5FR0xr?=
 =?utf-8?B?em1zeEFSd0xMdnd4T0s4WXBjNzhrS2pYOURhQ2FRM0hIMm9Cbkd5L3JSSjI2?=
 =?utf-8?B?ZVUrcGtLQVpvazNuWkZ3eUNwL0RYZjAyTExqS1ZUZkprT3Vqd0NhREU4M01M?=
 =?utf-8?B?VzlLU2crNHoyMmFPS3l0WTVqRUVlV0wyR0dnUXMzcmtkdjF0SWF1K25Sd29B?=
 =?utf-8?B?cjdXYjZkSXpoZUFIb3RMMjh6SHlhTzZwN2Z6andJTnN2dTliSmd3WVhhcW9K?=
 =?utf-8?B?b0hxdllVYkhZTzVnY09uMEZvZzJtZHEwK1NqaW5PamJOTzMwYXRlc1JVVmVP?=
 =?utf-8?B?SlpScjF2WkNldE55N2tnM09PZDRxWTBnKzhFdXArYnByS3huVnJHV3hkU01m?=
 =?utf-8?B?K1B4UHUvcWVJVllYYW9Ra2RhQ3JVR3BxUmxyY2M4ODRlOXpaMEhLL2dxa21i?=
 =?utf-8?B?dHJtN2ZaM1lLaHhYUmJESWNZK1AzVUxsV0c2S05KQWxCZHQzZGYvL0ppeWtQ?=
 =?utf-8?B?aTNKZE1kME1Cckl6R0g4NS9wc2t4K3Y0ekNhVUF2K3pKb25OZ0lwakxEUzZk?=
 =?utf-8?B?Y1FxSklYbUMrdk1TZkxoa0tFc3EwOXovbXVLbnJPalhRdDdOaDhZclRSak85?=
 =?utf-8?B?b0ZKYzFtMnpvQkdwU2toQmk5Zkw3N3Y2UzZFWWc1blFIcVg5ZHdvMUl1ODI1?=
 =?utf-8?B?SmlUWWhkOW5QcmppcGhCT29UVFpXTUZIbzhLN1lGSG9qWll1NlJFRGs2eEVO?=
 =?utf-8?B?UUZua0Y4N1huLzN2WDY4djR1a2kxWVh6eWlaeDhlc0xjc053bjlsb2ZCT0FS?=
 =?utf-8?B?RWQwV0syaCtLOEsvV3E1YjZZalBqOEpTUkJoR0w4VU9vQS9OcEh6TDIycmND?=
 =?utf-8?B?OEx4c1YxQVFwUXVSQWx2VlBzdktISG5zRkhmclJOV2tVZE9GNmdkRXQ2WFY2?=
 =?utf-8?B?eEFUYzJDS2pHOG5xRVhXN3RRZHo1WjU2TVhNbmRieDhyOVJGRU1Sb3JsOXJD?=
 =?utf-8?B?WWhXcXVBbUZUREhuSGRLMGFYZDYvUGlYdWs0Qi9ncHcrNDlmU3hOK0N1TjB2?=
 =?utf-8?Q?izXrtdWBPxjaXVY4R4=3D?=
x-microsoft-antispam-prvs: <SN6PR13MB22537D83BFEEC20726F364CFB87A0@SN6PR13MB2253.namprd13.prod.outlook.com>
x-forefront-prvs: 095972DF2F
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(396003)(376002)(136003)(39830400003)(366004)(189003)(199004)(316002)(1361003)(81166006)(8936002)(6512007)(76176011)(99286004)(86362001)(256004)(53936002)(81156014)(2501003)(7736002)(14454004)(97736004)(478600001)(305945005)(6246003)(6486002)(2906002)(25786009)(26005)(66066001)(71190400001)(105586002)(71200400001)(8676002)(3846002)(106356001)(5660300002)(476003)(68736007)(4326008)(11346002)(486006)(118296001)(6916009)(36756003)(229853002)(6436002)(6506007)(446003)(102836004)(2351001)(186003)(6116002)(5640700003)(2616005);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2253;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 1+s/vxruW0IviPArn8E1+MsJHB4TxSpv/Nn4uwFAB4YxONLLjv++tCkdVZZBsk2Bf4Bm9xVJhiz0dtPbaJoZ7ns4iYh+lyCNk2fpOzRKD25owwR6GaJgIwQiY19t6GyhtI0maGx0oCzuVsM3F5FzxGCnARe98lFRx36x71E9xoWRKV4xA12+2fEPFejHfUTaFKMhLlucXAN3e6pK9H6eEO05n5cClp/3Q/IK8eph0LtR9JyrRz3EQGmlUla5OMx/txNDuXJdVdwYpbUn++uSxO8kIJ194LdT9XNWAm37UGakx0mCIrQlhNSEAPTEu6CCKx9MrFeaWhPQzExjVYBqpzEabg4yPXHsnU6Acsv15ILuyc6rRRMXrHSrNLDkEQeBcBv83qb/2pgAnakKEUqU0GBp7VSv7VCJ5wHKxPkZbGU=
Content-Type: text/plain; charset="utf-8"
Content-ID: <46BA43EA7600E54DA1CB7D97C96D8D91@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 2b6cf735-8de7-4936-4db1-08d69b49da7f
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Feb 2019 17:51:21.8676
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2253
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE5LTAyLTIyIGF0IDE1OjU0IC0wNTAwLCBBbm5hIFNjaHVtYWtlciB3cm90ZToN
Cj4gSGkgVHJvbmQsDQo+IA0KPiBUaGUgZm9sbG93aW5nIGNoYW5nZXMgc2luY2UgY29tbWl0DQo+
IGQxMzkzNzExNmYxZTgyYmY1MDhhNjMyNTExMWIzMjJjMzBjODVlYjk6DQo+IA0KPiAgIExpbnV4
IDUuMC1yYzYgKDIwMTktMDItMTAgMTQ6NDI6MjAgLTA4MDApDQo+IA0KPiBhcmUgYXZhaWxhYmxl
IGluIHRoZSBHaXQgcmVwb3NpdG9yeSBhdDoNCj4gDQo+ICAgZ2l0Oi8vZ2l0LmxpbnV4LW5mcy5v
cmcvcHJvamVjdHMvYW5uYS9saW51eC1uZnMuZ2l0IHRhZ3MvbmZzLXJkbWEtDQo+IGZvci01LjEt
MQ0KPiANCj4gZm9yIHlvdSB0byBmZXRjaCBjaGFuZ2VzIHVwIHRvDQo+IDJjOTRiOGVjYTFhMjZj
ZDQ2MDEwZDZlNzNhMjNkYTVmMmU5M2ExOWQ6DQo+IA0KPiAgIFNVTlJQQzogVXNlIGF1X3JzbGFj
ayB3aGVuIGNvbXB1dGluZyByZXBseSBidWZmZXIgc2l6ZSAoMjAxOS0wMi0xNA0KPiAxMTo1ODo0
NA0KPiAtMDUwMCkNCj4gDQo+IC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCj4gTmV3IGZlYXR1cmVzOg0KPiAtIENvbnZlcnQg
cnBjIGF1dGggbGF5ZXIgdG8gdXNlIHhkcl9zdHJlYW1zDQo+IC0gQ29uZmlnIG9wdGlvbiB0byBk
aXNhYmxlIGluc2VjdXJlIGVuY3R5cGVzDQo+IC0gUmVkdWNlIHNpemUgb2YgUlBDIHJlY2VpdmUg
YnVmZmVycw0KPiANCj4gQnVnZml4ZXMgYW5kIGNsZWFudXBzOg0KPiAtIEZpeCBzcGFyc2Ugd2Fy
bmluZ3MNCj4gLSBDaGVjayBpbmxpbmUgc2l6ZSBiZWZvcmUgcHJvdmlkaW5nIGEgd3JpdGUgY2h1
bmsNCj4gLSBSZWR1Y2UgdGhlIHJlY2VpdmUgZG9vcmJlbGwgcmF0ZQ0KPiAtIFZhcmlvdXMgdHJh
Y2Vwb2ludCBpbXByb3ZlbWVudHMNCj4gLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KDQpPSyBwdWxsZWQsIGJ1dCB0aGVyZSB3
ZXJlIGEgYnVuY2ggb2YgY29uZmxpY3RzIGR1ZSB0byB0aGUgc3RyZWFtIHJlY29yZA0KbWFya2Vy
IGNoYW5nZXMuIEkgYmVsaWV2ZSBJJ3ZlIGZpeGVkIHRoZW0gdXAgY29ycmVjdGx5IGJ1dCBwbGVh
c2UgdGVzdC4NCg0KVGhhbmtzDQogIFRyb25kDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51
eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFt
bWVyc3BhY2UuY29tDQoNCg0K
