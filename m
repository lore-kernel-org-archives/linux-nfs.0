Return-Path: <SRS0=kagm=SN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AB6BC10F13
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 19:50:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EF3EA2070D
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 19:50:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="q7vFMGcc"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726661AbfDKTuV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 11 Apr 2019 15:50:21 -0400
Received: from mail-eopbgr700090.outbound.protection.outlook.com ([40.107.70.90]:20161
        "EHLO NAM04-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726629AbfDKTuU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 11 Apr 2019 15:50:20 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ZCNwvq7nCNeZewGKcABQZx/6B/OKoGosGIAJjvyq0F4=;
 b=q7vFMGccET9mKN46l10B9ay/xT+4O0ON09rM1YsPxWf1uaRYGF5Wk/R1hxQBMiUE3VwVoMJROIOXX7TkK6IwoAmKGo3W5Hl9jSwKr+s1BDOPs8CJEvYdPTqRaErph18b6ct9//erfGy/FHCCOqmYVVKUrUiISWlvFYZ/QY1/wb0=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2574.namprd13.prod.outlook.com (52.135.96.22) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1792.7; Thu, 11 Apr 2019 19:50:16 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1792.007; Thu, 11 Apr 2019
 19:50:16 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "daniel@zonque.org" <daniel@zonque.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: 5.1.0-rc4: Oops in __rpc_execute() when trying to boot from NFS
Thread-Topic: 5.1.0-rc4: Oops in __rpc_execute() when trying to boot from NFS
Thread-Index: AQHU7i3XWMBYs7+7DEGG17GL2cVEYaYym9UAgAFpbICAAAiIgIAAEFmAgANFEIA=
Date:   Thu, 11 Apr 2019 19:50:15 +0000
Message-ID: <be1368dce21d38bb1e90d2c84671ed51498d77ea.camel@hammerspace.com>
References: <0412f79c-61a8-bfa4-26ce-1083a59d31e8@zonque.org>
         <ce6d2388a9214f95cc38de5ec225cba26cf63b0d.camel@hammerspace.com>
         <4f4bb4a9-f752-f9f4-41cd-5c41d6191308@zonque.org>
         <7bdd83d7c2442d8096612ad3f821af556dd96015.camel@hammerspace.com>
         <78dbd13a-9a91-9a67-eaa6-ea7f0190898b@zonque.org>
In-Reply-To: <78dbd13a-9a91-9a67-eaa6-ea7f0190898b@zonque.org>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b0c3148e-7587-42e0-c81c-08d6beb6ebab
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2574;
x-ms-traffictypediagnostic: SN6PR13MB2574:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs: <SN6PR13MB2574AD6EB58E853E75303503B82F0@SN6PR13MB2574.namprd13.prod.outlook.com>
x-forefront-prvs: 00046D390F
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(376002)(396003)(39830400003)(346002)(136003)(55674003)(199004)(189003)(25786009)(316002)(6246003)(93886005)(106356001)(3846002)(6116002)(8936002)(71200400001)(71190400001)(8676002)(2906002)(68736007)(86362001)(256004)(2201001)(97736004)(5660300002)(2501003)(4326008)(229853002)(2616005)(476003)(11346002)(478600001)(81156014)(6436002)(36756003)(6486002)(118296001)(305945005)(99286004)(81166006)(6306002)(53546011)(14454004)(446003)(486006)(110136005)(966005)(76176011)(6506007)(7736002)(6512007)(186003)(53936002)(26005)(102836004)(66066001)(105586002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2574;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: OyeZJKf0B93OQ43GNVimqYOKGbLb6ZjqDqmrHQTvBu85zIoWb98Kz50X4CUlNeLguQEWfkzOBI8bgIuyC2H0yGvTTKUYp/zPxQ1C2hKJqtbN1bPlcBYiuRjcmcKJilQtB6Ya7gjv0zJ2luSdmVZF7WDCROki2WcUm4oBABBJ6aJrUGeLKHd58N+WnO3zZ0/hQBLEOFDTI7BbeNo/O+2wHdTJ1/McWyIMbqq59lyxM5TJbk3JIMRV9S1hvTzn07NZ0/IlcRVgJqzfEP7rUJPwpmYu5ghYwdjrw2xdVBeuO+MGigIIDTGloOg1nDLfFa5DkTKtVF4hmfFeaTlXdpjA7521ofqV9U6XnrkKKyvZt2cHFlgzI7h/IzBSlibLWxhCRb7pwSjSvF6rwENUVLRFAuZyU6oliXTOlEf3nOUVe/0=
Content-Type: text/plain; charset="utf-8"
Content-ID: <95C2719EA46869409E8F3A981EC79B59@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b0c3148e-7587-42e0-c81c-08d6beb6ebab
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Apr 2019 19:50:16.5652
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2574
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgRGFuaWVsLA0KDQpPbiBUdWUsIDIwMTktMDQtMDkgYXQgMTk6NTQgKzAyMDAsIERhbmllbCBN
YWNrIHdyb3RlOg0KPiBPbiA5LzQvMjAxOSA2OjU1IFBNLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+ID4gT24gVHVlLCAyMDE5LTA0LTA5IGF0IDE4OjI1ICswMjAwLCBEYW5pZWwgTWFjayB3cm90
ZToNCj4gPiA+IE9uIDgvNC8yMDE5IDg6NTEgUE0sIFRyb25kIE15a2xlYnVzdCB3cm90ZToNCj4g
PiA+ID4gT24gTW9uLCAyMDE5LTA0LTA4IGF0IDE5OjAxICswMjAwLCBEYW5pZWwgTWFjayB3cm90
ZToNCj4gPiA+ID4gPiBIaSwNCj4gPiA+ID4gPiANCj4gPiA+ID4gPiBJJ20gc2VlaW5nIHRoZSBP
b3BzIGJlbG93IHdoZW4gdHJ5aW5nIHRvIGJvb3QgNS4xLjAtcmM0IG9uIGFuDQo+ID4gPiA+ID4g
QVJNDQo+ID4gPiA+ID4gUFhBM3h4DQo+ID4gPiA+ID4gcGxhdGZvcm0uIHY1LjAgZGlkIG5vdCBz
aG93IHRoaXMgZWZmZWN0IHdpdGggdGhlIHNhbWUNCj4gPiA+ID4gPiBjbWRsaW5lLg0KPiA+ID4g
PiA+IA0KPiA+ID4gPiBQbGVhc2UgZG8gYmlzZWN0IGlmIHRoYXQgaXMgYXQgYWxsIHByYWN0aWNh
bC4gSSdtIGhhdmluZw0KPiA+ID4gPiB0cm91YmxlDQo+ID4gPiA+IGludGVycHJldGluZyB0aGlz
IE9vcHMuDQo+ID4gPiANCj4gPiA+IEhlcmUgeW91IGdvOg0KPiA+ID4gDQo+ID4gPiAwMDlhODJm
NjQzNzQ5MGMyNjI1ODRkNjVhMTQwOTRhODE4YmNiNzQ3IGlzIHRoZSBmaXJzdCBiYWQgY29tbWl0
DQo+ID4gPiBjb21taXQgMDA5YTgyZjY0Mzc0OTBjMjYyNTg0ZDY1YTE0MDk0YTgxOGJjYjc0Nw0K
PiA+ID4gQXV0aG9yOiBUcm9uZCBNeWtsZWJ1c3QgPHRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFj
ZS5jb20+DQo+ID4gPiBEYXRlOiAgIFNhdCBNYXIgOSAxMjowNzoxNyAyMDE5IC0wNTAwDQo+ID4g
PiANCj4gPiA+ICAgICBTVU5SUEM6IE1pY3JvLW9wdGltaXNlIHdoZW4gdGhlIHRhc2sgaXMga25v
d24gbm90IHRvIGJlDQo+ID4gPiBzbGVlcGluZw0KPiA+ID4gDQo+ID4gPiAgICAgSW4gY2FzZXMg
d2hlcmUgd2Uga25vdyB0aGUgdGFzayBpcyBub3Qgc2xlZXBpbmcsIHRyeSB0bw0KPiA+ID4gb3B0
aW1pc2UNCj4gPiA+ICAgICBhd2F5IHRoZSBpbmRpcmVjdCBjYWxsIHRvIHRhc2stPnRrX2FjdGlv
bigpIGJ5IHJlcGxhY2luZyBpdA0KPiA+ID4gd2l0aA0KPiA+ID4gICAgIGEgZGlyZWN0IGNhbGwu
DQo+ID4gPiAgICAgT25seSBjaGFuZ2UgdGFpbCBjYWxscywgdG8gYWxsb3cgZ2NjIHRvIHBlcmZv
cm0gdGFpbCBjYWxsDQo+ID4gPiAgICAgZWxpbWluYXRpb24uDQo+ID4gDQo+ID4gQWguLi4gSXQg
bG9va3MgbGlrZSB3ZSBleHBsaWNpdGx5IHR1cm4gb2ZmIHRhaWwgY2FsbCBvcHRpbWlzYXRpb24N
Cj4gPiBpbg0KPiA+IHNvbWUgQVJNIGNvbmZpZ3MsIHNvIHRoaXMgbWlnaHQgYmUgYSBzdGFjayBv
dmVyZmxvdy4NCj4gPiANCj4gPiBEb2VzIHlvdXIgY29uZmlnIGZpbGUgaGF2ZSBUSFVNQjJfQVZP
SURfUl9BUk1fVEhNX0pVTVAxMSBzZXQ/DQo+IA0KPiBOb3BlLiBJIGRvbid0IGV2ZW4gaGF2ZSBU
SFVNQjJfS0VSTkVMLg0KPiANCj4gSW4gdGhlIG1lYW50aW1lLCBJIHRyaWVkIHRvIHRyYWNlIHRo
YXQgd2l0aCBzb21lIHByaW50a3MsIGJ1dCB0aGUgYnVnDQo+IGFwcGVhcnMgZXZhc2l2ZSwgYW5k
IHRoZSBiYWNrdHJhY2UgY2hhbmdlcyBhcyBzb29uIGFzIEkgbW9kaWZ5IHRoZQ0KPiB0aW1pbmcu
IEhtbS4NCj4gDQo+IEhhcHB5IHRvIHRlc3QgcGF0Y2hlcyBpZiB5b3UgaGF2ZSBhbnkgaWRlYS4N
Cj4gDQoNCkNvdWxkIHlvdSBwbGVhc2UgdHJ5IHB1bGxpbmcgdGhlICd0ZXN0aW5nJyBicmFuY2gg
ZnJvbSANCmh0dHA6Ly9naXQubGludXgtbmZzLm9yZy8/cD10cm9uZG15L2xpbnV4LW5mcy5naXQ7
YT1zaG9ydGxvZztoPXJlZnMvaGVhZHMvdGVzdGluZw0KDQppLmUuICdnaXQgcHVsbCBnaXQ6Ly9n
aXQubGludXgtbmZzLm9yZy9wcm9qZWN0cy90cm9uZG15L2xpbnV4LW5mcy5naXQNCnRlc3Rpbmcn
DQoNCnRvIHNlZSBpZiB0aGF0IHN1ZmZpY2VzIHRvIGZpeCB0aGUgaXNzdWUgeW91J3JlIHJlcG9y
dGluZz8NCg0KVGhhbmtzDQogIFRyb25kDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZT
IGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNw
YWNlLmNvbQ0KDQoNCg==
