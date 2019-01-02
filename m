Return-Path: <SRS0=5e7g=PK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5F81C43387
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jan 2019 18:45:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6203B218D3
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jan 2019 18:45:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Z2bteC7j"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728297AbfABSpy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Jan 2019 13:45:54 -0500
Received: from mail-eopbgr690108.outbound.protection.outlook.com ([40.107.69.108]:56425
        "EHLO NAM04-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728202AbfABSpx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 2 Jan 2019 13:45:53 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ZumHpUKC1ASSJb+r3bkWamd6eVgPLQ4RypQjwlVs6jg=;
 b=Z2bteC7jd5U47slQ8/cs5GjrtFpj3ISvWJZrp4SewQ3LrDd3A7zpZLVY1SXAulAQpjt6QpInVnq5WdghoXBF9oOLd2qyvjLQNepRAwJoeXoJ2awmxYZrMu9nO+dy4hhJhMadJAYLnkSLVy8krWGZVNNbQ3yE05widIcistVlIAk=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2238.namprd13.prod.outlook.com (52.135.93.151) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1495.6; Wed, 2 Jan 2019 18:45:49 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%3]) with mapi id 15.20.1495.005; Wed, 2 Jan 2019
 18:45:49 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 26/44] SUNRPC: Improve latency for interactive tasks
Thread-Topic: [PATCH v3 26/44] SUNRPC: Improve latency for interactive tasks
Thread-Index: AQHUTob5qK09WaTXZkeMo/gY+CHqD6WTldAAgAAwIgCAAAW4AIAF/x2AgAAJ4YCAAAQ7gIAAAqsAgAACmQCAAADYgIADEu6AgAAHwwA=
Date:   Wed, 2 Jan 2019 18:45:48 +0000
Message-ID: <1fa9f43b6cc2ba5d4ebd24955bf76454bfab0c18.camel@hammerspace.com>
References: <c4bd04d525a1355e3dfff054985d697f0f391816.camel@hammerspace.com>
         <07dcc1731996d6e59d882c5e4e7e7765d013c337.camel@hammerspace.com>
         <E9A190A9-4A55-4D02-9259-2F26BC41F16C@oracle.com>
In-Reply-To: <E9A190A9-4A55-4D02-9259-2F26BC41F16C@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2238;6:y8q5OEXV6HuxDI9l8OmN3L1qGdStzqwhMKRUp537YwMmkEyDNSxpV6clHu3yQU5IQTIuog3q6scRx4Tze+fWkYy5/lIfH8TLm7yiUL41A+3spMyVgZO+HUwIy/dCFLFAJYLZ/Cv+pBsSafZY+A43v5aMsE09ks1C8+Ed8huJJkm7EyHaFDgSUKnzBaWIn9G6ZuauIZJAGAUPnMduHkBIw60/9Wy7wZEw/Zsa3N4XG/qx7XjZBmJO7spXVq+let7dDTNn1tlWcCqMHxMty5vF0/5LIj79os6FRA0Lz8WBhCAlWKg6j70QHDX1DfaPoS3UmpqdbsnmsVF1z4+klcQwfRvH4bYxs59dcLRG0Hzl98xqo+gj3vUrRMOIRovt+0i6QRQ8hBMQSc15Gwx4fHyYPfm5IZZQUDvkI0yunUOPBcd1YgPUrYH4oJq+oi4NNxKmenSEs7RqlUr8hRGeZ96e2w==;5:a+RqCv0ZmFbMPtR3v+4c28DzALdQsF1xPF6RuVU6e8hlIC8s9pucnUh+4L7h6yjpdeujyIZtK0Lrw/194Q0G6bZsMhRBOxSL70U1Y8N+y6IZpRXx3X1rsmi3zZZdNVCCGRUOkZVIYJDn54HL3C5H96cAVhlCcc156n6jiHQMYpoetUDvMJPHsOWmiTXv6SdFMy7ukc9lx1jf+fE9lABynA==;7:R5UWpdWxAbvlcrGiELGIfsXisiw7rPm9NNoyGXqcvchp7NlLxwGNhZTAJ15yJYkTK6gGRYQ7kZunYvQodjtV3sBT6/Z4KYgFwOl5idVGCGbgwwUk+S+tGyp8njIhlg8XQZeE1OD/nS2pIRVwN7kWdQ==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: be4d2802-5a98-423b-a2ce-08d670e2838f
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2238;
x-ms-traffictypediagnostic: SN6PR13MB2238:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-prvs: <SN6PR13MB2238D0296778A28974ED9264B88C0@SN6PR13MB2238.namprd13.prod.outlook.com>
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(908002)(999002)(5005026)(6040522)(8220060)(2401047)(8121501046)(10201501046)(3231475)(944501520)(52105112)(93006095)(93001095)(3002001)(6041310)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123562045)(20161123560045)(20161123558120)(20161123564045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2238;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2238;
x-forefront-prvs: 0905A6B2C7
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39830400003)(346002)(136003)(376002)(366004)(396003)(189003)(199004)(229853002)(86362001)(6916009)(5640700003)(6436002)(6512007)(66066001)(6486002)(118296001)(2351001)(5660300001)(2906002)(478600001)(106356001)(105586002)(8676002)(71200400001)(71190400001)(81166006)(81156014)(14454004)(8936002)(305945005)(7736002)(476003)(11346002)(446003)(2501003)(25786009)(97736004)(76176011)(316002)(186003)(68736007)(26005)(4001150100001)(6506007)(102836004)(36756003)(2616005)(6246003)(53546011)(53936002)(486006)(6116002)(99286004)(256004)(3846002)(14444005)(4326008);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2238;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 9vPHzEQAGRTzeJQkDX36O6hvGjZb7t2drPn+gOHWsUiWHpv6qDkRMuk0CTIhErl/COvgiq+XZOzHjcxAS0UFcXpPbz8Sz38ziv5c8VuANsOSM8P1Hhc47oXa0jPwnCNA2crkLYb7rFGEfGfHVXbhUfYtLVUYRpOmuDWyay03NDQ9m1hE3iqyzwAVCbhS+4PyePjNxSQx3/zy88KcteXI1ZqWoNO74REsGe2K0xFChjEcTPy9W6irYTe/cQyjOzs77LTHj2qxnF3yneESO8BFRt5qo7tljJ/SQKWIh0O96FDzTdz1j8yhPgVM5zLvFRYg
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <58A90725731B6044A3F253757D0BF318@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: be4d2802-5a98-423b-a2ce-08d670e2838f
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Jan 2019 18:45:49.0871
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2238
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gV2VkLCAyMDE5LTAxLTAyIGF0IDEzOjE3IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBEZWMgMzEsIDIwMTgsIGF0IDI6MjEgUE0sIFRyb25kIE15a2xlYnVzdCA8DQo+ID4gdHJv
bmRteUBoYW1tZXJzcGFjZS5jb20+IHdyb3RlOg0KPiA+IA0KPiA+IE9uIE1vbiwgMjAxOC0xMi0z
MSBhdCAxOToxOCArMDAwMCwgVHJvbmQgTXlrbGVidXN0IHdyb3RlOg0KPiA+ID4gT24gTW9uLCAy
MDE4LTEyLTMxIGF0IDE0OjA5IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4gPiA+ID4gPiBP
biBEZWMgMzEsIDIwMTgsIGF0IDE6NTkgUE0sIFRyb25kIE15a2xlYnVzdCA8DQo+ID4gPiA+ID4g
dHJvbmRteUBoYW1tZXJzcGFjZS5jb20+IHdyb3RlOg0KPiA+ID4gPiA+IA0KPiA+ID4gPiA+IA0K
PiA+ID4gVGhlIHRlc3QgZm9yIHJwY2F1dGhfeG1pdF9uZWVkX3JlZW5jb2RlKCkgaGFwcGVucyB3
aGVuIHdlIGNhbGwNCj4gPiA+IHhwcnRfcmVxdWVzdF90cmFuc21pdCgpIHRvIGFjdHVhbGx5IHB1
dCB0aGUgUlBDIGNhbGwgb24gdGhlIHdpcmUuDQo+ID4gPiBUaGUNCj4gPiA+IGVucXVldWUgb3Jk
ZXIgc2hvdWxkIG5vdCBiZSBhYmxlIHRvIGRlZmVhdCB0aGF0IHRlc3QuDQo+ID4gPiANCj4gPiA+
IEhtbS4uLiBJcyBpdCBwZXJoYXBzIHRoZSB0ZXN0IGZvciByZXEtPnJxX2J5dGVzX3NlbnQgdGhh
dCBpcw0KPiA+ID4gZmFpbGluZw0KPiA+ID4gYmVjYXVzZSB0aGlzIGlzIGEgcmV0cmFuc21pc3Np
b24gYWZ0ZXIgYSBkaXNjb25uZWN0L3JlY29ubmVjdA0KPiA+ID4gdGhhdA0KPiA+ID4gZGlkbid0
IHRyaWdnZXIgYSByZS1lbmNvZGU/DQo+ID4gDQo+ID4gQWN0dWFsbHksIGl0IG1pZ2h0IGJlIHdv
cnRoIGEgdHJ5IHRvIG1vdmUgdGhlIHRlc3QgZm9yDQo+ID4gcnBjYXV0aF94bWl0X25lZWRfcmVl
bmNvZGUoKSBvdXRzaWRlIHRoZSBlbmNsb3NpbmcgdGVzdCBmb3IgcmVxLQ0KPiA+ID4gcnFfYnl0
ZXNfc2VudCBhcyB0aGF0IGlzIGp1c3QgYSBtaW5vciBvcHRpbWlzYXRpb24uDQo+IA0KPiBQZXJo
YXBzIHRoYXQncyB0aGUgY2FzZSBmb3IgVENQLCBidXQgUlBDcyBzZW50IHZpYSB4cHJ0cmRtYSBu
ZXZlciBzZXQNCj4gcmVxLT5ycV9ieXRlc19zZW50IHRvIGEgbm9uLXplcm8gdmFsdWUuIFRoZSBi
b2R5IG9mIHRoZSAiaWYiDQo+IHN0YXRlbWVudA0KPiBpcyBhbHdheXMgZXhlY3V0ZWQgZm9yIHRo
b3NlIFJQQ3MuDQo+IA0KDQpUaGVuIHRoZSBxdWVzdGlvbiBpcyB3aGF0IGlzIGRlZmVhdGluZyB0
aGUgY2FsbCB0bw0KcnBjYXV0aF94bWl0X25lZWRfcmVlbmNvZGUoKSBpbiB4cHJ0X3JlcXVlc3Rf
dHJhbnNtaXQoKSBhbmQgY2F1c2luZyBpdA0Kbm90IHRvIHRyaWdnZXIgaW4gdGhlIG1pc29yZGVy
ZWQgY2FzZXM/DQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50
YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
