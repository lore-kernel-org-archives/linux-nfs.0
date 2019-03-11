Return-Path: <SRS0=Z4n1=RO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C432C43381
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 14:30:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BAE082087F
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 14:30:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="eSrEXhwR"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727433AbfCKOap (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Mar 2019 10:30:45 -0400
Received: from mail-eopbgr750104.outbound.protection.outlook.com ([40.107.75.104]:45796
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727388AbfCKOap (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 Mar 2019 10:30:45 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=GJSZqsRlVH/wD6g4NxmwDzGzTzNTlWsNYPtXfGKJgLM=;
 b=eSrEXhwRaAKKyT69+DPPTUtLQIXLxdQVh5qQxBu3zomRgL4TIh2yXT3PYtMfNPLtQhLZqYG8j+mww1YBIuzY+Ft7SGGK6HERcObPcTahyLFz7hFlRgvUlmzSGRX3HYpIWY5KGTfXC17Zx7QZj2NmZB0H1nsh5dT0CCKggdpNnQU=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2272.namprd13.prod.outlook.com (52.135.93.161) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.11; Mon, 11 Mar 2019 14:30:40 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb%3]) with mapi id 15.20.1709.011; Mon, 11 Mar 2019
 14:30:40 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "aglo@umich.edu" <aglo@umich.edu>
CC:     "jiufei.xue@linux.alibaba.com" <jiufei.xue@linux.alibaba.com>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "joseph.qi@linux.alibaba.com" <joseph.qi@linux.alibaba.com>
Subject: Re: [bug report] task hang while testing xfstests generic/323
Thread-Topic: [bug report] task hang while testing xfstests generic/323
Thread-Index: AQHUz03JX9HUIwfLV060fPzVrzJvGKX1yrYAgABwXICAAD3OgIAASFUAgATbqoCAAAhnAIAA30IAgAChFQCAAUJngIAAZ1oAgAaw2YCAAQ8rAA==
Date:   Mon, 11 Mar 2019 14:30:40 +0000
Message-ID: <ace3659edd3efb70d3d978e108ecf1fc22ee3966.camel@hammerspace.com>
References: <fa8ca171-b260-3e5a-d69c-13f263f5bb9c@linux.alibaba.com>
         <CAN-5tyG9sUw2Oi+hbaW+KJDhvk8KT3Lb-cgU6azxq1yN+Tr=KQ@mail.gmail.com>
         <3b6597b0-41b4-255a-5ebb-cf34ad95315c@linux.alibaba.com>
         <57796366-0f08-2cfb-6f85-27d5485c07af@linux.alibaba.com>
         <ce839197cb70f3bc75413ed2e54f8baafafc01dd.camel@hammerspace.com>
         <365504c3-d785-7e4b-1dd2-c75f30c85c65@linux.alibaba.com>
         <740c1ad6c5b2afad196af34f48dda7097b5102b7.camel@hammerspace.com>
         <1417d6c8-3602-d895-a036-44031a7c1e98@linux.alibaba.com>
         <b729878b38f32053890a592a91f0645f15caa96f.camel@hammerspace.com>
         <46f5c870-f4fd-b29a-f5eb-eab39c4c1e89@linux.alibaba.com>
         <20190306160934.GB3066@fieldses.org>
         <CAN-5tyEPSDKao=83sW+voU9SPbcszZyR+XfZzcsD2-ozVa22Xg@mail.gmail.com>
In-Reply-To: <CAN-5tyEPSDKao=83sW+voU9SPbcszZyR+XfZzcsD2-ozVa22Xg@mail.gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: df3530c0-bfb2-427a-45ed-08d6a62e2319
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2272;
x-ms-traffictypediagnostic: SN6PR13MB2272:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs: <SN6PR13MB2272DBF2BEF09B8B2CF99BBFB8480@SN6PR13MB2272.namprd13.prod.outlook.com>
x-forefront-prvs: 09730BD177
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(396003)(346002)(39830400003)(366004)(136003)(189003)(199004)(102836004)(2501003)(6486002)(4326008)(105586002)(2906002)(26005)(25786009)(5660300002)(186003)(106356001)(256004)(6436002)(86362001)(36756003)(446003)(76176011)(99286004)(2171002)(66066001)(6512007)(6306002)(81156014)(81166006)(8676002)(229853002)(14444005)(476003)(2616005)(53936002)(97736004)(11346002)(93886005)(68736007)(110136005)(6506007)(54906003)(7736002)(6116002)(8936002)(118296001)(966005)(14454004)(6246003)(3846002)(486006)(71200400001)(71190400001)(316002)(305945005)(478600001)(41533002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2272;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Thly5RDwZEuOTYMsNSaKlAtnbm44WNzEwKhJX2a0ZAtGBcHeCVp98M4ohu4tviDs5IrFNAw7TNJ4t+XMt8Nix/bXRNDWiXkdrp8zHQ/wMfuBd+7EAhJRrMamX0ePkf/HWDMc/zV1J5ronK2WuDcMuAx0XZ9rMCWNwSCPZ39y2oCCXm39jQMSpMKHyl89HWUVxxm947wGX5gsgfEXflbsNfae5cMwZyvvZTZjDpI87/9fLWbLu4rCIuYQA9UumAqic/o7mSiggHHSV5ZrB1tAYBekSWA/S6++6QcUeGVAxQwYMDzNS+QOBJax7A2dV5D4Kbjuhkhzxd2z16sJr+apbasHu+Xixoy/+XHPI68QLSiUBOd1C8mxqwN6GjYhDJ89QaaLrXL3wKahJlTyIpqOC2CJoK8PJLBGEnA3753t5Dw=
Content-Type: text/plain; charset="utf-8"
Content-ID: <602C9C9FBAD065459E013E2A91CB3D0E@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: df3530c0-bfb2-427a-45ed-08d6a62e2319
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Mar 2019 14:30:40.6068
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2272
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgT2xnYSwNCg0KT24gU3VuLCAyMDE5LTAzLTEwIGF0IDE4OjIwIC0wNDAwLCBPbGdhIEtvcm5p
ZXZza2FpYSB3cm90ZToNCj4gVGhlcmUgYXJlIGEgYnVuY2ggb2YgY2FzZXMgd2hlcmUgbXVsdGlw
bGUgb3BlcmF0aW9ucyBhcmUgdXNpbmcgdGhlDQo+IHNhbWUgc2VxaWQgYW5kIHNsb3QuDQo+IA0K
PiBFeGFtcGxlIG9mIHN1Y2ggd2VpcmRuZXNzIGlzIChuZnMuc2VxaWQgPT0gMHgwMDAwMDJmNCkg
JiYgKG5mcy5zbG90aWQNCj4gPT0gMCkgYW5kIHRoZSBvbmUgbGVhZGluZyB0byB0aGUgaGFuZy4N
Cj4gDQo+IEluIGZyYW1lIDQxNTg3MCwgdGhlcmUgaXMgYW4gT1BFTiB1c2luZyB0aGF0IHNlcWlk
IGFuZCBzbG90IGZvciB0aGUNCj4gZmlyc3QgdGltZSAoYnV0IHRoaXMgc2xvdCB3aWxsIGJlIHJl
LXVzZWQgYSBidW5jaCBvZiB0aW1lcyBiZWZvcmUgaXQNCj4gZ2V0cyBhIHJlcGx5IGluIGZyYW1l
IDQxNTkwOCB3aXRoIHRoZSBvcGVuIHN0YXRlaWQgc2VxPTQwKS4gIChhbHNvIGluDQo+IHRoaXMg
cGFja2V0IHRoZXJlIGlzIGFuIGV4YW1wbGUgb2YgcmV1c2Ugc2xvdD0xK3NlcWlkPTB4MDAwMTI4
ZjcgYnkNCj4gYm90aCBURVNUX1NUQVRFSUQgYW5kIE9QRU4gYnV0IGxldCdzIHNldCB0aGF0IGFz
aWRlKS4NCj4gDQo+IEluIGZyYW1lIDQxNTg3NCAoaW4gdGhlIHNhbWUgcGFja2V0KSwgY2xpZW50
IHNlbmRzIDUgb3BlbnMgb24gdGhlDQo+IFNBTUUNCj4gc2VxaWQgYW5kIHNsb3QgKGFsbCBoYXZl
IGRpc3RpbmN0IHhpZHMpLiBJbiBhIHdheXMgdGhhdCdzIGVuZCB1cA0KPiBiZWluZw0KPiBhbHJp
Z2h0IHNpbmNlIG9wZW5zIGFyZSBmb3IgdGhlIHNhbWUgZmlsZSBhbmQgdGh1cyByZXBseSBvdXQg
b2YgdGhlDQo+IGNhY2hlIGFuZCB0aGUgcmVwbHkgaXMgRVJSX0RFTEFZLiBCdXQgaW4gZnJhbWUg
NDE1ODc2LCBjbGllbnQgc2VuZHMNCj4gYWdhaW4gdXNlcyB0aGUgc2FtZSBzZXFpZCBhbmQgc2xv
dCAgYW5kIGluIHRoaXMgY2FzZSBpdCdzIHVzZWQgYnkNCj4gM29wZW5zIGFuZCBhIHRlc3Rfc3Rh
dGVpZC4NCj4gDQo+IENsaWVudCBpbiBhbGwgdGhpcyBtZXNzIG5ldmVyIHByb2Nlc3NlcyB0aGUg
b3BlbiBzdGF0ZWlkIHNlcT00MCBhbmQNCj4ga2VlcHMgb24gcmVzZW5kaW5nIENMT1NFIHdpdGgg
c2VxPTM3IChhbHNvIHRvIG5vdGUgY2xpZW50ICJtaXNzZWQiDQo+IHByb2Nlc3Npbmcgc2VxaWQ9
MzggYW5kIDM5IGFzIHdlbGwuIDM5IHByb2JhYmx5IGJlY2F1c2UgaXQgd2FzIGENCj4gcmVwbHkN
Cj4gb24gdGhlIHNhbWUga2luZCBvZiAiUmV1c2VkIiBzbG90PTEgYW5kIHNlcT0weDAwMDEyOGY3
LiBJIGhhdmVuJ3QNCj4gdHJhY2tlZCAzOCBidXQgaSdtIGFzc3VtaW5nIGl0J3MgdGhlIHNhbWUp
LiBJIGRvbid0IGtub3cgaG93IG1hbnkNCj4gdGltZXMgYnV0IGFmdGVyIDVtaW5zLCBJIHNlZSBh
IFRFU1RfU1RBVEVJRCB0aGF0IGFnYWluIHVzZXMgdGhlIHNhbWUNCj4gc2VxaWQrc2xvdCAod2hp
Y2ggZ2V0cyBhIHJlcGx5IGZyb20gdGhlIGNhY2hlIG1hdGNoaW5nIE9QRU4pLiBBbHNvDQo+IG9w
ZW4gKyBjbG9zZSAoc3RpbGwgd2l0aCBzZXE9MzcpIG9wZW4gaXMgcmVwbGllZCB0byBidXQgYWZ0
ZXIgdGhpcw0KPiBjbGllbnQgZ29lcyBpbnRvIGEgc29mdCBsb2NrdXAgbG9ncyBoYXZlDQo+ICJu
ZnM0X3NjaGVkdWxlX3N0YXRlX21hbmFnZXI6DQo+IGt0aHJlYWRfcnVhbjogLTQiIG92ZXIgYW5k
IG92ZXIgYWdhaW4gLiB0aGVuIGEgc29mdCBsb2NrdXAuDQo+IA0KPiBMb29raW5nIGJhY2sgb24g
c2xvdCAwLiBuZnMuc2VxaWQ9MHgwMDAwMDJmMyB3YXMgdXNlZCBpbiBmcmFtZT00MTU4NjYNCj4g
YnkgdGhlIFRFU1RfU1RBVEVJRC4gVGhpcyBpcyByZXBsaWVkIHRvIGluIGZyYW1lIDQxNTg3NyAo
d2l0aCBhbg0KPiBFUlJfREVMQVkpLiBCdXQgYmVmb3JlIHRoZSBjbGllbnQgZ290IGEgcmVwbHks
IGl0IHVzZWQgdGhlIHNsb3QgYW5kDQo+IHRoZSBzZXEgYnkgZnJhbWUgNDE1ODc0LiBURVNUX1NU
QVRFSUQgaXMgYSBzeW5jaHJvbm91cyBhbmQNCj4gaW50ZXJydXB0aWJsZSBvcGVyYXRpb24uIEkn
bSBzdXNwZWN0aW5nIHRoYXQgc29tZWhvdyBpdCB3YXMNCj4gaW50ZXJydXB0ZWQgYW5kIHRoYXQn
cyB3aG8gdGhlIHNsb3Qgd2FzIGFibGUgdG8gYmUgcmUtdXNlZCBieSB0aGUNCj4gZnJhbWUgNDE1
ODc0LiBCdXQgaG93IHRoZSBzZXZlcmFsIG9wZW5zIHdlcmUgYWJsZSB0byBnZXQgdGhlIHNhbWUN
Cj4gc2xvdA0KPiBJIGRvbid0IGtub3cuLg0KDQpJcyB0aGlzIHN0aWxsIHRydWUgd2l0aCB0aGUg
Y3VycmVudCBsaW51eC1uZXh0PyBJIHdvdWxkIGV4cGVjdCB0aGlzDQpwYXRjaCANCmh0dHA6Ly9n
aXQubGludXgtbmZzLm9yZy8/cD10cm9uZG15L2xpbnV4LW5mcy5naXQ7YT1jb21taXRkaWZmO2g9
MzQ1M2Q1NzA4YjMzZWZlNzZmNDBlY2ExYzBlZDYwOTIzMDk0Yjk3MQ0KdG8gY2hhbmdlIHRoZSBM
aW51eCBjbGllbnQgYmVoYXZpb3VyIGluIHRoZSBhYm92ZSByZWdhcmQuDQoNCkNoZWVycw0KICBU
cm9uZA0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVy
LCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
